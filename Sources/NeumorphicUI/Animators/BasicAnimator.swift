//
//  BasicAnimator.swift
//
//  Copyright © 2020 NeumorphicUI - Alberto Saltarelli
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

public class BasicAnimator: NeumorphicItemAnimator {
    public enum Timing {
        case curve(CAMediaTimingFunctionName)
        case spring(mass: CGFloat = 1, stiffness: CGFloat = 100, dampingRatio: CGFloat = 10, initialVelocity: CGFloat = 0)
        case controlPoint(controlPoint1: CGPoint, controlPoint2: CGPoint)
    }
    
    public var duration: TimeInterval
    public var delay: TimeInterval
    public var timing: Timing
    
    public var animation: NeumorphicItemAnimation {
        let animation: CABasicAnimation
        
        switch self.timing {
        case .curve(let name):
            animation = CABasicAnimation()
            animation.timingFunction = CAMediaTimingFunction(name: name)
        case let .spring(mass, stiffness, dampingRatio, initialVelocity):
            let springAnimation = CASpringAnimation()
            springAnimation.mass = mass
            springAnimation.stiffness = stiffness
            springAnimation.damping = dampingRatio
            springAnimation.initialVelocity = initialVelocity
            animation = springAnimation
        case let .controlPoint(controlPoint1, controlPoint2):
            animation = CABasicAnimation()
            animation.timingFunction = CAMediaTimingFunction(controlPoints: Float(controlPoint1.x), Float(controlPoint1.y), Float(controlPoint2.x), Float(controlPoint2.y))
        }
        
        animation.duration = duration
        animation.beginTime = CACurrentMediaTime() + delay
        
        return .basic(animation)
    }
    
    public init(duration: TimeInterval, delay: TimeInterval = 0, timing: Timing) {
        self.duration = duration
        self.delay = delay
        self.timing = timing
    }
}

public extension NeumorphicItem {
    @discardableResult func animate(duration: TimeInterval, delay: TimeInterval = 0, timing: BasicAnimator.Timing) -> Self {
        let animator = BasicAnimator(duration: duration, delay: delay, timing: timing)
        return self.animator(animator)
    }
}
