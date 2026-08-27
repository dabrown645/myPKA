#!/bin/bash
# CachyOS Dual-Boot QEMU Test Environment
# Simulates: Secure Boot + TPM 2.0 + two disks (Windows + CachyOS)
# Requires: qemu-full, swtpm, edk2-ovmf-fedora (AUR)
set -euo pipefail

# ─── Defaults ──────────────────────────────────────────────────────
SECURE_BOOT="${SECURE_BOOT:-false}"
RESET_VVARS="${RESET_VVARS:-false}"
DISPLAY_BACKEND="${DISPLAY_BACKEND:-sdl,gl=on}"

VM_DIR="$HOME/VMS/qemu-cachyos-test"
DISK_DIR="$VM_DIR/disks"
TPM_DIR="$VM_DIR/tpm"
WIN_SIZE="40G"
CACHY_SIZE="100G"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info() { echo -e "${CYAN}[INFO]${NC}  $*"; }
ok() { echo -e "${GREEN}[OK]${NC}    $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC}  $*"; }
fail() {
  echo -e "${RED}[FAIL]${NC}  $*"
  exit 1
}

# ─── Dependency Check ──────────────────────────────────────────────
check_deps() {
  info "Checking dependencies..."

  local missing=()

  command -v qemu-system-x86_64 &>/dev/null || missing+=("qemu-full")
  command -v swtpm &>/dev/null || missing+=("swtpm")

  # Check for OVMF firmware based on Secure Boot setting
  local ovmf_dir="/usr/share/edk2-ovmf/x64"
  local ovmf_code="OVMF_CODE.4m.fd"
  if [[ "$SECURE_BOOT" == "true" ]]; then
    ovmf_code="OVMF_CODE.secboot.4m.fd"
  fi
  if [[ ! -f "$ovmf_dir/$ovmf_code" ]]; then
    fail "OVMF firmware not found at $ovmf_dir/$ovmf_code. Install with: sudo pacman -S edk2-ovmf"
  fi

  if ((${#missing[@]} > 0)); then
    fail "Missing packages: ${missing[*]}. Install with: sudo pacman -S ${missing[*]}"
  fi

  ok "All dependencies satisfied."
}

# ─── Create VM directory structure ────────────────────────────────
setup_dirs() {
  info "Creating VM directory at $VM_DIR ..."
  mkdir -p "$DISK_DIR" "$TPM_DIR"

  # Copy OVMF firmware to VM dir (system files are root-owned, need local copies)
  local ovmf_dir="/usr/share/edk2-ovmf/x64"
  local ovmf_code="OVMF_CODE.4m.fd"
  if [[ "$SECURE_BOOT" == "true" ]]; then
    ovmf_code="OVMF_CODE.secboot.4m.fd"
  fi

  # Copy CODE firmware
  local vm_code="$VM_DIR/$ovmf_code"
  if [[ ! -f "$vm_code" ]]; then
    cp "$ovmf_dir/$ovmf_code" "$vm_code"
    chmod 644 "$vm_code"
    ok "Copied OVMF CODE firmware ($ovmf_code)."
  else
    ok "OVMF CODE already exists ($ovmf_code)."
  fi

  # VARS: separate file per mode (preserves enrolled keys for each mode independently)
  local vars_name="OVMF_VARS.4m.fd"
  if [[ "$SECURE_BOOT" == "true" ]]; then
    vars_name="OVMF_VARS.secboot.4m.fd"
  fi

  if [[ "$RESET_VVARS" == "true" ]]; then
    cp "$ovmf_dir/OVMF_VARS.4m.fd" "$VM_DIR/$vars_name"
    chmod 644 "$VM_DIR/$vars_name"
    ok "Reset OVMF VARS ($vars_name — cleared stale boot entries)."
  elif [[ ! -f "$VM_DIR/$vars_name" ]]; then
    cp "$ovmf_dir/OVMF_VARS.4m.fd" "$VM_DIR/$vars_name"
    chmod 644 "$VM_DIR/$vars_name"
    ok "Copied fresh OVMF VARS template ($vars_name)."
  else
    ok "OVMF VARS exists ($vars_name — preserving enrolled keys)."
  fi
}

# ─── Create virtual disks ─────────────────────────────────────────
create_disks() {
  info "Creating virtual disks..."

  if [[ ! -f "$DISK_DIR/win.qcow2" ]]; then
    qemu-img create -f qcow2 "$DISK_DIR/win.qcow2" "$WIN_SIZE"
    ok "Created Windows disk: $DISK_DIR/win.qcow2 ($WIN_SIZE)"
  else
    ok "Windows disk already exists."
  fi

  if [[ ! -f "$DISK_DIR/cachy.qcow2" ]]; then
    qemu-img create -f qcow2 "$DISK_DIR/cachy.qcow2" "$CACHY_SIZE"
    ok "Created CachyOS disk: $DISK_DIR/cachy.qcow2 ($CACHY_SIZE)"
  else
    ok "CachyOS disk already exists."
  fi
}

# ─── Start software TPM 2.0 ───────────────────────────────────────
start_tpm() {
  # Kill any existing swtpm for this VM
  if [[ -f "$TPM_DIR/swtpm.pid" ]]; then
    local old_pid
    old_pid=$(cat "$TPM_DIR/swtpm.pid" 2>/dev/null || true)
    if [[ -n "$old_pid" ]] && kill -0 "$old_pid" 2>/dev/null; then
      kill "$old_pid" 2>/dev/null || true
      sleep 0.5
    fi
    rm -f "$TPM_DIR/swtpm.pid"
  fi

  info "Starting software TPM 2.0..."
  swtpm socket \
    --tpm2 \
    --tpmstate dir="$TPM_DIR" \
    --ctrl type=unixio,path="$TPM_DIR/swtpm-sock" \
    --log level=20 >/dev/null 2>&1 &
  echo $! >"$TPM_DIR/swtpm.pid"
  sleep 1

  if kill -0 "$(cat "$TPM_DIR/swtpm.pid")" 2>/dev/null; then
    ok "TPM 2.0 emulator running (PID $(cat "$TPM_DIR/swtpm.pid"))."
  else
    fail "Failed to start swtpm."
  fi
}

# ─── Launch QEMU ───────────────────────────────────────────────────
launch_vm() {
  info "Launching QEMU with Secure Boot + TPM 2.0..."
  echo ""
  echo "  ┌─────────────────────────────────────────────┐"
  echo "  │  VM Settings                                │"
  echo "  │  - Machine:  pc/i440fx (UEFI)                │"
  local secure_boot_status="DISABLED (for install)"
  local ovmf_code="OVMF_CODE.4m.fd"
  local ovmf_vars="OVMF_VARS.4m.fd"
  if [[ "$SECURE_BOOT" == "true" ]]; then
    secure_boot_status="ENABLED"
    ovmf_code="OVMF_CODE.secboot.4m.fd"
    ovmf_vars="OVMF_VARS.secboot.4m.fd"
  fi
  echo "  │  - Secure Boot: $secure_boot_status"
  echo "  │  - TPM 2.0:    ENABLED (swtpm)             │"
  echo "  │  - RAM: 8GB, CPUs: 4                        │"
  echo "  │  - Disks: win.qcow2 + cachy.qcow2          │"
  echo "  │  - NVRAM: $VM_DIR/$ovmf_vars     │"
  echo "  └─────────────────────────────────────────────┘"
  echo ""
  echo "  UEFI boot menu: Press ESC when you see the CachyOS logo."
  echo "  Device menu:    Press F12 to pick boot device."
  echo ""

  local cmd=(
    qemu-system-x86_64
    -cpu host
    -m 8G
    -smp 4
  )

  # Machine type: q35 for Secure Boot (pflash needs it), pc for non-Secure Boot
  if [[ "$SECURE_BOOT" == "true" ]]; then
    cmd+=(-machine q35,accel=kvm)
  else
    cmd+=(-machine pc,accel=kvm)
  fi

  # UEFI firmware: both modes use pflash (required for efivars/sbctl)
  local ovmf_code_file="$VM_DIR/OVMF_CODE.4m.fd"
  local ovmf_vars_file="$VM_DIR/OVMF_VARS.4m.fd"
  if [[ "$SECURE_BOOT" == "true" ]]; then
    ovmf_code_file="$VM_DIR/OVMF_CODE.secboot.4m.fd"
    ovmf_vars_file="$VM_DIR/OVMF_VARS.secboot.4m.fd"
  fi
  cmd+=(
    -drive if=pflash,format=raw,readonly=on,file="$ovmf_code_file"
    -drive if=pflash,format=raw,file="$ovmf_vars_file"
  )

  cmd+=(
    # TPM 2.0
    -chardev socket,id=chrtpm,path="$TPM_DIR/swtpm-sock"
    -tpmdev emulator,id=tpm0,chardev=chrtpm
    -device tpm-tis,tpmdev=tpm0
    # SSD 1: "Windows"
    -drive file="$DISK_DIR/win.qcow2",format=qcow2,if=none,id=drive0
    -device virtio-blk-pci,drive=drive0
    # SSD 2: "CachyOS"
    -drive file="$DISK_DIR/cachy.qcow2",format=qcow2,if=none,id=drive1
    -device virtio-blk-pci,drive=drive1
    # Display
    -vga std
  )

  # Add CD-ROM if ISO provided, boot from CD first
  if [[ -n "${1:-}" && -f "${1:-}" ]]; then
    cmd+=(-cdrom "$1")
    cmd+=(-boot order=cd,menu=on)
    info "Mounting ISO: $1"
  else
    cmd+=(-boot menu=on)
  fi

  # Display backend
  cmd+=(-display "$DISPLAY_BACKEND")

  # Dry run mode: print command and exit
  if [[ "${DRY_RUN:-false}" == "true" ]]; then
    echo ""
    echo "  Generated QEMU command:"
    printf '  %s ' "${cmd[@]}"
    echo ""
    echo ""
    return
  fi

  # Diagnostic mode: print command and pause before executing
  if [[ "${DIAG:-false}" == "true" ]]; then
    echo ""
    echo "  Generated QEMU command:"
    echo "  ${cmd[*]}"
    echo ""
    read -rp "  Press Enter to execute, or Ctrl+C to abort... "
  fi

  info "Running: ${cmd[*]}"
  "${cmd[@]}" 2>&1
}

# ─── Cleanup ────────────────────────────────────────────────────────
cleanup() {
  info "Shutting down TPM emulator..."
  if [[ -f "$TPM_DIR/swtpm.pid" ]]; then
    kill "$(cat "$TPM_DIR/swtpm.pid")" 2>/dev/null || true
    rm -f "$TPM_DIR/swtpm.pid"
  fi
  ok "Cleanup done."
}

# ─── Status ─────────────────────────────────────────────────────────
status() {
  echo ""
  echo "  VM Directory:  $VM_DIR"
  echo "  Windows Disk:  $DISK_DIR/win.qcow2"
  echo "  CachyOS Disk:  $DISK_DIR/cachy.qcow2"
  echo "  OVMF VARS:     $VM_DIR/OVMF_VARS.4m.fd (non-secure boot)"
  echo "  OVMF VARS:     $VM_DIR/OVMF_VARS.secboot.4m.fd (secure boot)"
  echo "  TPM State:     $TPM_DIR/"
  echo ""
  if [[ -f "$DISK_DIR/win.qcow2" ]]; then
    echo "  Windows disk:  $(qemu-img info --output=json "$DISK_DIR/win.qcow2" | grep -o '"virtual-size": [0-9]*' | cut -d: -f2 | xargs numfmt --to=iec)"
  fi
  if [[ -f "$DISK_DIR/cachy.qcow2" ]]; then
    echo "  CachyOS disk:  $(qemu-img info --output=json "$DISK_DIR/cachy.qcow2" | grep -o '"virtual-size": [0-9]*' | cut -d: -f2 | xargs numfmt --to=iec)"
  fi
  echo ""
}

# ─── Destroy (reset everything) ────────────────────────────────────
destroy() {
  read -rp "This will DELETE all VM disks and state. Are you sure? [y/N] " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    cleanup
    rm -rf "$VM_DIR"
    ok "VM destroyed. All disks and TPM state deleted."
  else
    info "Aborted."
  fi
}

# ─── Main ───────────────────────────────────────────────────────────
usage() {
  echo ""
  echo "  CachyOS Dual-Boot QEMU Test Environment"
  echo ""
  echo "  Usage: $0 <command> [--secure-boot] [options]"
  echo ""
  echo "  Commands:"
  echo "    launch [path/to/CachyOS.iso]   Start the VM (optionally with an ISO)"
  echo "    test-display                   Quick test: boot Secure Boot OVMF (no disks)"
  echo "    status                          Show VM disk state"
  echo "    destroy                         Delete all VM data and start fresh"
  echo "    help                            Show this help"
  echo ""
  echo "  Options:"
  echo "    --secure-boot                   Enable UEFI Secure Boot (default: disabled)"
  echo "    --reset-vvars                   Reset OVMF VARS for current mode (clear stale boot entries)"
  echo "    --display=BACKEND               Display backend (default: sdl,gl=on)"
  echo "                                    Options: sdl,gl=on | sdl | gtk | vnc=:0 | none"
  echo ""
  echo "  Note: Each mode (secure-boot vs non-secure-boot) uses its own VARS file,"
  echo "        so enrolled keys are preserved when switching between modes."
  echo "  Environment Variables:"
  echo "    SECURE_BOOT=true                Alternative way to enable Secure Boot"
  echo "    DISPLAY_BACKEND=gtk             Alternative way to set display backend"
  echo ""
  echo "  Examples:"
  echo "    $0 launch                                    # Boot with empty disks (no Secure Boot)"
  echo "    $0 launch --secure-boot                      # Boot with Secure Boot enabled"
  echo "    $0 launch --secure-boot --display=gtk        # Secure Boot + GTK display"
  echo "    $0 launch ~/Downloads/CachyOS-Germinal.iso   # Boot with CachyOS ISO"
  echo "    $0 launch --secure-boot ~/Downloads/CachyOS-Germinal.iso  # ISO + Secure Boot"
  echo ""
}

trap cleanup EXIT

# Parse flags from any position
ARGS=()
for arg in "$@"; do
  case "$arg" in
  --secure-boot)
    SECURE_BOOT="true"
    ;;
  --reset-vvars)
    RESET_VVARS="true"
    ;;
  --display=*)
    DISPLAY_BACKEND="${arg#--display=}"
    ;;
  --dry-run)
    DRY_RUN="true"
    ;;
  --diag)
    DIAG="true"
    ;;
  *)
    ARGS+=("$arg")
    ;;
  esac
done
set -- "${ARGS[@]}"

case "${1:-help}" in
launch)
  check_deps
  setup_dirs
  create_disks
  start_tpm
  launch_vm "${2:-}"
  ;;
test-display)
  info "Testing display with Secure Boot OVMF..."
  cp /usr/share/edk2-ovmf/x64/OVMF_VARS.4m.fd "$VM_DIR/OVMF_VARS.4m.fd"
  qemu-system-x86_64 \
    -machine q35,accel=kvm \
    -cpu host \
    -m 8G \
    -smp 8 \
    -drive if=pflash,format=raw,readonly=on,file=/usr/share/edk2-ovmf/x64/OVMF_CODE.secboot.4m.fd \
    -drive if=pflash,format=raw,file="$VM_DIR/OVMF_VARS.4m.fd" \
    -display "$DISPLAY_BACKEND" \
    -vga std \
    -boot menu=on 2>&1
  ;;
status)
  status
  ;;
destroy)
  destroy
  ;;
help | *)
  usage
  ;;
esac
