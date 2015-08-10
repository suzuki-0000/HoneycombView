Pod::Spec.new do |s|
  s.name         = "HoneycombView"
  s.version      = "1.0.0"
  s.summary      = "HoneycombView is the view for displaying like 'Honyecomb' layout."
 #s.homepage     = "http://EXAMPLE/HoneycombView"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "suzuki_keishi" => "suzuki_keishi@cyberagent.co.jp" }
  s.source       = { :git => "http://EXAMPLE/HoneycombView.git", :tag => "0.0.1" }
  s.platform     = :ios, "8.0"
  s.source_files  = "HoneycombView/**/*.{h,swift}"
  s.requires_arc = true
  s.frameworks = "UIKit"
end
