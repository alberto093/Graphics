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
    /// You should not call this method directly. If you want to force a modifiers update, call the `setNeedsModify()` method instead to do so prior to the next drawing update.
    /// If you want to update the modifiers of your views immediately, call the `modifyIfNeeded()` method.
    func modifySubviews() {
        if needsSorting {
            stateModifiers = stateModifiers.sorted { $0.modifier.priority.rawValue > $1.modifier.priority.rawValue }
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
        
        for stateModifier in stateModifiers {
            switch stateModifier.state {
            case
                viewState,
                .normal where !stateModifiers.contains(where: { type(of: $0.modifier) == type(of: stateModifier.modifier) && $0.state == viewState }):
                stateModifier.modifier.modify(self, roundedCorners: cornerMaskRadii.0, cornerRadii: cornerMaskRadii.1)
            default:
                let shouldRevertModifier: Bool
                
                if stateModifier.modifier.allowsMultipleModifiers {
                    shouldRevertModifier = true
                } else {
                    let existActiveModifier = stateModifiers.contains {
                        let stateRequirement = $0.state == viewState || $0.state == .normal
                        return type(of: $0.modifier) == type(of: stateModifier.modifier) && stateRequirement
                    }
                    
                    shouldRevertModifier = !existActiveModifier
                }
                
                if shouldRevertModifier {
                    stateModifier.modifier.revert(self)
                    revertedModifiers.append(stateModifier.modifier)
                }
            }
        }
        
        return revertedModifiers
    }
}
