import React, { useState } from 'react';
import { PlasmaTopBar } from './components/PlasmaTopBar';
import { WaylandTestingCanvas } from './components/WaylandTestingCanvas';
import { OSKVirtualKeyboard } from './components/OSKVirtualKeyboard';
import { WaylandProtocolInspector } from './components/WaylandProtocolInspector';
import { NativeCodeViewer } from './components/NativeCodeViewer';
import { TestAppField, ThemeMode, WaylandProtocolEvent } from './types';

export default function App() {
  const [activeTab, setActiveTab] = useState<'osk' | 'protocol' | 'code'>('osk');
  const [tabletMode, setTabletMode] = useState<boolean>(true);
  const [isKeyboardVisible, setIsKeyboardVisible] = useState<boolean>(true);
  const [theme, setTheme] = useState<ThemeMode>('breeze-dark');

  const [testFields, setTestFields] = useState<TestAppField[]>([
    {
      id: 'konsole',
      name: 'Konsole Terminal (CLI)',
      icon: 'terminal',
      type: 'terminal',
      value: 'sudo pacman -Syu ',
      placeholder: 'Enter command...',
    },
    {
      id: 'firefox',
      name: 'Firefox Address Bar (Web)',
      icon: 'globe',
      type: 'browser',
      value: 'https://kde.org/plasma-desktop',
      placeholder: 'Search or enter address...',
    },
    {
      id: 'notes',
      name: 'Plasma Notes Editor (Kirigami)',
      icon: 'notes',
      type: 'notes',
      value: 'Meeting notes on Surface Pro tablet mode performance testing with KDE Plasma 6 Wayland.',
      placeholder: 'Type markdown notes...',
    },
    {
      id: 'password',
      name: 'KAuth System Authentication Prompt',
      icon: 'password',
      type: 'password',
      value: '',
      placeholder: 'Enter root password...',
    },
  ]);

  const [activeFieldId, setActiveFieldId] = useState<string | null>('konsole');

  const [protocolEvents, setProtocolEvents] = useState<WaylandProtocolEvent[]>([
    {
      id: '1',
      timestamp: new Date().toLocaleTimeString(),
      interface: 'zwp_input_method_v2',
      method: 'activate',
      details: 'Surface focused: Konsole Terminal (id: konsole)',
      direction: 'in',
    },
    {
      id: '2',
      timestamp: new Date().toLocaleTimeString(),
      interface: 'org.kde.KWin.TabletModeManager',
      method: 'tabletModeChanged',
      details: 'Tablet mode status: enabled (Surface Pro convertible state)',
      direction: 'in',
    },
    {
      id: '3',
      timestamp: new Date().toLocaleTimeString(),
      interface: 'org.kde.kwin.virtualkeyboard',
      method: 'setEnabled',
      details: 'KWin virtual keyboard requested show: true',
      direction: 'out',
    },
  ]);

  const logProtocol = (details: string, method: string) => {
    const newEvt: WaylandProtocolEvent = {
      id: Date.now().toString(),
      timestamp: new Date().toLocaleTimeString(),
      interface: 'zwp_input_method_v2',
      method,
      details,
      direction: method.includes('commit') || method.includes('send') ? 'out' : 'in',
    };
    setProtocolEvents(prev => [newEvt, ...prev.slice(0, 49)]);
  };

  const handleCommitText = (text: string) => {
    if (!activeFieldId) return;

    setTestFields(prev =>
      prev.map(f => {
        if (f.id === activeFieldId) {
          return { ...f, value: f.value + text };
        }
        return f;
      })
    );

    logProtocol(`Committed string: "${text}"`, 'zwp_input_method_v2.commit_string');
  };

  const handleBackspace = () => {
    if (!activeFieldId) return;

    setTestFields(prev =>
      prev.map(f => {
        if (f.id === activeFieldId) {
          return { ...f, value: f.value.slice(0, -1) };
        }
        return f;
      })
    );

    logProtocol('Deleted surrounding text (1 char before cursor)', 'zwp_input_method_v2.delete_surrounding_text');
  };

  const activeField = testFields.find(f => f.id === activeFieldId);

  return (
    <div className="min-h-screen bg-[#1b1e20] text-[#eff0f1] flex flex-col font-sans antialiased selection:bg-[#3daee9] selection:text-white">
      {/* Top Plasma Status & Mode Control Bar */}
      <PlasmaTopBar
        activeTab={activeTab}
        setActiveTab={setActiveTab}
        tabletMode={tabletMode}
        setTabletMode={(v) => {
          setTabletMode(v);
          logProtocol(`KWin TabletMode changed to: ${v}`, 'org.kde.KWin.TabletModeManager.tabletModeChanged');
          if (v) setIsKeyboardVisible(true);
        }}
        isKeyboardVisible={isKeyboardVisible}
        setIsKeyboardVisible={(v) => {
          setIsKeyboardVisible(v);
          logProtocol(`KWin VirtualKeyboard visibility toggled: ${v}`, 'org.kde.kwin.virtualkeyboard.setEnabled');
        }}
        theme={theme}
        setTheme={setTheme}
      />

      {/* Main View Area */}
      <main className="flex-1 flex flex-col justify-between overflow-y-auto pb-4">
        {activeTab === 'osk' ? (
          <>
            <div className="flex-1 py-4">
              <WaylandTestingCanvas
                fields={testFields}
                activeFieldId={activeFieldId}
                setActiveFieldId={(id) => {
                  setActiveFieldId(id);
                  if (tabletMode) setIsKeyboardVisible(true);
                }}
                updateFieldValue={(id, val) => {
                  setTestFields(prev => prev.map(f => f.id === id ? { ...f, value: val } : f));
                }}
                tabletMode={tabletMode}
                theme={theme}
                onLogProtocol={logProtocol}
              />
            </div>

            {/* Virtual Keyboard Layer */}
            {isKeyboardVisible && (
              <div className="w-full max-w-5xl mx-auto px-2">
                <OSKVirtualKeyboard
                  onCommitText={handleCommitText}
                  onBackspace={handleBackspace}
                  onHide={() => {
                    setIsKeyboardVisible(false);
                    logProtocol('OSK dismissed via bottom-right hide key', 'org.kde.kwin.virtualkeyboard.setEnabled(false)');
                  }}
                  theme={theme}
                  activeFieldValue={activeField?.value || ''}
                />
              </div>
            )}
          </>
        ) : activeTab === 'protocol' ? (
          <WaylandProtocolInspector
            events={protocolEvents}
            onClearEvents={() => setProtocolEvents([])}
          />
        ) : (
          <NativeCodeViewer />
        )}
      </main>
    </div>
  );
}
