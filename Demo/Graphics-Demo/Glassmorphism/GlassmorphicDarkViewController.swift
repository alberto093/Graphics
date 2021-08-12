//
//  GlassmorphicDarkViewController.swift
//  Graphics-Demo
//
//  Created by Alberto Saltarelli on 11/08/21.
//  Copyright © 2021 Alberto Saltarelli. All rights reserved.
//

import UIKit
import Graphics

class GlassmorphicDarkViewController: UIViewController {
    
    @IBOutlet private weak var topLeftEllipse: GradientView!
    @IBOutlet private weak var cardTopEllipse: GradientView!
    @IBOutlet private weak var cardBottomEllipse: GradientView!
    @IBOutlet private weak var cardView: GraphicsView!
    @IBOutlet private weak var bottomPortraitEllipse: GradientView!
    @IBOutlet private weak var portraitCardView: CardView!
    @IBOutlet private weak var bottomLandscapeEllipse: GradientView!
    @IBOutlet private weak var landscapeCardView: CardView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBackground()
        setupCard()
        setupPortraitCard()
        setupLandscapeCard()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        [topLeftEllipse, cardTopEllipse, cardBottomEllipse, bottomPortraitEllipse, bottomLandscapeEllipse].forEach {
            $0.layer.cornerRadius = min($0.bounds.width, $0.bounds.height) / 2
        }
    }
    
    private func setupBackground() {
        view.backgroundColor = UIColor(red: 16, green: 16, blue: 16)
        
        topLeftEllipse.startPoint = CGPoint(x: 0.5, y: 0.5)
        topLeftEllipse.endPoint = CGPoint(x: 1, y: 0)
        topLeftEllipse.colors = [UIColor(red: 9, green: 69, blue: 223), UIColor(red: 23, green: 179, blue: 169)]
        topLeftEllipse.transform = CGAffineTransform(rotationAngle: 30 * .pi / 180)
        topLeftEllipse.clipsToBounds = true
    }
    
    private func setupCard() {
        cardTopEllipse.startPoint = CGPoint(x: 0.5, y: 0.5)
        cardTopEllipse.endPoint = CGPoint(x: 1, y: 0)
        cardTopEllipse.colors = [UIColor(red: 9, green: 56, blue: 223), UIColor(red: 23, green: 179, blue: 132)]
        
        cardView.transform = CGAffineTransform(rotationAngle: -15 * .pi / 180)

        cardView
            .cornerRadius(radius: 16)
            .blur(style: .regular, intensity: 0.4)
            .border(width: 2, gradient: BorderModifier.GradientConfiguration(
                        type: .conic,
                        colors: [UIColor(red: 143, green: 118, blue: 125).withAlphaComponent(0.1),
                                 UIColor(red: 196, green: 70, blue: 197),
                                 UIColor(red: 196, green: 70, blue: 197).withAlphaComponent(0.1),
                                 UIColor(red: 143, green: 118, blue: 125)],
                        locations: [0.25, 0.65, 0.75, 1],
                        endPoint: CGPoint(x: 0.3, y: 0)))
        
        cardBottomEllipse.startPoint = CGPoint(x: 0.5, y: 0.5)
        cardBottomEllipse.endPoint = CGPoint(x: 1, y: 0)
        cardBottomEllipse.colors = [UIColor(red: 223, green: 9, blue: 202), UIColor(red: 119, green: 23, blue: 179)]
    }
    
    private func setupPortraitCard() {
        bottomPortraitEllipse.startPoint = CGPoint(x: 0.5, y: 0.5)
        bottomPortraitEllipse.endPoint = CGPoint(x: 1, y: 0)
        bottomPortraitEllipse.colors = [UIColor(red: 230, green: 68, blue: 103), UIColor(red: 231, green: 206, blue: 74)]
        
        portraitCardView.border(
            width: 2,
            gradient: BorderModifier.GradientConfiguration(
                type: .conic,
                colors: [UIColor(red: 33, green: 33, blue: 33).withAlphaComponent(0.1), UIColor(red: 91, green: 106, blue: 101)],
                startPoint: CGPoint(x: 1, y: 0.5),
                endPoint: CGPoint(x: 0, y: 0.3)))
    }
    
    private func setupLandscapeCard() {
        bottomLandscapeEllipse.startPoint = CGPoint(x: 0.5, y: 0.5)
        bottomLandscapeEllipse.endPoint = CGPoint(x: 1, y: 0)
        bottomLandscapeEllipse.colors = [UIColor(red: 83, green: 120, blue: 217), UIColor(red: 188, green: 238, blue: 235)]
        
        landscapeCardView.border(
            width: 2,
            gradient: BorderModifier.GradientConfiguration(
                type: .conic,
                colors: [
                    UIColor(red: 33, green: 33, blue: 33).withAlphaComponent(0.1),
                    UIColor(red: 140, green: 178, blue: 210),
                    UIColor(red: 33, green: 33, blue: 33).withAlphaComponent(0.1)],
                startPoint: CGPoint(x: 0.8, y: 0),
                endPoint: CGPoint(x: 0, y: 0.8)))
    }
}
