//
//  WelcomeViewController.m
//  SSTextHtmlCache
//
//  Created by simpleem on 15/12/4.
//  Copyright © 2015年 simpleem. All rights reserved.
//

#import "WelcomeViewController.h"

@interface WelcomeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
- (IBAction)back:(id)sender;

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.welcomeLabel.text = [NSString stringWithFormat:@"登陆成功欢迎你，%@", self.userName];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)back:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
