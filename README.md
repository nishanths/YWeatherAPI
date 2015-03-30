# [YWeatherAPI](http://cocoadocs.org/docsets/YWeatherAPI/)

A powerful API wrapper for [Yahoo Weather](https://developer.yahoo.com/weather/) for iOS and Mac.

[![CI Status](http://img.shields.io/travis/nishanths/YWeatherAPI.svg?style=flat)](https://travis-ci.org/Nishanth Shanmugham/YWeatherAPI)
[![Version](https://img.shields.io/cocoapods/v/YWeatherAPI.svg?style=flat)](http://cocoapods.org/pods/YWeatherAPI)
[![License](https://img.shields.io/cocoapods/l/YWeatherAPI.svg?style=flat)](http://cocoapods.org/pods/YWeatherAPI)
[![Platform](https://img.shields.io/cocoapods/p/YWeatherAPI.svg?style=flat)](http://cocoapods.org/pods/YWeatherAPI)

## Contents

* [Installation](https://github.com/nishanths/YWeatherAPI#installation)
* [Getting Started](https://github.com/nishanths/YWeatherAPI#getting-started)
* [Features](https://github.com/nishanths/YWeatherAPI#features)
* [Documentation](https://github.com/nishanths/YWeatherAPI#documentation)
* [FAQs](https://github.com/nishanths/YWeatherAPI#faqs)
* [Requirements](https://github.com/nishanths/YWeatherAPI#requirements)
* [Contributing](https://github.com/nishanths/YWeatherAPI#contributing)
* [License](https://github.com/nishanths/YWeatherAPI#license)


## Installation

#### CocoaPods (Recommended)

YWeatherAPI is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'YWeatherAPI', '~> 0.1'
```

And then from terminal, run:

```bash
$ pod install
```

#### Manual

Clone the repo and add all the files in the `Pod/Classes` directory to your Xcode target.


## Getting Started

YWeatherAPI makes it easy to work with the Yahoo Weather API. 

After [installing](https://github.com/nishanths/YWeatherAPI#installation), `#import <YWeatherAPI/YWeatherAPI.h>` to get started:

```obj-c
// Getting the current temperature in the default temperature unit 
// by coordinate for Redwood City, CA

CLLocation* coordinate = [[CLLocation alloc] initWithLatitude:37.48 longitude:122.23];

[[YWeatherAPI sharedManager] temperatureForCoordinate:(CLLocation*)coordinate
                                              success:^(NSDictionary* result)
         {
             NSString* temperature = [result objectForKey:kYWAIndex]; 
         }
                                              failure:^(id response, NSError* error)
         {
             NSLog(@"%@", error);
         }
];
```

#### Success result

The result in the success callback in the example above would be the following NSDictionary object:

```obj-c
{
    city = "Redwood City"; // access using kYWACity or @"city"
    country = "United States"; // kYWACountry
    index = "72"; // kYWAIndex
    latitude = "37.5"; // kYWALatitude 
    longitude = "-122.23"; // kYWALongitude
    region = "CA"; // kYWARegion
    temperatureInC = "22.222222"; // kYWATemperatureInC
    temperatureInF = "72"; // kYWATemperatureInF
}
```

See `YWeatherAPI.h` for a complete list of keys and data types returned.


#### Shared Singleton

Get the shared singleton by using:

```obj-c
[YWeatherAPI sharedManager];
``` 
#### Customizing Defaults

You can customize the default weather units to be returned, enable caching of results, and set the cache expiry duration:

```obj-c
[YWeatherAPI sharedManager].defaultPressureUnit = MB;
[YWeatherAPI sharedManager].cacheEnabled = YES;
[YWeatherAPI sharedManager].cacheExpiryInMinutes = 10;
```
Check out the [full documentation](https://github.com/nishanths/YWeatherAPI#documentation).

## Features

* Caching results, with customizable cache expiry times
* Looking up weather data by CLLocation, natural-language location strings, and [Yahoo WOEIDs](https://developer.yahoo.com/geo/geoplanet/guide/concepts.html)
* Looking up weather data in customizable pressure, distance, speed, and temperature units


## Documentation

The full list of methods is at [CocoaPods Docs](http://cocoadocs.org/docsets/YWeatherAPI/).

## FAQs

#### Do I need an API key?

No. Yahoo Weather currently does not require an API key to access most of its content, so this API wrapper does not ask for one either. However, this may change in the future. If it does, semantic versioning will be respected.


## Requirements

YWeatherAPI works on Mac OS X 10.8+ and iOS 6.0+. 

* CoreLocation is required to reverse geocode coordinates. 
* AFNetworking is a dependency and is automatically installed along with YWeatherAPI if it isn't already installed.

## Contributing

* New features, bug fixes, and additional documentation and [tests](https://github.com/nishanths/YWeatherAPI/tree/master/Example/Tests) are welcome! Please fork the repository and request to be merged into the `master` branch.
* Alternatively, if you have a feature request or find a bug, please let me know [here](https://github.com/nishanths/YWeatherAPI/issues), on [Twitter](https://twitter.com/nshanmugham), or [email](mailto:nishanth.gerrard@gmail.com).

## License

YWeatherAPI is available under the MIT license. See the [LICENSE](https://github.com/nishanths/YWeatherAPI/blob/master/LICENSE) file for more info.
