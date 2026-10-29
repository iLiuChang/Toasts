// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Toasts",
    platforms: [.iOS(.v11)],
    products: [
        .library(name: "Toasts", targets: ["Toasts"])
    ],
    targets: [
        .target(
            name: "Toasts",
            path: "Sources",
            resources: [.copy("PrivacyInfo.xcprivacy")]
        )
    ]
)
