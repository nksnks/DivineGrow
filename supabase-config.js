/* Copy this file to your deployment and add your Supabase project values. */
window.SUPABASE_URL = 'https://mtlhrlkejyxflrxizopi.supabase.co';
window.SUPABASE_ANON_KEY = 'sb_publishable_uP22IU1mLx5at2M4iF6xOw_ujokeTjk';
window.SUPABASE_NOTIFY_URL = '';

if (window.SUPABASE_URL && window.SUPABASE_ANON_KEY && window.supabase) {
  window.supabaseClient = window.supabase.createClient(window.SUPABASE_URL, window.SUPABASE_ANON_KEY);
}
