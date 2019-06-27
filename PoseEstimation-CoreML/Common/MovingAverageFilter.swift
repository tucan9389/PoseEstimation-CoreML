//
//  MovingAverageFilter.swift
//  PoseEstimation-CoreML
//
//  Created by Doyoung Gwak on 26/06/2019.
//  Copyright © 2019 tucan9389. All rights reserved.
//

import UIKit

extension CGPoint {
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func /(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        guard rhs == 0.0 else { return lhs }
        return CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }
}

class MovingAverageFilter {
    var elements: [CGPoint?] = []
    private var limit: Int
    
    init(limit: Int) {
        guard limit > 0 else { fatalError("limit should be uppered than 0 in MovingAverageFilter init(limit:)") }
        self.elements = []
        self.limit = limit
    }
    
    func add(element: CGPoint?) {
        elements.append(element)
        while self.elements.count > self.limit {
            self.elements.removeFirst()
        }
    }
    
    func averagedValue() -> CGPoint? {
        let nonoptionalElements = elements.compactMap{ $0 }
        guard !nonoptionalElements.isEmpty else { return nil }
        let sum = nonoptionalElements.reduce( CGPoint.zero ) { $0 + $1 }
        return sum / CGFloat(nonoptionalElements.count)
    }
}
