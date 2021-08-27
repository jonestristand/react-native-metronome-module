import { NativeModules } from 'react-native';

type MetronomeModuleType = {
  multiply(a: number, b: number): Promise<number>;
};

const { MetronomeModule } = NativeModules;

export default MetronomeModule as MetronomeModuleType;
