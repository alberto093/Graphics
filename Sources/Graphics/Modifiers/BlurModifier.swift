//
//  BlurModifier.swift
//
//  Copyright © 2020 Graphics - Alberto Saltarelli
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

#warning("Add vibracy support")
public class BlurModifier: GraphicsItemModifier {
    public let blurStyle: UIBlurEffect.Style
    public let blurIntensity: CGFloat
    public let allowsMultipleModifiers = true
    
    private weak var blurEffectView: UIVisualEffectView?
    private var intensityAnimator: UIViewPropertyAnimator? {
        didSet {
            oldValue?.stopAnimation(true)
        }
    }
    
    public init(blurStyle: UIBlurEffect.Style, blurIntensity: CGFloat = 1) {
        self.blurStyle = blurStyle
        self.blurIntensity = blurIntensity
    }
    
    public func modify(_ view: GraphicsItem, roundedCorners: UIRectCorner, cornerRadii: CGSize) {
        let blurView = prepareBlurEffectView(in: view)
        let effect = UIBlurEffect(style: blurStyle)
        
        if let mask = view.contentView.layer.mask {
            blurView.layoutIfNeeded()
            blurView.layer.mask = mask
        } else {
            blurView.layer.cornerRadius = cornerRadii.width
            blurView.layer.maskedCorners = roundedCorners.cornerMask
        }
        
        intensityAnimator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [weak blurEffectView] in blurEffectView?.effect = effect }
        intensityAnimator?.fractionComplete = blurIntensity
    }
    
    public func revert(_ view: GraphicsItem) {
        guard let contentView = blurEffectView?.contentView.subviews.first else { return }
        view.addSubview(contentView)
    }
    
    public func purge() {
        intensityAnimator = nil
        blurEffectView?.removeFromSuperview()
    }
    
    private func prepareBlurEffectView(in view: GraphicsItem) -> UIVisualEffectView {
        let blurView: UIVisualEffectView
        
        if let blurEffectView = blurEffectView {
            blurView = blurEffectView
        } else {
            blurView = UIVisualEffectView()
            blurView.clipsToBounds = true
            blurView.contentView.addSubview(view.contentView)
            view.insertSubview(blurView, at: 0)
            blurView.fill(view: view, insets: .zero, useSafeArea: false)
            self.blurEffectView = blurView
        }
        
        blurView.frame = view.bounds
        
        return blurView
    }
}

public extension GraphicsItem {
    @discardableResult func blur(style: UIBlurEffect.Style, intensity: CGFloat = 1) -> Self {
        let modifier = BlurModifier(blurStyle: style, blurIntensity: intensity)
        return self.modifier(modifier)
    }
}

public extension GraphicsItem where Self: UIControl {
    @discardableResult func blur(style: UIBlurEffect.Style, intensity: CGFloat = 1, state: State = .normal) -> Self {
        
        let modifier = BlurModifier(blurStyle: style, blurIntensity: intensity)
        return self.modifier(modifier, state: state)
    }
}

public extension UIRectCorner {
    var cornerMask: CACornerMask {
        var cornerMask = CACornerMask()
        
        if contains(.topLeft) {
            cornerMask.insert(.layerMinXMinYCorner)
        }
        
        if contains(.bottomLeft) {
            cornerMask.insert(.layerMinXMaxYCorner)
        }
        
        if contains(.bottomRight) {
            cornerMask.insert(.layerMaxXMaxYCorner)
        }
        
        if contains(.topRight) {
            cornerMask.insert(.layerMaxXMinYCorner)
        }
        
        return cornerMask
    }
}
