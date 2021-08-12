//
//  GraphicsButton.swift
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

/// A control that executes your custom code in response to user interactions.
///
/// When you tap a button, or select a button that has focus, the button performs any actions attached to it. You communicate the purpose of a button using a text label, an image, or both. The appearance of buttons is configurable, so you can tint buttons or format titles to match the design of your app. You can add buttons to your interface programmatically or using Interface Builder.
/// When adding a button to your interface, perform the following steps:
/// Set the type of the button at creation time by adding a regular view by making white its backgroud color.
/// Supply a title string or image; size the button appropriately for your content.
/// Connect one or more action methods to the button.
/// Set up Auto Layout rules to govern the size and position of the button in your interface.
open class GraphicsButton: GraphicsNibControl {
    public override static var nib: UINib {
        UINib(nibName: GraphicsButton.identifier, bundle: Bundle.module)
    }

    @IBOutlet private weak var rootStackView: UIStackView!
    @IBOutlet private weak var mainStackView: UIStackView!
    @IBOutlet private weak var imageContainerView: GraphicsControl!
    @IBOutlet private weak var imageBackgroundView: GradientView!
    @IBOutlet private weak var imageMaskedView: GradientMaskedView!
    @IBOutlet public private(set) weak var imageView: UIImageView!
    @IBOutlet private weak var labelContainerView: GraphicsControl!
    @IBOutlet private weak var labelBackgroundView: GradientView!
    @IBOutlet private weak var labelMaskedView: GradientMaskedView!
    @IBOutlet public private(set) weak var titleLabel: UILabel!
    
    private var backgroundView: GradientView {
        // swiftlint:disable:next force_cast
        contentView as! GradientView
    }
    
    private var titles: [State.RawValue: String] = [:] {
        didSet { update() }
    }
    
    private var attributedTitles: [State.RawValue: NSAttributedString] = [:] {
        didSet { update() }
    }
    
    private var titleColors: [State.RawValue: UIColor] = [:] {
        didSet { update() }
    }

    private var titleGradients: [State.RawValue: (colors: [UIColor], locations: [Double]?)] = [:] {
        didSet { update() }
    }
    
    private var images: [State.RawValue: UIImage] = [:] {
        didSet { update() }
    }
    
    private var imageColors: [State.RawValue: UIColor] = [:] {
        didSet { update() }
    }
    
    private var imageGradients: [State.RawValue: (colors: [UIColor], locations: [Double]?)] = [:] {
        didSet { update() }
    }
    
    open var configuration = Configuration() {
        didSet { update() }
    }
    
    open override var contentVerticalAlignment: ContentVerticalAlignment {
        didSet { updateLayout() }
    }
    
    open override var contentHorizontalAlignment: ContentHorizontalAlignment {
        didSet { updateLayout() }
    }
    
    open var contentAlignment: NSLayoutConstraint.Axis = .horizontal {
        didSet { updateLayout() }
    }
    
    open var contentEdgeInsets: UIEdgeInsets = .zero {
        didSet { updateLayout() }
    }

    open var titleEdgeInsets: UIEdgeInsets = .zero {
        didSet { updateLayout() }
    }
    
    open var imageEdgeInsets: UIEdgeInsets = .zero {
        didSet { updateLayout() }
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        backgroundView.startPoint = CGPoint(x: 0, y: 0.5)
        backgroundView.endPoint = CGPoint(x: 1, y: 0.5)
        update()
    }
    
    private func update() {
        let image = self.image(for: state) ?? self.image(for: .normal)
        imageView.image = image
        imageContainerView.isHidden = image == nil

        titleLabel.numberOfLines = configuration.allowsMultilineTitle ? 0 : 1
        if let attributedText = attributedTitle(for: state) ?? attributedTitle(for: .normal) {
            titleLabel.text = nil
            titleLabel.attributedText = attributedText
            labelContainerView.isHidden = attributedText.string.isEmpty
        } else {
            let text = title(for: state) ?? title(for: .normal)
            titleLabel.attributedText = nil
            titleLabel.text = text
            labelContainerView.isHidden = text.isNilOrEmpty
        }
        
        backgroundView.colors = configuration.gradientColors(background: \.background)
        imageBackgroundView.colors = configuration.gradientColors(background: \.imageBackground)
        labelBackgroundView.colors = configuration.gradientColors(background: \.titleBackground)
        
        [imageMaskedView, labelMaskedView].forEach {
            $0?.startPoint = configuration.tintStartPoint
            $0?.endPoint = configuration.tintEndPoint
        }

        if let gradientColors = self.titleGradient(for: state) {
            labelMaskedView.colors = gradientColors.colors
            labelMaskedView.locations = gradientColors.locations
        } else if let titleColor = self.titleColor(for: state) {
            labelMaskedView.colors = [titleColor, titleColor]
            labelMaskedView.locations = nil
        } else if let gradientColors = self.titleGradient(for: .normal) {
            labelMaskedView.colors = gradientColors.colors
            labelMaskedView.locations = gradientColors.locations
        } else if let titleColor = self.titleColor(for: .normal) {
            labelMaskedView.colors = [titleColor, titleColor]
            labelMaskedView.locations = nil
        } else {
            labelMaskedView.colors = [tintColor, tintColor]
            labelMaskedView.locations = nil
        }
        
        if let gradientColors = self.imageGradient(for: state) {
            imageMaskedView.colors = gradientColors.colors
            imageMaskedView.locations = gradientColors.locations
        } else if let imageColor = self.imageColor(for: state) {
            imageMaskedView.colors = [imageColor, imageColor]
            imageMaskedView.locations = nil
        } else if let gradientColors = self.imageGradient(for: .normal) {
            imageMaskedView.colors = gradientColors.colors
            imageMaskedView.locations = gradientColors.locations
        } else if let imageColor = self.imageColor(for: .normal) {
            imageMaskedView.colors = [imageColor, imageColor]
            imageMaskedView.locations = nil
        } else {
            imageMaskedView.colors = [tintColor, tintColor]
            imageMaskedView.locations = nil
        }
    }
    
    private func updateLayout() {
        let verticalAlignment: UIStackView.Alignment
        
        switch contentVerticalAlignment {
        case .top:
            verticalAlignment = .top
        case .center:
            verticalAlignment = .center
        case .bottom:
            verticalAlignment = .bottom
        case .fill:
            verticalAlignment = .fill
        @unknown default:
            #if DEBUG
            fatalError("NeumorphicButton: \(self) does not support \(contentVerticalAlignment) vertical alignment.")
            #else
            verticalAlignment = .center
            #endif
        }
        
        let horizontalAlignment: UIStackView.Alignment
        let horizontalSemantic: UISemanticContentAttribute = contentHorizontalAlignment == .left || contentHorizontalAlignment == .right ? .forceLeftToRight : .unspecified
        
        switch contentHorizontalAlignment {
        case .leading, .left:
            horizontalAlignment = .leading
        case .center:
            horizontalAlignment = .center
        case .trailing, .right:
            horizontalAlignment = .trailing
        case .fill:
            horizontalAlignment = .fill
        @unknown default:
            #if DEBUG
            fatalError("NeumorphicButton: \(self) does not support \(effectiveContentHorizontalAlignment) horizontal alignment.")
            #else
            horizontalAlignment = .center
            #endif
        }
        
        switch contentAlignment {
        case .horizontal:
            rootStackView.axis = .vertical
            mainStackView.axis = .horizontal
            rootStackView.alignment = verticalAlignment
            mainStackView.alignment = horizontalAlignment
            rootStackView.semanticContentAttribute = .unspecified
            mainStackView.semanticContentAttribute = horizontalSemantic
        case .vertical:
            rootStackView.axis = .horizontal
            mainStackView.axis = .vertical
            rootStackView.alignment = horizontalAlignment
            mainStackView.alignment = verticalAlignment
            rootStackView.semanticContentAttribute = horizontalSemantic
            mainStackView.semanticContentAttribute = .unspecified
        @unknown default:
            #if DEBUG
            fatalError("NeumorphicButton: \(self) does not support \(contentAlignment) alignment.")
            #endif
        }

        backgroundView.layoutMargins = contentEdgeInsets
        imageMaskedView.layoutMargins = imageEdgeInsets
        labelMaskedView.layoutMargins = titleEdgeInsets
    }
    
    open override func stateDidChange() {
        super.stateDidChange()
        
        [imageContainerView, labelContainerView].forEach {
            $0?.isEnabled = isEnabled
            $0?.isSelected = isSelected
            $0?.isHighlighted = isHighlighted
        }
        
        titleLabel.isEnabled = isEnabled
        titleLabel.isHighlighted = isHighlighted
        update()
    }
}

extension GraphicsButton {
    public struct Configuration {
        public enum Background {
            case solid(UIColor)
            case gradient([UIColor])
        }
        
        public var tintStartPoint: CGPoint
        public var tintEndPoint: CGPoint
        public var background: Background
        public var imageBackground: Background
        public var titleBackground: Background
        public var allowsMultilineTitle: Bool
        
        public init(
            tintStartPoint: CGPoint = CGPoint(x: 0, y: 0.5),
            tintEndPoint: CGPoint = CGPoint(x: 1, y: 0.5),
            background: Background = .solid(.white),
            imageBackground: Background = .solid(.clear),
            titleBackground: Background = .solid(.clear),
            allowsMultilineTitle: Bool = false) {
            
            self.tintStartPoint = tintStartPoint
            self.tintEndPoint = tintEndPoint
            self.background = background
            self.imageBackground = imageBackground
            self.titleBackground = titleBackground
            self.allowsMultilineTitle = allowsMultilineTitle
        }
    }
    
    /// Sets the title to use for the specified state.
    ///
    /// Use this method to set the title for the button. The title you specify derives its formatting from the button’s associated label object. If you set both a title and an attributed title for the button, the button prefers the use of the attributed title over this one.
    ///
    /// At a minimum, you should set the value for the normal state. If you don’t specify a title for the other states, the button uses the title associated with the normal state. If you don’t set the value for normal, then the property defaults to a system value.
    ///
    /// - Parameters:
    ///   - title: The title to use for the specified state.
    ///   - state: The state that uses the specified title. The possible values are described in [UIControl.State](https://developer.apple.com/documentation/uikit/uicontrol/state).
    public func setTitle(_ title: String?, for state: State) {
        titles[state.rawValue] = title
    }
    
    /// Sets the styled title to use for the specified state.
    ///
    /// Use this method to set the title of the button, including any relevant formatting information. If you set both a title and an attributed title for the button, the button prefers the use of the attributed title.
    ///
    /// At a minimum, you should set the value for the normal state. If a title is not specified for a state, the default behavior is to use the title associated with the normal state. If the value for normal is not set, then the property defaults to a system value.
    /// - Parameters:
    ///   - title: The styled text string so use for the title.
    ///   - state: The state that uses the specified title. The possible values are described in [UIControl.State](https://developer.apple.com/documentation/uikit/uicontrol/state).
    public func setAttributedTitle(_ title: NSAttributedString?, for state: State) {
        attributedTitles[state.rawValue] = title
    }
    
    /// Sets the color of the title to use for the specified state.
    ///
    /// In general, if a property is not specified for a state, the default is to use the normal value. If the normal value is not set, then the property defaults to a system value.
    /// Therefore, at a minimum, you should set the value for the normal state.
    ///
    /// - Parameters:
    ///   - color: The color of the title to use for the specified state.
    ///   - state: The state that uses the specified color. The possible values are described in [UIControl.State](https://developer.apple.com/documentation/uikit/uicontrol/state).
    public func setTitleColor(_ color: UIColor?, for state: State) {
        titleColors[state.rawValue] = color
    }
    
    /// Sets the gradient of the title to use for the specified state.
    ///
    /// In general, if a property is not specified for a state, the default is to use the normal value. If the normal value is not set, then the property defaults to a system value.
    /// Therefore, at a minimum, you should set the value for the normal state.
    ///
    /// - Parameters:
    ///   - colors: An array of UIColor objects defining the color of each gradient stop.
    ///   - locations: An optional array of values (in range 0...1) defining the location of each gradient stop.
    ///   - state: The state that uses the specified color. The possible values are described in [UIControl.State](https://developer.apple.com/documentation/uikit/uicontrol/state).
    public func setTitleGradient(colors: [UIColor], locations: [Double]? = nil, for state: State) {
        titleGradients[state.rawValue] = (colors, locations)
    }
    
    /// Sets the image to use for the specified state.
    ///
    /// At a minimum, always set an image for the normal state when associating images to a button. If you don’t specify an image for the other states, the button uses the image associated with normal. If you don’t specify an image for the normal state, the button uses a system value.
    ///
    /// - Parameters:
    ///   - image: The image to use for the specified state.
    ///   - state: The state that uses the specified image. The values are described in [UIControl.State](https://developer.apple.com/documentation/uikit/uicontrol/state).
    public func setImage(_ image: UIImage?, for state: State) {
        images[state.rawValue] = image
    }
    
    /// Sets the color of the image to use for the specified state.
    ///
    /// In general, if a property is not specified for a state, the default is to use the normal value. If the normal value is not set, then the property defaults to a system value.
    /// Therefore, at a minimum, you should set the value for the normal state.
    ///
    /// - Parameters:
    ///   - color: The color of the image to use for the specified state.
    ///   - state: The state that uses the specified color. The possible values are described in [UIControl.State](https://developer.apple.com/documentation/uikit/uicontrol/state).
    public func setImageColor(_ color: UIColor?, for state: State) {
        imageColors[state.rawValue] = color
    }
    
    /// Sets the gradient of the image to use for the specified state.
    ///
    /// In general, if a property is not specified for a state, the default is to use the normal value. If the normal value is not set, then the property defaults to a system value.
    /// Therefore, at a minimum, you should set the value for the normal state.
    ///
    /// - Parameters:
    ///   - colors: An array of UIColor objects defining the color of each gradient stop.
    ///   - locations: An optional array of values (in range 0...1) defining the location of each gradient stop.
    ///   - state: The state that uses the specified color. The possible values are described in [UIControl.State](https://developer.apple.com/documentation/uikit/uicontrol/state).
    public func setImageGradient(colors: [UIColor], locations: [Double]? = nil, for state: State) {
        imageGradients[state.rawValue] = (colors, locations)
    }
    
    /// Returns the title associated with the specified state.
    ///
    /// - Parameter state: The state that uses the title. The possible values are described in [UIControl.State](https://developer.apple.com/documentation/uikit/uicontrol/state).
    /// - Returns: The title for the specified state. If no title has been set for the specific state, this method returns the title associated with the normal state.
    public func title(for state: State) -> String? {
        titles[state.rawValue]
    }
    
    /// Returns the styled title associated with the specified state.
    ///
    /// - Parameter state: The state that uses the styled title. The possible values are described in [UIControl.State](https://developer.apple.com/documentation/uikit/uicontrol/state).
    /// - Returns: The title for the specified state. If no attributed title has been set for the specific state, this method returns the attributed title associated with the normal state. If no attributed title has been set for normal, returns nil.
    public func attributedTitle(for state: State) -> NSAttributedString? {
        attributedTitles[state.rawValue]
    }
    
    /// Returns the title color used for a state.
    ///
    /// - Parameter state: The state that uses the title color. The possible values are described in [UIControl.State](https://developer.apple.com/documentation/uikit/uicontrol/state).
    /// - Returns: The color of the title for the specified state.
    public func titleColor(for state: State) -> UIColor? {
        titleColors[state.rawValue]
    }
    
    /// Returns the title gradient used for a state.
    ///
    /// - Parameter state: The state that uses the title gradient. The possible values are described in [UIControl.State](https://developer.apple.com/documentation/uikit/uicontrol/state).
    /// - Returns: The gradient of the title for the specified state.
    public func titleGradient(for state: State) -> (colors: [UIColor], locations: [Double]?)? {
        titleGradients[state.rawValue]
    }
    
    /// Returns the image used for a button state.
    ///
    /// - Parameter state: The state that uses the image. Possible values are described in [UIControl.State](https://developer.apple.com/documentation/uikit/uicontrol/state).
    /// - Returns: The image used for the specified state.
    public func image(for state: State) -> UIImage? {
        images[state.rawValue]
    }
    
    /// Returns the image color used for a state.
    ///
    /// - Parameter state: The state that uses the image color. The possible values are described in [UIControl.State](https://developer.apple.com/documentation/uikit/uicontrol/state).
    /// - Returns: The color of the image for the specified state.
    public func imageColor(for state: State) -> UIColor? {
        imageColors[state.rawValue]
    }

    /// Returns the image gradient used for a state.
    ///
    /// - Parameter state: The state that uses the image gradient. The possible values are described in [UIControl.State](https://developer.apple.com/documentation/uikit/uicontrol/state).
    /// - Returns: The gradient of the image for the specified state.
    public func imageGradient(for state: State) -> (colors: [UIColor], locations: [Double]?)? {
        imageGradients[state.rawValue]
    }
}

extension GraphicsButton.Configuration {
    func gradientColors(background: KeyPath<Self, Background>) -> [UIColor] {
        switch self[keyPath: background] {
        case .solid(let color):
            return [color, color]
        case .gradient(let colors):
            return colors
        }
    }
}

extension GraphicsButton {
    /// It represents the graphics container view of the button's image. It is useful to apply additional graphics modifiers.
    public var imageGraphicsItem: UIControl & GraphicsItem {
        imageContainerView
    }
    
    /// It represents the graphics container view of the button's title. It is useful to apply additional graphics modifiers.
    public var titleGraphicsItem: UIControl & GraphicsItem {
        labelContainerView
    }
}
