# [YWeatherAPI](http://cocoadocs.org/docsets/YWeatherAPI/)

A powerful API wrapper for [Yahoo Weather](https://developer.yahoo.com/weather/) for iOS and Mac. Built on top of AFNetworking’s blocks-based architecture, it fetches responses asynchronously without any waiting on the main thread. 

This document provides a quick overview. Check out the **[full documentation](https://github.com/nishanths/YWeatherAPI#documentation)**.

The Yahoo Weather API does not require an API key.

[![CI Status](http://img.shields.io/travis/nishanths/YWeatherAPI.svg?style=flat)](https://travis-ci.org/nishanths/YWeatherAPI)
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

###### CocoaPods (Recommended)

YWeatherAPI is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'YWeatherAPI'
```

And then from terminal, run:

```bash
$ pod install
```

###### Manual

Clone the repo and add all the files in the `Pod/Classes` directory to your Xcode target.


## Getting Started


###### Include the header file

```
#import <YWeatherAPI/YWeatherAPI.h>
``` 

###### Shared Singleton

Use the shared singleton to make requests:

```obj-c
[YWeatherAPI sharedManager];
``` 

###### Example

Getting the current temperature is as simple as:

```obj-c
[[YWeatherAPI sharedManager] temperatureForLocation:@"Redwood City, California"
                                            success:^(NSDictionary* result)
    {
        NSString* temperature = [result objectForKey:kYWAIndex];
        NSLog(@"The temperature is a pleasant %@ F", temperature);
    }
                                            failure:^(id response, NSError* error)
    {
        // Yikes, something went wrong
    }
];
```

###### Success result 
The result in the success callback in the example is this NSDictionary object:

```obj-c
{
    city = "Redwood City"; 
    country = "United States"; 
    index = 72; // key @"index" (the detail you asked for)
    latitude = "37.5"; 
    longitude = "-122.23"; 
    region = CA; 
    temperatureInC = "22.22";
    temperatureInF = 72;
}
```

See [`YWeatherAPI.h`](https://github.com/nishanths/YWeatherAPI/blob/master/Pod/Classes/YWeatherAPI.h) for a complete list of keys and data types.


###### Customizing Defaults

Customize the default weather units to be returned, enable caching of results, set the cache expiry duration, and more.

```obj-c
[YWeatherAPI sharedManager].defaultPressureUnit = MB;
[YWeatherAPI sharedManager].cacheEnabled = YES;
[YWeatherAPI sharedManager].cacheExpiryInMinutes = 10;
```

## Features

* Caching results, with customizable cache expiry times.
* Looking up weather data by CLLocation, natural-language location string, and [Yahoo WOEID](https://developer.yahoo.com/geo/geoplanet/guide/concepts.html).
* Looking up weather data in customizable pressure, distance, speed, and temperature units.


## Documentation

The full documentation is at [CocoaDocs](http://cocoadocs.org/docsets/YWeatherAPI/1.0.4/Classes/YWeatherAPI.html).

## FAQs

###### Do I need an API key?

No, you do not. Yahoo Weather currently does not require an API key to access most of its content, so this API wrapper does not require one either. Please be respectful of this power. 

The requirement for an API key may change in the future. If it does, care will be taken to follow semantic versioning rules for backwards compatibility.

###### Do I need to know YQL (Yahoo Query Language) to use this?

Nope.

## Requirements

YWeatherAPI works on Mac OS X 10.8+ and iOS 6.0+. 

* CoreLocation is required to reverse geocode coordinates. 
* AFNetworking ~>2.0 is a dependency and is automatically installed along with YWeatherAPI if it isn't already.

## Contributing

* New features, bug fixes, and additional documentation and [tests](https://github.com/nishanths/YWeatherAPI/tree/master/Example/Tests) are welcome! Please fork the repository and request to be merged into the `master` branch. *Yes, I too like to live dangerously.*
* Alternatively, if you have a feature request or find a bug, please let me know [here](https://github.com/nishanths/YWeatherAPI/issues), on [Twitter](https://twitter.com/nshanmugham), or [email](mailto:nishanth.gerrard@gmail.com).

## License

YWeatherAPI is available under the MIT license. See the [LICENSE](https://github.com/nishanths/YWeatherAPI/blob/master/LICENSE) file for more info.
