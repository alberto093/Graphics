//
//  GraphicsItem+Lifecycle.swift
//
//  Copyright © 2021 Graphics - Alberto Saltarelli
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

public extension GraphicsItem {
    /// Updates modifiers.
    ///
    /// You should not call this method directly. If you want to force a modifiers update, call the `setNeedsLayout()` method instead to do so prior to the next drawing update.
    /// If you want to update the modifiers of your views immediately, call the `layoutIfNeeded()` method.
    func modifySubviews() {
        if needsSorting {
            stateModifiers = stateModifiers.sorted {
                let lhs = ($0.modifier.priority.rawValue, $0.state.rawValue)
                let rhs = ($1.modifier.priority.rawValue, $1.state.rawValue)
                return lhs > rhs
            }
            
            needsSorting = false
        }
        applyGraphics()
        
        for subview in subviews {
            guard let subitem = subview as? GraphicsItem else { continue }
            subitem.modifySubviews()
        }
    }
    
    private func applyGraphics() {
        let revertedModifiers = applyModifiers()
        revertedModifiers.forEach { $0.purge() }
    }
    
    @discardableResult private func applyModifiers() -> [GraphicsItemModifier] {
        let viewState = (self as? UIControl)?.state ?? .normal
        var cornerMaskRadii: (UIRectCorner, CGSize) = (.allCorners, .zero)
        
        for stateModifier in stateModifiers {
            guard let modifier = stateModifier.modifier as? GraphicsItemRoundingModifier else { continue }
            if stateModifier.state == viewState || stateModifier.state == .normal {
                cornerMaskRadii = (modifier.roundedCorners, modifier.cornerRadii(in: self))
            }
        
            if stateModifier.state == viewState {
                break
            }
        }
        
        var revertedModifiers: [GraphicsItemModifier] = []
        var viewStateAppliedModifiers: Set<String> = []
        var normalStateAppliedModifiers: Set<String> = []

        for stateModifier in stateModifiers {
            let modifierIdentifier = type(of: stateModifier.modifier).identifier

            switch stateModifier.state {
            case viewState where
                    !viewStateAppliedModifiers.contains(modifierIdentifier) || stateModifier.modifier.allowsMultipleModifiers:
                
                stateModifier.modifier.modify(self, roundedCorners: cornerMaskRadii.0, cornerRadii: cornerMaskRadii.1)
                viewStateAppliedModifiers.insert(modifierIdentifier)
            case .normal where
                    !viewStateAppliedModifiers.contains(modifierIdentifier) &&
                    (!normalStateAppliedModifiers.contains(modifierIdentifier) || stateModifier.modifier.allowsMultipleModifiers):
                
                stateModifier.modifier.modify(self, roundedCorners: cornerMaskRadii.0, cornerRadii: cornerMaskRadii.1)
                normalStateAppliedModifiers.insert(modifierIdentifier)
            default:
                stateModifier.modifier.revert(self)
                revertedModifiers.append(stateModifier.modifier)
            }
        }
        
        return revertedModifiers
    }
}
