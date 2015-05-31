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


/*  Enumerated values for units */
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
extern NSString* const kYWAIndex; // The detail asked for
// Pressure trend
extern NSString* const kYWAPressureTrend;
// Pressure
extern NSString* const kYWAPressureInIN;
extern NSString* const kYWAPressureInMB;
// Location
extern NSString* const kYWALatitude;
extern NSString* const kYWALongtitude;
extern NSString* const kYWALocation;
extern NSString* const kYWACity;
extern NSString* const kYWARegion;
extern NSString* const kYWACountry;
// Wind
extern NSString* const kYWAWindSpeedInMPH;
extern NSString* const kYWAWindSpeedInKMPH;
extern NSString* const kYWAWindDirectionInDegrees;
extern NSString* const kYWAWindDirectionInCompassPoints;
extern NSString* const kYWAWindChillInF;
extern NSString* const kYWAWindChillInC;
// Sunrise and Sunset
extern NSString* const kYWASunriseInLocalTime; // NSDateComponent with hour, minute, timeZone
extern NSString* const kYWASunsetInLocalTime; // NSDateComponent with hour, minute, timeZone
// Humdity
extern NSString* const kYWAHumidity;
// Visibility
extern NSString* const kYWAVisibilityInMI;
extern NSString* const kYWAVisibilityInKM;
// Short description
extern NSString* const kYWAShortDescription;
// Long description
extern NSString* const kYWALongDescription; // May contain HTML tags
// Condition
extern NSString* const kYWACondition;
extern NSString* const kYWAConditionNumber;
// Temperature
extern NSString* const kYWATemperatureInF;
extern NSString* const kYWATemperatureInC;
// Forecast conditions daily
extern NSString* const kYWAHighTemperatureForDay;
extern NSString* const kYWALowTemperatureForDay;
extern NSString* const kYWADateComponents; // NSDateCompoent with month, day, year
// Five day forecasts array key
extern NSString* const kYWAFiveDayForecasts; // NSArray containing NSDictionary objects for each day


/*  Comparison strings for empty index
 *  Compare with object for key kYWAIndex
 *  Currently, the today's forecast methods and the all current conditions methods return kYWAEmptyValue for the key kYWAIndex */
extern NSString* const kYWAEmptyValue;

/*  Returned by the condition methods when Yahoo weather has no condition string available
 *  See code 3200 at https://developer.yahoo.com/weather/documentation.html#codes */
extern NSString* const kYWANoDataAvailable;

/*  Comparison strings for wind direction
 *  Compare with object for key kYWAWindDirectionInCompassPoints */
extern NSString* const kYWAWindDirectionN;
extern NSString* const kYWAWindDirectionE;
extern NSString* const kYWAWindDirectionS;
extern NSString* const kYWAWindDirectionW;
// Quadrant 1
extern NSString* const kYWAWindDirectionNNE;
extern NSString* const kYWAWindDirectionNE;
extern NSString* const kYWAWindDirectionENE;
// Quadrant 2
extern NSString* const kYWAWindDirectionESE;
extern NSString* const kYWAWindDirectionSE;
extern NSString* const kYWAWindDirectionSSE;
// Quadrant 3
extern NSString* const kYWAWindDirectionSSW;
extern NSString* const kYWAWindDirectionSW;
extern NSString* const kYWAWindDirectionWSW;
// Quadrant 4
extern NSString* const kYWAWindDirectionWNW;
extern NSString* const kYWAWindDirectionNW;
extern NSString* const kYWAWindDirectionNNW;

/*  Comparison strings for pressure trends
 *  Compare with object for key kYWAPressureTrend */
extern NSString* const kYWAPressureTrendFalling;
extern NSString* const kYWAPressureTrendRising;


@interface YWeatherAPI : NSObject

/** @name Customizable properties */

@property (nonatomic, assign) BOOL cacheEnabled; // Defaults to YES
@property (nonatomic, assign) uint cacheExpiryInMinutes; // Defaults to 15 minutes
@property (nonatomic, assign) YWAPressureUnit defaultPressureUnit; // Defaults to IN
@property (nonatomic, assign) YWASpeedUnit defaultSpeedUnit; // Defaults to MPH
@property (nonatomic, assign) YWADistanceUnit defaultDistanceUnit; // Defaults to MI
@property (nonatomic, assign) YWATemperatureUnit defaultTemperatureUnit; // Defaults to F


/** @name Shared Instance */


/**
 *  Returns the shared singleton instance
 *
 *  @return The singleton object for the class
 */
+ (instancetype)sharedManager;


/** @name Today's Forecast */


/**
 *  Gets forecast information for the current day and includes a short description and low and high temperatures in the default temperature unit for a coordinate
 *
 *  @param coordinate Coordinate to get today's forecast for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) todaysForecastForCoordinate:(CLLocation*)coordinate
                             success:(void (^)(NSDictionary* result))success
                             failure:(void (^)(id response, NSError* error))failure;

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
                             failure:(void (^)(id response, NSError* error))failure;

/**
 *  Gets forecast information for the current day and includes a short description and low and high temperatures in the default temperature unit for a location
 *
 *  @param location Location to get today's forecast for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) todaysForecastForLocation:(NSString*)location
                           success:(void (^)(NSDictionary* result))success
                           failure:(void (^)(id response, NSError* error))failure;

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
                           failure:(void (^)(id response, NSError* error))failure;

/**
 *  Gets forecast information for the current day and includes a short description and low and high temperatures in the default temperature unit for a Yahoo WOEID
 *
 *  @param woeid   Yahoo WOEID to get today's forecast for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) todaysForecastForWOEID:(NSString*)woeid
                        success:(void (^)(NSDictionary* result))success
                        failure:(void (^)(id response, NSError* error))failure;

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
                        failure:(void (^)(id response, NSError* error))failure;


/** @name Five Day Forecast */

/**
 *  Gets forecast information for the next five days starting today and includes a short description and low and high temperatures in the default temperature unit for a coordinate
 *
 *  @param coordinate Coordinate to get five day forecast for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) fiveDayForecastForCoordinate:(CLLocation*)coordinate
                              success:(void (^)(NSDictionary* result))success
                              failure:(void (^)(id response, NSError* error))failure;

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
                              failure:(void (^)(id response, NSError* error))failure;

/**
 *  Gets forecast information for the next five days starting today and includes a short description and low and high temperatures in the default temperature unit for a location
 *
 *  @param location Location to get five day forecast for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) fiveDayForecastForLocation:(NSString*)location
                            success:(void (^)(NSDictionary* result))success
                            failure:(void (^)(id response, NSError* error))failure;
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
                            failure:(void (^)(id response, NSError* error))failure;

/**
 *  Gets forecast information for the next five days starting today and includes a short description and low and high temperatures in the default temperature unit for a Yahoo WOEID
 *
 *  @param woeid   Yahoo WOEID to get five day forecast for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) fiveDayForecastForWOEID:(NSString*)woeid
                         success:(void (^)(NSDictionary* result))success
                         failure:(void (^)(id response, NSError* error))failure;

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
                         failure:(void (^)(id response, NSError* error))failure;


/** @name All Current Weather Conditions */

/**
 *  Gets all the current weather conditions for a coordinate
 *
 *  @param woeid   Coordinate to get weather condition for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) allCurrentConditionsForCoordinate:(CLLocation*)coordinate
                                   success:(void (^)(NSDictionary* result))success
                                   failure:(void (^)(id response, NSError* error))failure;

/**
 *  Gets all the current weather conditions for a location
 *
 *  @param woeid   Location to get weather condition for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) allCurrentConditionsForLocation:(NSString*)location
                                 success:(void (^)(NSDictionary* result))success
                                 failure:(void (^)(id response, NSError* error))failure;

/**
 *  Gets all the current weather conditions for a Yahoo WOEID
 *
 *  @param woeid   Yahoo WOEID to get weather condition for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) allCurrentConditionsForWOEID:(NSString*)woeid
                              success:(void (^)(NSDictionary* result))success
                              failure:(void (^)(id response, NSError* error))failure;


/** @name Current Weather Descriptions */

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
                            failure:(void (^)(id response, NSError* error))failure;

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
                          failure:(void (^)(id response, NSError* error))failure;

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
                       failure:(void (^)(id response, NSError* error))failure;


/**
 *  Gets a long description of the weather for the current day for a coordinate
 *
 *  @param coordinate Coordinate to get long description for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) longDescriptionForCoordinate:(CLLocation*)coordinate
                              success:(void (^)(NSDictionary* result))success
                              failure:(void (^)(id response, NSError* error))failure;

/**
 *  Gets a long description of the weather for the current day for a location
 *
 *  @param location Location to get long description for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) longDescriptionForLocation:(NSString*)location
                            success:(void (^)(NSDictionary* result))success
                            failure:(void (^)(id response, NSError* error))failure;

/**
 *  Gets a long description of the weather for the current day for a Yahoo WOEID
 *
 *  @param woeid   Yahoo WOEID to get long description for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) longDescriptionForWOEID:(NSString*)woeid
                         success:(void (^)(NSDictionary* result))success
                         failure:(void (^)(id response, NSError* error))failure;


/**
 *  Gets a short description of the weather for the current day for a coordinate
 *
 *  @param coordinate Coordinate to get short description for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) shortDescriptionForCoordinate:(CLLocation*)coordinate
                               success:(void (^)(NSDictionary* result))success
                               failure:(void (^)(id response, NSError* error))failure;

/**
 *  Gets a short description of the weather for the current day for a location
 *
 *  @param location Location to get short description for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) shortDescriptionForLocation:(NSString*)location
                             success:(void (^)(NSDictionary* result))success
                             failure:(void (^)(id response, NSError* error))failure;

/**
 *  Gets a short description of the weather for the current day for a Yahoo WOEID
 *
 *  @param woeid   Yahoo WOEID to get short description for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) shortDescriptionForWOEID:(NSString*)woeid
                          success:(void (^)(NSDictionary* result))success
                          failure:(void (^)(id response, NSError* error))failure;


/** @name Current Temperature conditions */

/**
 *  Gets the current temperature in the default temperature unit for a coordinate
 *
 *  @param coordinate Coordinate to get temperature for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) temperatureForCoordinate:(CLLocation*)coordinate
                          success:(void (^)(NSDictionary* result))success
                          failure:(void (^)(id response, NSError* error))failure;

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
                          failure:(void (^)(id response, NSError* error))failure;

/**
 *  Gets the current temperature in the default temperature unit for a location
 *
 *  @param location Location to get temperature for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) temperatureForLocation:(NSString*)location
                        success:(void (^)(NSDictionary* result))success
                        failure:(void (^)(id response, NSError* error))failure;

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
                        failure:(void (^)(id response, NSError* error))failure;

/**
 *  Gets the current temperature in the default temperature unit for a Yahoo WOEID
 *
 *  @param woeid   Yahoo WOEID to get temperature for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) temperatureForWOEID:(NSString*)woeid
                     success:(void (^)(NSDictionary* result))success
                     failure:(void (^)(id response, NSError* error))failure;

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
                     failure:(void (^)(id response, NSError* error))failure;


/** @name Current Pressure conditions */

/**
 *  Gets the current pressure trend for a coordinate
 *
 *  @param coordinate Coordinate to get pressure trend for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) pressureTrendForCoordinate:(CLLocation*)coordinate
                            success:(void (^)(NSDictionary* result))success
                            failure:(void (^)(id response, NSError* error))failure;

/**
 *  Gets the current pressure trend for a location
 *
 *  @param location Location to get pressure trend for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) pressureTrendForLocation:(NSString*)location
                          success:(void (^)(NSDictionary* result))success
                          failure:(void (^)(id response, NSError* error))failure;

/**
 *  Gets the current pressure trend for a Yahoo WOEID
 *
 *  @param woeid   Yahoo WOEID to get pressure trend for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) pressureTrendForWOEID:(NSString*)woeid
                       success:(void (^)(NSDictionary* result))success
                       failure:(void (^)(id response, NSError* error))failure;

/**
 *  Gets the current pressure in the default pressure unit for a coordinate
 *
 *  @param coordinate Coordinate to get pressure for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) pressureForCoordinate:(CLLocation*)coordinate
                       success:(void (^)(NSDictionary* result))success
                       failure:(void (^)(id response, NSError* error))failure;
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
                       failure:(void (^)(id response, NSError* error))failure;

/**
 *  Gets the current pressure in the default pressure unit for a location
 *
 *  @param location Location to get pressure for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) pressureForLocation:(NSString*)location
                     success:(void (^)(NSDictionary* result))success
                     failure:(void (^)(id response, NSError* error))failure;

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
                     failure:(void (^)(id response, NSError* error))failure;

/**
 *  Gets the current pressure in the default pressure unit for a Yahoo WOEID
 *
 *  @param woeid   Yahoo WOEID to get pressure for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) pressureForWOEID:(NSString*)woeid
                  success:(void (^)(NSDictionary* result))success
                  failure:(void (^)(id response, NSError* error))failure;

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
                  failure:(void (^)(id response, NSError* error))failure;


/** @name Current Visibility conditions */

/**
 *  Gets the current visibility distance in the default distance unit for a coordinate
 *
 *  @param coordinate Coordinate to get visibility for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) visibilityForCoordinate:(CLLocation*)coordinate
                         success:(void (^)(NSDictionary* result))success
                         failure:(void (^)(id response, NSError* error))failure;

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
                         failure:(void (^)(id response, NSError* error))failure;

/**
 *  Gets the current visibility distance in the default distance unit for a location
 *
 *  @param location Location to get visibility for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) visibilityForLocation:(NSString*)location
                       success:(void (^)(NSDictionary* result))success
                       failure:(void (^)(id response, NSError* error))failure;

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
                       failure:(void (^)(id response, NSError* error))failure;

/**
 *  Gets the current visibility distance in the default distance unit for a Yahoo WOEID
 *
 *  @param woeid   Yahoo WOEID to get visibility for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) visibilityForWOEID:(NSString*)woeid
                    success:(void (^)(NSDictionary* result))success
                    failure:(void (^)(id response, NSError* error))failure;

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
                    failure:(void (^)(id response, NSError* error))failure;


/** @name Current Humidity conditions */

/**
 *  Gets the current humidity for a coordinate
 *
 *  @param coordinate Coordinate to get humidity for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) humidityForCoordinate:(CLLocation*)coordinate
                       success:(void (^)(NSDictionary* result))success
                       failure:(void (^)(id response, NSError *))failure;

/**
 *  Gets the current humidity for a location
 *
 *  @param location Location to get humidity for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) humidityForLocation:(NSString*)location
                     success:(void (^)(NSDictionary* result))success
                     failure:(void (^)(id response, NSError* error))failure;

/**
 *  Gets the current humidity for a Yahoo WOEID
 *
 *  @param woeid   Yahoo WOEID to get humidity for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) humidityForWOEID:(NSString*) woeid
                  success:(void (^)(NSDictionary* result))success
                  failure:(void (^)(id response, NSError* error))failure;



/** @name Sunrise and Sunset times */

/**
 *  Gets the sunrise time for the current day for a coordinate in its local time
 *
 *  @param coordinate Coordinate to get sunrise time for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) sunriseForCoordinate:(CLLocation*)coordinate
                      success:(void (^)(NSDictionary* result))success
                      failure:(void (^)(id response, NSError* error))failure;

/**
 *  Gets the sunrise time for the current day for a location in its local time
 *
 *  @param location Location to get sunrise time for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) sunriseForLocation:(NSString*)location
                    success:(void (^)(NSDictionary* result))success
                    failure:(void (^)(id response, NSError* error))failure;

/**
 *  Gets the sunrise time for the current day for a Yahoo WOEID in its local time
 *
 *  @param woeid   Yahoo WOEID to get sunrise time for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) sunriseForWOEID:(NSString*) woeid
                 success:(void (^)(NSDictionary* result))success
                 failure:(void (^)(id response, NSError* error))failure;


/**
 *  Gets the sunset time for the current day for a coordinate in its local time
 *
 *  @param coordinate Coordinate to get sunset time for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) sunsetForCoordinate:(CLLocation*)coordinate
                     success:(void (^)(NSDictionary* result))success
                     failure:(void (^)(id response, NSError* error))failure;

/**
 *  Gets the sunset time for the current day for a location in its local time
 *
 *  @param location Location to get sunset time for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) sunsetForLocation:(NSString*) location
                   success:(void (^)(NSDictionary* result))success
                   failure:(void (^)(id response, NSError* error))failure;
/**
 *  Gets the sunset time for the current day for a Yahoo WOEID in its local time
 *
 *  @param woeid   Yahoo WOEID to get sunset time for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) sunsetForWOEID:(NSString*) woeid
                success:(void (^)(NSDictionary* result))success
                failure:(void (^)(id response, NSError* error))failure;


/** @name Current Wind conditions */

/**
 *  Gets the current wind chill temperature in the default temperature unit for a coordinate
 *
 *  @param coordinate Coordinate to get wind chill for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) windChillForCoordinate:(CLLocation*)coordinate
                        success:(void (^)(NSDictionary* result))success
                        failure:(void (^)(id response, NSError* error))failure;

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
                        failure:(void (^)(id response, NSError* error))failure;

/**
 *  Gets the current wind chill temperature in the default temperature unit for a location
 *
 *  @param location Location to get wind chill for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) windChillForLocation:(NSString*)location
                      success:(void (^)(NSDictionary* result))success
                      failure:(void (^)(id response, NSError* error))failure;

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
                      failure:(void (^)(id response, NSError* error))failure;

/**
 *  Gets the current wind chill temperature in the default temperature unit for a Yahoo WOEID
 *
 *  @param woeid   Yahoo WOEID to get wind chill for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) windChillForWOEID:(NSString*) woeid
                   success:(void (^)(NSDictionary* result))success
                   failure:(void (^)(id response, NSError* error))failure;

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
                   failure:(void (^)(id response, NSError* error))failure;


/**
 *  Gets the current wind direction for a coordinate
 *
 *  @param coordinate Coordinate to get wind direction for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) windDirectionForCoordinate:(CLLocation*)coordinate
                            success:(void (^)(NSDictionary* result))success
                            failure:(void (^)(id response, NSError* error))failure;

/**
 *  Gets the current wind direction for a location
 *
 *  @param location Location to get wind direction for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void) windDirectionForLocation:(NSString*)location
                          success:(void (^)(NSDictionary* result))success
                          failure:(void (^)(id response, NSError* error))failure;

/**
 *  Gets the current wind direction for a Yahoo WOEID
 *
 *  @param woeid   Yahoo WOEID to get wind direction for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) windDirectionForWOEID:(NSString*)woeid
                       success:(void (^)(NSDictionary* result))success
                       failure:(void (^)(id response, NSError* error))failure;


/**
 *  Gets the current wind speed in the default speed unit for a coordinate
 *
 *  @param coordinate Coordinate to get wind speed for
 *  @param success    Callback block that receives the result on success
 *  @param failure    Callback block that receives the bad response and error on failure
 */
- (void) windSpeedForCoordinate:(CLLocation*)coordinate
                        success:(void (^)(NSDictionary* result))success
                        failure:(void (^)(id response, NSError* error))failure;

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
                        failure:(void (^)(id response, NSError* error))failure;

/**
 *  Gets the current wind speed in the default speed unit for a location
 *
 *  @param location Location to get wind speed for
 *  @param success  Callback block that receives the result on success
 *  @param failure  Callback block that receives the bad response and error on failure
 */
- (void)windSpeedForLocation:(NSString *)location
                     success:(void (^)(NSDictionary* result))success
                     failure:(void (^)(id response, NSError* error))failure;

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
                     failure:(void (^)(id response, NSError* error))failure;

/**
 *  Gets the current wind speed in the default speed unit for a Yahoo WOEID
 *
 *  @param woeid   Yahoo WOEID to get wind speed for
 *  @param success Callback block that receives the result on success
 *  @param failure Callback block that receives the bad response and error on failure
 */
- (void) windSpeedForWOEID:(NSString*)woeid
                   success:(void (^)(NSDictionary* result))success
                   failure:(void (^)(id response, NSError *error))failure;

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
                   failure:(void (^)(id response, NSError *error))failure;




/** @name Working with the Cache */

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
 *  @warning Requires the cached location string verbatim for guaranteed removal
 *  @see -clearCache
 */
- (void) removeCachedResultsForLocation: (NSString*) location;


/** @name Converting between geographical location formats */

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
 *  Gets the Yahoo WOEID for a natural-language location using Yahoo's GEO lookup
 *
 *  @param location Natural-language string representing a geographical location
 *  @param success  Callback block that receives the WOEID on a successful lookup
 *  @param failure  Callback block that receives the bad response and an NSError object on failure
 */
- (void) woeidForLocation:(NSString*)location
                  success:(void (^)(NSString* woeid))success
                  failure:(void (^)(id response, NSError *error))failure;



/** @name Converting between other units */

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
             value:(double)speed;

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
                   value:(double)temperature;

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
                value:(double)pressure;

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
                value:(double)distance;

/**
 *  Returns a string reperesenting the approximate compass point direction for a degree
 *
 *  @param degree The degree to convert, should be in the range [0 .. 360] for proper behavior
 *
 *  @return The compass point string
 */
- (NSString*) compassPointForDegree:(double) degree;

@end