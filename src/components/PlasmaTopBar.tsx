import React from 'react';
import { Tablet, Laptop, Keyboard, ShieldAlert, Code2, Sparkles, Terminal, Moon, Sun, Palette } from 'lucide-react';
import { ThemeMode } from '../types';

interface PlasmaTopBarProps {
  activeTab: 'osk' | 'protocol' | 'code';
  setActiveTab: (tab: 'osk' | 'protocol' | 'code') => void;
  tabletMode: boolean;
  setTabletMode: (v: boolean) => void;
  isKeyboardVisible: boolean;
  setIsKeyboardVisible: (v: boolean) => void;
  theme: ThemeMode;
  setTheme: (t: ThemeMode) => void;
}

export const PlasmaTopBar: React.FC<PlasmaTopBarProps> = ({
  activeTab,
  setActiveTab,
  tabletMode,
  setTabletMode,
  isKeyboardVisible,
  setIsKeyboardVisible,
  theme,
  setTheme,
}) => {
  return (
    <header className="bg-[#232629] border-b border-[#31363b] text-[#eff0f1] px-4 py-2.5 flex flex-wrap items-center justify-between gap-3 shadow-md select-none">
      {/* KDE Plasma Branding & Status */}
      <div className="flex items-center gap-3">
        <div className="flex items-center gap-2 bg-[#3daee9]/15 border border-[#3daee9]/40 text-[#3daee9] px-2.5 py-1 rounded-md text-xs font-semibold tracking-wide shadow-sm">
          <div className="w-2.5 h-2.5 rounded-full bg-[#3daee9] animate-pulse" />
          <span>KDE Plasma 6 Wayland</span>
        </div>
        <div className="hidden sm:flex items-center gap-1.5 text-xs text-[#eff0f1]/70">
          <span className="bg-[#1b1e20] px-2 py-0.5 rounded border border-[#31363b] font-mono text-[11px] text-[#3daee9]">
            zwp_input_method_v2
          </span>
          <span>•</span>
          <span className="text-[#eff0f1]/60">KWin LayerShell</span>
        </div>
      </div>

      {/* Mode Switches & Controls */}
      <div className="flex items-center gap-2">
        {/* Tablet / Laptop Hardware Switcher */}
        <button
          onClick={() => setTabletMode(!tabletMode)}
          className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium transition-all border ${
            tabletMode
              ? 'bg-[#3daee9]/20 border-[#3daee9] text-[#3daee9] shadow-sm font-semibold'
              : 'bg-[#31363b] border-[#1b1e20] text-[#eff0f1]/80 hover:bg-[#31363b]/80'
          }`}
          title="Simulate KWin org.kde.KWin.TabletModeManager tabletModeChanged signal"
        >
          {tabletMode ? <Tablet className="w-3.5 h-3.5 text-[#3daee9]" /> : <Laptop className="w-3.5 h-3.5 text-[#eff0f1]/60" />}
          <span>{tabletMode ? 'Tablet Mode' : 'Laptop Mode'}</span>
        </button>

        {/* OSK Toggle Button */}
        <button
          onClick={() => setIsKeyboardVisible(!isKeyboardVisible)}
          className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium transition-all border ${
            isKeyboardVisible
              ? 'bg-[#27ae60]/20 border-[#27ae60] text-[#27ae60] font-semibold'
              : 'bg-[#31363b] border-[#1b1e20] text-[#eff0f1]/60 hover:text-[#eff0f1]'
          }`}
        >
          <Keyboard className="w-3.5 h-3.5" />
          <span>{isKeyboardVisible ? 'OSK Active' : 'OSK Hidden'}</span>
        </button>

        {/* Theme Selector */}
        <div className="relative group">
          <button className="p-1.5 rounded-lg bg-[#31363b] border border-[#1b1e20] text-[#eff0f1] hover:bg-[#3daee9]/20 transition">
            <Palette className="w-3.5 h-3.5 text-[#3daee9]" />
          </button>
          <div className="absolute right-0 top-full mt-1 hidden group-hover:flex flex-col bg-[#232629] border border-[#31363b] rounded-lg shadow-2xl p-1 z-50 min-w-[150px]">
            <button
              onClick={() => setTheme('breeze-dark')}
              className={`text-left px-3 py-1.5 text-xs rounded hover:bg-[#31363b] ${theme === 'breeze-dark' ? 'text-[#3daee9] font-bold' : 'text-[#eff0f1]'}`}
            >
              Breeze Dark
            </button>
            <button
              onClick={() => setTheme('breeze-light')}
              className={`text-left px-3 py-1.5 text-xs rounded hover:bg-[#31363b] ${theme === 'breeze-light' ? 'text-[#3daee9] font-bold' : 'text-[#eff0f1]'}`}
            >
              Breeze Light
            </button>
            <button
              onClick={() => setTheme('material-teal')}
              className={`text-left px-3 py-1.5 text-xs rounded hover:bg-[#31363b] ${theme === 'material-teal' ? 'text-teal-400 font-bold' : 'text-[#eff0f1]'}`}
            >
              Material You Teal
            </button>
            <button
              onClick={() => setTheme('material-purple')}
              className={`text-left px-3 py-1.5 text-xs rounded hover:bg-[#31363b] ${theme === 'material-purple' ? 'text-purple-400 font-bold' : 'text-[#eff0f1]'}`}
            >
              Material You Purple
            </button>
          </div>
        </div>
      </div>

      {/* Main Tab Navigation */}
      <div className="flex items-center bg-[#1b1e20] p-1 rounded-lg border border-[#31363b] text-xs">
        <button
          onClick={() => setActiveTab('osk')}
          className={`flex items-center gap-1.5 px-3 py-1 rounded-md font-medium transition ${
            activeTab === 'osk'
              ? 'bg-[#3daee9] text-white font-semibold shadow-sm'
              : 'text-[#eff0f1]/70 hover:text-[#eff0f1]'
          }`}
        >
          <Keyboard className="w-3.5 h-3.5" />
          <span>Interactive OSK</span>
        </button>
        <button
          onClick={() => setActiveTab('protocol')}
          className={`flex items-center gap-1.5 px-3 py-1 rounded-md font-medium transition ${
            activeTab === 'protocol'
              ? 'bg-[#3daee9] text-white font-semibold shadow-sm'
              : 'text-[#eff0f1]/70 hover:text-[#eff0f1]'
          }`}
        >
          <Terminal className="w-3.5 h-3.5" />
          <span>Wayland Protocol</span>
        </button>
        <button
          onClick={() => setActiveTab('code')}
          className={`flex items-center gap-1.5 px-3 py-1 rounded-md font-medium transition ${
            activeTab === 'code'
              ? 'bg-[#3daee9] text-white font-semibold shadow-sm'
              : 'text-[#eff0f1]/70 hover:text-[#eff0f1]'
          }`}
        >
          <Code2 className="w-3.5 h-3.5" />
          <span>Native Code C++/QML</span>
        </button>
      </div>
    </header>
  );
};
