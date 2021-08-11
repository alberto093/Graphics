//
//  File.swift
//  
//
//  Created by Alberto Saltarelli on 10/08/21.
//

import UIKit
import Graphics

//swiftlint:disable:next type_name
class NeumorphicSegmentedControlsViewController: UIViewController {
    
    @IBOutlet private weak var gradientSegmentedControl: GraphicsSegmentedControl!
    @IBOutlet private weak var tintSegmentedControl: GraphicsSegmentedControl!
    @IBOutlet private weak var darkSegmentedControlContainerView: UIView!
    @IBOutlet private weak var darkSegmentedControl: GraphicsSegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .demoBackground
        setupGradientSegmentedControl()
        setupTintSegmentedControl()
        setupDarkSegmentedControl()
    }
    
    private func setupGradientSegmentedControl() {
        gradientSegmentedControl.configuration.backgroundColor = .demoBackground
        gradientSegmentedControl.configuration.selectionStyle = .toggle(background: .demoBackground)
        
        gradientSegmentedControl
            .cornerRadius(radius: .circle)
            .shadow(.inner, color: .lightShadow, offset: CGSize(width: -10, height: -10), blur: 10, opacity: 0.7)
            .shadow(.inner, color: .darkShadow, offset: CGSize(width: 10, height: 10), blur: 10, opacity: 0.2)
        
        gradientSegmentedControl.toggleItem
            .cornerRadius(radius: .circle)
            .border(width: 4, gradient: BorderModifier.GradientConfiguration(colors: [.red, .orange]))
            .shadow(color: .darkShadow, offset: CGSize(width: 10, height: 10), blur: 30, opacity: 0.4)
            .shadow(color: .lightShadow, offset: CGSize(width: -10, height: -10), blur: 30, opacity: 1)
        
        gradientSegmentedControl.titles = ["First", "Second", "Third"]
        gradientSegmentedControl.selectedSegmentIndex = 0
    
        let segmentsNormalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor(red: 164, green: 171, blue: 195)
        ]
        
        let segmentsSelectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor(red: 42, green: 47, blue: 88)
        ]
        
        gradientSegmentedControl.setTitleTextAttributes(segmentsNormalAttributes, for: .normal)
        [UIControl.State.selected, .highlighted, [.highlighted, .selected]].forEach {
            gradientSegmentedControl.setTitleTextAttributes(segmentsSelectedAttributes, for: $0)
        }
    }
    
    private func setupTintSegmentedControl() {
        tintSegmentedControl.configuration.backgroundColor = .demoBackground
        tintSegmentedControl.configuration.selectionStyle = .toggle(background: .demoBackground)
        
        tintSegmentedControl
            .cornerRadius(radius: .circle)
            .shadow(color: .darkShadow, offset: CGSize(width: 5, height: 5), blur: 15, opacity: 0.4)
            .shadow(color: .lightShadow, offset: CGSize(width: -5, height: -5), blur: 15)
        
        tintSegmentedControl.toggleItem
            .cornerRadius(radius: .circle)
        
        tintSegmentedControl.titles = ["First", "Second", "Third"]
        tintSegmentedControl.selectedSegmentIndex = 0
    
        let segmentsNormalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor(red: 164, green: 171, blue: 195)
        ]
        
        let segmentsSelectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.red
        ]
        
        tintSegmentedControl.setTitleTextAttributes(segmentsNormalAttributes, for: .normal)
        [UIControl.State.selected, .highlighted, [.highlighted, .selected]].forEach {
            tintSegmentedControl.setTitleTextAttributes(segmentsSelectedAttributes, for: $0)
        }
    }
    
    private func setupDarkSegmentedControl() {
        let backgroundColor = UIColor(red: 19, green: 20, blue: 25)
        let darkShadowColor = UIColor.black
        let lightShadowColor = UIColor(red: 46, green: 48, blue: 52)
        darkSegmentedControlContainerView.backgroundColor = backgroundColor
        
        darkSegmentedControl.configuration.backgroundColor = backgroundColor
        darkSegmentedControl.configuration.selectionStyle = .toggle(background: backgroundColor)
        
        darkSegmentedControl
            .cornerRadius(radius: 14)
            .shadow(color: darkShadowColor, offset: CGSize(width: 5, height: 5), blur: 5, opacity: 0.7)
            .shadow(color: lightShadowColor, offset: CGSize(width: -5, height: -5), blur: 5, opacity: 0.5)
        
        darkSegmentedControl.toggleItem
            .cornerRadius(radius: 14)
            .shadow(.inner, color: lightShadowColor, offset: CGSize(width: -5, height: -5), blur: 5, opacity: 0.3)
            .shadow(.inner, color: darkShadowColor, offset: CGSize(width: 5, height: 5), blur: 5, opacity: 0.2)
        
        darkSegmentedControl.toggleItemInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        
        darkSegmentedControl.titles = ["First", "Second", "Third"]
        darkSegmentedControl.selectedSegmentIndex = 0
    
        let segmentsNormalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor(red: 120, green: 120, blue: 120)
        ]
        
        let segmentsSelectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor(red: 242, green: 20, blue: 54)
        ]
        
        darkSegmentedControl.setTitleTextAttributes(segmentsNormalAttributes, for: .normal)
        [UIControl.State.selected, .highlighted, [.highlighted, .selected]].forEach {
            darkSegmentedControl.setTitleTextAttributes(segmentsSelectedAttributes, for: $0)
        }
    }
}
