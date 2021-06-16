//
//  File.swift
//  
//
//  Created by Alberto Saltarelli on 15/06/21.
//

import UIKit

class GradientMaskedView: GradientView {
    @IBOutlet private weak var contentMaskView: UIView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.mask = contentMaskView.layer
    }
}
