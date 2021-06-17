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
    
    @IBOutlet private weak var gradientButton: GraphicsButton!
    @IBOutlet private weak var imageButton: GraphicsButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .demoBackground
        setupTitleButton()
        setupImageButton()
    }
    
    private func setupTitleButton() {
        gradientButton.configuration.background = .solid(.demoBackground)
        gradientButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        gradientButton
            .cornerRadius(radius: 20)
            .shadow(color: .darkShadow, offset: CGSize(width: 5, height: 5), blur: 15, opacity: 0.4)
            .shadow(color: .lightShadow, offset: CGSize(width: -5, height: -5), blur: 15)
            .shadow(color: .darkShadow, offset: CGSize(width: 2, height: 2), blur: 10, opacity: 0.4, state: .highlighted)
            .shadow(color: .lightShadow, offset: CGSize(width: -2, height: -2), blur: 10, state: .highlighted)
            .shadow(.inner, color: .lightShadow, offset: CGSize(width: -14, height: -14), blur: 15, opacity: 0.7, state: [.highlighted, .selected])
            .shadow(.inner, color: .darkShadow, offset: CGSize(width: 14, height: 14), blur: 15, opacity: 0.2, state: [.highlighted, .selected])
            .shadow(.inner, color: .lightShadow, offset: CGSize(width: -10, height: -10), blur: 10, opacity: 0.7, state: .selected)
            .shadow(.inner, color: .darkShadow, offset: CGSize(width: 10, height: 10), blur: 10, opacity: 0.2, state: .selected)
        
        gradientButton.setTitleGradient(colors: [.red, .orange], for: .normal)
        gradientButton.setTitleGradient(colors: [.orange, .red], for: .selected)
        gradientButton.setTitle("Graphics", for: .normal)
        gradientButton.titleLabel.font = .boldSystemFont(ofSize: 48)
    }
    
    private func setupImageButton() {
        imageButton.configuration.background = .solid(.demoBackground)
        imageButton.configuration.imageBackground = .solid(.demoBackground)
        imageButton.imageEdgeInsets = UIEdgeInsets(top: 26, left: 18, bottom: 26, right: 18)
        imageButton.tintColor = .purple
        
        imageButton
            .cornerRadius(radius: .circle)
            .shadow(color: .darkShadow, offset: CGSize(width: 5, height: 5), blur: 15, opacity: 0.4)
            .shadow(color: .lightShadow, offset: CGSize(width: -5, height: -5), blur: 15)
            .shadow(color: .darkShadow, offset: CGSize(width: 2, height: 2), blur: 10, opacity: 0.4, state: .highlighted)
            .shadow(color: .lightShadow, offset: CGSize(width: -2, height: -2), blur: 10, state: .highlighted)
            .shadow(.inner, color: .lightShadow, offset: CGSize(width: -14, height: -14), blur: 15, opacity: 0.7, state: [.highlighted, .selected])
            .shadow(.inner, color: .darkShadow, offset: CGSize(width: 14, height: 14), blur: 15, opacity: 0.2, state: [.highlighted, .selected])
            .shadow(.inner, color: .lightShadow, offset: CGSize(width: -10, height: -10), blur: 10, opacity: 0.7, state: .selected)
            .shadow(.inner, color: .darkShadow, offset: CGSize(width: 10, height: 10), blur: 10, opacity: 0.2, state: .selected)
        
        imageButton.imageGraphicsItem
            .cornerRadius(radius: .circle)
            .shadow(color: .darkShadow, offset: CGSize(width: 5, height: 5), blur: 15, opacity: 0.4)
            .shadow(color: .lightShadow, offset: CGSize(width: -5, height: -5), blur: 15)
            .shadow(color: .darkShadow, offset: CGSize(width: 2, height: 2), blur: 10, opacity: 0.4, state: .highlighted)
            .shadow(color: .lightShadow, offset: CGSize(width: -2, height: -2), blur: 10, state: .highlighted)
            .shadow(.inner, color: .lightShadow, offset: CGSize(width: -14, height: -14), blur: 15, opacity: 0.7, state: [.highlighted, .selected])
            .shadow(.inner, color: .darkShadow, offset: CGSize(width: 14, height: 14), blur: 15, opacity: 0.2, state: [.highlighted, .selected])
            .shadow(.inner, color: .lightShadow, offset: CGSize(width: -10, height: -10), blur: 10, opacity: 0.7, state: .selected)
            .shadow(.inner, color: .darkShadow, offset: CGSize(width: 10, height: 10), blur: 10, opacity: 0.2, state: .selected)
        
        imageButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
        imageButton.setImage(UIImage(systemName: "play.circle.fill"), for: .highlighted)
        imageButton.setImage(UIImage(systemName: "play.circle.fill"), for: .selected)
        imageButton.setImage(UIImage(systemName: "play.circle.fill"), for: [.highlighted, .selected])
        imageButton.imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 68, weight: .regular, scale: .large)
    }
    
    @IBAction private func buttonDidTap(_ sender: UIControl) {
        sender.isSelected.toggle()
    }
}
