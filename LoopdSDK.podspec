#
# Be sure to run `pod lib lint LoopdSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "LoopdSDK"
  s.version          = "1.0.11"
  s.summary          = "A framework easy to use Loopd Badge"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = "A framework to control Loopd Badge."

  s.homepage         = "https://github.com/loopdinc/iOS-Loopd-SDK"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Derrick" => "derrick@getloopd.com" }
  s.source           = { :git => "https://github.com/loopdinc/iOS-Loopd-SDK.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  #s.resource_bundles = {
  #  'LoopdSDK' => ['Pod/Assets/*.png']
  #}

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
   s.vendored_frameworks = 'Pod/Frameworks/LoopdSDK.framework'
  # s.dependency 'AFNetworking', '~> 2.3'
end
