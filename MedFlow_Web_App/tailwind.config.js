/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        appPrimary: '#007069',
        appSecondary: '#C5D4E5',
        appBackground: '#FFFFFF',
      }
    },
  },
  plugins: [],
}