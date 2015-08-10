Pod::Spec.new do |s|
  s.name         = "HoneycombView"
  s.version      = "1.0.0"
  s.summary      = "HoneycombView is the view for displaying like 'Honyecomb' layout."
  s.homepage     = "https://github.com/suzuki-0000/HoneycombView"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "suzuki_keishi" => "keishi.1983@gmail.com" }
  s.source       = { :git => "https://github.com/suzuki-0000/HoneycombView.git", :tag => "1.0.0" }
  s.platform     = :ios, "8.0"
  s.source_files  = "HoneycombView/**/*.{h,swift}"
  s.requires_arc = true
  s.frameworks = "UIKit"
end
