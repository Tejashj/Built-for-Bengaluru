import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { supabase } from './services/supabaseClient';
import { Loader2 } from 'lucide-react';

// Layout & Pages
import PageLayout from './components/layout/PageLayout';
import AuthPage from './pages/AuthPage';
import ExecutiveOverview from './pages/ExecutiveOverview';
import PatientManagement from './pages/PatientManagement';
import InventoryDashboard from './pages/InventoryDashboard';
import StaffManagement from './pages/StaffManagement';
import Settings from './pages/Settings';

// 1. The Gatekeeper Component
// If there is no active session, kick the user back to the login page
const ProtectedRoute = ({ session, children }) => {
  if (!session) {
    return <Navigate to="/login" replace />;
  }
  return children;
};

function App() {
  const [session, setSession] = useState(null);
  const [isLoading, setIsLoading] = useState(true);

  // 2. Global Authentication Listener
  useEffect(() => {
    // Check for an existing session on initial load
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      setIsLoading(false);
    });

    // Listen for login, signup, or logout events to update the app state instantly
    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session);
    });

    return () => subscription.unsubscribe();
  }, []);

  // 3. App Loading State
  if (isLoading) {
    return (
      <div className="h-screen w-screen flex flex-col items-center justify-center bg-slate-50">
        <Loader2 className="animate-spin text-appPrimary mb-4" size={48} />
        <p className="text-slate-500 font-medium tracking-wide">Securing connection...</p>
      </div>
    );
  }

  return (
    <Router>
      <Routes>
        
        {/* PUBLIC ROUTE: The Login / Signup Page */}
        {/* If they already have a session, bounce them away from the login page to the dashboard */}
        <Route 
          path="/login" 
          element={!session ? <AuthPage /> : <Navigate to="/" replace />} 
        />

        {/* SECURE ROUTES: Everything inside the PageLayout wrapper */}
        <Route 
          element={
            <ProtectedRoute session={session}>
              <PageLayout />
            </ProtectedRoute>
          }
        >
          <Route path="/" element={<ExecutiveOverview />} />
          <Route path="/patients" element={<PatientManagement />} />
          <Route path="/inventory" element={<InventoryDashboard />} />
          <Route path="/staff" element={<StaffManagement />} />
          <Route path="/settings" element={<Settings />} />
        </Route>

        {/* Catch-all: If they type a weird URL, send them to the root (which will redirect to login if logged out) */}
        <Route path="*" element={<Navigate to="/" replace />} />
        
      </Routes>
    </Router>
  );
}

export default App;