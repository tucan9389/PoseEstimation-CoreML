//
//  StillImageHeatmapViewController.swift
//  PoseEstimation-CoreML
//
//  Created by Doyoung Gwak on 25/04/2019.
//  Copyright © 2019 tucan9389. All rights reserved.
//

import UIKit
import Photos
import Vision
import CoreMedia

class StillImageHeatmapViewController: UIViewController {
    
    // MARK: - UI Properties
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var heatmapView: DrawingHeatmapView!
    @IBOutlet weak var guideLabel: UILabel!
    
    let galleryPicker = UIImagePickerController()
    
    // MARK: - ML Properties
    // Core ML model
    typealias EstimationModel = model_cpm
    
    // Preprocess and Inference
    var request: VNCoreMLRequest?
    var visionModel: VNCoreMLModel?
    
    // Postprocess
    var postProcessor: HeatmapPostProcessor = HeatmapPostProcessor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup the model
        setUpModel()
    }
    
    // MARK: - Setup Core ML
    func setUpModel() {
        if let visionModel = try? VNCoreMLModel(for: EstimationModel().model) {
            self.visionModel = visionModel
            request = VNCoreMLRequest(model: visionModel, completionHandler: visionRequestDidComplete)
            request?.imageCropAndScaleOption = .scaleFill
        } else {
            fatalError()
        }
    }
    
    @IBAction func tapPhotoLibraryItem(_ sender: Any) {
        openPicker()
    }
    
    // opens the image picker for photo library
    func openPicker() {
        galleryPicker.sourceType = .photoLibrary
        galleryPicker.delegate = self
        present(galleryPicker, animated: true)
    }
}

// MARK: - UINavigationControllerDelegate & UIImagePickerControllerDelegate
extension StillImageHeatmapViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
        print("canceled")
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            mainImageView.image = image
            guideLabel.alpha = 0
            predictUsingVision(uiImage: image)
        }
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Core ML
extension StillImageHeatmapViewController {
    // MARK: - Inferencing
    func predictUsingVision(uiImage: UIImage) {
        guard let request = request, let cgImage = uiImage.cgImage else { fatalError() }
        // vision framework configures the input size of image following our model's input configuration automatically
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: uiImage.convertImageOrientation())
        try? handler.perform([request])
    }
    
    // MARK: - Poseprocessing
    func visionRequestDidComplete(request: VNRequest, error: Error?) {
        if let observations = request.results as? [VNCoreMLFeatureValueObservation],
            let heatmaps = observations.first?.featureValue.multiArrayValue {
            
            // convert heatmap to Array<Array<Double>>
            let heatmap3D = postProcessor.convertTo2DArray(from: heatmaps)

            // must run on main thread
            self.heatmapView.heatmap3D = heatmap3D
            
        }
    }
}

extension UIImage {
    func convertImageOrientation() -> CGImagePropertyOrientation  {
        let cgiOrientations : [ CGImagePropertyOrientation ] = [
            .up, .down, .left, .right, .upMirrored, .downMirrored, .leftMirrored, .rightMirrored
        ]
        return cgiOrientations[imageOrientation.rawValue]
    }
}
