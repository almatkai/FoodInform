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
    @Published var barcode = ""
    @Published var text = ""
    @Published var product: Product? = nil
    
    @Published var showBarcodeSearch = false
    @Published var stopScanning = false
    
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
        
        print("DEBUG: fetchProductData")
        URLSession.shared.fetchData(for: apiURL) { (result: Result<BarcodeProduct, Error>) in
            switch result {
            case .success(let product):
                self.product = product.product
                if let product = self.product {
                    withAnimation(.bouncy) {
                        self.showBarcodeSearch = true
                    }
                } else {
                    self.showBarcodeSearch = false
                }
            case .failure(let error):
                print("Error: \(error)")
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

