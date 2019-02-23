#
# Be sure to run `pod lib lint Saffron.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Saffron'
  s.version          = '0.1.0'
  s.summary          = 'SoundFont 2.0 (SF2) library for iOS and macOS apps in Swift'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
SoundFont 2.0 (SF2) library for iOS and macOS apps written in Swift. Use it
to create SoundFont files from samples, with instrument definitions.
                       DESC

  s.homepage         = 'https://github.com/coniferprod/Saffron'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jere Käpyaho' => 'jere@coniferproductions.com' }
  s.source           = { :git => 'https://github.com/jere@coniferproductions.com/Saffron.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/coniferprod'

  s.ios.deployment_target = '11.0'

  s.source_files = 'Saffron/Classes/**/*'
  
  # s.resource_bundles = {
  #   'Saffron' => ['Saffron/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
