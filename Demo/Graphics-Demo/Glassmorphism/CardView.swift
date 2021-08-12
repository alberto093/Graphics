//
//  CardView.swift
//  Graphics-Demo
//
//  Created by Alberto Saltarelli on 11/08/21.
//  Copyright © 2021 Alberto Saltarelli. All rights reserved.
//

import UIKit
import Graphics

class CardView: GraphicsNibView {
    enum Style {
        case dark
        case light
    }
    
    @IBOutlet private weak var numberLabel: UILabel!
    @IBOutlet private weak var holderLabel: UILabel!
    @IBOutlet private weak var ringsImageView: UIImageView!
    @IBOutlet private weak var wavesImageView: UIImageView!
    
    var style: Style = .light {
        didSet {
            update()
        }
    }
    
    private var blurModifier: BlurModifier?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cornerRadius(radius: 16)
        update()
    }
    
    private func update() {
        if let blurModifier = blurModifier {
            remove(modifier: blurModifier)
        }
        
        switch style {
        case .dark:
            blurModifier = BlurModifier(blurStyle: .systemUltraThinMaterialDark, blurIntensity: 0.35)
            [ringsImageView, wavesImageView].forEach {
                $0?.tintColor = UIColor(red: 100, green: 110, blue: 108)
            }
            
            [numberLabel, holderLabel].forEach {
                $0?.textColor = UIColor(red: 21, green: 21, blue: 21).withAlphaComponent(0.5)
            }
        case .light:
            blurModifier = BlurModifier(blurStyle: .regular, blurIntensity: 0.52)
            [ringsImageView, wavesImageView].forEach {
                $0?.tintColor = UIColor(red: 160, green: 160, blue: 160)
            }
            
            [numberLabel, holderLabel].forEach {
                $0?.textColor = .white.withAlphaComponent(0.6)
            }
        }
        
        modifier(blurModifier!)
    }
}
