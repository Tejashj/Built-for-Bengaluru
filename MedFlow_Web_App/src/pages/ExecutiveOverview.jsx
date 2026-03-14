import React, { useState, useEffect } from 'react';
import { Users, Bed, Activity, TrendingUp, Clock, AlertCircle, CheckCircle2, Info, ServerCrash, AlignLeft } from 'lucide-react';
import { supabase } from '../services/supabaseClient';

const ExecutiveOverview = () => {
  // --- 1. EXISTING DATABASE STATE ---
  const [stats, setStats] = useState({ totalBeds: 0, occupiedBeds: 0, availableBeds: 0, occupancyRate: 0, activeAdmissions: 0 });
  const [departmentStats, setDepartmentStats] = useState([]);
  const [recentAdmissions, setRecentAdmissions] = useState([]);
  const [isDbLoading, setIsDbLoading] = useState(true);

  // --- 2. AI AGENT STATE ---
  const [parsedAiData, setParsedAiData] = useState(null);
  const [isAiLoading, setIsAiLoading] = useState(true);
  const [aiError, setAiError] = useState(null);

  // --- 3. SUPABASE DATA FETCHING ---
  useEffect(() => {
    const fetchDashboardData = async () => {
      setIsDbLoading(true);
      try {
        const [bedsRes, admRes] = await Promise.all([
          supabase.from('beds').select('*'),
          supabase.from('admissions').select(`id, department, priority, admitted_at, patientdata(name)`).eq('status', 'Admitted').order('admitted_at', { ascending: false }).limit(5)
        ]);
        if (bedsRes.error) throw bedsRes.error;
        if (admRes.error) throw admRes.error;

        const beds = bedsRes.data || [];
        const admissions = admRes.data || [];
        const occupied = beds.filter(b => b.status === 'Occupied').length;
        const rate = beds.length === 0 ? 0 : Math.round((occupied / beds.length) * 100);

        setStats({ totalBeds: beds.length, occupiedBeds: occupied, availableBeds: beds.filter(b => b.status === 'Available').length, occupancyRate: rate, activeAdmissions: admissions.length });

        const depMap = {};
        beds.forEach(bed => {
          if (!depMap[bed.department]) depMap[bed.department] = { total: 0, occupied: 0 };
          depMap[bed.department].total += 1;
          if (bed.status === 'Occupied') depMap[bed.department].occupied += 1;
        });

        setDepartmentStats(Object.keys(depMap).map(dep => ({
          name: dep, total: depMap[dep].total, occupied: depMap[dep].occupied, rate: Math.round((depMap[dep].occupied / depMap[dep].total) * 100)
        })).sort((a, b) => b.rate - a.rate));
        setRecentAdmissions(admissions);
      } catch (error) {
        console.error("DB Error:", error);
      } finally {
        setIsDbLoading(false);
      }
    };
    fetchDashboardData();
  }, []);

  // --- 4. POLISHED AGENT JSON PARSER ---
  const parseAiReport = (backendJson) => {
    if (!backendJson) return null;

    // 🔥 THE MEMO SHREDDER: Removes code blocks and roleplay formatting 🔥
    const cleanAiText = (str) => {
      if (typeof str !== 'string') return '';
      return str
        .replace(/```[\s\S]*?```/g, '') // Remove Python code blocks
        .replace(/FINAL HOSPITAL COMMAND[\s\S]*?EXECUTIVE SUMMARY/i, '') // Remove TO/FROM/SUBJECT headers
        .replace(/ACKNOWLEDGMENT[\s\S]*/i, '') // Delete the entire signature block at the bottom
        .replace(/EFFECTIVE DATE[\s\S]*?(?=\n\n|$)/i, '') // Delete effective date boilerplate
        .replace(/ACTION ITEMS[\s\S]*?(?=\n\n|$)/i, '') // Delete action item boilerplate
        .replace(/MONITORING AND EVALUATION[\s\S]*?(?=\n\n|$)/i, '') // Delete monitoring boilerplate
        .replace(/IMPLEMENTATION PLAN/i, '') // Remove unnecessary heading
        .replace(/\*\*/g, '') // Strip all markdown asterisks
        .replace(/\n{3,}/g, '\n\n') // Collapse excessive line breaks into standard paragraphs
        .trim();
    };

    if (backendJson.status === "success" && backendJson.data) {
      const d = backendJson.data;
      
      // Clean all inputs
      let summaryText = cleanAiText(d.final_decision) || cleanAiText(d.demand_prediction);
      const seasonalText = cleanAiText(d.seasonal_disease_prediction);
      const emergencyText = cleanAiText(d.emergency_status);
      const staffText = cleanAiText(d.staff_plan);
      const allocationText = cleanAiText(d.allocation_plan);

      // Force the Executive Summary to actually be a summary (Take only the first paragraph)
      if (summaryText) {
        const paragraphs = summaryText.split('\n\n');
        summaryText = paragraphs[0]; // Just grab the concise intro
      }

      return {
        summary: summaryText || "Analysis completed by backend agents.",
        findings: [
          emergencyText ? `Emergency Status Check:\n${emergencyText}` : null,
          seasonalText ? `Seasonal Disease Watch:\n${seasonalText}` : null
        ].filter(Boolean),
        recommendations: [
          staffText ? `Staff Optimization:\n${staffText}` : null,
          allocationText ? `Resource Strategy:\n${allocationText}` : null
        ].filter(Boolean),
        isFallback: false
      };
    }

    // Fallback mode if backend structure changes
    return {
      summary: typeof backendJson === 'string' ? backendJson : JSON.stringify(backendJson, null, 2),
      findings: [],
      recommendations: [],
      isFallback: true
    };
  };

  // --- 5. FASTAPI AI FETCHING ---
  useEffect(() => {
    const fetchAiReport = async () => {
      const cachedReport = sessionStorage.getItem('aiReportCache');
      if (cachedReport) {
        setParsedAiData(parseAiReport(JSON.parse(cachedReport)));
        setIsAiLoading(false);
        return;
      }

      setIsAiLoading(true);
      setAiError(null);
      try {
        const response = await fetch('https://turpentinic-teagan-seasonably.ngrok-free.dev/ai-report', {
          method: 'GET',
          headers: {
            'ngrok-skip-browser-warning': '69420',
            'Content-Type': 'application/json'
          }
        });

        if (!response.ok) throw new Error(`Backend returned ${response.status}`);
        
        const rawData = await response.json();
        
        sessionStorage.setItem('aiReportCache', JSON.stringify(rawData));
        setParsedAiData(parseAiReport(rawData));

      } catch (error) {
        console.error("AI Fetch Error:", error);
        setAiError("Agent network is unreachable. Showing local database stats.");
      } finally {
        setIsAiLoading(false);
      }
    };
    
    fetchAiReport();
  }, []);

  // --- 6. RENDER HELPER ---
  const renderFindingCard = (finding, idx) => {
    const isCritical = finding.includes("100%") || finding.toLowerCase().includes("emergency") || finding.toLowerCase().includes("high risk");
    
    let title = "Insight";
    let description = finding;
    
    if (finding.includes(':\n')) {
      const parts = finding.split(':\n');
      title = parts[0];
      description = parts.slice(1).join(':\n').trim();
    }

    return (
      <div key={idx} className={`p-4 rounded-lg border ${isCritical ? 'bg-rose-50 border-rose-200' : 'bg-slate-50 border-slate-200'}`}>
        <div className="flex items-start gap-3">
          <div className="w-full">
            <h4 className={`text-sm font-bold ${isCritical ? 'text-rose-800' : 'text-slate-800'}`}>{title}</h4>
            {/* Added max-h and scrollbar so huge agent outputs don't break the UI */}
            <div className={`mt-1.5 text-sm leading-relaxed ${isCritical ? 'text-rose-700' : 'text-slate-600'} whitespace-pre-wrap max-h-[250px] overflow-y-auto pr-2`}>
              {description}
            </div>
          </div>
        </div>
      </div>
    );
  };

  if (isDbLoading) {
    return (
      <div className="flex h-full items-center justify-center text-slate-400 flex-col gap-3">
        <Activity className="animate-pulse" size={40} />
        <p className="font-medium text-lg">Crunching hospital metrics...</p>
      </div>
    );
  }

  return (
    <div className="flex flex-col space-y-6 pb-6">
      
      <div className="flex-shrink-0">
        <h1 className="text-2xl font-bold text-slate-800 tracking-tight">Executive Overview</h1>
        <p className="text-sm text-slate-500 mt-1">Live capacity metrics and AI-driven resource allocation</p>
      </div>

      {/* TOP STAT CARDS (Local DB Data) */}
      <div className="grid grid-cols-4 gap-4 flex-shrink-0">
        <div className="bg-white p-5 rounded-xl border border-slate-200 shadow-sm flex flex-col justify-center">
          <div className="flex justify-between items-start mb-2">
            <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">Occupancy Rate</span>
            <div className="p-2 bg-slate-50 text-slate-700 rounded-lg"><TrendingUp size={18} /></div>
          </div>
          <span className="text-3xl font-bold text-slate-800">{stats.occupancyRate}%</span>
        </div>
        <div className="bg-white p-5 rounded-xl border border-slate-200 shadow-sm flex flex-col justify-center">
          <div className="flex justify-between items-start mb-2">
            <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">Available Beds</span>
            <div className="p-2 bg-emerald-50 text-emerald-600 rounded-lg"><Bed size={18} /></div>
          </div>
          <span className="text-3xl font-bold text-emerald-600">{stats.availableBeds}</span>
          <span className="text-xs text-slate-400 mt-1">out of {stats.totalBeds} total</span>
        </div>
        <div className="bg-white p-5 rounded-xl border border-slate-200 shadow-sm flex flex-col justify-center">
          <div className="flex justify-between items-start mb-2">
            <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">Occupied Beds</span>
            <div className="p-2 bg-blue-50 text-blue-600 rounded-lg"><Users size={18} /></div>
          </div>
          <span className="text-3xl font-bold text-blue-600">{stats.occupiedBeds}</span>
        </div>
        <div className="bg-white p-5 rounded-xl border border-slate-200 shadow-sm flex flex-col justify-center">
          <div className="flex justify-between items-start mb-2">
            <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">Active Triage</span>
            <div className="p-2 bg-amber-50 text-amber-600 rounded-lg"><Activity size={18} /></div>
          </div>
          <span className="text-3xl font-bold text-slate-800">{recentAdmissions.length}</span>
          <span className="text-xs text-slate-400 mt-1">Recent admissions</span>
        </div>
      </div>

      {/* AI STRATEGY & INSIGHTS PANEL */}
      <div className="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden flex-shrink-0">
        <div className="px-6 py-4 border-b border-slate-100 bg-slate-50 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Activity className="text-appPrimary" size={20} />
            <h3 className="text-lg font-bold text-slate-800">Resource Optimization Report</h3>
          </div>
          {isAiLoading && <span className="text-xs font-bold text-slate-500 animate-pulse">Fetching network data...</span>}
        </div>
        
        <div className="p-6">
          {aiError ? (
            <div className="flex items-center gap-3 text-rose-600 bg-rose-50 p-4 rounded-lg">
              <ServerCrash size={20} />
              <p className="text-sm font-semibold">{aiError}</p>
            </div>
          ) : !parsedAiData ? (
            <div className="h-20 flex items-center justify-center text-slate-400 text-sm">Waiting for prediction models...</div>
          ) : (
            
            parsedAiData.isFallback ? (
              <div className="bg-slate-50 p-6 rounded-lg border border-slate-200">
                <div className="flex items-center gap-2 text-slate-500 mb-3 font-bold text-sm">
                  <AlignLeft size={16} /> Raw Backend JSON Received:
                </div>
                <pre className="text-sm text-slate-700 whitespace-pre-wrap font-mono bg-white p-4 rounded border border-slate-100 max-h-[400px] overflow-y-auto">
                  {parsedAiData.summary}
                </pre>
              </div>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                <div className="space-y-6">
                  <div>
                    <h4 className="text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">Executive Summary</h4>
                    <p className="text-sm text-slate-700 leading-relaxed bg-slate-50 p-4 rounded-lg border border-slate-100">
                      {parsedAiData.summary}
                    </p>
                  </div>

                  <div>
                    <h4 className="text-xs font-bold text-slate-400 uppercase tracking-wider mb-3">Network Capacity Status</h4>
                    <div className="space-y-3">
                      {parsedAiData.findings.map((finding, idx) => renderFindingCard(finding, idx))}
                    </div>
                  </div>
                </div>

                <div>
                  <h4 className="text-xs font-bold text-slate-400 uppercase tracking-wider mb-3">Actionable Recommendations</h4>
                  <div className="bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden">
                    <div className="divide-y divide-slate-100">
                      {parsedAiData.recommendations.map((rec, idx) => {
                        let title = "Optimization Action";
                        let actionText = rec;
                        if(rec.includes(':\n')) {
                            const parts = rec.split(':\n');
                            title = parts[0];
                            actionText = parts.slice(1).join(':\n').trim();
                        }
                        
                        return (
                          <div key={idx} className="p-4 hover:bg-slate-50 transition-colors flex gap-3">
                            <CheckCircle2 className="text-emerald-500 flex-shrink-0 mt-0.5" size={18} />
                            <div className="w-full">
                              <span className="text-sm font-bold text-slate-800">{title}:</span>
                              {/* Added max-h and scrollbar here as well */}
                              <div className="text-sm text-slate-600 mt-1.5 whitespace-pre-wrap leading-relaxed max-h-[300px] overflow-y-auto pr-2">
                                {actionText}
                              </div>
                            </div>
                          </div>
                        );
                      })}
                    </div>
                  </div>
                </div>
              </div>
            )
          )}
        </div>
      </div>

      {/* LOWER SECTION: GRAPHS & TABLES (Local DB Data) */}
      <div className="grid grid-cols-3 gap-6 flex-shrink-0">
        <div className="col-span-2 bg-white rounded-xl border border-slate-200 shadow-sm p-6 flex flex-col min-h-[300px]">
          <h3 className="text-lg font-bold text-slate-800 mb-6">Local Department Capacity</h3>
          <div className="space-y-6 pr-2">
            {departmentStats.map((dep, idx) => (
              <div key={idx}>
                <div className="flex justify-between text-sm mb-2">
                  <span className="font-bold text-slate-700">{dep.name}</span>
                  <span className="text-slate-500 font-medium">{dep.occupied} / {dep.total} Beds ({dep.rate}%)</span>
                </div>
                <div className="w-full bg-slate-100 rounded-full h-2.5 overflow-hidden">
                  <div className={`h-2.5 rounded-full ${dep.rate > 85 ? 'bg-rose-500' : dep.rate > 50 ? 'bg-amber-500' : 'bg-appPrimary'}`} style={{ width: `${dep.rate}%` }}></div>
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="col-span-1 bg-white rounded-xl border border-slate-200 shadow-sm p-6 flex flex-col min-h-[300px]">
          <h3 className="text-lg font-bold text-slate-800 mb-6">Recent Admissions</h3>
          {recentAdmissions.length === 0 ? (
            <div className="flex-1 flex items-center justify-center text-sm text-slate-400">No recent activity.</div>
          ) : (
            <div className="space-y-4">
              {recentAdmissions.map((adm) => (
                <div key={adm.id} className="flex gap-4 items-start p-3 rounded-lg hover:bg-slate-50 transition-colors border border-transparent hover:border-slate-100">
                  <div className={`mt-0.5 w-2 h-2 rounded-full flex-shrink-0 ${adm.priority === 'High' ? 'bg-rose-500' : adm.priority === 'Medium' ? 'bg-amber-500' : 'bg-emerald-500'}`} />
                  <div>
                    <p className="text-sm font-bold text-slate-800">{adm.patientdata?.name || 'Unknown Patient'}</p>
                    <p className="text-xs text-slate-500">{adm.department}</p>
                    <div className="flex items-center gap-1 mt-1.5 text-[10px] text-slate-400 font-medium">
                      <Clock size={10} />
                      {new Date(adm.admitted_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                    </div>
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

export default ExecutiveOverview;