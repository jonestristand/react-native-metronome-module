package com.reactnativemetronomemodule;

import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.Promise;

import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.ScheduledThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

import android.media.SoundPool;
import android.media.AudioAttributes;

public class MetronomeModule extends NativeMetronomeModuleSpec implements LifecycleEventListener {

  /** === Private members ================================================== */
  private final ReactApplicationContext reactContext;

  private int bpm = 100;
  private boolean shouldPauseOnLostFocus = true;

  private enum State { PLAYING, PAUSED, STOPPED }
  private State currentState = State.STOPPED;

  private SoundPool soundPool;
  private int soundId = 0;
  private boolean soundLoaded = false;

  private final ScheduledThreadPoolExecutor scheduledExecutor = new ScheduledThreadPoolExecutor(1);
  private ScheduledFuture<?> scheduledFuture;

  // Lambda so `this` is the module (in the old anonymous class it was the Runnable)
  private final Runnable tok = () -> {
    synchronized (this) {
      if (soundLoaded) {
        soundPool.play(soundId, 1, 1, 1, 0, 1.0f);
      }
    }
  };

  /** === Public constructor =============================================== */
  MetronomeModule(ReactApplicationContext context) {
    super(context);
    this.reactContext = context;
    this.reactContext.addLifecycleEventListener(this);
    this.scheduledExecutor.setRemoveOnCancelPolicy(true);
    initializeSoundPool();
  }

  /** === Private helpers (call with `this` lock held) ===================== */
  private int getIntervalMS() {
    return 60_000 / bpm;   // bpm clamped >= 1 in setBPM
  }

  private void initializeSoundPool() {
    soundPool = new SoundPool.Builder()
      .setMaxStreams(1)
      .setAudioAttributes(new AudioAttributes.Builder()
        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
        .build())
      .build();

    // Track the real sample id + readiness instead of assuming id 1
    soundPool.setOnLoadCompleteListener((pool, sampleId, status) -> {
      synchronized (this) {
        if (status == 0) {
          soundId = sampleId;
          soundLoaded = true;
        }
      }
    });

    int soundResourceId = reactContext.getResources()
      .getIdentifier("metronome", "raw", reactContext.getPackageName());
    soundPool.load(reactContext, soundResourceId, 1);
  }

  private void startTimer() {
    scheduledFuture = scheduledExecutor.scheduleAtFixedRate(
      tok, 0, getIntervalMS(), TimeUnit.MILLISECONDS);
  }

  private void stopTimer() {
    if (scheduledFuture != null) {
      scheduledFuture.cancel(false);
      scheduledFuture = null;
    }
  }

  /** === Host lifecycle hooks (UI thread) ================================= */
  @Override
  public synchronized void onHostResume() {
    if (currentState == State.PAUSED) {
      startTimer();
      currentState = State.PLAYING;
    }
  }

  @Override
  public synchronized void onHostPause() {
    if (currentState == State.PLAYING && shouldPauseOnLostFocus) {
      stopTimer();
      currentState = State.PAUSED;
    }
  }

  @Override
  public synchronized void onHostDestroy() {
    stopTimer();
    currentState = State.STOPPED;
  }

  /** === React Methods (NativeModules thread) ============================= */
  @Override
  public synchronized void start() {
    if (currentState != State.PLAYING) {
      startTimer();
      currentState = State.PLAYING;
    }
  }

  @Override
  public synchronized void stop() {
    // unconditional: also clears a lost-focus PAUSED state so the
    // metronome can't auto-resume after an explicit stop
    stopTimer();
    currentState = State.STOPPED;
  }

  @Override
  public synchronized void setBPM(double newBPM) {
    bpm = Math.max(1, (int) Math.round(newBPM));   // no div-by-zero / negative
    if (currentState == State.PLAYING) {
      stopTimer();
      startTimer();
    }
  }

  @Override
  public synchronized void getBPM(Promise promise) {
    promise.resolve(bpm);
  }

  @Override
  public synchronized void setShouldPauseOnLostFocus(boolean shouldPause) {
    shouldPauseOnLostFocus = shouldPause;
  }

  @Override
  public synchronized void getShouldPauseOnLostFocus(Promise promise) {
    promise.resolve(shouldPauseOnLostFocus);
  }

  @Override
  public synchronized void isPlaying(Promise promise) {
    promise.resolve(currentState == State.PLAYING);
  }

  @Override
  public synchronized void isPaused(Promise promise) {
    promise.resolve(currentState == State.PAUSED);
  }

  /** === Teardown ========================================================= */
  @Override
  public synchronized void invalidate() {
    stopTimer();
    scheduledExecutor.shutdownNow();
    soundPool.release();
    reactContext.removeLifecycleEventListener(this);
    super.invalidate();
  }
}
