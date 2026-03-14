import { createClient } from '@supabase/supabase-js';

// Pulling the secure keys from Vite's environment variables (.env file)
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

// Fail-safe to alert the developer if the .env file is missing
if (!supabaseUrl || !supabaseAnonKey) {
  console.error("Supabase Connection Error: Missing environment variables.");
  console.warn("Please ensure you have created a .env file at the root of your project with VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY.");
}

// Initialize and export the single Supabase client instance
export const supabase = createClient(supabaseUrl, supabaseAnonKey);