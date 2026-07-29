import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  start(): void;
  stop(): void;

  setBPM(newBPM: number): void;
  getBPM(): Promise<number>;

  setShouldPauseOnLostFocus(shouldPause: boolean): void;
  getShouldPauseOnLostFocus(): Promise<boolean>;

  isPlaying(): Promise<boolean>;
  isPaused(): Promise<boolean>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('MetronomeModule');
