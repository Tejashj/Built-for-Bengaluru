import React, { useState, useEffect } from 'react';
import BedCard from '../components/ui/BedCard';
import DepartmentCard from '../components/ui/DepartmentCard';
import StatusUpdateModal from '../components/ui/StatusUpdateModal';
import { Search, SlidersHorizontal, Plus, Activity, ChevronLeft } from 'lucide-react';
import { supabase } from '../services/supabaseClient';

const InventoryDashboard = () => {
  const [beds, setBeds] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  
  // Interaction State
  const [selectedBed, setSelectedBed] = useState(null);
  const [selectedDepartment, setSelectedDepartment] = useState(null); // Controls the Drill-Down View
  const [searchQuery, setSearchQuery] = useState('');

  // 1. Fetch Logic
  useEffect(() => {
    const fetchInventory = async () => {
      try {
        setIsLoading(true);
        const { data, error } = await supabase
          .from('beds')
          .select('*')
          .order('id', { ascending: true });
          
        if (error) throw error;
        setBeds(data || []); 
      } catch (error) {
        console.error("Error fetching inventory:", error);
      } finally {
        setIsLoading(false);
      }
    };
    fetchInventory();
  }, []);

  // 2. Update Logic
  const handleUpdateBedStatus = async (bedId, newStatus) => {
    try {
      const { error } = await supabase.from('beds').update({ status: newStatus }).eq('id', bedId);
      if (error) throw error;

      setBeds(currentBeds => 
        currentBeds.map(bed => bed.id === bedId ? { ...bed, status: newStatus } : bed)
      );
    } catch (error) {
      console.error("Failed to update database:", error);
      throw error; 
    }
  };

  // 3. Data Processing: Grouping Beds by Department
  const departmentData = beds.reduce((acc, bed) => {
    if (!acc[bed.department]) {
      acc[bed.department] = { name: bed.department, total: 0, available: 0, occupied: 0, cleaning: 0, beds: [] };
    }
    acc[bed.department].total += 1;
    if (bed.status === 'Available') acc[bed.department].available += 1;
    if (bed.status === 'Occupied') acc[bed.department].occupied += 1;
    if (bed.status === 'Needs Cleaning') acc[bed.department].cleaning += 1;
    
    acc[bed.department].beds.push(bed);
    return acc;
  }, {});

  const departmentsArray = Object.values(departmentData);

  // 4. View Logic & Dynamic Metrics
  const isDepartmentView = selectedDepartment !== null;
  
  // Calculate top metrics based on the current view (All Hospital vs Specific Department)
  const activeData = isDepartmentView ? departmentData[selectedDepartment].beds : beds;
  
  const totalBeds = activeData.length;
  const availableBeds = activeData.filter(b => b.status === 'Available').length;
  const occupiedBeds = activeData.filter(b => b.status === 'Occupied').length;
  const cleaningBeds = activeData.filter(b => b.status === 'Needs Cleaning').length;

  // Search Filtering
  const filteredDepartments = departmentsArray.filter(dep => 
    dep.name.toLowerCase().includes(searchQuery.toLowerCase())
  );
  
  const filteredBeds = isDepartmentView ? activeData.filter(bed => 
    bed.id.toLowerCase().includes(searchQuery.toLowerCase()) || 
    bed.ward.toLowerCase().includes(searchQuery.toLowerCase())
  ) : [];

  return (
    <div className="flex flex-col h-full space-y-6 relative pb-6">
      
      {/* HEADER & ACTION BUTTONS */}
      <div className="flex justify-between items-end">
        <div>
          {/* Back Button (Only shows in Department View) */}
          {isDepartmentView && (
            <button 
              onClick={() => {
                setSelectedDepartment(null);
                setSearchQuery(''); // Clear search when going back
              }}
              className="flex items-center gap-1 text-sm font-bold text-appPrimary hover:text-teal-700 transition-colors mb-2"
            >
              <ChevronLeft size={16} /> Back to All Departments
            </button>
          )}
          
          <h1 className="text-2xl font-bold text-slate-800 tracking-tight">
            {isDepartmentView ? `${selectedDepartment} Ward` : 'Hospital Departments'}
          </h1>
          <p className="text-sm text-slate-500 mt-1">
            {isDepartmentView ? 'Manage specific beds and cleaning statuses' : 'Select a department to view detailed bed inventory'}
          </p>
        </div>
        <button className="flex items-center gap-2 bg-appPrimary hover:bg-teal-700 text-white px-4 py-2 rounded-lg font-medium transition-colors shadow-sm h-fit">
          <Plus size={18} />
          <span>Add Resource</span>
        </button>
      </div>

      {/* DYNAMIC METRICS BAR */}
      <div className="grid grid-cols-4 gap-4 flex-shrink-0">
        {[
          { label: isDepartmentView ? 'Ward Capacity' : 'Total Capacity', val: totalBeds, color: 'text-slate-800' },
          { label: 'Available slots', val: availableBeds, color: 'text-emerald-600' },
          { label: 'Occupied', val: occupiedBeds, color: 'text-blue-600' },
          { label: 'Needs Cleaning', val: cleaningBeds, color: 'text-slate-600' }
        ].map((metric, idx) => (
          <div key={idx} className="bg-white p-4 rounded-xl border border-appSecondary shadow-sm flex flex-col justify-center">
            <span className="text-xs font-semibold text-slate-500 uppercase tracking-wider mb-1">{metric.label}</span>
            <span className={`text-2xl font-bold ${metric.color}`}>{metric.val}</span>
          </div>
        ))}
      </div>

      {/* TOOLBAR (Search & Filters) */}
      <div className="flex gap-4 bg-white p-3 rounded-xl border border-appSecondary shadow-sm flex-shrink-0">
        <div className="relative flex-1">
          <Search size={18} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
          <input 
            type="text" 
            placeholder={isDepartmentView ? "Search by Bed ID or Ward..." : "Search Departments..."} 
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

      {/* MAIN INVENTORY AREA */}
      <div className="flex-1 overflow-auto rounded-xl border border-slate-200 bg-slate-50/50 p-6">
        {isLoading ? (
          <div className="flex h-full items-center justify-center text-slate-400 flex-col gap-3">
            <Activity className="animate-pulse" size={32} />
            <p className="font-medium">Syncing with database...</p>
          </div>
        ) : !isDepartmentView ? (
          
          /* --- VIEW 1: DEPARTMENT GRID --- */
          filteredDepartments.length === 0 ? (
            <div className="flex h-full items-center justify-center text-slate-400">
              <p className="font-medium text-center">No departments found matching your search.</p>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
              {filteredDepartments.map((dep, idx) => (
                <DepartmentCard 
                  key={idx} 
                  departmentName={dep.name} 
                  stats={{ total: dep.total, available: dep.available, occupied: dep.occupied, cleaning: dep.cleaning }}
                  onClick={() => {
                    setSelectedDepartment(dep.name);
                    setSearchQuery(''); // Clear search when drilling down
                  }} 
                />
              ))}
            </div>
          )

        ) : (
          
          /* --- VIEW 2: DETAILED BED GRID --- */
          filteredBeds.length === 0 ? (
            <div className="flex h-full items-center justify-center text-slate-400">
              <p className="font-medium text-center">No beds found in this department.</p>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 2xl:grid-cols-5 gap-4">
              {filteredBeds.map(bed => (
                <BedCard 
                  key={bed.id} 
                  bed={bed} 
                  onUpdateClick={() => setSelectedBed(bed)} 
                />
              ))}
            </div>
          )
        )}
      </div>

      {/* STATUS UPDATE MODAL */}
      {selectedBed && (
        <StatusUpdateModal 
          bed={selectedBed} 
          onClose={() => setSelectedBed(null)} 
          onUpdate={handleUpdateBedStatus}
        />
      )}

    </div>
  );
};

export default InventoryDashboard;