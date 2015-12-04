//
//  SSCacheWebView.h
//  SSTextHtmlCache
//
//  Created by simpleem on 15/12/3.
//  Copyright © 2015年 simpleem. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSCacheWebView : UIWebView

// 加载缓存策略的网页
-(void)loadURL:(NSURL *)url;

// 删除所有的页面缓存
- (void)deleteCache;

@end
