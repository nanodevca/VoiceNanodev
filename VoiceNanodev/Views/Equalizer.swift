//
//  Equalizer.swift
//  VoiceNanodev
//
//  Created by Roy Christo Ndjanfa Biaga on 2024-10-05.
//

import SwiftUI

struct EqualizerView: View {
    var level: Float // Niveau de la voix normalisé entre 0 et 1
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<5) { i in
                BarView(level: level, index: i)
            }
        }
        .frame(height: 100)
    }
}

struct BarView: View {
    var level: Float
    var index: Int
    
    var body: some View {
        let adjustedLevel = min(max(0, level - Float(index) * 0.3), 2.0)
        let barHeight = CGFloat(adjustedLevel) * 100
        
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.green)
            .frame(width: 10, height: barHeight)
            .animation(.easeOut(duration: 0.4), value: barHeight)
    }
}

struct CircleView: View {
    var level: Float // Niveau de la voix normalisé entre 0 et 1
    
    var body: some View {
        let size = CGFloat(level) * 100 + 50 // Taille du cercle varie avec le niveau de la voix
        
        Circle()
            .fill(Color.blue)
            .frame(width: size, height: size)
            .animation(.easeInOut(duration: 0.2), value: size)
    }
}
