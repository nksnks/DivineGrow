# DiVineGrow
Building with Trust

Production site: https://divinegrow.co.in

## Supabase setup

The site remains static GitHub Pages-compatible. The quote form uses the Supabase JavaScript CDN and reads its project settings from `supabase-config.js`.

1. Create a Supabase project and open **SQL Editor**.
2. Run [`supabase/schema.sql`](supabase/schema.sql). It creates `enquiries` and `profiles`, indexes, and row-level security policies. Public visitors may insert enquiries; only authenticated admins may read or update them.
3. Create an email/password user in **Authentication → Users**, then promote it by inserting its UUID into `profiles`:
   `insert into public.profiles (id, role) values ('YOUR_AUTH_USER_UUID', 'admin');`
   Alternatively set the user's `user_metadata.admin` value to `true`.
4. Copy the project URL and anon key into `supabase-config.js` as `SUPABASE_URL` and `SUPABASE_ANON_KEY`. Never put a service-role key in this static site.
5. For automatic email copies, deploy `supabase/functions/notify-enquiry/index.ts` with the Supabase CLI, set `RESEND_API_KEY` and optionally `NOTIFY_FROM`, then put the deployed function URL in `SUPABASE_NOTIFY_URL`. The enquiry is still recorded if notification setup is omitted.
6. Open `admin.html` to sign in and manage enquiry/contact status. Missing config keeps the public forms graceful and explains how to contact DivineGrow directly.

The Supabase dashboard and admin page show all contact/quote submissions stored in the `enquiries` table. Admin access is controlled by the `profiles.role = 'admin'` policy; do not use editable user metadata for authorization.
