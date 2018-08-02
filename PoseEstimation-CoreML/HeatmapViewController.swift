//
//  HeatmapViewController.swift
//  PoseEstimation-CoreML
//
//  Created by GwakDoyoung on 02/08/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import UIKit
import Vision
import CoreMedia

class HeatmapViewController: UIViewController {

    // MARK: - UI Properties
    @IBOutlet weak var videoPreview: UIView!
    @IBOutlet weak var heatmapView: HeatmapView!
    
    @IBOutlet weak var inferenceLabel: UILabel!
    @IBOutlet weak var etimeLabel: UILabel!
    @IBOutlet weak var fpsLabel: UILabel!
    
    // MARK - Performance Measurement Property
    private let 👨‍🔧 = 📏()
    
    // MARK - Core ML model
    typealias EstimationModel = model_cpm
    var coremlModel: EstimationModel? = nil
    
    // MARK: - Vision Properties
    var request: VNCoreMLRequest!
    var visionModel: VNCoreMLModel! {
        didSet {
            request = VNCoreMLRequest(model: visionModel, completionHandler: visionRequestDidComplete)
            request.imageCropAndScaleOption = .scaleFill
        }
    }
    
    // MARK: - AV Property
    var videoCapture: VideoCapture!
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        visionModel = try? VNCoreMLModel(for: EstimationModel().model)
        
        // 카메라 세팅
        setUpCamera()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - SetUp Video
    func setUpCamera() {
        videoCapture = VideoCapture()
        videoCapture.delegate = self
        videoCapture.fps = 30
        videoCapture.setUp(sessionPreset: .vga640x480) { success in
            
            if success {
                // UI에 비디오 미리보기 뷰 넣기
                if let previewLayer = self.videoCapture.previewLayer {
                    self.videoPreview.layer.addSublayer(previewLayer)
                    self.resizePreviewLayer()
                }
                
                // 초기설정이 끝나면 라이브 비디오를 시작할 수 있음
                self.videoCapture.start()
            }
        }
    }
    
    func resizePreviewLayer() {
        videoCapture.previewLayer?.frame = videoPreview.bounds
    }
    
    // MARK: - Inferencing
    func predictUsingVision(pixelBuffer: CVPixelBuffer) {
        // Vision이 입력이미지를 자동으로 크기조정을 해줄 것임.
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        try? handler.perform([request])
    }
    
    // MARK: - Poseprocessing
    func visionRequestDidComplete(request: VNRequest, error: Error?) {
        self.👨‍🔧.🏷(with: "endInference")
        if let observations = request.results as? [VNCoreMLFeatureValueObservation],
            let heatmap = observations.first?.featureValue.multiArrayValue {
            
            
            
            DispatchQueue.main.async {
                // end of measure
                self.heatmapView.heatmap = heatmap
                
                self.👨‍🔧.🎬🤚()
            }
        }
    }
}

// MARK: - VideoCaptureDelegate
extension HeatmapViewController: VideoCaptureDelegate {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame pixelBuffer: CVPixelBuffer?, timestamp: CMTime) {
        // 카메라에서 캡쳐된 화면은 pixelBuffer에 담김.
        // Vision 프레임워크에서는 이미지 대신 pixelBuffer를 바로 사용 가능
        if let pixelBuffer = pixelBuffer {
            // start of measure
            self.👨‍🔧.🎬👏()
            
            // predict!
            self.predictUsingVision(pixelBuffer: pixelBuffer)
        }
    }
}
