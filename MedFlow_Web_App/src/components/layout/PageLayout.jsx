import React from 'react';
import { Outlet, Link, useLocation } from 'react-router-dom';
import { LayoutDashboard, Bed, Users, UserPlus, Settings, Bell } from 'lucide-react';
import logoUrl from '../../assets/logo.png';

const PageLayout = () => {
  const location = useLocation();

  // Scalable navigation configuration mapped to our new features
  const navItems = [
    { name: 'Executive Overview', path: '/', icon: LayoutDashboard },
    { name: 'Patients & Admission', path: '/patients', icon: UserPlus },
    { name: 'Department Inventory', path: '/inventory', icon: Bed },
    { name: 'Staff Management', path: '/staff', icon: Users },
  ];

  // Dynamically get the current page title based on the route
  const currentTitle = navItems.find(item => item.path === location.pathname)?.name || 'Management Console';

  return (
    <div className="flex h-screen w-full bg-appBackground text-slate-800 font-sans overflow-hidden">
      
      {/* LEFT SIDEBAR */}
<aside className="w-64 border-r border-appSecondary flex flex-col bg-white">
  {/* Brand/Logo Area */}
        <div className="h-16 flex items-center px-10 border-b border-appSecondary bg-white">
          <img 
            src={logoUrl} 
            alt="Hospital Logo" 
            className="h-40 w-full object-contain object-left" 
          />
        </div>

        {/* Navigation Links */}
        <nav className="flex-1 p-4 space-y-1.5 overflow-y-auto">
          <p className="px-3 text-xs font-semibold text-slate-400 uppercase tracking-wider mb-2 mt-2">Core Operations</p>
          {navItems.map((item) => {
            const Icon = item.icon;
            const isActive = location.pathname === item.path;
            return (
              <Link
                key={item.name}
                to={item.path}
                className={`flex items-center gap-3 px-3 py-2.5 rounded-lg transition-all duration-200 ${
                  isActive 
                    ? 'bg-appPrimary/10 text-appPrimary font-semibold shadow-sm border border-appPrimary/20' 
                    : 'text-slate-600 font-medium hover:bg-appSecondary/30 hover:text-appPrimary'
                }`}
              >
                <Icon size={18} />
                <span>{item.name}</span>
              </Link>
            );
          })}
        </nav>

        {/* Bottom Settings Link */}
        <div className="p-4 border-t border-appSecondary bg-slate-50/50">
          <Link to="/settings" className="flex w-full items-center gap-3 px-3 py-2 rounded-lg text-slate-600 font-medium hover:bg-appSecondary/50 transition-colors">
            <Settings size={18} />
            <span>Settings</span>
          </Link>
        </div>
      </aside>
        
{/* MAIN CONTENT AREA */}
      <main className="flex-1 flex flex-col h-screen overflow-hidden bg-slate-50/50">
        
        {/* Minimalist Top Navigation Bar */}
        <header className="h-16 border-b border-appSecondary flex items-center justify-end px-8 bg-white shadow-sm z-10">
          
          <div className="flex items-center gap-5">
            {/* Notification Bell Only */}
            <button className="relative p-2 text-slate-500 hover:text-appPrimary hover:bg-appSecondary/30 rounded-full transition-colors">
              <Bell size={20} />
              <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-rose-500 rounded-full border-2 border-white"></span>
            </button>
          </div>
          
        </header>

        {/* Dynamic Page Content Injected Here */}
        <div className="flex-1 overflow-auto p-6 md:p-8">
          <Outlet />
        </div>
      </main>

    </div>
  );
};

export default PageLayout;