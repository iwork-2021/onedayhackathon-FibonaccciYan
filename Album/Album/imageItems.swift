//
//  imageItem.swift
//  Album
//
//  Created by 严思远 on 2021/12/21.
//

import UIKit
import CoreML
import CoreMedia
import Vision

class imageItems: NSObject {
    var collectionViewController: UICollectionViewController?
    var targetImage: UIImage = UIImage()
    var images: [UIImage] = []
    var tags: [String:[UIImage]] = ["apple":[],
                                    "banana":[],
                                    "cake":[],
                                    "candy":[],
                                    "carrot":[],
                                    "cookie":[],
                                    "doughnut":[],
                                    "grape":[],
                                    "hot dog":[],
                                    "ice cream":[],
                                    "juice":[],
                                    "muffin":[],
                                    "orange":[],
                                    "pineapple":[],
                                    "popcorn":[],
                                    "pretzel":[],
                                    "salad":[],
                                    "strawberry":[],
                                    "waffle":[],
                                    "watermelon":[],
                                    "Not Sure":[]
    ]
    
    lazy var classificationRequest: VNCoreMLRequest = {
        do{
            let classifier = try snacks(configuration: MLModelConfiguration())
            let model = try VNCoreMLModel(for: classifier.model)
            let request = VNCoreMLRequest(model: model, completionHandler: {
                [weak self] request,error in
                self?.processObservations(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to create request")
        }
    }()
    
    override init() {
        images.append(UIImage(named: "apple.jpg")!)
        tags["apple"]?.append(contentsOf: [UIImage(named: "apple.jpg")!])
        images.append(UIImage(named: "orange.jpg")!)
        tags["orange"]?.append(contentsOf: [UIImage(named: "orange.jpg")!])
        images.append(UIImage(named: "strawberry.jpg")!)
        tags["strawberry"]?.append(contentsOf: [UIImage(named: "strawberry.jpg")!])
    }
    
    func addImage(image: UIImage) {
        images.append(image)
        self.collectionViewController?.collectionView.reloadData()
        targetImage = image
        classify(image: targetImage)
    }
    
    
    
    func processObservations(for request: VNRequest, error: Error?) {
        if let results = request.results as? [VNClassificationObservation] {
            if results.isEmpty {
                return
            } else {
                let result = results[0].identifier
                let confidence = results[0].confidence
                if confidence < 0.70 {
                    // self.resultsLabel.text! = "I'm not sure.Is this a/an " + result + " ?"
                    tags["Not Sure"]?.append(targetImage)
                } else {
                    // self.resultsLabel.text! = "I'm " + String(format:"%.1f%%", confidence * 100) + " sure that this is a/an " + result + "."
                    tags[result]?.append(targetImage)
                }
            }
        } else if let error = error {
            // self.resultsLabel.text = "Error: \(error.localizedDescription)"
            print("Error: \(error.localizedDescription)")
        } else {
            // self.resultsLabel.text = "???"
            print("???")
        }
        
        // self.showResultsView()
    }
    
    func getCount() -> Int {
        return images.count
    }
}

extension UIImage {
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
            // Determine the scale factor that preserves aspect ratio
            let widthRatio = targetSize.width / size.width
            let heightRatio = targetSize.height / size.height
            
            let scaleFactor = min(widthRatio, heightRatio)
            
            // Compute the new image size that preserves aspect ratio
            let scaledImageSize = CGSize(
                width: size.width * scaleFactor,
                height: size.height * scaleFactor
            )

            // Draw and return the resized UIImage
            let renderer = UIGraphicsImageRenderer(
                size: scaledImageSize
            )

            let scaledImage = renderer.image { _ in
                self.draw(in: CGRect(
                    origin: .zero,
                    size: scaledImageSize
                ))
            }
            
            return scaledImage
        }
    
    func toCVPixelBuffer() -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(self.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard status == kCVReturnSuccess else {
            return nil
        }

        if let pixelBuffer = pixelBuffer {
            CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
            let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)

            let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
            let context = CGContext(data: pixelData, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

            context?.translateBy(x: 0, y: self.size.height)
            context?.scaleBy(x: 1.0, y: -1.0)

            UIGraphicsPushContext(context!)
            self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
            UIGraphicsPopContext()
            CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))

            return pixelBuffer
        }

        return nil
    }
}
