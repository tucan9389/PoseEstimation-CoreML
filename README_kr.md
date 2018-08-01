

# PoseEstimation-CoreML

여러가지 iOS+ML예제는 [iOS Projects with ML Models 저장소](https://github.com/motlabs/iOS-Proejcts-with-ML-Models)에 모아져있습니다.<br>
이 프로젝트는 Core ML을 사용하여 Pose Estimation을 실행시켜본 예제입니다. <br>
![180705-poseestimation-demo.gif](https://github.com/tucan9389/PoseEstimation-CoreML/blob/master/resource/180801-poseestimation-demo.gif?raw=true)

## 요구환경

- Xcode 9.2+
- iOS 11.0+
- Swift 4.1

## 모델 준비

Core ML용 Pose Estimation 모델(`model_cpm.mlmodel`)<br>
☞ Download Core ML model [model_cpm.mlmodel](https://github.com/edvardHua/PoseEstimationForMobile/tree/master/release/cpm_model) or [hourglass.mlmodel](https://github.com/edvardHua/PoseEstimationForMobile/blob/master/release/hourglass_model/hourglass.mlmodel).

> input_name_shape_dict = {"image:0":[1,224,224,3]} image_input_names=["image:0"] <br>output_feature_names = ['Convolutional_Pose_Machine/stage_5_out:0']
>
> －in [https://github.com/edvardHua/PoseEstimationForMobile](https://github.com/edvardHua/PoseEstimationForMobile)

|                          | cpm                                      | hourglass          |
| ------------------------ | ---------------------------------------- | ------------------ |
| Input shape              | `[1, 192, 192, 3]`                       | `[1, 192, 192, 3]` |
| Output shape             | `[1, 96, 96, 14]`                        | `[1, 48, 48, 14]`  |
| Input node name          | `image`                                  | `image`            |
| Output node name         | `Convolutional_Pose_Machine/stage_5_out` | `hourglass_out_3`  |
| Inference time(iPhone X) | 57 mm                                    | 33 mm              |



## 빌드 준비

### 모델 가져오기

![모델 불러오기.png](https://github.com/tucan9389/MobileNetApp-CoreML/blob/master/resource/%EB%AA%A8%EB%8D%B8%20%EB%B6%88%EB%9F%AC%EC%98%A4%EA%B8%B0.png?raw=true)

모델을 넣으셨으면 자동으로 모델 이름의 파일이 빌드경로 어딘가에 생성됩니다. 모델을 사용할때는 경로로 접근하는 것이 아니라 모델 클래스로 객체를 생성하여 접근할 수 있습니다.

## 코드 작성

(준비중)
