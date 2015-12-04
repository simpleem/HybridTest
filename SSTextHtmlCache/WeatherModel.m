

//
//  WeatherModel.m
//  tt
//
//  Created by Mac on 15/12/3.
//  Copyright © 2015年 Mac. All rights reserved.
//

#import "WeatherModel.h"

@implementation WeatherModel
+ (id)weatherWithHourlyJSON:(NSDictionary *)hourlyDic {
    return [[self alloc] initWithHourlyJSON:hourlyDic];
}
- (id)initWithHourlyJSON:(NSDictionary *)hourlyDic {
    if (self = [super init]) {
        self.temp = [hourlyDic[@"tempC"] floatValue];
        self.time = [hourlyDic[@"time"] floatValue] / 100;
        NSString *iconStr = hourlyDic[@"weatherIconUrl"][0][@"value"];
        self.iconURL = [NSURL URLWithString:iconStr];
    }
    
    return self;
}
+ (id)weatherWithDailyJSON:(NSDictionary *)dailyDic {
    return [[self alloc] initWithDailyJSON:dailyDic];
}

- (id)initWithDailyJSON:(NSDictionary *)dailyDic {
    if (self = [super init]) {
        self.date = dailyDic[@"date"];
        self.maxTemp = [dailyDic[@"maxtempC"] floatValue];
        self.minTemp = [dailyDic[@"mintempC"] floatValue];
        NSString *iconStr = dailyDic[@"hourly"][0][@"weatherIconUrl"][0][@"value"];
        self.iconURL = [NSURL URLWithString:iconStr];
    }
    return self;
}

@end
