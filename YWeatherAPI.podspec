#
# Be sure to run `pod lib lint YWeatherAPI.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "YWeatherAPI"
  s.version          = "0.1.0"
  s.summary          = "Powerful Yahoo Weather wrapper for iOS and Mac"
  s.description      = <<-DESC
                       Powerful Yahoo Weather wrapper for iOS and Mac with support for

                       * Caching
                       * Forecast lookups by natural-language locations, coordinates, and Yahoo WOEIDs.
                       * Setting default temperature, pressure, speed, and distance units
                       DESC
  s.homepage         = "https://github.com/nishanths/YWeatherAPI"
  s.license          = 'MIT'
  s.author           = { "Nishanth Shanmugham" => "nishanth.gerrard@gmail.com" }
  s.source           = { :git => "https://github.com/nishanths/YWeatherAPI.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/nshanmugham'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'CLLocation'
  s.dependency 'AFNetworking', '~> 2.5.2'
end
