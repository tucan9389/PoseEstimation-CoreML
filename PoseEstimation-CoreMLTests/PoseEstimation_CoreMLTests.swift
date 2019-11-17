//
//  PoseEstimation_CoreMLTests.swift
//  PoseEstimation-CoreMLTests
//
//  Created by GwakDoyoung on 31/01/2019.
//  Copyright © 2019 tucan9389. All rights reserved.
//

import XCTest
import Vision

class PoseEstimation_CoreMLTests: XCTestCase {
    
    // MARK: - Vision Properties
    var cpmRequest: VNCoreMLRequest?
    var cpmModel: VNCoreMLModel?
    
    var hourglassRequest: VNCoreMLRequest?
    var hourglassModel: VNCoreMLModel?
    
    let image = UIImage(named: "adult-building-business-1436289")
    var pixelBuffer: CVPixelBuffer?
    
    override func setUp() {
        // <# CPM model #>
        cpmModel = try? VNCoreMLModel(for: model_cpm().model)
        if let visionModel = cpmModel {
            cpmRequest = VNCoreMLRequest(model: visionModel, completionHandler: visionRequestDidComplete)
        }
        cpmRequest?.imageCropAndScaleOption = .scaleFill
        
        // <# Hourglass model #>
        hourglassModel = try? VNCoreMLModel(for: model_hourglass().model)
        if let visionModel = hourglassModel {
            hourglassRequest = VNCoreMLRequest(model: visionModel, completionHandler: visionRequestDidComplete)
        }
        hourglassRequest?.imageCropAndScaleOption = .scaleFill
        
        // image configuration
        pixelBuffer = image?.pixelBufferFromImage()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPerformanceCPMModel() {
        guard let pixelBuffer = pixelBuffer,
            let request = cpmRequest else {
                fatalError()
        }
        self.measure {
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
            try? handler.perform([request])
        }
    }
    
    func testPerformanceHourglassModel() {
        guard let pixelBuffer = pixelBuffer,
            let request = hourglassRequest else {
            fatalError()
        }
        self.measure {
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
            try? handler.perform([request])
        }
    }
    
    func visionRequestDidComplete(request: VNRequest, error: Error?) {
        
    }
}
