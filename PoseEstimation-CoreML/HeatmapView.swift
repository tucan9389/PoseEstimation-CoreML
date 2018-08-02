//
//  HeatmapView.swift
//  FingerEstimation-CoreML
//
//  Created by GwakDoyoung on 13/07/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import UIKit
import CoreML

class HeatmapView: UIView {
    
    var heatmap: MLMultiArray? = nil {
        didSet {
            if let heatmap = heatmap {
                self.convertedHeatmap = convert(with: heatmap)
            }
            self.setNeedsDisplay()
        }
    }
    var convertedHeatmap: Array<Array<Double>> = []
    
    private func convert(with heatmap: MLMultiArray) -> Array<Array<Double>> {
        guard heatmap.shape.count >= 3 else {
            print("heatmap's shape is invalid. \(heatmap.shape)")
            return []
        }
        let keypoint_number = heatmap.shape[0].intValue
        let heatmap_w = heatmap.shape[1].intValue
        let heatmap_h = heatmap.shape[2].intValue
        
        var convertedHeatmap: Array<Array<Double>> = Array(repeating: Array(repeating: 0.0, count: heatmap_h), count: heatmap_w)
        
        for k in 0..<keypoint_number {
            for i in 0..<heatmap_w {
                for j in 0..<heatmap_h {
                    let index = k*(heatmap_w*heatmap_h) + i*(heatmap_h) + j
                    let confidence = heatmap[index].doubleValue
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
        
        if let max = (convertedHeatmap.map({ $0.max() }).compactMap({ $0 })).max(), max < 1.0 {
            convertedHeatmap = convertedHeatmap.map { row in
                return row.map { element in
                    return element/max
                }
            }
        }

        
        return convertedHeatmap
    }
    
    override func draw(_ rect: CGRect) {
        
        if let ctx = UIGraphicsGetCurrentContext() {
            
            ctx.clear(rect);
            
            let size = self.bounds.size
            let heatmap_w = convertedHeatmap.count
            let heatmap_h = convertedHeatmap.first?.count ?? 0
            let w = size.width / CGFloat(heatmap_w)
            let h = size.height / CGFloat(heatmap_h)
            
            for j in 0..<heatmap_w {
                for i in 0..<heatmap_h {
                    let value = convertedHeatmap[i][j]
                    let alpha: CGFloat = CGFloat(value)
                    guard alpha > 0 else { continue; }
                    
                    let rect: CGRect = CGRect(x: CGFloat(i) * w, y: CGFloat(j) * h, width: w, height: h)
                    
                    let color: UIColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: alpha)
                    
                    let bpath: UIBezierPath = UIBezierPath(rect: rect)
                    
                    color.set()
                    bpath.stroke()
                }
            }
            
        }
    }
}
