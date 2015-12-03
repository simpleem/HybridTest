//
//  Demo3ViewController.m
//  SSTextHtmlCache
//
//  Created by simpleem on 15/12/2.
//  Copyright © 2015年 simpleem. All rights reserved.
//

#import "Demo3ViewController.h"

@interface Demo3ViewController ()

- (IBAction)back:(id)sender;

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation Demo3ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSArray *content = [fileMgr contentsOfDirectoryAtPath:bundlePath error:nil];
    NSEnumerator *e = [content objectEnumerator];
    NSString *ePath;
    while (ePath = [e nextObject]) {
        NSLog(@"%@",ePath);
    }
    
    
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"index.html" ofType:nil];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"%@",htmlString);
    [self.webView loadHTMLString:htmlString baseURL:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    
}

- (IBAction)back:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
