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
    
    let height = UIScreen.main.bounds.height
    
    var body: some View {
        ZStack {
            HStack {
                // MARK: - Functional Camera Buttons
                VStack{
                    CameraActionButton(action: {
                        vibrate()
                        vm.showText = true
                    },
                        image: "tray",
                        width: 22)
                    // MARK: - Disable Barcode Search Button
                    ZStack {
                        CameraActionButton(action: {
                            vm.isSheetPageOpen.toggle()
                            vm.showBarcodeSearch = false
                            vibrate()
                            withAnimation {
                                if vm.barcodeScanDisabled {
                                    vm.stopScanning = false
                                    self.vm.barcodeScanDisabled.toggle()
                                    vm.isSheetPageOpen = false
                                }
                                else {
                                    vm.isSheetPageOpen = true
                                    vm.stopScanning = true
                                    self.vm.barcodeScanDisabled.toggle()
                                }
                            }
                        }, image: "barcode.viewfinder", width: 22, fontWeigt: .medium)
                        
                        if vm.barcodeScanDisabled {
                            Rectangle()
                                .frame(width: 36, height: 2)
                                .rotationEffect(Angle(degrees: 135))
                                .foregroundStyle(.white)
                        }
                    }
                    
                    // MARK: - Flash Button
                    CameraActionButton(action: {
                        toggleTorch()
                        vibrate()
                        withAnimation {
                            flashOn.toggle()
                        }
                    }, imagePressed: "bolt.fill", image: "bolt", width: 18, pressed: flashOn, fontWeigt: .medium)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            // MARK: - Barcode Search Show
            if vm.showBarcodeSearch {
                VStack{
                    HStack {
                        switch vm.showBarcodeSearchRes {
                        case .found:
                            Text("See results")
                                .barcodeInfoTextModifier()
                                .onTapGesture {
                                    vibrate()
                                    showBarcodeSearch = true
                                    vm.stopScanning = true
                                    vm.isSheetPageOpen = true
                                }
                        case .notFound:
                            Text("No information available for this barcode \n Try Text Search")
                                .barcodeInfoTextModifier()
                                .multilineTextAlignment(.center)
                        case .notEnoughInfo:
                            Text("Insufficient barcode \n Try Text Search")
                                .barcodeInfoTextModifier()
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, height * 0.1)
                    Spacer()
                }
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
            vm.stopScanning = false
            vm.isSheetPageOpen = false
            withAnimation {
                vm.showBarcodeSearch = false
                showBarcodeSearch = false
            }
        }, content: {
            BarcodeRecommendationView(vm: vm)
                .presentationDetents([.fraction(0.75)])
        })
//        .gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
//            .onEnded { value in
//                print(value.translation)
//                switch(value.translation.width, value.translation.height) {
//                    case (...0, -30...30):  print("left swipe")
//                    case (0..., -30...30):  print("right swipe")
//                    case (-100...100, ...0):
//                        if vm.showBarcodeSearchRes == .found {
//                            showBarcodeSearch = true
//                            vm.stopScanning = true
//                            vm.isSheetPageOpen = true
//                        }
//                    case (-100...100, 0...):  print("down swipe")
//                    default:  print("no clue")
//                }
//            }
//        )
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
    
    @ViewBuilder
    private func CameraActionButton(action: @escaping () -> Void, imagePressed: String = "", image: String, width: CGFloat, pressed: Bool = false, fontWeigt: Font.Weight = .semibold) -> some View {
        Button(action: action) {
            Image(systemName: pressed ? imagePressed : image)
                .resizable()
                .scaledToFit()
                .frame(width: width)
                .fontWeight(fontWeigt)
                .foregroundStyle(pressed ? .yellow : .white)
                .padding()
        }
        .background {
            Circle()
                .frame(width: 50)
                .foregroundStyle(Color.black.opacity(0.6))
        }
    }
}

#Preview {
    ScannerOverlayView(vm: AppViewModel())
}

extension View {
    @ViewBuilder
    func barcodeInfoTextModifier() -> some View {
        self
            .font(.system(size: 14))
            .foregroundStyle(.white)
            .padding(9)
            .background {
                Color.black.opacity(0.35).cornerRadius(8)
            }
    }
}

