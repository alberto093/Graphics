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
    var allowsMultipleModifiers: Bool { get }
    func modify(_ view: NeumorphicItem, roundedCorners: UIRectCorner, cornerRadii: CGSize, animation: NeumorphicItemAnimation?)
    func revert(_ view: NeumorphicItem, animation: NeumorphicItemAnimation?)
    func purge()
}

public extension NeumorphicItemModifier {
    func purge() { }
}

public protocol NeumorphicItemRoundingModifier: NeumorphicItemModifier {
    var roundedCorners: UIRectCorner { get }
    func cornerRadii(in view: NeumorphicItem) -> CGSize
    func modify(_ view: NeumorphicItem, animation: NeumorphicItemAnimation?)
}

public extension NeumorphicItemRoundingModifier {
    func modify(_ view: NeumorphicItem, roundedCorners: UIRectCorner, cornerRadii: CGSize, animation: NeumorphicItemAnimation?) {
        modify(view, animation: animation)
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
}

public extension NeumorphicItem where Self: UIControl {
    @discardableResult func modifier(_ modifier: NeumorphicItemModifier, state: State) -> Self {
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

struct StateModifier {
    let state: UIControl.State
    let modifier: NeumorphicItemModifier
}

extension NeumorphicItem {
    private(set) var stateModifiers: [StateModifier] {
        get { objc_getAssociatedObject(self, &AssociatedObjectKey.stateModifiers) as? [StateModifier] ?? [] }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectKey.stateModifiers, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            setNeedsModify()
        }
    }
    
    var needsModify: Bool {
        get { objc_getAssociatedObject(self, &AssociatedObjectKey.needsModify) as? Bool == true }
        set { objc_setAssociatedObject(self, &AssociatedObjectKey.needsModify, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
