import React from 'react';
import { Terminal, Globe, FileText, Lock, Sparkles, AlertCircle } from 'lucide-react';
import { TestAppField, ThemeMode } from '../types';

interface WaylandTestingCanvasProps {
  fields: TestAppField[];
  activeFieldId: string | null;
  setActiveFieldId: (id: string | null) => void;
  updateFieldValue: (id: string, value: string) => void;
  tabletMode: boolean;
  theme: ThemeMode;
  onLogProtocol: (msg: string, method: string) => void;
}

export const WaylandTestingCanvas: React.FC<WaylandTestingCanvasProps> = ({
  fields,
  activeFieldId,
  setActiveFieldId,
  updateFieldValue,
  tabletMode,
  theme,
  onLogProtocol,
}) => {
  const activeField = fields.find(f => f.id === activeFieldId);

  const getIcon = (type: string) => {
    switch (type) {
      case 'terminal': return <Terminal className="w-4 h-4 text-emerald-400" />;
      case 'browser': return <Globe className="w-4 h-4 text-sky-400" />;
      case 'notes': return <FileText className="w-4 h-4 text-amber-400" />;
      case 'password': return <Lock className="w-4 h-4 text-rose-400" />;
      default: return <FileText className="w-4 h-4 text-slate-400" />;
    }
  };

  return (
    <div className="w-full max-w-5xl mx-auto p-4 space-y-4">
      {/* Wayland App Focus Surface Header */}
      <div className="bg-[#232629] border border-[#31363b] rounded-xl p-4 shadow-xl backdrop-blur-md">
        <div className="flex flex-wrap items-center justify-between gap-3 border-b border-[#31363b] pb-3 mb-4">
          <div>
            <h2 className="text-sm font-semibold text-[#eff0f1] flex items-center gap-2">
              <span className="w-2.5 h-2.5 rounded-full bg-[#27ae60]" />
              Active Wayland Surface Client Applications
            </h2>
            <p className="text-xs text-[#eff0f1]/70 mt-0.5">
              Click any application field below to focus text input via <code className="text-[#3daee9]">zwp_input_method_v2</code>.
            </p>
          </div>
          {tabletMode && (
            <div className="flex items-center gap-1.5 text-xs text-[#3daee9] bg-[#3daee9]/15 border border-[#3daee9]/40 px-2.5 py-1 rounded-md font-medium">
              <Sparkles className="w-3.5 h-3.5 text-[#3daee9]" />
              <span>Tablet Mode Active: Auto-triggers OSK on focus</span>
            </div>
          )}
        </div>

        {/* Applications Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {fields.map((field) => {
            const isActive = field.id === activeFieldId;
            return (
              <div
                key={field.id}
                onClick={() => {
                  setActiveFieldId(field.id);
                  onLogProtocol(`Activated input focus on ${field.name}`, 'zwp_input_method_v2.activate');
                }}
                className={`p-3.5 rounded-xl border transition-all cursor-pointer ${
                  isActive
                    ? 'bg-[#2a2e32] border-[#3daee9] shadow-lg ring-1 ring-[#3daee9]/50'
                    : 'bg-[#1b1e20] border-[#31363b] hover:border-[#3daee9]/40 hover:bg-[#2a2e32]/60'
                }`}
              >
                <div className="flex items-center justify-between mb-2">
                  <div className="flex items-center gap-2">
                    {getIcon(field.type)}
                    <span className="text-xs font-medium text-[#eff0f1]">{field.name}</span>
                  </div>
                  {isActive && (
                    <span className="text-[10px] bg-[#3daee9] border border-[#3daee9] text-white px-2 py-0.5 rounded-full font-mono font-bold tracking-wider">
                      FOCUSED
                    </span>
                  )}
                </div>

                {field.type === 'notes' ? (
                  <textarea
                    rows={3}
                    value={field.value}
                    onChange={(e) => updateFieldValue(field.id, e.target.value)}
                    placeholder={field.placeholder}
                    className="w-full bg-[#1b1e20] border border-[#31363b] rounded-lg p-2.5 text-xs text-[#eff0f1] placeholder-[#eff0f1]/40 focus:outline-none focus:border-[#3daee9] font-mono resize-none shadow-inner"
                  />
                ) : (
                  <input
                    type={field.type === 'password' ? 'password' : 'text'}
                    value={field.value}
                    onChange={(e) => updateFieldValue(field.id, e.target.value)}
                    placeholder={field.placeholder}
                    className="w-full bg-[#1b1e20] border border-[#31363b] rounded-lg px-3 py-2 text-xs text-[#eff0f1] placeholder-[#eff0f1]/40 focus:outline-none focus:border-[#3daee9] font-mono shadow-inner"
                  />
                )}
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
};
