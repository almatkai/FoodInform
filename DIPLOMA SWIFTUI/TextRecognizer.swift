//
//  TextRecognizer.swift
//  DIPLOMA SWIFTUI
//
//  Created by Almat Kairatov on 18.02.2024.
//

import Foundation
import Vision
import VisionKit

final class TextRecognizer {
    var image: UIImage? = nil
    
    private let queue = DispatchQueue(label: "scan-codes", qos: .default, attributes: [], autoreleaseFrequency: .workItem)
    
    func recognizeText(image: UIImage, withCompletionHandler completionHandler: @escaping (String) -> Void) {
        self.image = image
        queue.async {
            guard let cgImage = self.image?.cgImage else {
                completionHandler("")
                return
            }
            
            let request = VNRecognizeTextRequest()
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    completionHandler("")
                    return
                }
                
                let recognizedText = observations.compactMap({ $0.topCandidates(1).first?.string }).joined(separator: "\n")
                completionHandler(recognizedText)
            } catch {
                print(error)
                completionHandler("")
            }
        }
    }
}
