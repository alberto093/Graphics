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

#warning("Add animation to non animatable properties like layer.path, layer.frame in BorderModifier, ShadowModifier")
/*
 override func layoutSubviews() {
     super.layoutSubviews()

     if let animation = layer.animation(forKey: "position") {
         CATransaction.begin()
         CATransaction.setAnimationDuration(animation.duration)
         CATransaction.setAnimationTimingFunction(animation.timingFunction)

         let frameAnimation = CABasicAnimation(keyPath: "frame")
         topGradient.add(frameAnimation, forKey: "frame")
         leftGradient.add(frameAnimation, forKey: "frame")
         rightGradient.add(frameAnimation, forKey: "frame")
         bottomGradient.add(frameAnimation, forKey: "frame")

         let pathAnimation = CABasicAnimation(keyPath: "path")
         topGradient.mask?.add(pathAnimation, forKey: "path")
         leftGradient.mask?.add(pathAnimation, forKey: "path")
         rightGradient.mask?.add(pathAnimation, forKey: "path")
         bottomGradient.mask?.add(pathAnimation, forKey: "path")

         layoutGradients()
         CATransaction.commit()
     } else {
         layoutGradients()
     }
 }
 */

public class PropertyAnimator: NeumorphicItemAnimator {
    public enum Animation {
        case curve(UIView.AnimationCurve)
        case spring(dampingRatio: CGFloat)
        case controlPoint(p1: CGPoint, p2: CGPoint)
        case timingParameters(UITimingCurveProvider)
    }
    
    public var duration: TimeInterval
    public var delay: TimeInterval
    public var animation: Animation
    
    private lazy var animator: UIViewPropertyAnimator = {
        switch animation {
        case .curve(let curve):
            return UIViewPropertyAnimator(duration: duration, curve: curve)
        case .spring(let dampingRatio):
            return UIViewPropertyAnimator(duration: duration, dampingRatio: dampingRatio)
        case .controlPoint(let p1, let p2):
            return UIViewPropertyAnimator(duration: duration, controlPoint1: p1, controlPoint2: p2)
        case .timingParameters(let provider):
            return UIViewPropertyAnimator(duration: duration, timingParameters: provider)
        }
    }()
    
    public init(duration: TimeInterval, delay: TimeInterval = 0, animation: Animation) {
        self.duration = duration
        self.delay = delay
        self.animation = animation
    }
    
    deinit {
        animator.stopAnimation(true)
    }
    
    public func animate(animations: @escaping () -> Void, completion: @escaping () -> Void) {
        animator.addAnimations(animations)
        animator.startAnimation(afterDelay: delay)
        animator.addCompletion { _ in completion() }
    }
}

public extension NeumorphicItem {
    @discardableResult func animate(duration: TimeInterval, delay: TimeInterval = 0, animation: PropertyAnimator.Animation) -> Self {
        let animator = PropertyAnimator(duration: duration, animation: animation)
        return self.animator(animator)
    }
}
