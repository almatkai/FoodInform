//
//  TextRecommendationView.swift
//  DIPLOMA SWIFTUI
//
//  Created by Almat Kairatov on 05.03.2024.
//

import SwiftUI

struct TextRecommendationView: View {
    
    @ObservedObject var vm: AppViewModel
    
    var body: some View {
        ScrollView {
            Text(vm.text)
        }
    }
}

#Preview {
    TextRecommendationView(vm: AppViewModel())
}
