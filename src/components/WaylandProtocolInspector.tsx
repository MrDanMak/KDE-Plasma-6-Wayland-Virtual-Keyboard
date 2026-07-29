import React from 'react';
import { Terminal, Shield, Play, Pause, Trash2, ArrowUpRight, ArrowDownLeft } from 'lucide-react';
import { WaylandProtocolEvent } from '../types';

interface WaylandProtocolInspectorProps {
  events: WaylandProtocolEvent[];
  onClearEvents: () => void;
}

export const WaylandProtocolInspector: React.FC<WaylandProtocolInspectorProps> = ({
  events,
  onClearEvents,
}) => {
  return (
    <div className="w-full max-w-5xl mx-auto p-4 space-y-4">
      <div className="bg-[#232629] border border-[#31363b] rounded-xl p-4 shadow-2xl">
        <div className="flex flex-wrap items-center justify-between gap-3 border-b border-[#31363b] pb-3 mb-4">
          <div className="flex items-center gap-2">
            <Terminal className="w-5 h-5 text-[#3daee9]" />
            <div>
              <h2 className="text-sm font-semibold text-[#eff0f1]">Wayland Protocol & KWin DBus Live Inspector</h2>
              <p className="text-xs text-[#eff0f1]/70">
                Monitoring IPC messages across <code className="text-[#3daee9]">zwp_input_method_v2</code> and <code className="text-[#3daee9]">org.kde.KWin</code>
              </p>
            </div>
          </div>

          <button
            onClick={onClearEvents}
            className="flex items-center gap-1.5 px-3 py-1.5 bg-[#31363b] hover:bg-[#31363b]/80 text-[#eff0f1] rounded-lg text-xs font-medium transition shadow-sm border border-[#1b1e20]"
          >
            <Trash2 className="w-3.5 h-3.5" />
            <span>Clear Logs</span>
          </button>
        </div>

        {/* Live Logs Terminal View */}
        <div className="bg-[#1b1e20] border border-[#31363b] rounded-xl p-3 font-mono text-xs max-h-[460px] overflow-y-auto space-y-2">
          {events.length === 0 ? (
            <div className="text-[#eff0f1]/40 py-12 text-center italic">
              No Wayland protocol events recorded yet. Type into any focused field to observe live IPC requests.
            </div>
          ) : (
            events.map((evt) => (
              <div
                key={evt.id}
                className="flex items-start gap-3 p-2 rounded bg-[#232629] border border-[#31363b] hover:bg-[#2a2e32] transition"
              >
                <span className="text-[#eff0f1]/50 text-[11px] shrink-0 font-mono">{evt.timestamp}</span>
                <span className={`px-1.5 py-0.5 rounded text-[10px] font-semibold shrink-0 ${
                  evt.direction === 'in' ? 'bg-[#27ae60]/20 text-[#27ae60] border border-[#27ae60]/50' : 'bg-[#3daee9]/20 text-[#3daee9] border border-[#3daee9]/50'
                }`}>
                  {evt.direction === 'in' ? <ArrowDownLeft className="w-3 h-3 inline mr-1" /> : <ArrowUpRight className="w-3 h-3 inline mr-1" />}
                  {evt.direction.toUpperCase()}
                </span>
                <span className="text-[#3daee9] font-semibold shrink-0">{evt.interface}</span>
                <span className="text-[#27ae60] shrink-0">{evt.method}</span>
                <span className="text-[#eff0f1] break-all">{evt.details}</span>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
};
