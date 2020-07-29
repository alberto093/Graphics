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
}

// MARK: - Private
private struct AssociatedObjectKey {
    static var animatorsCache = "neumorphicItem_animators"
}

extension NeumorphicItem {
    private(set) var animators: [NeumorphicItemAnimator] {
        get { objc_getAssociatedObject(self, &AssociatedObjectKey.animatorsCache) as? [NeumorphicItemAnimator] ?? [] }
        set { objc_setAssociatedObject(self, &AssociatedObjectKey.animatorsCache, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
