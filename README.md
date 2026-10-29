# Toasts

![Swift](https://img.shields.io/badge/Swift-5.5%2B-orange.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%2011.0%2B-lightgrey.svg)
![Version](https://img.shields.io/badge/Version-3.0.0-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![SPM](https://img.shields.io/badge/SPM-supported-brightgreen.svg)
![CocoaPods](https://img.shields.io/badge/CocoaPods-supported-blueviolet.svg)

## Overview

A lightweight toast library for iOS, built as an extension on `UIView`. Show a short message, an image, or a loading indicator with one call:

- **Toast** — text and optional image, placed by `ToastConfiguration.position`
- **Activity** — a loading indicator that stays until you hide it

## Features

- **Any UIView** — show toasts from a view controller's view or any other view
- **Message and Image** — text only, image only, or both with the image centered above the message
- **Activity Toast** — independent loading indicator that is not affected by the toast queue
- **Configuration** — global defaults through `ToastConfiguration.default`, or a per-call configuration
- **Style** — background, typography, insets, size limits, corner radius, and optional shadow
- **Queue** — show toasts one after another when `isQueueEnabled` is `true`
- **Tap to Dismiss** — dismiss early with an optional completion that reports whether the user tapped
- **Safe Area** — top and bottom placement add the superview's safe area insets

## Requirements

- iOS 11.0+
- Swift 5.5+

## Installation

### CocoaPods

```ruby
pod 'Toasts'
```

Then run:

```bash
pod install
```

### Swift Package Manager

In Xcode: **File → Add Packages…** and enter:

```
https://github.com/iLiuChang/Toasts.git
```

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/iLiuChang/Toasts.git", from: "3.0.0")
]
```

### Manual

1. Download the files in the `Sources` folder
2. Drag them into your Xcode project

## Usage

### Basic Toast

```swift
import Toasts

view.showToast("Saved successfully")
```

### Image Toast

```swift
view.showToast("Done", image: UIImage(systemName: "checkmark.circle.fill"))
```

### Position

Position comes from `ToastConfiguration`. Change the default, or pass a configuration for one call:

```swift
ToastConfiguration.default.position = .top

let configuration = ToastConfiguration()
configuration.position = .center
view.showToast("Centered toast", configuration: configuration)
```

### Custom Point

```swift
view.showToast("Pinned here", at: CGPoint(x: view.bounds.midX, y: 180))
```

### Custom Appearance

```swift
let configuration = ToastConfiguration()
configuration.duration = 2
configuration.style.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.92)
configuration.style.messageColor = .white
configuration.style.cornerRadius = 16
configuration.style.contentInsets = UIEdgeInsets(top: 14, left: 18, bottom: 14, right: 18)
configuration.style.shadow = ToastShadow(color: .systemGreen, opacity: 0.35)

view.showToast("Custom style", configuration: configuration)
```

Change `ToastConfiguration.default` to apply the same behavior and style to every call that does not pass a configuration.

### Completion

```swift
view.showToast("Tap to dismiss") { didTap in
    print(didTap ? "Dismissed by tap" : "Timed out")
}
```

### Queue

```swift
let configuration = ToastConfiguration()
configuration.isQueueEnabled = true
configuration.duration = 1.2

view.showToast("First", configuration: configuration)
view.showToast("Second", configuration: configuration)
view.showToast("Third", configuration: configuration)
```

### Activity Toast

```swift
view.showActivityToast()

// When the work finishes:
view.hideActivityToast()
```

Activity toasts are independent of regular toasts. Only one activity toast can be visible on a view at a time.

### Hide

```swift
view.hideToast()
view.hideAllToasts()
view.clearToastQueue()
```

## API Reference

### UIView

| Method / Property | Description |
|---|---|
| `showToast(_:image:configuration:completion:)` | Shows a toast. Position and duration come from `configuration`. |
| `showToast(_:at:image:configuration:completion:)` | Shows a toast at a specific center point. |
| `hideToast()` | Hides the oldest visible toast. Does not hide the activity toast. |
| `hideAllToasts(includeActivity:clearQueue:)` | Hides all visible toasts. Both flags default to `true`. |
| `clearToastQueue()` | Clears queued toasts without hiding any that are currently visible. |
| `showActivityToast(configuration:)` | Shows an activity toast using the configuration's position. |
| `showActivityToast(at:configuration:)` | Shows an activity toast at a specific center point. |
| `hideActivityToast()` | Hides the visible activity toast, if there is one. |
| `isShowingToast` | Whether a toast or activity toast is currently visible. |

### ToastConfiguration

| Property | Description |
|---|---|
| `default` | Used when no configuration is passed. |
| `style` | Visual style for toast and activity views. |
| `isTapToDismissEnabled` | Whether tapping a toast dismisses it. Default is `true`. |
| `isQueueEnabled` | Whether toasts wait in a queue. Default is `false`. Does not affect activity toasts. |
| `duration` | Visible duration in seconds. Default is `3`. |
| `position` | `.top`, `.center`, or `.bottom`. Default is `.bottom`. |

### ToastStyle

| Property | Description |
|---|---|
| `backgroundColor` | Toast background. Default is black at 80% opacity. |
| `messageColor` | Message text color. Default is white. |
| `messageFont` | Message font. Default is system 16 pt. |
| `messageAlignment` | Message text alignment. Default is `.center`. |
| `messageNumberOfLines` | Maximum number of lines. `0` means no limit. |
| `maxWidthRatio` | Maximum width as a fraction of the superview, in `0...1`. Default is `0.8`. |
| `maxHeightRatio` | Maximum height as a fraction of the superview, in `0...1`. Default is `0.8`. |
| `contentInsets` | Insets from the toast edges to its content. Default is `10` on all sides. |
| `cornerRadius` | Corner radius. Default is `10`. |
| `shadow` | Optional `ToastShadow`. `nil` means no shadow. |
| `imageSize` | Image size. Default is `80 × 80`. |
| `activitySize` | Activity toast size. Default is `100 × 100`. |
| `fadeDuration` | Fade in and fade out duration. Default is `0.2`. |
| `activityIndicatorColor` | Activity indicator color. Default is white. |
| `activityBackgroundColor` | Activity toast background. Default is black at 80% opacity. |

### ToastShadow

| Property | Description |
|---|---|
| `color` | Shadow color. Default is black. |
| `opacity` | Shadow opacity, in `0...1`. Default is `0.8`. |
| `radius` | Shadow blur radius. Default is `6`. |
| `offset` | Shadow offset. Default is `4 × 4`. |

### ToastPosition

| Case | Description |
|---|---|
| `.top` | Near the top, including the top safe area inset. |
| `.center` | Centered in the superview. |
| `.bottom` | Near the bottom, including the bottom safe area inset. |

## Architecture

`UIView` extensions create a private toast view from the message, image, and `ToastStyle`, then present it with fade animation and an optional timer. When `isQueueEnabled` is `true` and a toast is already visible, later toasts wait in a queue and appear after the current one finishes.

Activity toasts use a separate associated object and are not part of that queue. Placement for `.top` and `.bottom` adds `contentInsets` to the superview's safe area insets.

## License

MIT License. See [LICENSE](LICENSE) for details.
