import React, { useState } from 'react';
import { NATIVE_FILES } from '../data/nativeFiles';
import { NativeFileItem } from '../types';
import { Code2, Download, Copy, Check, FileCode, Folder, ChevronRight, Search, Terminal, Info, Play } from 'lucide-react';
import JSZip from 'jszip';

export const NativeCodeViewer: React.FC = () => {
  const [selectedFilePath, setSelectedFilePath] = useState<string>('CMakeLists.txt');
  const [searchQuery, setSearchQuery] = useState('');
  const [copied, setCopied] = useState(false);
  const [downloading, setDownloading] = useState(false);
  const [showGuide, setShowGuide] = useState(true);

  const selectedFile = NATIVE_FILES.find(f => f.path === selectedFilePath) || NATIVE_FILES[0];

  const filteredFiles = NATIVE_FILES.filter(f => 
    f.path.toLowerCase().includes(searchQuery.toLowerCase()) ||
    f.filename.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const handleCopyCode = () => {
    navigator.clipboard.writeText(selectedFile.content);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleDownloadZip = async () => {
    setDownloading(true);
    try {
      const zip = new JSZip();
      NATIVE_FILES.forEach(file => {
        zip.file(file.path, file.content);
      });
      const content = await zip.generateAsync({ type: 'blob' });
      const url = URL.createObjectURL(content);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'plasma-virtualkeyboard-native-src.zip';
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(url);
    } catch (err) {
      console.error('Failed to zip files:', err);
    } finally {
      setDownloading(false);
    }
  };

  return (
    <div className="w-full max-w-6xl mx-auto p-4 space-y-4">
      {/* Header Banner */}
      <div className="bg-[#232629] border border-[#31363b] rounded-xl p-4 shadow-2xl flex flex-wrap items-center justify-between gap-4">
        <div>
          <h2 className="text-base font-semibold text-[#eff0f1] flex items-center gap-2">
            <Code2 className="w-5 h-5 text-[#3daee9]" />
            Native C++ & QML Project Deliverable Explorer
          </h2>
          <p className="text-xs text-[#eff0f1]/70 mt-0.5">
            Complete KDE Plasma 6 Wayland virtual keyboard source tree (Qt 6, Kirigami, Wayland protocol bindings).
          </p>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={() => setShowGuide(!showGuide)}
            className="flex items-center gap-1.5 px-3 py-2 bg-[#31363b] hover:bg-[#3daee9]/20 text-[#3daee9] border border-[#3daee9]/40 rounded-lg text-xs font-semibold transition"
          >
            <Info className="w-4 h-4" />
            <span>{showGuide ? 'Hide Setup Guide' : 'How to Run on KDE Plasma 6'}</span>
          </button>

          <button
            onClick={handleDownloadZip}
            disabled={downloading}
            className="flex items-center gap-2 px-4 py-2 bg-[#3daee9] hover:bg-[#3daee9]/90 text-white rounded-lg text-xs font-semibold shadow-md transition disabled:opacity-50"
          >
            <Download className="w-4 h-4" />
            <span>{downloading ? 'Packing Zip...' : 'Download Project (.zip)'}</span>
          </button>
        </div>
      </div>

      {/* KDE Plasma 6 Quick Setup & Launch Guide */}
      {showGuide && (
        <div className="bg-[#1b1e20] border border-[#3daee9]/30 rounded-xl p-4 space-y-3">
          <div className="flex items-center gap-2 text-[#3daee9] font-semibold text-xs uppercase tracking-wider">
            <Terminal className="w-4 h-4" />
            <span>KDE Plasma 6 Wayland: Launching & Enabling the Keyboard</span>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-xs">
            <div className="bg-[#232629] border border-[#31363b] p-3 rounded-lg space-y-2">
              <span className="font-semibold text-white block flex items-center gap-1.5">
                <Play className="w-3.5 h-3.5 text-[#27ae60]" />
                1. Test Launch Directly from Terminal
              </span>
              <p className="text-[#eff0f1]/70 text-[11px]">
                Since this is a custom standalone Wayland Input Method application, run it directly:
              </p>
              <pre className="bg-[#1b1e20] p-2 rounded text-[11px] font-mono text-[#27ae60] overflow-x-auto">
                plasma-virtualkeyboard
              </pre>
            </div>

            <div className="bg-[#232629] border border-[#31363b] p-3 rounded-lg space-y-2">
              <span className="font-semibold text-white block flex items-center gap-1.5">
                <Folder className="w-3.5 h-3.5 text-[#3daee9]" />
                2. Add to KDE Application Launcher & Autostart
              </span>
              <p className="text-[#eff0f1]/70 text-[11px]">
                Create a desktop entry so it runs automatically in tablet mode:
              </p>
              <pre className="bg-[#1b1e20] p-2 rounded text-[10px] font-mono text-[#eff0f1]/80 overflow-x-auto">
{`mkdir -p ~/.local/share/applications/
cat << 'EOF' > ~/.local/share/applications/plasma-virtualkeyboard.desktop
[Desktop Entry]
Name=Plasma Virtual Keyboard
Comment=Wayland Touch Virtual Keyboard
Exec=plasma-virtualkeyboard
Icon=input-keyboard
Terminal=false
Type=Application
Categories=Qt;KDE;Utility;
EOF`}
              </pre>
            </div>
          </div>
        </div>
      )}

      {/* Main Split File Explorer View */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 min-h-[520px]">
        {/* File Tree Sidebar */}
        <div className="bg-[#232629] border border-[#31363b] rounded-xl p-3 flex flex-col space-y-3">
          <div className="relative">
            <Search className="w-3.5 h-3.5 absolute left-2.5 top-2.5 text-[#eff0f1]/50" />
            <input
              type="text"
              placeholder="Search files..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full bg-[#1b1e20] border border-[#31363b] rounded-lg pl-8 pr-3 py-1.5 text-xs text-[#eff0f1] placeholder-[#eff0f1]/40 focus:outline-none focus:border-[#3daee9]"
            />
          </div>

          <div className="flex-1 overflow-y-auto space-y-1 pr-1">
            <div className="text-[11px] font-semibold text-[#eff0f1]/60 uppercase tracking-wider px-2 py-1 flex items-center gap-1">
              <Folder className="w-3.5 h-3.5 text-[#3daee9]" />
              <span>plasma-virtualkeyboard/</span>
            </div>
            {filteredFiles.map((file) => {
              const isSelected = file.path === selectedFilePath;
              return (
                <button
                  key={file.path}
                  onClick={() => setSelectedFilePath(file.path)}
                  className={`w-full text-left px-2.5 py-1.5 rounded-lg text-xs font-mono transition flex items-center gap-2 ${
                    isSelected
                      ? 'bg-[#3daee9]/20 text-[#3daee9] border border-[#3daee9]/40 font-semibold'
                      : 'text-[#eff0f1]/70 hover:bg-[#31363b] hover:text-[#eff0f1]'
                  }`}
                >
                  <FileCode className="w-3.5 h-3.5 text-[#eff0f1]/50 shrink-0" />
                  <span className="truncate">{file.path}</span>
                </button>
              );
            })}
          </div>
        </div>

        {/* Source Code Content View */}
        <div className="md:col-span-3 bg-[#1b1e20] border border-[#31363b] rounded-xl flex flex-col overflow-hidden">
          <div className="bg-[#31363b] px-4 py-2.5 border-b border-[#1b1e20] flex items-center justify-between">
            <span className="text-xs font-mono font-medium text-[#3daee9] flex items-center gap-2">
              <FileCode className="w-4 h-4 text-[#3daee9]" />
              {selectedFile.path}
            </span>

            <button
              onClick={handleCopyCode}
              className="flex items-center gap-1.5 px-3 py-1 bg-[#232629] hover:bg-[#2a2e32] text-[#eff0f1] rounded text-xs font-medium transition border border-[#1b1e20]"
            >
              {copied ? <Check className="w-3.5 h-3.5 text-[#27ae60]" /> : <Copy className="w-3.5 h-3.5" />}
              <span>{copied ? 'Copied!' : 'Copy Code'}</span>
            </button>
          </div>

          <div className="flex-1 p-4 overflow-auto font-mono text-xs text-[#aeb4bb] leading-relaxed bg-[#1b1e20]">
            <pre>
              <code>{selectedFile.content}</code>
            </pre>
          </div>
        </div>
      </div>
    </div>
  );
};
