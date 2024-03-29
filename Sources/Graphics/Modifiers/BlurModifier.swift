//
//  BlurModifier.swift
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

/// A modifier that allows to blur a graphics view.
public class BlurModifier: GraphicsItemModifier {
    
    /// The intensity of the blur effect. See [UIBlurEffect.Style](https://developer.apple.com/documentation/uikit/uiblureffect/style) for valid options.
    public let blurStyle: UIBlurEffect.Style
    
    /// The percentage of the blur effect. Values should be ranged from 0 to 1.
    public let blurIntensity: CGFloat
    
    /// The vibrancy effect for a specific blur effect.
    public let vibrancy: Vibrancy?
    
    public let allowsMultipleModifiers = false
    public let priority: GraphicsItemModifierPriority = .required
    
    private weak var blurEffectView: UIVisualEffectView?
    private weak var vibrancyView: UIVisualEffectView?
    
    private var intensityAnimator: UIViewPropertyAnimator?
    
    /// It creates a new blur modifier.
    ///
    /// - Parameters:
    ///   - blurStyle: The intensity of the blur effect. See [UIBlurEffect.Style](https://developer.apple.com/documentation/uikit/uiblureffect/style) for valid options.
    ///   - blurIntensity: The percentage of the blur effect. Values should be ranged from 0 to 1.
    ///   - vibrancy: The vibrancy effect for a specific blur effect.
    public init(blurStyle: UIBlurEffect.Style, blurIntensity: CGFloat = 1, vibrancy: Vibrancy? = nil) {
        self.blurStyle = blurStyle
        self.blurIntensity = blurIntensity
        self.vibrancy = vibrancy
    }
    
    public func modify(_ view: GraphicsItem, roundedCorners: UIRectCorner, cornerRadii: CGSize) {
        let blurView = prepareBlurEffectView(in: view)
        let effect = UIBlurEffect(style: blurStyle)
        let vibrancyEffect: UIVibrancyEffect?
        
        if let vibrancy = vibrancy {
            if #available(iOS 13.0, *), let style = vibrancy.style {
                vibrancyEffect = UIVibrancyEffect(blurEffect: effect, style: style)
            } else {
                vibrancyEffect = UIVibrancyEffect(blurEffect: effect)
            }
        } else {
            vibrancyEffect = nil
        }
    
        if let mask = view.contentView.layer.mask {
            blurView.layoutIfNeeded()
            blurView.layer.mask = mask
        } else {
            blurView.layer.cornerRadius = cornerRadii.width
            blurView.layer.maskedCorners = roundedCorners.cornerMask
        }
        
        intensityAnimator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [weak blurEffectView, weak vibrancyView] in
            blurEffectView?.effect = effect
            vibrancyView?.effect = vibrancyEffect
        }
        
        startAnimation()
    }
    
    public func revert(_ view: GraphicsItem) {
        guard let contentView = blurEffectView?.contentView.subviews.first else { return }
        view.addSubview(contentView)
    }
    
    public func purge() {
        intensityAnimator?.stopAnimation(true)
        intensityAnimator?.finishAnimation(at: .current)
        intensityAnimator = nil
        blurEffectView?.removeFromSuperview()
    }
    
    private func prepareBlurEffectView(in view: GraphicsItem) -> UIVisualEffectView {
        let backgroundView: UIVisualEffectView
        
        if let blurEffectView = blurEffectView {
            backgroundView = blurEffectView
        } else {
            backgroundView = UIVisualEffectView()
            backgroundView.clipsToBounds = true
            
            if vibrancy == nil {
                backgroundView.contentView.addSubview(view.contentView)
            } else {
                let vibrancyEffectView = UIVisualEffectView()
                vibrancyEffectView.contentView.addSubview(view.contentView)
                backgroundView.contentView.addSubview(vibrancyEffectView)
                self.vibrancyView = vibrancyEffectView
            }
        
            view.insertSubview(backgroundView, at: 0)
            backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.blurEffectView = backgroundView
        }
        
        backgroundView.frame = view.bounds
        view.contentView.frame = view.bounds
        
        return backgroundView
    }
    
    private func startAnimation() {
        DispatchQueue.main.async {
            self.intensityAnimator?.fractionComplete = self.blurIntensity
            DispatchQueue.main.async {
                self.intensityAnimator?.stopAnimation(true)
                self.intensityAnimator?.finishAnimation(at: .current)
            }
        }
    }
}

public extension BlurModifier {
    /// It represents the vibrancy style. Additional vibrancy styles available in iOS 13, intended for use with the "system material" UIBlurEffect styles.
    ///
    ///  ````
    ///  var vibrancy: Vibrancy?
    ///  vibrancy = nil
    ///  vibrancy = .default
    ///  vibrancy = .style(.label) // available on iOS 13.0
    ///
    ///  ````
    ///
    /// These vibrancy styles, combined with those blur effect styles, cause only the alpha component of the content
    /// to be used. Color information is ignored. (UIVibrancyEffectStyleLabel is an exception; it passes color through.)
    public struct Vibrancy {
        private let _style: Any?
        
        @available(iOS 13.0, *)
        var style: UIVibrancyEffectStyle? {
            _style as? UIVibrancyEffectStyle
        }
        
        private init() {
            _style = nil
        }
        
        @available(iOS 13.0, *)
        private init(style: UIVibrancyEffectStyle?) {
            _style = style
        }
        
        @available(iOS 13.0, *)
        static func style(_ style: UIVibrancyEffectStyle) -> Vibrancy {
            Vibrancy(style: style)
        }
    
        static let `default` = Vibrancy()
    }
}

public extension GraphicsItem {
    /// Applies a Gaussian blur to this view.
    ///
    /// - Parameters:
    ///   - style: The intensity of the blur effect. See [UIBlurEffect.Style](https://developer.apple.com/documentation/uikit/uiblureffect/style) for valid options.
    ///   - intensity: The percentage of the blur effect. Values should be ranged from 0 to 1.
    ///   - vibrancy: The vibrancy effect for a specific blur effect.
    /// - Returns: It returns the callers in order to apply multiple modifiers using the dot notation.
    @discardableResult func blur(style: UIBlurEffect.Style, intensity: CGFloat = 1, vibrancy: BlurModifier.Vibrancy? = nil) -> Self {
        let modifier = BlurModifier(blurStyle: style, blurIntensity: intensity, vibrancy: vibrancy)
        return self.modifier(modifier)
    }
}

public extension GraphicsItem where Self: UIControl {
    /// Applies a Gaussian blur to this view.
    /// - Parameters:
    ///   - style: The intensity of the blur effect. See [UIBlurEffect.Style](https://developer.apple.com/documentation/uikit/uiblureffect/style) for valid options.
    ///   - intensity: The percentage of the blur effect. Values should be ranged from 0 to 1.
    ///   - vibrancy: The vibrancy effect for a specific blur effect.
    ///   - state: The state that uses the specified modifier. The possible values are described in [UIControl.State](https://developer.apple.com/documentation/uikit/uicontrol/state).
    /// - Returns: It returns the callers in order to apply multiple modifiers using the dot notation.
    @discardableResult func blur(style: UIBlurEffect.Style, intensity: CGFloat = 1, vibrancy: BlurModifier.Vibrancy? = nil, state: State = .normal) -> Self {
        
        let modifier = BlurModifier(blurStyle: style, blurIntensity: intensity, vibrancy: vibrancy)
        return self.modifier(modifier, state: state)
    }
}

extension UIRectCorner {
    var cornerMask: CACornerMask {
        var cornerMask = CACornerMask()

        if contains(.topLeft) {
            cornerMask.insert(.layerMinXMinYCorner)
        }

        if contains(.bottomLeft) {
            cornerMask.insert(.layerMinXMaxYCorner)
        }

        if contains(.bottomRight) {
            cornerMask.insert(.layerMaxXMaxYCorner)
        }

        if contains(.topRight) {
            cornerMask.insert(.layerMaxXMinYCorner)
        }

        return cornerMask
    }
}
