//
//  GraphicsControl.swift
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
