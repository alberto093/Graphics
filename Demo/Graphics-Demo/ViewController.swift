//
//  ViewController.swift
//  Graphics-Demo
//
//  Created by Alberto Saltarelli on 29/07/2020.
//  Copyright © 2020 Alberto Saltarelli. All rights reserved.
//

import UIKit
import Graphics

class ViewController: UIViewController {
    
    @IBOutlet private weak var control: GraphicsControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        control
            .cornerRadius(radius: .circle)
            .shadow(offset: .zero, radius: 12, opacity: 1)
            .blur(style: .regular, intensity: 0.2, vibrancy: .default)
            .border(position: .inside, width: 5, gradient: .init(colors: [.blue, .green]))
    }
    
    @IBAction private func controlDidTap() {
        control.isSelected.toggle()
    }
}

extension UIBezierPath {
    static func couponMask(bounds: CGRect, circleMaskLocationY: CGFloat, circleMaskRadius: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: 0, y: circleMaskLocationY - circleMaskRadius))
        path.addArc(
            withCenter: CGPoint(x: 0, y: circleMaskLocationY),
            radius: circleMaskRadius,
            startAngle: -(.pi / 2),
            endAngle: .pi / 2,
            clockwise: true)
        path.addLine(to: CGPoint(x: 0, y: bounds.maxY))
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
        path.addLine(to: CGPoint(x: bounds.maxX, y: circleMaskLocationY + circleMaskRadius))
        path.addArc(
            withCenter: CGPoint(x: bounds.maxX, y: circleMaskLocationY),
            radius: circleMaskRadius,
            startAngle: .pi / 2,
            endAngle: 3 / 2 * .pi,
            clockwise: true)
        path.addLine(to: CGPoint(x: bounds.maxX, y: 0))
        path.close()
        return path
    }
    
    static func couponDiscountMask(bounds: CGRect, curveMaskLocationY: CGFloat, curveLenght: CGFloat) -> UIBezierPath {
        let curveMinY = curveMaskLocationY - curveLenght / 2
        let curveMaxY = curveMinY + curveLenght
        let curveMinControlPointY = curveMinY + curveLenght / 4
        let curveMaxControlPointY = curveMaxY - curveLenght / 4
    
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: 0, y: curveMinY))
        path.addCurve(
            to: CGPoint(x: 0, y: curveMaxY),
            controlPoint1: CGPoint(x: curveLenght / 4, y: curveMinControlPointY),
            controlPoint2: CGPoint(x: curveLenght / 4, y: curveMaxControlPointY))
        path.addLine(to: CGPoint(x: 0, y: bounds.maxY))
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
        path.addLine(to: CGPoint(x: bounds.maxX, y: curveMaxY))
        path.addCurve(
            to: CGPoint(x: bounds.maxX, y: curveMinY),
            controlPoint1: CGPoint(x: bounds.maxX - curveLenght / 4, y: curveMaxControlPointY),
            controlPoint2: CGPoint(x: bounds.maxX - curveLenght / 4, y: curveMinControlPointY))
        path.addLine(to: CGPoint(x: bounds.maxX, y: 0))
        path.close()
        return path
    }
}
