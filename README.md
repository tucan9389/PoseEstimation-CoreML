

# PoseEstimation-CoreML

This project is Pose Estimation on iOS with Core ML.<br>If you are interested in iOS + Machine Learning, visit [here](https://github.com/motlabs/iOS-Proejcts-with-ML-Models) you can see various DEMOs.<br>

![180705-poseestimation-demo.gif](https://github.com/tucan9389/PoseEstimation-CoreML/blob/master/resource/180801-poseestimation-demo.gif?raw=true)

[한국어 README](https://github.com/tucan9389/PoseEstimation-CoreML/blob/master/README_kr.md)

## Requirements

- Xcode 9.2+
- iOS 11.0+
- Swift 4.1

## Download model

Pose Estimation model for Core ML(`model_cpm.mlmodel`)<br>
☞ Download Core ML model [model_cpm.mlmodel](https://github.com/edvardHua/PoseEstimationForMobile/tree/master/release/cpm_model) or [hourglass.mlmodel](https://github.com/edvardHua/PoseEstimationForMobile/tree/master/release/hourglass_model).

> input_name_shape_dict = {"image:0":[1,224,224,3]} image_input_names=["image:0"] <br>output_feature_names = ['Convolutional_Pose_Machine/stage_5_out:0']
>
> －in [https://github.com/edvardHua/PoseEstimationForMobile](https://github.com/edvardHua/PoseEstimationForMobile)

|                            | cpm                                      | hourglass          |
| -------------------------- | ---------------------------------------- | ------------------ |
| Input shape                | `[1, 192, 192, 3]`                       | `[1, 192, 192, 3]` |
| Output shape               | `[1, 96, 96, 14]`                        | `[1, 48, 48, 14]`  |
| Input node name            | `image`                                  | `image`            |
| Output node name           | `Convolutional_Pose_Machine/stage_5_out` | `hourglass_out_3`  |
| Inference time on iPhone X | 57 mm                                    | 33 mm              |



## Preparing build

### Import the model

![모델 불러오기.png](https://github.com/tucan9389/MobileNetApp-CoreML/blob/master/resource/%EB%AA%A8%EB%8D%B8%20%EB%B6%88%EB%9F%AC%EC%98%A4%EA%B8%B0.png?raw=true)

Once you import the model, compiler generates model helper class on build path automatically. You can access the model through model helper class by creating an instance, not through build path.

## Code

(Ready to publish)
