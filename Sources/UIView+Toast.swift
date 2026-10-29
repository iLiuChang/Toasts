//
//  UIView+Toast.swift
//  Toasts
//
//  Created by Leo on 2026/10/28.
//

import UIKit
import ObjectiveC

private var toastActiveToastsKey: UInt8 = 0
private var activityToastViewKey: UInt8 = 0
private var toastQueueKey: UInt8 = 0

/// Adds toast notifications to `UIView`.
public extension UIView {
    
    // MARK: - Show
    
    /// Shows a toast with an optional message and image.
    ///
    /// Position, duration, and appearance come from `configuration`. When `configuration` is `nil`,
    /// ``ToastConfiguration/default`` is used.
    ///
    /// - Parameters:
    ///   - message: The text to display.
    ///   - image: An optional image shown above the message.
    ///   - configuration: Behavior and style settings. Uses ``ToastConfiguration/default`` when `nil`.
    ///   - completion: Called after the toast disappears. The argument is `true` if the user tapped to dismiss.
    func showToast(_ message: String?, image: UIImage? = nil, configuration: ToastConfiguration? = nil, completion: ((_ didTap: Bool) -> Void)? = nil) {
        let configuration = configuration ?? .default
        guard let toast = makeToastView(message: message, image: image, configuration: configuration, completion: completion) else { return }
        let point = configuration.position.centerPoint(forToast: toast, inSuperview: self, configuration: configuration)
        present(toast, at: point)
    }
    
    /// Shows a toast at a specific center point.
    ///
    /// Duration and appearance come from `configuration`. When `configuration` is `nil`,
    /// ``ToastConfiguration/default`` is used.
    ///
    /// - Parameters:
    ///   - message: The text to display.
    ///   - point: The center point of the toast in the receiver's coordinate space.
    ///   - image: An optional image shown above the message.
    ///   - configuration: Behavior and style settings. Uses ``ToastConfiguration/default`` when `nil`.
    ///   - completion: Called after the toast disappears. The argument is `true` if the user tapped to dismiss.
    func showToast(_ message: String?, at point: CGPoint, image: UIImage? = nil, configuration: ToastConfiguration? = nil, completion: ((_ didTap: Bool) -> Void)? = nil) {
        let configuration = configuration ?? .default
        guard let toast = makeToastView(message: message, image: image, configuration: configuration, completion: completion) else { return }
        present(toast, at: point)
    }
    
    // MARK: - Hide
    
    /// Hides the oldest visible toast.
    ///
    /// This does not hide an activity toast. Use ``hideActivityToast()`` for that.
    /// To hide every toast, call ``hideAllToasts(includeActivity:clearQueue:)``.
    func hideToast() {
        guard let toast = activeToasts.first else { return }
        hide(toast)
    }
    
    /// Hides all visible toasts.
    ///
    /// - Parameters:
    ///   - includeActivity: Pass `true` to also hide the activity toast. Default is `true`.
    ///   - clearQueue: Pass `true` to clear queued toasts. Default is `true`.
    func hideAllToasts(includeActivity: Bool = true, clearQueue: Bool = true) {
        if clearQueue {
            clearToastQueue()
        }
        
        activeToasts.forEach { hide($0) }
        
        if includeActivity {
            hideActivityToast()
        }
    }
    
    /// Removes queued toasts without hiding any toast that is currently visible.
    func clearToastQueue() {
        queue.removeAll()
    }
    
    // MARK: - Activity
    
    /// Shows an activity toast.
    ///
    /// Only one activity toast can be visible on a view at a time. Later calls are ignored until
    /// ``hideActivityToast()`` is called. Activity toasts are independent of regular toasts and
    /// are not affected by queueing.
    ///
    /// - Parameter configuration: Behavior and style settings. Uses ``ToastConfiguration/default`` when `nil`.
    func showActivityToast(configuration: ToastConfiguration? = nil) {
        let configuration = configuration ?? .default
        let toast = makeActivityToastView(configuration: configuration)
        let point = configuration.position.centerPoint(forToast: toast, inSuperview: self, configuration: configuration)
        showActivityToast(toast, at: point)
    }
    
    /// Shows an activity toast at a specific center point.
    ///
    /// Only one activity toast can be visible on a view at a time. Later calls are ignored until
    /// ``hideActivityToast()`` is called. Activity toasts are independent of regular toasts and
    /// are not affected by queueing.
    ///
    /// - Parameters:
    ///   - point: The center point of the activity toast in the receiver's coordinate space.
    ///   - configuration: Behavior and style settings. Uses ``ToastConfiguration/default`` when `nil`.
    func showActivityToast(at point: CGPoint, configuration: ToastConfiguration? = nil) {
        let configuration = configuration ?? .default
        showActivityToast(makeActivityToastView(configuration: configuration), at: point)
    }
    
    /// Hides the visible activity toast, if there is one.
    func hideActivityToast() {
        guard let toast = objc_getAssociatedObject(self, &activityToastViewKey) as? ActivityToastView else { return }
        UIView.animate(withDuration: toast.configuration.style.fadeDuration, delay: 0.0, options: [.curveEaseIn, .beginFromCurrentState], animations: {
            toast.alpha = 0.0
        }) { _ in
            toast.removeFromSuperview()
            objc_setAssociatedObject(self, &activityToastViewKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK: - Status
    
    /// A Boolean value indicating whether a toast or activity toast is currently visible.
    var isShowingToast: Bool {
        activeToasts.count > 0 || objc_getAssociatedObject(self, &activityToastViewKey) != nil
    }
}

// MARK: - Private

private extension UIView {
    
    var activeToasts: [ToastView] {
        get { toastBox(for: &toastActiveToastsKey).toasts }
        set { toastBox(for: &toastActiveToastsKey).toasts = newValue }
    }
    
    var queue: [ToastView] {
        get { toastBox(for: &toastQueueKey).toasts }
        set { toastBox(for: &toastQueueKey).toasts = newValue }
    }
    
    func toastBox(for key: UnsafePointer<UInt8>) -> ToastBox {
        let pointer = UnsafeRawPointer(key)
        if let box = objc_getAssociatedObject(self, pointer) as? ToastBox {
            return box
        }
        let box = ToastBox()
        objc_setAssociatedObject(self, pointer, box, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return box
    }
    
    func present(_ toast: ToastView, at point: CGPoint) {
        if toast.configuration.isQueueEnabled, activeToasts.count > 0 {
            toast.queuedPoint = point
            queue.append(toast)
            return
        }
        
        toast.center = point
        toast.alpha = 0.0
        
        if toast.configuration.isTapToDismissEnabled {
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(UIView.handleToastTapped(_:)))
            toast.addGestureRecognizer(recognizer)
            toast.isUserInteractionEnabled = true
            toast.isExclusiveTouch = true
        }
        
        activeToasts.append(toast)
        addSubview(toast)
        
        toast.timer = Timer(timeInterval: toast.configuration.duration, repeats: false) { [weak self] _ in
            self?.hide(toast)
        }
        
        UIView.animate(withDuration: toast.configuration.style.fadeDuration, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            toast.alpha = 1.0
        }) { _ in
            guard let timer = toast.timer else { return }
            RunLoop.main.add(timer, forMode: .common)
        }
        
        UIAccessibility.post(notification: .screenChanged, argument: toast)
    }
    
    func hide(_ toast: ToastView, fromTap: Bool = false) {
        guard activeToasts.contains(toast) else { return }
        
        toast.timer?.invalidate()
        toast.timer = nil
        
        UIView.animate(withDuration: toast.configuration.style.fadeDuration, delay: 0.0, options: [.curveEaseIn, .beginFromCurrentState], animations: {
            toast.alpha = 0.0
        }) { _ in
            toast.removeFromSuperview()
            self.activeToasts.removeAll { $0 === toast }
            toast.completion?(fromTap)
            
            guard !self.queue.isEmpty else { return }
            let next = self.queue.removeFirst()
            self.present(next, at: next.queuedPoint ?? next.center)
        }
    }
    
    @objc
    func handleToastTapped(_ recognizer: UITapGestureRecognizer) {
        guard let toast = recognizer.view as? ToastView else { return }
        hide(toast, fromTap: true)
    }
    
    // MARK: - Activity
    
    func showActivityToast(_ toast: ActivityToastView, at point: CGPoint) {
        guard objc_getAssociatedObject(self, &activityToastViewKey) as? UIView == nil else { return }
        
        toast.alpha = 0.0
        toast.center = point
        objc_setAssociatedObject(self, &activityToastViewKey, toast, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        addSubview(toast)
        
        UIView.animate(withDuration: toast.configuration.style.fadeDuration, delay: 0.0, options: .curveEaseOut, animations: {
            toast.alpha = 1.0
        })
    }
    
    func makeActivityToastView(configuration: ToastConfiguration) -> ActivityToastView {
        let style = configuration.style
        let toast = ActivityToastView(configuration: configuration)
        toast.frame = CGRect(origin: .zero, size: style.activitySize)
        toast.backgroundColor = style.activityBackgroundColor
        toast.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        toast.layer.cornerRadius = style.cornerRadius
        toast.applyShadow(style.shadow)
        
        let indicatorStyle: UIActivityIndicatorView.Style
        if #available(iOS 13.0, *) {
            indicatorStyle = .large
        } else {
            indicatorStyle = UIActivityIndicatorView.Style(rawValue: 0)!
        }
        let indicator = UIActivityIndicatorView(style: indicatorStyle)
        indicator.center = CGPoint(x: toast.bounds.midX, y: toast.bounds.midY)
        indicator.color = style.activityIndicatorColor
        indicator.startAnimating()
        toast.addSubview(indicator)
        
        return toast
    }
    
    // MARK: - Construction

    
    func makeToastView(message: String?, image: UIImage?, configuration: ToastConfiguration, completion: ((Bool) -> Void)?) -> ToastView? {
        guard message != nil || image != nil else { return nil }
        
        let style = configuration.style
        let toast = ToastView(configuration: configuration)
        toast.completion = completion
        toast.backgroundColor = style.backgroundColor
        toast.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        toast.layer.cornerRadius = style.cornerRadius
        toast.applyShadow(style.shadow)
        
        var imageRect = CGRect.zero
        var imageView: UIImageView?
        if let image {
            imageView = UIImageView(image: image)
            imageView?.contentMode = .scaleAspectFit
            imageRect.size = style.imageSize
        }
        
        var messageRect = CGRect.zero
        var messageLabel: UILabel?
        if let message {
            let label = UILabel()
            label.text = message
            label.numberOfLines = style.messageNumberOfLines
            label.font = style.messageFont
            label.textAlignment = style.messageAlignment
            label.lineBreakMode = .byTruncatingTail
            label.textColor = style.messageColor
            label.backgroundColor = .clear
            
            let maxWidthRatio = min(max(style.maxWidthRatio, 0), 1)
            let maxHeightRatio = min(max(style.maxHeightRatio, 0), 1)
            let maxMessageWidth = (bounds.width * maxWidthRatio) - style.contentInsets.left - style.contentInsets.right
            var maxMessageHeight = bounds.height * maxHeightRatio
            if imageRect.height > 0 {
                maxMessageHeight -= imageRect.height + style.contentInsets.top
            }
            let maxSize = CGSize(width: max(maxMessageWidth, 0), height: max(maxMessageHeight, 0))
            let fittedSize = label.sizeThatFits(maxSize)
            messageRect.size = CGSize(width: min(fittedSize.width, maxSize.width), height: min(fittedSize.height, maxSize.height))
            messageLabel = label
        }
        
        let contentWidth = max(imageRect.width, messageRect.width)
        let wrapperWidth = contentWidth + style.contentInsets.left + style.contentInsets.right
        
        if imageView != nil {
            imageRect.origin.x = (wrapperWidth - imageRect.width) / 2.0
            imageRect.origin.y = style.contentInsets.top
        }
        
        if messageLabel != nil {
            messageRect.origin.x = style.contentInsets.left
            messageRect.size.width = wrapperWidth - style.contentInsets.left - style.contentInsets.right
            messageRect.origin.y = imageView != nil ? imageRect.maxY + style.contentInsets.top : style.contentInsets.top
        }
        
        let contentMaxY = messageRect.height > 0 ? messageRect.maxY : imageRect.maxY
        toast.frame = CGRect(x: 0, y: 0, width: wrapperWidth, height: contentMaxY + style.contentInsets.bottom)
        
        if let imageView {
            imageView.frame = imageRect
            toast.addSubview(imageView)
        }
        if let messageLabel {
            messageLabel.frame = messageRect
            toast.addSubview(messageLabel)
        }
        
        return toast
    }
    
    func applyShadow(_ shadow: ToastShadow?) {
        guard let shadow else { return }
        layer.shadowColor = shadow.color.cgColor
        layer.shadowOpacity = min(max(shadow.opacity, 0), 1)
        layer.shadowRadius = shadow.radius
        layer.shadowOffset = shadow.offset
    }
}

private final class ToastBox {
    var toasts: [ToastView] = []
}

// MARK: - Private Views

private final class ToastView: UIView {
    let configuration: ToastConfiguration
    var completion: ((Bool) -> Void)?
    var timer: Timer?
    var queuedPoint: CGPoint?
    
    init(configuration: ToastConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        nil
    }
}

private final class ActivityToastView: UIView {
    let configuration: ToastConfiguration
    
    init(configuration: ToastConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        nil
    }
}
