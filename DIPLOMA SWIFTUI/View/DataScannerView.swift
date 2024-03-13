//
//  DataScannerView.swift
//  DIPLOMA SWIFTUI
//
//  Created by Almat Kairatov on 14.02.2024.
//

import Foundation
import SwiftUI
import Vision
import VisionKit

struct DataScannerView: UIViewControllerRepresentable {
    
    @ObservedObject var vm: AppViewModel
    @State var capturingAndRecognizing = false
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let vc = DataScannerViewController(
            recognizedDataTypes: [vm.recognizedDataType],
            qualityLevel: .accurate,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: false,
            isPinchToZoomEnabled: true, isGuidanceEnabled: false,
            isHighlightingEnabled: true
        )
        return vc
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        uiViewController.delegate = context.coordinator
        try? uiViewController.startScanning()
        if vm.shouldCapturePhoto, !capturingAndRecognizing {
            capturePhoto(dataScannerVC: uiViewController)
        }
        
        if vm.stopScanning {
            uiViewController.stopScanning()
        }
    }
    
    private func capturePhoto(dataScannerVC: DataScannerViewController) {
        Task { @MainActor in
            capturingAndRecognizing = true
            do {
                let photo = try await dataScannerVC.capturePhoto()
                self.vm.capturedPhoto = .init(photo)
            } catch {
                print(error.localizedDescription)
            }
            
            let recognizer = TextRecognizer()
            if let image = vm.capturedPhoto {
                recognizer.recognizeText(image: image, withCompletionHandler: { text in
                    self.vm.shouldCapturePhoto = false
                    self.capturingAndRecognizing = false
                    vm.text = text
                    if text != "" {
                        vm.showText = true
                        vm.stopScanning = true
                        print("DEBUG vm.showText: \(vm.showText)")
                        print("DEBUG vm.stopScanning: \(vm.stopScanning)")
                    }
                    print("DEBUG: \(text)")
                })
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(vm: _vm)
    }
    
    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
        uiViewController.stopScanning()
    }
    
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        
        @ObservedObject var vm: AppViewModel
        
        init(vm: ObservedObject<AppViewModel>) {
            self._vm = vm
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            
            vm.recognizedItems = addedItems
            
            switch vm.recognizedItems[0] {
            case .barcode(let barcode):
                self.vm.previousBarcode = self.vm.barcode
                self.vm.barcode = barcode.payloadStringValue ?? ""
                print("1")
                if self.vm.barcode != self.vm.previousBarcode {
                    self.vm.fetchProductData()
                    print("2")
                } else {
                    self.vm.showBarcodeSearch = true
                    self.vm.fetchingInfoTimer()
                    print("3")
                }
                // Pause the scanner
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.vm.stopScanning = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        if !self.vm.isSheetPageOpen {
                            self.vm.stopScanning = false
                        }
                    }
                }

            @unknown default:
                print("Unknown")
            }
        }
        func dataScanner(_ dataScanner: DataScannerViewController, becameUnavailableWithError error: DataScannerViewController.ScanningUnavailable) {
            print("became unavailable with error \(error.localizedDescription)")
        }
    }
}

