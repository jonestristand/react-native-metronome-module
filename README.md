# react-native-metronome-module

Cross-platform metronome module for iOS and Android

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
getShouldPauseOnLostFocus: () => Promise<number>
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
