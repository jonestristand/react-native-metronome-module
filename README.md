# react-native-metronome-module

Cross-platform metronome module for iOS and Android

## Version compatibility

| Library | React Native | Architecture |
| ------- | ------------ | ------------ |
| 3.x     | ≥ 0.76       | New architecture (TurboModule) |
| 2.x     | ≤ 0.7x       | Legacy architecture (also works on new-arch apps via the interop layer) |

Version 3.0.0 is a rewrite as a [TurboModule](https://reactnative.dev/docs/turbo-native-modules-introduction) and requires the new architecture (default since React Native 0.76). If your app runs the legacy architecture, pin `react-native-metronome-module@^2.5.1`.

## Installation

```sh
npm install react-native-metronome-module
```

**You must include a metronome.wav file in the following locations for this module to work:**
- android/app/src/main/res/raw
- ios (and add the file to the project in XCode)

## Usage

```js
import MetronomeModule from "react-native-metronome-module";

// ...

MetronomeModule.setBPM(100);
MetronomeModule.setShouldPauseOnLostFocus(true);

MetronomeModule.start();

// ...

if (await MetronomeModule.isPlaying()) {
  const bpm = await MetronomeModule.getBPM();
  console.log(`Metronome playing at ${bpm}bpm!`);

  MetronomeModule.stop();
}

```

## Methods

### Control
```ts
start: () => void
stop: () => void
```

### Getters/Setters
```ts
setBPM: (newBPM: number) => void
getBPM: () => Promise<number>


setShouldPauseOnLostFocus: (shouldPause: boolean) => void
getShouldPauseOnLostFocus: () => Promise<boolean>
```

### Check State
```ts
isPlaying: () => Promise<boolean>
isPaused: () => Promise<boolean>
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
