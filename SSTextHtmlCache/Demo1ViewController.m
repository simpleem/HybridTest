//
//  Demo1ViewController.m
//  SSTextHtmlCache
//
//  Created by simpleem on 15/12/2.
//  Copyright © 2015年 simpleem. All rights reserved.
//

#import "Demo1ViewController.h"
#import "WeatherModel.h"
#import "MBProgressHUD+NJ.h"
//#import "UIImageView+WebCache.h"
@interface Demo1ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIImageView *backgroundImageView;


@property (nonatomic, strong) NSArray *dailyArray;

@property (nonatomic, strong) NSArray *hourlyArray;
@property(nonatomic,strong)NSMutableArray *hcarray;
@property(nonatomic,strong)NSOperationQueue *queue;

@property(nonatomic,strong)NSMutableDictionary *imagesDic;
@property(nonatomic,strong)NSString *cachesPath;
@property(nonatomic,strong)UIView *controllerView;

@end

@implementation Demo1ViewController

-(NSString *)cachesPath{
    if (!_cachesPath) {
        _cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
    }
    return _cachesPath;
}

-(NSMutableDictionary *)imagesDic{
    if (!_imagesDic) {
        _imagesDic = [NSMutableDictionary new];
    }
    return _imagesDic;
}

-(NSOperationQueue *)queue{
    if (!_queue) {
        _queue = [[NSOperationQueue alloc]init];
    }
    return _queue;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpTableView];
    [self sendRequestGetJSON];
    self.view.backgroundColor = [UIColor whiteColor];
    CGRect buttonbounds = CGRectMake(0, 20, 40, 25);
    UIButton *button = [[UIButton alloc]initWithFrame:buttonbounds];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    CGRect rect = CGRectMake(0, 50, self.view.bounds.size.width, self.view.bounds.size.height);
    self.tableView.frame = rect;
}
-(void)buttonClicked:(UIButton *)senter{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)sendRequestGetJSON {
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://api.worldweatheronline.com/free/v2/weather.ashx?q=shenzhen&num_of_days=5&format=json&tp=6&key=17b1ab83b007db838c5b89a7497da"]];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
        if (statusCode == 200) {
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            self.hourlyArray = [self hourlyWeathFromJSON:jsonDic];
            self.dailyArray = [self dailyWeathFromJSON:jsonDic];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.tableView reloadData];
            });
            
        } else {
            NSLog(@"返回失败：%@", error.userInfo);
        }
    }];
    [task resume];
}
#pragma mark -- 解析后的数据存储到数组中
- (NSArray *)hourlyWeathFromJSON:(NSDictionary *)jsonDic {
    NSMutableArray *hourlMutableArray = [NSMutableArray array];
    NSArray *hourlyArray = jsonDic[@"data"][@"weather"][0][@"hourly"];
    for (NSDictionary *hourlyDic in hourlyArray) {
        WeatherModel *hourlyMode = [WeatherModel weatherWithHourlyJSON:hourlyDic];
        
        [hourlMutableArray addObject:hourlyMode];
    }
    
    return [hourlMutableArray copy];
}

- (void)setUpTableView {
    CGRect bounds = CGRectMake(0, 50, self.view.bounds.size.width, self.view.bounds.size.height);
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:bounds];
    self.backgroundImageView.image = [UIImage imageNamed:@"bg.png"];
    [self.view addSubview:self.backgroundImageView];
    self.tableView = [UITableView new];
    self.tableView.frame = bounds;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
    self.tableView.pagingEnabled = YES;
    [self.view addSubview:self.tableView];
}
- (NSArray *)dailyWeathFromJSON:(NSDictionary *)dailyDic {
    NSArray *dailyArray = dailyDic[@"data"][@"weather"];
    NSMutableArray *dailyMutalArray = [NSMutableArray array];
    for (NSDictionary *dailyDic in dailyArray) {
        WeatherModel *dailyMode = [WeatherModel weatherWithDailyJSON:dailyDic];
        [dailyMutalArray addObject:dailyMode];
    }
    
    return [dailyMutalArray copy];
}
#pragma mark -- data source / delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? self.hourlyArray.count + 1 : self.dailyArray.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    cell.textLabel.textColor = [UIColor whiteColor];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Hourly Forecast";
            cell.imageView.image = nil;
            cell.detailTextLabel.text = @"";
        } else {
            WeatherModel *weatherModel = self.hourlyArray[indexPath.row - 1];
            
            [self configureCell:cell weather:weatherModel cellAtIndexPath:indexPath isHourly:YES];
        }
    } else {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Daily Forecast";
        } else {
            WeatherModel *weatherModel = self.dailyArray[indexPath.row - 1];
            [self configureCell:cell weather:weatherModel cellAtIndexPath:indexPath isHourly:NO];
        }
    }
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell weather:(WeatherModel *)weather cellAtIndexPath:(NSIndexPath *)indexPath isHourly:(BOOL)isHourly {
    cell.textLabel.text = isHourly ? [NSString stringWithFormat:@"%.0f:00", weather.time] : weather.date;
    
    cell.detailTextLabel.text = isHourly ? [NSString stringWithFormat:@"%.0f˚", weather.temp] : [NSString stringWithFormat:@"%.0f˚ / %.0f˚", weather.maxTemp, weather.minTemp];
        self.queue = [[NSOperationQueue alloc] init];
    NSString *filePath1 = [self.cachesPath stringByAppendingPathComponent:[weather.iconURL lastPathComponent]];
    UIImage *image = [UIImage imageWithContentsOfFile:filePath1];
//       UIImage *image = self.imagesDic[weather.iconURL];
//    NSLog(@"image:%@",image);
    
    if (image) {
        cell.imageView.image = image;
    }else{
        
        //从沙盒中读取图片
        NSString *filePath = [self.cachesPath stringByAppendingPathComponent:[weather.iconURL lastPathComponent]];
        //        NSLog(@"weather.iconURL:%@",weather.iconURL);
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        if (data) {
            [MBProgressHUD showMessage:@"正从本地缓存中加载" toView:self.view];
            //沙盒中有相应的图片数据
            cell.imageView.image = [UIImage imageWithData:data];
        }else{
            //占位符占图
            cell.imageView.image = [UIImage imageNamed:@"placeholder.png"];
            //内存中没有下载的图片
            [MBProgressHUD showMessage:@"正从网络中加载..." toView:self.view];
            //开始下载
            [self downloadImage:weather cell:cell indexPath:indexPath];
        }
            }

}

-(void)downloadImage:(WeatherModel *)weather cell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath{
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSData *iconData = [NSData dataWithContentsOfURL:weather.iconURL];
        NSLog(@"下载完毕：%@", weather.iconURL);
        //往字典中缓存
        UIImage *image = [UIImage imageWithData:iconData];
        NSLog(@"image:%@",image);
        self.imagesDic[weather.iconURL] = image;
        
        //第一次：往沙盒中存图片
        NSData *data = UIImagePNGRepresentation(image);
        NSString *filePath = [self.cachesPath stringByAppendingPathComponent:[weather.iconURL lastPathComponent]];
        [self.imagesDic writeToFile:filePath atomically:YES];
        NSLog(@"filePath:%@",filePath);
        [data writeToFile:filePath atomically:YES];
        //回到主线程设置cell的image
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            //设置cell的图片
            cell.imageView.image = [UIImage imageWithData:iconData];
            
        }];
    }];
    [self.queue addOperation:operation];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger cellCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    //整个屏幕的高除以行数
    return [UIScreen mainScreen].bounds.size.height / cellCount;
}

#pragma mark -- 内存警告
-(void)didReceiveMemoryWarning{
    [self.queue cancelAllOperations];
    [self.imagesDic removeAllObjects];
}
@end
