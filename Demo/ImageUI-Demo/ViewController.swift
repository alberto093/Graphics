//
//  ViewController.swift
//  NeumorphicUI-Demo
//
//  Created by Alberto Saltarelli on 29/07/2020.
//  Copyright © 2020 Alberto Saltarelli. All rights reserved.
//

import UIKit
import NeumorphicUI

class ViewController: UIViewController {
    
    @IBOutlet private weak var control: NeumorphicControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        control
            .cornerRadius(radius: .circle)
            .border(position: .inside, width: 25, color: .green)
            .border(position: .inside, width: 50, color: .red)
            .border(position: .inside, width: 75, color: .yellow)
            .border(position: .inside, width: 100, color: .orange)
            .border(position: .inside, width: 25, color: .blue, state: .selected)
            .border(position: .inside, width: 50, color: .orange, state: .selected)
            .border(position: .inside, width: 75, color: .yellow, state: .selected)
            .border(position: .inside, width: 100, color: .red, state: .selected)
            .property(keyPath: \.alpha, value: 0.5, defaultValue: 1)
            .property(keyPath: \.alpha, value: 1, defaultValue: 1, state: .selected)
            .property(keyPath: \.contentView.backgroundColor, value: .blue, defaultValue: .white)
            .property(keyPath: \.contentView.backgroundColor, value: .green, defaultValue: .white, state: .selected)
    }
    
    @IBAction private func controlDidTap() {
        control.isSelected.toggle()
    }
}

