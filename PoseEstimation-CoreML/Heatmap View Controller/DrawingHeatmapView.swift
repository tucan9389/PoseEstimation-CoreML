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
    
    override func draw(_ rect: CGRect) {
        
        if let ctx = UIGraphicsGetCurrentContext() {
            
            ctx.clear(rect);
            
            guard let heatmap = self.heatmap3D else { return }
            
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
        }
    } // end of draw(rect:)
}
