//
//  NeumorphicItem+Modifier.swift
//
//  Copyright © 2020 NeumorphicUI - Alberto Saltarelli
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

// MARK: - Public
public protocol NeumorphicItemModifier: class {
    func modify(_ view: NeumorphicItem, roundedCorners: UIRectCorner, cornerRadii: CGSize)
    func revert(_ view: NeumorphicItem)
    func purge()
}

public extension NeumorphicItemModifier {
    func purge() { }
}

public protocol NeumorphicItemRoundingModifier: NeumorphicItemModifier {
    var roundedCorners: UIRectCorner { get }
    func cornerRadii(in view: NeumorphicItem) -> CGSize
    func modify(_ view: NeumorphicItem)
}

public extension NeumorphicItemRoundingModifier {
    func modify(_ view: NeumorphicItem, roundedCorners: UIRectCorner, cornerRadii: CGSize) {
        modify(view)
    }
}

public extension NeumorphicItem {
    @discardableResult func modifier(_ modifier: NeumorphicItemModifier) -> Self {
        let stateModifier = StateModifier(state: .normal, modifier: modifier)
        stateModifiers.append(stateModifier)
        setNeedsModify()
        return self
    }
    
    func remove(modifier: NeumorphicItemModifier) {
        guard let modifierIndex = stateModifiers.firstIndex(where: { $0.modifier === modifier }) else { return }
        stateModifiers.remove(at: modifierIndex)
        modifier.purge()
        setNeedsModify()
    }
    
    func removeAllModifiers() {
        stateModifiers.forEach { $0.modifier.purge() }
        stateModifiers = []
        setNeedsModify()
    }
    
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
    
    /// Updates modifiers.
    ///
    /// You should not call this method directly. If you want to force a modifiers update, call the `setNeedsModify()` method instead to do so prior to the next drawing update.
    /// If you want to update the modifiers of your views immediately, call the `modifyIfNeeded()` method.
    func modifySubviews() {
        applyNeumorphism()
        for subview in subviews {
            guard let subitem = subview as? NeumorphicItem else { continue }
            subitem.modifySubviews()
        }
    }
    
    private func applyNeumorphism() {
        let revertedModifiers = applyModifiers()
        revertedModifiers.forEach { $0.purge() }
    }
}

public extension NeumorphicItem where Self: UIControl {
    @discardableResult func modifier(_ modifier: NeumorphicItemModifier, state: UIControl.State) -> Self {
        let stateModifier = StateModifier(state: state, modifier: modifier)
        stateModifiers.append(stateModifier)
        setNeedsModify()
        return self
    }
}

// MARK: - Private
private struct AssociatedObjectKey {
    static var stateModifiers = "neumorphicItem_stateModifiers"
    static var needsModify = "neumorphicItem_needsModify"
}

private struct StateModifier {
    let state: UIControl.State
    let modifier: NeumorphicItemModifier
}

extension NeumorphicItem {
    private var stateModifiers: [StateModifier] {
        get { objc_getAssociatedObject(self, &AssociatedObjectKey.stateModifiers) as? [StateModifier] ?? [] }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectKey.stateModifiers, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            setNeedsModify()
        }
    }
    
    private var needsModify: Bool {
        get { objc_getAssociatedObject(self, &AssociatedObjectKey.needsModify) as? Bool == true }
        set { objc_setAssociatedObject(self, &AssociatedObjectKey.needsModify, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    @discardableResult func applyModifiers() -> [NeumorphicItemModifier] {
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
                stateModifier.modifier.modify(self, roundedCorners: cornerMaskRadii.0, cornerRadii: cornerMaskRadii.1)
            default:
                stateModifier.modifier.revert(self)
                revertedModifiers.append(stateModifier.modifier)
            }
        }
        
        return revertedModifiers
    }
}
