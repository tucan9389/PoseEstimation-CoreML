//
//  PoseView.swift
//  PoseEstimation-CoreML
//
//  Created by GwakDoyoung on 15/07/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import UIKit

class PoseView: UIView {

    var bodyPoints: [ViewController.BodyPoint?] = [] {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        if let ctx = UIGraphicsGetCurrentContext() {
            
            ctx.clear(rect);
            
            //            drawLine(ctx: ctx, from: CGPoint(x: 10, y: 20), to: CGPoint(x: 100, y: 20), color: UIColor.red.cgColor)
            //            drawLine(ctx: ctx, from: CGPoint(x: 110, y: 120), to: CGPoint(x: 200, y: 120), color: UIColor.blue.cgColor)
            let size = self.bounds.size
            
            let color = Constant.jointLineColor.cgColor
            if Constant.pointLabels.count == bodyPoints.count {
                let _ = Constant.connectingPointIndexs.map { pIndex1, pIndex2 in
                    if let bp1 = self.bodyPoints[pIndex1], bp1.confidence > 0.5,
                        let bp2 = self.bodyPoints[pIndex2], bp2.confidence > 0.5 {
                        let p1 = bp1.point
                        let p2 = bp2.point
                        let point1 = CGPoint(x: p1.x * size.width, y: p1.y*size.height)
                        let point2 = CGPoint(x: p2.x * size.width, y: p2.y*size.height)
                        drawLine(ctx: ctx, from: point1, to: point2, color: color)
                    }
                }
            }
        }
    }
    
    func drawLine(ctx: CGContext, from p1: CGPoint, to p2: CGPoint, color: CGColor) {
        ctx.setStrokeColor(color)
        ctx.setLineWidth(3.0)
        
        ctx.move(to: p1)
        ctx.addLine(to: p2)
        
        ctx.strokePath();
    }
}
