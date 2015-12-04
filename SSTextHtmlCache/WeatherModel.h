//
//  WeatherModel.h
//  tt
//
//  Created by Mac on 15/12/3.
//  Copyright © 2015年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeatherModel : NSObject

@property (nonatomic, strong) NSString *date;
@property (nonatomic, assign) float maxTemp;
@property (nonatomic, assign) float minTemp;
@property (nonatomic, assign) float time;
@property (nonatomic, strong) NSURL *iconURL;
@property (nonatomic, assign) float temp;
@property (nonatomic, strong) NSString *weatherDesc;
@property (nonatomic, strong) NSString *cityName;
+ (id)weatherWithHourlyJSON:(NSDictionary *)hourlyDic;
+ (id)weatherWithDailyJSON:(NSDictionary *)dailyDic;
@end
