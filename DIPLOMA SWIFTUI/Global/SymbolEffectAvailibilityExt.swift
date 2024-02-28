//
//  SymbolEffectAvailibilityExt.swift
//  DIPLOMA SWIFTUI
//
//  Created by Almat Kairatov on 28.02.2024.
//

import SwiftUI

extension View {
    @ViewBuilder
    func bounceSymbolEffect(value: Bool? = true) -> some View {
        if #available(iOS 17.0, *) {
            self
                .symbolEffect(.bounce.down.byLayer, value: value)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func pulseSymbolEffect(value: Bool? = true) -> some View {
        if #available(iOS 17.0, *) {
            self
                .symbolEffect(.pulse, options: .repeating, value: value)
        } else {
            self
        }
    }
}
