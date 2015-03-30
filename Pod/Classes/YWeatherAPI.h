//
//  YWeatherAPI.h
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

#import <Foundation/Foundation.h>
@class CLLocation;


#pragma mark - STRING CONSTANTS and ENUMS

/* Enums for units */
typedef enum {
    MI, KM
} YWADistanceUnit;

typedef enum {
    IN, MB
} YWAPressureUnit;

typedef enum {
    F, C
} YWATemperatureUnit;

typedef enum {
    MPH, KMPH
} YWASpeedUnit;

/*
 *  Result keys to access objects from the wrapper's results.
 *  All objects returned are NSString* except for those explicity marked below with comments.
 */
NSString* const kYWAIndex; // The detail asked for
// Pressure trend
NSString* const kYWAPressureTrend;
NSString* const kYWAPressureTrendFalling;
NSString* const kYWAPressureTrendRising;
// Pressure
NSString* const kYWAPressureInIN;
NSString* const kYWAPressureInMB;
// Location
NSString* const kYWALatitude;
NSString* const kYWALongtitude;
NSString* const kYWALocation;
NSString* const kYWACity;
NSString* const kYWARegion;
NSString* const kYWACountry;
// Wind
NSString* const kYWAWindSpeedInMPH;
NSString* const kYWAWindSpeedInKMPH;
NSString* const kYWAWindDirectionInDegrees;
NSString* const kYWAWindDirectionInCompassPoints;
NSString* const kYWAWindChillInF;
NSString* const kYWAWindChillInC;
// Sunrise and Sunset
NSString* const kYWASunriseInLocalTime; // NSDateComponent with hour, minute, timeZone
NSString* const kYWASunsetInLocalTime; // NSDateComponent with hour, minute, timeZone
// Humdity
NSString* const kYWAHumidity;
// Visibility
NSString* const kYWAVisibilityInMI;
NSString* const kYWAVisibilityInKM;
// Short description
NSString* const kYWAShortDescription;
// Long description
NSString* const kYWALongDescription; // May contain HTML tags
// Temperature
NSString* const kYWATemperatureInF;
NSString* const kYWATemperatureInC;
// Forecast conditions daily
NSString* const kYWAHighTemperatureForDay;
NSString* const kYWALowTemperatureForDay;
NSString* const kYWADateComponents; // NSDateCompoent with month, day, year
// Five day forecasts array key
NSString* const kYWAFiveDayForecasts; // NSArray containing NSDictionary

/*
 *  Wind direction
 *  Use for comparisons
 */
// Cardinals
NSString* const kYWAWindDirectionNorth;
NSString* const kYWAWindDirectionEast;
NSString* const kYWAWindDirectionSouth;
NSString* const kYWAWindDirectionWest;
// Quadrant 1
NSString* const kYWAWindDirectionNorthNorthEast;
NSString* const kYWAWindDirectionNorthEast;
NSString* const kYWAWindDirectionEastNorthEast;
// Quadrant 2
NSString* const kYWAWindDirectionEastSouthEast;
NSString* const kYWAWindDirectionSouthEast;
NSString* const kYWAWindDirectionSouthSouthEast;
// Quadrant 3
NSString* const kYWAWindDirectionSouthSouthWest;
NSString* const kYWAWindDirectionSouthWest;
NSString* const kYWAWindDirectionWestSouthWest;
// Quadrant 4
NSString* const kYWAWindDirectionWestNorthWest;
NSString* const kYWAWindDirectionNorthWest;
NSString* const kYWAWindDirectionNorthNorthWest;


@interface YWeatherAPI : NSObject

///---------------------
/// @name Customizable properties
///---------------------

@property (nonatomic, assign) BOOL cacheEnabled; // Defaults to YES
@property (nonatomic, assign) uint cacheExpiryInMinutes; // Defaults to 15 minutes
@property (nonatomic, assign) YWAPressureUnit defaultPressureUnit; // Defaults to IN
@property (nonatomic, assign) YWASpeedUnit defaultSpeedUnit; // Defaults to MPH
@property (nonatomic, assign) YWADistanceUnit defaultDistanceUnit; // Defaults to MI
@property (nonatomic, assign) YWATemperatureUnit defaultTemperatureUnit; // Defaults to F



///---------------------
/// @name Singleton instance
///---------------------

/**
 *  Returns the singleton shared manager object
 *
 *  @return the singleton object for the class
 */
+ (instancetype)sharedManager;



///---------------------
/// @name Forecast data for the day
///---------------------

#pragma mark - TODAY'S FORECAST by COORDINATE, LOCATION, WOEID

/**
 *  Returns forecast information for the current day and includes low and high temperatures and a short description
 *
 *  @param coordinate Coordinate to get today's forecast for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) todaysForecastForCoordinate:(CLLocation*)coordinate
                             success:(void (^)(NSDictionary* result))success
                             failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns forecast information for the current day and includes low and high temperatures and a short description
 *
 *  @param coordinate      Coordinate to get today's forecast for
 *  @param temperatureUnit Temperature unit for the response that overrides the default
 *  @param success         Callback block that receives the result on success
 *  @param failure         Callback block that receives the bad response and error on failure
 */
- (void) todaysForecastForCoordinate:(CLLocation*)coordinate
                     temperatureUnit:(YWATemperatureUnit)temperatureUnit
                             success:(void (^)(NSDictionary* result))success
                             failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns forecast information for the current day and includes low and high temperatures and a short description
 *
 *  @param location Location to get today's forecast for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) todaysForecastForLocation:(NSString*)location
                           success:(void (^)(NSDictionary* result))success
                           failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns forecast information for the current day and includes low and high temperatures and a short description
 *
 *  @param location        Location to get today's forecast for
 *  @param temperatureUnit Temperature unit for the response that overrides the default
 *  @param success         Callback block that receives the result on success
 *  @param failure         Callback block that receives the bad response and error on failure
 */
- (void) todaysForecastForLocation:(NSString*)location
                   temperatureUnit:(YWATemperatureUnit)temperatureUnit
                           success:(void (^)(NSDictionary* result))success
                           failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns forecast information for the current day and includes low and high temperatures and a short description
 *
 *  @param woeid   Yahoo WOEID to get today's forecast for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) todaysForecastForWOEID:(NSString*)woeid
                        success:(void (^)(NSDictionary* result))success
                        failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns forecast information for the current day and includes low and high temperatures and a short description
 *
 *  @param woeid           Yahoo WOEID to get today's forecast for
 *  @param temperatureUnit Temperature unit for the response that overrides the default
 *  @param success         Callback block that receives the result on success
 *  @param failure         Callback block that receives the bad response and error on failure
 */
- (void) todaysForecastForWOEID:(NSString*)woeid
                temperatureUnit:(YWATemperatureUnit)temperatureUnit
                        success:(void (^)(NSDictionary* result))success
                        failure:(void (^)(id response, NSError* error))failure;


///---------------------
/// @name Forecast data for next five days
///---------------------

#pragma mark - FIVE DAY FORECAST by COORDINATE, LOCATION, WOEID

/**
 *  Returns forecast information for the next five days starting today and includes low and high temperatures and a short description
 *
 *  @param coordinate Coordinate to get five day forecast for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) fiveDayForecastForCoordinate:(CLLocation*)coordinate
                              success:(void (^)(NSDictionary* result))success
                              failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns forecast information for the next five days starting today and includes low and high temperatures and a short description
 *
 *  @param coordinate      Coordinate to get five day forecast for
 *  @param temperatureUnit Temperature unit for the response that overrides the default
 *  @param success         Callback block that receives the result on success
 *  @param failure         Callback block that receives the bad response and error on failure
 */
- (void) fiveDayForecastForCoordinate:(CLLocation*)coordinate
                      temperatureUnit:(YWATemperatureUnit)temperatureUnit
                              success:(void (^)(NSDictionary* result))success
                              failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns forecast information for the next five days starting today and includes low and high temperatures and a short description
 *
 *  @param location Location to get five day forecast for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) fiveDayForecastForLocation:(NSString*)location
                            success:(void (^)(NSDictionary* result))success
                            failure:(void (^)(id response, NSError* error))failure;
/**
 *  Returns forecast information for the next five days starting today and includes low and high temperatures and a short description
 *
 *  @param location        Location to get five day forecast for
 *  @param temperatureUnit Temperature unit for the response that overrides the default
 *  @param success         Callback block that receives the result on success
 *  @param failure         Callback block that receives the bad response and error on failure
 */
- (void) fiveDayForecastForLocation:(NSString*)location
                    temperatureUnit:(YWATemperatureUnit)temperatureUnit
                            success:(void (^)(NSDictionary* result))success
                            failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns forecast information for the next five days starting today and includes low and high temperatures and a short description
 *
 *  @param woeid   Yahoo WOEID to get five day forecast for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) fiveDayForecastForWOEID:(NSString*)woeid
                         success:(void (^)(NSDictionary* result))success
                         failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns forecast information for the next five days starting today and includes low and high temperatures and a short description
 *
 *  @param woeid           Yahoo WOEID to get five day forecast for
 *  @param temperatureUnit Temperature unit for the response that overrides the default
 *  @param success         Callback block that receives the result on success
 *  @param failure         Callback block that receives the bad response and error on failure
 */
- (void) fiveDayForecastForWOEID:(NSString*)woeid
                 temperatureUnit:(YWATemperatureUnit)temperatureUnit
                         success:(void (^)(NSDictionary* result))success
                         failure:(void (^)(id response, NSError* error))failure;



///---------------------
/// @name Current temperature data
///---------------------

#pragma mark - TEMPERATURE by COORDINATE, LOCATION, WOEID

/**
 *  Returns the current temperature
 *
 *  @param coordinate Coordinate to get temperature for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) temperatureForCoordinate:(CLLocation*)coordinate
                          success:(void (^)(NSDictionary* result))success
                          failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns the current temperature
 *
 *  @param coordinate      Coordinate to get temperature for
 *  @param temperatureUnit Temperature unit for the response that overrides the default
 *  @param success         Callback block that receives the result on success
 *  @param failure         Callback block that receives the bad response and error on failure
 */
- (void) temperatureForCoordinate:(CLLocation*)coordinate
                  temperatureUnit:(YWATemperatureUnit)temperatureUnit
                          success:(void (^)(NSDictionary* result))success
                          failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns the current temperature
 *
 *  @param location Location to get temperature for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) temperatureForLocation:(NSString*)location
                        success:(void (^)(NSDictionary* result))success
                        failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns the current temperature
 *
 *  @param location        Location to get temperature for
 *  @param temperatureUnit Temperature unit for the response that overrides the default
 *  @param success         Callback block that receives the result on success
 *  @param failure         Callback block that receives the bad response and error on failure
 */
- (void) temperatureForLocation:(NSString*)location
                temperatureUnit:(YWATemperatureUnit)temperatureUnit
                        success:(void (^)(NSDictionary* result))success
                        failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns the current temperature
 *
 *  @param woeid   Yahoo WOEID to get temperature for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) temperatureForWOIED:(NSString*)woeid
                     success:(void (^)(NSDictionary* result))success
                     failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns the current temperature
 *
 *  @param woeid           Yahoo WOEID to get temperature for
 *  @param temperatureUnit Temperature unit for the response that overrides the default
 *  @param success         Callback block that receives the result on success
 *  @param failure         Callback block that receives the bad response and error on failure
 */
- (void) temperatureForWOIED:(NSString*)woeid
             temperatureUnit:(YWATemperatureUnit)temperatureUnit
                     success:(void (^)(NSDictionary* result))success
                     failure:(void (^)(id response, NSError* error))failure;

///---------------------
/// @name Current weather descriptions
///---------------------

#pragma mark - LONG DESCRIPTION by COORDINATE, LOCATION, WOEID

/**
 *  Returns a long description of the weather for the current day
 *
 *  @param coordinate Coordinate to get long description for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) longDescriptionForCoordinate:(CLLocation*)coordinate
                              success:(void (^)(NSDictionary* result))success
                              failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns a long description of the weather for the current day
 *
 *  @param location Location to get long description for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) longDescriptionForLocation:(NSString*)location
                            success:(void (^)(NSDictionary* result))success
                            failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns a long description of the weather for the current day
 *
 *  @param woeid   Yahoo WOEID to get long description for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) longDescriptionForWOEID:(NSString*)woeid
                         success:(void (^)(NSDictionary* result))success
                         failure:(void (^)(id response, NSError* error))failure;


#pragma mark - SHORT DESCRIPTION by COORDINATE, LOCATION, WOEID

/**
 *  Returns a short description of the weather for the current day
 *
 *  @param coordinate Coordinate to get short description for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) shortDescriptionForCoordinate:(CLLocation*)coordinate
                               success:(void (^)(NSDictionary* result))success
                               failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns a short description of the weather for the current day
 *
 *  @param location Location to get short description for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) shortDescriptionForLocation:(NSString*)location
                             success:(void (^)(NSDictionary* result))success
                             failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns a short description of the weather for the current day
 *
 *  @param woeid   Yahoo WOEID to get short description for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) shortDescriptionForWOEID:(NSString*)woeid
                          success:(void (^)(NSDictionary* result))success
                          failure:(void (^)(id response, NSError* error))failure;


///---------------------
/// @name Current pressure data
///---------------------

#pragma mark - PRESSURE TREND by COORDINATE, LOCATION, WOEID

/**
 *  Returns the current pressure trend
 *
 *  @param coordinate Coordinate to get pressure trend for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) pressureTrendForCoordinate:(CLLocation*)coordinate
                            success:(void (^)(NSDictionary* result))success
                            failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns the current pressure trend
 *
 *  @param location Location to get pressure trend for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) pressureTrendForLocation:(NSString*)location
                          success:(void (^)(NSDictionary* result))success
                          failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns the current pressure trend
 *
 *  @param woeid   Yahoo WOEID to get pressure trend for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) pressureTrendForWOEID:(NSString*)woeid
                       success:(void (^)(NSDictionary* result))success
                       failure:(void (^)(id response, NSError* error))failure;


#pragma mark - PRESSURE by COORDINATE, LOCATION, WOEID (optional: YWAPressureUnit)

/**
 *  Returns the current pressure
 *
 *  @param coordinate Coordinate to get pressure for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) pressureForCoordinate:(CLLocation*)coordinate
                       success:(void (^)(NSDictionary* result))success
                       failure:(void (^)(id response, NSError* error))failure;
/**
 *  Returns the current pressure
 *
 *  @param coordinate   Coordinate to get pressure for
 *  @param pressureUnit Pressure unit for the response that overrides the default
 *  @param success      Callback block that receives the result on success
 *  @param failure      Callback block that receives the bad response and error on failure
 */
- (void) pressureForCoordinate:(CLLocation*)coordinate
                  pressureUnit:(YWAPressureUnit)pressureUnit
                       success:(void (^)(NSDictionary* result))success
                       failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns the current pressure
 *
 *  @param location Location to get pressure for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) pressureForLocation:(NSString*)location
                     success:(void (^)(NSDictionary* result))success
                     failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns the current pressure
 *
 *  @param location     Location to get pressure for
 *  @param pressureUnit Pressure unit for the response that overrides the default
 *  @param success      Callback block that receives the result on success
 *  @param failure      Callback block that receives the bad response and error on failure
 */
- (void) pressureForLocation:(NSString*)location
                pressureUnit:(YWAPressureUnit)pressureUnit
                     success:(void (^)(NSDictionary* result))success
                     failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns the current pressure
 *
 *  @param woeid   Yahoo WOEID to get pressure for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) pressureForWOEID:(NSString*)woeid
                  success:(void (^)(NSDictionary* result))success
                  failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns the current pressure
 *
 *  @param woeid        Yahoo WOEID to get pressure for
 *  @param pressureUnit Pressure unit for the response that overrides the default
 *  @param success      Callback block that receives the result on success
 *  @param failure      Callback block that receives the bad response and error on failure
 */
- (void) pressureForWOEID:(NSString*)woeid
             pressureUnit:(YWAPressureUnit)pressureUnit
                  success:(void (^)(NSDictionary* result))success
                  failure:(void (^)(id response, NSError* error))failure;

///---------------------
/// @name Current visibility data
///---------------------

#pragma mark - VISIBILITY by COORDINATE, LOCATION, WOEID (optional: YWADistanceUnit)

/**
 *  Returns the current visibility distance
 *
 *  @param coordinate Coordinate to get visibility for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) visibilityForCoordinate:(CLLocation*)coordinate
                         success:(void (^)(NSDictionary* result))success
                         failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns the current visibility distance
 *
 *  @param coordinate   Coordinate to get visibility for
 *  @param distanceUnit Distance unit for the response that overrides the default
 *  @param success      Callback block that receives the result on success
 *  @param failure      Callback block that receives the bad response and error on failure
 */
- (void) visibilityForCoordinate:(CLLocation*)coordinate
                    distanceUnit:(YWADistanceUnit)distanceUnit
                         success:(void (^)(NSDictionary* result))success
                         failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns the current visibility distance
 *
 *  @param location Location to get visibility for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) visibilityForLocation:(NSString*)location
                       success:(void (^)(NSDictionary* result))success
                       failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns the current visibility distance
 *
 *  @param location     Location to get visibility for
 *  @param distanceUnit Distance unit for the response that overrides the default
 *  @param success      Callback block that receives the result on success
 *  @param failure      Callback block that receives the bad response and error on failure
 */
- (void) visibilityForLocation:(NSString*)location
                  distanceUnit:(YWADistanceUnit)distanceUnit
                       success:(void (^)(NSDictionary* result))success
                       failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns the current visibility distance
 *
 *  @param woeid   Yahoo WOEID to get visibility for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) visibilityForWOEID:(NSString*)woeid
                    success:(void (^)(NSDictionary* result))success
                    failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns the current visibility distance
 *
 *  @param woeid        Yahoo WOEID to get visibility for
 *  @param distanceUnit Distance unit for the response that overrides the default
 *  @param success      Callback block that receives the result on success
 *  @param failure      Callback block that receives the bad response and error on failure
 */
- (void) visibilityForWOEID:(NSString*)woeid
               distanceUnit:(YWADistanceUnit)distanceUnit
                    success:(void (^)(NSDictionary* result))success
                    failure:(void (^)(id response, NSError* error))failure;


///---------------------
/// @name Current humidity data
///---------------------

#pragma mark - HUMIDITY by COORDINATE, LOCATION, WOEID

/**
 *  Returns the current humidity
 *
 *  @param coordinate Coordinate to get humidity for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) humidityForCoordinate:(CLLocation*)coordinate
                       success:(void (^)(NSDictionary* result))success
                       failure:(void (^)(id response, NSError *))failure;

/**
 *  Returns the current humidity
 *
 *  @param location Location to get humidity for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) humidityForLocation:(NSString*)location
                     success:(void (^)(NSDictionary* result))success
                     failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns the current humidity
 *
 *  @param woeid   Yahoo WOEID to get humidity for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) humidityForWOEID:(NSString*) woeid
                  success:(void (^)(NSDictionary* result))success
                  failure:(void (^)(id response, NSError* error))failure;


///---------------------
/// @name Sunrise and sunset data
///---------------------

#pragma mark - SUNRISE by COORDINATE, LOCATION, WOEID

/**
 *  Returns the sunrise time for the current day
 *
 *  @param coordinate Coordinate to get sunrise time for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) sunriseForCoordinate:(CLLocation*)coordinate
                      success:(void (^)(NSDictionary* result))success
                      failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns the sunrise time for the current day
 *
 *  @param location Location to get sunrise time for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) sunriseForLocation:(NSString*)location
                    success:(void (^)(NSDictionary* result))success
                    failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns the sunrise time for the current day
 *
 *  @param woeid   Yahoo WOEID to get sunrise time for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) sunriseForWOEID:(NSString*) woeid
                 success:(void (^)(NSDictionary* result))success
                 failure:(void (^)(id response, NSError* error))failure;


#pragma mark - SUNSET by COORDINATE, LOCATION, WOEID

/**
 *  Returns the sunset time for the current day
 *
 *  @param coordinate Coordinate to get sunset time for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) sunsetForCoordinate:(CLLocation*)coordinate
                     success:(void (^)(NSDictionary* result))success
                     failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns the sunset time for the current day
 *
 *  @param location Location to get sunset time for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) sunsetForLocation:(NSString*) location
                   success:(void (^)(NSDictionary* result))success
                   failure:(void (^)(id response, NSError* error))failure;
/**
 *  Returns the sunset time for the current day
 *
 *  @param woeid   Yahoo WOEID to get sunset time for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) sunsetForWOEID:(NSString*) woeid
                success:(void (^)(NSDictionary* result))success
                failure:(void (^)(id response, NSError* error))failure;


///---------------------
/// @name Current wind conditions
///---------------------

#pragma mark - WIND CHILL by COORDINATE, LOCATION, WOEID (optional: YWATemperatureUnit)

/**
 *  Returns the current wind chill temperature
 *
 *  @param coordinate Coordinate to get wind chill for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) windChillForCoordinate:(CLLocation*)coordinate
                        success:(void (^)(NSDictionary* result))success
                        failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns the current wind chill temperature
 *
 *  @param coordinate      Coordinate to get wind chill for
 *  @param temperatureUnit Temperature unit for the response that overrides the default
 *  @param success         Callback block that receives the result on success
 *  @param failure         Callback block that receives the bad response and error on failure
 */
- (void) windChillForCoordinate:(CLLocation*)coordinate
                temperatureUnit:(YWATemperatureUnit)temperatureUnit
                        success:(void (^)(NSDictionary* result))success
                        failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns the current wind chill temperature
 *
 *  @param location Location to get wind chill for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) windChillForLocation:(NSString*)location
                      success:(void (^)(NSDictionary* result))success
                      failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns the current wind chill temperature
 *
 *  @param location        Location to get wind chill for
 *  @param temperatureUnit Temperature unit for the response that overrides the default
 *  @param success         Callback block that receives the result on success
 *  @param failure         Callback block that receives the bad response and error on failure
 */
- (void) windChillForLocation:(NSString*)location
              temperatureUnit:(YWATemperatureUnit)temperatureUnit
                      success:(void (^)(NSDictionary* result))success
                      failure:(void (^)(id response, NSError* error))failure;


/**
 *  Returns the current wind chill temperature
 *
 *  @param woeid   Yahoo WOEID to get wind chill for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) windChillForWOEID:(NSString*) woeid
                   success:(void (^)(NSDictionary* result))success
                   failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns the current wind chill temperature
 *
 *  @param woeid           Yahoo WOEID to get wind chill for
 *  @param temperatureUnit Temperature unit for the response that overrides the default
 *  @param success         Callback block that receives the result on success
 *  @param failure         Callback block that receives the bad response and error on failure
 */
- (void) windChillForWOEID:(NSString*) woeid
           temperatureUnit:(YWATemperatureUnit)temperatureUnit
                   success:(void (^)(NSDictionary* result))success
                   failure:(void (^)(id response, NSError* error))failure;


#pragma mark - WIND DIRECTION by COORDINATE, LOCATION, WOEID

/**
 *  Returns the current wind direction
 *
 *  @param coordinate Coordinate to get wind direction for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) windDirectionForCoordinate:(CLLocation*)coordinate
                            success:(void (^)(NSDictionary* result))success
                            failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns the current wind direction
 *
 *  @param location Location to get wind direction for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) windDirectionForLocation:(NSString*)location
                          success:(void (^)(NSDictionary* result))success
                          failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns the current wind direction
 *
 *  @param woeid   Yahoo WOEID to get wind direction for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) windDirectionForWOEID:(NSString*)woeid
                       success:(void (^)(NSDictionary* result))success
                       failure:(void (^)(id response, NSError* error))failure;


#pragma mark - WIND SPEED by COORDINATE, LOCATION, WOEID (optional: YWASpeedUnit)

/**
 *  Returns the current wind speed
 *
 *  @param coordinate Coordinate to get wind speed for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) windSpeedForCoordinate:(CLLocation*)coordinate
                        success:(void (^)(NSDictionary* result))success
                        failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns the current wind speed
 *
 *  @param coordinate Coordinate to get wind speed for
 *  @param speedUnit  Speed unit for the response that overrides the default
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) windSpeedForCoordinate:(CLLocation*)coordinate
                      speedUnit:(YWASpeedUnit)speedUnit
                        success:(void (^)(NSDictionary* result))success
                        failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns the current wind speed
 *
 *  @param location Location to get wind speed for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void)windSpeedForLocation:(NSString *)location
                     success:(void (^)(NSDictionary* result))success
                     failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns the current wind speed
 *
 *  @param location  Location to get wind speed for
 *  @param speedUnit Speed unit for the response that overrides the default
 *  @param success   Callback block that receives the result on success
 *  @param failure   Callback block that receives the bad response and error on failure
 */
- (void)windSpeedForLocation:(NSString *)location
                   speedUnit:(YWASpeedUnit)speedUnit
                     success:(void (^)(NSDictionary* result))success
                     failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns the current wind speed
 *
 *  @param woeid   Yahoo WOEID to get wind speed for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) windSpeedForWOEID:(NSString*)woeid
                   success:(void (^)(NSDictionary* result))success
                   failure:(void (^)(id response, NSError *error))failure;

/**
 *  Returns the current wind speed
 *
 *  @param woeid     Yahoo WOEID to get wind speed for
 *  @param speedUnit Speed unit for the response that overrides the default
 *  @param success   Callback block that receives the result on success
 *  @param failure   Callback block that receives the bad response and error on failure
 */
- (void) windSpeedForWOEID:(NSString*)woeid
                 speedUnit:(YWASpeedUnit)speedUnit
                   success:(void (^)(NSDictionary* result))success
                   failure:(void (^)(id response, NSError *error))failure;



///---------------------
/// @name Working with the cache
///---------------------

#pragma mark - CACHE

/**
 *  Flushes the cache, removing all cached results
 *
 *  @see -removeCachedResultsForWOEID:
 */
- (void) clearCache;

/**
 *  Removes cached results for a WOEID
 *
 *  @param woeid A WOEID
 *  @see -clearCache
 */
- (void) removeCachedResultsForWOEID:(NSString*) woeid;

/**
 *  Removes cached results for a location
 *
 *  @param location Natural-language string representing a geographical location
 *  @warning Not as accurate as removing by WOEID – if WOEID is not known, consider clearing the entire cache
 *  @see -clearCache
 */
- (void) removeCachedResultsForLocation: (NSString*) location;



///---------------------
/// @name Converting between geographical formats
///---------------------

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
                             failure:(void (^)(id response, NSError* error))failure;

/**
 *  Returns the Yahoo WOEID for a natural-language location using Yahoo's GEO lookup
 *
 *  @param location Natural-language string representing a geographical location
 *  @param success  Callback block that receives the WOEID on a successful lookup
 *  @param failure  Callback block that receives the bad response and an NSError object on failure
 */
- (void) woeidForLocation:(NSString*)location
                  success:(void (^)(NSString* woeid))success
                  failure:(void (^)(id response, NSError *error))failure;


///---------------------
/// @name Converting weather units
///---------------------

#pragma mark - CONVERSIONS

/**
 *  Converts speed units from MPH to KMPH or vice versa.
 *  For your convenience, consider setting the default speed unit or using a method that has a speed unit parameter
 *
 *  @param toUnit   The speed unit to convert to
 *  @param fromUnit The speed unit to convert from
 *  @param speed    The value to convert
 *
 *  @return Converted speed value in the unit to convert to
 */
- (double) speedIn:(YWASpeedUnit)toUnit
              from:(YWASpeedUnit)fromUnit
             value:(double)speed;

/**
 *  Converts speed units from F to C or vice versa.
 *  For your convenience, consider setting the default speed unit or using a method that has a speed unit parameter
 *
 *  @param toUnit      The temperature unit to convert to
 *  @param fromUnit    The temperature unit to convert from
 *  @param temperature The value to convert
 *
 *  @return Converted temperature value in the unit to convert to
 */
- (double) temperatureIn:(YWATemperatureUnit)toUnit
                    from:(YWATemperatureUnit)fromUnit
                   value:(double)temperature;

/**
 *  Converts speed units from IN to MN or vice versa.
 *  For your convenience, consider setting the default speed unit or using a method that has a speed unit parameter
 *
 *  @param toUnit      The pressure unit to convert to
 *  @param fromUnit    The pressure unit to convert from
 *  @param temperature The value to convert
 *
 *  @return Converted pressure value in the unit to convert to
 */
- (double) pressureIn:(YWAPressureUnit)toUnit
                 from:(YWAPressureUnit)fromUnit
                value:(double)pressure;

/**
 *  Converts speed units from MI to KM or vice versa.
 *  For your convenience, consider setting the default speed unit or using a method that has a speed unit parameter
 *
 *  @param toUnit      The distance unit to convert to
 *  @param fromUnit    The distance unit to convert from
 *  @param temperature The value to convert
 *
 *  @return Converted distance value in the unit to convert to
 */
- (double) distanceIn:(YWADistanceUnit)toUnit
                 from:(YWADistanceUnit)fromUnit
                value:(double)distance;



@end