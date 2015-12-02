//
//  ViewController.m
//  SSTextHtmlCache
//
//  Created by simpleem on 15/12/1.
//  Copyright © 2015年 simpleem. All rights reserved.
//

#import "ViewController.h"
#import "ASIWebPageRequest.h"
#import "ASIDownloadCache.h"
#import "Reachability.h"
#import "MBProgressHUD+NJ.h"

@interface ViewController ()<UIWebViewDelegate>

- (IBAction)load163:(id)sender;
- (IBAction)loadBaidu:(id)sender;
- (IBAction)loadTencent:(id)sender;

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) ASIWebPageRequest *request;

@property (assign, nonatomic) NSStringEncoding encode;

@property (strong, nonatomic) Reachability *reach;

@property (weak, nonatomic) IBOutlet UILabel *currentNetworkLabel;

- (IBAction)changeVersion:(id)sender;

- (IBAction)back:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView.delegate = self;
    
    // 监听网络状态
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.apple.com"];
    self.reach = reach;
    NSLog(@"current status: %zi",[reach currentReachabilityStatus]);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachableChange:) name:kReachabilityChangedNotification object:nil];
    [reach startNotifier];
    
    // 初始化加载
    [self load163:nil];
}

- (void)reachableChange:(NSNotification *)noti{

    Reachability *reach = [noti object];
    
    NSString *currentNetWorkStr;
    switch (reach.currentReachabilityStatus) {
        case NotReachable:
            
            currentNetWorkStr = @"当前网络不可用";
            break;
        case ReachableViaWiFi:
            
            currentNetWorkStr = @"当前wifi环境";
            break;
        case ReachableViaWWAN:
            
            currentNetWorkStr = @"当前为手机网络环境";
            break;
    }
    self.currentNetworkLabel.text = currentNetWorkStr;
}

- (IBAction)load163:(id)sender {
    
    NSURL *url = [NSURL URLWithString:@"http://www.163.com"];
    [self loadURL:url];
}

- (IBAction)loadBaidu:(id)sender{

    NSURL *url = [NSURL URLWithString:@"http://www.baidu.com"];
    [self loadURL:url];
}

- (IBAction)loadTencent:(id)sender {
    
    NSURL *url = [NSURL URLWithString:@"http://www.360.com"];
    [self loadURL:url];
}

-(void)loadURL:(NSURL *)url{
    
    [self.request cancel];
    
    self.request = [ASIWebPageRequest requestWithURL:url];
    
    // 设置缓存文件的策略 permanent永久存储
    [self.request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [self.request setDelegate:self];
    [self.request setDidFailSelector:@selector(webPageFetchFailed:)];
    [self.request setDidFinishSelector:@selector(webPageFetchSucceeded:)];
    
    // Tell the request to embed external resources directly in the page
    [self.request setUrlReplacementMode:ASIReplaceExternalResourcesWithData];
    
    // It is strongly recommended you use a download cache with ASIWebPageRequest
    // When using a cache, external resources are automatically stored in the cache
    [self.request setDownloadCache:[ASIDownloadCache sharedCache]];
    
    // Ask the download cache for a place to store the cached data
    // This is the most efficient way for an ASIWebPageRequest to store a web page
    [self.request setDownloadDestinationPath:
     [[ASIDownloadCache sharedCache] pathToStoreCachedResponseDataForRequest:self.request]];
    
    // 判断是否已经缓存
    NSString *cachePath = [self.request cachePathForRequest:self.request];
    NSString *htmlStr = [NSString stringWithContentsOfFile:cachePath encoding:NSUTF8StringEncoding error:nil];

    if (htmlStr) {// 页面存在缓存
        
        // 1. 判断md5
        [MBProgressHUD showMessage:@"正从本地缓存中加载" toView:self.view];
        [self.webView loadHTMLString:htmlStr baseURL:url];
        
    }else{// 页面不存在缓存
    
        [self.request startAsynchronous];
        [MBProgressHUD showMessage:@"正从网络中加载..." toView:self.view];
    }
    
}

- (void)webPageFetchFailed:(ASIHTTPRequest *)theRequest
{
    NSLog(@"%@",[theRequest error]);
}

- (void)webPageFetchSucceeded:(ASIHTTPRequest *)theRequest
{
    NSString *response = [NSString stringWithContentsOfFile:
                          [self.request downloadDestinationPath] encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:response baseURL:[self.request url]];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{

    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}


- (IBAction)changeVersion:(id)sender {

    [self deleteCache];
}

- (IBAction)back:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)deleteCache{
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *cacheDocumentPath = [[self.request downloadDestinationPath] stringByDeletingLastPathComponent];
    NSLog(@"%@",cacheDocumentPath);
    
    // 笔记
    NSArray *contents = [fileMgr contentsOfDirectoryAtPath:cacheDocumentPath error:nil];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *fileName;
    while (fileName = [e nextObject]) {
        
        NSString *filePath = [cacheDocumentPath stringByAppendingPathComponent:fileName];
        NSLog(@"remove %@ : %zi", fileName, [fileMgr removeItemAtPath:filePath error:nil]);
        
    }
    
    [MBProgressHUD showSuccess:@"更换版本成功" toView:self.view];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{

    
    return YES;
}

@end
