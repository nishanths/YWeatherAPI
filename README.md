# YWeatherAPI

A powerful API wrapper for Yahoo Weather for iOS and Mac.

[![CI Status](http://img.shields.io/travis/nishanths/YWeatherAPI.svg?style=flat)](https://travis-ci.org/Nishanth Shanmugham/YWeatherAPI)
[![Version](https://img.shields.io/cocoapods/v/YWeatherAPI.svg?style=flat)](http://cocoapods.org/pods/YWeatherAPI)
[![License](https://img.shields.io/cocoapods/l/YWeatherAPI.svg?style=flat)](http://cocoapods.org/pods/YWeatherAPI)
[![Platform](https://img.shields.io/cocoapods/p/YWeatherAPI.svg?style=flat)](http://cocoapods.org/pods/YWeatherAPI)

## Installation

YWeatherAPI is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "YWeatherAPI"
```

And then run:

```bash
$ pod install
```

## Usage

#### Get Started

Import `#import <YWeatherAPI/YWeatherAPI.h>` and use:

```obj-c
// Getting the current temperature in the default temperature unit for Redwood City, California by coordinate

CLLocation* coordinate = [[CLLocation alloc] initWithLatitude:37.48 longitude:122.23];

[[YWeatherAPI sharedManager] temperatureForCoordinate:(CLLocation*)coordinate
                                              success:^(NSDictionary* result)
         {
             NSString* temperature = [result objectForKey:kYWAIndex]; 
             // kYWAIndex gets you the detail you asked for from the returned dictionary
         }
                                              failure:^(id response, NSError* error)
         {
             NSLog(@"%@", error);
         }];
```

#### Shared Singleton

Get the shared singleton by using:

```obj-c
[YWeatherAPI sharedManager];
``` 
#### Customizing Defaults

You can use to get a [variety of information](http://cocoadocs.org/docsets/YWeatherAPI/) from Yahoo Weather. You can customize the default weather units to be returned, enable caching of results, and set the cache expiry duration:

```obj-c
[YWeatherAPI sharedManager].defaultPressureUnit = MB;
[YWeatherAPI sharedManager].cacheEnabled = YES;
[YWeatherAPI sharedManager].cacheExpiryInMinutes = 10;
```

#### Sample response

The `result` for the example above would be:

```obj-c
{
    city = "Redwood City"; // access using kYWACity
    country = "United States"; // access using kYWACountry
    index = 72; 	// access using kYWAIndex
    latitude = "37.5"; // and so on ..
    longitude = "-122.23";
    region = CA;
    temperatureInC = "22.222222";
    temperatureInF = 72;
}
```
The prefix for key string names is `kYWA`. See `YWeatherAPI.h` for a complete list, or check out the [CocoaPods Docs](http://cocoadocs.org/docsets/YWeatherAPI/).

## Features

YWeatherAPI makes it easy to work with the Yahoo Weather API.

* Caching, with customizable cache expiry times
* Looking up weather data by `CLLocation`, natural-language location strings, or [Yahoo WOEIDs](https://developer.yahoo.com/geo/geoplanet/guide/concepts.html).
* Looking up weather data in customizable pressure, distance, speed, and temperature units

## Documentation

Full documentation is on [CocoaPods Docs](http://cocoadocs.org/docsets/YWeatherAPI/).

## FAQ

**Do I need an API key?**<br>
Nope, Yahoo Weather does not need an API key to access most of its content. This API wrapper does not ask for one, but this may change in the future. If that does happen, semantic versioning will be respected.

## Contributing

New features and bug requests are welcome. Please fork the repository and request to be merged into the `master` branch. 

## Requirements

YWeather API works on Mac OS X 10.8+ and iOS 6.0+. CoreLocation is required to reverse geocode coordinates.

## License

YWeatherAPI is available under the MIT license. See the [LICENSE](https://github.com/nishanths/YWeatherAPI/blob/master/LICENSE) file for more info.