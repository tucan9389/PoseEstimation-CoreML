//
//  MLMultiArray+Heatmap.swift
//  PoseEstimation-CoreML
//
//  Created by GwakDoyoung on 31/01/2019.
//  Copyright © 2019 tucan9389. All rights reserved.
//

import CoreML

struct BodyPoint {
    let maxPoint: CGPoint
    let maxConfidence: Double
}

extension MLMultiArray {
    func convertHeatmapToBodyPoint() -> [BodyPoint?] {
        guard self.shape.count >= 3 else {
            print("heatmap's shape is invalid. \(self.shape)")
            return []
        }
        let keypoint_number = self.shape[0].intValue
        let heatmap_w = self.shape[1].intValue
        let heatmap_h = self.shape[2].intValue
        
        var n_kpoints = (0..<keypoint_number).map { _ -> BodyPoint? in
            return nil
        }
        
        for k in 0..<keypoint_number {
            for i in 0..<heatmap_w {
                for j in 0..<heatmap_h {
                    let index = k*(heatmap_w*heatmap_h) + i*(heatmap_h) + j
                    let confidence = self[index].doubleValue
                    guard confidence > 0 else { continue }
                    if n_kpoints[k] == nil ||
                        (n_kpoints[k] != nil && n_kpoints[k]!.maxConfidence < confidence) {
                        n_kpoints[k] = BodyPoint(maxPoint: CGPoint(x: CGFloat(j), y: CGFloat(i)), maxConfidence: confidence)
                    }
                }
            }
        }
        
        
        // transpose to (1.0, 1.0)
        n_kpoints = n_kpoints.map { kpoint -> BodyPoint? in
            if let kp = kpoint {
                return BodyPoint(maxPoint: CGPoint(x: (kp.maxPoint.x+0.5)/CGFloat(heatmap_w),
                                                   y: (kp.maxPoint.y+0.5)/CGFloat(heatmap_h)),
                                 maxConfidence: kp.maxConfidence)
            } else {
                return nil
            }
        }
        
        return n_kpoints
    }
    
    func convertHeatmapTo3DArray() -> Array<Array<Double>> {
        guard self.shape.count >= 3 else {
            print("heatmap's shape is invalid. \(self.shape)")
            return []
        }
        let keypoint_number = self.shape[0].intValue
        let heatmap_w = self.shape[1].intValue
        let heatmap_h = self.shape[2].intValue
        
        var convertedHeatmap: Array<Array<Double>> = Array(repeating: Array(repeating: 0.0, count: heatmap_h), count: heatmap_w)
        
        for k in 0..<keypoint_number {
            for i in 0..<heatmap_w {
                for j in 0..<heatmap_h {
                    let index = k*(heatmap_w*heatmap_h) + i*(heatmap_h) + j
                    let confidence = self[index].doubleValue
                    guard confidence > 0 else { continue }
                    convertedHeatmap[j][i] += confidence
                }
            }
        }
        
        convertedHeatmap = convertedHeatmap.map { row in
            return row.map { element in
                if element > 1.0 {
                    return 1.0
                } else if element < 0 {
                    return 0.0
                } else {
                    return element
                }
            }
        }
        
//        if let max = (convertedHeatmap.map({ $0.max() }).compactMap({ $0 })).max(), max < 1.0 {
//            convertedHeatmap = convertedHeatmap.map { row in
//                return row.map { element in
//                    return element/max
//                }
//            }
//        }
        
        return convertedHeatmap
    }
}
