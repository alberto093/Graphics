//
//  ShadowModifier.swift
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

/// A modifier that allows to shadow the view's content.
///
/// Shadow modifier supports both custom mask path and corner radius modifier. It doesn't support both at the same time.
public class ShadowModifier: GraphicsItemModifier {
    /// Constants that specify the shadow position.
    public enum Shadow {
        case outer
        case inner
    }
    
    /// The position of the shadow.
    public var shadow: Shadow
    
    /// The color of the layer’s shadow.
    public var color: UIColor
    
    /// The offset (in points) of the shadow.
    public var offset: CGSize
    
    /// The blur radius (in points) used to render the shadow.
    public var radius: CGFloat
    
    /// The opacity of the layer’s shadow.
    ///
    /// The value in this property must be in the range 0.0 (transparent) to 1.0 (opaque).
    public var opacity: Float
    
    public let allowsMultipleModifiers = true
    
    private weak var shadowLayer: CALayer?
    
    /// It creates a new shadow modifier.
    /// - Parameters:
    ///   - shadow: The position of the shadow.
    ///   - color: The color of the layer’s shadow.
    ///   - offset: The offset (in points) of the shadow.
    ///   - radius: The blur radius (in points) used to render the shadow.
    ///   - opacity: The opacity of the layer’s shadow.
    public init(shadow: ShadowModifier.Shadow, color: UIColor, offset: CGSize, radius: CGFloat, opacity: Float) {
        self.shadow = shadow
        self.color = color
        self.offset = offset
        self.radius = radius
        self.opacity = opacity
    }
    
    public func modify(_ view: GraphicsItem, roundedCorners: UIRectCorner, cornerRadii: CGSize) {
        view.contentView.clipsToBounds = true
        let layer = prepareShadowLayer(view: view)
        switch shadow {
        case .outer:
            view.clipsToBounds = false
            updateOuterShadow(layer: layer, roundedCorners: roundedCorners, cornerRadii: cornerRadii, in: view)
        case .inner:
            view.contentView.clipsToBounds = true
            updateInnerShadow(layer: layer, roundedCorners: roundedCorners, cornerRadii: cornerRadii, in: view)
        }
    }
    
    public func revert(_ view: GraphicsItem) {

    }
    
    public func purge() {
        shadowLayer?.removeFromSuperlayer()
    }
}

public extension GraphicsItem {
    /// Adds a shadow to this view.
    /// - Parameters:
    ///   - shadow: The position of the shadow.
    ///   - color: The shadow’s color.
    ///   - offset: The offset (in points) of the shadow.
    ///   - radius: The blur radius (in points) used to render the shadow.
    ///   - opacity: The opacity of the shadow.
    /// - Returns: It returns the callers in order to apply multiple modifiers using the dot notation.
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

public extension GraphicsItem where Self: UIControl {
    /// Adds a shadow to this view.
    /// - Parameters:
    ///   - shadow: The position of the shadow.
    ///   - color: The shadow’s color.
    ///   - offset: The offset (in points) of the shadow.
    ///   - radius: The blur radius (in points) used to render the shadow.
    ///   - opacity: The opacity of the shadow.
    ///   - state: The state that uses the specified modifier. The possible values are described in [UIControl.State](https://developer.apple.com/documentation/uikit/uicontrol/state).
    /// - Returns: It returns the callers in order to apply multiple modifiers using the dot notation.
    @discardableResult func shadow(
        _ shadow: ShadowModifier.Shadow = .outer,
        color: UIColor = .black,
        offset: CGSize = CGSize(width: 0, height: -3),
        radius: CGFloat = 3,
        opacity: Float = 1,
        state: State = .normal) -> Self {
        
        let modifier = ShadowModifier(shadow: shadow, color: color, offset: offset, radius: radius, opacity: opacity)
        return self.modifier(modifier, state: state)
    }
}

private extension ShadowModifier {
    @discardableResult func prepareShadowLayer(view: GraphicsItem) -> CALayer {
        let layer: CALayer
        if let shadowLayer = shadowLayer {
            layer = shadowLayer
        } else {
            layer = CALayer()
            switch shadow {
            case .outer:
                view.layer.insertSublayer(layer, at: 0)
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
    
    func updateOuterShadow(layer: CALayer, roundedCorners: UIRectCorner, cornerRadii: CGSize, in view: GraphicsItem) {
        if view.isBlurredBackground, let blurView = view.blurView {
            let pathRect = layer.bounds.insetBy(dx: -radius, dy: -radius)
            
            if let maskPath = (blurView.layer.mask as? CAShapeLayer)?.path {
                let path = UIBezierPath(cgPath: maskPath)
                let transform = CGAffineTransform(scaleX: pathRect.width / layer.bounds.width, y: pathRect.height / layer.bounds.height)
                    .concatenating(CGAffineTransform(translationX: -radius, y: -radius))
                path.apply(transform)
                let cutout = UIBezierPath(cgPath: maskPath).reversing()
                path.append(cutout)

                layer.shadowPath = path.cgPath
            } else {
                let path = UIBezierPath(roundedRect: pathRect, byRoundingCorners: roundedCorners, cornerRadii: cornerRadii)
                let hole = UIBezierPath(roundedRect: layer.bounds, byRoundingCorners: roundedCorners, cornerRadii: cornerRadii).reversing()
                path.append(hole)
                layer.shadowPath = path.cgPath
            }
        } else {
            if let maskPath = (view.contentView.layer.mask as? CAShapeLayer)?.path {
                layer.shadowPath = maskPath
            } else {
                layer.shadowPath = UIBezierPath(roundedRect: layer.bounds, byRoundingCorners: roundedCorners, cornerRadii: cornerRadii).cgPath
            }
        }
    }
    
    func updateInnerShadow(layer: CALayer, roundedCorners: UIRectCorner, cornerRadii: CGSize, in view: GraphicsItem) {
        let pathRect = layer.bounds.insetBy(dx: -layer.bounds.width, dy: -layer.bounds.height)
        
        if let maskPath = (view.contentView.layer.mask as? CAShapeLayer)?.path {
            let path = UIBezierPath(cgPath: maskPath)
            path.apply(CGAffineTransform(scaleX: pathRect.width / layer.bounds.width, y: pathRect.height / layer.bounds.height))
            let cutout = UIBezierPath(cgPath: maskPath).reversing()
            path.append(cutout)

            layer.shadowPath = path.cgPath
        } else {
            let path = UIBezierPath(roundedRect: pathRect, byRoundingCorners: roundedCorners, cornerRadii: cornerRadii)
            let cutout = UIBezierPath(roundedRect: layer.bounds, byRoundingCorners: roundedCorners, cornerRadii: cornerRadii).reversing()
            path.append(cutout)
            
            layer.shadowPath = path.cgPath
        }
    }
}
