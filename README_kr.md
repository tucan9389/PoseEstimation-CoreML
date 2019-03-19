

# PoseEstimation-CoreML

![platform-ios](https://img.shields.io/badge/platform-ios-lightgrey.svg)
![swift-version](https://img.shields.io/badge/swift-4.2-red.svg)
![lisence](https://img.shields.io/badge/license-MIT-black.svg)

여러가지 iOS+ML예제는 [iOS Projects with ML Models 저장소](https://github.com/motlabs/iOS-Proejcts-with-ML-Models)에 모아져있습니다.<br>
이 프로젝트는 Core ML을 사용하여 Pose Estimation을 실행시켜본 예제입니다. <br>

| Jointed Keypoints                                            | Concatenated heatmap                                         |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| ![poseestimation-demo-joint.gif](https://github.com/tucan9389/PoseEstimation-CoreML/blob/master/resource/180801-poseestimation-demo.gif?raw=true) | ![poseestimation-demo-heatmap.gif](https://github.com/tucan9389/PoseEstimation-CoreML/blob/master/resource/180914-poseestimation-demo.gif?raw=true) |

비디오 출처: [https://www.youtube.com/watch?v=EM16LBKBEgI](https://www.youtube.com/watch?v=EM16LBKBEgI)

## 요구환경

- Xcode 9.2+
- iOS 11.0+
- Swift 4

## 모델 준비

Core ML용 Pose Estimation 모델(`model_cpm.mlmodel`)<br>
> ~~☞ Core ML 모델을 여기서 다운받으세요([model_cpm.mlmodel](https://github.com/edvardHua/PoseEstimationForMobile/tree/master/release/cpm_model) 혹은 [hourglass.mlmodel](https://github.com/edvardHua/PoseEstimationForMobile/blob/master/release/hourglass_model/hourglass.mlmodel)).~~
> `DEPRECATED`

위 저장소는 닫혔습니다. 우선 아래 모델을 사용해주세요.
- [cpm](models/cpm_model)
- [hourglass](models/hourglass_model)

> input_name_shape_dict = {"image:0":[1,224,224,3]} image_input_names=["image:0"] <br>output_feature_names = ['Convolutional_Pose_Machine/stage_5_out:0']
>
> －in [https://github.com/edvardHua/PoseEstimationForMobile](https://github.com/edvardHua/PoseEstimationForMobile)

#### 메타정보

|                  | cpm                                      | hourglass          |
| ---------------- | ---------------------------------------- | ------------------ |
| Input shape      | `[1, 192, 192, 3]`                       | `[1, 192, 192, 3]` |
| Output shape     | `[1, 96, 96, 14]`                        | `[1, 48, 48, 14]`  |
| Input node name  | `image`                                  | `image`            |
| Output node name | `Convolutional_Pose_Machine/stage_5_out` | `hourglass_out_3`  |
| Model size       | 2.6 MB                                   | 2.0 MB             |

#### 추론시간

|           | cpm    | hourglass |
| --------- | ------ | --------- |
| iPhone X  | 51 ms  | 49 ms     |
| iPhone 8+ | 49 ms  | 46 ms     |
| iPhone 6+ | 200 ms | 180 ms    |

## 빌드 준비

### 모델 가져오기

![모델 불러오기.png](https://github.com/tucan9389/MobileNetApp-CoreML/blob/master/resource/%EB%AA%A8%EB%8D%B8%20%EB%B6%88%EB%9F%AC%EC%98%A4%EA%B8%B0.png?raw=true)

모델을 넣으셨으면 자동으로 모델 이름의 파일이 빌드경로 어딘가에 생성됩니다. 모델을 사용할때는 경로로 접근하는 것이 아니라 모델 클래스로 객체를 생성하여 접근할 수 있습니다.

## 코드 작성

#### 1. Vision 프레임크 불러오기

```swift
import Vision
```

#### 2. Core ML 프로퍼티 선언

```swift
typealias EstimationModel = model_cpm // model name(model_cpm) must be equal with mlmodel file name
var request: VNCoreMLRequest!
var visionModel: VNCoreMLModel!
```

#### 3. 모델 준비

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

#### 4. 추론 🏃‍♂️

```swift
// on the inference point
let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
try? handler.perform([request])
```

## Performance Test

### 모델 가져오기

You can download cpm or hourglass model for Core ML from [edvardHua/PoseEstimationForMobile](https://github.com/edvardHua/PoseEstimationForMobile) repo.

### 모델 이름 변경([`PoseEstimation_CoreMLTests.swift`](PoseEstimation-CoreMLTests/PoseEstimation_CoreMLTests.swift))

![fix-model-name-for-testing](/Users/canapio/Project/machine%20learning/MoT%20Labs/github_project/ml-ios-projects/PoseEstimation-CoreML/resource/fix-model-name-for-testing.png)

### 테스트 실행

단축키로는 `⌘ + U`를 누르거나  `Build for Testing` 아이콘을 누르세요.

![build-for-testing](/Users/canapio/Project/machine%20learning/MoT%20Labs/github_project/ml-ios-projects/PoseEstimation-CoreML/resource/build-for-testing.png)

## 함께 볼 것

- [motlabs/iOS-Proejcts-with-ML-Models](https://github.com/motlabs/iOS-Proejcts-with-ML-Models)<br>
  : TensorFlow로 만든 머신러닝 모델을 iOS에서 사용해보는 프로젝트 모음
- ~~[edvardHua/PoseEstimationForMobile](https://github.com/edvardHua/PoseEstimationForMobile)~~ -> `DEPRECATED` <br>
  : 모바일용 Pose Estination TensorFlow 프로젝트
- [tucan9389/FingertipEstimation-CoreML](https://github.com/tucan9389/FingertipEstimation-CoreML)<br>
  : [edvardHua/PoseEstimationForMobile](https://github.com/edvardHua/PoseEstimationForMobile)를 이용해 데이터셋만 Fingertip으로 바꾸어 학습시킨 모델을 CoreML에 맞춰 구현한 iOS 프로젝트
