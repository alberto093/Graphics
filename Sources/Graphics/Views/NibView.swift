//
//  NibView.swift
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

/**
 An abstract class that allows to load view from nib.
 A NibView sublcass can be instantiated programmatically or embeded inside a Storyboard.
 
 To work properly a ``NibView`` subclass must satisfy the following conditions:
 - The the nib name must match the subclass name
 - The view inside the nib should be a regular UIView
 - The file's owner of the nib must be the subclass type
 */
@IBDesignable open class NibView: UIView {
    /// It returns the real nib view.
    ///
    /// You should use this view to setup the user interaction (e.g. UIGestureRecognizer).
    public private(set) var nibView: UIView!

    public override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
        awakeFromNib()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib()
    }
    
    private func loadNib() {
        translatesAutoresizingMaskIntoConstraints = false
        //swiftlint:disable:next force_cast
        nibView = (type(of: self).nib.instantiate(withOwner: self, options: nil).first as! UIView)
        addSubview(nibView)
        
        nibView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nibView.leadingAnchor.constraint(equalTo: leadingAnchor),
            nibView.bottomAnchor.constraint(equalTo: bottomAnchor),
            nibView.trailingAnchor.constraint(equalTo: trailingAnchor),
            nibView.topAnchor.constraint(equalTo: topAnchor)])
    }
    
    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        loadNib()
    }
}
