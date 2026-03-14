import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { supabase } from '../services/supabaseClient';
import InputField from '../components/ui/forms/InputField';
import { ShieldCheck, Loader2 } from 'lucide-react';
import illustration from '../assets/empty-state.png';
import logo from '../assets/logo.png';

const AuthPage = () => {
  const navigate = useNavigate();
  const [isLogin, setIsLogin] = useState(true);
  const [isLoading, setIsLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');

  // DEMO TIP: You can put your demo email and password inside these quotes to auto-fill them!
  const [formData, setFormData] = useState({
    email: '',
    password: '',
    organizationName: '' // Only used for signup
  });

  const handleChange = (e) => {
    setFormData(prev => ({ ...prev, [e.target.name]: e.target.value }));
  };

  const handleAuth = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    setErrorMsg('');

    try {
      if (isLogin) {
        // --- LOG IN ---
        const { error } = await supabase.auth.signInWithPassword({
          email: formData.email,
          password: formData.password,
        });
        if (error) throw error;
        
        // Successful login, redirect to dashboard
        navigate('/');
      } else {
        // --- SIGN UP ---
        const { error } = await supabase.auth.signUp({
          email: formData.email,
          password: formData.password,
          options: {
            data: {
              organization_name: formData.organizationName,
            }
          }
        });
        if (error) throw error;
        
        // Supabase might require email confirmation depending on your settings.
        // For a hackathon/demo, you usually turn off "Confirm Email" in the Supabase Auth settings.
        alert("Registration successful! Logging you in...");
        navigate('/');
      }
    } catch (error) {
      console.error('Auth error:', error.message);
      setErrorMsg(error.message);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex bg-slate-50">
      
      {/* LEFT SIDE - BRANDING & ILLUSTRATION (Hidden on mobile) */}
      <div className="hidden lg:flex w-1/2 bg-appPrimary/5 flex-col items-center justify-center p-12 relative overflow-hidden border-r border-appPrimary/10">
        <div className="absolute top-8 left-8">
          <img src={logo} alt="Logo" className="h-8 w-auto object-contain" />
        </div>
        
        <div className="max-w-md text-center flex flex-col items-center">
          <img 
            src={illustration} 
            alt="Hospital Management" 
            className="w-full h-auto max-w-[320px] mb-8 drop-shadow-xl"
          />
          <h2 className="text-3xl font-bold text-slate-800 tracking-tight mb-4">
            Streamline Your Hospital Operations
          </h2>
          <p className="text-slate-500 font-medium">
            Manage bed inventory, track patient triage, and optimize staff scheduling all from one centralized command center.
          </p>
        </div>
      </div>

      {/* RIGHT SIDE - AUTH FORM */}
      <div className="w-full lg:w-1/2 flex items-center justify-center p-8">
        <div className="w-full max-w-md bg-white p-8 rounded-2xl shadow-xl border border-slate-100">
          
          <div className="flex flex-col items-center mb-8">
            <div className="w-12 h-12 bg-appPrimary/10 text-appPrimary rounded-xl flex items-center justify-center mb-4">
              <ShieldCheck size={28} />
            </div>
            <h1 className="text-2xl font-bold text-slate-800">
              {isLogin ? 'Welcome Back' : 'Register Organization'}
            </h1>
            <p className="text-sm text-slate-500 mt-1">
              {isLogin ? 'Enter your credentials to access the dashboard.' : 'Create a new workspace for your hospital.'}
            </p>
          </div>

          {errorMsg && (
            <div className="mb-6 p-3 bg-rose-50 text-rose-600 text-sm font-semibold rounded-lg border border-rose-100 text-center">
              {errorMsg}
            </div>
          )}

          <form onSubmit={handleAuth} className="space-y-5">
            {!isLogin && (
              <div className="animate-in fade-in slide-in-from-top-2 duration-300">
                <InputField 
                  label="Organization Name" 
                  name="organizationName" 
                  value={formData.organizationName} 
                  onChange={handleChange} 
                  placeholder="e.g. City General Hospital" 
                  required={!isLogin} 
                />
              </div>
            )}
            
            <InputField 
              label="Work Email" 
              name="email" 
              type="email" 
              value={formData.email} 
              onChange={handleChange} 
              placeholder="admin@hospital.com" 
              required 
            />
            
            <InputField 
              label="Password" 
              name="password" 
              type="password" 
              value={formData.password} 
              onChange={handleChange} 
              placeholder="••••••••" 
              required 
            />

            <button 
              type="submit" 
              disabled={isLoading}
              className="w-full flex items-center justify-center gap-2 bg-appPrimary hover:bg-teal-700 text-white py-3 rounded-lg font-bold transition-all disabled:opacity-70 mt-2 shadow-sm"
            >
              {isLoading ? (
                <><Loader2 size={18} className="animate-spin" /> Authenticating...</>
              ) : (
                isLogin ? 'Secure Login' : 'Create Workspace'
              )}
            </button>
          </form>

          {/* TOGGLE LOGIN/SIGNUP */}
          <div className="mt-8 text-center text-sm">
            <span className="text-slate-500">
              {isLogin ? "Don't have an account? " : "Already have an account? "}
            </span>
            <button 
              onClick={() => {
                setIsLogin(!isLogin);
                setErrorMsg('');
              }}
              className="font-bold text-appPrimary hover:underline"
            >
              {isLogin ? 'Register your hospital' : 'Log in here'}
            </button>
          </div>

        </div>
      </div>
    </div>
  );
};

export default AuthPage;