//
//  HeatmapPostProcessor.swift
//  PoseEstimation-CoreML
//
//  Created by Doyoung Gwak on 27/06/2019.
//  Copyright © 2019 tucan9389. All rights reserved.
//

import Foundation
import CoreML

class HeatmapPostProcessor {
    
    //var maxvalue: Double = 0.5
    //var minvalue: Double = 0.5
    
    var onlyBust: Bool = false
    
    func convertToPredictedPoints(from heatmaps: MLMultiArray, isFlipped: Bool = false) -> [PredictedPoint?] {
        guard heatmaps.shape.count >= 3 else {
            print("heatmap's shape is invalid. \(heatmaps.shape)")
            return []
        }
        let total_keypoint_number = heatmaps.shape[0].intValue
        var keypoint_number = total_keypoint_number
        if onlyBust { keypoint_number = min(total_keypoint_number, 8/*the index of R hip*/) }
        let heatmap_w = heatmaps.shape[1].intValue
        let heatmap_h = heatmaps.shape[2].intValue
        
        var n_kpoints = (0..<total_keypoint_number).map { _ -> PredictedPoint? in
            return nil
        }
        
        for k in 0..<keypoint_number {
            for i in 0..<heatmap_w {
                for j in 0..<heatmap_h {
                    let index = k*(heatmap_w*heatmap_h) + i*(heatmap_h) + j
                    let confidence = heatmaps[index].doubleValue
                    //if maxvalue < confidence { maxvalue = confidence }
                    //if minvalue > confidence { minvalue = confidence }
                    guard confidence > 0 else { continue }
                    if n_kpoints[k] == nil ||
                        (n_kpoints[k] != nil && n_kpoints[k]!.maxConfidence < confidence) {
                        n_kpoints[k] = PredictedPoint(maxPoint: CGPoint(x: CGFloat(j), y: CGFloat(i)), maxConfidence: confidence)
                    }
                }
            }
        }
        
        //print(maxvalue, minvalue)
        
        // transpose to (1.0, 1.0)
        n_kpoints = n_kpoints.map { kpoint -> PredictedPoint? in
            if let kp = kpoint {
                var x: CGFloat = (kp.maxPoint.x+0.5)/CGFloat(heatmap_w)
                let y: CGFloat = (kp.maxPoint.y+0.5)/CGFloat(heatmap_h)
                if isFlipped { x = 1 - x }
                return PredictedPoint(maxPoint: CGPoint(x: x, y: y),
                                      maxConfidence: kp.maxConfidence)
            } else {
                return nil
            }
        }
        
        return n_kpoints
    }
    
    func convertTo3DArray(from heatmaps: MLMultiArray) -> Array<Array<Double>> {
        guard heatmaps.shape.count >= 3 else {
            print("heatmap's shape is invalid. \(heatmaps.shape)")
            return []
        }
        let keypoint_number = heatmaps.shape[0].intValue
        let heatmap_w = heatmaps.shape[1].intValue
        let heatmap_h = heatmaps.shape[2].intValue
        
        var convertedHeatmap: Array<Array<Double>> = Array(repeating: Array(repeating: 0.0, count: heatmap_h), count: heatmap_w)
        
        for k in 0..<keypoint_number {
            for i in 0..<heatmap_w {
                for j in 0..<heatmap_h {
                    let index = k*(heatmap_w*heatmap_h) + i*(heatmap_h) + j
                    let confidence = heatmaps[index].doubleValue
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
        
        return convertedHeatmap
    }
}
