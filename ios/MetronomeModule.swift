//
//  RCTMetronomeModule.swift
//  metronome
//
//  Created by Tristan Jones on 2021-08-26.
//

import Foundation
import AVFoundation
import UIKit
import React

@objc(MetronomeModule)
public class MetronomeModule: NSObject, RCTInvalidating {

  private let queue = DispatchQueue(label: "com.reactnativemetronomemodule");

  private var bpm: Int = 60;
  private var shouldPauseOnLostFocus: Bool = true;

  private var timer: DispatchSourceTimer?;
  private var player: AVAudioPlayer?;

  private enum State {
    case playing, paused, stopped
  }
  private var currentState: State = .stopped;

  /** === Public constructor ================================================== */
  public override init() {
    super.init();
    NotificationCenter.default.addObserver(
      self, selector: #selector(handleResignActive),
      name: UIApplication.willResignActiveNotification, object: nil);
    NotificationCenter.default.addObserver(
      self, selector: #selector(handleBecomeActive),
      name: UIApplication.didBecomeActiveNotification, object: nil);
  }

  /** === Private properties ================================================== */
  private var interval: DispatchTimeInterval {
    .milliseconds(60_000 / bpm) // bpm is clamped >= 1 in setBPM
  }

  /** === Private methods ===================================================== */
  private func initializeSoundPlayer() {
    guard let url = Bundle.main.url(forResource: "metronome", withExtension: "wav") else {
      print("metronome.wav file not found"); return
    }

    do {
      try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default);
      try AVAudioSession.sharedInstance().setActive(true);

      self.player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue);
      self.player?.prepareToPlay();
    } catch let error {
      print(error.localizedDescription)
    }
  }

  private func startTimerLocked() {
    let t = DispatchSource.makeTimerSource(queue: queue)
    t.schedule(deadline: .now(), repeating: interval)
    t.setEventHandler { [weak self] in
      self?.player?.currentTime = 0
      self?.player?.play()
    }
    t.resume()
    timer = t
  }

  private func stopTimerLocked() {
    timer?.cancel()
    timer = nil
  }

  /** === App lifecycle (posted on main; hop to queue) ===================== */
  @objc private func handleResignActive() {
    queue.async {
      if self.currentState == .playing && self.shouldPauseOnLostFocus {
        self.stopTimerLocked()
        self.currentState = .paused
      }
    }
  }

  @objc private func handleBecomeActive() {
    queue.async {
      if self.currentState == .paused {
        self.startTimerLocked()
        self.currentState = .playing
      }
    }
  }

  /** === React Methods ======================================================= */
  @objc public func start() {
    queue.async {
      guard self.currentState != .playing else { return }
      if self.player == nil {          // minor fix: was `timer == nil`
        self.initializeSoundPlayer()
      }
      self.startTimerLocked()
      self.currentState = .playing
    }
  }

  @objc public func stop() {
    queue.async {
      // unconditional: also clears a lost-focus PAUSED state so the
      // metronome can't auto-resume after an explicit stop
      self.stopTimerLocked()
      self.currentState = .stopped
    }
  }

  @objc(setBPM:)
  public func setBPM(_ newBPM: Double) {
    queue.async {
      self.bpm = max(1, Int(newBPM.rounded()))
      // reschedule in place
      self.timer?.schedule(deadline: .now(), repeating: self.interval)
    }
  }

  @objc(getBPM:reject:)
  public func getBPM(_ resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
    queue.sync { resolve(self.bpm) }
  }

  @objc(setShouldPauseOnLostFocus:)
  public func setShouldPauseOnLostFocus(_ shouldPause: Bool) {
    queue.async { self.shouldPauseOnLostFocus = shouldPause }
  }

  @objc(getShouldPauseOnLostFocus:reject:)
  public func getShouldPauseOnLostFocus(_ resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
    queue.sync { resolve(self.shouldPauseOnLostFocus) }
  }

  @objc(isPlaying:reject:)
  public func isPlaying(_ resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
    queue.sync { resolve(self.currentState == .playing) }
  }

  @objc(isPaused:reject:)
  public func isPaused(_ resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
    queue.sync { resolve(self.currentState == .paused) }
  }

  public func invalidate() {
    NotificationCenter.default.removeObserver(self)
    queue.sync {
      self.stopTimerLocked()
      self.currentState = .stopped
    }
  }
}
