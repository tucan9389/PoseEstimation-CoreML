//
//  HeatmapView.swift
//  FingerEstimation-CoreML
//
//  Created by GwakDoyoung on 13/07/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import UIKit
import CoreML

class DrawingHeatmapView: UIView {
    
    var heatmap3D: Array<Array<Double>>? = nil {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var heatmaps: MLMultiArray?
    var keypointNumber: Int?
    
    
    override func draw(_ rect: CGRect) {
        
        if let ctx = UIGraphicsGetCurrentContext() {
            
            ctx.clear(rect);
            
            if let heatmap = self.heatmap3D {
                let size = self.bounds.size
                let heatmap_w = heatmap.count
                let heatmap_h = heatmap.first?.count ?? 0
                let w = size.width / CGFloat(heatmap_w)
                let h = size.height / CGFloat(heatmap_h)
                
                for j in 0..<heatmap_w {
                    for i in 0..<heatmap_h {
                        let value = heatmap[i][j]
                        let alpha: CGFloat = CGFloat(value)
                        guard alpha > 0 else { continue; }
                        
                        let rect: CGRect = CGRect(x: CGFloat(i) * w, y: CGFloat(j) * h, width: w, height: h)
                        
                        let color: UIColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: alpha*0.58)
                        
                        let bpath: UIBezierPath = UIBezierPath(rect: rect)
                        
                        color.set()
                        bpath.stroke()
                        bpath.fill()
                    }
                }
            } else if let heatmaps = heatmaps, let keypointNumber = keypointNumber {
                let size = self.bounds.size
                
                let heatmap_w = heatmaps.shape[1].intValue
                let heatmap_h = heatmaps.shape[2].intValue
                
                let w = size.width / CGFloat(heatmap_w)
                let h = size.height / CGFloat(heatmap_h)
                
                for x in 0..<heatmap_w {
                    for y in 0..<heatmap_h {
                        let index = keypointNumber*(heatmap_w*heatmap_h) + y*(heatmap_h) + x
                        let alpha: CGFloat = CGFloat(heatmaps[index].doubleValue)
                        guard alpha > 0 else { continue }
                        
                        let rect: CGRect = CGRect(x: CGFloat(x) * w, y: CGFloat(y) * h, width: w, height: h)
                        
                        let color: UIColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: alpha*0.58)
                        
                        let bpath: UIBezierPath = UIBezierPath(rect: rect)
                        
                        color.set()
                        bpath.stroke()
                        bpath.fill()
                    }
                }
            } else {
                
            }
        }
    } // end of draw(rect:)
}
