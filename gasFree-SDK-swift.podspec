#
# Be sure to run `pod lib lint gasFree-SDK-swift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'gasFree-SDK-swift'
  s.version          = '0.1.0'
  s.summary          = 'gasFree-Java-SDK Generator gasFree Address from user address'

  s.homepage         = 'https://github.com/TronLink/gasFree-SDK-swift'
  s.license          = { :type => 'Apache', :file => 'LICENSE' }
  s.author           = 'tronlinkdev'
  s.source           = { :git => 'https://github.com/TronLink/gasFree-SDK-swift.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.swift_versions = '4.2'

  s.source_files = 'gasFree-SDK-swift/Classes/**/*'
  s.dependency 'tronlink-iOS-core'
end
