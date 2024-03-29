//
//  CornerRadiusModifier.swift
//
//  Copyright © 2021 Graphics - Alberto Saltarelli
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

/// A modifier that allows to clips a view to its bounding frame.
public class CornerRadiusModifier: GraphicsItemRoundingModifier {
    /// Constants that specify the corner radius.
    public enum Radius {
        case circle
        case equalTo(CGFloat)
    }
    
    /// Defines which of the four corners receives the masking. Defaults to all four corners.
    public var mask: CACornerMask
    
    /// The radius to use when drawing rounded corners for the layer’s background.
    public var radius: Radius
    
    public let priority: GraphicsItemModifierPriority = .required
    public let allowsMultipleModifiers = false
    
    public var roundedCorners: UIRectCorner {
        mask.rectCorners
    }
    
    /// It creates a new corner radius modifier.
    /// - Parameters:
    ///   - mask: Defines which of the four corners receives the masking. Defaults to all four corners.
    ///   - radius: The radius to use when drawing rounded corners for the layer’s background.
    public init(mask: CACornerMask, radius: Radius) {
        self.mask = mask
        self.radius = radius
    }
    
    public func cornerRadii(in view: GraphicsItem) -> CGSize {
        let cornerRadius = self.cornerRadius(in: view)
        return CGSize(width: cornerRadius, height: cornerRadius)
    }
    
    public func modify(_ view: GraphicsItem) {
        view.contentView.clipsToBounds = true
        view.contentView.layer.maskedCorners = mask
        view.contentView.layer.cornerRadius = cornerRadius(in: view)
    }
    
    public func revert(_ view: GraphicsItem) {
        view.contentView.layer.maskedCorners = .all
        view.contentView.layer.cornerRadius = 0
    }

    private func cornerRadius(in view: GraphicsItem) -> CGFloat {
        switch radius {
        case .circle:
            return min(view.contentView.bounds.width, view.contentView.bounds.height) / 2
        case .equalTo(let radius):
            return radius
        }
    }
}

extension CACornerMask {
    public static let all: CACornerMask = [
        .layerMinXMinYCorner,
        .layerMaxXMinYCorner,
        .layerMinXMaxYCorner,
        .layerMaxXMaxYCorner
    ]
    
    var rectCorners: UIRectCorner {
        var cornerMask = UIRectCorner()
        
        if contains(.layerMinXMinYCorner) {
            cornerMask.insert(.topLeft)
        }
        
        if contains(.layerMinXMaxYCorner) {
            cornerMask.insert(.bottomLeft)
        }
        
        if contains(.layerMaxXMaxYCorner) {
            cornerMask.insert(.bottomRight)
        }
        
        if contains(.layerMaxXMinYCorner) {
            cornerMask.insert(.topRight)
        }
        
        return cornerMask
    }
}

public extension GraphicsItem {
    /// Clips this view to its bounding frame, with the specified corner radius.
    /// - Parameters:
    ///   - mask: Defines which of the four corners receives the masking. Defaults to all four corners.
    ///   - radius: The radius to use when drawing rounded corners for the layer’s background.
    /// - Returns: It returns the callers in order to apply multiple modifiers using the dot notation.
    @discardableResult func cornerRadius(mask: CACornerMask = .all, radius: CornerRadiusModifier.Radius) -> Self {
        let modifier = CornerRadiusModifier(mask: mask, radius: radius)
        return self.modifier(modifier)
    }
    
    /// Clips this view to its bounding frame, with the specified corner radius.
    /// - Parameters:
    ///   - mask: Defines which of the four corners receives the masking. Defaults to all four corners.
    ///   - radius: The radius to use when drawing rounded corners for the layer’s background.
    /// - Returns: It returns the callers in order to apply multiple modifiers using the dot notation.
    @discardableResult func cornerRadius(mask: CACornerMask = .all, radius: CGFloat) -> Self {
        let modifier = CornerRadiusModifier(mask: mask, radius: .equalTo(radius))
        return self.modifier(modifier)
    }
}

public extension GraphicsItem where Self: UIControl {
    /// Clips this view to its bounding frame, with the specified corner radius.
    /// - Parameters:
    ///   - mask: Defines which of the four corners receives the masking. Defaults to all four corners.
    ///   - radius: The radius to use when drawing rounded corners for the layer’s background.
    ///   - state: The state that uses the specified modifier. The possible values are described in [UIControl.State](https://developer.apple.com/documentation/uikit/uicontrol/state).
    /// - Returns: It returns the callers in order to apply multiple modifiers using the dot notation.
    @discardableResult func cornerRadius(mask: CACornerMask = .all, radius: CornerRadiusModifier.Radius, state: State = .normal) -> Self {
        let modifier = CornerRadiusModifier(mask: mask, radius: radius)
        return self.modifier(modifier, state: state)
    }
    
    /// Clips this view to its bounding frame, with the specified corner radius.
    /// - Parameters:
    ///   - mask: Defines which of the four corners receives the masking. Defaults to all four corners.
    ///   - radius: The radius to use when drawing rounded corners for the layer’s background.
    ///   - state: The state that uses the specified modifier. The possible values are described in [UIControl.State](https://developer.apple.com/documentation/uikit/uicontrol/state).
    /// - Returns: It returns the callers in order to apply multiple modifiers using the dot notation.
    @discardableResult func cornerRadius(mask: CACornerMask = .all, radius: CGFloat, state: State = .normal) -> Self {
        let modifier = CornerRadiusModifier(mask: mask, radius: .equalTo(radius))
        return self.modifier(modifier, state: state)
    }
}
