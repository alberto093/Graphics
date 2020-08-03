//
//  PropertyAnimator.swift
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

public class PropertyAnimator: NeumorphicItemAnimator {
    public enum Timing {
        case curve(UIView.AnimationCurve)
        case spring(dampingRatio: CGFloat)
        case controlPoint(p1: CGPoint, p2: CGPoint)
        case timingParameters(UITimingCurveProvider)
    }
    
    public let duration: TimeInterval
    public let timing: Timing
    public var delay: TimeInterval
    
    private lazy var animator: UIViewPropertyAnimator = {
        switch timing {
        case .curve(let curve):
            return UIViewPropertyAnimator(duration: duration, curve: curve)
        case .spring(let dampingRatio):
            return UIViewPropertyAnimator(duration: duration, dampingRatio: dampingRatio)
        case let .controlPoint(controlPoint1, controlPoint2):
            return UIViewPropertyAnimator(duration: duration, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        case .timingParameters(let provider):
            return UIViewPropertyAnimator(duration: duration, timingParameters: provider)
        }
    }()
    
    public var animation: NeumorphicItemAnimation {
        .animator(animator, delay: delay)
    }
    
    public init(duration: TimeInterval, delay: TimeInterval = 0, timing: Timing) {
        self.duration = duration
        self.delay = delay
        self.timing = timing
    }
    
    deinit {
        animator.stopAnimation(true)
    }
}

public extension NeumorphicItem {
    @discardableResult func animate(duration: TimeInterval, delay: TimeInterval = 0, timing: PropertyAnimator.Timing) -> Self {
        let animator = PropertyAnimator(duration: duration, timing: timing)
        return self.animator(animator)
    }
}