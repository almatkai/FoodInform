//
//  RecommendationView.swift
//  DIPLOMA SWIFTUI
//
//  Created by Almat Kairatov on 22.02.2024.
//

import SwiftUI

struct BarcodeRecommendationView: View {
    @ObservedObject var vm: AppViewModel
        
    @State var starPressed = false
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Good")
                        .font(.title)
                        .foregroundStyle(.green)
                    
                    Spacer()
                    
                    Image(systemName: "barcode")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30)
                    Text("\(vm.barcodeProduct?.code ?? "Information is missing")")
                }
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: 1)
                
                HStack {
                    Text("\(vm.barcodeProduct?.product?.productName ?? "Information is missing")")
                    
                    Spacer()
                    
                    Image(systemName: starPressed ? "star.fill" : "star")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30)
                        .foregroundStyle(starPressed ? .yellow : .white)
                        .onTapGesture {
                            starPressed.toggle()
                        }
                }
                
                Text("Ingredients")
                
                VStack {
                    ForEach(vm.barcodeProduct?.product?.ingredients?.compactMap { $0 } ?? []) { ingredient in
                        HStack {
                            Text(ingredient.text)
                        }
                    }
                }
                
                VStack {
                    ImageFromUrlView(imageURL: vm.barcodeProduct?.product?.imageURL ?? "")
                    ImageFromUrlView(imageURL: vm.barcodeProduct?.product?.imageNutritionThumbUrl ?? "")
                    ImageFromUrlView(imageURL: vm.barcodeProduct?.product?.imageIngredientsUrl ?? "")
                }
            }
            .padding(40)
        }
    }
}
