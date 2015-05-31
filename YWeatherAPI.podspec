Pod::Spec.new do |s|
  s.name         = "YWeatherAPI"
  s.version      = "1.0.5"
  s.summary      = "Powerful Yahoo Weather API wrapper for iOS and Mac."

  s.description  = <<-DESC 

  A powerful API wrapper for [Yahoo Weather](https://developer.yahoo.com/weather/) for iOS and Mac. Built on top of AFNetworking’s blocks-based architecture, it fetches responses asynchronously without any waiting on the main thread. It supports:


  * Caching results with customizable expiry times,
  * Requesting forecasts by natural-language location strings, `CLLocation` coordinates, and Yahoo WOEIDs,
  * Customizing default temperature, pressure, speed, and distance return units.
                   DESC

  s.homepage     = "https://github.com/nishanths/YWeatherAPI"
  s.license      = "MIT"

  s.author             = { "Nishanth Shanmugham" => "nishanth.gerrard@gmail.com" }
  s.social_media_url   = "http://twitter.com/nshanmugham"

  s.source       = { :git => "https://github.com/nishanths/YWeatherAPI.git", :tag => s.version.to_s }
  s.source_files = 'Pod/Classes/**/*'
  s.public_header_files = 'Pod/Classes/YWeatherAPI.h'

  s.framework  = "CoreLocation"
  s.requires_arc = true
  s.dependency "AFNetworking", "~> 2.0"

  s.ios.deployment_target = "6.0"
  s.osx.deployment_target = "10.8"
end
