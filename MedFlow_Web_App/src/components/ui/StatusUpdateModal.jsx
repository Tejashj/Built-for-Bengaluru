import React, { useState } from 'react';
import { X, CheckCircle, User, Sparkles, Loader2 } from 'lucide-react';

const StatusUpdateModal = ({ bed, onClose, onUpdate }) => {
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Failsafe: If no bed is passed, don't render
  if (!bed) return null;

  // Handles the click, shows loading state, and calls the parent's Supabase function
  const handleStatusChange = async (newStatus) => {
    // Prevent redundant updates
    if (newStatus === bed.status) return;

    setIsSubmitting(true);
    try {
      // We await the parent function which will contain the Supabase logic
      await onUpdate(bed.id, newStatus);
      onClose(); // Close modal on success
    } catch (error) {
      console.error("Failed to update status:", error);
      // In a full build, we would trigger a toast error notification here
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/40 backdrop-blur-sm">
      {/* Modal Container */}
      <div className="bg-white w-full max-w-md rounded-2xl shadow-xl border border-appSecondary overflow-hidden flex flex-col animate-in fade-in zoom-in-95 duration-200">
        
        {/* Header */}
        <div className="flex justify-between items-center p-5 border-b border-appSecondary bg-slate-50">
          <div>
            <h2 className="text-lg font-bold text-slate-800 tracking-tight">Update Inventory Item</h2>
            <p className="text-sm text-slate-500 font-medium mt-0.5">Resource ID: {bed.id} • {bed.ward}</p>
          </div>
          <button 
            onClick={onClose}
            disabled={isSubmitting}
            className="p-2 rounded-full text-slate-400 hover:text-slate-600 hover:bg-slate-200 transition-colors disabled:opacity-50"
          >
            <X size={20} />
          </button>
        </div>

        {/* Body / Actions */}
        <div className="p-6 space-y-3">
          <p className="text-sm font-semibold text-slate-600 uppercase tracking-wider mb-2">Select New Status</p>

          {/* Action: Mark Available */}
          <button
            onClick={() => handleStatusChange('Available')}
            disabled={isSubmitting || bed.status === 'Available'}
            className="w-full flex items-center justify-between p-4 rounded-xl border transition-all hover:bg-emerald-50 hover:border-emerald-300 disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:bg-transparent border-slate-200"
          >
            <div className="flex items-center gap-3">
              <CheckCircle className={bed.status === 'Available' ? 'text-emerald-500' : 'text-slate-400'} size={24} />
              <span className="font-semibold text-slate-700">Mark as Available</span>
            </div>
            {isSubmitting && bed.status !== 'Available' ? <Loader2 className="animate-spin text-slate-400" size={18} /> : null}
          </button>

          {/* Action: Mark Occupied */}
          <button
            onClick={() => handleStatusChange('Occupied')}
            disabled={isSubmitting || bed.status === 'Occupied'}
            className="w-full flex items-center justify-between p-4 rounded-xl border transition-all hover:bg-blue-50 hover:border-blue-300 disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:bg-transparent border-slate-200"
          >
            <div className="flex items-center gap-3">
              <User className={bed.status === 'Occupied' ? 'text-blue-500' : 'text-slate-400'} size={24} />
              <span className="font-semibold text-slate-700">Mark as Occupied</span>
            </div>
            {isSubmitting && bed.status !== 'Occupied' ? <Loader2 className="animate-spin text-slate-400" size={18} /> : null}
          </button>

          {/* Action: Mark Needs Cleaning */}
          <button
            onClick={() => handleStatusChange('Needs Cleaning')}
            disabled={isSubmitting || bed.status === 'Needs Cleaning'}
            className="w-full flex items-center justify-between p-4 rounded-xl border transition-all hover:bg-slate-100 hover:border-slate-400 disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:bg-transparent border-slate-200"
          >
            <div className="flex items-center gap-3">
              <Sparkles className={bed.status === 'Needs Cleaning' ? 'text-slate-600' : 'text-slate-400'} size={24} />
              <span className="font-semibold text-slate-700">Flag for Cleaning</span>
            </div>
            {isSubmitting && bed.status !== 'Needs Cleaning' ? <Loader2 className="animate-spin text-slate-400" size={18} /> : null}
          </button>

        </div>
      </div>
    </div>
  );
};

export default StatusUpdateModal;