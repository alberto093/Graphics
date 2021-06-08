//
//  UIView+Autolayout.swift
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

@objc public extension UIView {
    /**
     Adds Autolayout constraints to fill `view` with `self`
     
     - parameter view: the UIView to fill
     - parameter insets: insets of `self` respect to `view`
     - parameter useSafeArea: if true use the safe area anchors
     - precondition: `self` and `view` must be in the same view hierachy
     */
    func fill(view: UIView, insets: UIEdgeInsets = .zero, useSafeArea: Bool = true) {
        translatesAutoresizingMaskIntoConstraints = false
        let leading = self.leadingAnchor.constraint(equalTo: useSafeArea ? view.safeAreaLayoutGuide.leadingAnchor : view.leadingAnchor, constant: insets.left)
        let bottom = self.bottomAnchor.constraint(equalTo: useSafeArea ? view.safeAreaLayoutGuide.bottomAnchor : view.bottomAnchor, constant: -insets.bottom)
        let trailing = self.trailingAnchor.constraint(equalTo: useSafeArea ? view.safeAreaLayoutGuide.trailingAnchor : view.trailingAnchor, constant: -insets.right)
        let top = self.topAnchor.constraint(equalTo: useSafeArea ? view.safeAreaLayoutGuide.topAnchor : view.topAnchor, constant: insets.top)
        NSLayoutConstraint.activate([leading, bottom, trailing, top])
    }

    /**
     Adds Autolayout constraints to center `self` inside `view`
     
     - parameter view: the UIView to center in
     - parameter offset: the absolute offset from the center of `view`
     - precondition: `self` and `view` must be in the same view hierachy
     */
    func center(in view: UIView, offset: CGPoint = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        let centerHorizontally = self.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: offset.x)
        let centerVertically = self.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: offset.y)
        NSLayoutConstraint.activate([centerHorizontally, centerVertically])
    }
    
    /**
     Adds Autolayout constraints to place `self` as header of `view`
     
     - parameter view: the UIView in which `self` will be placed as header
     - parameter insets: insets of `self` respect to `view`
     - parameter useSafeArea: if true use the safe area anchors
     - precondition: `self` and `view` must be in the same view hierachy
     */
    func asHeader(in view: UIView, insets: UIEdgeInsets = .zero, useSafeArea: Bool = true) {
        translatesAutoresizingMaskIntoConstraints = false
        let leading = self.leadingAnchor.constraint(equalTo: useSafeArea ? view.safeAreaLayoutGuide.leadingAnchor : view.leadingAnchor, constant: insets.left)
        let trailing = self.trailingAnchor.constraint(equalTo: useSafeArea ? view.safeAreaLayoutGuide.trailingAnchor : view.trailingAnchor, constant: -insets.right)
        let top = self.topAnchor.constraint(equalTo: useSafeArea ? view.safeAreaLayoutGuide.topAnchor : view.topAnchor, constant: insets.top)
        NSLayoutConstraint.activate([leading, trailing, top])
    }
    
    /**
     Adds Autolayout constraints to place `self` as footer of `view`
     
     - parameter view: the UIView in which `self` will be placed as footer
     - parameter insets: insets of `self` respect to `view`
     - parameter useSafeArea: if true use the safe area anchors
     - precondition: `self` and `view` must be in the same view hierachy
     */
    func asFooter(in view: UIView, insets: UIEdgeInsets = .zero, useSafeArea: Bool = true) {
        translatesAutoresizingMaskIntoConstraints = false
        let leading = self.leadingAnchor.constraint(equalTo: useSafeArea ? view.safeAreaLayoutGuide.leadingAnchor : view.leadingAnchor, constant: insets.left)
        let bottom = self.bottomAnchor.constraint(equalTo: useSafeArea ? view.safeAreaLayoutGuide.bottomAnchor : view.bottomAnchor, constant: -insets.bottom)
        let trailing = self.trailingAnchor.constraint(equalTo: useSafeArea ? view.safeAreaLayoutGuide.trailingAnchor : view.trailingAnchor, constant: -insets.right)
        NSLayoutConstraint.activate([leading, bottom, trailing])
    }
}
