//
//  ToastConfiguration.swift
//  Toasts
//
//  Created by Leo on 2026/10/29.
//

import UIKit

// MARK: - ToastShadow

/// Shadow appearance for a toast view.
public struct ToastShadow {
    
    /// The shadow color. Default is black.
    public var color: UIColor = .black
    
    /// The shadow opacity, in the range `0...1`. Default is `0.8`.
    public var opacity: Float = 0.8
    
    /// The shadow blur radius. Default is `6`.
    public var radius: CGFloat = 6.0
    
    /// The shadow offset. Default is `4 × 4`.
    public var offset = CGSize(width: 4.0, height: 4.0)
    
    public init(
        color: UIColor = .black,
        opacity: Float = 0.8,
        radius: CGFloat = 6.0,
        offset: CGSize = CGSize(width: 4.0, height: 4.0)
    ) {
        self.color = color
        self.opacity = opacity
        self.radius = radius
        self.offset = offset
    }
}

// MARK: - ToastStyle

/// Visual style for toast views created by `showToast`.
public struct ToastStyle {

    public init() {}
    
    /// The background color. Default is black at 80% opacity.
    public var backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.8)
    
    /// The maximum width of the toast as a fraction of its superview, in the range `0...1`. Default is `0.8`.
    public var maxWidthRatio: CGFloat = 0.8
    
    /// The maximum height of the toast as a fraction of its superview, in the range `0...1`. Default is `0.8`.
    public var maxHeightRatio: CGFloat = 0.8
    
    /// Insets from the toast edges to its content. Default is `10` on all sides.
    ///
    /// When positioning the toast, `top` and `bottom` are added to the superview's safe area insets.
    public var contentInsets: UIEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    
    /// The spacing between the image and the message. Default is `10`.
    public var spacing: CGFloat = 10.0
    
    /// The corner radius. Default is `10`.
    public var cornerRadius: CGFloat = 10.0
    
    /// The message text color. Default is white.
    public var messageColor: UIColor = .white

    /// The message font. Default is the system font at size `16`.
    public var messageFont: UIFont = .systemFont(ofSize: 16.0)
    
    /// The message text alignment. Default is `.center`.
    public var messageAlignment: NSTextAlignment = .center
    
    /// The maximum number of lines for the message. `0` means no limit. Default is `0`.
    public var messageNumberOfLines = 0
    
    /// The shadow. `nil` means no shadow. Default is `nil`.
    public var shadow: ToastShadow?
    
    /// The image size. Default is `80 × 80`.
    public var imageSize = CGSize(width: 80.0, height: 80.0)
    
    /// The activity toast size. Default is `100 × 100`.
    public var activitySize = CGSize(width: 100.0, height: 100.0)
    
    /// The activity indicator color. Default is white.
    public var activityIndicatorColor: UIColor = .white
    
}

// MARK: - ToastConfiguration

/// Shared behavior settings for toast notifications.
///
/// Pass an instance to `showToast` or `showActivityToast`. When omitted, ``default`` is used.
public struct ToastConfiguration {
    
    /// The configuration used when a show method does not receive an explicit configuration.
    @MainActor public static var `default` = ToastConfiguration()
    
    public init() {}
    
    /// The visual style used to build toast views.
    public var style = ToastStyle()
    
    /// A Boolean value that determines whether tapping a toast or activity toast dismisses it. Default is `true`.
    public var isTapToDismissEnabled = true
    
    /// A Boolean value that determines whether toasts are shown one after another.
    ///
    /// When `false`, multiple toasts can appear at the same time. This does not affect activity toasts.
    /// Default is `false`.
    public var isQueueEnabled = false
    
    /// The visible duration of a toast, in seconds. Default is `3`.
    public var visibleDuration: TimeInterval = 3.0
    
    /// The fade in and fade out duration, in seconds. Default is `0.2`.
    public var fadeDuration: TimeInterval = 0.2
    
    /// The default toast position. Default is ``ToastPosition/center``.
    public var position: ToastPosition = .center
    
}

// MARK: - ToastPosition

/// A position used to place a toast in its superview.
public enum ToastPosition {
    /// Near the top of the superview, including the top safe area inset.
    case top
    /// Centered in the superview.
    case center
    /// Near the bottom of the superview, including the bottom safe area inset.
    case bottom
    
    func centerPoint(for toast: UIView, in superview: UIView, style: ToastStyle) -> CGPoint {
        let bounds = superview.bounds
        let midX = bounds.midX
        
        switch self {
        case .top:
            let padding = style.contentInsets.top + superview.safeAreaInsets.top
            return CGPoint(x: midX, y: toast.bounds.midY + padding)
        case .center:
            return CGPoint(x: midX, y: bounds.midY)
        case .bottom:
            let padding = style.contentInsets.bottom + superview.safeAreaInsets.bottom
            return CGPoint(x: midX, y: bounds.maxY - toast.bounds.midY - padding)
        }
    }
}
