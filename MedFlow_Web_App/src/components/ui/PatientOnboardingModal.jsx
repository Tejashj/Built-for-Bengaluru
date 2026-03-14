import React, { useState, useEffect } from 'react';
import { X, ChevronRight, ChevronLeft, CheckCircle2, UserPlus, Activity, BedDouble, Loader2, Wand2 } from 'lucide-react';
import InputField from './forms/InputField';
import SelectField from './forms/SelectField';
import { supabase } from '../../services/supabaseClient';

const PatientOnboardingModal = ({ onClose, onSubmit }) => {
  const [currentStep, setCurrentStep] = useState(1);
  const [isSubmitting, setIsSubmitting] = useState(false);
  
  const [departments, setDepartments] = useState([]);
  const [availableBeds, setAvailableBeds] = useState([]);
  const [isLoadingDeps, setIsLoadingDeps] = useState(false);
  const [isLoadingBeds, setIsLoadingBeds] = useState(false);

  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '',
    age: '',
    gender: '',
    blood_group: '',
    city: '',
    department: '',
    priority: '',
    reason: '',
    bedAssigned: ''
  });

  // --- DEMO AUTO-FILL FEATURE ---
  const handleAutoFillDemo = () => {
    const firstNames = ['Amit', 'Priya', 'Rahul', 'Sneha', 'Vikram', 'Anjali', 'Karthik', 'Meera'];
    const lastNames = ['Sharma', 'Patil', 'Rao', 'Desai', 'Singh', 'Reddy', 'Iyer', 'Menon'];
    const genders = ['Male', 'Female', 'Male', 'Female', 'Male', 'Female', 'Male', 'Female'];
    const bloodGroups = ['A+', 'O+', 'B+', 'AB+', 'O-'];
    const cities = ['Bengaluru', 'Mumbai', 'Delhi', 'Chennai', 'Hyderabad', 'Pune'];
    
    const r = Math.floor(Math.random() * firstNames.length);
    
    setFormData(prev => ({
      ...prev,
      name: `${firstNames[r]} ${lastNames[r]}`,
      email: `${firstNames[r].toLowerCase()}${Math.floor(Math.random()*100)}@example.com`,
      phone: `+91 9${Math.floor(100000000 + Math.random() * 900000000)}`,
      age: String(Math.floor(Math.random() * 60) + 18), // Random age between 18 and 78
      gender: genders[r],
      blood_group: bloodGroups[Math.floor(Math.random() * bloodGroups.length)],
      city: cities[Math.floor(Math.random() * cities.length)]
    }));
  };
  // ------------------------------

  useEffect(() => {
    const fetchDepartments = async () => {
      setIsLoadingDeps(true);
      try {
        const { data, error } = await supabase.from('beds').select('department');
        if (error) throw error;
        const uniqueDeps = [...new Set(data.map(b => b.department))].filter(Boolean);
        setDepartments(uniqueDeps.map(d => ({ value: d, label: d })));
      } catch (error) {
        console.error("Failed to fetch departments:", error);
      } finally {
        setIsLoadingDeps(false);
      }
    };
    fetchDepartments();
  }, []);

  useEffect(() => {
    const fetchBeds = async () => {
      if (!formData.department) return;
      setIsLoadingBeds(true);
      setFormData(prev => ({ ...prev, bedAssigned: '' }));
      
      try {
        const { data, error } = await supabase
          .from('beds')
          .select('id, ward')
          .eq('department', formData.department)
          .eq('status', 'Available');
          
        if (error) throw error;
        setAvailableBeds(data.map(b => ({ value: b.id, label: `${b.id} - ${b.ward}` })));
      } catch (error) {
        console.error("Failed to fetch beds:", error);
      } finally {
        setIsLoadingBeds(false);
      }
    };
    fetchBeds();
  }, [formData.department]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const validateStep = () => {
    if (currentStep === 1) return formData.name && formData.age && formData.gender && formData.phone;
    if (currentStep === 2) return formData.department && formData.priority;
    if (currentStep === 3) return formData.bedAssigned;
    return true;
  };

  const nextStep = () => { if (validateStep()) setCurrentStep(prev => Math.min(prev + 1, 3)); };
  const prevStep = () => setCurrentStep(prev => Math.max(prev - 1, 1));

  const handleFinalSubmit = async () => {
    if (!validateStep()) return;
    setIsSubmitting(true);
    try {
      await onSubmit(formData);
    } catch (error) {
      console.error("Admission failed:", error);
    } finally {
      setIsSubmitting(false);
    }
  };

  const steps = [
    { num: 1, title: 'Patient Profile', icon: UserPlus },
    { num: 2, title: 'Triage & Dept', icon: Activity },
    { num: 3, title: 'Bed Allocation', icon: BedDouble }
  ];

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/50 backdrop-blur-sm p-4">
      <div className="bg-white w-full max-w-2xl rounded-2xl shadow-2xl flex flex-col max-h-[90vh]">
        
        <div className="flex justify-between items-center px-6 py-4 border-b border-appSecondary bg-slate-50 rounded-t-2xl">
          <div>
            <h2 className="text-xl font-bold text-slate-800 tracking-tight">Walk-In Admission</h2>
            <p className="text-sm text-slate-500 font-medium">Create profile and allocate resources dynamically</p>
          </div>
          <button onClick={onClose} disabled={isSubmitting} className="p-2 text-slate-400 hover:text-slate-600 hover:bg-slate-200 rounded-full transition-colors disabled:opacity-50">
            <X size={20} />
          </button>
        </div>

        <div className="px-8 py-5 border-b border-slate-100 bg-white">
          <div className="flex items-center justify-between relative">
            <div className="absolute left-0 top-1/2 -translate-y-1/2 w-full h-1 bg-slate-100 -z-10 rounded-full"></div>
            {steps.map((step) => {
              const Icon = step.icon;
              const isActive = currentStep === step.num;
              const isCompleted = currentStep > step.num;
              return (
                <div key={step.num} className="flex flex-col items-center bg-white px-2">
                  <div className={`w-10 h-10 rounded-full flex items-center justify-center border-2 transition-colors duration-300 ${
                    isActive ? 'border-appPrimary bg-appPrimary/10 text-appPrimary' :
                    isCompleted ? 'border-emerald-500 bg-emerald-500 text-white' :
                    'border-slate-200 bg-slate-50 text-slate-400'
                  }`}>
                    {isCompleted ? <CheckCircle2 size={20} /> : <Icon size={18} />}
                  </div>
                  <span className={`text-xs font-bold mt-2 ${isActive ? 'text-appPrimary' : 'text-slate-400'}`}>{step.title}</span>
                </div>
              );
            })}
          </div>
        </div>

        <div className="p-8 overflow-y-auto flex-1 bg-white">
          
          {currentStep === 1 && (
            <div className="space-y-4 animate-in slide-in-from-right-4 fade-in duration-300">
              
              {/* DEMO BUTTON REPLACES HEADER */}
              <div className="flex justify-between items-center mb-2">
                <span className="text-sm font-bold text-slate-800">Personal Details</span>
                <button 
                  onClick={handleAutoFillDemo}
                  className="flex items-center gap-1.5 text-xs font-bold text-appPrimary bg-appPrimary/10 hover:bg-appPrimary/20 px-3 py-1.5 rounded-lg transition-colors border border-appPrimary/20"
                >
                  <Wand2 size={14} /> Auto-Fill Demo
                </button>
              </div>

              <InputField label="Full Name" name="name" value={formData.name} onChange={handleChange} placeholder="e.g. Jane Doe" required />
              <div className="grid grid-cols-2 gap-4">
                <InputField label="Phone Number" name="phone" type="tel" value={formData.phone} onChange={handleChange} placeholder="+91 XXXXX XXXXX" required />
                <InputField label="Email Address (Optional)" name="email" type="email" value={formData.email} onChange={handleChange} placeholder="patient@example.com" />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <InputField label="Age" name="age" type="number" value={formData.age} onChange={handleChange} required />
                <SelectField label="Gender" name="gender" value={formData.gender} onChange={handleChange} options={[ { value: 'Male', label: 'Male' }, { value: 'Female', label: 'Female' }, { value: 'Other', label: 'Other' } ]} required />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <SelectField label="Blood Group" name="blood_group" value={formData.blood_group} onChange={handleChange} options={[ { value: 'A+', label: 'A+' }, { value: 'O+', label: 'O+' }, { value: 'B+', label: 'B+' }, { value: 'AB+', label: 'AB+' }, { value: 'O-', label: 'O-' } ]} />
                <InputField label="City" name="city" value={formData.city} onChange={handleChange} />
              </div>
            </div>
          )}

          {currentStep === 2 && (
            <div className="space-y-4 animate-in slide-in-from-right-4 fade-in duration-300">
              <SelectField label={isLoadingDeps ? "Loading Departments..." : "Assign Department"} name="department" value={formData.department} onChange={handleChange} options={departments} placeholder={isLoadingDeps ? "Fetching..." : "Select Department"} required />
              <SelectField label="Triage Priority" name="priority" value={formData.priority} onChange={handleChange} options={[ { value: 'Low', label: '🟢 Low (Routine)' }, { value: 'Medium', label: '🟡 Medium (Urgent)' }, { value: 'High', label: '🔴 High (Emergency)' } ]} required />
              <div className="flex flex-col space-y-1.5 w-full">
                <label className="text-sm font-semibold text-slate-700">Reason for Admission / Symptoms</label>
                <textarea name="reason" value={formData.reason} onChange={handleChange} placeholder="Briefly describe..." className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-appPrimary/20 focus:border-appPrimary transition-all h-24 resize-none" />
              </div>
            </div>
          )}

          {currentStep === 3 && (
            <div className="space-y-4 animate-in slide-in-from-right-4 fade-in duration-300">
              <div className="p-4 bg-appPrimary/5 border border-appPrimary/20 rounded-xl mb-4">
                <p className="text-sm text-appPrimary font-medium">Allocating bed in <span className="font-bold">{formData.department}</span> for <span className="font-bold">{formData.name}</span></p>
              </div>
              
              {availableBeds.length === 0 && !isLoadingBeds ? (
                <div className="p-4 bg-rose-50 border border-rose-200 rounded-xl text-rose-700 text-sm font-semibold flex items-center gap-2">
                  <Activity size={18} /> No beds available in this department! Go back and reassign.
                </div>
              ) : (
                <SelectField label={isLoadingBeds ? "Scanning for available beds..." : "Assign Specific Bed"} name="bedAssigned" value={formData.bedAssigned} onChange={handleChange} options={availableBeds} placeholder={isLoadingBeds ? "Fetching..." : "Select an available bed"} required />
              )}
            </div>
          )}
        </div>

        <div className="px-6 py-4 border-t border-appSecondary bg-slate-50 rounded-b-2xl flex justify-between items-center">
          <button onClick={onClose} disabled={isSubmitting} className="px-4 py-2 text-sm font-semibold text-slate-600 hover:bg-slate-200 rounded-lg transition-colors">Cancel</button>
          <div className="flex gap-3">
            {currentStep > 1 && <button onClick={prevStep} disabled={isSubmitting} className="flex items-center gap-2 px-4 py-2 text-sm font-semibold text-slate-700 bg-white border border-slate-300 hover:bg-slate-50 rounded-lg transition-colors"><ChevronLeft size={16} /> Back</button>}
            {currentStep < 3 ? (
              <button onClick={nextStep} disabled={!validateStep()} className="flex items-center gap-2 px-6 py-2 text-sm font-bold text-white bg-appPrimary hover:bg-teal-700 rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed">Next <ChevronRight size={16} /></button>
            ) : (
              <button onClick={handleFinalSubmit} disabled={isSubmitting || !validateStep()} className="flex items-center gap-2 px-6 py-2 text-sm font-bold text-white bg-appPrimary hover:bg-teal-700 rounded-lg transition-colors disabled:opacity-70 disabled:cursor-not-allowed">{isSubmitting ? <><Loader2 size={16} className="animate-spin" /> Processing...</> : <><CheckCircle2 size={16} /> Complete Admission</>}</button>
            )}
          </div>
        </div>

      </div>
    </div>
  );
};

export default PatientOnboardingModal;