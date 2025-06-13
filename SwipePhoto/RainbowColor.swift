//
//  RainbowColor.swift
//  SwipePhoto
//
//  Created by Atara Weinreb on 6/13/25.
//

import SwiftUI
import Foundation
enum RainbowColor: String, CaseIterable {
    case red, orange, yellow, green, blue, indigo, violet

    var color: Color {
        switch self {
        case .red: return .red
        case .orange: return .orange
        case .yellow: return .yellow
        case .green: return .green
        case .blue: return .blue
        case .indigo: return Color(hue: 0.7, saturation: 0.7, brightness: 0.7)
        case .violet: return Color.purple
        }
    }
} 
