//
//  FunctionalityFunctions.swift
//  DIPLOMA SWIFTUI
//
//  Created by Almat Kairatov on 27.02.2024.
//

import Foundation
import SwiftUI

public func vibrate() {
    let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    impactFeedbackGenerator.prepare()
    impactFeedbackGenerator.impactOccurred()
}
