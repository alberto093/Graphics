//
//  BlurModifier.swift
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

#warning("Resolve cornerRadius clipsToBounds")
public class BlurModifier<Item: NeumorphicItem, SubView: UIView>: NeumorphicItemModifier {
    
    public let subviewKeyPath: KeyPath<Item, SubView>
    public let blurViewIndex: Int
    public let blurStyle: UIBlurEffect.Style
    public let blurIntensity: CGFloat
    public let allowsMultipleModifiers = true
    
    private weak var blurEffectView: UIVisualEffectView?
    private var intensityAnimator: UIViewPropertyAnimator? {
        didSet {
            oldValue?.stopAnimation(true)
        }
    }
    
    public init(subviewKeyPath: KeyPath<Item, SubView>, blurViewIndex: Int = 0, blurStyle: UIBlurEffect.Style, blurIntensity: CGFloat = 1) {
        self.subviewKeyPath = subviewKeyPath
        self.blurViewIndex = blurViewIndex
        self.blurStyle = blurStyle
        self.blurIntensity = blurIntensity
    }
    
    public func modify(_ view: NeumorphicItem, roundedCorners: UIRectCorner, cornerRadii: CGSize) {
        guard let view = view as? Item else { return }
        let blurView = prepareBlurEffectView(in: view)
        let effect = UIBlurEffect(style: blurStyle)
        
        if let mask = (view.contentView.layer.mask as? CAShapeLayer) {
            blurView.layoutIfNeeded()
            blurView.layer.mask = mask
        } else {
            blurView.layer.cornerRadius = cornerRadii.width
            blurView.layer.maskedCorners = roundedCorners.cornerMask
        }
        
        intensityAnimator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [weak blurEffectView] in blurEffectView?.effect = effect }
        intensityAnimator?.fractionComplete = blurIntensity
    }
    
    public func revert(_ view: NeumorphicItem) {
        
    }
    
    public func purge() {
        intensityAnimator = nil
        blurEffectView?.removeFromSuperview()
    }
    
    private func prepareBlurEffectView(in view: Item) -> UIVisualEffectView {
        let blurView: UIVisualEffectView
        
        if let blurEffectView = blurEffectView {
            blurView = blurEffectView
        } else {
            blurView = UIVisualEffectView()
            blurView.clipsToBounds = true
            view[keyPath: subviewKeyPath].insertSubview(blurView, at: blurViewIndex)
            self.blurEffectView = blurView
        }
        
        let subviewFrame = view[keyPath: subviewKeyPath].frame
        blurView.frame = view[keyPath: subviewKeyPath].bounds.insetBy(dx: -subviewFrame.width, dy: -subviewFrame.height)
        
        return blurView
    }
}

public extension NeumorphicItem {
    @discardableResult func blur(
        subviewBlurIndex: Int = 0,
        style: UIBlurEffect.Style,
        intensity: CGFloat = 1) -> Self {
        
        blur(\.contentView, subviewBlurIndex: subviewBlurIndex, style: style, intensity: intensity)
    }
    
    @discardableResult func blur<SubView: UIView>(
        _ subview: KeyPath<Self, SubView>,
        subviewBlurIndex: Int = 0,
        style: UIBlurEffect.Style,
        intensity: CGFloat = 1) -> Self {
        
        let modifier = BlurModifier(subviewKeyPath: subview, blurViewIndex: subviewBlurIndex, blurStyle: style, blurIntensity: intensity)
        return self.modifier(modifier)
    }
}

public extension NeumorphicItem where Self: UIControl {
    @discardableResult func blur(
        subviewBlurIndex: Int = 0,
        style: UIBlurEffect.Style,
        intensity: CGFloat = 1,
        state: State = .normal) -> Self {
        
        blur(\.contentView, subviewBlurIndex: subviewBlurIndex, style: style, intensity: intensity, state: state)
    }
    
    @discardableResult func blur<SubView: UIView>(
        _ subview: KeyPath<Self, SubView>,
        subviewBlurIndex: Int = 0,
        style: UIBlurEffect.Style,
        intensity: CGFloat = 1,
        state: State = .normal) -> Self {
        
        let modifier = BlurModifier(subviewKeyPath: subview, blurViewIndex: subviewBlurIndex, blurStyle: style, blurIntensity: intensity)
        return self.modifier(modifier, state: state)
    }
}
