//
//  ViewPropertyModifier.swift
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

/// A modifier that allows to change view properties.
public class ViewPropertyModifier<Item: GraphicsItem, T>: GraphicsItemModifier {
    
    /// A key path that indicates the property of the view to update.
    public let keyPath: ReferenceWritableKeyPath<Item, T>
    
    /// The new value to set for the item specified by keyPath.
    public let value: T
    
    /// An optional value that modifier set from the item specified by keyPath when It will be reverted.
    public var defaultValue: T?
    
    public let allowsMultipleModifiers = false
    
    /// It creates a new view property modifier.
    /// - Parameters:
    ///   - keyPath: A key path that indicates the property of the view to update.
    ///   - value: The new value to set for the item specified by keyPath.
    ///   - defaultValue: An optional value that modifier set from the item specified by keyPath when It will be reverted.
    public init(keyPath: ReferenceWritableKeyPath<Item, T>, value: T, defaultValue: T?) {
        self.keyPath = keyPath
        self.value = value
        self.defaultValue = defaultValue
    }
    
    public func modify(_ view: GraphicsItem, roundedCorners: UIRectCorner, cornerRadii: CGSize) {
        guard let view = view as? Item else { return }
        view[keyPath: keyPath] = value
    }
    
    public func revert(_ view: GraphicsItem) {
        guard let view = view as? Item, let defaultValue = defaultValue else { return }
        view[keyPath: keyPath] = defaultValue
    }
}

public extension GraphicsItem {
    /// Change the value of a view's property.
    ///
    /// - Parameters:
    ///   - keyPath: A key path that indicates the property of the view to update.
    ///   - value: The new value to set for the item specified by keyPath.
    ///   - defaultValue: An optional value that modifier set from the item specified by keyPath when It will be reverted.
    /// - Returns: It returns the callers in order to apply multiple modifiers using the dot notation.
    @discardableResult func property<T>(keyPath: ReferenceWritableKeyPath<Self, T>, value: T, defaultValue: T? = nil) -> Self {
        let modifier = ViewPropertyModifier(keyPath: keyPath, value: value, defaultValue: defaultValue)
        return self.modifier(modifier)
    }
}

public extension GraphicsItem where Self: UIControl {
    /// Change the value of a view's property.
    ///
    /// - Parameters:
    ///   - keyPath: A key path that indicates the property of the view to update.
    ///   - value: The new value to set for the item specified by keyPath.
    ///   - defaultValue: An optional value that modifier set from the item specified by keyPath when It will be reverted.
    ///   - state: The state that uses the specified modifier. The possible values are described in [UIControl.State](https://developer.apple.com/documentation/uikit/uicontrol/state).
    /// - Returns: It returns the callers in order to apply multiple modifiers using the dot notation.
    @discardableResult func property<T>(keyPath: ReferenceWritableKeyPath<Self, T>, value: T, defaultValue: T? = nil, state: State = .normal) -> Self {
        let modifier = ViewPropertyModifier(keyPath: keyPath, value: value, defaultValue: defaultValue)
        return self.modifier(modifier, state: state)
    }
}
