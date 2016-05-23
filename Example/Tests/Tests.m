//
//  YWeatherAPITests.m
//  YWeatherAPITests
//
//  Created by Nishanth Shanmugham on 3/29/2015.
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

@import Foundation;
#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <YWeatherAPI/YWeatherAPI.h>

@import CoreLocation;

SpecBegin(YWeatherAPI)

describe(@"YWeatherAPI", ^{
    beforeAll(^{
        [Expecta setAsynchronousTestTimeout:10];
    });
    
    it(@"returns the properly initialized singleton", ^{
        expect([YWeatherAPI sharedManager]).toNot.beNil();
        expect([YWeatherAPI sharedManager].defaultPressureUnit).to.equal(IN);
        expect([YWeatherAPI sharedManager].defaultTemperatureUnit).to.equal(F);
        expect([YWeatherAPI sharedManager].defaultSpeedUnit).to.equal(MPH);
        expect([YWeatherAPI sharedManager].defaultDistanceUnit).to.equal(MI);
        expect([YWeatherAPI sharedManager].cacheExpiryInMinutes).to.equal(15);
    });
    
    it(@"returns non nil values for humidity", ^{
        NSString* location = @"Austin, TX";
        
        waitUntil(^(DoneCallback done) {
            [[YWeatherAPI sharedManager] humidityForLocation:location success:^(NSDictionary *result) {
                NSString* h = [result objectForKey:kYWAHumidity];
                expect(h).willNot.beNil();
                done();
            } failure:^(id response, NSError *error) {
                failure(@"fail");
                done();
            }];
        });
    });
    
    it(@"returns values in the right range", ^{
        CLLocation* austinTexas = [[CLLocation alloc] initWithLatitude:30.25 longitude:97.75];
        
        waitUntil(^(DoneCallback done) {
            [[YWeatherAPI sharedManager] temperatureForCoordinate:(CLLocation*)austinTexas
                                                  temperatureUnit:(YWATemperatureUnit)C
                                                          success:^(NSDictionary* result)
             {
                 NSString* temperatureAskedFor = [result objectForKey:kYWAIndex];
                 expect([temperatureAskedFor length]).will.beGreaterThan(@0);
                 expect([temperatureAskedFor doubleValue]).will.beInTheRangeOf(@-30, @50);
                 done();
             }
                                                          failure:^(id response, NSError* error)
             {
                 failure(@"fail");
                 done();
             }];
        });
    });
    
    it(@"returns the correct today date for forecasts", ^{
        NSDate* today = [NSDate date];
        NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:today];
        NSInteger month = [dateComponents month];
        NSInteger year = [dateComponents year];
        
        waitUntil(^(DoneCallback done) {
            [[YWeatherAPI sharedManager] fiveDayForecastForLocation:@"Redwood City CA" success:^(NSDictionary *result) {
                NSDateComponents* comps = [[[result objectForKey:kYWAFiveDayForecasts] objectAtIndex:0] objectForKey:kYWADateComponents];
                expect([comps month]).will.equal(month);
                expect([comps year]).will.equal(year);
                done();
            } failure:^(id response, NSError *error) {
                failure(@"fail");
                done();
            }];
        });
    });
    
    
    it(@"clears the cache without throwing a tantrum", ^{
        [[YWeatherAPI sharedManager] clearCache];
    });
    
    
    it(@"returns a non-nil result when asking for all conditions", ^{
        waitUntil(^(DoneCallback done) {
            [[YWeatherAPI sharedManager] allCurrentConditionsForLocation:@"Chennai, India" success:^(NSDictionary *result) {
                expect(result).willNot.beNil();
                done();
            } failure:^(id response, NSError *error) {
                failure(@"fail");
                done();
            }];
        });
    });
    
    it (@"returns a non-nil string for current condition by code", ^{
        waitUntil(^(DoneCallback done) {
            [[YWeatherAPI sharedManager] allCurrentConditionsForLocation:@"Liverpool, England" success:^(NSDictionary *result) {
                expect([result objectForKey:kYWACondition]).willNot.beNil();
                done();
            } failure:^(id response, NSError *error) {
                failure(@"fail");
                done();
            }];
        });
    });
    
    it(@"encodes location correctly in the query string", ^{
        waitUntil(^(DoneCallback done) {
            [[YWeatherAPI sharedManager] temperatureForLocation:@"Prince George's MD United States" success:^(NSDictionary *result) {
                expect([result objectForKey:kYWAIndex]).willNot.beNil();
                done();
            } failure:^(id response, NSError *error) {
                NSLog(@"%@", error);
                failure(@"fail");
                done();
            }];
        });
    });
    
    it(@"clears the cache without throwing a tantrum", ^{
        [[YWeatherAPI sharedManager] clearCache];
    });
});

SpecEnd

