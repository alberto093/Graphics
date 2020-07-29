//
//  File.swift
//  
//
//  Created by Alberto Saltarelli on 29/07/2020.
//

import UIKit

public extension NeumorphicItem {
    /// Invalidates the current modifiers of the receiver and triggers a modifiers update during the next update cycle.
    ///
    /// Call this method on your application’s main thread when you want to adjust the modifiers of a view’s subviews.
    /// This method makes a note of the request and returns immediately. Because this method does not force an immediate update, but instead waits for the next update cycle, you
    /// can use it to invalidate the modifiers of multiple neumorphic items before any of those views are updated.
    func setNeedsModify() {
        needsModify = true
        DispatchQueue.main.async {
            self.modifyIfNeeded()
        }
    }
    
    /// Updates modifiers immediately, if modifiers updates are pending.
    ///
    /// Use this method to force the `NeumorphicItem` to update its modifiers immediately. If no modifiers updates are pending, this method exits without modifying the existing modifiers.
    func modifyIfNeeded() {
        guard needsModify else { return }
        needsModify = false
        modifySubviews()
    }
    
    /// Updates modifiers.
    ///
    /// You should not call this method directly. If you want to force a modifiers update, call the `setNeedsModify()` method instead to do so prior to the next drawing update.
    /// If you want to update the modifiers of your views immediately, call the `modifyIfNeeded()` method.
    func modifySubviews() {
        if areAnimationsEnabled {
            animateModifiers()
        } else {
            applyNeumorphism()
        }
        
        for subview in subviews {
            guard let subitem = subview as? NeumorphicItem else { continue }
            subitem.modifySubviews()
        }
    }
    
    private func applyNeumorphism() {
        let revertedModifiers = applyModifiers()
        revertedModifiers.forEach { $0.purge() }
    }
    
    @discardableResult private func applyModifiers() -> [NeumorphicItemModifier] {
        let viewState = (self as? UIControl)?.state ?? .normal
        var cornerMaskRadii: (UIRectCorner, CGSize) = (.allCorners, .zero)
        
        for stateModifier in stateModifiers {
            guard let modifier = stateModifier.modifier as? NeumorphicItemRoundingModifier else { continue }
            if stateModifier.state == viewState || stateModifier.state == .normal {
                cornerMaskRadii = (modifier.roundedCorners, modifier.cornerRadii(in: self))
            }
        
            if stateModifier.state == viewState {
                break
            }
        }
        
        var revertedModifiers: [NeumorphicItemModifier] = []
        
        for stateModifier in stateModifiers {
            switch stateModifier.state {
            case
                viewState,
                .normal where !stateModifiers.contains(where: { type(of: $0.modifier) == type(of: stateModifier.modifier) && $0.state == viewState }):
                stateModifier.modifier.modify(self, roundedCorners: cornerMaskRadii.0, cornerRadii: cornerMaskRadii.1, animated: areAnimationsEnabled)
            default:
                stateModifier.modifier.revert(self, animated: areAnimationsEnabled)
                revertedModifiers.append(stateModifier.modifier)
            }
        }
        
        return revertedModifiers
    }
}

// MARK: - Animations
private extension NeumorphicItem {
    var areAnimationsEnabled: Bool {
        !animators.isEmpty
    }
    
    func animateModifiers() {
        let group = DispatchGroup()
        var revertedModifiers: [NeumorphicItemModifier] = []
        animators.forEach {
            group.enter()
            $0.animate(
                animations: { revertedModifiers.append(contentsOf: self.applyModifiers()) },
                completion: group.leave)
        }
        
        group.notify(queue: .main) {
            revertedModifiers.forEach { $0.purge() }
        }
    }
}
