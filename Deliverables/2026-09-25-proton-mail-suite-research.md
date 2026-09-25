# Proton Mail Suite Research — 2026-09-25

## Executive summary
Proton Mail is a Swiss, open-source, end-to-end encrypted mail + suite (Calendar, Drive, VPN, Pass, Meet, Lumo AI). For individuals the practical entry points are Mail Plus $3.99/mo annual (15 GB, 1 custom domain) and Unlimited $9.99/mo annual (500 GB, full suite). Against Gmail/Outlook (feature-rich but ad/surveillance-based, no E2EE) and vs Tuta (cheaper, quantum-safe, but no IMAP/Bridge) and Fastmail (fast, IMAP-native, no E2EE), Proton is the best default if privacy + custom domain + everyday usability must coexist.

## Key findings

1. **Plans/pricing 2026 (High)** — Free: 1 GB mail, 1 address, 150 msgs/day, 3 folders/labels. Mail Plus: $4.99 mo / $3.99 annual ($47.88/yr), 15 GB, 10 addresses, 1 custom domain, unlimited msgs, Bridge/IMAP, catch-all, forwarding. Unlimited: $12.99 mo / $9.99 annual ($119.88/yr), 500 GB pooled, 15 addresses, 3 custom domains, full VPN (140+ countries), 50 Pass vaults, Drive version history, Sentinel. Duo $14.99 / Family $23.99 annual. Business: Mail Essentials ~$6.99/user/mo annual, Workspace Standard ~$12.99, Premium ~$19.99.
2. **Suite breadth (High)** — Mail + Calendar (E2EE sharing, appointment pages on paid), Drive (Docs/Sheets E2EE, 5 GB free / 15 GB Plus / 500 GB Unlimited), VPN Free (1 device, 10 countries) vs Unlimited (10 devices, Secure Core, NetShield, P2P, streaming), Pass (2 vaults free, 50 Unlimited), Wallet (Bitcoin via email), Meet (50 participants, 1hr), Lumo AI (limited on all tiers), Scribe writing assistant as paid add-on.
3. **Security model (High)** — End-to-end (Proton-to-Proton, PGP to externals, password-protected to anyone) + zero-access encryption at rest (provider cannot decrypt). Open-source clients, third-party audits, Key Transparency, Sentinel anomaly blocking, Dark Web Monitoring, tracker-pixel blocking via proxy.
4. **Jurisdiction + limits (Medium)** — Switzerland, strong privacy law, outside US 5-Eyes sharing. Still subject to Swiss court orders; can be compelled to log IP in criminal cases (no mailbox content — cryptographically unable). No ads/trackers, strict no-logs VPN claim.
5. **vs Gmail/Outlook (High)** — Gmail free 15 GB pooled, Workspace from ~$7/user/mo. Outlook similar. Neither offers E2EE/zero-access (TLS + at-rest only, provider holds keys, ad profiling). Proton wins privacy; loses on storage-per-dollar free tier, AI/search speed, third-party integrations.
6. **vs Tuta (Medium-High)** — Both E2EE, audited, ad-free. Tuta cheaper (~3 EUR/mo tiers), quantum-safe TutaCrypt default, free native desktop clients, no Google push dependency, encrypts subject lines. Proton advantages: PGP interop, Bridge for Outlook/Thunderbird/Apple Mail, Easy Switch importer, hide-my-email aliases unlimited on Unlimited, newsletter view, Sentinel/Dark Web, full suite (Drive/VPN/Pass). Tuta has no IMAP/SMTP/Bridge (Thunderbird add-on only), no custom-domain on free.
7. **vs Fastmail (High)** — Fastmail Individual/Standard ~$6/mo ($60/yr annual), 50 GB mail + 10 GB files, 100+ custom domains, full IMAP/SMTP, masked emails, fast search, excellent deliverability. No E2EE/zero-access (provider can access). Proton wins privacy; Fastmail wins speed, standards-compliance, client choice with no Bridge needed.
8. **Migration friction (Medium)** — Proton Easy Switch imports Gmail/Outlook/Yahoo mail+calendar+contacts, can keep sending via Gmail address inside Proton during transition. Bridge requires paid plan, decrypts locally for IMAP clients (plaintext in third-party client — expected tradeoff). Tuta→Proton via Easy Switch/IMAP export.

## Evidence
- Proton pricing grid (official, fetched Sept 2026): https://proton.me/pricing — Free/Plus/Unlimited storage, domain, Bridge, VPN tiers. Credibility: primary, High.
- Proton plans explained: https://proton.me/support/proton-plans — Free/Plus/Unlimited/Duo/Family/Visionary annual equivalents. Primary, High.
- Proton for Business plans: https://proton.me/business/plans — Essentials/Standard/Premium per-user. Primary, High.
- Proton Mail security: https://proton.me/mail/security — E2EE + zero-access, Sentinel, open-source/audited. Primary, High.
- Zero-access explainer: https://proton.me/learn/encryption/types-of-encryption/zero-access — Primary, High.
- Proton vs Tuta (official, June 2026 data): https://proton.me/mail/proton-mail-vs-tuta — IMAP/Bridge, PGP, Easy Switch deltas. Primary but vendor-biased, Medium-High, cross-checked.
- Proton vs Gmail (official): https://proton.me/mail/proton-mail-vs-gmail — E2EE vs ads/trackers table. Primary but biased, Medium, cross-checked.
- Tuta comparison Proton vs Gmail (competitor, 2026): https://tuta.com/blog/protonmail-vs-gmail — confirms Proton safer than Gmail, flags Scribe AI backlash, Bridge plaintext caveat, 150/day free limit. Secondary, Medium, useful for contradictions.
- Fastmail pricing (official): https://www.fastmail.com/pricing/ — Individual $6/$5 annual, Basic no-domain, Standard+ domain. Primary, High.
- PrivacyGuides forum thread Nov 2025 + Reddit r/PrivacyGuides threads — anecdotal Proton most expensive but best UI, Tuta no IMAP, Mailbox/Posteo tradeoffs. Low, context only.

## Methodology
1. websearch: `Proton Mail plans pricing 2026`, `Proton Mail security model audit`, `Proton vs Gmail Outlook Tuta Fastmail 2026`, `Fastmail pricing 2026`.
2. webfetch/read official pages first (proton.me/pricing, /support/proton-plans, /business/plans, /mail/security), then competitor pages (tuta.com, fastmail.com) for triangulation.
3. Compared overlapping claims (storage, domain counts, Bridge/IMAP, E2EE scope). Flagged vendor bias where Proton vs Tuta/Gmail pages omit Tuta quantum-safe lead and Proton AI criticism.

## Limitations
- Pricing varies by currency/tax/promos (USD vs EUR cited as listed; Black Friday/first-month $1 offers rotate). Verify at checkout.
- Business monthly vs annual rates inconsistently published; ~22% annual discount estimate from secondary source — Medium.
- Audit recency and post-quantum rollout status for Proton not fully verified from primary audit PDFs in this pass — treat as Medium.
- Search/throughput performance (encrypted search slower) is anecdotal — Low, needs hands-on test.

## Recommendations
1. If David's goal is de-Google with custom domain on a budget: start Mail Plus trial, test Bridge + Easy Switch with one domain.
2. If full Big-Tech replacement (mail+drive+vpn+pass): price Unlimited $119.88/yr vs Duo/Family if multi-user — Family often beats separate Unlimiteds.
3. Bookmark: proton.me/pricing, proton.me/mail/security, Easy Switch docs, Fastmail pricing for fallback if IMAP-native speed matters more than E2EE.
4. Next questions: how many custom domains/addresses needed? Need Bridge/Linux support? Need business admin/retention? Stay on Gmail for search/integrations or full cutover?

## Flags
- CRM/Orgs: Proton AG, Tuta, Fastmail, Google (Workspace/Gmail), Microsoft (Outlook) — add if tracking vendors.
- Topics: candidate `PKM/My Life/Topics/` note for Email Privacy / De-Googling if David wants ongoing tracking.
- No PKM writes made by Pax per contract.
