import React from 'react';
import { ChevronDown } from 'lucide-react';

  // Magic function to jump to the next input when Enter is pressed
  const handleKeyDown = (e) => {
    if (e.key === 'Enter') {
      e.preventDefault(); // Stop form submission
      
      // Find all focusable elements in the current view
      const focusableElements = document.querySelectorAll(
        'input:not([disabled]), select:not([disabled]), textarea:not([disabled]), button:not([disabled])'
      );
      
      const elementsArray = Array.from(focusableElements);
      const currentIndex = elementsArray.indexOf(e.target);
      
      // Focus the next element if it exists
      if (currentIndex > -1 && currentIndex < elementsArray.length - 1) {
        elementsArray[currentIndex + 1].focus();
      }
    }
  };

const SelectField = ({ label, name, value, onChange, options, required = false, placeholder = "Select an option" }) => {
  return (
    <div className="flex flex-col space-y-1.5 w-full relative">
      <label htmlFor={name} className="text-sm font-semibold text-slate-700">
        {label} {required && <span className="text-rose-500">*</span>}
      </label>
      <div className="relative">
        <select
          id={name}
          name={name}
          value={value}
          onChange={onChange}
          onKeyDown={handleKeyDown}
          required={required}
          className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-lg text-sm text-slate-800 appearance-none focus:outline-none focus:ring-2 focus:ring-appPrimary/20 focus:border-appPrimary transition-all cursor-pointer"
        >
          <option value="" disabled>{placeholder}</option>
          {options.map((opt) => (
            <option key={opt.value} value={opt.value}>
              {opt.label}
            </option>
          ))}
        </select>
        <div className="absolute inset-y-0 right-0 flex items-center px-3 pointer-events-none text-slate-400">
          <ChevronDown size={16} />
        </div>
      </div>
    </div>
  );
};

export default SelectField;