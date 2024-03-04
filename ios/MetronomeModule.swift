//
//  RCTMetronomeModule.swift
//  metronome
//
//  Created by Tristan Jones on 2021-08-26.
//

import Foundation
import AVFoundation
import React

@objc(MetronomeModule)
class MetronomeModule: NSObject, RCTInvalidating {

  var bpm: Int = 60 ;
  var shouldPauseOnLostFocus: Bool = true;

  var timer: Timer?;
  var player: AVAudioPlayer?;

  enum metronomeState {
    case PLAYING
    case PAUSED
    case STOPPED
  }
  var currentState: metronomeState = metronomeState.STOPPED;

  /** === Public constructor =============================================== */
/*  override init() {
    super.init();

    self.initializeSoundPlayer();
  }*/

  /** === Private methods ================================================== */
  private func getIntervalMS() -> Double {
    return 60.0 / Double(self.bpm);
  }

  private func initializeSoundPlayer() -> Void {
    guard let url = Bundle.main.url(forResource: "metronome", withExtension: "wav") else { print("metronome.wav file not found"); return; };

    do {
      try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default);
      try AVAudioSession.sharedInstance().setActive(true);

      self.player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue);
    } catch let error {
      print(error.localizedDescription)
    }
  }

  @objc private func tok()
  {
    self.player?.play();
  }

  /** === React Methods ==================================================== */
  @objc
  func start() -> Void {
    if (self.currentState != metronomeState.PLAYING) {

      // Lazy initialization of sound player
      if (self.timer == nil) {
        initializeSoundPlayer();
      }

      // Start Timer on another thread
      DispatchQueue.global(qos:.userInteractive).async(execute: {
        self.timer = Timer.scheduledTimer(timeInterval: self.getIntervalMS(), target: self, selector: #selector(self.tok), userInfo: nil, repeats: true);
        RunLoop.current.run();
      });

      // Update the state of the metronome
      self.currentState = metronomeState.PLAYING;
    }
  }

  @objc
  func stop() -> Void {
    if (self.currentState == metronomeState.PLAYING) {
      self.timer?.invalidate();
      self.timer = nil;
      self.currentState = metronomeState.STOPPED;
    }
  }

  @objc(setBPM:)
  func setBPM(_ newBPM: Int) -> Void {
    self.bpm = newBPM;

    if (self.currentState == metronomeState.PLAYING) {
      self.stop();
      self.start();
    }
  }

  @objc(getBPM:rejecter:)
  func getBPM(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
    resolve(self.bpm);
  }

  @objc(setShouldPauseOnLostFocus:)
  func setShouldPauseOnLostFocus(_ shouldPause: Bool) -> Void {
    self.shouldPauseOnLostFocus = shouldPause;
  }

  @objc(getShouldPauseOnLostFocus:rejecter:)
  func getShouldPauseOnLostFocus(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
    resolve(self.shouldPauseOnLostFocus);
  }

  @objc(isPlaying:rejecter:)
  func isPlaying(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
    resolve(self.currentState == metronomeState.PLAYING);
  }

  @objc(isPaused:rejecter:)
  func isPaused(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
    resolve(self.currentState == metronomeState.PAUSED);
  }

  func invalidate() -> Void{
    self.stop();
  }
}
