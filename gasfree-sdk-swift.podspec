#
# Be sure to run `pod lib lint gasfree-sdk-swift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'gasfree-sdk-swift'
  s.version          = '0.1.0'
  s.summary          = 'gasfree-sdk-swift Generator gasFree Address from user address'

  s.homepage         = 'https://github.com/gasfreeio/gasfree-sdk-swift'
  s.license          = { :type => 'Apache', :file => 'LICENSE' }
  s.author           = 'gasfree-dev'
  s.source           = { :git => 'https://github.com/gasfreeio/gasfree-sdk-swift.git', :tag => s.version.to_s }
  s.ios.deployment_target = '13.0'
  s.swift_versions = '4.2'

  s.source_files = 'gasfree-sdk-swift/Classes/**/*'
  s.dependency 'tronlink-iOS-core'
end
