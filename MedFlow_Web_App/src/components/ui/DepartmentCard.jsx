import React from 'react';
import { Building2, Bed, Users, Sparkles } from 'lucide-react';

const DepartmentCard = ({ departmentName, stats, onClick }) => {
  // Calculate the occupancy percentage for the progress bar
  const occupancyRate = stats.total === 0 ? 0 : Math.round((stats.occupied / stats.total) * 100);

  return (
    <div 
      onClick={onClick}
      className="bg-white p-6 rounded-xl border border-slate-200 shadow-sm hover:shadow-md hover:border-appPrimary/40 transition-all cursor-pointer group flex flex-col"
    >
      {/* Header */}
      <div className="flex items-start justify-between mb-4">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-slate-50 text-slate-600 rounded-lg group-hover:bg-appPrimary/10 group-hover:text-appPrimary transition-colors">
            <Building2 size={24} />
          </div>
          <h3 className="text-lg font-bold text-slate-800 group-hover:text-appPrimary transition-colors">
            {departmentName}
          </h3>
        </div>
      </div>

      {/* Progress Bar */}
      <div className="mb-6">
        <div className="flex justify-between text-xs font-bold mb-1.5">
          <span className="text-slate-500 uppercase tracking-wider">Occupancy</span>
          <span className={occupancyRate > 85 ? 'text-rose-600' : 'text-slate-700'}>
            {occupancyRate}%
          </span>
        </div>
        <div className="w-full bg-slate-100 rounded-full h-2 overflow-hidden">
          <div 
            className={`h-2 rounded-full transition-all duration-500 ${
              occupancyRate > 85 ? 'bg-rose-500' : 
              occupancyRate > 50 ? 'bg-amber-500' : 'bg-emerald-500'
            }`}
            style={{ width: `${occupancyRate}%` }}
          ></div>
        </div>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-3 gap-2 mt-auto pt-4 border-t border-slate-100">
        <div className="flex flex-col items-center p-2 bg-emerald-50 rounded-lg">
          <Bed size={16} className="text-emerald-600 mb-1" />
          <span className="text-lg font-bold text-emerald-700">{stats.available}</span>
          <span className="text-[10px] font-bold text-emerald-600/70 uppercase">Available</span>
        </div>
        
        <div className="flex flex-col items-center p-2 bg-blue-50 rounded-lg">
          <Users size={16} className="text-blue-600 mb-1" />
          <span className="text-lg font-bold text-blue-700">{stats.occupied}</span>
          <span className="text-[10px] font-bold text-blue-600/70 uppercase">Occupied</span>
        </div>

        <div className="flex flex-col items-center p-2 bg-slate-50 rounded-lg">
          <Sparkles size={16} className="text-slate-500 mb-1" />
          <span className="text-lg font-bold text-slate-700">{stats.cleaning}</span>
          <span className="text-[10px] font-bold text-slate-500/70 uppercase">Cleaning</span>
        </div>
      </div>
    </div>
  );
};

export default DepartmentCard;