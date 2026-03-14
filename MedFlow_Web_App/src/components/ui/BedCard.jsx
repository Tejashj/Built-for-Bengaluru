import React from 'react';
import { BedDouble, User } from 'lucide-react';

const BedCard = ({ bed, onUpdateClick }) => {
  // Destructure the expected database fields
  const { id, ward, status, patient_id } = bed;

  // Dynamic styling function based on strict inventory statuses
  const getStatusConfig = (currentStatus) => {
    switch (currentStatus) {
      case 'Available':
        return { bg: 'bg-emerald-50', text: 'text-emerald-700', border: 'border-emerald-200' };
      case 'Occupied':
        return { bg: 'bg-blue-50', text: 'text-blue-700', border: 'border-blue-200' };
      case 'Needs Cleaning':
        return { bg: 'bg-slate-100', text: 'text-slate-700', border: 'border-slate-300' };
      default:
        return { bg: 'bg-gray-50', text: 'text-gray-500', border: 'border-gray-200' };
    }
  };

  const style = getStatusConfig(status);

  return (
    <div 
      onClick={() => onUpdateClick(bed)}
      className="group relative flex flex-col justify-between p-4 bg-white rounded-xl border border-appSecondary shadow-sm hover:shadow-md hover:border-appPrimary transition-all cursor-pointer h-32"
    >
      {/* Top Row: Inventory ID & Ward Location */}
      <div className="flex justify-between items-start">
        <div className="flex items-center gap-2">
          <div className="p-1.5 bg-slate-50 rounded-md text-slate-500 group-hover:text-appPrimary transition-colors">
            <BedDouble size={18} />
          </div>
          <span className="font-bold text-slate-800 tracking-tight">{id}</span>
        </div>
        <span className="text-xs font-medium text-slate-500 uppercase tracking-wider">
          {ward}
        </span>
      </div>

      {/* Bottom Row: Status Badge & Occupant Info */}
      <div className="flex justify-between items-end mt-auto">
        <div className={`px-2.5 py-1 rounded-md text-xs font-semibold border ${style.bg} ${style.text} ${style.border}`}>
          {status}
        </div>
        
        {/* Only render occupant slot if a patient is assigned */}
        {patient_id && (
          <div className="flex items-center gap-1 text-xs font-medium text-slate-600 bg-slate-50 px-2 py-1 rounded-md border border-slate-100">
            <User size={12} />
            <span>ID: {patient_id}</span>
          </div>
        )}
      </div>
    </div>
  );
};

export default BedCard; 