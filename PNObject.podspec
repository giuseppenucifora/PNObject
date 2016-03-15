#
# Be sure to run `pod lib lint PNObject.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = "PNObject"
s.version          = "0.4.0"
s.summary          = "PNObject is a simple replica of the more complex ParseObject"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
# s.description      = <<-DESC DESC

s.homepage         = "https://github.com/giuseppenucifora/PNObject"
# s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
s.license          = 'MIT'
s.author           = { "Giuseppe Nucifora" => "me@giuseppenucifora.com" }
s.source           = { :git => "https://github.com/giuseppenucifora/PNObject.git", :tag => s.version.to_s }
# s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

s.platform     = :ios, '8.0'
s.requires_arc = true

s.source_files = 'Pod/Classes/**/*'
# s.frameworks = 'UIKit', 'MapKit'

s.dependency 'AFNetworking'
s.dependency 'PEAR-FileManager-iOS'
s.dependency 'NSDate_Utils'
s.dependency 'UIDevice-Utils'
s.dependency 'nv-ios-http-status'
s.dependency 'NSString-Helper'
s.dependency 'CodFis-Helper'
s.dependency 'StrongestPasswordValidator'
s.dependency 'FBSDKCoreKit'
s.dependency 'FBSDKShareKit'
s.dependency 'FBSDKLoginKit'
s.dependency 'NACrypto'
s.dependency 'NSUserDefaults-AESEncryptor'


end
