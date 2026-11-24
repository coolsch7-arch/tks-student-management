# TKS Student Operations v2 — English dashboard + cloud-ready sharing

## What works right now
- English responsive interface on computers, tablets, and phones.
- Dashboard grouped by **current belt**, showing **every student** with attendance count, target status, next belt, belt size, and test decision.
- Filter by belt, student, and review period.
- Student entry, attendance entry, quarterly testing, award candidates, belt orders, CSV import/export, and JSON backups.
- Without cloud configuration, data is stored **only in that browser**. It will NOT synchronize between devices.

## Enable shared access from any device (administrator setup required)
1. Create a private Supabase project at https://supabase.com . Choose an appropriate region and review privacy obligations for children's records.
2. Open Supabase **SQL Editor**, paste `schema.sql`, and run it.
3. In SQL Editor, approve your own email: `insert into public.allowed_staff(email) values ('your-email@example.com') on conflict do nothing;` . Approve other staff emails similarly. Do NOT share the SQL editor with staff.
4. In Supabase Authentication settings, enable Email OTP / magic links and configure the Site URL and redirect allowlist for your hosted HTTPS site. Confirm your project's email delivery limits and sender setup. New accounts may be created by the sign-in flow, but unapproved accounts cannot read workspace records.
5. Copy the **Project URL** and **publishable / anon** key into `config.js`. NEVER use a secret or `service_role` key in frontend code.
6. Publish `index.html` and `config.js` together using a static host such as GitHub Pages (private repo recommended for code management, but GitHub Pages publication may expose site files), Netlify, or Cloudflare Pages. Serve over HTTPS. GitHub hosts code and static pages, while Supabase stores the shared data.
7. Visit the published site, sign in with an approved email, then open **Team Access**. Copy the link or print the QR code for staff. Each staff member must use an approved email.
8. Optionally enable Supabase Realtime replication for `public.workspaces` to refresh other connected devices. If not enabled, refresh the page to see other staff changes.
9. Test using two approved devices and one unapproved email **before** entering real student records. Verify RLS and access revocation. Configure database backups and retention.

## Important limitations
- **No live public URL is created by this ZIP**. Hosting and Supabase configuration require an administrator's account access.
- QR code encodes the hosted site address, **not** a login credential. A QR scan alone never grants data access.
- The app stores all records in one shared JSON workspace. Simultaneous edits can conflict: revision checks prevent a silent overwrite but the affected editor must export a backup and refresh. Use one active editor at a time for this prototype.
- This is a prototype, not a production-ready system for sensitive student information. Before production, implement proper per-record database tables, audit history, role permissions, backups, retention rules, and security testing.
- Paper attendance photos/PDFs are **not automatically read**. Convert them to CSV and verify the extracted data first.
- “Perfect attendance” means attendance on all **recorded** class dates only. It is not proof of true perfect attendance.
- Default minimum of 24 attendances is an **example**, not an official TKS testing rule.
- For shared use, data is held in Supabase; for local demo use, data is held in the current browser. Existing v1 browser data is not automatically migrated. Export a JSON backup from v1 and restore it in v2 after cloud sign-in.

## File overview
- `index.html`: application
- `config.js`: cloud connection settings
- `schema.sql`: database and authorization setup
- `SETUP.md`: deployment and security instructions

## CSV format
Students: `id,name,currentBelt,nextBelt,beltSize,lastTest`
Attendance: `studentId,date,present` where present is 1, true, yes, 0, false, or no.
