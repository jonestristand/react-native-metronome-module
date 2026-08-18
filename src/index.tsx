import NativeMetronomeModule from './NativeMetronomeModule';

type MetronomeModuleType = {
  start: () => void;
  stop: () => void;

  setBPM: (newBPM: number) => void;
  getBPM: () => Promise<number>;

  setShouldPauseOnLostFocus: (shouldPause: boolean) => void;
  getShouldPauseOnLostFocus: () => Promise<boolean>;

  isPlaying: () => Promise<boolean>;
  isPaused: () => Promise<boolean>;
};

export default NativeMetronomeModule as MetronomeModuleType;
