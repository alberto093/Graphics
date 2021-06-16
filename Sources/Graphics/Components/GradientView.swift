//
//  File.swift
//  
//
//  Created by Alberto Saltarelli on 15/06/21.
//

import UIKit

class GradientView: UIView {
    override static var layerClass: AnyClass {
        CAGradientLayer.self
    }
    
    var startPoint: CGPoint = CGPoint(x: 0.5, y: 0)
    var endPoint: CGPoint = CGPoint(x: 0.5, y: 1)
    private var firstColor: UIColor = .clear
    private var secondColor: UIColor = .clear

    var gradientLayer: CAGradientLayer {
        // swiftlint:disable:next force_cast
        layer as! CAGradientLayer
    }
    
    var colors: [UIColor]? {
        didSet { setNeedsDisplay() }
    }
    
    var locations: [Double]? {
        didSet { setNeedsDisplay() }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        gradientLayer.colors = (colors ?? [firstColor, secondColor]).map(\.cgColor)
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.locations = locations?.map(NSNumber.init)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .clear
    }
}
