//
//  GraphicsSegmentedControl.swift
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

#warning("Create segmented struct that allows to set both text and image for each segment. Create APIs like insertSegmentImage:at: and insertSegmentTitle:at:")

/// A horizontal control that consists of multiple segments, each segment functioning as a discrete button.
///
/// A segmented control can display a title (an NSString object) or an image (UIImage object). The `GraphicsSegmentedControl` object automatically resizes segments to fit proportionally within their superview unless they have a specific width set.
/// You register the target-action methods for a segmented.  control using the `valueChanged` constant as shown below.
///
///     segmentedControl.addTarget(self, action: "action:", forControlEvents: .valueChanged)
///
open class GraphicsSegmentedControl: NeumorphicControl {
    private struct Constants {
        static let segmentAnimationDuration: TimeInterval = 0.18
    }
    
    static let noSegment = -1
    
    private let segmentsStackView = UIStackView()
    
    private let toggleView: NeumorphicView = {
        let view = NeumorphicView()
        let contentView = UIView()
        view.addSubview(contentView)
        contentView.fill(view: view, insets: .zero, useSafeArea: false)
        return view
    }()
    
    private let lineView = GradientView()
    
    private let borderModifier = BorderModifier(border: .center, width: 1, color: .flat(.black))
    
    private var segments: [UILabel] {
        segmentsStackView.arrangedSubviews as? [UILabel] ?? []
    }
    
    private var titleTextAttributes: [State.RawValue: [NSAttributedString.Key: Any]] = [:] {
        didSet { update() }
    }
    
    private var widths: [Int: SegmentWidth] = [:] {
        didSet { update() }
    }
    
    var titles: [String] = [] {
        didSet {
            setupTitles()
            
            switch selectedSegmentIndex {
            case NeumorphicSegmentedControl.noSegment:
                update()
            default:
                selectedSegmentIndex = selectedSegmentIndex.clamped(to: titles.indices)
            }
        }
    }
    
    var configuration = Configuration() {
        didSet {
            removeAllModifiers()
            applyPreferredToggleModifiersIfNeeded()
            update()
        }
    }

    var selectedSegmentIndex = noSegment {
        didSet { update() }
    }
    
    private var highlightedSegmentIndex = noSegment {
        didSet { update() }
    }
    private var isTrackingToggle = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let segmentIndex = isTrackingToggle ? highlightedSegmentIndex : selectedSegmentIndex
        updateToggleView(segmentIndex: segmentIndex)
        updateLineView(segmentIndex: segmentIndex)
    }
    
    private func setup() {
        let contentView = UIView()

        [contentView, toggleView, segmentsStackView, lineView].forEach {
            $0.isUserInteractionEnabled = false
            addSubview($0)
        }
        
        contentView.fill(view: self, insets: .zero, useSafeArea: false)
        segmentsStackView.fill(view: contentView, insets: .zero, useSafeArea: false)
    
        toggleView
            .cornerRadius(radius: .circle)
            .modifier(borderModifier)
            .shadow(color: .darkShadow, offset: CGSize(width: 10, height: 10), blur: 30, opacity: 0.4)
            .shadow(color: .lightShadow, offset: CGSize(width: -10, height: -10), blur: 30, opacity: 1)
        
        lineView.startPoint = CGPoint(x: 0, y: 0.5)
        lineView.endPoint = CGPoint(x: 1, y: 0.5)
        
        update()
    }
    
    private func setupTitles() {
        segmentsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        titles.forEach { text in
            let label = UILabel()
            label.text = text
            label.textAlignment = .center
            segmentsStackView.addArrangedSubview(label)
        }
    }
    
    private func update() {
        contentView.backgroundColor = configuration.backgroundColor
        toggleView.isHidden = !configuration.isToggleEnabled
        toggleView.contentView.backgroundColor = configuration.backgroundColor
        borderModifier.color = .gradient(configuration: .init(colors: configuration.gradientColors, startPoint: CGPoint(x: 1, y: 0.5), endPoint: CGPoint(x: 0, y: 0.5)))
        lineView.colors = configuration.gradientColors
        lineView.isHidden = configuration.isToggleEnabled
        
        titles.enumerated().forEach {
            guard let label = segments[safe: $0.offset] else { return }
            
            let highlightedSelectedSegmentIndex = isTrackingToggle && highlightedSegmentIndex == selectedSegmentIndex ? selectedSegmentIndex : nil
            let selectedSegmentIndex = isTrackingToggle || self.selectedSegmentIndex == highlightedSelectedSegmentIndex ? nil : self.selectedSegmentIndex
            
            let segmentState: State
            switch $0.offset {
            case highlightedSegmentIndex:
                segmentState = .highlighted
            case highlightedSelectedSegmentIndex:
                segmentState = [.highlighted, .selected]
            case selectedSegmentIndex:
                segmentState = .selected
            default:
                segmentState = .normal
            }
            
            if let attributes = titleTextAttributes(for: segmentState) ?? titleTextAttributes(for: .normal) {
                label.attributedText = NSAttributedString(string: $0.element, attributes: attributes)
            } else {
                label.text = $0.element
            }
        }
        
        updateSegmentsLayout()
        setNeedsLayout()
    }
    
    private func updateSegmentsLayout() {
        let constraints: [NSLayoutConstraint]
        
        if widths.isEmpty {
            segmentsStackView.distribution = .fillEqually
            
            let segmentWidth = segments.reduce(0) { max($0, $1.intrinsicContentSize.width) } + configuration.segmentsPadding * 2
            constraints = segments.reduce(into: []) {
                let constraint = $1.widthAnchor.constraint(equalToConstant: segmentWidth)
                constraint.priority = .defaultHigh
                $0.append(constraint)
            }
        } else {
            segmentsStackView.distribution = .fill
            
            constraints = segments.enumerated().reduce(into: []) { constraints, tuple in
                let constraint: NSLayoutConstraint
                switch widths[tuple.offset] {
                case .equalTo(let width):
                    constraint = tuple.element.widthAnchor.constraint(equalToConstant: width)
                case .intrinsic, .none:
                    constraint = tuple.element.widthAnchor.constraint(equalToConstant: tuple.element.intrinsicContentSize.width + configuration.segmentsPadding * 2)
                }
                
                constraint.priority = .defaultHigh
                constraints.append(constraint)
            }
        }
        
        NSLayoutConstraint.activate(constraints)
        segmentsStackView.layoutIfNeeded()
    }
    
    private func updateToggleView(segmentIndex: Int) {
        guard configuration.isToggleEnabled, segments.indices.contains(segmentIndex) else { return }
        layoutIfNeeded()
        toggleView.frame.size.width = segments[segmentIndex].bounds.width
        toggleView.frame.size.height = bounds.height
        toggleView.frame.origin.x = segments[0..<segmentIndex].reduce(0) { $0 + $1.bounds.width }
    }
    
    private func updateLineView(segmentIndex: Int) {
        guard case .line(let lineConfiguration) = configuration.selectionStyle, segments.indices.contains(segmentIndex) else { return }
        
        layoutIfNeeded()
        lineView.frame.size.height = lineConfiguration.height
        
        switch (lineConfiguration.edge, lineConfiguration.position) {
        case (.top, .inner):
            lineView.frame.origin.y = 0
        case (.top, .center):
            lineView.frame.origin.y = -lineConfiguration.height / 2
        case (.top, .outer):
            lineView.frame.origin.y = -lineConfiguration.height
        case (.bottom, .inner):
            lineView.frame.origin.y = bounds.height - lineConfiguration.height
        case (.bottom, .center):
            lineView.frame.origin.y = bounds.height - lineConfiguration.height / 2
        case (.bottom, .outer):
            lineView.frame.origin.y = bounds.height
        }
        
        let lineWidth: CGFloat
        switch lineConfiguration.width {
        case .fill(let padding):
            let preferredWidth = segments[segmentIndex].bounds.width - padding * 2
            lineWidth = min(preferredWidth, 0)
        case .proportional(let padding):
            let maximumWidth = segments.reduce(0) { max($0, $1.intrinsicContentSize.width) }
            lineWidth = maximumWidth - padding * 2
        case .equalTo(let value):
            lineWidth = min(value, segments[segmentIndex].bounds.width)
        }
        
        lineView.frame.size.width = lineWidth
        
        let offsetX = segments[0..<segmentIndex].reduce(0) { $0 + $1.bounds.width }
        let segmentWidth = segments[segmentIndex].bounds.width
        lineView.frame.origin.x = offsetX + (segmentWidth - lineWidth) / 2
        
        lineView.layer.cornerRadius = min(lineWidth, lineConfiguration.height) / 2
    }
    
    private func applyPreferredToggleModifiersIfNeeded() {
        guard configuration.isToggleEnabled else { return }
        shadow(.inner, color: .lightShadow, offset: CGSize(width: -10, height: -10), blur: 10, opacity: 0.7)
        shadow(.inner, color: .darkShadow, offset: CGSize(width: 10, height: 10), blur: 10, opacity: 0.2)
        cornerRadius(radius: .circle)
    }
    
    private func animateToggleTracking() {
        UIView.animate(
            withDuration: Constants.segmentAnimationDuration,
            delay: 0,
            options: [.allowUserInteraction, .curveEaseOut],
            animations: { self.layoutIfNeeded() })
    }
    
    private func indexForSegment(at pointX: CGFloat) -> Int {
        for (index, segment) in segments.enumerated() {
            let segmentFrame = segment.convert(segment.bounds, to: self)
            if (segmentFrame.minX..<segmentFrame.maxX).contains(pointX) {
                return index
            }
        }
        
        return NeumorphicSegmentedControl.noSegment
    }

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        guard super.beginTracking(touch, with: event) else { return false }

        let touchLocation = touch.location(in: self)
        let trackingSegmentIndex = indexForSegment(at: touchLocation.x)
        isTrackingToggle = trackingSegmentIndex == selectedSegmentIndex
        highlightedSegmentIndex = trackingSegmentIndex
        return true
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        guard super.continueTracking(touch, with: event) else { return false }
        let touchLocation = touch.location(in: self)
        let highlightingSegmentIndex = isHighlighted || isTrackingToggle ? indexForSegment(at: touchLocation.x) : NeumorphicSegmentedControl.noSegment
        
        if highlightingSegmentIndex != highlightedSegmentIndex, !isTrackingToggle || segments.indices.contains(highlightingSegmentIndex) {
            highlightedSegmentIndex = highlightingSegmentIndex
            animateToggleTracking()
        }
        
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        let isValueChanged = selectedSegmentIndex != highlightedSegmentIndex && (isHighlighted || isTrackingToggle)
        isTrackingToggle = false
        
        guard isValueChanged else { return }
        selectedSegmentIndex = highlightedSegmentIndex
        animateToggleTracking()
        
        if isValueChanged {
            sendActions(for: .valueChanged)
        }
    }
}

extension NeumorphicSegmentedControl {
    enum SegmentWidth {
        case intrinsic
        case equalTo(width: CGFloat)
    }
    
    enum SelectionStyle {
        case toggle
        case line(configuration: LineConfiguration)
    }
    
    struct LineConfiguration {
        //swiftlint:disable nesting
        enum Width {
            case fill(padding: CGFloat)
            case proportional(padding: CGFloat)
            case equalTo(CGFloat)
        }
        
        enum Edge {
            case top
            case bottom
        }
        
        enum Position {
            case inner
            case center
            case outer
        }
        //swiftlint:enable nesting
        
        let width: Width
        let height: CGFloat
        let edge: Edge
        let position: Position
        
        init(width: Width = .proportional(padding: 0), height: CGFloat = 2, edge: Edge = .bottom, position: Position = .center) {
            self.width = width
            self.height = height
            self.edge = edge
            self.position = position
        }
    }
    
    struct Configuration {
        var primaryColor: UIColor
        var secondaryColor: UIColor?
        var backgroundColor: UIColor
        var segmentsPadding: CGFloat
        var selectionStyle: SelectionStyle
        
        var gradientColors: [UIColor] {
            [primaryColor, secondaryColor ?? primaryColor]
        }
        
        fileprivate var isToggleEnabled: Bool {
            switch selectionStyle {
            case .toggle:
                return true
            case .line:
                return false
            }
        }

        init(
            primaryColor: UIColor = .appBackground,
            secondaryColor: UIColor? = nil,
            backgroundColor: UIColor = .appBackground,
            segmentsPadding: CGFloat = 30,
            selectionStyle: SelectionStyle = .toggle) {
            
            self.primaryColor = primaryColor
            self.secondaryColor = secondaryColor
            self.backgroundColor = backgroundColor
            self.segmentsPadding = segmentsPadding
            self.selectionStyle = selectionStyle
        }
    }
    
    func setTitleTextAttributes(_ attributes: [NSAttributedString.Key: Any]?, for state: State) {
        titleTextAttributes[state.rawValue] = attributes ?? [:]
    }

    func titleTextAttributes(for state: UIControl.State) -> [NSAttributedString.Key: Any]? {
        guard let attributes = titleTextAttributes[state.rawValue] else { return nil }
        return attributes.isEmpty ? nil : attributes
    }
    
    func setWidth(_ width: SegmentWidth, forSegmentAt segment: Int) {
        widths[segment] = width
    }

    func widthForSegment(at segment: Int) -> SegmentWidth? {
        widths[segment]
    }
}
