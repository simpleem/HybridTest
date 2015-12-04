//
//  SSCacheWebView.m
//  SSTextHtmlCache
//
//  Created by simpleem on 15/12/3.
//  Copyright © 2015年 simpleem. All rights reserved.
//  必须导入的框架为：ASI, MBProgressHud, Reachability为目前定制

#import "SSCacheWebView.h"
#import "ASIWebPageRequest.h"
#import "ASIDownloadCache.h"
#import "MBProgressHUD+NJ.h"
#import "Reachability.h"
#import "Reachability.h"

@interface SSCacheWebView ()

@property (strong, nonatomic) ASIWebPageRequest *theRequest;

@property (strong, nonatomic) Reachability *reach;

@property (assign, nonatomic) BOOL isConnectNetwork;

@end

@implementation SSCacheWebView

- (instancetype)init{

    if (self = [super init]) {
        
        // 监听网络状态
        Reachability *reach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
        self.reach = reach;
        NSLog(@"current status: %zi",[reach currentReachabilityStatus]);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachableChange:) name:kReachabilityChangedNotification object:nil];
        [reach startNotifier];
    }
    
    return self;
}

// 监听是否联网
- (void)reachableChange:(NSNotification *)noti{
    
    Reachability *reach = [noti object];
    
    BOOL isConnectNetwork;
    switch (reach.currentReachabilityStatus) {
        case NotReachable:
            
            isConnectNetwork = NO;
            break;
        case ReachableViaWiFi:
        case ReachableViaWWAN:
            
            isConnectNetwork = YES;
            break;
    }
    
    self.isConnectNetwork = isConnectNetwork;
}


-(void)loadURL:(NSURL *)url{
    
    [self.theRequest cancel];
    
    self.theRequest = [ASIWebPageRequest requestWithURL:url];
    
    // 设置缓存文件的策略 permanent永久存储
    [self.theRequest setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [self.theRequest setDelegate:self];
    [self.theRequest setDidFailSelector:@selector(webPageFetchFailed:)];
    [self.theRequest setDidFinishSelector:@selector(webPageFetchSucceeded:)];
    
    // Tell the request to embed external resources directly in the page
    [self.theRequest setUrlReplacementMode:ASIReplaceExternalResourcesWithData];
    
    // It is strongly recommended you use a download cache with ASIWebPageRequest
    // When using a cache, external resources are automatically stored in the cache
    [self.theRequest setDownloadCache:[ASIDownloadCache sharedCache]];
    
    // Ask the download cache for a place to store the cached data
    // This is the most efficient way for an ASIWebPageRequest to store a web page
    [self.theRequest setDownloadDestinationPath:
     [[ASIDownloadCache sharedCache] pathToStoreCachedResponseDataForRequest:self.theRequest]];
    
    // 判断是否已经缓存
    NSString *cachePath = [self.theRequest cachePathForRequest:self.theRequest];
    NSString *htmlStr = [NSString stringWithContentsOfFile:cachePath encoding:NSUTF8StringEncoding error:nil];
    
    if (htmlStr) {// 页面存在缓存
        
        // 1. 判断md5
        [MBProgressHUD showMessage:@"正从本地缓存中加载" toView:self];
        [self loadHTMLString:htmlStr baseURL:url];
        
    }else{// 页面不存在缓存
        
        [self.theRequest startAsynchronous];
        [MBProgressHUD showMessage:@"正从网络中加载..." toView:self];
    }
}

- (void)webPageFetchFailed:(ASIHTTPRequest *)theRequest
{
    NSLog(@"%@",[theRequest error]);
}

- (void)webPageFetchSucceeded:(ASIHTTPRequest *)theRequest
{
    NSString *response = [NSString stringWithContentsOfFile:
                          [self.theRequest downloadDestinationPath] encoding:NSUTF8StringEncoding error:nil];
    [self loadHTMLString:response baseURL:[self.theRequest url]];
}

// 删除缓存
- (void)deleteCache{
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *cacheDocumentPath = [[self.theRequest downloadDestinationPath] stringByDeletingLastPathComponent];
    NSLog(@"%@",cacheDocumentPath);
    
    // 笔记
    NSArray *contents = [fileMgr contentsOfDirectoryAtPath:cacheDocumentPath error:nil];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *fileName;
    while (fileName = [e nextObject]) {
        
        NSString *filePath = [cacheDocumentPath stringByAppendingPathComponent:fileName];
        NSLog(@"remove %@ : %zi", fileName, [fileMgr removeItemAtPath:filePath error:nil]);
        
    }
    
    [MBProgressHUD showSuccess:@"更换版本成功" toView:self];
}


@end
