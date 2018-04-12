#
# Be sure to run `pod lib lint TLPhotoPicker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FeedbackSlack'
  s.version          = '0.0.9'
  s.summary          = 'This library provides feedback to Slack when users take a screenshot on iOS.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This library provides feedback to Slack when users take a screenshot on iOS. Uses a custom Slack bot.
                       DESC

  s.homepage         = 'https://github.com/ShotSkydiver/SlackFeedback'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Conner Owen' => 'bigglesworth330@gmail.com' }
  s.source           = { :git => 'https://github.com/ShotSkydiver/SlackFeedback.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.swift_version = '4.1'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.1' }

  s.source_files = 'FeedbackSlack/**/*.{swift}'
  
  # s.resource_bundles = { 'FeedbackSlack' => ['TLPhotoPicker/Classes/*.xib'] }
  # s.resources = 'TLPhotoPicker/TLPhotoPickerController.bundle'

  s.public_header_files = 'FeedbackSlack/**/*.h'
  s.frameworks = 'SystemConfiguration', 'CoreTelephony'
  # s.dependency 'AFNetworking', '~> 2.3'
end
