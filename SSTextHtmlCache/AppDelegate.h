//
//  AppDelegate.h
//  SSTextHtmlCache
//
//  Created by simpleem on 15/12/1.
//  Copyright © 2015年 simpleem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIDownloadCache.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic,retain) ASIDownloadCache *myCache;

@end

