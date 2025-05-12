//
//  SpeechManager.swift
//  whisper.swiftui
//
//  Created by Anthony Campos on 5/6/25.
//
import AVFoundation

class SpeechManager: ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()
    
    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        synthesizer.speak(utterance)
    }
}


