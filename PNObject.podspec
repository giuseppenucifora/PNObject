#
# Be sure to run `pod lib lint PNObject.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = 'PNObject'
s.version          = '1.0.2'
s.summary          = 'PNObject is a simple replica of the more complex ParseObject'


#s.description      = <<-DESC TODO: Add long description of the pod here. DESC

s.homepage         = "https://git.giuseppenucifora.com/giuseppenucifora/PNObject"
# s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'Giuseppe Nucifora' => 'me@giuseppenucifora.com' }
s.source           = { :git => "https://git.giuseppenucifora.com/giuseppenucifora/PNObject.git", :tag => s.version.to_s }
# s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

s.ios.deployment_target = '8.0'

s.source_files = 'PNObject/Classes/**/*'

# s.resource_bundles = {
#   'PNObject' => ['PNObject/Assets/*.png']
# }

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
s.dependency 'NSDataAES'
s.dependency 'DDDKeychainWrapper'
s.dependency 'DJLocalization'
s.dependency 'RZDataBinding'

end
