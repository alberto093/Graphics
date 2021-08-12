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

/// A horizontal control that consists of multiple segments, each segment functioning as a discrete button.
///
/// A segmented control can display a title (an NSString object) or an image (UIImage object). The `GraphicsSegmentedControl` object automatically resizes segments to fit proportionally within their superview unless they have a specific width set.
/// You register the target-action methods for a segmented control using the `valueChanged` constant as shown below.
///
///     segmentedControl.addTarget(self, action: "action:", forControlEvents: .valueChanged)
///
open class GraphicsSegmentedControl: GraphicsControl {
    private struct Constants {
        static let segmentAnimationDuration: TimeInterval = 0.18
    }
    
    static let noSegment = -1
    
    private let segmentsStackView = UIStackView()
    
    private let toggleView: GraphicsView = {
        let view = GraphicsView()
        let contentView = UIView()
        view.addSubview(contentView)
        contentView.fill(view: view, insets: .zero, useSafeArea: false)
        return view
    }()
    
    private let lineView = GradientView()
    
    private var segments: [UILabel] {
        segmentsStackView.arrangedSubviews as? [UILabel] ?? []
    }
    
    private var titleTextAttributes: [State.RawValue: [NSAttributedString.Key: Any]] = [:] {
        didSet { update() }
    }
    
    private var widths: [Int: SegmentWidth] = [:] {
        didSet { update() }
    }
    
    public var toggleItemInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) {
        didSet {
            updateToggleView(segmentIndex: selectedSegmentIndex)
        }
    }
    
    open var titles: [String] = [] {
        didSet {
            setupTitles()
            
            switch selectedSegmentIndex {
            case GraphicsSegmentedControl.noSegment,
                 _ where titles.isEmpty:
                update()
            default:
                selectedSegmentIndex = selectedSegmentIndex < titles.count ? selectedSegmentIndex : 0
            }
        }
    }
    
    open var configuration = Configuration() {
        didSet {
            removeAllModifiers()
            update()
        }
    }

    open var selectedSegmentIndex = noSegment {
        didSet { update() }
    }
    
    private var highlightedSegmentIndex = noSegment {
        didSet { update() }
    }
    
    private var isTrackingToggle = false
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    open override func layoutSubviews() {
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
        
        switch configuration.selectionStyle {
        case .toggle(let backgroundColor):
            toggleView.isHidden = false
            lineView.isHidden = true
            toggleView.contentView.backgroundColor = backgroundColor
        case .line(_, let colors):
            lineView.isHidden = false
            toggleView.isHidden = true
            lineView.colors = colors.count == 1 ? [colors[0], colors[0]] : colors
        }
        
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
        toggleView.frame.size.width = segments[segmentIndex].bounds.width - (toggleItemInsets.left + toggleItemInsets.right)
        toggleView.frame.size.height = bounds.height - (toggleItemInsets.top + toggleItemInsets.bottom)
        toggleView.frame.origin.x = segments[0..<segmentIndex].reduce(0) { $0 + $1.bounds.width } + toggleItemInsets.left
        toggleView.frame.origin.y = toggleItemInsets.top
    }
    
    private func updateLineView(segmentIndex: Int) {
        guard case .line(let lineConfiguration, _) = configuration.selectionStyle, segments.indices.contains(segmentIndex) else { return }
        
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
        
        return GraphicsSegmentedControl.noSegment
    }

    open override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        guard super.beginTracking(touch, with: event) else { return false }

        let touchLocation = touch.location(in: self)
        let trackingSegmentIndex = indexForSegment(at: touchLocation.x)
        isTrackingToggle = trackingSegmentIndex == selectedSegmentIndex
        highlightedSegmentIndex = trackingSegmentIndex
        return true
    }
    
    open override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        guard super.continueTracking(touch, with: event) else { return false }
        let touchLocation = touch.location(in: self)
        let highlightingSegmentIndex = isHighlighted || isTrackingToggle ? indexForSegment(at: touchLocation.x) : GraphicsSegmentedControl.noSegment
        
        if highlightingSegmentIndex != highlightedSegmentIndex, !isTrackingToggle || segments.indices.contains(highlightingSegmentIndex) {
            highlightedSegmentIndex = highlightingSegmentIndex
            animateToggleTracking()
        }
        
        return true
    }
    
    open override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
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

public extension GraphicsSegmentedControl {
    enum SegmentWidth {
        case intrinsic
        case equalTo(width: CGFloat)
    }
    
    enum SelectionStyle {
        case toggle(background: UIColor)
        case line(configuration: LineConfiguration, colors: [UIColor])
    }
    
    struct LineConfiguration {
        public enum Width {
            case fill(padding: CGFloat)
            case proportional(padding: CGFloat)
            case equalTo(CGFloat)
        }
        
        public enum Edge {
            case top
            case bottom
        }
        
        public enum Position {
            case inner
            case center
            case outer
        }
        
        public let width: Width
        public let height: CGFloat
        public let edge: Edge
        public let position: Position
        
        public init(width: Width = .proportional(padding: 0), height: CGFloat = 2, edge: Edge = .bottom, position: Position = .center) {
            self.width = width
            self.height = height
            self.edge = edge
            self.position = position
        }
    }
    
    struct Configuration {
        public var backgroundColor: UIColor
        public var segmentsPadding: CGFloat
        public var selectionStyle: SelectionStyle
        
        fileprivate var isToggleEnabled: Bool {
            switch selectionStyle {
            case .toggle:
                return true
            case .line:
                return false
            }
        }

        public init(
            backgroundColor: UIColor = .lightGray,
            segmentsPadding: CGFloat = 30,
            selectionStyle: SelectionStyle = .toggle(background: .darkGray)) {
            
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

public extension GraphicsSegmentedControl {
    var toggleItem: GraphicsItem {
        toggleView
    }
}
