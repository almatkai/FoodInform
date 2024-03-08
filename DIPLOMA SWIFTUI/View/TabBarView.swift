//
//  TabBarView.swift
//  DIPLOMA SWIFTUI
//
//  Created by Almat Kairatov on 25.02.2024.
//

import SwiftUI

struct TabBarView: View {
    
    @ObservedObject var vm: AppViewModel

    var width: CGFloat
    var height: CGFloat
    var bottomInset: CGFloat
    @Binding var index: Int
    @Binding var activeTab: [Bool?]
    
    @State var secondTap = false
    
    var body: some View {
        VStack{
            Spacer()
            HStack {
                HStack {
                    Spacer()
                    VStack{
                        Image(systemName: "clock.arrow.circlepath")
                            .applyCustomModifier(width: 35, flag: index == 0, colorActive: .blue, colorNonActive: .gray)
                            .bounceSymbolEffect(value: activeTab[0])
                            .symbolRenderingMode(index == 0 ? .multicolor : .hierarchical)
                        Text("History")
                            .font(.system(size: 14))
                            .foregroundStyle(index == 0 ? .blue : Color("black"))
                    }
                    .onTapGesture {
                        vm.capturedPhoto = nil
                        withAnimation(.bouncy) {
                            index = 0
                        }
                        secondTap = false
                    }
                    
                    Spacer()
                    ZStack {
                        Circle()
                            .frame(width: index == 1 ? 90 : 65)
                            .foregroundColor(vm.dataScannerAccessStatus == .scannerAvailable ? .blue : .gray)
                        VStack{
                            Image(systemName: vm.textIdendificationInProgress ? "circle.dotted" : "text.viewfinder")
                                .applyCustomModifier(width: index == 1 ? 45 : 30, flag: index == 1, colorActive: .white, colorNonActive: .white)
                                .replaceSymbolEffect()
                        }
                    }
                    .offset(y: index == 1 ? -47.5 : -8)
                    .frame(width: 90)

                    .onTapGesture {
                        vibrate()
                        
                        Task {
                            await vm.requestDataScannerAccessStatus()
                        }
                        
                        if index == 1 {
                            withAnimation {
                                vm.shouldCapturePhoto = true
                                secondTap = true
                            }
                        }
                        
                        withAnimation(.bouncy) {
                            index = 1
                        }
                    }
                    Spacer()
                    VStack{
                        Image(systemName: index == 2 ? "person.fill" : "person")
                            .applyCustomModifier(width: 35, flag: index == 2, colorActive: .blue, colorNonActive: .gray)
                        Text("Profile")
                            .font(.system(size: 14))
                            .foregroundStyle(index == 2 ? .blue : Color("black"))
                    }
                    .onTapGesture {
                        vm.capturedPhoto = nil
                        withAnimation(.bouncy) {
                            index = 2
                        }
                        secondTap = false
                    }
                    Spacer()
                }
                .frame(width: width, height: 95)
                .background {
                    Color("white")
                        .frame(maxWidth: .infinity)
                        .opacity(0.75)
                }
                .shadow(radius: 10)
            }
            .frame(width: width, height: 95)
        }
        .onChange(of: index) { newValue in
            switch newValue {
            case 0:
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction, {
                    activeTab[2] = nil
                    activeTab[1] = nil
                })
                activeTab[0] = true
            case 1:
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction, {
                    activeTab[0] = nil
                    activeTab[2] = nil
                })
                activeTab[1] = true
            default:
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction, {
                    activeTab[0] = nil
                    activeTab[1] = nil
                })
                activeTab[2] = true
            }
        }
    }
}

extension Image {
    func applyCustomModifier(width: CGFloat, flag: Bool?, colorActive: Color?, colorNonActive: Color?) -> some View {
        self
            .resizable()
            .scaledToFit()
            .frame(width: width)
            .foregroundColor(flag ?? false ? colorActive : colorNonActive)
    }
}
