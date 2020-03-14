# PoseEstimation-CoreML

![platform-ios](https://img.shields.io/badge/platform-ios-lightgrey.svg)
![swift-version](https://img.shields.io/badge/swift-4.2-red.svg)
![lisence](https://img.shields.io/badge/license-MIT-black.svg)

This project is Pose Estimation on iOS with Core ML.<br>If you are interested in iOS + Machine Learning, visit [here](https://github.com/motlabs/iOS-Proejcts-with-ML-Models) you can see various DEMOs.<br>

[한국어 README](https://github.com/tucan9389/PoseEstimation-CoreML/blob/master/README_kr.md)

| Jointed Keypoints | Hatmaps | Still Image |
| :-----: | :-----: | :-----: |
| <img src="https://user-images.githubusercontent.com/37643248/69563016-acdf3400-0ff3-11ea-8cd0-12df4a86e104.gif" width=240px> | <img src="https://user-images.githubusercontent.com/37643248/69562897-77d2e180-0ff3-11ea-83a7-ee557111b633.gif" width=240px> | <img src="resource/190629-poseestimation-stillimage-demo.gif" width=240px>

Video source:
- [https://www.youtube.com/watch?v=EM16LBKBEgI](https://www.youtube.com/watch?v=EM16LBKBEgI)
-

| Pose Capturing | Pose Matching |
| :----: | :----: |
| <img src="resource/demo-pose-capturing.gif"> | <img src="resource/demo-pose-matching.gif"> |

## Features

- Estimate body pose on a image
- Inference with camera's pixel buffer on real-time
- Inference with a photo library's image
- Visualize as heatmaps
- Visualize as lines and points
- Pose capturing and pose matching

## How it works

![how_it_works](resource/how_it_works.png)

## Requirements

- Xcode 9.2+
- iOS 11.0+
- Swift 4

## Model

### Get PoseEstimationForMobile's model

Download this temporary models from [following link](models).
- [cpm](models/cpm_model)
- [hourglass](models/hourglass_model)

Or

☞ Download Core ML model [model_cpm.mlmodel](https://github.com/tucan9389/pose-estimation-for-mobile/tree/master/release/cpm_model) or [hourglass.mlmodel](https://github.com/tucan9389/pose-estimation-for-mobile/tree/master/release/hourglass_model).

> input_name_shape_dict = {"image:0":[1,192,192,3]} image_input_names=["image:0"] <br>output_feature_names = ['Convolutional_Pose_Machine/stage_5_out:0']
>
> －in [https://github.com/tucan9389/pose-estimation-for-mobile](https://github.com/tucan9389/pose-estimation-for-mobile)

### Model Size, Minimum iOS Version, Input/Output Shape

| Model | Size<br>(MB) | Minimum<br>iOS Version | Input Shape | Output Shape |
| ----: | :----: | :----: | :----: | :----: |
| cpm | 2.6 | iOS11 | `[1, 192, 192, 3]` | `[1, 96, 96, 14]` |
| hourhglass | 2 | iOS11 | `[1, 192, 192, 3]` | `[1, 48, 48, 14]` |

### Infernece Time (ms)

| Model vs. Device | 11<br>Pro | XS<br>Max | XR | X | 8 | 8+ | 7 | 7+ | 6S+ | 6+ |
| ----: | :----: | :----: | :----: | :----: | :----: | :----: | :----: | :----: | :----: | :----: |
| cpm | 5 | 27 | 27 | 32 | 31 | 31 | 39 | 37 | 44 | 115 |
| hourhglass | 3 | 6 | 7 | 29 | 31 | 32 | 37 | 42 | 48 | 94 |

![mobile-pose-estimation](https://user-images.githubusercontent.com/37643248/75271451-94bfc080-583f-11ea-946d-175d8e14e335.jpg)

### Total Time (ms)

| Model vs. Device | 11<br>Pro | XS<br>Max | XR | X | 8 | 8+ | 7 | 7+ | 6S+ | 6+ |
| ----: | :----: | :----: | :----: | :----: | :----: | :----: | :----: | :----: | :----: | :----: |
| cpm | 23 | 39 | 40 | 46 | 47 | 45 | 55 | 58 | 56 | 139 |
| hourhglass | 23 | 15 | 15 | 38 | 40 | 40 | 48 | 55 | 58 | 106 |

### FPS

| Model vs. Device | 11<br>Pro | XS<br>Max | XR | X | 8 | 8+ | 7 | 7+ | 6S+ | 6+ |
| ----: | :----: | :----: | :----: | :----: | :----: | :----: | :----: | :----: | :----: | :----: |
| cpm | 15 | 23 | 23 | 20 | 20 | 21 | 17 | 16 | 16 | 6 |
| hourhglass | 15 | 23 | 23 | 24 | 23 | 23 | 19 | 16 | 15 | 8 |

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

#### 3.1 Import Vision framework

```swift
import Vision
```

#### 3.2 Define properties for Core ML

```swift
// properties on ViewController
typealias EstimationModel = model_cpm // model name(model_cpm) must be equal with mlmodel file name
var request: VNCoreMLRequest!
var visionModel: VNCoreMLModel!
```

#### 3.3 Configure and prepare the model

```swift
override func viewDidLoad() {
    super.viewDidLoad()

    visionModel = try? VNCoreMLModel(for: EstimationModel().model)
	request = VNCoreMLRequest(model: visionModel, completionHandler: visionRequestDidComplete)
	request.imageCropAndScaleOption = .scaleFill
}

func visionRequestDidComplete(request: VNRequest, error: Error?) {
    /* ------------------------------------------------------ */
    /* something postprocessing what you want after inference */
    /* ------------------------------------------------------ */
}
```

#### 3.4 Inference 🏃‍♂️

```swift
// on the inference point
let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
try? handler.perform([request])
```

## Performance Test

### 1. Import the model

You can download cpm or hourglass model for Core ML from [tucan9389/pose-estimation-for-mobile](https://github.com/tucan9389/pose-estimation-for-mobile) repo.

### 2. Fix the model name on [`PoseEstimation_CoreMLTests.swift`](PoseEstimation-CoreMLTests/PoseEstimation_CoreMLTests.swift)

<img src="resource/fix-model-name-for-testing.png" width="660px">

### 3. Run the test

Hit the `⌘ + U` or click the `Build for Testing` icon.

<img src="resource/build-for-testing.png" width="320px">



## See also

- [motlabs/iOS-Proejcts-with-ML-Models](https://github.com/motlabs/iOS-Proejcts-with-ML-Models)<br>
  : The challenge using machine learning model created from tensorflow on iOS
- [tucan9389/PoseEstimation-TFLiteSwift](https://github.com/tucan9389/PoseEstimation-TFLiteSwift)<br>
  : The pose estimation with TensorFlowLiteSwift pod for iOS (Preparing...)
- [edvardHua/PoseEstimationForMobile](https://github.com/edvardHua/PoseEstimationForMobile)<br>
  : TensorFlow project for pose estimation for mobile
- [tucan9389/pose-estimation-for-mobile](https://github.com/tucan9389/pose-estimation-for-mobile)<br>
  : forked from edvardHua/PoseEstimationForMobile
- [tucan9389/FingertipEstimation-CoreML](https://github.com/tucan9389/FingertipEstimation-CoreML)<br>
  : iOS project for fingertip estimation using CoreML.
