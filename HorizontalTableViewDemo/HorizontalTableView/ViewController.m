//
//  ViewController.m
//  HorizontalTableView
//
//  Created by exitingchen on 15/1/27.
//  Copyright (c) 2015年 Nirvawolf. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic,strong) PSHorizontalTableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    self.tableView = [[PSHorizontalTableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 300)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    
    self.view.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_tableView];
    _tableView.center = CGPointMake(screenWidth/2.0f,screenHeight/2.0f);
    
    [_tableView reloadData];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableViewDelegate and datasouce
- (PSHorizontalTableCell *)ps_tableView:(PSHorizontalTableView *)tableView columForIndexPath:(NSUInteger)index
{
    static NSString *const kReuableIdentifier = @"ReuableCell";
    PSHorizontalTableCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuableIdentifier];
    if (!cell) {
        cell = [[PSHorizontalTableCell alloc] init];
        cell.reusableIdentifier = kReuableIdentifier;
    }
    
    if (index % 2 == 0) {
        cell.backgroundColor = [UIColor orangeColor];
    }else{
        cell.backgroundColor = [UIColor greenColor];
    }
    
    return cell;
}

- (CGFloat)ps_tableViewWidthForColum:(PSHorizontalTableView *)tableView colum:(NSUInteger)colum
{
    return 80;
}

- (NSUInteger)numberOfColums:(PSHorizontalTableView *)tableView
{
    return 10;
}


@end
