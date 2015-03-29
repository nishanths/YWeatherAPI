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
#import "YWeatherAPI.h"
//#import <YWeatherAPI/YWeatherAPI.h>

@import CoreLocation;

SpecBegin(YWeatherAPI)

describe(@"YWeatherAPI", ^{
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
        
        [[YWeatherAPI sharedManager] humidityForLocation:location success:^(NSDictionary *result) {
            NSString* h = [result objectForKey:kYWAHumidity];
            expect(h).toNot.beNil();
        } failure:^(id response, NSError *error) {
            expect(YES).to.beFalsy();
        }];
    });
    
    it(@"returns values in the right range", ^{
        CLLocation* austinTexas = [[CLLocation alloc] initWithLatitude:30.25 longitude:97.75];
        
        [[YWeatherAPI sharedManager] temperatureForCoordinate:(CLLocation*)austinTexas
                                              temperatureUnit:(YWATemperatureUnit)C
                                                      success:^(NSDictionary* result) {
                                                          NSString* temperatureAskedFor = [result objectForKey:kYWAIndex];
                                                          expect([temperatureAskedFor length]).toNot.beGreaterThan(0);
                                                          expect([temperatureAskedFor doubleValue]).to.beInTheRangeOf(@-30, @50);
                                                      }
                                                      failure:^(id response, NSError* error) {
                                                          expect(YES).to.beFalsy();
                                                      }];
    });
    
    it(@"returns the correct today date for forecasts", ^{
        NSDate* today = [NSDate date];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *dateComponents = [gregorian components:(NSDayCalendarUnit) fromDate:today];
        NSInteger day = [dateComponents day];
        
        [[YWeatherAPI sharedManager] fiveDayForecastForLocation:@"Redwood City CA" success:^(NSDictionary *result) {
            NSDateComponents* comps = [[[result objectForKey:kYWAFiveDayForecasts] objectAtIndex:0] objectForKey:kYWADateComponents];
            expect([comps day]).to.equal(day);
        } failure:^(id response, NSError *error) {
            expect(YES).to.beFalsy();
        }];
    });
    
    it(@"clears the cache without throwing a tantrum", ^{
        [[YWeatherAPI sharedManager] clearCache];
    });
    
});

SpecEnd

