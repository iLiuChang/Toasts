Pod::Spec.new do |s|
  s.name         = "Toasts"
  s.version      = "3.0.0"
  s.summary      = "Simple swift toast notifications"
  s.homepage     = "https://github.com/iLiuChang/Toasts"
  s.license      = "MIT"
  s.authors      = { "iLiuChang" => "iliuchang@foxmail.com" }
  s.platform     = :ios, "11.0"
  s.source       = { :git => "https://github.com/iLiuChang/Toasts.git", :tag => s.version }
  s.requires_arc = true
  s.swift_version = "5.5"
  s.source_files = "Sources/*.{swift}"
  s.resource_bundles = { 'Toasts' => ['Sources/PrivacyInfo.xcprivacy'] }
end
