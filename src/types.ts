export type ThemeMode = 'breeze-dark' | 'breeze-light' | 'material-teal' | 'material-purple';
export type KeyboardMode = 'standard' | 'split' | 'emoji' | 'clipboard';
export type ShiftMode = 'off' | 'shift' | 'caps';
export type SymbolPage = 'alpha' | 'numeric' | 'symbols';

export interface WaylandProtocolEvent {
  id: string;
  timestamp: string;
  interface: 'zwp_input_method_v2' | 'org.kde.KWin.TabletModeManager' | 'org.kde.kwin.virtualkeyboard';
  method: string;
  details: string;
  direction: 'in' | 'out';
}

export interface TestAppField {
  id: string;
  name: string;
  icon: string;
  type: 'terminal' | 'browser' | 'notes' | 'password';
  value: string;
  placeholder: string;
}

export interface NativeFileItem {
  path: string;
  filename: string;
  language: 'cmake' | 'cpp' | 'qml' | 'xml';
  content: string;
}
