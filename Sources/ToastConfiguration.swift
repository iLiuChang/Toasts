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
    
    /// The message text color. Default is white.
    public var messageColor: UIColor = .white
    
    /// The maximum width of the toast as a fraction of its superview, in the range `0...1`. Default is `0.8`.
    public var maxWidthRatio: CGFloat = 0.8
    
    /// The maximum height of the toast as a fraction of its superview, in the range `0...1`. Default is `0.8`.
    public var maxHeightRatio: CGFloat = 0.8
    
    /// Insets from the toast edges to its content. Default is `10` on all sides.
    ///
    /// `top` is also used as the spacing between the image and the message.
    /// When positioning the toast, `top` and `bottom` are added to the superview's safe area insets.
    public var contentInsets: UIEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    
    /// The corner radius. Default is `10`.
    public var cornerRadius: CGFloat = 10.0
    
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
    
    /// The fade in and fade out duration. Default is `0.2` seconds.
    public var fadeDuration: TimeInterval = 0.2
    
    /// The activity indicator color. Default is white.
    public var activityIndicatorColor: UIColor = .white
    
    /// The activity toast background color. Default is black at 80% opacity.
    public var activityBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.8)
    
}

// MARK: - ToastConfiguration

/// Shared behavior settings for toast notifications.
///
/// Pass an instance to `showToast` or `showActivityToast`. When omitted, ``default`` is used.
public class ToastConfiguration {
    
    /// The configuration used when a show method does not receive an explicit configuration.
    public static let `default` = ToastConfiguration()
    
    public init() {}
    
    /// The visual style used to build toast views.
    public var style = ToastStyle()
    
    /// A Boolean value that determines whether tapping a toast dismisses it. Default is `true`.
    public var isTapToDismissEnabled = true
    
    /// A Boolean value that determines whether toasts are shown one after another.
    ///
    /// When `false`, multiple toasts can appear at the same time. This does not affect activity toasts.
    /// Default is `false`.
    public var isQueueEnabled = false
    
    /// The visible duration of a toast, in seconds. Default is `3`.
    public var duration: TimeInterval = 3.0
    
    /// The default toast position. Default is ``ToastPosition/bottom``.
    public var position: ToastPosition = .bottom
    
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
    
    func centerPoint(forToast toast: UIView, inSuperview superview: UIView, configuration: ToastConfiguration) -> CGPoint {
        let topPadding = configuration.style.contentInsets.top + superview.safeAreaInsets.top
        let bottomPadding = configuration.style.contentInsets.bottom + superview.safeAreaInsets.bottom
        
        switch self {
        case .top:
            return CGPoint(x: superview.bounds.size.width / 2.0, y: (toast.frame.size.height / 2.0) + topPadding)
        case .center:
            return CGPoint(x: superview.bounds.size.width / 2.0, y: superview.bounds.size.height / 2.0)
        case .bottom:
            return CGPoint(x: superview.bounds.size.width / 2.0, y: (superview.bounds.size.height - (toast.frame.size.height / 2.0)) - bottomPadding)
        }
    }
}
