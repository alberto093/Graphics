//
//  BorderModifier.swift
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

/// A modifier that allows to add a border to a graphics view.
///
/// It supports the corner radius applied to the view but It doesn't support any custom mask.
public class BorderModifier: GraphicsItemModifier {
    /// The position of border layer.
    public var border: Border
    
    /// The thickness of the border.
    public var width: CGFloat
    
    /// The color of the border.
    public var color: Color
    
    public let allowsMultipleModifiers = true
    
    private weak var borderLayer: CAGradientLayer?
    
    /// It creates a new border modifier.
    ///
    /// - Parameters:
    ///   - border: The position of border layer.
    ///   - width: The thickness of the border.
    ///   - color: The color of the border.
    public init(border: Border, width: CGFloat, color: Color) {
        self.border = border
        self.width = width
        self.color = color
    }
    
    public func modify(_ view: GraphicsItem, roundedCorners: UIRectCorner, cornerRadii: CGSize) {
        let layer = prepareBorderLayer(view: view)
        view.contentView.clipsToBounds = true
        
        let layerSize: CGSize
        
        switch border {
        case .inside:
            layerSize = view.bounds.size
        case .center:
            layerSize = view.bounds.insetBy(dx: -width / 2, dy: -width / 2).size
        case .outside:
            layerSize = view.bounds.insetBy(dx: -width, dy: -width).size
        }

        updateBorder(layer: layer, rectSize: layerSize, roundedCorners: roundedCorners, cornerRadii: cornerRadii)
    }
    
    public func revert(_ view: GraphicsItem) {
        
    }
    
    public func purge() {
        borderLayer?.removeFromSuperlayer()
    }
}

public extension BorderModifier {
    /// Constants that specify the border position.
    enum Border {
        
        /// Border is visually inside the view.
        case inside
        
        /// Border is visually over the view.
        case center
        
        /// Border is visually outside the view.
        case outside
    }
    
    /// Constants that specify the border color.
    enum Color {
        case gradient(configuration: GradientConfiguration)
        case flat(UIColor)
    }
    
    /// A configuration that will be provided to a gradient layer.
    struct GradientConfiguration {
        /// The style of gradient drawn by the layer.
        let type: CAGradientLayerType
        
        /// An array of `UIColor` objects defining the color of each gradient stop.
        let colors: [UIColor]
        
        /// An optional array of numbers defining the location of each gradient stop.
        let locations: [Double]?
        
        /// The start point of the gradient when drawn in the layer’s coordinate space.
        let startPoint: CGPoint
        
        /// The end point of the gradient when drawn in the layer’s coordinate space.
        let endPoint: CGPoint
        
        /// It creates a gradient configuration.
        /// - Parameters:
        ///   - type: The style of gradient drawn by the layer.
        ///   - colors: An array of `UIColor` objects defining the color of each gradient stop.
        ///   - locations: An optional array of numbers defining the location of each gradient stop.
        ///   - startPoint: The start point of the gradient when drawn in the layer’s coordinate space.
        ///   - endPoint: The end point of the gradient when drawn in the layer’s coordinate space.
        public init(
            type: CAGradientLayerType = .axial,
            colors: [UIColor],
            locations: [Double]? = nil,
            startPoint: CGPoint? = nil,
            endPoint: CGPoint? = nil) {
            self.type = type
            self.colors = colors
            self.locations = locations
            
            if let startPoint = startPoint {
                self.startPoint = startPoint
            } else {
                switch type {
                case .axial:
                    self.startPoint = CGPoint(x: 0.5, y: 0)
                case .radial:
                    self.startPoint = CGPoint(x: 0.5, y: 0.5)
                default:
                    if #available(iOS 12.0, *), type == .conic {
                        self.startPoint = CGPoint(x: 0.5, y: 0.5)
                    } else {
                        self.startPoint = CGPoint(x: 0.5, y: 0)
                    }
                }
            }
            
            if let endPoint = endPoint {
                self.endPoint = endPoint
            } else {
                switch type {
                case .axial:
                    self.endPoint = CGPoint(x: 0.5, y: 1)
                case .radial:
                    self.endPoint = CGPoint(x: 1, y: 1)
                default:
                    if #available(iOS 12.0, *), type == .conic {
                        self.endPoint = CGPoint(x: 0.5, y: 0)
                    } else {
                        self.endPoint = CGPoint(x: 0.5, y: 1)
                    }
                }
            }
        }
    }
}

public extension GraphicsItem {
    /// Adds a border to this view with the specified style and width.
    /// - Parameters:
    ///   - position: The position of border layer.
    ///   - width: The thickness of the border.
    ///   - color: The color of the border.
    /// - Returns: It returns the callers in order to apply multiple modifiers using the dot notation.
    @discardableResult func border(position: BorderModifier.Border = .center, width: CGFloat, color: UIColor) -> Self {
        let modifier = BorderModifier(border: position, width: width, color: .flat(color))
        return self.modifier(modifier)
    }
    
    /// Adds a border to this view with the specified style and width.
    /// - Parameters:
    ///   - position: The position of border layer.
    ///   - width: The thickness of the border.
    ///   - gradient: The configuration for the gradient layer.
    /// - Returns: It returns the callers in order to apply multiple modifiers using the dot notation.
    @discardableResult func border(position: BorderModifier.Border = .center, width: CGFloat, gradient: BorderModifier.GradientConfiguration) -> Self {
        let modifier = BorderModifier(border: position, width: width, color: .gradient(configuration: gradient))
        return self.modifier(modifier)
    }
}

public extension GraphicsItem where Self: UIControl {
    /// Adds a border to this view with the specified style and width.
    /// - Parameters:
    ///   - position: The position of border layer.
    ///   - width: The thickness of the border.
    ///   - color: The color of the border.
    ///   - state: The state that uses the specified modifier. The possible values are described in [UIControl.State](https://developer.apple.com/documentation/uikit/uicontrol/state).
    /// - Returns: It returns the callers in order to apply multiple modifiers using the dot notation.
    @discardableResult func border(position: BorderModifier.Border = .center, width: CGFloat, color: UIColor, state: State = .normal) -> Self {
        let modifier = BorderModifier(border: position, width: width, color: .flat(color))
        return self.modifier(modifier, state: state)
    }
    
    /// Adds a border to this view with the specified style and width.
    /// - Parameters:
    ///   - position: The position of border layer.
    ///   - width: The thickness of the border.
    ///   - gradient: The configuration for the gradient layer.
    ///   - state: The state that uses the specified modifier. The possible values are described in [UIControl.State](https://developer.apple.com/documentation/uikit/uicontrol/state).
    /// - Returns: It returns the callers in order to apply multiple modifiers using the dot notation.
    @discardableResult func border(position: BorderModifier.Border = .center, width: CGFloat, gradient: BorderModifier.GradientConfiguration, state: State = .normal) -> Self {
        let modifier = BorderModifier(border: position, width: width, color: .gradient(configuration: gradient))
        return self.modifier(modifier, state: state)
    }
}

private extension BorderModifier {
    @discardableResult func prepareBorderLayer(view: GraphicsItem) -> CAGradientLayer {
        let layer = borderLayer ?? CAGradientLayer()

        if view.isBlurredBackground, let backgrounView = view.backgroundView {
            backgrounView.layer.insertSublayer(layer, at: 1)
        } else {
            view.layer.insertSublayer(layer, at: 1)
        }

        self.borderLayer = layer
        layer.frame = view.contentView.bounds
        return layer
    }
    
    func updateBorder(layer: CAGradientLayer, rectSize: CGSize, roundedCorners: UIRectCorner, cornerRadii: CGSize) {
        switch color {
        case .flat(let color):
            layer.type = .radial
            layer.colors = [color.cgColor, color.cgColor]
        case .gradient(let configuration):
            layer.type = configuration.type
            layer.colors = configuration.colors.map(\.cgColor)
            layer.startPoint = configuration.startPoint
            layer.endPoint = configuration.endPoint
            layer.locations = configuration.locations?.map(NSNumber.init)
        }
        
        switch border {
        case .inside:
            layer.frame = CGRect(origin: .zero, size: rectSize)
        case .center:
            layer.frame = CGRect(origin: CGPoint(x: -width / 2, y: -width / 2), size: rectSize)
        case .outside:
            layer.frame = CGRect(origin: CGPoint(x: -width, y: -width), size: rectSize)
        }
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = CGRect(origin: .zero, size: rectSize)
        let holeRect = CGRect(x: width, y: width, width: rectSize.width - width * 2, height: rectSize.height - width * 2)
        let holePath = UIBezierPath(roundedRect: holeRect, byRoundingCorners: roundedCorners, cornerRadii: cornerRadii)
        let maskPath = UIBezierPath(roundedRect: CGRect(origin: .zero, size: rectSize), byRoundingCorners: roundedCorners, cornerRadii: cornerRadii)
        maskPath.append(holePath)
        maskLayer.fillRule = .evenOdd
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }
}
