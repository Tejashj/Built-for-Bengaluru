import React, { useState, useEffect } from 'react';
import { Search, SlidersHorizontal, UserPlus, Activity, Clock, LogOut } from 'lucide-react';
import PatientOnboardingModal from '../components/ui/PatientOnboardingModal';
import { supabase } from '../services/supabaseClient';

const PatientManagement = () => {
  const [admissions, setAdmissions] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [isModalOpen, setIsModalOpen] = useState(false);

  // 1. Fetch Active Admissions (Join with the new `patientdata` table)
  const fetchActiveAdmissions = async () => {
    try {
      setIsLoading(true);
      const { data, error } = await supabase
        .from('admissions')
        .select(`
          id,
          priority,
          department,
          bed_id,
          admitted_at,
          patientdata (
            name,
            phone,
            email
          )
        `)
        .eq('status', 'Admitted')
        .order('admitted_at', { ascending: false });

      if (error) throw error;
      setAdmissions(data || []);
    } catch (error) {
      console.error("Fetch error:", error);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchActiveAdmissions();
  }, []);

  // 2. The Dynamic Admission Workflow
  const handleAdmitPatient = async (formData) => {
    try {
      // Step A: Insert into the decoupled `patientdata` table and return the new ID
      const { data: newPatient, error: patientError } = await supabase
        .from('patientdata')
        .insert([{
          name: formData.name,
          email: formData.email || null, // Optional for walk-ins
          phone: formData.phone,
          age: parseInt(formData.age),
          gender: formData.gender,
          blood_group: formData.blood_group,
          city: formData.city
        }])
        .select('id')
        .single();

      if (patientError) throw patientError;

      // Step B: Create the Admission record linked to the new patient
      const { error: admError } = await supabase
        .from('admissions')
        .insert([{
          patient_id: newPatient.id,
          bed_id: formData.bedAssigned,
          department: formData.department,
          priority: formData.priority,
          reason: formData.reason,
          status: 'Admitted'
        }]);

      if (admError) throw admError;

      // Step C: Lock the bed (Mark as Occupied)
      const { error: bedError } = await supabase
        .from('beds')
        .update({ status: 'Occupied' })
        .eq('id', formData.bedAssigned);

      if (bedError) throw bedError;

      // Refresh table to show the new admission
      await fetchActiveAdmissions();
      setIsModalOpen(false);
      
    } catch (error) {
      console.error("Admission logic error:", error);
      alert("Failed to admit patient. Check console for details.");
    }
  };

  // 3. Discharge Workflow
  const handleDischarge = async (admissionId, bedId) => {
    if (!window.confirm("Are you sure you want to discharge this patient? This frees up the bed.")) return;

    try {
      const { error: admError } = await supabase.from('admissions').update({ status: 'Discharged' }).eq('id', admissionId);
      if (admError) throw admError;

      const { error: bedError } = await supabase.from('beds').update({ status: 'Needs Cleaning' }).eq('id', bedId);
      if (bedError) throw bedError;

      await fetchActiveAdmissions();
    } catch (error) {
      console.error("Discharge failed:", error);
    }
  };

  const getPriorityStyle = (priority) => {
    switch(priority) {
      case 'High': return 'bg-rose-50 text-rose-700 border-rose-200';
      case 'Medium': return 'bg-amber-50 text-amber-700 border-amber-200';
      case 'Low': return 'bg-emerald-50 text-emerald-700 border-emerald-200';
      default: return 'bg-slate-50 text-slate-700 border-slate-200';
    }
  };

  // Safe filtering (matching the new `patientdata` relation)
  const filteredAdmissions = admissions.filter(adm => {
    const patientName = adm.patientdata?.name || '';
    const bedId = adm.bed_id || '';
    return patientName.toLowerCase().includes(searchQuery.toLowerCase()) || 
           bedId.toLowerCase().includes(searchQuery.toLowerCase());
  });

  return (
    <div className="flex flex-col h-full space-y-6 relative">
      
      {/* HEADER */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-slate-800 tracking-tight">Active Admissions</h1>
          <p className="text-sm text-slate-500 mt-1">Real-time patient-to-bed tracking</p>
        </div>
        <button 
          onClick={() => setIsModalOpen(true)} 
          className="flex items-center gap-2 bg-appPrimary hover:bg-teal-700 text-white px-5 py-2.5 rounded-lg font-bold shadow-sm transition-colors"
        >
          <UserPlus size={18} />
          <span>Walk-In Admission</span>
        </button>
      </div>

      {/* SEARCH TOOLBAR */}
      <div className="flex gap-4 bg-white p-3 rounded-xl border border-appSecondary shadow-sm">
        <div className="relative flex-1">
          <Search size={18} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
          <input 
            type="text" 
            placeholder="Search by Patient Name or Bed ID..." 
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
          <div className="col-span-2">Patient Details</div>
          <div>Department</div>
          <div>Location</div>
          <div>Triage</div>
          <div className="text-right">Actions</div>
        </div>

        <div className="flex-1 overflow-auto bg-slate-50/30">
          {isLoading ? (
            <div className="flex h-full items-center justify-center text-slate-400 flex-col gap-3">
              <Activity className="animate-pulse" size={32} />
              <p className="font-medium">Syncing active admissions...</p>
            </div>
          ) : filteredAdmissions.length === 0 ? (
            <div className="flex h-full flex-col items-center justify-center text-slate-400 gap-2">
              <UserPlus size={40} className="text-slate-300" />
              <p className="font-medium text-center">No active admissions found.</p>
            </div>
          ) : (
            <div className="divide-y divide-slate-100">
              {filteredAdmissions.map(adm => (
                <div key={adm.id} className="grid grid-cols-6 gap-4 px-6 py-4 items-center hover:bg-slate-50 transition-colors">
                  
                  <div className="col-span-2 flex items-center gap-3">
                    <div className="w-10 h-10 rounded-full bg-appSecondary/50 text-appPrimary flex items-center justify-center font-bold text-sm uppercase">
                      {adm.patientdata?.name ? adm.patientdata.name.substring(0, 2) : '??'}
                    </div>
                    <div>
                      <p className="font-bold text-slate-800">{adm.patientdata?.name || 'Unknown Patient'}</p>
                      <p className="text-xs text-slate-500 font-medium">{adm.patientdata?.phone || 'No contact info'}</p>
                    </div>
                  </div>
                  
                  <div className="text-sm text-slate-700 font-medium">{adm.department}</div>

                  <div>
                    <p className="text-sm font-bold text-slate-700 flex items-center gap-1.5">{adm.bed_id}</p>
                  </div>

                  <div className="flex flex-col items-start gap-1.5">
                    <span className={`px-2.5 py-1 rounded-md text-xs font-bold border ${getPriorityStyle(adm.priority)}`}>
                      {adm.priority}
                    </span>
                    <div className="flex items-center gap-1 text-xs text-slate-400">
                      <Clock size={12} />
                      <span>{new Date(adm.admitted_at).toLocaleDateString()}</span>
                    </div>
                  </div>

                  <div className="text-right">
                    <button 
                      onClick={() => handleDischarge(adm.id, adm.bed_id)}
                      className="inline-flex items-center gap-1.5 text-xs font-bold text-rose-600 hover:text-rose-700 hover:bg-rose-50 px-3 py-2 rounded-lg border border-transparent hover:border-rose-200 transition-all"
                    >
                      <LogOut size={14} />
                      Discharge
                    </button>
                  </div>

                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      {isModalOpen && (
        <PatientOnboardingModal 
          onClose={() => setIsModalOpen(false)} 
          onSubmit={handleAdmitPatient}
        />
      )}
    </div>
  );
};

export default PatientManagement;