//
//  ViewController.swift
//  Album
//
//  Created by 严思远 on 2021/12/21.
//

import UIKit
import CoreMedia
import CoreML
import Vision

protocol AddPhotoDelegate {
    func addPhoto(image: UIImage, tag: String)
}

class addViewController: UIViewController {
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var photoLibraryButton: UIButton!
    @IBOutlet weak var resultsLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultsView: UIView!
    @IBOutlet weak var resultsConstraint: NSLayoutConstraint!
    
    var addPhotoDelegate: AddPhotoDelegate?
    var targetImage = UIImage()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        resultsView.alpha = 0
        resultsLabel.text = "choose or take a photo"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Show the "choose or take a photo" hint when the app is opened.
        showResultsView(delay: 0)
    }
  
    @IBAction func takePicture() {
        presentPhotoPicker(sourceType: .camera)
    }

    @IBAction func choosePhoto() {
        presentPhotoPicker(sourceType: .photoLibrary)
    }

    func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
        hideResultsView()
    }

    func showResultsView(delay: TimeInterval = 0.1) {
        resultsConstraint.constant = 100
        view.layoutIfNeeded()

        UIView.animate(withDuration: 0.5,
                       delay: delay,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.6,
                       options: .beginFromCurrentState,
                       animations: {
                          self.resultsView.alpha = 1
                          self.resultsConstraint.constant = -10
                          self.view.layoutIfNeeded()
                        },
                       completion: nil)
    }

    func hideResultsView() {
        UIView.animate(withDuration: 0.3) {
            self.resultsView.alpha = 0
        }
    }
    
    func classify(image: UIImage) {
        let handler = VNImageRequestHandler(cgImage: image.cgImage!)
        do {
            try handler.perform([self.classificationRequest])
        } catch {
            print("Failed to perform classification: \(error)")
        }
    }

}

extension addViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
      picker.dismiss(animated: true)

      let image = info[.originalImage] as! UIImage
      imageView.image = image
      self.targetImage = image
      
      classify(image: image)
  }
}

extension addViewController {
    func processObservations(for request: VNRequest, error: Error?) {
        // print("Result:",request.results)
        if let results = request.results as? [VNClassificationObservation] {
            if results.isEmpty {
                self.resultsLabel.text = "Nothing found"
            } else {
                let result = results[0].identifier
                let confidence = results[0].confidence
                if confidence < 0.80 {
                    self.resultsLabel.text! = "I'm not sure.Is this a/an " + result + " ?"
                    self.addPhotoDelegate?.addPhoto(image: self.targetImage, tag: "Not Sure")
                } else {
                    self.resultsLabel.text! = "I'm " + String(format:"%.1f%%", confidence * 100) + " sure that this is a/an " + result + "."
                    self.addPhotoDelegate?.addPhoto(image: self.targetImage, tag: result)
                }
            }
        } else if let error = error {
            self.resultsLabel.text = "Error: \(error.localizedDescription)"
        } else {
            self.resultsLabel.text = "???"
        }
        
        self.showResultsView()
    }
}


