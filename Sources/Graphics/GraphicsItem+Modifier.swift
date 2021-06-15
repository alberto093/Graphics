//
//  GraphicsItem+Modifier.swift
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

// MARK: - Public
/// A modifier that you apply to a `UIView` or a `UIControl`, producing a different version of the original value.
///
/// Adopt the ``GraphicsItemModifier`` protocol when you want to create a reusable
/// modifier that you can apply to any view.
///
/// You can apply ``modifier(_:)`` directly to a view, but a more common and
/// idiomatic approach uses ``modifier(_:)`` to define an extension to
/// ``GraphicsItem`` itself that incorporates the view modifier:
///
///     extension GraphicsItem {
///         @discardableResult func customModifier() -> Self {
///             modifier(CustomModifier())
///         }
///     }
///
/// You can then apply the bordered caption to any view, similar to this:
///
///     UILabel()
///         .shadow()
///         .customModifier()
public protocol GraphicsItemModifier: AnyObject {
    
    /// The priority of the modifier.
    ///
    /// By default, all modifiers have high priority.
    /// Higher priority constraints are satisfied before lower priority constraints.
    /// Priorities may not change from nonrequired to required, or from required to nonrequired.Changing from one optional priority to another optional priority is allowed even after the modifier is applied on a view.
    /// Priorities must be greater than 0 and less than or equal to required.
    var priority: GraphicsItemModifierPriority { get }
    
    /// A Boolean value specifying whether the view can applies multiple modifiers for the same modifier's type.
    ///
    /// When this property is set to `true`, the modifiers system allows the view to be modified using all the same type modifiers provided.
    ///
    /// When the property is set to `false`, the modifiers system applies the highest priority modifier and reverts the others.
    var allowsMultipleModifiers: Bool { get }
    
    /// The core function in which modifier is applied the to the given view.
    ///
    /// - Parameters:
    ///   - view: The graphics view in which modifier must be applied.
    ///   - roundedCorners: The corners applied by the corner radius modifier. Use this parameter to round only a subset of the corners of the rectangle.
    ///   - cornerRadii: The radius of each corner oval.
    ///
    /// If the modifier needs to be rounded you should use the two parameters provided or better you firstly need to check if the content view of the graphics item was masked, then use it. Otherwise you can ignore this two parameters.
    ///
    /// The implementation can be animated using an `animator`.
    func modify(_ view: GraphicsItem, roundedCorners: UIRectCorner, cornerRadii: CGSize)
    
    /// Remove the effects of the modifier.
    ///
    /// - Parameter view: The graphics view in which modifier was applied.
    ///
    /// The implementation can be animated using an `animator`.
    func revert(_ view: GraphicsItem)
    
    /// This method clean and reset any stored properties in order to reset the state of view at its original value.
    ///
    /// Modifier system calls this method at the end of animation in order to allows you to fine control the animation in the `revert(_:)` method.
    ///
    /// he default implementation of this method does nothing.
    func purge()
}

public extension GraphicsItemModifier {
    var priority: GraphicsItemModifierPriority {
        .high
    }
    
    func purge() { }
}

/// A particular `GraphicsItemModifier` that allows to clips the view to its bounding frame.
public protocol GraphicsItemRoundingModifier: GraphicsItemModifier {
    /// Defines which of the four corners receives the masking. Defaults to all four corners.
    var roundedCorners: UIRectCorner { get }
    
    /// It returns the radius of each corner oval.
    func cornerRadii(in view: GraphicsItem) -> CGSize
    
    /// The core function in which modifier is applied the to the given view.
    ///
    /// - Parameters:
    ///   - view: The graphics view in which modifier must be applied.
    ///
    /// The implementation can be animated using an `animator`.
    func modify(_ view: GraphicsItem)
}

public extension GraphicsItemRoundingModifier {
    func modify(_ view: GraphicsItem, roundedCorners: UIRectCorner, cornerRadii: CGSize) {
        modify(view)
    }
}

/// The layout priority is used to indicate to the modifiers-based layout system which modifiers are more important.
public struct GraphicsItemModifierPriority: Hashable, Equatable, RawRepresentable {
    /// A required modifier.
    ///
    /// Do not specify a modifier that exceeds this number.
    public static let required = GraphicsItemModifierPriority(1000)
    
    /// The priority level with which a view applies its modifier.
    public static let high = GraphicsItemModifierPriority(750)
    
    /// The priority level with which a view applies its modifier.
    public static let low = GraphicsItemModifierPriority(250)
    
    public let rawValue: Int
    private let valueRange = 0...1000
    
    public init(_ rawValue: Int) {
        self.rawValue = Swift.min(Swift.max(rawValue, valueRange.lowerBound), valueRange.upperBound)
    }

    public init(rawValue: Int) {
        self.rawValue = Swift.min(Swift.max(rawValue, valueRange.lowerBound), valueRange.upperBound)
    }
}

public extension GraphicsItem {
    /// Applies a modifier to a graphics item and returns the callers.
    ///
    /// Use this modifier to combine a ``GraphicsItem`` and a ``GraphicsItemModifier``, to update the view layout.
    ///
    /// - Parameter modifier: The modifier to apply to this view.
    /// - Returns: It returns the callers in order to apply multiple modifiers using the dot notation.
    ///
    /// This method invalidates the current layout of the receiver and triggers a layout update during the next update cycle.
    @discardableResult func modifier(_ modifier: GraphicsItemModifier) -> Self {
        let stateModifier = StateModifier(state: .normal, modifier: modifier)
        stateModifiers.append(stateModifier)
        setNeedsLayout()
        return self
    }
    
    /// Removes a modifier from a graphics item.
    ///
    /// - Parameter modifier: The modifier to remove from this view.
    ///
    /// This method invalidates the current layout of the receiver and triggers a layout update during the next update cycle.
    func remove(modifier: GraphicsItemModifier) {
        guard let modifierIndex = stateModifiers.firstIndex(where: { $0.modifier === modifier }) else { return }
        stateModifiers.remove(at: modifierIndex)
        modifier.purge()
        setNeedsLayout()
    }
    
    /// Remove all modifiers from a graphics item.
    ///
    /// This method invalidates the current layout of the receiver and triggers a layout update during the next update cycle.
    func removeAllModifiers() {
        stateModifiers.forEach { $0.modifier.purge() }
        stateModifiers = []
        setNeedsLayout()
    }
}

public extension GraphicsItem where Self: UIControl {
    /// Applies a modifier to a graphics item and returns the callers.
    ///
    /// Use this modifier to combine a ``GraphicsItem`` and a ``GraphicsItemModifier``, to update the view layout.
    ///
    /// - Parameters:
    ///   - modifier: The modifier to apply to this view.
    ///   - state: The state that uses the specified modifier. The possible values are described in [UIControl.State](https://developer.apple.com/documentation/uikit/uicontrol/state).
    /// - Returns: It returns the callers in order to apply multiple modifiers using the dot notation.
    ///
    /// This method invalidates the current layout of the receiver and triggers a layout update during the next update cycle.
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
    static var needsSorting = "neumorphicItem_needsSorting"
}

struct StateModifier {
    let state: UIControl.State
    let modifier: GraphicsItemModifier
}

extension GraphicsItem {
    var stateModifiers: [StateModifier] {
        get { objc_getAssociatedObject(self, &AssociatedObjectKey.stateModifiers) as? [StateModifier] ?? [] }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectKey.stateModifiers, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            needsSorting = true
        }
    }
    
    var needsSorting: Bool {
        get { objc_getAssociatedObject(self, &AssociatedObjectKey.needsSorting) as? Bool == true }
        set { objc_setAssociatedObject(self, &AssociatedObjectKey.needsSorting, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
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
