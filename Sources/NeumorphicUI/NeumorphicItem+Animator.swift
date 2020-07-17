//
//  NeumorphicItem+Animator.swift
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
public protocol NeumorphicItemAnimator: class {
    func animate(animations: @escaping () -> Void, completion: @escaping () -> Void)
}

public extension NeumorphicItem {
    @discardableResult func animator(_ animator: NeumorphicItemAnimator) -> Self {
        animators.append(animator)
        return self
    }
    
    func remove(animator: NeumorphicItemAnimator) {
        guard let animatorIndex = animators.firstIndex(where: { $0 === animator }) else { return }
        animators.remove(at: animatorIndex)
    }
    
    func setNeedsAnimate() {
        guard shouldAnimateModifiers != false else { return }
        shouldAnimateModifiers = false
        DispatchQueue.main.async {
            self.shouldAnimateModifiers = true
            guard self.isAnimationEnabled else { return }
            self.layoutIfNeeded()
            self.animateModifiers()
        }
    }
}

// MARK: - Private
private struct AssociatedObjectKey {
    static var animatorsCache = "neumorphicItem_animators"
    static var shouldAnimateModifiers = "neumorphicItem_shouldAnimateModifiers"
}

extension NeumorphicItem {
    private var animators: [NeumorphicItemAnimator] {
        get { objc_getAssociatedObject(self, &AssociatedObjectKey.animatorsCache) as? [NeumorphicItemAnimator] ?? [] }
        set { objc_setAssociatedObject(self, &AssociatedObjectKey.animatorsCache, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    private var shouldAnimateModifiers: Bool? {
        get { objc_getAssociatedObject(self, &AssociatedObjectKey.shouldAnimateModifiers) as? Bool }
        set { objc_setAssociatedObject(self, &AssociatedObjectKey.shouldAnimateModifiers, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    var isAnimationEnabled: Bool {
        shouldAnimateModifiers != nil && !animators.isEmpty
    }
    
    private func animateModifiers() {
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
