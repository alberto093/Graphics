//
//  GraphicsControl.swift
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

/// A default implementation of `GraphicsItem` that allows you to create a nib for a specified control.
///
/// You should design your component starting directly from the content view of the graphics item.
///
/// It provides a new method called `stateDidChange` that allows you to perform any additional actions.
@IBDesignable open class GraphicsNibControl: NibControl, GraphicsItem {
    public var contentView: UIView {
        nibView
    }
    
    override open var isEnabled: Bool {
        didSet {
            guard oldValue != isEnabled else { return }
            stateDidChange()
        }
    }
    
    override open var isSelected: Bool {
        didSet {
            guard oldValue != isSelected else { return }
            stateDidChange()
        }
    }
    
    override open var isHighlighted: Bool {
        didSet {
            guard oldValue != isHighlighted else { return }
            stateDidChange()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        modifySubviews()
    }
    
    /// Tells the control that its state changed.
    ///
    /// The default implementation of this method updates the graphics state. Subclasses can override it to perform additional actions when state changed.
    /// You should call super at some point in your implementation.
    open func stateDidChange() {
        setNeedsLayout()
    }
}

/// A subclass of `UIControl` that conforms to `GraphicsItem`.
///
/// You should design your component following the view hierarchy documented in `GraphicsItem` protocol. The default implementation of the content view requirement returns the first subview.
///
/// It provides a new method called `stateDidChange` that allows you to perform any additional actions.
open class GraphicsControl: UIControl, GraphicsItem {
    open var contentView: UIView {
        if let backgroundView = backgroundView {
            return backgroundView.subviews.first ?? self
        } else {
            return subviews.first ?? self
        }
    }
    
    override open var isEnabled: Bool {
        didSet {
            guard oldValue != isEnabled else { return }
            stateDidChange()
        }
    }
    
    override open var isSelected: Bool {
        didSet {
            guard oldValue != isSelected else { return }
            stateDidChange()
        }
    }
    
    override open var isHighlighted: Bool {
        didSet {
            guard oldValue != isHighlighted else { return }
            stateDidChange()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        modifySubviews()
    }
    
    /// Tells the control that its state changed.
    ///
    /// The default implementation of this method updates the graphics state. Subclasses can override it to perform additional actions when state changed.
    /// You should call super at some point in your implementation.
    open func stateDidChange() {
        setNeedsLayout()
    }
}
