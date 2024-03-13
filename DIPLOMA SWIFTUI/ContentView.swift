//
//  ContentView.swift
//  DIPLOMA SWIFTUI
//
//  Created by Almat Kairatov on 14.02.2024.
//

import PhotosUI
import SwiftUI

struct ContentView: View {
    
    @ObservedObject var vm: AppViewModel
    @State var width: CGFloat = 0
    @State var height: CGFloat = 0
    @State var bottomInset: CGFloat = 0
    
    // MARK: - TabBar Variables
    @State var index = 1
    @State var activeTab: [Bool?] = [nil, true, nil]
    
    // MARK: - Scan Variables
    var recognize = false
    @State var showText = false
    @State var showBarcode = false
    @State var showSearchBarcode = false
    
    
    @State var showBarcodeSearch = false
    var body: some View {
        GeometryReader(content: { geometry in
            ZStack {
                // MARK: - Views
                VStack {
                    switch index {
                    case 0:
                        VStack {
                            Text("History")
                                .frame(width: .infinity, height: .infinity)
                        }
                        .background(Color.pink)
                    case 1:
                        scannerView
                    default:
                        VStack {
                            Text("Profile")
                        }
                        .background(Color.pink)
                    }
                }
                .ignoresSafeArea()
                
                // MARK: - Tab Bar
                TabBarView(vm: vm, width: width,
                           height: height, bottomInset: bottomInset,
                           index: $index, activeTab: $activeTab)
                .ignoresSafeArea()
                
                
            }
            .onAppear {
                self.width = geometry.size.width
                self.height = geometry.size.height
                self.bottomInset = geometry.safeAreaInsets.bottom
            }
            .frame(width: width, height: height)
            
        })
    }
    
    @ViewBuilder
    private var scannerView: some View {
        switch vm.dataScannerAccessStatus {
        case .scannerAvailable:
            CameraView
        case .cameraNotAvailable:
            Text("Your device doesn't have a camera")
        case .scannerNotAvailable:
            VStack {
                Text("Your device doesn't have support for scanning barcode with this app")
                Button(action: {
                    vm.barcode = "5449000004864"
                    vm.fetchProductData()
                    showBarcodeSearch = true
                }){
                    Text("LET'S FUCKING READ BARCODE")
                }
            } 
            .sheet(isPresented: $showBarcodeSearch, onDismiss: {
                
            }, content: {
                BarcodeRecommendationView(vm: vm)
                    .presentationDetents([.fraction(0.75)])
            })
        case .cameraAccessNotGranted:
            Text("Please provide access to the camera in settings")
        case .notDetermined:
            Text("Request camera access")
                .onTapGesture {
                    Task {
                        await vm.requestDataScannerAccessStatus()
                    }
                }
        }
    }
    
    @ViewBuilder
    private var CameraView: some View {
        ZStack {
            DataScannerView(
                vm: vm
            )
            .ignoresSafeArea()
            
            ScannerOverlayView(vm: vm)
        }
        .sheet(isPresented: $vm.showText, onDismiss: {
            vm.capturedPhoto = nil
            if !vm.barcodeScanDisabled {
                vm.stopScanning = false
            }
        }, content: {
            TextRecommendationView(vm: vm)
                .presentationDetents([.fraction(0.75)])
        })
    }
}

#Preview {
    ContentView(vm: AppViewModel())
}

