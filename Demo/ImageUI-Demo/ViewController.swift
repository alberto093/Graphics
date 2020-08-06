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
            .blur(style: .light, intensity: 0.08)
    }
    
    @IBAction private func controlDidTap() {
        control.isSelected.toggle()
    }
}

