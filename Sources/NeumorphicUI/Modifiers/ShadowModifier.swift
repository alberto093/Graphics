//
//  ShadowModifier.swift
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

public class ShadowModifier: NeumorphicItemModifier {
    #warning("Fix implementation")
    public var modifiedLayer: CALayer?
    public var allowsMultipleModifier: Bool = true
    
    public enum Shadow {
        case outer
        case inner
    }
    
    public var shadow: Shadow
    public var color: UIColor
    public var offset: CGSize
    public var radius: CGFloat
    public var opacity: Float
    
    private weak var shadowLayer: CALayer?
    
    public init(shadow: ShadowModifier.Shadow, color: UIColor, offset: CGSize, radius: CGFloat, opacity: Float) {
        self.shadow = shadow
        self.color = color
        self.offset = offset
        self.radius = radius
        self.opacity = opacity
    }
    
    public func modify(_ view: NeumorphicItem, roundedCorners: UIRectCorner, cornerRadii: CGSize, animation: NeumorphicItemAnimation?) {
        #warning("Add animation")
        let layer = prepareShadowLayer(view: view)
        switch shadow {
        case .outer:
            view.clipsToBounds = false
            updateOuterShadow(layer: layer, roundedCorners: roundedCorners, cornerRadii: cornerRadii, maskLayer: view.contentView.layer.mask)
        case .inner:
            view.contentView.clipsToBounds = true
            updateInnerShadow(layer: layer, roundedCorners: roundedCorners, cornerRadii: cornerRadii, maskLayer: view.contentView.layer.mask)
        }
    }
    
    public func revert(_ view: NeumorphicItem, animation: NeumorphicItemAnimation?) {
        guard let shadowLayer = shadowLayer else { return }
        
        switch animation {
        case .none:
            shadowLayer.shadowOpacity = 0
        case .basic(let animation):
            shadowLayer.shadowOpacity = 0
            animation.keyPath = #keyPath(CALayer.shadowOpacity)
            animation.toValue = 0
            shadowLayer.add(animation, forKey: nil)
        case let .animator(animator, delay):
            animator.addAnimations {
                shadowLayer.shadowOpacity = 0
            }
            animator.startAnimation(afterDelay: delay)
        }
    }
    
    public func purge() {
        shadowLayer?.removeFromSuperlayer()
    }
}

public extension NeumorphicItem {
    @discardableResult func shadow(
        _ shadow: ShadowModifier.Shadow = .outer,
        color: UIColor = .black,
        offset: CGSize = CGSize(width: 0, height: -3),
        radius: CGFloat = 3,
        opacity: Float = 1) -> Self {
        
        let modifier = ShadowModifier(shadow: shadow, color: color, offset: offset, radius: radius, opacity: opacity)
        return self.modifier(modifier)
    }
}

public extension NeumorphicItem where Self: UIControl {
    @discardableResult func shadow(
        _ shadow: ShadowModifier.Shadow = .outer,
        color: UIColor = .black,
        offset: CGSize = CGSize(width: 0, height: -3),
        radius: CGFloat = 3,
        opacity: Float = 1,
        state: UIControl.State = .normal) -> Self {
        
        let modifier = ShadowModifier(shadow: shadow, color: color, offset: offset, radius: radius, opacity: opacity)
        return self.modifier(modifier, state: state)
    }
}

private extension ShadowModifier {
    @discardableResult func prepareShadowLayer(view: NeumorphicItem) -> CALayer {
        let layer: CALayer
        if let shadowLayer = shadowLayer {
            layer = shadowLayer
        } else {
            layer = CALayer()
            switch shadow {
            case .outer:
                view.layer.insertSublayer(layer, below: view.contentView.layer)
            case .inner:
                if let contentSubview = view.contentView.subviews.first {
                    view.contentView.layer.insertSublayer(layer, below: contentSubview.layer)
                } else {
                    view.contentView.layer.addSublayer(layer)
                }
            }

            self.shadowLayer = layer
        }
        
        layer.frame = view.bounds
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        return layer
    }
    
    func updateOuterShadow(layer: CALayer, roundedCorners: UIRectCorner, cornerRadii: CGSize, maskLayer: CALayer? = nil) {
        if let maskPath = (maskLayer as? CAShapeLayer)?.path {
            layer.shadowPath = maskPath
        } else {
            layer.shadowPath = UIBezierPath(roundedRect: layer.bounds, byRoundingCorners: roundedCorners, cornerRadii: cornerRadii).cgPath
        }
    }
    
    func updateInnerShadow(layer: CALayer, roundedCorners: UIRectCorner, cornerRadii: CGSize, maskLayer: CALayer? = nil) {
        #warning("Add custom mask path implementation")
        let insets = UIEdgeInsets(top: -layer.bounds.height, left: -layer.bounds.width, bottom: -layer.bounds.height, right: -layer.bounds.width)
        let path = UIBezierPath(roundedRect: layer.bounds.inset(by: insets), byRoundingCorners: roundedCorners, cornerRadii: cornerRadii)
        let cutout = UIBezierPath(roundedRect: layer.bounds, byRoundingCorners: roundedCorners, cornerRadii: cornerRadii).reversing()
        path.append(cutout)
        
        layer.shadowPath = path.cgPath
    }
}
