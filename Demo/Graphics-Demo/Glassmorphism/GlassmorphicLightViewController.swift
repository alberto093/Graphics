//
//  GlassmorphicLightViewController.swift
//  Graphics-Demo
//
//  Created by Alberto Saltarelli on 11/08/21.
//  Copyright © 2021 Alberto Saltarelli. All rights reserved.
//

import UIKit
import Graphics

class GlassmorphicLightViewController: UIViewController {
    
    @IBOutlet private weak var backgroundEllipse: GraphicsView!
    @IBOutlet private weak var backgroundEllipseContentView: GradientView!
    @IBOutlet private weak var portraitLeftCardView: CardView!
    @IBOutlet private weak var portraitCenterCardView: CardView!
    @IBOutlet private weak var portraitRightCardView: CardView!
    @IBOutlet private weak var landscapeLeftCardView: CardView!
    @IBOutlet private weak var landscapeRightCardView: CardView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBackground()
        setupCards()
    }

    private func setupBackground() {
        backgroundEllipse.cornerRadius(radius: .circle)
        
        backgroundEllipseContentView.startPoint = CGPoint(x: 0.2, y: 0.35)
        backgroundEllipseContentView.endPoint = CGPoint(x: 0.8, y: 0)
        backgroundEllipseContentView.colors = [
            UIColor(red: 188, green: 217, blue: 238),
            UIColor(red: 225, green: 238, blue: 188),
            UIColor(red: 188, green: 238, blue: 235)]
    }
    
    private func setupCards() {
        [portraitLeftCardView, portraitCenterCardView, portraitRightCardView, landscapeLeftCardView, landscapeRightCardView].forEach {
            $0.style = .dark
        }
    }
}
