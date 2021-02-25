#
# Be sure to run `pod lib lint Pushnami.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Pushnami'
  s.version          = '0.2.2'
  s.summary          = 'Pushnami iOS SDK for sending push notifications through the Pushnami Engine'

  s.description      = <<-DESC
  Pushnami iOS SDK for sending push notifications through the Pushnami Engine.
                       DESC

  s.homepage         = 'https://github.com/pushnami/ios-sdk-pod'
  s.license          = { :type => 'MIT', :file => 'Pushnami/LICENSE' }
  s.author           = { 'Pushnami' => 'support@pushnami.com' }
  s.source           = { :git => 'https://github.com/pushnami/ios-sdk-pod.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'Pushnami/Classes/**/*'

  s.swift_version = '5.0'

  s.platform = :ios, "10.0"
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0' }
end
