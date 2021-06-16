//
//  NeumorphicButtonsViewController.swift
//  Graphics-Demo
//
//  Created by Alberto Saltarelli on 15/06/21.
//  Copyright © 2021 Alberto Saltarelli. All rights reserved.
//

import UIKit
import Graphics

class NeumorphicButtonsViewController: UIViewController {
    
    @IBOutlet private weak var titleButton: GraphicsButton!
    @IBOutlet private weak var imageButton: GraphicsButton!
    @IBOutlet private weak var gradientButton: GraphicsButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .demoBackground
        setupTitleButton()
    }
    
    private func setupTitleButton() {
        titleButton.configuration.background = .solid(.demoBackground)
        titleButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        titleButton
            .cornerRadius(radius: 20)
            .shadow(color: .darkShadow, offset: CGSize(width: 5, height: 5), blur: 15, opacity: 0.4)
            .shadow(color: .lightShadow, offset: CGSize(width: -5, height: -5), blur: 15)
            .shadow(color: .darkShadow, offset: CGSize(width: 2, height: 2), blur: 10, opacity: 0.4, state: .highlighted)
            .shadow(color: .lightShadow, offset: CGSize(width: -2, height: -2), blur: 10, state: .highlighted)
            .shadow(.inner, color: .lightShadow, offset: CGSize(width: -14, height: -14), blur: 15, opacity: 0.7, state: [.highlighted, .selected])
            .shadow(.inner, color: .darkShadow, offset: CGSize(width: 14, height: 14), blur: 15, opacity: 0.2, state: [.highlighted, .selected])
            .shadow(.inner, color: .lightShadow, offset: CGSize(width: -10, height: -10), blur: 10, opacity: 0.7, state: .selected)
            .shadow(.inner, color: .darkShadow, offset: CGSize(width: 10, height: 10), blur: 10, opacity: 0.2, state: .selected)
        
        titleButton.setTitleGradient(colors: [.red, .orange], for: .normal)
        titleButton.setTitle("Graphics", for: .normal)
        titleButton.titleLabel.font = .boldSystemFont(ofSize: 48)
    }
    
    @IBAction private func titleButtonDidTap() {
        titleButton.isSelected.toggle()
    }
}
