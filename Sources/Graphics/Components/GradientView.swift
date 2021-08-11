//
//  GradientView.swift
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

open class GradientView: UIView {
    public override static var layerClass: AnyClass {
        CAGradientLayer.self
    }
    
    public var startPoint: CGPoint = CGPoint(x: 0.5, y: 0)
    public var endPoint: CGPoint = CGPoint(x: 0.5, y: 1)
    private var firstColor: UIColor = .clear
    private var secondColor: UIColor = .clear

    public var gradientLayer: CAGradientLayer {
        // swiftlint:disable:next force_cast
        layer as! CAGradientLayer
    }
    
    public var colors: [UIColor]? {
        didSet { setNeedsDisplay() }
    }
    
    public var locations: [Double]? {
        didSet { setNeedsDisplay() }
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        gradientLayer.colors = (colors ?? [firstColor, secondColor]).map(\.cgColor)
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.locations = locations?.map(NSNumber.init)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .clear
    }
}
