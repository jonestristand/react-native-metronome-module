import React, { useCallback, useEffect, useState } from 'react';
import {
  Pressable,
  StatusBar,
  StyleSheet,
  Switch,
  Text,
  View,
  useColorScheme,
} from 'react-native';
import Metronome from 'react-native-metronome-module';

const BPM_STEP = 5;

function App(): React.JSX.Element {
  const isDarkMode = useColorScheme() === 'dark';

  const [bpm, setBpm] = useState<number>(100);
  const [playing, setPlaying] = useState(false);
  const [pauseOnLostFocus, setPauseOnLostFocus] = useState(true);

  // Pull initial state from the native module
  useEffect(() => {
    Metronome.getBPM().then(setBpm);
    Metronome.getShouldPauseOnLostFocus().then(setPauseOnLostFocus);
  }, []);

  // Poll isPlaying so the UI reflects native state (e.g. focus pause)
  useEffect(() => {
    const id = setInterval(() => {
      Metronome.isPlaying().then(setPlaying);
    }, 500);
    return () => clearInterval(id);
  }, []);

  const toggle = useCallback(() => {
    if (playing) {
      Metronome.stop();
      setPlaying(false);
    } else {
      Metronome.start();
      setPlaying(true);
    }
  }, [playing]);

  const changeBpm = useCallback((delta: number) => {
    setBpm((current) => {
      const next = Math.max(20, Math.min(300, current + delta));
      Metronome.setBPM(next);
      return next;
    });
  }, []);

  const togglePause = useCallback((value: boolean) => {
    setPauseOnLostFocus(value);
    Metronome.setShouldPauseOnLostFocus(value);
  }, []);

  const textColor = isDarkMode ? styles.textDark : styles.textLight;

  return (
    <View style={[styles.container, isDarkMode && styles.containerDark]}>
      <StatusBar barStyle={isDarkMode ? 'light-content' : 'dark-content'} />
      <Text style={[styles.title, textColor]}>Metronome</Text>

      <Text style={[styles.bpm, textColor]}>{bpm}</Text>
      <Text style={[styles.bpmLabel, textColor]}>BPM</Text>

      <View style={styles.row}>
        <Pressable
          style={styles.stepButton}
          onPress={() => changeBpm(-BPM_STEP)}
        >
          <Text style={styles.stepButtonText}>−{BPM_STEP}</Text>
        </Pressable>
        <Pressable
          style={[styles.playButton, playing && styles.playButtonActive]}
          onPress={toggle}
        >
          <Text style={styles.playButtonText}>{playing ? 'Stop' : 'Start'}</Text>
        </Pressable>
        <Pressable
          style={styles.stepButton}
          onPress={() => changeBpm(BPM_STEP)}
        >
          <Text style={styles.stepButtonText}>+{BPM_STEP}</Text>
        </Pressable>
      </View>

      <View style={styles.row}>
        <Text style={[styles.switchLabel, textColor]}>
          Pause when app loses focus
        </Text>
        <Switch value={pauseOnLostFocus} onValueChange={togglePause} />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    gap: 12,
    backgroundColor: '#f5f5f5',
  },
  containerDark: {
    backgroundColor: '#111',
  },
  title: {
    fontSize: 24,
    fontWeight: '600',
    marginBottom: 24,
  },
  bpm: {
    fontSize: 72,
    fontWeight: '200',
    fontVariant: ['tabular-nums'],
  },
  bpmLabel: {
    fontSize: 14,
    letterSpacing: 4,
    marginBottom: 24,
  },
  textLight: { color: '#111' },
  textDark: { color: '#eee' },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 16,
    marginTop: 16,
  },
  stepButton: {
    paddingHorizontal: 20,
    paddingVertical: 12,
    borderRadius: 8,
    backgroundColor: '#ddd',
  },
  stepButtonText: {
    fontSize: 18,
    fontWeight: '600',
    color: '#111',
  },
  playButton: {
    paddingHorizontal: 36,
    paddingVertical: 12,
    borderRadius: 8,
    backgroundColor: '#2e7d32',
  },
  playButtonActive: {
    backgroundColor: '#c62828',
  },
  playButtonText: {
    fontSize: 18,
    fontWeight: '600',
    color: '#fff',
  },
  switchLabel: {
    fontSize: 14,
  },
});

export default App;
