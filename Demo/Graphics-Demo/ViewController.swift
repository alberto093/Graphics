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
            .blur(style: .regular, intensity: 0.1)
            .blur(style: .regular, intensity: 0.2, state: .highlighted)
            .blur(style: .regular, intensity: 1, state: .selected)
            .blur(style: .regular, intensity: 0.8, state: [.highlighted, .selected])
            .border(width: 2, gradient: .init(type: .conic, colors: [.red, .yellow]))
            .shadow(.inner)
    }
    
    @IBAction private func controlDidTap() {
        control.isSelected.toggle()
    }
}
