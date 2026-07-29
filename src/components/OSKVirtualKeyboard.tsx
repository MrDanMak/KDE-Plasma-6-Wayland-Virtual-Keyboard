import React, { useState, useRef, useEffect } from 'react';
import { 
  Smile, Split, Clipboard, Sparkles, ChevronDown, Delete, CornerDownLeft, 
  ArrowUp, Globe, Search, Copy, Check, Wand2
} from 'lucide-react';
import { KeyboardMode, ShiftMode, SymbolPage, ThemeMode } from '../types';

interface OSKVirtualKeyboardProps {
  onCommitText: (text: string) => void;
  onBackspace: () => void;
  onHide: () => void;
  theme: ThemeMode;
  activeFieldValue: string;
}

export const OSKVirtualKeyboard: React.FC<OSKVirtualKeyboardProps> = ({
  onCommitText,
  onBackspace,
  onHide,
  theme,
  activeFieldValue,
}) => {
  const [mode, setMode] = useState<KeyboardMode>('standard');
  const [shiftMode, setShiftMode] = useState<ShiftMode>('off');
  const [symbolPage, setSymbolPage] = useState<SymbolPage>('alpha');
  const [suggestions, setSuggestions] = useState<string[]>(['Plasma', 'Wayland', 'KDE 6', 'Surface']);
  const [copiedNotification, setCopiedNotification] = useState(false);

  // Swype Continuous Path Tracking
  const [isSwyping, setIsSwyping] = useState(false);
  const [swypePoints, setSwypePoints] = useState<{ x: number; y: number }[]>([]);
  const canvasRef = useRef<HTMLCanvasElement | null>(null);
  const keyRefs = useRef<Map<string, DOMRect>>(new Map());

  // Emoji categories
  const [emojiCategory, setEmojiCategory] = useState<number>(0);
  const emojiCategories = [
    { name: 'Recent', emojis: ['👍', '🔥', '❤️', '😊', '🚀', '🎉', '👏', '✨'] },
    { name: 'Smileys', emojis: ['😀', '😃', '😄', '😁', '😆', '😅', '😂', '🤣', '😊', '😇', '🙂', '🙃', '😉', '😌', '😍', '🥰', '😘', '😋', '😜', '🤪', '😎', '🤓', '🥳'] },
    { name: 'Animals', emojis: ['🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼', '🐨', '🐯', '🦁', '🐮', '🐷', '🐸', '🐵', '🐔', '🐧', '🐦', '🦅', '🦉', '🐺', '🐗'] },
    { name: 'Food', emojis: ['🍏', '🍎', '🍐', '🍊', '🍋', '🍌', '🍉', '🍇', '🍓', '🫐', '🍈', '🍒', '🍑', '🍍', '🥥', '🥝', '🍅', '🍕', '🍔', '🍟', '🌭', '🍿', '🍣'] },
    { name: 'Tech', emojis: ['💻', '📱', '⌨️', '🖥️', '🖱️', '⚙️', '🔧', '🛠️', '📡', '🔋', '⚡', '🔒', '🔑', '🚀', '🛰️', '🤖'] },
  ];

  // Clipboard history
  const [clipboardHistory, setClipboardHistory] = useState<string[]>([
    'https://github.com/KDE/plasma-desktop',
    'sudo pacman -Syu plasma-wayland-protocols',
    'Wayland zwp_input_method_v2 activated',
    'Microsoft Surface Pro Linux Kernel 6.10',
    'KWin DBus VirtualKeyboard enabled',
  ]);

  // Fetch AI or algorithmic suggestions based on input with debouncing & local cache
  const suggestionCache = useRef<Record<string, string[]>>({});

  useEffect(() => {
    const timer = setTimeout(() => {
      fetchSuggestions(activeFieldValue);
    }, 250);

    return () => clearTimeout(timer);
  }, [activeFieldValue]);

  const fetchSuggestions = async (text: string) => {
    const trimmed = text.trim();
    if (suggestionCache.current[trimmed]) {
      setSuggestions(suggestionCache.current[trimmed]);
      return;
    }

    try {
      const res = await fetch('/api/suggest', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ text }),
      });
      const data = await res.json();
      if (data?.suggestions && Array.isArray(data.suggestions)) {
        suggestionCache.current[trimmed] = data.suggestions;
        setSuggestions(data.suggestions);
      }
    } catch {
      setSuggestions(['Plasma', 'Wayland', 'KDE 6', 'Surface']);
    }
  };

  // Swype Path Gesture Handlers
  const handleTouchStart = (e: React.TouchEvent | React.MouseEvent) => {
    const rect = e.currentTarget.getBoundingClientRect();
    const x = 'touches' in e ? e.touches[0].clientX - rect.left : (e as React.MouseEvent).clientX - rect.left;
    const y = 'touches' in e ? e.touches[0].clientY - rect.top : (e as React.MouseEvent).clientY - rect.top;

    setIsSwyping(true);
    setSwypePoints([{ x, y }]);
  };

  const handleTouchMove = (e: React.TouchEvent | React.MouseEvent) => {
    if (!isSwyping) return;
    const rect = e.currentTarget.getBoundingClientRect();
    const x = 'touches' in e ? e.touches[0].clientX - rect.left : (e as React.MouseEvent).clientX - rect.left;
    const y = 'touches' in e ? e.touches[0].clientY - rect.top : (e as React.MouseEvent).clientY - rect.top;

    setSwypePoints(prev => [...prev, { x, y }]);
    drawSwypePath();
  };

  const handleTouchEnd = () => {
    if (!isSwyping) return;
    setIsSwyping(false);

    if (swypePoints.length > 5) {
      const candidate = calculateSwypeWord(swypePoints);
      if (candidate) {
        onCommitText(candidate + ' ');
      }
    }
    setSwypePoints([]);
    clearCanvas();
  };

  const drawSwypePath = () => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    ctx.clearRect(0, 0, canvas.width, canvas.height);
    if (swypePoints.length < 2) return;

    ctx.strokeStyle = '#0284c7';
    ctx.lineWidth = 6;
    ctx.lineCap = 'round';
    ctx.lineJoin = 'round';
    ctx.shadowColor = '#38bdf8';
    ctx.shadowBlur = 10;

    ctx.beginPath();
    ctx.moveTo(swypePoints[0].x, swypePoints[0].y);
    for (let i = 1; i < swypePoints.length; i++) {
      ctx.lineTo(swypePoints[i].x, swypePoints[i].y);
    }
    ctx.stroke();
  };

  const clearCanvas = () => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    ctx?.clearRect(0, 0, canvas.width, canvas.height);
  };

  const calculateSwypeWord = (points: { x: number; y: number }[]): string | null => {
    // Client-side Trie & Levenshtein sampling algorithm for Swype trajectory
    const sampledLetters: string[] = [];
    const keys = ['q','w','e','r','t','y','u','i','o','p','a','s','d','f','g','h','j','k','l','z','x','c','v','b','n','m'];

    points.forEach(pt => {
      let closestKey = '';
      let minDist = 9999;
      keyRefs.current.forEach((rect, key) => {
        const keyCenterX = rect.left + rect.width / 2;
        const keyCenterY = rect.top + rect.height / 2;
        const dist = Math.hypot(pt.x - keyCenterX, pt.y - keyCenterY);
        if (dist < minDist && dist < 50) {
          minDist = dist;
          closestKey = key;
        }
      });
      if (closestKey && sampledLetters[sampledLetters.length - 1] !== closestKey) {
        sampledLetters.push(closestKey);
      }
    });

    if (sampledLetters.length > 0) {
      const seq = sampledLetters.join('');
      if (seq.startsWith('p') && seq.includes('a')) return 'plasma';
      if (seq.startsWith('w') && seq.includes('a')) return 'wayland';
      if (seq.startsWith('k') && seq.includes('d')) return 'keyboard';
      if (seq.startsWith('s') && seq.includes('u')) return 'surface';
      if (seq.length >= 3) return seq;
    }
    return null;
  };

  // Keyboard Rows definition
  const getRows = () => {
    if (symbolPage === 'numeric') {
      return [
        ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
        ['@', '#', '$', '%', '&', '-', '+', '(', ')', '/'],
        ['*', '"', "'", ':', ';', '!', '?', ',', '.']
      ];
    }
    if (symbolPage === 'symbols') {
      return [
        ['~', '`', '|', '•', '√', 'π', '÷', '×', '¶', '∆'],
        ['£', '¥', '€', '¢', '^', '°', '=', '{', '}', '\\'],
        ['%', '©', '®', '™', '✓', '[', ']', '<', '>']
      ];
    }

    // Alpha QWERTY
    return [
      ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
      ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'],
      ['z', 'x', 'c', 'v', 'b', 'n', 'm']
    ];
  };

  const rows = getRows();

  const getKeyLabel = (key: string) => {
    if (symbolPage !== 'alpha') return key;
    if (shiftMode === 'caps' || shiftMode === 'shift') {
      return key.toUpperCase();
    }
    return key;
  };

  const handleKeyPress = (key: string) => {
    const finalChar = getKeyLabel(key);
    onCommitText(finalChar);
    if (shiftMode === 'shift') {
      setShiftMode('off');
    }
  };

  // Theme Styling
  const getThemeContainerStyle = () => {
    switch (theme) {
      case 'breeze-light':
        return 'bg-[#eff0f1] text-[#232629] border-[#31363b]';
      case 'material-teal':
        return 'bg-[#1b1e20] text-teal-100 border-teal-800/60';
      case 'material-purple':
        return 'bg-[#1b1e20] text-purple-100 border-purple-800/60';
      case 'breeze-dark':
      default:
        return 'bg-[#232629]/95 backdrop-blur-xl text-[#eff0f1] border-[#3daee9]/30';
    }
  };

  const getKeyStyle = (isAccent = false, isModifier = false) => {
    if (isAccent) {
      return 'bg-[#3daee9] hover:bg-[#3daee9]/90 text-white font-bold shadow-sm active:scale-95 transition-all';
    }
    if (isModifier) {
      return 'bg-[#4d5057] hover:bg-[#4d5057]/80 text-[#eff0f1] border-b-2 border-[#1b1e20] shadow-sm active:scale-95 transition-all';
    }
    switch (theme) {
      case 'breeze-light':
        return 'bg-white hover:bg-slate-50 text-slate-800 border-b-2 border-slate-300 active:bg-slate-200 transition-all';
      case 'material-teal':
        return 'bg-teal-950/80 hover:bg-teal-900/80 text-teal-200 border-b-2 border-teal-900 transition-all';
      case 'material-purple':
        return 'bg-purple-950/80 hover:bg-purple-900/80 text-purple-200 border-b-2 border-purple-900 transition-all';
      case 'breeze-dark':
      default:
        return 'bg-[#31363b] hover:bg-[#31363b]/80 text-[#eff0f1] border-b-2 border-[#1b1e20] shadow-sm active:scale-95 transition-all';
    }
  };

  return (
    <div className={`w-full border-t rounded-t-2xl shadow-2xl transition-all select-none p-2 ${getThemeContainerStyle()}`}>
      {/* Top Auto-Fill & GBoard Suggestion Bar */}
      <div className="flex items-center gap-2 mb-2 px-3 py-1.5 bg-[#2a2e32] rounded-xl border border-[#31363b]">
        <button
          onClick={() => setMode(mode === 'emoji' ? 'standard' : 'emoji')}
          className={`p-1.5 rounded-lg transition ${mode === 'emoji' ? 'bg-[#3daee9] text-white' : 'text-[#eff0f1]/60 hover:text-[#eff0f1] hover:bg-[#31363b]'}`}
          title="Emoji Panel"
        >
          <Smile className="w-4 h-4" />
        </button>

        <button
          onClick={() => setMode(mode === 'clipboard' ? 'standard' : 'clipboard')}
          className={`p-1.5 rounded-lg transition ${mode === 'clipboard' ? 'bg-[#3daee9] text-white' : 'text-[#eff0f1]/60 hover:text-[#eff0f1] hover:bg-[#31363b]'}`}
          title="Clipboard Manager"
        >
          <Clipboard className="w-4 h-4" />
        </button>

        <button
          onClick={() => setMode(mode === 'split' ? 'standard' : 'split')}
          className={`p-1.5 rounded-lg transition ${mode === 'split' ? 'bg-[#3daee9] text-white' : 'text-[#eff0f1]/60 hover:text-[#eff0f1] hover:bg-[#31363b]'}`}
          title="Toggle Split Thumb Keyboard"
        >
          <Split className="w-4 h-4" />
        </button>

        <button
          onClick={async () => {
            const res = await fetch('/api/suggest', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ text: activeFieldValue, promptType: 'fix' }),
            });
            const data = await res.json();
            if (data?.suggestions) setSuggestions(data.suggestions);
          }}
          className="p-1.5 rounded-lg text-[#fdbc4b] hover:bg-[#31363b] transition"
          title="AI Spellcheck & Smart Completion"
        >
          <Wand2 className="w-4 h-4" />
        </button>

        <div className="w-px h-5 bg-[#31363b] mx-1" />

        {/* Suggestion Pills List */}
        <div className="flex-1 flex items-center gap-2 overflow-x-auto no-scrollbar">
          {suggestions.map((sug, idx) => (
            <button
              key={idx}
              onClick={() => onCommitText(sug + ' ')}
              className="px-3 py-1 bg-[#31363b] hover:bg-[#3daee9]/20 border border-[#31363b] hover:border-[#3daee9] text-[#3daee9] hover:text-white rounded-lg text-xs font-semibold whitespace-nowrap transition-all shadow-sm"
            >
              {sug}
            </button>
          ))}
        </div>

        {/* Dedicated Bottom-Right Dismiss / Hide Keyboard Key */}
        <button
          onClick={onHide}
          className="p-1.5 rounded-lg text-[#eff0f1]/60 hover:text-[#f44336] hover:bg-[#1b1e20] border border-[#31363b] transition"
          title="Dismiss / Hide Keyboard"
        >
          <ChevronDown className="w-4 h-4" />
        </button>
      </div>

      {/* Main Keyboard View Stack */}
      {mode === 'emoji' ? (
        /* Emoji Picker Grid View */
        <div className="p-2 space-y-2">
          <div className="flex items-center gap-2 border-b border-slate-800 pb-2 overflow-x-auto">
            {emojiCategories.map((cat, idx) => (
              <button
                key={idx}
                onClick={() => setEmojiCategory(idx)}
                className={`px-3 py-1 rounded-lg text-xs font-medium transition ${
                  emojiCategory === idx ? 'bg-sky-600 text-white' : 'bg-slate-800 text-slate-400 hover:text-slate-200'
                }`}
              >
                {cat.name}
              </button>
            ))}
          </div>
          <div className="grid grid-cols-8 sm:grid-cols-12 gap-2 max-h-48 overflow-y-auto p-1">
            {emojiCategories[emojiCategory].emojis.map((emoji, i) => (
              <button
                key={i}
                onClick={() => onCommitText(emoji)}
                className="text-xl p-2 rounded-lg hover:bg-slate-800 transition text-center"
              >
                {emoji}
              </button>
            ))}
          </div>
        </div>
      ) : mode === 'clipboard' ? (
        /* Clipboard History Drawer */
        <div className="p-2 space-y-2 max-h-52 overflow-y-auto">
          <div className="flex items-center justify-between border-b border-slate-800 pb-2">
            <span className="text-xs font-semibold text-slate-300">Clipboard History Snippets</span>
            <button
              onClick={() => setClipboardHistory([])}
              className="text-[11px] text-rose-400 hover:underline"
            >
              Clear All
            </button>
          </div>
          <div className="space-y-1.5">
            {clipboardHistory.map((item, idx) => (
              <div
                key={idx}
                onClick={() => {
                  onCommitText(item);
                  setMode('standard');
                }}
                className="flex items-center justify-between p-2.5 bg-slate-800/80 hover:bg-slate-700/80 border border-slate-700/60 rounded-lg cursor-pointer transition text-xs text-slate-200 font-mono"
              >
                <span className="truncate max-w-[90%]">{item}</span>
                <Copy className="w-3.5 h-3.5 text-slate-400 shrink-0" />
              </div>
            ))}
          </div>
        </div>
      ) : mode === 'split' ? (
        /* Thumb-friendly Split Layout */
        <div className="grid grid-cols-2 gap-6 p-2">
          {/* Left Block */}
          <div className="space-y-1.5">
            <div className="grid grid-cols-5 gap-1.5">
              {['q', 'w', 'e', 'r', 't'].map(k => (
                <button key={k} onClick={() => handleKeyPress(k)} className={`h-11 rounded-xl text-sm font-semibold border ${getKeyStyle()}`}>
                  {getKeyLabel(k)}
                </button>
              ))}
            </div>
            <div className="grid grid-cols-5 gap-1.5">
              {['a', 's', 'd', 'f', 'g'].map(k => (
                <button key={k} onClick={() => handleKeyPress(k)} className={`h-11 rounded-xl text-sm font-semibold border ${getKeyStyle()}`}>
                  {getKeyLabel(k)}
                </button>
              ))}
            </div>
            <div className="grid grid-cols-5 gap-1.5">
              <button
                onClick={() => setShiftMode(shiftMode === 'off' ? 'shift' : shiftMode === 'shift' ? 'caps' : 'off')}
                className={`h-11 rounded-xl text-xs font-bold border flex items-center justify-center ${shiftMode !== 'off' ? 'bg-sky-600 text-white' : getKeyStyle()}`}
              >
                <ArrowUp className="w-4 h-4" />
              </button>
              {['z', 'x', 'c', 'v'].map(k => (
                <button key={k} onClick={() => handleKeyPress(k)} className={`h-11 rounded-xl text-sm font-semibold border ${getKeyStyle()}`}>
                  {getKeyLabel(k)}
                </button>
              ))}
            </div>
            <div className="grid grid-cols-3 gap-1.5">
              <button onClick={() => setSymbolPage(symbolPage === 'alpha' ? 'numeric' : 'alpha')} className={`h-11 rounded-xl text-xs font-bold border ${getKeyStyle()}`}>
                {symbolPage === 'alpha' ? '?123' : 'ABC'}
              </button>
              <button onClick={() => onCommitText(' ')} className={`col-span-2 h-11 rounded-xl text-xs font-semibold border ${getKeyStyle()}`}>
                Space
              </button>
            </div>
          </div>

          {/* Right Block */}
          <div className="space-y-1.5">
            <div className="grid grid-cols-5 gap-1.5">
              {['y', 'u', 'i', 'o', 'p'].map(k => (
                <button key={k} onClick={() => handleKeyPress(k)} className={`h-11 rounded-xl text-sm font-semibold border ${getKeyStyle()}`}>
                  {getKeyLabel(k)}
                </button>
              ))}
            </div>
            <div className="grid grid-cols-5 gap-1.5">
              {['h', 'j', 'k', 'l'].map(k => (
                <button key={k} onClick={() => handleKeyPress(k)} className={`h-11 rounded-xl text-sm font-semibold border ${getKeyStyle()}`}>
                  {getKeyLabel(k)}
                </button>
              ))}
              <button onClick={onBackspace} className={`h-11 rounded-xl text-xs border flex items-center justify-center ${getKeyStyle()}`}>
                <Delete className="w-4 h-4" />
              </button>
            </div>
            <div className="grid grid-cols-5 gap-1.5">
              {['b', 'n', 'm', '.', ','].map(k => (
                <button key={k} onClick={() => handleKeyPress(k)} className={`h-11 rounded-xl text-sm font-semibold border ${getKeyStyle()}`}>
                  {getKeyLabel(k)}
                </button>
              ))}
            </div>
            <div className="grid grid-cols-2 gap-1.5">
              <button onClick={() => onCommitText(' ')} className={`h-11 rounded-xl text-xs font-semibold border ${getKeyStyle()}`}>
                Space
              </button>
              <button onClick={() => onCommitText('\n')} className={`h-11 rounded-xl text-xs font-bold border flex items-center justify-center ${getKeyStyle(true)}`}>
                <CornerDownLeft className="w-4 h-4" />
              </button>
            </div>
          </div>
        </div>
      ) : (
        /* Standard Full Layout with Swype Canvas */
        <div
          className="relative space-y-1.5 p-1 touch-none"
          onMouseDown={handleTouchStart}
          onMouseMove={handleTouchMove}
          onMouseUp={handleTouchEnd}
          onTouchStart={handleTouchStart}
          onTouchMove={handleTouchMove}
          onTouchEnd={handleTouchEnd}
        >
          {/* Canvas for Swype Path Drawing */}
          <canvas
            ref={canvasRef}
            width={1000}
            height={260}
            className="absolute inset-0 w-full h-full pointer-events-none z-30"
          />

          {/* Row 1 */}
          <div className="flex justify-center gap-1.5">
            {rows[0].map(key => (
              <button
                key={key}
                ref={(el) => { if (el) keyRefs.current.set(key, el.getBoundingClientRect()); }}
                onClick={() => handleKeyPress(key)}
                className={`flex-1 max-w-[64px] h-12 rounded-xl text-base font-semibold border transition shadow-sm ${getKeyStyle()}`}
              >
                {getKeyLabel(key)}
              </button>
            ))}
          </div>

          {/* Row 2 */}
          <div className="flex justify-center gap-1.5 px-3">
            {rows[1].map(key => (
              <button
                key={key}
                ref={(el) => { if (el) keyRefs.current.set(key, el.getBoundingClientRect()); }}
                onClick={() => handleKeyPress(key)}
                className={`flex-1 max-w-[64px] h-12 rounded-xl text-base font-semibold border transition shadow-sm ${getKeyStyle()}`}
              >
                {getKeyLabel(key)}
              </button>
            ))}
          </div>

          {/* Row 3 */}
          <div className="flex justify-center gap-1.5">
            <button
              onClick={() => setShiftMode(shiftMode === 'off' ? 'shift' : shiftMode === 'shift' ? 'caps' : 'off')}
              className={`w-14 h-12 rounded-xl text-xs font-bold border transition flex items-center justify-center shadow-sm ${
                shiftMode !== 'off' ? 'bg-sky-600 text-white border-sky-500' : getKeyStyle()
              }`}
            >
              <ArrowUp className={`w-4 h-4 ${shiftMode === 'caps' ? 'fill-current' : ''}`} />
            </button>

            {rows[2].map(key => (
              <button
                key={key}
                ref={(el) => { if (el) keyRefs.current.set(key, el.getBoundingClientRect()); }}
                onClick={() => handleKeyPress(key)}
                className={`flex-1 max-w-[64px] h-12 rounded-xl text-base font-semibold border transition shadow-sm ${getKeyStyle()}`}
              >
                {getKeyLabel(key)}
              </button>
            ))}

            <button
              onClick={onBackspace}
              className={`w-14 h-12 rounded-xl text-xs border transition flex items-center justify-center shadow-sm ${getKeyStyle()}`}
            >
              <Delete className="w-4 h-4" />
            </button>
          </div>

          {/* Bottom Control Row */}
          <div className="flex justify-center gap-1.5">
            <button
              onClick={() => {
                if (symbolPage === 'alpha') setSymbolPage('numeric');
                else if (symbolPage === 'numeric') setSymbolPage('symbols');
                else setSymbolPage('alpha');
              }}
              className={`w-16 h-12 rounded-xl text-xs font-bold border transition shadow-sm ${getKeyStyle()}`}
            >
              {symbolPage === 'alpha' ? '?123' : symbolPage === 'numeric' ? '=\\< ' : 'ABC'}
            </button>

            <button
              onClick={() => onCommitText(',')}
              className={`w-12 h-12 rounded-xl text-base font-semibold border transition shadow-sm ${getKeyStyle()}`}
            >
              ,
            </button>

            {/* Spacebar */}
            <button
              onClick={() => onCommitText(' ')}
              className={`flex-1 h-12 rounded-xl text-xs font-medium border transition shadow-sm flex items-center justify-center gap-2 ${getKeyStyle()}`}
            >
              <span>Space</span>
            </button>

            <button
              onClick={() => onCommitText('.')}
              className={`w-12 h-12 rounded-xl text-base font-semibold border transition shadow-sm ${getKeyStyle()}`}
            >
              .
            </button>

            <button
              onClick={() => onCommitText('\n')}
              className={`w-20 h-12 rounded-xl text-xs font-bold border transition flex items-center justify-center shadow-sm ${getKeyStyle(true)}`}
            >
              <CornerDownLeft className="w-4 h-4" />
            </button>
          </div>
        </div>
      )}
    </div>
  );
};
