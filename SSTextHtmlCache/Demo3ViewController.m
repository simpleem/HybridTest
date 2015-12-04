//
//  Demo3ViewController.m
//  SSTextHtmlCache
//
//  Created by simpleem on 15/12/2.
//  Copyright © 2015年 simpleem. All rights reserved.
//

#import "Demo3ViewController.h"
#import "SSCacheWebView.h"
#import "MBProgressHUD+NJ.h"
#import "WelcomeViewController.h"

@interface Demo3ViewController ()<UIWebViewDelegate>

- (IBAction)back:(id)sender;

@property (weak, nonatomic) IBOutlet SSCacheWebView *webView;

@end

@implementation Demo3ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView.delegate = self;
    
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSArray *content = [fileMgr contentsOfDirectoryAtPath:bundlePath error:nil];
    NSEnumerator *e = [content objectEnumerator];
    NSString *ePath;
    while (ePath = [e nextObject]) {
//        NSLog(@"%@",ePath);
    }
    
    NSURL * resourcePathURL = [[NSBundle mainBundle] resourceURL];
    if(resourcePathURL)
    {
        NSURL * urlToLoad = [resourcePathURL URLByAppendingPathComponent: @"index.html"];
        if(urlToLoad)
        {
            NSURLRequest *request = [NSURLRequest requestWithURL:urlToLoad];
            [self.webView loadRequest:request];
        }  
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    
}

- (IBAction)back:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma - mark UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView{

    [MBProgressHUD  hideHUDForView:self.webView animated:YES];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{

    // 回调地址
    NSString *urlString = request.URL.relativeString;
    urlString = [urlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSRange range = [urlString rangeOfString:@"/ios/api/"];
    if (range.location != NSNotFound) {// location存在，是js对ios的回调
        
        NSString *mainUrl = [urlString substringFromIndex:range.location + range.length];
        NSLog(@"%@",mainUrl);
//        NSString *
        if ([mainUrl hasPrefix:@"login"]) {// 登陆界面
            
            NSArray *array = [mainUrl componentsSeparatedByString:@"/"];
            
            UIAlertController *alerVC = [UIAlertController alertControllerWithTitle:@"Native弹窗" message:[NSString stringWithFormat:@"输入的账户：%@ 密码： %@", array[1], array[2]]  preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
                WelcomeViewController *welcomViewVC = [[WelcomeViewController alloc] init];
                welcomViewVC.userName = array[1];
                [self presentViewController:welcomViewVC animated:YES completion:nil];
            }];
            [alerVC addAction:confirm];
            [self presentViewController:alerVC animated:YES completion:nil];

        }else if ([mainUrl hasPrefix:@"/ios/api/regist"]){// 注册界面
        
            NSLog(@"注册页面的回调");
        }
    }


    [urlString stringByRemovingPercentEncoding];
    
    return YES;
}




@end
