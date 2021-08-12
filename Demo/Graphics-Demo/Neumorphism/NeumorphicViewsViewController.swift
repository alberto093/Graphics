//
//  NeumorphicViewsViewController.swift
//  Graphics-Demo
//
//  Created by Alberto Saltarelli on 11/08/21.
//  Copyright © 2021 Alberto Saltarelli. All rights reserved.
//

import UIKit
import Graphics

class NeumorphicViewsViewController: UIViewController {
    
    @IBOutlet private weak var dropShadowView: GraphicsView!
    @IBOutlet private weak var innerShadowView: GraphicsView!
    @IBOutlet private weak var circleMainView: GraphicsView!
    @IBOutlet private weak var circleInnerView: GraphicsView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .demoBackground
        setupDropShadowView()
        setupInnerShadowView()
        setupCircleView()
    }
    
    private func setupDropShadowView() {
        dropShadowView.contentView.backgroundColor = .demoBackground
        
        dropShadowView
            .cornerRadius(radius: 24)
            .shadow(color: .darkShadow, offset: CGSize(width: 5, height: 5), blur: 15, opacity: 0.4)
            .shadow(color: .lightShadow, offset: CGSize(width: -5, height: -5), blur: 15)
    }
    
    private func setupInnerShadowView() {
        innerShadowView.contentView.backgroundColor = .demoBackground
        
        innerShadowView
            .cornerRadius(radius: 16)
            .shadow(.inner, color: .lightShadow, offset: CGSize(width: -10, height: -10), blur: 10, opacity: 0.7)
            .shadow(.inner, color: .darkShadow, offset: CGSize(width: 10, height: 10), blur: 10, opacity: 0.2)
    }
    
    private func setupCircleView() {
        circleMainView.contentView.backgroundColor = .demoBackground
        circleInnerView.contentView.backgroundColor = .demoBackground
        
        circleMainView
            .cornerRadius(radius: .circle)
            .shadow(.inner, color: .lightShadow, offset: CGSize(width: -10, height: -10), blur: 10, opacity: 0.7)
            .shadow(.inner, color: .darkShadow, offset: CGSize(width: 10, height: 10), blur: 10, opacity: 0.2)
        
        circleInnerView
            .cornerRadius(radius: .circle)
            .shadow(color: .darkShadow, offset: CGSize(width: 5, height: 5), blur: 15, opacity: 0.4)
            .shadow(color: .lightShadow, offset: CGSize(width: -5, height: -5), blur: 15)
    }
}
