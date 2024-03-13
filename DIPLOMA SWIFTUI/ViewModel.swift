//
//  ViewModel.swift
//  DIPLOMA SWIFTUI
//
//  Created by Almat Kairatov on 14.02.2024.
//

import AVKit
import Foundation
import PhotosUI
import SwiftUI
import VisionKit

enum ScanType: String {
    case barcode, text
}

enum SearchResult {
    case found
    case notFound
    case notEnoughInfo
}

enum DataScannerAccessStatusType {
    case notDetermined
    case cameraAccessNotGranted
    case cameraNotAvailable
    case scannerAvailable
    case scannerNotAvailable
}

@MainActor
final class AppViewModel: ObservableObject {
    
    @Published var dataScannerAccessStatus: DataScannerAccessStatusType = .notDetermined
    @Published var recognizedItems: [RecognizedItem] = []
    @Published var textContentType: DataScannerViewController.TextContentType?
    
    @Published var shouldCapturePhoto = false
    @Published var capturedPhoto: UIImage? = nil
    @Published var selectedPhotoPickerItem: PhotosPickerItem? = nil
    @Published var previousBarcode = ""
    @Published var barcode = ""
    @Published var text = ""
    @Published var barcodeProduct: BarcodeProduct? = nil
    
    @Published var textIdendificationInProgress = false
    @Published var showText = false
    @Published var showBarcodeSearch = false
    @Published var showBarcodeSearchRes: SearchResult = .notFound
    @Published var stopScanning = false
    @Published var isSheetPageOpen = false
    @Published var barcodeScanDisabled = false
        
    var recognizedDataType: DataScannerViewController.RecognizedDataType = .barcode()
    
    private var isScannerAvailable: Bool {
        DataScannerViewController.isAvailable && DataScannerViewController.isSupported
    }
    
    func requestDataScannerAccessStatus() async {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            dataScannerAccessStatus = .cameraNotAvailable
            return
        }
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            
        case .authorized:
            dataScannerAccessStatus = isScannerAvailable ? .scannerAvailable : .scannerNotAvailable
            
        case .restricted, .denied:
            dataScannerAccessStatus = .cameraAccessNotGranted
            
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            if granted {
                dataScannerAccessStatus = isScannerAvailable ? .scannerAvailable : .scannerNotAvailable
            } else {
                dataScannerAccessStatus = .cameraAccessNotGranted
            }
            
        default: break
        }
    }
    
    
    func fetchProductData() {
        let baseURL = "https://world.openfoodfacts.org/api/v0/product/"
        let apiURL = URL(string: baseURL + barcode + ".json")!

        print("4")
        URLSession.shared.fetchData(for: apiURL) { (result: Result<BarcodeProduct, Error>) in
            print("5")
            switch result {
            case .success(let barcodeProduct):
                
                print("6")
                self.barcodeProduct = barcodeProduct
                // Handle success cases directly
                if self.barcodeProduct!.statusVerbose == "product found" {
                    if self.barcodeProduct?.product?.ingredients == nil {
                        self.showBarcodeSearchRes = .notEnoughInfo
                        print("7")
                    } else {
                        self.showBarcodeSearchRes = .found
                        print("8")
                    }
                } else if self.barcodeProduct!.statusVerbose == "product not found" {
                    self.showBarcodeSearchRes = .notFound
                    print("9")
                }
            case .failure(_):
                self.showBarcodeSearchRes = .notFound
                print("10")
            }
            self.showBarcodeSearch = true
            print("11")
            self.fetchingInfoTimer()
        }
    }
    
    func fetchingInfoTimer() {
        if self.showBarcodeSearchRes == .found {
            DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                withAnimation {
                    self.showBarcodeSearch = false
                    print("12")
                }
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    self.showBarcodeSearch = false
                print("13")
                }
            }
        }
    }

}


extension URLSession {
    func fetchData<T: Decodable>(for url: URL, completion: @escaping (Result<T, Error>) -> Void) {
        self.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            }
            
            if let data = data {
                do {
                    let object = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(object))
                } catch let decoderError {
                    completion(.failure(decoderError))
                }
            }
        }.resume()
    }
}

