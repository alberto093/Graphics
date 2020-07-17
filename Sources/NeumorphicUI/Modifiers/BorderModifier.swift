//
//  BorderModifier.swift
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

public class BorderModifier: NeumorphicItemModifier {
    public var border: Border
    public var width: CGFloat
    public var color: Color
    
    private weak var borderLayer: CAGradientLayer?
    
    public init(border: Border, width: CGFloat, color: Color) {
        self.border = border
        self.width = width
        self.color = color
    }
    
    public func modify(_ view: NeumorphicItem, roundedCorners: UIRectCorner, cornerRadii: CGSize) {
        let layer = prepareBorderLayer(view: view)
        view.contentView.clipsToBounds = true
        
        let layerSize: CGSize
        
        switch border {
        case .inside:
            layerSize = view.contentView.bounds.size
        case .center:
            layerSize = view.contentView.bounds.insetBy(dx: -width / 2, dy: -width / 2).size
        case .outside:
            layerSize = view.contentView.bounds.insetBy(dx: -width, dy: -width).size
        }

        updateBorder(layer: layer, rectSize: layerSize, roundedCorners: roundedCorners, cornerRadii: cornerRadii)
    }
    
    public func revert(_ view: NeumorphicItem) {
        #warning("Add basic animation to change the path to 'zero'")
    }
    
    public func purge() {
        borderLayer?.removeFromSuperlayer()
    }
}

public extension BorderModifier {
    enum Border {
        case inside
        case center
        case outside
    }
    
    enum Color {
        case gradient(configuration: GradientConfiguration)
        case flat(UIColor)
    }
    
    struct GradientConfiguration {
        let type: CAGradientLayerType
        let colors: [UIColor]
        let locations: [Double]?
        let startPoint: CGPoint
        let endPoint: CGPoint
        
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

public extension NeumorphicItem {
    @discardableResult func border(position: BorderModifier.Border = .center, width: CGFloat, color: UIColor) -> Self {
        let modifier = BorderModifier(border: position, width: width, color: .flat(color))
        return self.modifier(modifier)
    }
    
    @discardableResult func border(position: BorderModifier.Border = .center, width: CGFloat, gradient: BorderModifier.GradientConfiguration) -> Self {
        let modifier = BorderModifier(border: position, width: width, color: .gradient(configuration: gradient))
        return self.modifier(modifier)
    }
}

public extension NeumorphicItem where Self: UIControl {
    @discardableResult func border(position: BorderModifier.Border = .center, width: CGFloat, color: UIColor, state: UIControl.State = .normal) -> Self {
        let modifier = BorderModifier(border: position, width: width, color: .flat(color))
        return self.modifier(modifier, state: state)
    }
    
    @discardableResult func border(position: BorderModifier.Border = .center, width: CGFloat, gradient: BorderModifier.GradientConfiguration, state: UIControl.State = .normal) -> Self {
        let modifier = BorderModifier(border: position, width: width, color: .gradient(configuration: gradient))
        return self.modifier(modifier, state: state)
    }
}

private extension BorderModifier {
    @discardableResult func prepareBorderLayer(view: NeumorphicItem) -> CAGradientLayer {
        let layer: CAGradientLayer
        if let borderLayer = borderLayer {
            layer = borderLayer
        } else {
            layer = CAGradientLayer()
            view.layer.insertSublayer(layer, above: view.contentView.layer)
            self.borderLayer = layer
        }
        
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
