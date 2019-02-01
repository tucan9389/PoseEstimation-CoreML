

# PoseEstimation-CoreML

This project is Pose Estimation on iOS with Core ML.<br>If you are interested in iOS + Machine Learning, visit [here](https://github.com/motlabs/iOS-Proejcts-with-ML-Models) you can see various DEMOs.<br>

| Jointed Keypoints                                            | Concatenated heatmap                                         |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| ![poseestimation-demo-joint.gif](resource/180801-poseestimation-demo.gif?raw=true) | ![poseestimation-demo-heatmap.gif](resource/180914-poseestimation-demo.gif) |

[한국어 README](https://github.com/tucan9389/PoseEstimation-CoreML/blob/master/README_kr.md)

## How it works

![how_it_works](resource/how_it_works.png)

Video source: [https://www.youtube.com/watch?v=EM16LBKBEgI](https://www.youtube.com/watch?v=EM16LBKBEgI)

## Requirements

- Xcode 9.2+
- iOS 11.0+
- Swift 4.1

## Download model

### Get PoseEstimationForMobile's model

Pose Estimation model for Core ML(`model_cpm.mlmodel`)<br>
☞ Download Core ML model [model_cpm.mlmodel](https://github.com/edvardHua/PoseEstimationForMobile/tree/master/release/cpm_model) or [hourglass.mlmodel](https://github.com/edvardHua/PoseEstimationForMobile/tree/master/release/hourglass_model).

> input_name_shape_dict = {"image:0":[1,192,192,3]} image_input_names=["image:0"] <br>output_feature_names = ['Convolutional_Pose_Machine/stage_5_out:0']
>
> －in [https://github.com/edvardHua/PoseEstimationForMobile](https://github.com/edvardHua/PoseEstimationForMobile)

|                  | cpm                                      | hourglass          |
| ---------------- | ---------------------------------------- | ------------------ |
| Input shape      | `[1, 192, 192, 3]`                       | `[1, 192, 192, 3]` |
| Output shape     | `[1, 96, 96, 14]`                        | `[1, 48, 48, 14]`  |
| Input node name  | `image`                                  | `image`            |
| Output node name | `Convolutional_Pose_Machine/stage_5_out` | `hourglass_out_3`  |
| Model size       | 2.6 MB                                   | 2.0 MB             |

#### Inference Time

|           | cpm   | hourglass |
| --------- | ----- | --------- |
| iPhone X  | 51 mm | 49 mm     |
| iPhone 8+ | 49 mm | 46 mm     |

### Get your own model

> Or you can use your own PoseEstimation model

## Build & Run

### 1. Prerequisites

#### 1.1 Import pose estimation model

![모델 불러오기.png](https://github.com/tucan9389/MobileNetApp-CoreML/blob/master/resource/%EB%AA%A8%EB%8D%B8%20%EB%B6%88%EB%9F%AC%EC%98%A4%EA%B8%B0.png?raw=true)

Once you import the model, compiler generates model helper class on build path automatically. You can access the model through model helper class by creating an instance, not through build path.

#### 1.2 Add permission in info.plist for device's camera access

![prerequest_001_plist](resource/prerequest_001_plist.png)

### 2. Dependencies

No external library yet.

### 3. Code

```swift
import Vision

// properties on JointViewController
typealias EstimationModel = model_cpm // model name(model_cpm) must be same with mlmodel file name
var request: VNCoreMLRequest!
var visionModel: VNCoreMLModel!

// on viewDidLoad
visionModel = try? VNCoreMLModel(for: EstimationModel().model)
request = VNCoreMLRequest(model: visionModel, completionHandler: visionRequestDidComplete)
request.imageCropAndScaleOption = .scaleFill

func visionRequestDidComplete(request: VNRequest, error: Error?) { 
    /* ------------------------------------------------------ */
    /* something postprocessing what you want after inference */
    /* ------------------------------------------------------ */
}

// on the inference point
let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
try? handler.perform([request])
```

## Performance Test

### 1. Import the model

You can download cpm or hourglass model for Core ML from [edvardHua/PoseEstimationForMobile](https://github.com/edvardHua/PoseEstimationForMobile) repo.

### 2. Fix the model name on [`PoseEstimation_CoreMLTests.swift`](PoseEstimation-CoreMLTests/PoseEstimation_CoreMLTests.swift)

![fix-model-name-for-testing](resource/fix-model-name-for-testing.png)

### 3. Run the test

Hit the `⌘ + U` or click the `Build for Testing` icon.

![build-for-testing](resource/build-for-testing.png)



## See also

- [motlabs/iOS-Proejcts-with-ML-Models](https://github.com/motlabs/iOS-Proejcts-with-ML-Models)<br>
  : The challenge using machine learning model created from tensorflow on iOS
- [edvardHua/PoseEstimationForMobile](https://github.com/edvardHua/PoseEstimationForMobile)<br>
  : TensorFlow project for pose estimation for mobile
- [tucan9389/FingertipEstimation-CoreML](https://github.com/tucan9389/FingertipEstimation-CoreML)<br>
  : iOS project for fingertip estimation using CoreML.

