import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { supabase } from '../services/supabaseClient';
import { Building2, Mail, ShieldCheck, LogOut, Loader2, Activity } from 'lucide-react';

const Settings = () => {
  const navigate = useNavigate();
  const [userData, setUserData] = useState({
    email: '',
    organizationName: '',
    createdAt: ''
  });
  const [isLoading, setIsLoading] = useState(true);
  const [isLoggingOut, setIsLoggingOut] = useState(false);

  // 1. Fetch the authenticated user's details
  useEffect(() => {
    const fetchUserProfile = async () => {
      try {
        setIsLoading(true);
        const { data: { user }, error } = await supabase.auth.getUser();
        
        if (error) throw error;
        
        if (user) {
          setUserData({
            email: user.email,
            // We pull the custom metadata we saved during signup
            organizationName: user.user_metadata?.organization_name || 'Hospital Administrator',
            createdAt: new Date(user.created_at).toLocaleDateString()
          });
        }
      } catch (error) {
        console.error("Error fetching user profile:", error);
      } finally {
        setIsLoading(false);
      }
    };

    fetchUserProfile();
  }, []);

  // 2. Secure Logout Logic
  const handleLogout = async () => {
    setIsLoggingOut(true);
    try {
      const { error } = await supabase.auth.signOut();
      if (error) throw error;
      
      // Force redirect to the login screen
      navigate('/login', { replace: true });
    } catch (error) {
      console.error("Error logging out:", error);
      alert("Failed to log out. Please try again.");
      setIsLoggingOut(false);
    }
  };

  if (isLoading) {
    return (
      <div className="flex h-full items-center justify-center text-slate-400 flex-col gap-3">
        <Activity className="animate-pulse" size={32} />
        <p className="font-medium">Loading organization profile...</p>
      </div>
    );
  }

  return (
    <div className="flex flex-col h-full space-y-6 max-w-4xl mx-auto w-full">
      
      {/* HEADER */}
      <div>
        <h1 className="text-2xl font-bold text-slate-800 tracking-tight">System Settings</h1>
        <p className="text-sm text-slate-500 mt-1">Manage your organization profile and security</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        
        {/* LEFT COLUMN: Profile Info */}
        <div className="md:col-span-2 space-y-6">
          
          {/* Organization Details Card */}
          <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-sm">
            <h2 className="text-lg font-bold text-slate-800 mb-4 flex items-center gap-2">
              <Building2 size={20} className="text-appPrimary" />
              Organization Profile
            </h2>
            
            <div className="space-y-4">
              <div className="p-4 bg-slate-50 rounded-lg border border-slate-100 flex flex-col gap-1">
                <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">Workspace Name</span>
                <span className="text-lg font-bold text-slate-800">{userData.organizationName}</span>
              </div>
              
              <div className="grid grid-cols-2 gap-4">
                <div className="p-4 bg-slate-50 rounded-lg border border-slate-100 flex items-start gap-3">
                  <Mail size={18} className="text-slate-400 mt-0.5" />
                  <div className="flex flex-col gap-1">
                    <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">Admin Email</span>
                    <span className="text-sm font-semibold text-slate-700">{userData.email}</span>
                  </div>
                </div>

                <div className="p-4 bg-slate-50 rounded-lg border border-slate-100 flex items-start gap-3">
                  <ShieldCheck size={18} className="text-emerald-500 mt-0.5" />
                  <div className="flex flex-col gap-1">
                    <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">Account Status</span>
                    <span className="text-sm font-bold text-emerald-600">Active (Admin)</span>
                    <span className="text-xs text-slate-400 mt-1">Created: {userData.createdAt}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

        </div>

        {/* RIGHT COLUMN: Security & Actions */}
        <div className="space-y-6">
          <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-sm">
            <h2 className="text-lg font-bold text-slate-800 mb-4 flex items-center gap-2">
              <ShieldCheck size={20} className="text-slate-600" />
              Security
            </h2>
            
            <p className="text-sm text-slate-500 mb-6">
              Logging out will clear your secure session and require you to authenticate again to access hospital data.
            </p>

            <button 
              onClick={handleLogout}
              disabled={isLoggingOut}
              className="w-full flex items-center justify-center gap-2 bg-rose-50 hover:bg-rose-100 text-rose-600 border border-rose-200 py-2.5 rounded-lg font-bold transition-all disabled:opacity-50"
            >
              {isLoggingOut ? (
                <><Loader2 size={18} className="animate-spin" /> Terminating Session...</>
              ) : (
                <><LogOut size={18} /> Secure Logout</>
              )}
            </button>
          </div>
        </div>

      </div>
    </div>
  );
};

export default Settings;