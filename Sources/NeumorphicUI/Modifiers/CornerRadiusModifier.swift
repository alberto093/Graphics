//
//  CornerRadiusModifier.swift
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

public class CornerRadiusModifier {
    public enum Radius {
        case circle
        case equalTo(CGFloat)
    }
    
    public var mask: CACornerMask
    public var radius: Radius
    
    public init(mask: CACornerMask, radius: Radius) {
        self.mask = mask
        self.radius = radius
    }
}

extension CornerRadiusModifier: NeumorphicItemRoundingModifier {
    public var roundedCorners: UIRectCorner {
        mask.rectCorners
    }
    
    public func cornerRadii(in view: NeumorphicItem) -> CGSize {
        let cornerRadius = self.cornerRadius(in: view)
        return CGSize(width: cornerRadius, height: cornerRadius)
    }
    
    public func modify(_ view: NeumorphicItem, animated: Bool) {
        view.contentView.clipsToBounds = true
        view.contentView.layer.maskedCorners = mask
        view.contentView.layer.cornerRadius = cornerRadius(in: view)
    }
    
    public func revert(_ view: NeumorphicItem, animated: Bool) {
        view.contentView.layer.maskedCorners = .all
        view.contentView.layer.cornerRadius = 0
    }

    private func cornerRadius(in view: NeumorphicItem) -> CGFloat {
        switch radius {
        case .circle:
            return min(view.contentView.bounds.width, view.contentView.bounds.height) / 2
        case .equalTo(let radius):
            return radius
        }
    }
}

public extension CACornerMask {
    static let all: CACornerMask = [
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

public extension NeumorphicItem {
    @discardableResult func cornerRadius(mask: CACornerMask = .all, radius: CornerRadiusModifier.Radius) -> Self {
        let modifier = CornerRadiusModifier(mask: mask, radius: radius)
        return self.modifier(modifier)
    }
    
    @discardableResult func cornerRadius(mask: CACornerMask = .all, radius: CGFloat) -> Self {
        let modifier = CornerRadiusModifier(mask: mask, radius: .equalTo(radius))
        return self.modifier(modifier)
    }
}

public extension NeumorphicItem where Self: UIControl {
    @discardableResult func cornerRadius(mask: CACornerMask = .all, radius: CornerRadiusModifier.Radius, state: UIControl.State = .normal) -> Self {
        let modifier = CornerRadiusModifier(mask: mask, radius: radius)
        return self.modifier(modifier, state: state)
    }
    
    @discardableResult func cornerRadius(mask: CACornerMask = .all, radius: CGFloat, state: UIControl.State = .normal) -> Self {
        let modifier = CornerRadiusModifier(mask: mask, radius: .equalTo(radius))
        return self.modifier(modifier, state: state)
    }
}
