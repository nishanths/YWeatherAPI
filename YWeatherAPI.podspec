Pod::Spec.new do |s|
  s.name             = "YWeatherAPI"
  s.version          = "0.1.0"
  s.summary          = "Powerful Yahoo Weather API wrapper for iOS and Mac"
  s.description      = <<-DESC
                       Powerful Yahoo Weather API wrapper for iOS and Mac with support for

                       * Caching results with customizable expiry times
                       * Requesting forecasts by natural-language location strings, `CLLocation` coordinates, and Yahoo WOEIDs.
                       * Customizing default temperature, pressure, speed, and distance return units
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
  s.frameworks = 'CoreLocation'
  s.dependency 'AFNetworking', '~> 2.5'
end
