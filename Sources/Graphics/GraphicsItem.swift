//
//  GraphicsItem.swift
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

/// A set of methods that can make a custom object eligible to participate in Graphics.
///
/// If you are conforming directly with `GraphicsItem` (e.g. `UICollectionViewCell`) remember to call `modifySubviews()` in your `layoutSubviews()` implementation. Otherwise you can use the provided components like: `GraphicsView` and `GraphicsControl`.
///
/// ```
/// override func layoutSubviews() {
///     super.layoutSubviews()
///     modifySubviews()
/// }
/// ```
///
/// The view hierarchy should be
///
/// ````
/// | GraphicsItem (clear background color)
/// | | UIView (e.g. the content view)
/// ````
///
/// The must important thing is to layout the content view using autoresizing mask instead of autolayout. Otherwise some modifiers (e.g. blur modifier) should not work as expected
///
public protocol GraphicsItem: UIView {
    var contentView: UIView { get }
}

extension GraphicsItem {
    /// A view that some modifiers (e.g. blur) can add in the view tree above the graphics item and below its content view
    var backgroundView: UIView? {
        guard isBlurredBackground, let blurView = subviews.first as? UIVisualEffectView else { return nil }
        
        if let vibrancyView = blurView.contentView.subviews.first as? UIVisualEffectView {
            return vibrancyView.contentView
        } else {
            return blurView.contentView
        }
    }
}
