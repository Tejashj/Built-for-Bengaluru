import React, { useState, useEffect } from 'react';
import { Search, SlidersHorizontal, Plus, UserCheck, UserMinus, UserX, Activity } from 'lucide-react';
import { supabase } from '../services/supabaseClient';

const StaffManagement = () => {
  const [staffList, setStaffList] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');

  // 1. Fetch Staff Data
  const fetchStaff = async () => {
    try {
      setIsLoading(true);
      const { data, error } = await supabase
        .from('staff')
        .select('*')
        .order('role', { ascending: true }) // Groups Doctors, then Nurses, etc.
        .order('name', { ascending: true });

      if (error) throw error;
      setStaffList(data || []);
    } catch (error) {
      console.error("Error fetching staff:", error);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchStaff();
  }, []);

  // 2. Toggle "On Duty" / "Off Duty" Status
  const handleToggleStatus = async (staffId, currentStatus) => {
    // If they are on leave, don't allow a quick toggle
    if (currentStatus === 'On Leave') return; 

    const newStatus = currentStatus === 'On Duty' ? 'Off Duty' : 'On Duty';

    try {
      // Optimistic UI Update for instant feedback
      setStaffList(current => current.map(s => s.id === staffId ? { ...s, status: newStatus } : s));

      const { error } = await supabase
        .from('staff')
        .update({ status: newStatus })
        .eq('id', staffId);

      if (error) {
        // Revert if failed
        await fetchStaff();
        throw error;
      }
    } catch (error) {
      console.error("Failed to update status:", error);
      alert("Could not update staff status.");
    }
  };

  // Utility styles for Roles and Statuses
  const getRoleStyle = (role) => {
    switch(role) {
      case 'Doctor': return 'bg-blue-50 text-blue-700 border-blue-200';
      case 'Nurse': return 'bg-emerald-50 text-emerald-700 border-emerald-200';
      case 'Technician': return 'bg-purple-50 text-purple-700 border-purple-200';
      default: return 'bg-slate-50 text-slate-700 border-slate-200';
    }
  };

  const getStatusIcon = (status) => {
    switch(status) {
      case 'On Duty': return <UserCheck size={16} className="text-emerald-500" />;
      case 'Off Duty': return <UserMinus size={16} className="text-slate-400" />;
      case 'On Leave': return <UserX size={16} className="text-amber-500" />;
      default: return null;
    }
  };

  // Filter Logic
  const filteredStaff = staffList.filter(staff => 
    staff.name.toLowerCase().includes(searchQuery.toLowerCase()) || 
    staff.department.toLowerCase().includes(searchQuery.toLowerCase()) ||
    staff.role.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="flex flex-col h-full space-y-6">
      
      {/* HEADER */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-slate-800 tracking-tight">Staff Directory</h1>
          <p className="text-sm text-slate-500 mt-1">Manage personnel, shift schedules, and duty status</p>
        </div>
        <button className="flex items-center gap-2 bg-appPrimary hover:bg-teal-700 text-white px-5 py-2.5 rounded-lg font-bold shadow-sm transition-colors">
          <Plus size={18} />
          <span>Add Staff Member</span>
        </button>
      </div>

      {/* SEARCH TOOLBAR */}
      <div className="flex gap-4 bg-white p-3 rounded-xl border border-appSecondary shadow-sm">
        <div className="relative flex-1">
          <Search size={18} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
          <input 
            type="text" 
            placeholder="Search by Name, Role, or Department..." 
            className="w-full pl-10 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-appPrimary/20 focus:border-appPrimary transition-all"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>
        <button className="flex items-center gap-2 px-4 py-2 border border-slate-200 rounded-lg text-sm font-medium text-slate-600 hover:bg-slate-50 transition-colors">
          <SlidersHorizontal size={16} />
          Filters
        </button>
      </div>

      {/* DATA TABLE */}
      <div className="flex-1 overflow-hidden rounded-xl border border-slate-200 bg-white shadow-sm flex flex-col">
        <div className="grid grid-cols-6 gap-4 px-6 py-4 border-b border-slate-200 bg-slate-50 text-xs font-bold text-slate-500 uppercase tracking-wider">
          <div className="col-span-2">Personnel</div>
          <div>Role & Dept</div>
          <div>Shift Assigned</div>
          <div>Status</div>
          <div className="text-right">Quick Action</div>
        </div>

        <div className="flex-1 overflow-auto bg-slate-50/30">
          {isLoading ? (
            <div className="flex h-full items-center justify-center text-slate-400 flex-col gap-3">
              <Activity className="animate-pulse" size={32} />
              <p className="font-medium">Loading roster...</p>
            </div>
          ) : filteredStaff.length === 0 ? (
            <div className="flex h-full flex-col items-center justify-center text-slate-400 gap-2">
              <UserMinus size={40} className="text-slate-300" />
              <p className="font-medium text-center">No staff found matching your search.</p>
            </div>
          ) : (
            <div className="divide-y divide-slate-100">
              {filteredStaff.map(staff => (
                <div key={staff.id} className="grid grid-cols-6 gap-4 px-6 py-4 items-center hover:bg-slate-50 transition-colors">
                  
                  {/* Name & Contact */}
                  <div className="col-span-2 flex items-center gap-3">
                    <div className="w-10 h-10 rounded-full bg-slate-200 text-slate-600 flex items-center justify-center font-bold text-sm">
                      {staff.name.split(' ').map(n => n[0]).join('').substring(0, 2)}
                    </div>
                    <div>
                      <p className="font-bold text-slate-800">{staff.name}</p>
                      <p className="text-xs text-slate-500 font-medium">{staff.contact}</p>
                    </div>
                  </div>
                  
                  {/* Role & Department */}
                  <div className="flex flex-col items-start gap-1">
                    <span className={`px-2 py-0.5 rounded text-[10px] font-bold border ${getRoleStyle(staff.role)}`}>
                      {staff.role}
                    </span>
                    <span className="text-xs font-semibold text-slate-600">{staff.department}</span>
                  </div>

                  {/* Shift */}
                  <div className="text-sm font-medium text-slate-700">
                    {staff.shift}
                  </div>

                  {/* Status Indicator */}
                  <div className="flex items-center gap-2">
                    {getStatusIcon(staff.status)}
                    <span className={`text-sm font-bold ${
                      staff.status === 'On Duty' ? 'text-emerald-600' : 
                      staff.status === 'On Leave' ? 'text-amber-600' : 'text-slate-500'
                    }`}>
                      {staff.status}
                    </span>
                  </div>

                  {/* Quick Action Toggle */}
                  <div className="text-right">
                    <button 
                      onClick={() => handleToggleStatus(staff.id, staff.status)}
                      disabled={staff.status === 'On Leave'}
                      className={`text-xs font-bold px-3 py-1.5 rounded-md border transition-colors ${
                        staff.status === 'On Leave' 
                          ? 'bg-slate-50 text-slate-400 border-slate-200 cursor-not-allowed opacity-50'
                          : staff.status === 'On Duty'
                            ? 'text-slate-600 hover:bg-slate-100 border-slate-200'
                            : 'text-emerald-600 hover:bg-emerald-50 border-emerald-200 bg-white'
                      }`}
                    >
                      {staff.status === 'On Duty' ? 'Clock Out' : staff.status === 'Off Duty' ? 'Clock In' : 'Unavailable'}
                    </button>
                  </div>

                </div>
              ))}
            </div>
          )}
        </div>
      </div>

    </div>
  );
};

export default StaffManagement;