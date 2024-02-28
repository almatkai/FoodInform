//
//  RecommendationView.swift
//  DIPLOMA SWIFTUI
//
//  Created by Almat Kairatov on 22.02.2024.
//

import SwiftUI

struct RecommendationView: View {
    @ObservedObject var vm: AppViewModel
    var body: some View {
        VStack {
            Image(systemName: "person")
                .resizable()
                .scaledToFit()
                .frame(width: 100)
            Text("\(vm.product?.productName ?? "") XUI")
            
            //list products
            List {
                ForEach(vm.product!.ingredients) { ingredient in
                    HStack {
                        Text(ingredient.text)
                        Spacer()
                        Image(systemName: "person")
                    }
                }
            }
        }
        .onAppear {
            print("DEBUG: \(vm.product)")
        }
    }
}
