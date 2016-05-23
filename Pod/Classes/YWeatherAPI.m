//
//  YWeatherAPI.m
//  Pods
//
//  Created by Nishanth Shanmugham on 3/24/2015.
//  The MIT License (MIT)
//
//  Copyright (c) 2015 Nishanth Shanmugham <nishanth.gerrard@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//


#import "YWeatherAPI.h"
#import "YWeatherAPIHTTPClient.h"
#import <AFNetworking/AFNetworking.h>
@import CoreLocation; // for reverse geocoding latitude and longitude

#pragma mark - DEFAULTS and MISCELLANEOUS

// Defaults
YWAPressureUnit kYWADefaultPressureUnit = IN;
YWASpeedUnit kYWADefaultSpeedUnit = MPH;
YWADistanceUnit kYWADefaultDistanceUnit = MI;
YWATemperatureUnit kYWADefaultTemperatureUnit = F;
BOOL kYWADefaultCacheEnabledValue = YES;
uint kYWADefaultCacheExpiryInMinutes = 15;

// Aysnc queue id
char* const kYWAAsyncQueueIdentifier = "io.github.nishanths.yweatherapi.asyncQueue";

// YQL Query strings - only the "all" query is used currently to make the cache more usable.
// More query strings may be needed in the future if external queries will be specific.
NSString* const kYWAYQLQueryAll = @"select * from weather.forecast";
NSString* const kYWAYQLQueryWindSpeed = @"select wind.speed from weather.forecast";
NSString* const kYWAYQLQueryWindDirection = @"select wind.direction from weather.forecast";

// Errors
NSString* const kYWAErrorDomain = @"io.nishanths.github.yweatherapi";
NSString* const kYWAYahooWeatherErrorReturn = @"Yahoo! Weather Error";
typedef enum {
    kYWACacheNotEnabled,
    kYWACacheCannotBeUsed,
    kYWAEmptyResponse // Good response but Y! Weather did not return any usable details
} kYWAErrorCode;

// Cache
NSString* const kYWACacheKey = @"YWACache";
NSString* const kYWACacheExpiryKey = @"expiresAt";
NSString* const kYWACacheResultKey = @"result";


/*  Keys to access objects success results
 *
 *  All values returned are NSString objects except for the objects accessed using these keys:
 *
 *  kYWASunriseInLocalTime
 *  kYWASunsetInLocalTime
 *  kYWADateComponents
 *  kYWAFiveDayForecasts
 *
 *
 *  The index key provides quick access to the detail you queried for. However, it maps to an empty in the methods under these sections:
 *
 *  Today's forecast
 *  All Current Weather Conditions
 *
 *
 *  See the comments for details            */
NSString* const kYWAIndex = @"index"; // The detail asked for
// Pressure trend
NSString* const kYWAPressureTrend = @"pressureTrend";
// Pressure
NSString* const kYWAPressureInIN = @"pressureInIN";
NSString* const kYWAPressureInMB = @"pressureInMB";
// Location
NSString* const kYWALatitude = @"latitude";
NSString* const kYWALongtitude = @"longitude";
NSString* const kYWALocation = @"location";
NSString* const kYWACity = @"city";
NSString* const kYWARegion = @"region";
NSString* const kYWACountry = @"country";
// Wind
NSString* const kYWAWindSpeedInMPH = @"windSpeedInMPH";
NSString* const kYWAWindSpeedInKMPH = @"windSpeedInKMPH";
NSString* const kYWAWindDirectionInDegrees = @"windDirectionInDegrees";
NSString* const kYWAWindDirectionInCompassPoints = @"windDirectionInCompassPoints";
NSString* const kYWAWindChillInF = @"windChillInF";
NSString* const kYWAWindChillInC = @"windChillInC";
// Sunrise and Sunset
NSString* const kYWASunriseInLocalTime = @"sunriseInLocalTime"; // NSDateComponent with hour, minute, timeZone
NSString* const kYWASunsetInLocalTime = @"sunsetInLocalTime"; // NSDateComponent with hour, minute, timeZone
// Humdity
NSString* const kYWAHumidity = @"humidity";
// Visibility
NSString* const kYWAVisibilityInMI = @"visibilityInMI";
NSString* const kYWAVisibilityInKM = @"visibilityInMI";
// Short description
NSString* const kYWAShortDescription = @"shortDescription";
// Long description
NSString* const kYWALongDescription = @"longDescription"; // May contain HTML tags
// Condition
NSString* const kYWACondition = @"condition";
NSString* const kYWAConditionNumber = @"conditionNumber";
// Temperature
NSString* const kYWATemperatureInF = @"temperatureInF";
NSString* const kYWATemperatureInC = @"temperatureInC";
// Forecast conditions daily
NSString* const kYWAHighTemperatureForDay = @"highTemperatureForDay";
NSString* const kYWALowTemperatureForDay = @"lowTemperatureForDay";
NSString* const kYWADateComponents = @"kYWADateComponents"; // NSDateCompoent with month, day, year
// Five day forecasts array key
NSString* const kYWAFiveDayForecasts = @"fiveDayForecasts"; // NSArray containing NSDictionary objects for each day


/*  Comparison strings for empty index
 *  Compare with object for key kYWAIndex
 *  Currently, the today's forecast methods and the all current conditions methods return kYWAEmptyValue for the key kYWAIndex */
NSString* const kYWAEmptyValue = @"";

/*  Returned by the condition methods when Yahoo weather has no condition string available
 *  See code 3200 at https://developer.yahoo.com/weather/documentation.html#codes */
NSString* const kYWANoDataAvailable = @"Not Available";

/*  Comparison strings for wind direction
 *  Compare with object for key kYWAWindDirectionInCompassPoints */
NSString* const kYWAWindDirectionN = @"N";
NSString* const kYWAWindDirectionE = @"E";
NSString* const kYWAWindDirectionS = @"S";
NSString* const kYWAWindDirectionW = @"W";
// Quadrant 1
NSString* const kYWAWindDirectionNNE = @"NNE";
NSString* const kYWAWindDirectionNE = @"NE";
NSString* const kYWAWindDirectionENE = @"ENE";
// Quadrant 2
NSString* const kYWAWindDirectionESE = @"ESE";
NSString* const kYWAWindDirectionSE = @"SE";
NSString* const kYWAWindDirectionSSE = @"SSE";
// Quadrant 3
NSString* const kYWAWindDirectionSSW = @"SSW";
NSString* const kYWAWindDirectionSW = @"SW";
NSString* const kYWAWindDirectionWSW = @"WSW";
// Quadrant 4
NSString* const kYWAWindDirectionWNW = @"WNW";
NSString* const kYWAWindDirectionNW = @"NW";
NSString* const kYWAWindDirectionNNW = @"NNW";

/*  Comparison strings for pressure trends
 *  Compare with object for key kYWAPressureTrend */
NSString* const kYWAPressureTrendFalling = @"0";
NSString* const kYWAPressureTrendRising = @"1";


#pragma mark - INTERFACE

@interface YWeatherAPI()
{
    dispatch_queue_t async_queue; // for async saves to the cache
    NSUserDefaults* userDefaults; // the cache lives here
}
@end


#pragma mark - IMPLEMENTATION

@implementation YWeatherAPI


#pragma mark - INIT and SHARED SINGLETON

/**
 *  Returns the shared singleton instance
 *
 *  @return The singleton object for the class
 */
+ (instancetype)sharedManager
{
    static YWeatherAPI* _sharedManager;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (instancetype) init
{
    self = [super init];
    NSAssert(self, @"YWeatherAPI sharedManager initialization did not succeed.");
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    async_queue = dispatch_queue_create(kYWAAsyncQueueIdentifier, NULL);
    
    // Settings
    _cacheEnabled = kYWADefaultCacheEnabledValue;
    _cacheExpiryInMinutes = kYWADefaultCacheExpiryInMinutes;
    _defaultDistanceUnit = kYWADefaultDistanceUnit;
    _defaultPressureUnit = kYWADefaultPressureUnit;
    _defaultSpeedUnit = kYWADefaultSpeedUnit;
    _defaultTemperatureUnit = kYWADefaultTemperatureUnit;
    
    return self;
}


#pragma mark - TODAY'S FORECAST by COORDINATE, LOCATION, WOEID (empty value for index key)

/**
 *  Gets forecast information for the current day and includes a short description and low and high temperatures in the default temperature unit for a coordinate
 *
 *  @param coordinate Coordinate to get today's forecast for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) todaysForecastForCoordinate:(CLLocation*)coordinate
                             success:(void (^)(NSDictionary* result))success
                             failure:(void (^)(id response, NSError* error))failure
{
    [self todaysForecastForCoordinate:coordinate temperatureUnit:_defaultTemperatureUnit success:success failure:failure];
}

/**
 *  Gets forecast information for the current day and includes a short description and low and high temperatures in the specified temperature unit for a coordinate
 *
 *  @param coordinate      Coordinate to get today's forecast for
 *  @param temperatureUnit Temperature unit for the response that overrides the default
 *  @param success         Callback block that receives the result on success
 *  @param failure         Callback block that receives the bad response and error on failure
 */
- (void) todaysForecastForCoordinate:(CLLocation*)coordinate
                     temperatureUnit:(YWATemperatureUnit)temperatureUnit
                             success:(void (^)(NSDictionary* result))success
                             failure:(void (^)(id response, NSError* error))failure
{
    [self locationStringForCoordinate:coordinate
                              success:^(NSString *locationString)
     {
         [self todaysForecastForLocation:locationString temperatureUnit:temperatureUnit success:success failure:failure];
     }
                              failure:failure];
}

/**
 *  Gets forecast information for the current day and includes a short description and low and high temperatures in the default temperature unit for a location
 *
 *  @param location Location to get today's forecast for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) todaysForecastForLocation:(NSString*)location
                           success:(void (^)(NSDictionary* result))success
                           failure:(void (^)(id response, NSError* error))failure
{
    [self todaysForecastForLocation:location temperatureUnit:_defaultTemperatureUnit success:success failure:failure];
}

/**
 *  Gets forecast information for the current day and includes a short description and low and high temperatures in the specified temperature unit for a location
 *
 *  @param location        Location to get today's forecast for
 *  @param temperatureUnit Temperature unit for the response that overrides the default
 *  @param success         Callback block that receives the result on success
 *  @param failure         Callback block that receives the bad response and error on failure
 */
- (void) todaysForecastForLocation:(NSString*)location
                   temperatureUnit:(YWATemperatureUnit)temperatureUnit
                           success:(void (^)(NSDictionary* result))success
                           failure:(void (^)(id response, NSError* error))failure
{
    [self woeidForLocation:location
                   success:^(NSString *woeid)
     {
         [self todaysForecastForWOEID:woeid temperatureUnit:temperatureUnit success:success failure:failure];
     }
                   failure:failure];
}

/**
 *  Gets forecast information for the current day and includes a short description and low and high temperatures in the default temperature unit for a Yahoo WOEID
 *
 *  @param woeid   Yahoo WOEID to get today's forecast for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) todaysForecastForWOEID:(NSString*)woeid
                        success:(void (^)(NSDictionary* result))success
                        failure:(void (^)(id response, NSError* error))failure
{
    [self todaysForecastForWOEID:woeid temperatureUnit:_defaultTemperatureUnit success:success failure:failure];
}

/**
 *  Gets forecast information for the current day and includes a short description and low and high temperatures in the specified temperature unit for a Yahoo WOEID
 *
 *  @param woeid           Yahoo WOEID to get today's forecast for
 *  @param temperatureUnit Temperature unit for the response that overrides the default
 *  @param success         Callback block that receives the result on success
 *  @param failure         Callback block that receives the bad response and error on failure
 */
- (void) todaysForecastForWOEID:(NSString*)woeid
                temperatureUnit:(YWATemperatureUnit)temperatureUnit
                        success:(void (^)(NSDictionary* result))success
                        failure:(void (^)(id response, NSError* error))failure
{
    [self queryResultForWOEID:woeid
                     yqlQuery:kYWAYQLQueryAll
                    speedUnit:_defaultSpeedUnit
              temperatureUnit:temperatureUnit
                 pressureUnit:_defaultPressureUnit
                 distanceUnit:_defaultDistanceUnit
                      success:^(id result)
     {
         NSArray* YWFiveDaysForecasts = [NSArray arrayWithArray: [[result objectForKey:@"item"] objectForKey:@"forecast"]];
         NSDictionary* today = [YWFiveDaysForecasts objectAtIndex:0];
         
         NSDictionary* packedTodayForecast = [self packagedYWForecastDayInfoFor:today temperatureUnit:temperatureUnit];
         NSMutableDictionary* r = [NSMutableDictionary dictionaryWithDictionary:packedTodayForecast];
         [r setObject:kYWAEmptyValue forKey:kYWAIndex]; // defensive
         [r addEntriesFromDictionary:[self locationInfoFromResult:result]];
         
         
         success([NSDictionary dictionaryWithDictionary:r]);
     }
                      failure:failure];
}


#pragma mark - FIVE DAY FORECAST by COORDINATE, LOCATION, WOEID

/**
 *  Gets forecast information for the next five days starting today and includes a short description and low and high temperatures in the default temperature unit for a coordinate
 *
 *  @param coordinate Coordinate to get five day forecast for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) fiveDayForecastForCoordinate:(CLLocation*)coordinate
                              success:(void (^)(NSDictionary* result))success
                              failure:(void (^)(id response, NSError* error))failure
{
    [self fiveDayForecastForCoordinate:coordinate temperatureUnit:_defaultTemperatureUnit success:success failure:failure];
}

/**
 *  Gets forecast information for the next five days starting today and includes a short description and low and high temperatures in the specified temperature unit for a coordinate
 *
 *  @param coordinate      Coordinate to get five day forecast for
 *  @param temperatureUnit Temperature unit for the response that overrides the default
 *  @param success         Callback block that receives the result on success
 *  @param failure         Callback block that receives the bad response and error on failure
 */
- (void) fiveDayForecastForCoordinate:(CLLocation*)coordinate
                      temperatureUnit:(YWATemperatureUnit)temperatureUnit
                              success:(void (^)(NSDictionary* result))success
                              failure:(void (^)(id response, NSError* error))failure
{
    [self locationStringForCoordinate:coordinate
                              success:^(NSString *locationString)
     {
         [self fiveDayForecastForLocation:locationString temperatureUnit:temperatureUnit success:success failure:failure];
     }
                              failure:failure];
}

/**
 *  Gets forecast information for the next five days starting today and includes a short description and low and high temperatures in the default temperature unit for a location
 *
 *  @param location Location to get five day forecast for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) fiveDayForecastForLocation:(NSString*)location
                            success:(void (^)(NSDictionary* result))success
                            failure:(void (^)(id response, NSError* error))failure
{
    [self fiveDayForecastForLocation:location temperatureUnit:_defaultTemperatureUnit success:success failure:failure];
}

/**
 *  Gets forecast information for the next five days starting today and includes a short description and low and high temperatures in the specified temperature unit for a location
 *
 *  @param location        Location to get five day forecast for
 *  @param temperatureUnit Temperature unit for the response that overrides the default
 *  @param success         Callback block that receives the result on success
 *  @param failure         Callback block that receives the bad response and error on failure
 */
- (void) fiveDayForecastForLocation:(NSString*)location
                    temperatureUnit:(YWATemperatureUnit)temperatureUnit
                            success:(void (^)(NSDictionary* result))success
                            failure:(void (^)(id response, NSError* error))failure
{
    [self woeidForLocation:location
                   success:^(NSString *woeid)
     {
         [self fiveDayForecastForWOEID:woeid temperatureUnit:temperatureUnit success:success failure:failure];
     }
                   failure:failure];
}

/**
 *  Gets forecast information for the next five days starting today and includes a short description and low and high temperatures in the default temperature unit for a Yahoo WOEID
 *
 *  @param woeid   Yahoo WOEID to get five day forecast for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) fiveDayForecastForWOEID:(NSString*)woeid
                         success:(void (^)(NSDictionary* result))success
                         failure:(void (^)(id response, NSError* error))failure
{
    [self fiveDayForecastForWOEID:woeid temperatureUnit:_defaultTemperatureUnit success:success failure:failure];
}

/**
 *  Gets forecast information for the next five days starting today and includes a short description and low and high temperatures in the specified temperature unit for a Yahoo WOEID
 *
 *  @param woeid           Yahoo WOEID to get five day forecast for
 *  @param temperatureUnit Temperature unit for the response that overrides the default
 *  @param success         Callback block that receives the result on success
 *  @param failure         Callback block that receives the bad response and error on failure
 */
- (void) fiveDayForecastForWOEID:(NSString*)woeid
                 temperatureUnit:(YWATemperatureUnit)temperatureUnit
                         success:(void (^)(NSDictionary* result))success
                         failure:(void (^)(id response, NSError* error))failure
{
    [self queryResultForWOEID:woeid
                     yqlQuery:kYWAYQLQueryAll
                    speedUnit:_defaultSpeedUnit
              temperatureUnit:temperatureUnit
                 pressureUnit:_defaultPressureUnit
                 distanceUnit:_defaultDistanceUnit
                      success:^(id result)
     {
         NSArray* YWFiveDayForecasts = [NSArray arrayWithArray: [[result objectForKey:@"item"] objectForKey:@"forecast"]];
         NSMutableArray* fiveDayForecasts = [[NSMutableArray alloc] initWithCapacity:[YWFiveDayForecasts count]];
         
         for (NSDictionary* forecastDay in YWFiveDayForecasts) {
             [fiveDayForecasts addObject:[self packagedYWForecastDayInfoFor:forecastDay temperatureUnit:temperatureUnit]];
         }
         
         NSMutableDictionary* r = [NSMutableDictionary dictionaryWithObjects:@[fiveDayForecasts, fiveDayForecasts] forKeys:@[kYWAIndex, kYWAFiveDayForecasts]];
         [r addEntriesFromDictionary:[self locationInfoFromResult:result]];
         
         success([NSDictionary dictionaryWithDictionary:r]);
     }
                      failure:failure];
}


#pragma mark - ALL CURRENT CONDITIONS (empty value for index key)

/**
 *  Gets all the current weather conditions for a coordinate
 *
 *  @param woeid   Coordinate to get weather condition for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) allCurrentConditionsForCoordinate:(CLLocation*)coordinate
                                   success:(void (^)(NSDictionary* result))success
                                   failure:(void (^)(id response, NSError* error))failure
{
    [self locationStringForCoordinate:coordinate success:^(NSString *locationString) {
        [self allCurrentConditionsForLocation:locationString success:success failure:failure];
    } failure:failure];
}

/**
 *  Gets all the current weather conditions for a location
 *
 *  @param woeid   Location to get weather condition for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) allCurrentConditionsForLocation:(NSString*)location
                                 success:(void (^)(NSDictionary* result))success
                                 failure:(void (^)(id response, NSError* error))failure
{
    [self woeidForLocation:location
                   success:^(NSString *woeid)
     {
         [self allCurrentConditionsForWOEID:woeid success:success failure:failure];
     }
                   failure:failure];
}

/**
 *  Gets all the current weather conditions for a Yahoo WOEID
 *
 *  @param woeid   Yahoo WOEID to get weather condition for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) allCurrentConditionsForWOEID:(NSString*)woeid
                              success:(void (^)(NSDictionary* result))success
                              failure:(void (^)(id response, NSError* error))failure
{
    [self queryResultForWOEID:woeid
                     yqlQuery:kYWAYQLQueryAll
                    speedUnit:_defaultSpeedUnit
              temperatureUnit:_defaultTemperatureUnit
                 pressureUnit:_defaultPressureUnit
                 distanceUnit:_defaultDistanceUnit
                      success:^(id result)
     {
         // wind chill
         NSString* windChillInF = [[result objectForKey:@"wind"] objectForKey:@"chill"];
         NSString* windChillInC = [NSString stringWithFormat:@"%.2f", [self temperatureIn:C from:F value:[windChillInF doubleValue]]];
         // direction
         NSString* windDirectionInDegrees = [[result objectForKey:@"wind"] objectForKey:@"direction"];
         NSString* windDirectionInCompassPoints = [self compassPointForDegree:[windDirectionInDegrees doubleValue]];
         // speed
         NSString* windSpeedInMPH = [[result objectForKey:@"wind"] objectForKey:@"speed"];
         NSString* windSpeedInKMPH = [NSString stringWithFormat: @"%.2f" , [self speedIn:KMPH from:MPH value:[windSpeedInMPH doubleValue]]];
         
         // atmosphere pressure trend
         NSString* pressureTrend = [[result objectForKey:@"atmosphere"] objectForKey:@"rising"];
         // pressure
         NSString* pressureInIN = [[result objectForKey:@"atmosphere"] objectForKey:@"pressure"];
         NSString* pressureInMB = [NSString stringWithFormat:@"%.2f", [self pressureIn:MB from:IN value:[pressureInIN doubleValue]]];
         // humidity
         NSString* humidity = [[result objectForKey:@"atmosphere"] objectForKey:@"humidity"];
         // visibility
         NSString* visibilityInMI = [[result objectForKey:@"atmosphere"] objectForKey:@"visibility"];
         NSString* visibilityInKM = [NSString stringWithFormat:@"%.2f", [self distanceIn:KM from:MI value:[visibilityInMI doubleValue]]];
         
         // astronomy sunrise
         NSString* timeString = [[[result objectForKey:@"item"] objectForKey:@"condition"] objectForKey:@"date"];
         NSString* timeZone = [self timeZoneFromYWTimeString:timeString];
         NSString* srTimeIn12Hour = [[result objectForKey:@"astronomy"] objectForKey:@"sunrise"];
         NSDateComponents* sunriseInLocalTime = [self dateComponentsFor12HourTime:srTimeIn12Hour withShortTimeZone:timeZone];
         // sunset
         NSString* ssTimeIn12Hour = [[result objectForKey:@"astronomy"] objectForKey:@"sunset"];
         NSDateComponents* sunsetInLocalTime = [self dateComponentsFor12HourTime:ssTimeIn12Hour withShortTimeZone:timeZone];
         
         // condition temperature
         NSString* temperatureInF = [[[result objectForKey:@"item"] objectForKey:@"condition"] objectForKey:@"temp"];
         NSString* temperatureInC = [NSString stringWithFormat:@"%.2f", [self temperatureIn:C from:F value:[temperatureInF doubleValue]]];
         // short description
         NSString* shortDescription = [[[result objectForKey:@"item"] objectForKey:@"condition"] objectForKey:@"text"];
         // long description
         NSString* longDescription = [[result objectForKey:@"item"] objectForKey:@"description"];
         // condition code
         NSString* numberCode = [[[result objectForKey:@"item"] objectForKey:@"condition"] objectForKey:@"code"];
         NSString* meaningfulConditionStringForCode = [self weatherConditionForCode:numberCode];
         
         NSMutableDictionary* r = [NSMutableDictionary dictionaryWithObjects:@[windChillInF,
                                                                               windChillInC,
                                                                               windDirectionInCompassPoints,
                                                                               windDirectionInDegrees,
                                                                               windSpeedInMPH,
                                                                               windSpeedInKMPH,
                                                                               
                                                                               pressureTrend,
                                                                               pressureInIN,
                                                                               pressureInMB,
                                                                               humidity,
                                                                               visibilityInMI,
                                                                               visibilityInKM,
                                                                               
                                                                               sunriseInLocalTime,
                                                                               sunsetInLocalTime,
                                                                               
                                                                               temperatureInF,
                                                                               temperatureInC,
                                                                               shortDescription,
                                                                               longDescription,
                                                                               meaningfulConditionStringForCode,
                                                                               numberCode]
                                   
                                                                     forKeys:@[kYWAWindChillInF,
                                                                               kYWAWindChillInC,
                                                                               kYWAWindDirectionInCompassPoints,
                                                                               kYWAWindDirectionInDegrees,
                                                                               kYWAWindSpeedInMPH,
                                                                               kYWAWindSpeedInKMPH,
                                                                               
                                                                               kYWAPressureTrend,
                                                                               kYWAPressureInIN,
                                                                               kYWAPressureInMB,
                                                                               kYWAHumidity,
                                                                               kYWAVisibilityInMI,
                                                                               kYWAVisibilityInKM,
                                                                               
                                                                               kYWASunriseInLocalTime,
                                                                               kYWASunsetInLocalTime,
                                                                               
                                                                               kYWATemperatureInF,
                                                                               kYWATemperatureInC,
                                                                               kYWAShortDescription,
                                                                               kYWALongDescription,
                                                                               kYWACondition,
                                                                               kYWAConditionNumber]];
         
         [r setObject:kYWAEmptyValue forKey:kYWAIndex]; // defensive
         [r addEntriesFromDictionary:[self locationInfoFromResult:result]];
         success([NSDictionary dictionaryWithDictionary:r]);
     }
                      failure:failure];
}


#pragma mark - CODE CONDITIONS by COORDINATE, LOCATION, WOEID

/**
 *  Gets the weather condition code for a coordinate
 *
 *  @param location   Coordinate to get weather condition for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 *  @see https://developer.yahoo.com/weather/documentation.html#codes
 *  @see -weatherConditionForCode:
 */
- (void) conditionCodeForCoordinate:(CLLocation*)coordinate
                            success:(void (^)(NSDictionary*))success
                            failure:(void (^)(id response, NSError* error))failure
{
    [self locationStringForCoordinate:coordinate success:^(NSString *locationString) {
        [self conditionCodeForLocation:locationString success:success failure:failure];
    } failure:failure];
}

/**
 *  Gets the weather condition code for a location
 *
 *  @param location   Location to get weather condition for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 *  @see https://developer.yahoo.com/weather/documentation.html#codes
 *  @see -weatherConditionForCode:
 */
- (void) conditionCodeForLocation:(NSString*)location
                          success:(void (^)(NSDictionary*))success
                          failure:(void (^)(id response, NSError* error))failure
{
    [self woeidForLocation:location
                   success:^(NSString *woeid)
     {
         [self conditionCodeForWOEID:woeid success:success failure:failure];
     }
                   failure:failure];
}

/**
 *  Gets the weather condition code for a Yahoo WOEID
 *
 *  @param woeid   Yahoo WOEID to get weather condition for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 *  @see https://developer.yahoo.com/weather/documentation.html#codes
 *  @see -weatherConditionForCode:
 */
- (void) conditionCodeForWOEID:(NSString*)woeid
                       success:(void (^)(NSDictionary*))success
                       failure:(void (^)(id response, NSError* error))failure
{
    [self queryResultForWOEID:woeid
                     yqlQuery:kYWAYQLQueryAll
                    speedUnit:_defaultSpeedUnit
              temperatureUnit:_defaultTemperatureUnit
                 pressureUnit:_defaultPressureUnit
                 distanceUnit:_defaultDistanceUnit
                      success:^(id result)
     {
         NSString* numberCode = [[[result objectForKey:@"item"] objectForKey:@"condition"] objectForKey:@"code"];
         NSString* meaningfulConditionStringForCode = [self weatherConditionForCode:numberCode];
         
         NSMutableDictionary* r = [NSMutableDictionary dictionaryWithObjects:@[numberCode,
                                                                               numberCode,
                                                                               meaningfulConditionStringForCode]
                                                                     forKeys:@[kYWAIndex,
                                                                               kYWAConditionNumber,
                                                                               kYWACondition]];
         [r addEntriesFromDictionary:[self locationInfoFromResult:result]];
         success([NSDictionary dictionaryWithDictionary:r]);
     }
                      failure:failure];
}


#pragma mark - LONG DESCRIPTION by COORDINATE, LOCATION, WOEID

/**
 *  Gets a long description of the weather for the current day for a coordinate
 *
 *  @param coordinate Coordinate to get long description for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) longDescriptionForCoordinate:(CLLocation*)coordinate
                              success:(void (^)(NSDictionary* result))success
                              failure:(void (^)(id response, NSError* error))failure
{
    [self locationStringForCoordinate:coordinate
                              success:^(NSString *locationString) {
                                  [self longDescriptionForLocation:locationString success:success failure:failure];
                              } failure:failure];
}

/**
 *  Gets a long description of the weather for the current day for a location
 *
 *  @param location Location to get long description for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) longDescriptionForLocation:(NSString*)location
                            success:(void (^)(NSDictionary* result))success
                            failure:(void (^)(id response, NSError* error))failure
{
    [self woeidForLocation:location
                   success:^(NSString *woeid) {
                       [self longDescriptionForWOEID:woeid success:success failure:failure];
                   } failure:failure];
}

/**
 *  Gets a long description of the weather for the current day for a Yahoo WOEID
 *
 *  @param woeid   Yahoo WOEID to get long description for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) longDescriptionForWOEID:(NSString*)woeid
                         success:(void (^)(NSDictionary* result))success
                         failure:(void (^)(id response, NSError* error))failure
{
    [self queryResultForWOEID:woeid
                     yqlQuery:kYWAYQLQueryAll
                    speedUnit:_defaultSpeedUnit
              temperatureUnit:_defaultTemperatureUnit
                 pressureUnit:_defaultPressureUnit
                 distanceUnit:_defaultDistanceUnit
                      success:^(id result)
     {
         NSString* longDescription = [[result objectForKey:@"item"] objectForKey:@"description"];
         NSMutableDictionary* r = [NSMutableDictionary dictionaryWithObjects:@[longDescription, longDescription] forKeys:@[kYWAIndex, kYWALongDescription]];
         [r addEntriesFromDictionary:[self locationInfoFromResult:result]];
         success([NSDictionary dictionaryWithDictionary:r]);
     }
                      failure:failure
     ];
}


#pragma mark - SHORT DESCRIPTION by COORDINATE, LOCATION, WOEID

/**
 *  Gets a short description of the weather for the current day for a coordinate
 *
 *  @param coordinate Coordinate to get short description for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) shortDescriptionForCoordinate:(CLLocation*)coordinate
                               success:(void (^)(NSDictionary* result))success
                               failure:(void (^)(id response, NSError* error))failure
{
    [self locationStringForCoordinate:coordinate
                              success:^(NSString *locationString) {
                                  [self shortDescriptionForLocation:locationString success:success failure:failure];
                              } failure:failure];
}

/**
 *  Gets a short description of the weather for the current day for a location
 *
 *  @param location Location to get short description for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) shortDescriptionForLocation:(NSString*)location
                             success:(void (^)(NSDictionary* result))success
                             failure:(void (^)(id response, NSError* error))failure
{
    [self woeidForLocation:location
                   success:^(NSString *woeid) {
                       [self shortDescriptionForWOEID:woeid success:success failure:failure];
                   } failure:failure];
}

/**
 *  Gets a short description of the weather for the current day for a Yahoo WOEID
 *
 *  @param woeid   Yahoo WOEID to get short description for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) shortDescriptionForWOEID:(NSString*)woeid
                          success:(void (^)(NSDictionary* result))success
                          failure:(void (^)(id response, NSError* error))failure
{
    [self queryResultForWOEID:woeid
                     yqlQuery:kYWAYQLQueryAll
                    speedUnit:_defaultSpeedUnit
              temperatureUnit:_defaultTemperatureUnit
                 pressureUnit:_defaultPressureUnit
                 distanceUnit:_defaultDistanceUnit
                      success:^(id result)
     {
         NSString* shortDescription = [[[result objectForKey:@"item"] objectForKey:@"condition"] objectForKey:@"text"];
         NSMutableDictionary* r = [NSMutableDictionary dictionaryWithObjects:@[shortDescription, shortDescription] forKeys:@[kYWAIndex, kYWAShortDescription]];
         [r addEntriesFromDictionary:[self locationInfoFromResult:result]];
         success([NSDictionary dictionaryWithDictionary:r]);
     } failure:failure
     ];
}


#pragma mark - TEMPERATURE by COORDINATE, LOCATION, WOEID

/**
 *  Gets the current temperature in the default temperature unit for a coordinate
 *
 *  @param coordinate Coordinate to get temperature for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) temperatureForCoordinate:(CLLocation*)coordinate
                          success:(void (^)(NSDictionary* result))success
                          failure:(void (^)(id response, NSError* error))failure
{
    [self temperatureForCoordinate:coordinate temperatureUnit:_defaultTemperatureUnit success:success failure:failure];
}

/**
 *  Gets the current temperature in the specified temperature unit for a coordinate
 *
 *  @param coordinate      Coordinate to get temperature for
 *  @param temperatureUnit Temperature unit for the response that overrides the default
 *  @param success         Callback block that receives the result on success
 *  @param failure         Callback block that receives the bad response and error on failure
 */
- (void) temperatureForCoordinate:(CLLocation*)coordinate
                  temperatureUnit:(YWATemperatureUnit)temperatureUnit
                          success:(void (^)(NSDictionary* result))success
                          failure:(void (^)(id response, NSError* error))failure
{
    [self locationStringForCoordinate:coordinate
                              success:^(NSString *locationString) {
                                  [self temperatureForLocation:locationString temperatureUnit:temperatureUnit success:success failure:failure];
                              } failure:failure];
}

/**
 *  Gets the current temperature in the default temperature unit for a location
 *
 *  @param location Location to get temperature for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) temperatureForLocation:(NSString*)location
                        success:(void (^)(NSDictionary* result))success
                        failure:(void (^)(id response, NSError* error))failure
{
    [self temperatureForLocation:location temperatureUnit:_defaultTemperatureUnit success:success failure:failure];
}

/**
 *  Gets the current temperature in the specified temperature unit for a location
 *
 *  @param location        Location to get temperature for
 *  @param temperatureUnit Temperature unit for the response that overrides the default
 *  @param success         Callback block that receives the result on success
 *  @param failure         Callback block that receives the bad response and error on failure
 */
- (void) temperatureForLocation:(NSString*)location
                temperatureUnit:(YWATemperatureUnit)temperatureUnit
                        success:(void (^)(NSDictionary* result))success
                        failure:(void (^)(id response, NSError* error))failure
{
    [self woeidForLocation:location
                   success:^(NSString *woeid) {
                       [self temperatureForWOEID:woeid temperatureUnit:temperatureUnit success:success failure:failure];
                   } failure:failure];
}

/**
 *  Gets the current temperature in the default temperature unit for a Yahoo WOEID
 *
 *  @param woeid   Yahoo WOEID to get temperature for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) temperatureForWOEID:(NSString*)woeid
                     success:(void (^)(NSDictionary* result))success
                     failure:(void (^)(id response, NSError* error))failure
{
    [self temperatureForWOEID:woeid temperatureUnit:_defaultTemperatureUnit success:success failure:failure];
}

/**
 *  Gets the current temperature in the specified temperature unit for a Yahoo WOEID
 *
 *  @param woeid           Yahoo WOEID to get temperature for
 *  @param temperatureUnit Temperature unit for the response that overrides the default
 *  @param success         Callback block that receives the result on success
 *  @param failure         Callback block that receives the bad response and error on failure
 */
- (void) temperatureForWOEID:(NSString*)woeid
             temperatureUnit:(YWATemperatureUnit)temperatureUnit
                     success:(void (^)(NSDictionary* result))success
                     failure:(void (^)(id response, NSError* error))failure
{
    [self queryResultForWOEID:woeid
                     yqlQuery:kYWAYQLQueryAll
                    speedUnit:_defaultSpeedUnit
              temperatureUnit:temperatureUnit
                 pressureUnit:_defaultPressureUnit
                 distanceUnit:_defaultDistanceUnit
                      success:^(id result)
     {
         NSString* temperatureInF = [[[result objectForKey:@"item"] objectForKey:@"condition"] objectForKey:@"temp"];
         NSString* temperatureInC = [NSString stringWithFormat:@"%.2f", [self temperatureIn:C from:F value:[temperatureInF doubleValue]]];
         NSString* index = (temperatureUnit == F) ? temperatureInF : temperatureInC;
         
         NSMutableDictionary* r = [NSMutableDictionary dictionaryWithObjects:@[index,
                                                                               temperatureInF,
                                                                               temperatureInC]
                                                                     forKeys:@[kYWAIndex,
                                                                               kYWATemperatureInF,
                                                                               kYWATemperatureInC]];
         [r addEntriesFromDictionary:[self locationInfoFromResult:result]];
         success([NSDictionary dictionaryWithDictionary:r]);
     }
                      failure:failure];
}


#pragma mark - PRESSURE TREND by COORDINATE, LOCATION, WOEID


/**
 *  Gets the current pressure trend for a coordinate
 *
 *  @param coordinate Coordinate to get pressure trend for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) pressureTrendForCoordinate:(CLLocation*)coordinate
                            success:(void (^)(NSDictionary* result))success
                            failure:(void (^)(id response, NSError* error))failure
{
    [self locationStringForCoordinate:coordinate
                              success:^(NSString *locationString) {
                                  [self pressureTrendForLocation:locationString success:success failure:failure];
                              } failure:failure];
}

/**
 *  Gets the current pressure trend for a location
 *
 *  @param location Location to get pressure trend for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) pressureTrendForLocation:(NSString*)location
                          success:(void (^)(NSDictionary* result))success
                          failure:(void (^)(id response, NSError* error))failure
{
    [self woeidForLocation:location
                   success:^(NSString *woeid) {
                       [self pressureTrendForWOEID:woeid success:success failure:failure];
                   } failure:failure];
}

/**
 *  Gets the current pressure trend for a Yahoo WOEID
 *
 *  @param woeid   Yahoo WOEID to get pressure trend for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) pressureTrendForWOEID:(NSString*)woeid
                       success:(void (^)(NSDictionary* result))success
                       failure:(void (^)(id response, NSError* error))failure
{
    [self queryResultForWOEID:woeid
                     yqlQuery:kYWAYQLQueryAll
                    speedUnit:_defaultSpeedUnit
              temperatureUnit:_defaultTemperatureUnit
                 pressureUnit:_defaultPressureUnit
                 distanceUnit:_defaultDistanceUnit
                      success:^(id result)
     {
         NSString* pressureTrend = [[result objectForKey:@"atmosphere"] objectForKey:@"rising"];
         NSMutableDictionary* r = [NSMutableDictionary dictionaryWithObjects:@[pressureTrend, pressureTrend] forKeys:@[kYWAIndex, kYWAPressureTrend]];
         [r addEntriesFromDictionary:[self locationInfoFromResult:result]];
         success([NSDictionary dictionaryWithDictionary:r]);
     }
                      failure:failure
     ];
}


#pragma mark - PRESSURE by COORDINATE, LOCATION, WOEID (optional: YWAPressureUnit)

/**
 *  Gets the current pressure in the default pressure unit for a coordinate
 *
 *  @param coordinate Coordinate to get pressure for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) pressureForCoordinate:(CLLocation*)coordinate
                       success:(void (^)(NSDictionary* result))success
                       failure:(void (^)(id response, NSError* error))failure
{
    [self pressureForCoordinate:coordinate pressureUnit:_defaultPressureUnit success:success failure:failure];
}

/**
 *  Gets the current pressure in the specified pressure unit for a coordinate
 *
 *  @param coordinate   Coordinate to get pressure for
 *  @param pressureUnit Pressure unit for the response that overrides the default
 *  @param success      Callback block that receives the result on success
 *  @param failure      Callback block that receives the bad response and error on failure
 */
- (void) pressureForCoordinate:(CLLocation*)coordinate
                  pressureUnit:(YWAPressureUnit)pressureUnit
                       success:(void (^)(NSDictionary* result))success
                       failure:(void (^)(id response, NSError* error))failure
{
    [self locationStringForCoordinate:coordinate
                              success:^(NSString* locationString) {
                                  [self pressureForLocation:locationString pressureUnit:pressureUnit success:success failure:failure];
                              } failure:failure
     ];
}

/**
 *  Gets the current pressure in the default pressure unit for a location
 *
 *  @param location Location to get pressure for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) pressureForLocation:(NSString*)location
                     success:(void (^)(NSDictionary* result))success
                     failure:(void (^)(id response, NSError* error))failure
{
    [self pressureForLocation:location pressureUnit:_defaultPressureUnit success:success failure:failure];
}

/**
 *  Gets the current pressure in the specified pressure unit for a location
 *
 *  @param location     Location to get pressure for
 *  @param pressureUnit Pressure unit for the response that overrides the default
 *  @param success      Callback block that receives the result on success
 *  @param failure      Callback block that receives the bad response and error on failure
 */
- (void) pressureForLocation:(NSString*)location
                pressureUnit:(YWAPressureUnit)pressureUnit
                     success:(void (^)(NSDictionary* result))success
                     failure:(void (^)(id response, NSError* error))failure
{
    [self woeidForLocation:location
                   success:^(NSString *woeid) {
                       [self pressureForWOEID:woeid pressureUnit:pressureUnit success:success failure:failure];
                   } failure:failure
     ];
}

/**
 *  Gets the current pressure in the default pressure unit for a Yahoo WOEID
 *
 *  @param woeid   Yahoo WOEID to get pressure for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) pressureForWOEID:(NSString*)woeid
                  success:(void (^)(NSDictionary* result))success
                  failure:(void (^)(id response, NSError* error))failure
{
    [self pressureForWOEID:woeid pressureUnit:_defaultPressureUnit success:success failure:failure];
}

/**
 *  Gets the current pressure in the specified pressure unit for a Yahoo WOEID
 *
 *  @param woeid        Yahoo WOEID to get pressure for
 *  @param pressureUnit Pressure unit for the response that overrides the default
 *  @param success      Callback block that receives the result on success
 *  @param failure      Callback block that receives the bad response and error on failure
 */
- (void) pressureForWOEID:(NSString*)woeid
             pressureUnit:(YWAPressureUnit)pressureUnit
                  success:(void (^)(NSDictionary* result))success
                  failure:(void (^)(id response, NSError* error))failure
{
    [self queryResultForWOEID:woeid
                     yqlQuery:kYWAYQLQueryAll
                    speedUnit:_defaultSpeedUnit
              temperatureUnit:_defaultTemperatureUnit
                 pressureUnit:pressureUnit
                 distanceUnit:_defaultDistanceUnit
                      success:^(id result)
     {
         NSString* pressureInIN = [[result objectForKey:@"atmosphere"] objectForKey:@"pressure"];
         NSString* pressureInMB = [NSString stringWithFormat:@"%.2f", [self pressureIn:MB from:IN value:[pressureInIN doubleValue]]];
         NSString* index = (pressureUnit == IN) ? pressureInIN : pressureInMB;
         
         NSMutableDictionary* r = [NSMutableDictionary dictionaryWithObjects:@[index,
                                                                               pressureInIN,
                                                                               pressureInMB]
                                                                     forKeys:@[kYWAIndex,
                                                                               kYWAPressureInIN,
                                                                               kYWAPressureInMB]];
         [r addEntriesFromDictionary:[self locationInfoFromResult:result]];
         success([NSDictionary dictionaryWithDictionary:r]);
     }
                      failure:failure
     ];
}


#pragma mark - VISIBILITY by COORDINATE, LOCATION, WOEID (optional: YWADistanceUnit)

/**
 *  Gets the current visibility distance in the default distance unit for a coordinate
 *
 *  @param coordinate Coordinate to get visibility for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) visibilityForCoordinate:(CLLocation*)coordinate
                         success:(void (^)(NSDictionary* result))success
                         failure:(void (^)(id response, NSError* error))failure
{
    [self visibilityForCoordinate:coordinate distanceUnit:_defaultDistanceUnit success:success failure:failure];
}

/**
 *  Gets the current visibility distance in the specified distance unit for a coordinate
 *
 *  @param coordinate   Coordinate to get visibility for
 *  @param distanceUnit Distance unit for the response that overrides the default
 *  @param success      Callback block that receives the result on success
 *  @param failure      Callback block that receives the bad response and error on failure
 */
- (void) visibilityForCoordinate:(CLLocation*)coordinate
                    distanceUnit:(YWADistanceUnit)distanceUnit
                         success:(void (^)(NSDictionary* result))success
                         failure:(void (^)(id response, NSError* error))failure
{
    [self locationStringForCoordinate:coordinate
                              success:^(NSString *locationString)
     {
         [self visibilityForLocation:locationString distanceUnit:distanceUnit success:success failure:failure];
     }
                              failure:failure];
}

/**
 *  Gets the current visibility distance in the default distance unit for a location
 *
 *  @param location Location to get visibility for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) visibilityForLocation:(NSString*)location
                       success:(void (^)(NSDictionary* result))success
                       failure:(void (^)(id response, NSError* error))failure
{
    [self visibilityForLocation:location distanceUnit:_defaultDistanceUnit success:success failure:failure];
}

/**
 *  Gets the current visibility distance in the specified distance unit for a location
 *
 *  @param location     Location to get visibility for
 *  @param distanceUnit Distance unit for the response that overrides the default
 *  @param success      Callback block that receives the result on success
 *  @param failure      Callback block that receives the bad response and error on failure
 */
- (void) visibilityForLocation:(NSString*)location
                  distanceUnit:(YWADistanceUnit)distanceUnit
                       success:(void (^)(NSDictionary* result))success
                       failure:(void (^)(id response, NSError* error))failure
{
    [self woeidForLocation:location
                   success:^(NSString *woeid)
     {
         [self visibilityForWOEID:woeid distanceUnit:distanceUnit success:success failure:failure];
     }
                   failure:failure];
}

/**
 *  Gets the current visibility distance in the default distance unit for a Yahoo WOEID
 *
 *  @param woeid   Yahoo WOEID to get visibility for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) visibilityForWOEID:(NSString*)woeid
                    success:(void (^)(NSDictionary* result))success
                    failure:(void (^)(id response, NSError* error))failure
{
    [self visibilityForWOEID:woeid distanceUnit:_defaultDistanceUnit success:success failure:failure];
}

/**
 *  Gets the current visibility distance in the specified distance unit for a Yahoo WOEID
 *
 *  @param woeid        Yahoo WOEID to get visibility for
 *  @param distanceUnit Distance unit for the response that overrides the default
 *  @param success      Callback block that receives the result on success
 *  @param failure      Callback block that receives the bad response and error on failure
 */
- (void) visibilityForWOEID:(NSString*)woeid
               distanceUnit:(YWADistanceUnit)distanceUnit
                    success:(void (^)(NSDictionary* result))success
                    failure:(void (^)(id response, NSError* error))failure
{
    [self queryResultForWOEID:woeid
                     yqlQuery:kYWAYQLQueryAll
                    speedUnit:_defaultSpeedUnit
              temperatureUnit:_defaultTemperatureUnit
                 pressureUnit:_defaultPressureUnit
                 distanceUnit:distanceUnit
                      success:^(id result)
     {
         NSString* visibilityInMI = [[result objectForKey:@"atmosphere"] objectForKey:@"visibility"];
         NSString* visibilityInKM = [NSString stringWithFormat:@"%.2f", [self distanceIn:KM from:MI value:[visibilityInMI doubleValue]]];
         NSString* index = (distanceUnit == MI) ? visibilityInMI : visibilityInKM;
         
         
         NSMutableDictionary* r = [NSMutableDictionary dictionaryWithObjects:@[index,
                                                                               visibilityInMI,
                                                                               visibilityInKM]
                                                                     forKeys:@[kYWAIndex,
                                                                               kYWAVisibilityInMI,
                                                                               kYWAVisibilityInKM]];
         [r addEntriesFromDictionary:[self locationInfoFromResult:result]];
         success([NSDictionary dictionaryWithDictionary:r]);
     }
                      failure:failure
     ];
}


#pragma mark - HUMIDITY by COORDINATE, LOCATION, WOEID

/**
 *  Gets the current humidity for a coordinate
 *
 *  @param coordinate Coordinate to get humidity for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) humidityForCoordinate:(CLLocation*)coordinate
                       success:(void (^)(NSDictionary* result))success
                       failure:(void (^)(id response, NSError *))failure
{
    [self locationStringForCoordinate:coordinate
                              success:^(NSString *locationString) {
                                  [self humidityForLocation:locationString success:success failure:failure];
                              } failure:failure];
}

/**
 *  Gets the current humidity for a location
 *
 *  @param location Location to get humidity for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) humidityForLocation:(NSString*)location
                     success:(void (^)(NSDictionary* result))success
                     failure:(void (^)(id response, NSError* error))failure
{
    [self woeidForLocation:location
                   success:^(NSString *woeid) {
                       [self humidityForWOEID:woeid success:success failure:failure];
                   } failure:failure
     ];
}

/**
 *  Gets the current humidity for a Yahoo WOEID
 *
 *  @param woeid   Yahoo WOEID to get humidity for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) humidityForWOEID:(NSString*) woeid
                  success:(void (^)(NSDictionary* result))success
                  failure:(void (^)(id response, NSError* error))failure
{
    [self queryResultForWOEID:woeid
                     yqlQuery:kYWAYQLQueryAll
                    speedUnit:_defaultSpeedUnit
              temperatureUnit:_defaultTemperatureUnit
                 pressureUnit:_defaultPressureUnit
                 distanceUnit:_defaultDistanceUnit
                      success:^(id result)
     {
         NSString* humidity = [[result objectForKey:@"atmosphere"] objectForKey:@"humidity"];
         NSMutableDictionary* r = [NSMutableDictionary dictionaryWithObjects:@[humidity, humidity] forKeys:@[kYWAIndex, kYWAHumidity]];
         [r addEntriesFromDictionary:[self locationInfoFromResult:result]];
         success([NSDictionary dictionaryWithDictionary:r]);
     }
                      failure:failure];
}


#pragma mark - SUNRISE by COORDINATE, LOCATION, WOEID


/**
 *  Gets the sunrise time for the current day for a coordinate in its local time
 *
 *  @param coordinate Coordinate to get sunrise time for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) sunriseForCoordinate:(CLLocation*)coordinate
                      success:(void (^)(NSDictionary* result))success
                      failure:(void (^)(id response, NSError* error))failure
{
    [self locationStringForCoordinate:coordinate
                              success:^(NSString *locationString) {
                                  [self sunriseForLocation:locationString success:success failure:failure];
                              } failure:failure];
}

/**
 *  Gets the sunrise time for the current day for a location in its local time
 *
 *  @param location Location to get sunrise time for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) sunriseForLocation:(NSString*)location
                    success:(void (^)(NSDictionary* result))success
                    failure:(void (^)(id response, NSError* error))failure
{
    [self woeidForLocation:location
                   success:^(NSString *woeid) {
                       [self sunriseForWOEID:woeid success:success failure:failure];
                   } failure:failure
     ];
}

/**
 *  Gets the sunrise time for the current day for a Yahoo WOEID in its local time
 *
 *  @param woeid   Yahoo WOEID to get sunrise time for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) sunriseForWOEID:(NSString*) woeid
                 success:(void (^)(NSDictionary* result))success
                 failure:(void (^)(id response, NSError* error))failure
{
    [self queryResultForWOEID:woeid
                     yqlQuery:kYWAYQLQueryAll
                    speedUnit:_defaultSpeedUnit
              temperatureUnit:_defaultTemperatureUnit
                 pressureUnit:_defaultPressureUnit
                 distanceUnit:_defaultDistanceUnit
                      success:^(id result)
     {
         NSString* timeIn12Hour = [[result objectForKey:@"astronomy"] objectForKey:@"sunrise"];
         NSString* timeString = [[[result objectForKey:@"item"] objectForKey:@"condition"] objectForKey:@"date"];
         NSString* timeZone = [self timeZoneFromYWTimeString:timeString];
         NSDateComponents* sunriseInLocalTime = [self dateComponentsFor12HourTime:timeIn12Hour withShortTimeZone:timeZone];
         
         NSMutableDictionary* r = [NSMutableDictionary dictionaryWithObjects:@[sunriseInLocalTime, sunriseInLocalTime] forKeys:@[kYWAIndex, kYWASunriseInLocalTime]];
         [r addEntriesFromDictionary:[self locationInfoFromResult:result]];
         success([NSDictionary dictionaryWithDictionary:r]);
     }
                      failure:failure
     ];
}


#pragma mark - SUNSET by COORDINATE, LOCATION, WOEID

/**
 *  Gets the sunset time for the current day for a coordinate in its local time
 *
 *  @param coordinate Coordinate to get sunset time for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) sunsetForCoordinate:(CLLocation*)coordinate
                     success:(void (^)(NSDictionary* result))success
                     failure:(void (^)(id response, NSError* error))failure
{
    [self locationStringForCoordinate:coordinate
                              success:^(NSString *locationString) {
                                  [self sunsetForLocation:locationString success:success failure:failure];
                              } failure:failure];
}

/**
 *  Gets the sunset time for the current day for a location in its local time
 *
 *  @param location Location to get sunset time for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) sunsetForLocation:(NSString*) location
                   success:(void (^)(NSDictionary* result))success
                   failure:(void (^)(id response, NSError* error))failure
{
    [self woeidForLocation:location
                   success:^(NSString *woeid) {
                       [self sunsetForWOEID:woeid success:success failure:failure];
                   } failure:failure
     ];
}

/**
 *  Gets the sunset time for the current day for a Yahoo WOEID in its local time
 *
 *  @param woeid   Yahoo WOEID to get sunset time for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) sunsetForWOEID:(NSString*) woeid
                success:(void (^)(NSDictionary* result))success
                failure:(void (^)(id response, NSError* error))failure
{
    [self queryResultForWOEID:woeid
                     yqlQuery:kYWAYQLQueryAll
                    speedUnit:_defaultSpeedUnit
              temperatureUnit:_defaultTemperatureUnit
                 pressureUnit:_defaultPressureUnit
                 distanceUnit:_defaultDistanceUnit
                      success:^(id result)
     {
         NSString* timeIn12Hour = [[result objectForKey:@"astronomy"] objectForKey:@"sunset"];
         NSString* timeString = [[[result objectForKey:@"item"] objectForKey:@"condition"] objectForKey:@"date"];
         NSString* timeZone = [self timeZoneFromYWTimeString:timeString];
         NSDateComponents* sunsetInLocalTime = [self dateComponentsFor12HourTime:timeIn12Hour withShortTimeZone:timeZone];
         
         NSMutableDictionary* r = [NSMutableDictionary dictionaryWithObjects:@[sunsetInLocalTime, sunsetInLocalTime] forKeys:@[kYWAIndex, kYWASunsetInLocalTime]];
         [r addEntriesFromDictionary:[self locationInfoFromResult:result]];
         success([NSDictionary dictionaryWithDictionary:r]);
     }
                      failure:failure
     ];
}


#pragma mark - WIND CHILL by COORDINATE, LOCATION, WOEID (optional: YWATemperatureUnit)

/**
 *  Gets the current wind chill temperature in the default temperature unit for a coordinate
 *
 *  @param coordinate Coordinate to get wind chill for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) windChillForCoordinate:(CLLocation*)coordinate
                        success:(void (^)(NSDictionary* result))success
                        failure:(void (^)(id response, NSError* error))failure
{
    [self windChillForCoordinate:coordinate temperatureUnit:_defaultTemperatureUnit success:success failure:failure];
}

/**
 *  Gets the current wind chill temperature in the specified temperature unit for a coordinate
 *
 *  @param coordinate      Coordinate to get wind chill for
 *  @param temperatureUnit Temperature unit for the response that overrides the default
 *  @param success         Callback block that receives the result on success
 *  @param failure         Callback block that receives the bad response and error on failure
 */
- (void) windChillForCoordinate:(CLLocation*)coordinate
                temperatureUnit:(YWATemperatureUnit)temperatureUnit
                        success:(void (^)(NSDictionary* result))success
                        failure:(void (^)(id response, NSError* error))failure
{
    [self locationStringForCoordinate:coordinate
                              success:^(NSString *locationString) {
                                  [self windChillForLocation:locationString temperatureUnit:temperatureUnit success:success failure:failure];
                              } failure:failure];
}

/**
 *  Gets the current wind chill temperature in the default temperature unit for a location
 *
 *  @param location Location to get wind chill for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) windChillForLocation:(NSString*)location
                      success:(void (^)(NSDictionary* result))success
                      failure:(void (^)(id response, NSError* error))failure
{
    [self windChillForLocation:location temperatureUnit:_defaultTemperatureUnit success:success failure:failure];
}

/**
 *  Gets the current wind chill temperature in the specified temperature unit for a location
 *
 *  @param location        Location to get wind chill for
 *  @param temperatureUnit Temperature unit for the response that overrides the default
 *  @param success         Callback block that receives the result on success
 *  @param failure         Callback block that receives the bad response and error on failure
 */
- (void) windChillForLocation:(NSString*)location
              temperatureUnit:(YWATemperatureUnit)temperatureUnit
                      success:(void (^)(NSDictionary* result))success
                      failure:(void (^)(id response, NSError* error))failure
{
    [self woeidForLocation:location
                   success:^(NSString *woeid) {
                       [self windChillForWOEID:woeid temperatureUnit:temperatureUnit success:success failure:failure];
                   } failure:failure
     ];
}

/**
 *  Gets the current wind chill temperature in the default temperature unit for a Yahoo WOEID
 *
 *  @param woeid   Yahoo WOEID to get wind chill for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) windChillForWOEID:(NSString*) woeid
                   success:(void (^)(NSDictionary* result))success
                   failure:(void (^)(id response, NSError* error))failure
{
    [self windChillForWOEID:woeid temperatureUnit:_defaultTemperatureUnit success:success failure:failure];
}

/**
 *  Gets the current wind chill temperature in the specified temperature unit for a Yahoo WOEID
 *
 *  @param woeid           Yahoo WOEID to get wind chill for
 *  @param temperatureUnit Temperature unit for the response that overrides the default
 *  @param success         Callback block that receives the result on success
 *  @param failure         Callback block that receives the bad response and error on failure
 */
- (void) windChillForWOEID:(NSString*) woeid
           temperatureUnit:(YWATemperatureUnit)temperatureUnit
                   success:(void (^)(NSDictionary* result))success
                   failure:(void (^)(id response, NSError* error))failure
{
    [self queryResultForWOEID:woeid
                     yqlQuery:kYWAYQLQueryAll
                    speedUnit:_defaultSpeedUnit
              temperatureUnit:temperatureUnit
                 pressureUnit:_defaultPressureUnit
                 distanceUnit:_defaultDistanceUnit
                      success:^(id result)
     {
         NSString* windChillInF = [[result objectForKey:@"wind"] objectForKey:@"chill"];
         NSString* windChillInC = [NSString stringWithFormat:@"%.2f", [self temperatureIn:C from:F value:[windChillInF doubleValue]]];
         NSString* index = temperatureUnit == MPH ? windChillInF : windChillInC;
         
         
         NSMutableDictionary* r = [NSMutableDictionary dictionaryWithObjects:@[index,
                                                                               windChillInF,
                                                                               windChillInC]
                                                                     forKeys:@[kYWAIndex,
                                                                               kYWAWindChillInF,
                                                                               kYWAWindChillInC]];
         [r addEntriesFromDictionary:[self locationInfoFromResult:result]];
         success([NSDictionary dictionaryWithDictionary:r]);
     }
                      failure:failure
     ];
}


#pragma mark - WIND DIRECTION by COORDINATE, LOCATION, WOEID

/**
 *  Gets the current wind direction for a coordinate
 *
 *  @param coordinate Coordinate to get wind direction for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) windDirectionForCoordinate:(CLLocation*)coordinate
                            success:(void (^)(NSDictionary* result))success
                            failure:(void (^)(id response, NSError* error))failure
{
    [self locationStringForCoordinate:coordinate
                              success:^(NSString *locationString) {
                                  [self windDirectionForLocation:locationString success:success failure:failure];
                              } failure:failure];
}

/**
 *  Gets the current wind direction for a location
 *
 *  @param location Location to get wind direction for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) windDirectionForLocation:(NSString*)location
                          success:(void (^)(NSDictionary* result))success
                          failure:(void (^)(id response, NSError* error))failure
{
    [self woeidForLocation:location
                   success:^(NSString *woeid) {
                       [self windDirectionForWOEID:woeid success:success failure:failure];
                   } failure:failure
     ];
}

/**
 *  Gets the current wind direction for a Yahoo WOEID
 *
 *  @param woeid   Yahoo WOEID to get wind direction for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) windDirectionForWOEID:(NSString*)woeid
                       success:(void (^)(NSDictionary* result))success
                       failure:(void (^)(id response, NSError* error))failure
{
    [self queryResultForWOEID:woeid
                     yqlQuery:kYWAYQLQueryAll
                    speedUnit:_defaultSpeedUnit
              temperatureUnit:_defaultTemperatureUnit
                 pressureUnit:_defaultPressureUnit
                 distanceUnit:_defaultDistanceUnit
                      success:^(id result)
     {
         NSString* windDirectionInDegrees = [[result objectForKey:@"wind"] objectForKey:@"direction"];
         NSString* windDirectionInCompassPoints = [self compassPointForDegree:[windDirectionInDegrees doubleValue]];
         
         NSMutableDictionary* r = [NSMutableDictionary dictionaryWithObjects:@[windDirectionInCompassPoints,
                                                                               windDirectionInDegrees,
                                                                               windDirectionInCompassPoints]
                                                                     forKeys:@[kYWAIndex,
                                                                               kYWAWindDirectionInDegrees,
                                                                               kYWAWindDirectionInCompassPoints]];
         [r addEntriesFromDictionary:[self locationInfoFromResult:result]];
         success([NSDictionary dictionaryWithDictionary:r]);
     }
                      failure:failure
     ];
}


#pragma mark - WIND SPEED by COORDINATE, LOCATION, WOEID (optional: YWASpeedUnit)

/**
 *  Gets the current wind speed in the default speed unit for a coordinate
 *
 *  @param coordinate Coordinate to get wind speed for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) windSpeedForCoordinate:(CLLocation*)coordinate
                        success:(void (^)(NSDictionary* result))success
                        failure:(void (^)(id response, NSError* error))failure
{
    [self windSpeedForCoordinate:coordinate speedUnit:_defaultSpeedUnit success:success failure:failure];
}

/**
 *  Gets the current wind speed in the specified speed unit for a coordinate
 *
 *  @param coordinate Coordinate to get wind speed for
 *  @param speedUnit  Speed unit for the response that overrides the default
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) windSpeedForCoordinate:(CLLocation*)coordinate
                      speedUnit:(YWASpeedUnit)speedUnit
                        success:(void (^)(NSDictionary* result))success
                        failure:(void (^)(id response, NSError* error))failure
{
    [self locationStringForCoordinate:coordinate
                              success:^(NSString *locationString) {
                                  [self windSpeedForLocation:locationString speedUnit:speedUnit success:success failure:failure];
                              } failure:failure];
}

/**
 *  Gets the current wind speed in the default speed unit for a location
 *
 *  @param location Location to get wind speed for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void)windSpeedForLocation:(NSString *)location
                     success:(void (^)(NSDictionary* result))success
                     failure:(void (^)(id response, NSError* error))failure
{
    [self windSpeedForLocation:location speedUnit:_defaultSpeedUnit success:success failure:failure];
}

/**
 *  Gets the current wind speed in the specified speed unit for a location
 *
 *  @param location  Location to get wind speed for
 *  @param speedUnit Speed unit for the response that overrides the default
 *  @param success   Callback block that receives the result on success
 *  @param failure   Callback block that receives the bad response and error on failure
 */
- (void)windSpeedForLocation:(NSString *)location
                   speedUnit:(YWASpeedUnit)speedUnit
                     success:(void (^)(NSDictionary* result))success
                     failure:(void (^)(id response, NSError* error))failure
{
    [self woeidForLocation:location
                   success:^(NSString *woeid) {
                       [self windSpeedForWOEID:woeid speedUnit:speedUnit success:success failure:failure];
                   } failure:failure
     ];
}

/**
 *  Gets the current wind speed in the default speed unit for a Yahoo WOEID
 *
 *  @param woeid   Yahoo WOEID to get wind speed for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) windSpeedForWOEID:(NSString*)woeid
                   success:(void (^)(NSDictionary* result))success
                   failure:(void (^)(id response, NSError *error))failure
{
    [self windSpeedForWOEID:woeid speedUnit:_defaultSpeedUnit success:success failure:failure];
}

/**
 *  Gets the current wind speed in the specified speed unit for a Yahoo WOEID
 *
 *  @param woeid     Yahoo WOEID to get wind speed for
 *  @param speedUnit Speed unit for the response that overrides the default
 *  @param success   Callback block that receives the result on success
 *  @param failure   Callback block that receives the bad response and error on failure
 */
- (void) windSpeedForWOEID:(NSString*)woeid
                 speedUnit:(YWASpeedUnit)speedUnit
                   success:(void (^)(NSDictionary* result))success
                   failure:(void (^)(id response, NSError *error))failure
{
    [self queryResultForWOEID:woeid
                     yqlQuery:kYWAYQLQueryAll
                    speedUnit:speedUnit
              temperatureUnit:_defaultTemperatureUnit
                 pressureUnit:_defaultPressureUnit
                 distanceUnit:_defaultDistanceUnit
                      success:^(id result)
     {
         NSString* windSpeedInMPH = [[result objectForKey:@"wind"] objectForKey:@"speed"];
         NSString* windSpeedInKMPH = [NSString stringWithFormat: @"%.2f" , [self speedIn:KMPH from:MPH value:[windSpeedInMPH doubleValue]]];
         NSString* index = speedUnit == MPH ? windSpeedInMPH : windSpeedInKMPH;
         
         NSMutableDictionary* r = [NSMutableDictionary dictionaryWithObjects:@[index,
                                                                               windSpeedInMPH,
                                                                               windSpeedInKMPH]
                                                                     forKeys:@[kYWAIndex,
                                                                               kYWAWindSpeedInMPH,
                                                                               kYWAWindSpeedInKMPH]];
         [r addEntriesFromDictionary:[self locationInfoFromResult:result]];
         success([NSDictionary dictionaryWithDictionary:r]);
     }
                      failure:failure
     ];
}


#pragma mark - GRAND FUNCTION THAT MAKES EXTERNAL REQUESTS

- (void) queryResultForWOEID:(NSString*)woeid
                    yqlQuery:(NSString*)yqlQuery
                   speedUnit:(YWASpeedUnit)speedUnit
             temperatureUnit:(YWATemperatureUnit)temperatureUnit
                pressureUnit:(YWAPressureUnit)pressureUnit
                distanceUnit:(YWADistanceUnit)distanceUnit
                     success:(void (^)(id result))success
                     failure:(void (^)(id response, NSError *error))failure
{
    NSString* path = [self makePathForWOEID:woeid yqlQuery:yqlQuery];
    NSString* encodedPath = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [self cachedResultForWOEID:woeid success:^(id result) {
        success([[[result objectForKey:@"query"] objectForKey:@"results"] objectForKey:@"channel"]);
    } failure:^(NSError *error) { // cache failed
        [[YWeatherAPIHTTPClient sharedClient] GET:encodedPath parameters:nil
                                          success:^(NSURLSessionDataTask *task, id result)
         {
             // received a response, but Yahoo did not find any useful information for us
             BOOL badResponse = [[[[[result objectForKey:@"query"] objectForKey:@"results"] objectForKey:@"channel"] objectForKey:@"description"] caseInsensitiveCompare:kYWAYahooWeatherErrorReturn] == NSOrderedSame;
             
             if (badResponse) {
                 failure((NSHTTPURLResponse*) task.response, [NSError errorWithDomain:kYWAErrorDomain code:kYWAEmptyResponse userInfo:nil]);
                 return;
             }
             
             // cache the result, pass result to the callback
             if (_cacheEnabled) { [self cacheResult:result WOEID:woeid]; }
             success([[[result objectForKey:@"query"] objectForKey:@"results"] objectForKey:@"channel"]);
         }
                                          failure:^(NSURLSessionDataTask *task, NSError *error)
         {
             failure((NSHTTPURLResponse*) task.response, error);
         }];
    }];
    
}


#pragma mark - CACHE

- (void) cacheResult:(id)result
               WOEID:(NSString*)woeid
{
    dispatch_async(async_queue, ^{
        NSMutableDictionary* cache = [[userDefaults dictionaryForKey:kYWACacheKey] mutableCopy];
        if (!cache) { cache = [[NSMutableDictionary alloc] initWithCapacity:1]; }
        NSDate* expiry = [[NSDate date] dateByAddingTimeInterval:_cacheExpiryInMinutes * 60];
        
        NSDictionary* newItem = [NSDictionary dictionaryWithObjects:@[expiry, result] forKeys:@[kYWACacheExpiryKey, kYWACacheResultKey]];
        
        id archivedNewItem = newItem ? [NSKeyedArchiver archivedDataWithRootObject:newItem] : nil;
        [cache setObject:archivedNewItem forKey:woeid];
        [userDefaults setObject:cache forKey:kYWACacheKey];
        [userDefaults synchronize];
    });
    
}

/**
 *  Flushes the cache, removing all cached results
 *
 *  @see -removeCachedResultsForWOEID:
 */
- (void) clearCache
{
    [userDefaults removeObjectForKey:kYWACacheKey];
    [userDefaults synchronize];
}

- (BOOL) expired:(NSDate*) expiryDate
{
    return [[NSDate date] compare:expiryDate] == NSOrderedDescending;
}

/**
 *  Removes cached results for a WOEID
 *
 *  @param woeid A WOEID
 *  @see -clearCache
 */
- (void) removeCachedResultsForWOEID:(NSString*) woeid
{
    NSMutableDictionary* cache = [[userDefaults dictionaryForKey:kYWACacheKey] mutableCopy];
    if (cache) {
        [cache removeObjectForKey:woeid];
        [userDefaults setObject:cache forKey:kYWACacheKey];
        [userDefaults synchronize];
    }
}

/**
 *  Removes cached results for a location
 *
 *  @param location Natural-language string representing a geographical location
 *  @warning Requires the cached location string verbatim for guaranteed removal
 *  @see -clearCache
 */
- (void) removeCachedResultsForLocation: (NSString*) location
{
    [self woeidForLocation:location success:^(NSString *woeid) {
        [self removeCachedResultsForWOEID:woeid];
    } failure:^(id response, NSError *error) {
        NSLog(@"Cache removal did not succeed: %@", error);
    }];
}

- (void) cachedResultForWOEID:(NSString*) woeid
                      success:(void (^)(id result))success
                      failure:(void (^)(NSError* error))failure
{
    if (_cacheEnabled) {
        dispatch_async(async_queue, ^{
            BOOL cacheCanBeUsed = NO;
            
            @try {
                
                NSDictionary* cache = [userDefaults dictionaryForKey:kYWACacheKey];
                if (cache) {
                    NSData* archivedItem = [cache objectForKey:woeid];
                    if (archivedItem) {
                        NSDictionary* item = archivedItem ? [NSKeyedUnarchiver unarchiveObjectWithData:archivedItem] : nil;
                        if (item) {
                            NSDate* expiryDate = [cache objectForKey:kYWACacheExpiryKey];
                            if (![self expired:expiryDate]) {
                                // cache item can be used
                                cacheCanBeUsed = YES;
                                id result = [item objectForKey: kYWACacheResultKey];
                                dispatch_sync(dispatch_get_main_queue(), ^{
                                    success(result);
                                });
                            }
                        }
                    }
                }
                if (!cacheCanBeUsed) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        NSError* error = [NSError errorWithDomain:kYWAErrorDomain code:kYWACacheCannotBeUsed userInfo:nil];
                        failure(error);
                    });
                }
            }
            
            @catch(NSException* exception) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    NSError* error = [NSError errorWithDomain:kYWAErrorDomain code:kYWACacheCannotBeUsed userInfo:nil];
                    failure(error);
                });
            }
        });
    }
    
    else { // Cache failed
        NSError* error = [NSError errorWithDomain:kYWAErrorDomain code:kYWACacheNotEnabled userInfo:nil];
        failure(error);
    }
}


#pragma mark - HELPERS

/**
 *  Returns a natural-language location string by reverse geocoding a coordinate
 *
 *  @param coordinate CLLocation object with valid latitude and longitude
 *  @param success    Callback block that receives the location on successful reverse geocoding
 *  @param failure    Callback block that receives nil and an NSError object on failure
 */
- (void) locationStringForCoordinate:(CLLocation*)coordinate
                             success:(void (^)(NSString* locationString))success
                             failure:(void (^)(id response, NSError* error))failure
{
    CLGeocoder* geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:coordinate
                   completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (error) {
             failure(nil, error);
             return;
         }
         
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         NSString* locationString = [[[NSArray arrayWithObjects:
                                       placemark.subLocality ? placemark.subLocality : @"",
                                       placemark.subAdministrativeArea ? placemark.subAdministrativeArea : @"",
                                       placemark.administrativeArea ? placemark.administrativeArea : @"",
                                       placemark.country ? placemark.country : @"",
                                       nil] componentsJoinedByString:@" "] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
         
         if ([locationString length] == 0) {
             failure(nil, error);
             return;
         }
         
         success(locationString);
     }];
}

- (NSString*) makePathForWOEID:(NSString*)woeid
                      yqlQuery:(NSString*)yqlQuery
{
    return [[NSArray arrayWithObjects: @"yql?q=", yqlQuery, @" where woeid = ", woeid, @"&format=json", nil] componentsJoinedByString:@""];
}

/**
 *  Gets the Yahoo WOEID for a natural-language location using Yahoo's GEO lookup
 *
 *  @param location Natural-language string representing a geographical location
 *  @param success  Callback block that receives the WOEID on a successful lookup
 *  @param failure  Callback block that receives the bad response and an NSError object on failure
 */
- (void) woeidForLocation:(NSString*)location
                  success:(void (^)(NSString* woeid))success
                  failure:(void (^)(id response, NSError *error))failure
{
    // XXX: refactor encoding logic
    NSString* path = [[NSArray arrayWithObjects: @"yql?q=", @"select woeid from geo.places(1) where text", nil] componentsJoinedByString:@""];
    NSMutableString* encodedPath = [[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    [encodedPath appendString:@"%3D'"];
    NSString* path2 = [[NSArray arrayWithObjects: [YWeatherAPI urlencode:location], @"'&format=json", nil] componentsJoinedByString:@""];
    [encodedPath appendString:[path2 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [[YWeatherAPIHTTPClient sharedClient] GET:encodedPath
                                   parameters:nil
                                      success:^(NSURLSessionDataTask *task, id result)
     {
         // Geo check for null
         if ([[result objectForKey:@"query"] objectForKey:@"results"] == [NSNull null]) {
             failure((NSHTTPURLResponse*) task.response, [NSError errorWithDomain:kYWAErrorDomain code:kYWAEmptyResponse userInfo:nil]);
         } else {
             success([[[[result objectForKey:@"query"] objectForKey:@"results"] objectForKey:@"place"] objectForKey:@"woeid"]);
         }
     }
                                      failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         failure((NSHTTPURLResponse*) task.response, error);
     }];
}

- (NSDictionary*) locationInfoFromResult:(id)result
{
    NSMutableDictionary* location = [[result objectForKey:@"location"] mutableCopy];
    [location setObject:[[result objectForKey:@"item"] objectForKey:@"lat"] forKey:kYWALatitude];
    [location setObject:[[result objectForKey:@"item"] objectForKey:@"long"] forKey:kYWALongtitude];
    return [NSDictionary dictionaryWithDictionary:location];
}

- (NSString*) timeZoneFromYWTimeString:(NSString*)timeString
{
    NSError* regexError = nil;
    NSString* timeZone;
    
    NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:@"\\s(\\w+)$"
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:&regexError];
    NSArray* tokens = [regex matchesInString:timeString options:0 range:NSMakeRange(0, [timeString length])];
    
    for (NSTextCheckingResult* match in tokens) {
        timeZone = [timeString substringWithRange:[match rangeAtIndex:1]];
    }
    
    return [timeZone uppercaseString];
}

- (NSDictionary*) packagedYWForecastDayInfoFor:(NSDictionary*)forecastDayInfo
                               temperatureUnit:(YWATemperatureUnit)temperatureUnit
{
    // Temperature
    NSString* highTemperatureInF = [forecastDayInfo objectForKey:@"high"];
    NSString* lowTemperatureInF = [forecastDayInfo objectForKey:@"low"];
    NSString* highTemperatureInC = [NSString stringWithFormat:@"%.2f", [self temperatureIn:C from:F value:[highTemperatureInF doubleValue]]];
    NSString* lowTemperatureInC = [NSString stringWithFormat:@"%.2f", [self temperatureIn:C from:F value:[lowTemperatureInF doubleValue]]];
    NSString *indexHighTemperature, *indexLowTemperature;
    
    if (temperatureUnit == F) {
        indexHighTemperature = highTemperatureInF;
        indexLowTemperature = lowTemperatureInF;
    } else {
        indexHighTemperature = highTemperatureInC;
        indexLowTemperature = lowTemperatureInC;
    }
    
    // Date
    NSDateComponents* dateComps = [self dateComponentsForShortDate:[forecastDayInfo objectForKey:@"date"]];
    
    // Short text
    NSString* shortDescription = [forecastDayInfo objectForKey:@"text"];
    
    // Pack into dictionary
    NSDictionary* d = [NSMutableDictionary dictionaryWithObjects:@[indexHighTemperature,
                                                                   indexLowTemperature,
                                                                   dateComps,
                                                                   shortDescription]
                                                         forKeys:@[kYWAHighTemperatureForDay,
                                                                   kYWALowTemperatureForDay,
                                                                   kYWADateComponents,
                                                                   kYWAShortDescription]];
    return d;
}


#pragma mark - UNIT CONVERSIONS

/**
 *  Converts speed units from MPH to KMPH or vice versa.
 *  For your convenience, consider setting the default distance unit or using a method that has a speed unit parameter instead.
 *
 *  @param toUnit   The speed unit to convert to
 *  @param fromUnit The speed unit to convert from
 *  @param speed    The value to convert
 *
 *  @return Converted speed value in the unit to convert to
 */
- (double) speedIn:(YWASpeedUnit)toUnit
              from:(YWASpeedUnit)fromUnit
             value:(double)speed
{
    if (toUnit == fromUnit) {
        return speed;
    }
    
    double converted;
    if (toUnit == KMPH && fromUnit == MPH) {
        converted = 1.60934 * speed;
    } else {
        converted = 0.621371 * speed;
    }
    
    return roundf(converted * 100) / 100;
}

/**
 *  Converts speed units from F to C or vice versa.
 *  For your convenience, consider setting the default temperature unit or using a method that has a temperature unit parameter instead.
 *
 *  @param toUnit      The temperature unit to convert to
 *  @param fromUnit    The temperature unit to convert from
 *  @param temperature The value to convert
 *
 *  @return Converted temperature value in the unit to convert to
 */
- (double) temperatureIn:(YWATemperatureUnit)toUnit
                    from:(YWATemperatureUnit)fromUnit
                   value:(double)temperature
{
    if (toUnit == fromUnit) {
        return temperature;
    }
    
    double converted;
    if (toUnit == C && fromUnit == F) {
        converted = (temperature - 32) * 5/9;
    } else {
        converted = (temperature * 9/5) + 32;
    }
    
    return roundf(converted * 100) / 100;
}

/**
 *  Converts speed units from IN to MN or vice versa.
 *  For your convenience, consider setting the default pressure unit or using a method that has a pressure unit parameter instead.
 *
 *  @param toUnit      The pressure unit to convert to
 *  @param fromUnit    The pressure unit to convert from
 *  @param temperature The value to convert
 *
 *  @return Converted pressure value in the unit to convert to
 */
- (double) pressureIn:(YWAPressureUnit)toUnit
                 from:(YWAPressureUnit)fromUnit
                value:(double)pressure
{
    if (toUnit == fromUnit) {
        return pressure;
    }
    
    double converted;
    if (toUnit == MB && fromUnit == IN) {
        converted = pressure * 33.8638866667;
    } else {
        converted = pressure * 0.000295299830714;
    }
    
    return roundf(converted * 100) / 100;
}

/**
 *  Converts speed units from MI to KM or vice versa.
 *  For your convenience, consider setting the default distance unit or using a method that has a distance unit parameter instead.
 *
 *  @param toUnit      The distance unit to convert to
 *  @param fromUnit    The distance unit to convert from
 *  @param temperature The value to convert
 *
 *  @return Converted distance value in the unit to convert to
 */
- (double) distanceIn:(YWADistanceUnit)toUnit
                 from:(YWADistanceUnit)fromUnit
                value:(double)distance
{
    if (toUnit == fromUnit) {
        return distance;
    }
    
    double converted;
    if (toUnit == KM && fromUnit == MI) {
        converted = distance * 1.60934;
    } else {
        converted = distance * 0.621371;
    }
    
    return roundf(converted * 100) / 100;
}

/**
 *  Returns a meaningful weather condition for a Yahoo Condition Code
 *
 *  @param numberCode A numerical Yahoo condition code as a NSString. Valid numbers: [0 .. 47, 3200]
 *
 *  @return The weather condition string for the condition code
 */
- (NSString*) weatherConditionForCode:(NSString*)numberCode
{
    NSDictionary* const kYWAWeatherConditionCodes = @{@"0"  : 	@"Tornado",
                                                      @"1"  : 	@"Tropical Storm",
                                                      @"2"  : 	@"Hurricane",
                                                      @"3"  : 	@"Severe Thunderstorms",
                                                      @"4"  : 	@"Thunderstorms",
                                                      @"5"  : 	@"Mixed Rain and Snow",
                                                      @"6"  : 	@"Mixed Rain and Sleet",
                                                      @"7"  : 	@"Mixed Snow and Sleet",
                                                      @"8"  : 	@"Freezing Drizzle",
                                                      @"9"  : 	@"Drizzle",
                                                      @"10" : 	@"Freezing Rain",
                                                      @"11" : 	@"Showers",
                                                      @"12" : 	@"Showers",
                                                      @"13" : 	@"Snow Flurries",
                                                      @"14" : 	@"Light Snow Showers",
                                                      @"15" : 	@"Blowing Snow",
                                                      @"16" : 	@"Snow",
                                                      @"17" : 	@"Hail",
                                                      @"18" : 	@"Sleet",
                                                      @"19" : 	@"Dust",
                                                      @"20" : 	@"Foggy",
                                                      @"21" : 	@"Haze",
                                                      @"22" : 	@"Smoky",
                                                      @"23" : 	@"Blustery",
                                                      @"24" : 	@"Windy",
                                                      @"25" : 	@"Cold",
                                                      @"26" : 	@"Cloudy",
                                                      @"27" : 	@"Mostly Cloudy (night)",
                                                      @"28" : 	@"Mostly Cloudy (day)",
                                                      @"29" : 	@"Partly Cloudy (night)",
                                                      @"30" : 	@"Partly Cloudy (day)",
                                                      @"31" : 	@"Clear (night)",
                                                      @"32" : 	@"Sunny",
                                                      @"33" : 	@"Fair (night)",
                                                      @"34" : 	@"Fair (day)",
                                                      @"35" : 	@"Mixed Rain and Hail",
                                                      @"36" : 	@"Hot",
                                                      @"37" : 	@"Isolated Thunderstorms",
                                                      @"38" : 	@"Scattered Thunderstorms",
                                                      @"39" : 	@"Scattered Thunderstorms",
                                                      @"40" : 	@"Scattered Showers",
                                                      @"41" : 	@"Heavy Snow",
                                                      @"42" : 	@"Scattered Snow Showers",
                                                      @"43" : 	@"Heavy Snow",
                                                      @"44" : 	@"Partly Cloudy",
                                                      @"45" : 	@"Thundershowers",
                                                      @"46" : 	@"Snow Showers",
                                                      @"47" : 	@"Isolated Thundershowers",
                                                      @"3200" : kYWANoDataAvailable
                                                      };
    
    return [kYWAWeatherConditionCodes objectForKey:numberCode];
    
}

/**
 *  Returns a string reperesenting the approx. compass point direction for a degree
 *
 *  @param degree The degree to convert, should be in the range [0 .. 360] for proper behavior
 *
 *  @return The compass point string
 */
- (NSString*) compassPointForDegree:(double) degree
{
    if (degree < 0.0) { degree = degree + 360.0; }
    if (degree > 360.0) { degree = ((int) degree) % 360; }
    NSAssert(degree >= 0.0 && degree <= 360.0, @"Degree out of range");
    
    double div = 11.25;
    
    if (degree >= 31 * div && degree < 1 * div) {
        return kYWAWindDirectionN;
    } else if (degree >= 1 * div && degree < 3 * div) {
        return kYWAWindDirectionNNE;
    } else if (degree >= 3 * div && degree < 5 * div) {
        return kYWAWindDirectionNE;
    } else if (degree >= 5 * div && degree < 7 * div) {
        return kYWAWindDirectionENE;
    } else if (degree >= 7 * div && degree < 9 * div) {
        return kYWAWindDirectionE;
    } else if (degree >= 9 * div && degree < 11 * div) {
        return kYWAWindDirectionESE;
    } else if (degree >= 11 * div && degree < 13 * div) {
        return kYWAWindDirectionS;
    } else if (degree >= 13 * div && degree < 15 * div) {
        return kYWAWindDirectionSSE;
    } else if (degree >= 15 * div && degree < 17 * div) {
        return kYWAWindDirectionS;
    } else if (degree >= 17 * div && degree < 19 * div) {
        return kYWAWindDirectionSSW;
    } else if (degree >= 19 * div && degree < 21 * div) {
        return kYWAWindDirectionSW;
    } else if (degree >= 21 * div && degree < 23 * div) {
        return kYWAWindDirectionWSW;
    } else if (degree >= 23 * div && degree < 25 * div) {
        return kYWAWindDirectionW;
    } else if (degree >= 25 * div && degree < 27 * div) {
        return kYWAWindDirectionWNW;
    } else if (degree >= 27 * div && degree < 29 * div) {
        return kYWAWindDirectionNW;
    } else {
        return kYWAWindDirectionNNW;
    }
}

- (NSDateComponents*) dateComponentsForShortDate:(NSString*)shortDate
{
    NSDictionary* monthNameToNumber = [NSDictionary dictionaryWithObjects:@[@1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12]
                                                                  forKeys:@[@"jan",
                                                                            @"feb",
                                                                            @"mar",
                                                                            @"apr",
                                                                            @"may",
                                                                            @"jun",
                                                                            @"jul",
                                                                            @"aug",
                                                                            @"sep",
                                                                            @"oct",
                                                                            @"nov",
                                                                            @"dec"]];
    NSString *dayString, *monthString, *yearString;
    NSError* regexError = nil;
    
    NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:@"(.+)\\s(.+)\\s(.+)"
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:&regexError];
    NSArray* tokens = [regex matchesInString:shortDate options:0 range:NSMakeRange(0, [shortDate length])];
    
    for (NSTextCheckingResult* match in tokens) {
        dayString = [shortDate substringWithRange:[match rangeAtIndex:1]];
        monthString = [shortDate substringWithRange:[match rangeAtIndex:2]];
        yearString = [shortDate substringWithRange:[match rangeAtIndex:3]];
    }
    
    NSString* monthStringLowercase = [monthString lowercaseString];
    
    NSDateComponents* comps = [[NSDateComponents alloc] init];
    comps.month = [[monthNameToNumber objectForKey:monthStringLowercase] integerValue];
    comps.day = [dayString integerValue];
    comps.year = [yearString integerValue];
    
    return comps;
}

- (NSDateComponents*) dateComponentsFor12HourTime:(NSString*)timeIn12Hour
                                withShortTimeZone:(NSString*)timeZone
{
    NSString *hourString, *minuteString, *ampm;
    NSInteger hour;
    BOOL am;
    NSError* regexError = nil; // unchecked currently
    
    NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:@"(.+)\\:(.+)\\s(.+)"
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:&regexError];
    NSArray* timeTokens = [regex matchesInString:timeIn12Hour options:0 range:NSMakeRange(0, [timeIn12Hour length])];
    
    for (NSTextCheckingResult* match in timeTokens) {
        hourString = [timeIn12Hour substringWithRange:[match rangeAtIndex:1]];
        minuteString = [timeIn12Hour substringWithRange:[match rangeAtIndex:2]];
        ampm = [timeIn12Hour substringWithRange:[match rangeAtIndex:3]];
    }
    
    if ([ampm caseInsensitiveCompare:@"am"] == NSOrderedSame) {
        am = YES;
    } else {
        am = NO;
    }
    
    hour = [hourString integerValue];
    
    if (am && hour == 12) {
        hour = 0;
    } else if (!am && hour != 12) { // except 12 pm
        hour += 12;
    }
    
    NSDateComponents* comps = [[NSDateComponents alloc] init];
    comps.hour = hour;
    comps.minute = [minuteString integerValue];
    comps.timeZone = [NSTimeZone timeZoneWithAbbreviation:timeZone];
    
    return comps;
}

// http://stackoverflow.com/questions/8088473/how-do-i-url-encode-a-string
+ (NSString *)urlencode:(NSString*) s {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[s UTF8String];
    unsigned long sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}


@end
