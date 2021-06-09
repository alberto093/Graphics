//
//  GraphicsItem+Modifier.swift
//
//  Copyright © 2020 Graphics - Alberto Saltarelli
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
public protocol GraphicsItemModifier: AnyObject {
    var allowsMultipleModifiers: Bool { get }
    func modify(_ view: GraphicsItem, roundedCorners: UIRectCorner, cornerRadii: CGSize)
    func revert(_ view: GraphicsItem)
    func purge()
}

public extension GraphicsItemModifier {
    func purge() { }
}

public protocol GraphicsItemRoundingModifier: GraphicsItemModifier {
    var roundedCorners: UIRectCorner { get }
    func cornerRadii(in view: GraphicsItem) -> CGSize
    func modify(_ view: GraphicsItem)
}

public extension GraphicsItemRoundingModifier {
    func modify(_ view: GraphicsItem, roundedCorners: UIRectCorner, cornerRadii: CGSize) {
        modify(view)
    }
}

public extension GraphicsItem {
    @discardableResult func modifier(_ modifier: GraphicsItemModifier) -> Self {
        let stateModifier = StateModifier(state: .normal, modifier: modifier)
        stateModifiers.append(stateModifier)
        setNeedsLayout()
        return self
    }
    
    func remove(modifier: GraphicsItemModifier) {
        guard let modifierIndex = stateModifiers.firstIndex(where: { $0.modifier === modifier }) else { return }
        stateModifiers.remove(at: modifierIndex)
        modifier.purge()
        setNeedsLayout()
    }
    
    func removeAllModifiers() {
        stateModifiers.forEach { $0.modifier.purge() }
        stateModifiers = []
        setNeedsLayout()
    }
}

public extension GraphicsItem where Self: UIControl {
    @discardableResult func modifier(_ modifier: GraphicsItemModifier, state: State) -> Self {
        let stateModifier = StateModifier(state: state, modifier: modifier)
        stateModifiers.append(stateModifier)
        setNeedsLayout()
        return self
    }
}

// MARK: - Private
private struct AssociatedObjectKey {
    static var stateModifiers = "graphicsItem_stateModifiers"
}

struct StateModifier {
    let state: UIControl.State
    let modifier: GraphicsItemModifier
}

extension GraphicsItem {
    private(set) var stateModifiers: [StateModifier] {
        get { objc_getAssociatedObject(self, &AssociatedObjectKey.stateModifiers) as? [StateModifier] ?? [] }
        set { objc_setAssociatedObject(self, &AssociatedObjectKey.stateModifiers, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    var isBlurredBackground: Bool {
        stateModifiers.contains { $0.modifier is BlurModifier }
    }
}

extension GraphicsItem where Self: UIControl {
    var isBlurredBackground: Bool {
        stateModifiers.contains { $0.modifier is BlurModifier && state.contains($0.state) }
    }
}
