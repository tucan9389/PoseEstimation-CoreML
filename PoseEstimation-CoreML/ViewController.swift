//
//  ViewController.swift
//  PoseEstimation-CoreML
//
//  Created by GwakDoyoung on 05/07/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import UIKit
import Vision
import CoreMedia

class ViewController: UIViewController, VideoCaptureDelegate {
    
    public typealias BodyPoint = (point: CGPoint, confidence: Double)
    public typealias DetectObjectsCompletion = ([BodyPoint?]?, Error?) -> Void
    
    // MARK: - UI 프로퍼티
    
    @IBOutlet weak var videoPreview: UIView!
    @IBOutlet weak var poseView: PoseView!
    @IBOutlet weak var mylabel: UILabel!
    
    @IBOutlet weak var etimeLabel: UILabel!
    @IBOutlet weak var fpsLabel: UILabel!
    
    
    
    
    var view_14: [UIView] = []
    
    
    // MARK - 성능 측정 프러퍼티
    private let 👨‍🔧 = 📏()
    
    
    // MARK - Core ML model
    
    var coremlModel: model_cpm? = nil
    
    // MARK: - Vision 프로퍼티
    
    var request: VNCoreMLRequest!
    var visionModel: VNCoreMLModel! {
        didSet {
            request = VNCoreMLRequest(model: visionModel, completionHandler: visionRequestDidComplete)
            // NOTE: If you choose another crop/scale option, then you must also
            // change how the BoundingBox objects get scaled when they are drawn.
            // Currently they assume the full input image is used.
            request.imageCropAndScaleOption = .scaleFill
        }
    }
    
    
    // MARK: - AV 프로퍼티
    
    var videoCapture: VideoCapture!
    let semaphore = DispatchSemaphore(value: 2)
    
    
    // MARK: - 라이프사이클 메소드
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MobileNet 클래스는 `MobileNet.mlmodel`를 프로젝트에 넣고, 빌드시키면 자동으로 생성된 랩퍼 클래스
        // MobileNet에서 만든 model: MLModel 객체로 (Vision에서 사용할) VNCoreMLModel 객체를 생성
        // Vision은 모델의 입력 크기(이미지 크기)에 따라 자동으로 조정해 줌
        visionModel = try? VNCoreMLModel(for: model_cpm().model)
        
        // 카메라 세팅
        setUpCamera()
        
        // 레이블 점 세팅
        setUpOutputComponent()
        
        // 성능측정용 델리게이트 설정
        👨‍🔧.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - 초기 세팅
    
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
    
    
    
    // MARK: - 추론하기
    
    func predictUsingVision(pixelBuffer: CVPixelBuffer) {
        
        // Vision이 입력이미지를 자동으로 크기조정을 해줄 것임.
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        try? handler.perform([request])
    }
    
    func visionRequestDidComplete(request: VNRequest, error: Error?) {
        
        if let observations = request.results as? [VNCoreMLFeatureValueObservation],
            let heatmap = observations.first?.featureValue.multiArrayValue {
            
            // convert heatmap to [keypoint]
            let n_kpoints = convert(heatmap: heatmap)
            
            
            // draw key points
            drawKeypoints(with: n_kpoints)
            
            
            // draw line
            poseView.bodyPoints = n_kpoints
            
            
            // show key points description
            showKeypointsDescription(with: n_kpoints)
            
            // end of measure
            self.👨‍🔧.🎬🤚()
            // 임시
            self.semaphore.signal()
        }
        
    }
    
    func convert(heatmap: MLMultiArray) -> [BodyPoint?] {
        guard heatmap.shape.count >= 3 else {
            print("heatmap's shape is invalid. \(heatmap.shape)")
            return []
        }
        let keypoint_number = heatmap.shape[0].intValue
        let heatmap_w = heatmap.shape[1].intValue
        let heatmap_h = heatmap.shape[2].intValue
        
        var n_kpoints = (0..<keypoint_number).map { _ -> BodyPoint? in
            return nil
        }
        
        for k in 0..<keypoint_number {
            for i in 0..<heatmap_w {
                for j in 0..<heatmap_h {
                    let index = k*(heatmap_w*heatmap_h) + i*(heatmap_h) + j
                    let confidence = heatmap[index].doubleValue
                    guard confidence > 0 else { continue }
                    if n_kpoints[k] == nil ||
                        (n_kpoints[k] != nil && n_kpoints[k]!.confidence < confidence) {
                        n_kpoints[k] = (CGPoint(x: CGFloat(j), y: CGFloat(i)), confidence)
                    }
                }
            }
        }
        
        // transpose to (1.0, 1.0)
        n_kpoints = n_kpoints.map { kpoint -> BodyPoint? in
            if let kp = kpoint {
                return (CGPoint(x: kp.point.x/CGFloat(heatmap_w),
                                y: kp.point.y/CGFloat(heatmap_h)),
                        kp.confidence)
            } else {
                return nil
            }
        }
        
        return n_kpoints
    }
    
    func drawKeypoints(with n_kpoints: [BodyPoint?]) {
        let imageFrame = CGRect(origin: .zero, size: self.videoPreview.frame.size)//self.imageView.imageFrame
        
        let minAlpha: CGFloat = 0.1
        let maxAlpha: CGFloat = 1.0
        let maxC: Double = 0.6
        let minC: Double = 0.1
        
        for (index, kp) in n_kpoints.enumerated() {
            if let n_kp = kp {
                let x = imageFrame.origin.x + n_kp.point.x * imageFrame.width
                let y = imageFrame.origin.y + n_kp.point.y * imageFrame.height
                view_14[index].center = CGPoint(x: x, y: y)
                let cRate = (n_kp.confidence - minC)/(maxC - minC)
                view_14[index].alpha = (maxAlpha - minAlpha) * CGFloat(cRate) + minAlpha
            } else {
                view_14[index].center = CGPoint(x: -4000, y: -4000)
                view_14[index].alpha = minAlpha
            }
        }
    }
    
    func showKeypointsDescription(with n_kpoints: [BodyPoint?]) {
        let resultString = zip(n_kpoints, Constant.pointLabels).reduce("", { (result, obj) -> String in
            var r = ""
            
            if Constant.pointLabels.index(of: obj.1) == 2 || Constant.pointLabels.index(of: obj.1) == 8 {
                r = "\n"
            }
            if let kp = obj.0 {
                let point = String(format: "(%.2f, %.2f)", kp.point.x, kp.point.y)
                let confidence = String(format: "%.3f", kp.confidence)
                r = r + obj.1 + ": " + "\(point)" + " " + "[\(confidence)]" + "\n"
                
            } else {
                r = r + obj.1 + ": " + "nil" + "\n"
            }
            
            return result + r
        })
        
        self.mylabel.text = resultString
    }
    
    
    // MARK: - VideoCaptureDelegate
    
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame pixelBuffer: CVPixelBuffer?, timestamp: CMTime) {
        
        // 비디오 캡쳐 큐에서 실행된 videoCapture(::) 메소드는 멈추기
        // 추론하는 동안은 메인스레드로 이동하여 처리
        semaphore.wait()
        
        // 카메라에서 캡쳐된 화면은 pixelBuffer에 담김.
        // Vision 프레임워크에서는 이미지 대신 pixelBuffer를 바로 사용 가능
        if let pixelBuffer = pixelBuffer {
            // 추론은 메인스레드에서 실행시키며
            // 추론 결과값 출력도 메인스레드에서 처리 후,
            // 멈춘 스레드를 풀어줌(semaphore.signal())
            DispatchQueue.main.async {
                // start of measure
                self.👨‍🔧.🎬👏()
                self.predictUsingVision(pixelBuffer: pixelBuffer)
            }
        }
    }
    
    
    
    // MARK: -
    
    func setUpOutputComponent() {
        view_14 = Constant.colors.map { color in
            let v = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
            v.backgroundColor = color
            v.clipsToBounds = false
            let l = UILabel(frame: CGRect(x: 4 + 3, y: -3, width: 100, height: 8))
            l.text = Constant.pointLabels[Constant.colors.index(where: {$0 == color})!]
            l.textColor = color
            l.font = UIFont.preferredFont(forTextStyle: .caption2)
            v.addSubview(l)
            self.videoPreview.addSubview(v)
            return v
        }
        
        
        var x: CGFloat = 0.0
        let y = self.videoPreview.frame.origin.y + self.videoPreview.frame.height
        let _ = Constant.colors.map { color in
            let index = Constant.colors.index(where: { color == $0 })
            if index == 2 || index == 8 { x += 28 }
            else { x += 14 }
            let v = UIView(frame: CGRect(x: x, y: y + 10, width: 4, height: 4))
            v.backgroundColor = color
            
            self.view.addSubview(v)
            return
        }
    }
    
}

extension ViewController: 📏Delegate {
    func updateMeasure(executionTime: Double, fps: Int) {
        //print(executionTime, fps)
        self.etimeLabel.text = "E Time: \(Int(executionTime*1000.0)) mm"
        self.fpsLabel.text = "fps: \(fps)"
    }
}


class PoseView: UIView {
    
    var bodyPoints: [ViewController.BodyPoint?] = [] {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        if let ctx = UIGraphicsGetCurrentContext() {
            
            ctx.clear(rect);
            
            //            drawLine(ctx: ctx, from: CGPoint(x: 10, y: 20), to: CGPoint(x: 100, y: 20), color: UIColor.red.cgColor)
            //            drawLine(ctx: ctx, from: CGPoint(x: 110, y: 120), to: CGPoint(x: 200, y: 120), color: UIColor.blue.cgColor)
            let size = self.bounds.size
            
            let color = Constant.jointLineColor.cgColor
            if Constant.pointLabels.count == bodyPoints.count {
                let _ = Constant.connectingPointIndexs.map { pIndex1, pIndex2 in
                    if let bp1 = self.bodyPoints[pIndex1], bp1.confidence > 0.5,
                        let bp2 = self.bodyPoints[pIndex2], bp2.confidence > 0.5 {
                        let p1 = bp1.point
                        let p2 = bp2.point
                        let point1 = CGPoint(x: p1.x * size.width, y: p1.y*size.height)
                        let point2 = CGPoint(x: p2.x * size.width, y: p2.y*size.height)
                        drawLine(ctx: ctx, from: point1, to: point2, color: color)
                    }
                }
            }
        }
    }
    
    func drawLine(ctx: CGContext, from p1: CGPoint, to p2: CGPoint, color: CGColor) {
        ctx.setStrokeColor(color)
        ctx.setLineWidth(3.0)
        
        ctx.move(to: p1)
        ctx.addLine(to: p2)
        
        ctx.strokePath();
    }
}



struct Constant {
    
    static let pointLabels = [
        "top\t\t\t", //0
        "neck\t\t", //1
        
        "R shoulder\t", //2
        "R elbow\t\t", //3
        "R wrist\t\t", //4
        "L shoulder\t", //5
        "L elbow\t\t", //6
        "L wrist\t\t", //7
        
        "R hip\t\t", //8
        "R knee\t\t", //9
        "R ankle\t\t", //10
        "L hip\t\t", //11
        "L knee\t\t", //12
        "L ankle\t\t", //13
    ]
    
    static let connectingPointIndexs: [(Int, Int)] = [
        (0, 1), // top-neck
        
        (1, 2), // neck-rshoulder
        (2, 3), // rshoulder-relbow
        (3, 4), // relbow-rwrist
        (1, 8), // neck-rhip
        (8, 9), // rhip-rknee
        (9, 10), // rknee-rankle
        
        (1, 5), // neck-lshoulder
        (5, 6), // lshoulder-lelbow
        (6, 7), // lelbow-lwrist
        (1, 11), // neck-lhip
        (11, 12), // lhip-lknee
        (12, 13), // lknee-lankle
    ]
    static let jointLineColor: UIColor = UIColor(displayP3Red: 87.0/255.0,
                                                 green: 255.0/255.0,
                                                 blue: 211.0/255.0,
                                                 alpha: 0.5)
    
    
    static let colors: [UIColor] = [
        .black,
        .darkGray,
        
        .lightGray,
        .white,
        .gray,
        .red,
        .green,
        .blue,
        
        .cyan,
        .yellow,
        .magenta,
        .orange,
        .purple,
        .brown
    ]
    
    
}
