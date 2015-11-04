Pod::Spec.new do |s|
  s.name             = "MultiPicker"
  s.version          = "0.1.2"
  s.summary          = "An Image Picker View Controller for iOS."

  s.description      = <<-DESC
An Image Picker View Controller for iOS that supports multiple images, multiple presentation styles, storyboards and rotation. Inspired by: https://github.com/questbeat/QBImagePicker
                       DESC

  s.homepage         = "https://github.com/BellAppLab/MultiPicker"
  s.license          = 'MIT'
  s.author           = { "Bell App Lab" => "apps@bellapplab.com" }
  s.source           = { :git => "https://github.com/BellAppLab/MultiPicker.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/BellAppLab'

  s.platform     = :ios, '9.0'
  s.requires_arc = true

  s.module_name = 'MultiPicker'

  s.source_files = 'Pod/Classes/*'
  s.resource = 'Pod/Assets/*.{storyboard}'

  s.frameworks = 'UIKit', 'Photos'
  s.dependency 'Permissionable/Photos'
end
