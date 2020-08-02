//
//  ViewPropertyModifier.swift
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

public class ViewPropertyModifier<Item: NeumorphicItem, T>: NeumorphicItemModifier {
    
    let keyPath: ReferenceWritableKeyPath<Item, T>
    let value: T
    let defaultValue: T
    
    public let allowsMultipleModifiers = false
    
    init(keyPath: ReferenceWritableKeyPath<Item, T>, value: T, defaultValue: T) {
        self.keyPath = keyPath
        self.value = value
        self.defaultValue = defaultValue
    }
    
    public func modify(_ view: NeumorphicItem, roundedCorners: UIRectCorner, cornerRadii: CGSize) {
        guard let view = view as? Item else { return }
        view[keyPath: keyPath] = value
    }
    
    public func revert(_ view: NeumorphicItem) {
        guard let view = view as? Item else { return }
        view[keyPath: keyPath] = defaultValue
    }
}

public extension NeumorphicItem {
    @discardableResult func property<T>(keyPath: ReferenceWritableKeyPath<Self, T>, value: T, defaultValue: T) -> Self {
        let modifier = ViewPropertyModifier(keyPath: keyPath, value: value, defaultValue: defaultValue)
        return self.modifier(modifier)
    }
}

public extension NeumorphicItem where Self: UIControl {
    @discardableResult func property<T>(keyPath: ReferenceWritableKeyPath<Self, T>, value: T, defaultValue: T, state: State = .normal) -> Self {
        let modifier = ViewPropertyModifier(keyPath: keyPath, value: value, defaultValue: defaultValue)
        return self.modifier(modifier, state: state)
    }
}
