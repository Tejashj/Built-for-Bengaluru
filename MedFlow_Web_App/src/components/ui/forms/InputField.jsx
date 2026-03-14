import React from 'react';

const InputField = ({ label, name, type = 'text', value, onChange, placeholder, required = false }) => {
  
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

  return (
    <div className="flex flex-col space-y-1.5 w-full">
      <label htmlFor={name} className="text-sm font-semibold text-slate-700">
        {label} {required && <span className="text-rose-500">*</span>}
      </label>
      <input
        id={name}
        name={name}
        type={type}
        value={value}
        onChange={onChange}
        onKeyDown={handleKeyDown}
        placeholder={placeholder}
        required={required}
        className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-lg text-sm text-slate-800 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-appPrimary/20 focus:border-appPrimary transition-all"
      />
    </div>
  );
};

export default InputField;  