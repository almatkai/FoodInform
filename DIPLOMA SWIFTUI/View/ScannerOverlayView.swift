//
//  ScannerOverlayView.swift
//  DIPLOMA SWIFTUI
//
//  Created by Almat Kairatov on 28.02.2024.
//

import SwiftUI
import PhotosUI

struct ScannerOverlayView: View {
    
    var width = UIScreen.main.bounds.width
    
    @ObservedObject var vm: AppViewModel
    @State var  flashOn = false
    @State var showBarcodeSearch = false
    
    var body: some View {
        VStack{
            Spacer()
            ZStack {
                HStack {
                    // MARK: - Try to Search By Barcode Button
                    Spacer()
                    // MARK: - Flash Button
                    VStack{
                        Button(action: {
                            vibrate()
                            withAnimation {
                                vm.showBarcodeSearch = false
                                vm.stopScanning = false
                            }
                        }){
                            Image(systemName: "arrow.circlepath")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30)
                                .fontWeight(.semibold)
                                .foregroundStyle(flashOn ? Color(.yellow) : .white)
                                .padding()
                        }
                        .background {
                            Circle()
                                .frame(width: 50)
                                .foregroundStyle(Color.black.opacity(0.6))
                        }
                        .padding(.bottom, 10)
                        Button(action: {
                            toggleTorch()
                            vibrate()
                            withAnimation {
                                flashOn.toggle()
                            }
                        }){
                            Image(systemName: flashOn ? "bolt.fill" : "bolt")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18)
                                .foregroundStyle(flashOn ? Color(.yellow) : .white)
                                .padding()
                        }
                        .background {
                            Circle()
                                .frame(width: 50)
                                .foregroundStyle(Color.black.opacity(0.6))
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
                
                HStack {
                    // MARK: - Barcode Search Show
                    if vm.showBarcodeSearch {
                        Image(systemName: "barcode")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35)
                            .foregroundStyle(.blue)
                            .padding(5)
                            .pulseSymbolEffect()
                            .onTapGesture {
                                vibrate()
                                showBarcodeSearch = true
                            }
                    }
                    
                }
                .padding(.bottom, 50)
            }
        }
        .padding(.bottom, 95)
        .onReceive(vm.$capturedPhoto) { photo in
            let recognizer = TextRecognizer()
            if let image = photo {
                recognizer.recognizeText(image: image, withCompletionHandler: { text in
                    vm.text = text
                })
            }
        }
        .sheet(isPresented: $showBarcodeSearch, onDismiss: {
            vm.product = Product()
            withAnimation {
                vm.stopScanning = false
                vm.showBarcodeSearch = false
                showBarcodeSearch = false
            }
        }, content: {
            RecommendationView(vm: vm)
                .presentationDetents([.fraction(0.75)])
                .onAppear {
                    vm.stopScanning = true
                }
        })
    }
    
    private func toggleTorch() {
        guard
            let device = AVCaptureDevice.default(for: AVMediaType.video),
            device.hasTorch
        else { return }
        
        do {
            try device.lockForConfiguration()
            if device.torchMode == AVCaptureDevice.TorchMode.on
            {
                device.torchMode = .off
                
            } else {
                device.torchMode = .on
                
            }
            device.unlockForConfiguration()
        } catch {
            print("Torch could not be used")
        }
    }
}

#Preview {
    ScannerOverlayView(vm: AppViewModel())
}
