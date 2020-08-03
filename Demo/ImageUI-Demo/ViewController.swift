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
            .border(position: .inside, width: 125, color: .brown)
            .property(keyPath: \.alpha, value: 0.5)
            .property(keyPath: \.alpha, value: 1, state: .selected)
            
    }
    
    @IBAction private func controlDidTap() {
        control.isSelected.toggle()
    }
}

