//
//  DescriptionViewController.m
//  nbtoilet
//
//  Created by lz on 16/8/14.
//  Copyright © 2016年 bjcy. All rights reserved.
//

#import "DescriptionViewController.h"
#import "DetailTableCell.h"
#import "NSImageUtil.h"

@interface DescriptionViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *table;
}

@property (strong, nonatomic) NSMutableArray *books;
@property (strong, nonatomic) NSMutableArray *details;
@property (strong, nonatomic) NSMutableArray *icons;

@end

@implementation DescriptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    table = [[UITableView alloc] initWithFrame:CGRectMake(0, 70, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-70)];
    
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom ];
    btnBack.frame = CGRectMake(0, 35, 70, 20);
    [btnBack setTitle:@"返回" forState:UIControlStateNormal];
    btnBack.titleLabel.font = [UIFont systemFontOfSize:17];
    [btnBack setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [btnBack setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [btnBack addTarget:self action:@selector(onButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *lbTitle = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)/2-40, 35, 80, 20)];
    [lbTitle setText:@"公厕详情"];
    [lbTitle setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
    
    [self.view addSubview:table];
    [self.view addSubview:btnBack];
    [self.view addSubview:lbTitle];
    
    table.dataSource = self;
    table.delegate = self;
    table.allowsSelection = NO;
    _books = [[NSMutableArray alloc] initWithObjects:
              @"公厕名称:",
              @"位置:",
              @"类型:",
              @"开放时间:",
              @"收费情况:",
              @"厕纸情况:",
              @"无障碍设施:",
              @"管理部门:",
              @"联系人:",
              @"联系电话:",
              nil];
    _icons = [[NSMutableArray alloc] initWithObjects:
              @"detail",
              @"address",
              @"type",
              @"time",
              @"dollar",
              @"toiletPaper",
              @"wheelchair",
              @"company",
              @"user",
              @"phone", nil];
    _details =  [[NSMutableArray alloc] init];
    [_details addObject:[self.toiletDic objectForKey:@"ToiletName"]];
    [_details addObject:[self.toiletDic objectForKey:@"Address"]];
    [_details addObject:[self.toiletDic objectForKey:@"ToiletType"]];
    [_details addObject:[self.toiletDic objectForKey:@"ServiceTime"]];
    bool isFree = [self.toiletDic objectForKey:@"IsFree"];
    [_details addObject:isFree?@"免费":@"收费"];
    bool hasToiletPaper = [self.toiletDic objectForKey:@"HasToiletPaper"];
    [_details addObject:hasToiletPaper?@"有厕纸":@"无厕纸"];
    bool hasDeformity = [self.toiletDic objectForKey:@"HasDeformity"];
    [_details addObject:hasDeformity?@"有":@"无"];
    [_details addObject:[self.toiletDic objectForKey:@"DepartmentName"]];
    [_details addObject:[self.toiletDic objectForKey:@"ContactPerson"]];
    [_details addObject:[self.toiletDic objectForKey:@"ContactPhone"]];
//    table.tableHeaderView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"location_star"]];
//    table.tableFooterView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"location_normal"]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onButtonClicked{
    [self dismissViewControllerAnimated:YES completion:^(){}];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellId = @"cellId";
    DetailTableCell *cell = [tableView dequeueReusableCellWithIdentifier: cellId];
    if(cell == nil){
        cell = [[DetailTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.layer.cornerRadius = 12;
    cell.layer.masksToBounds = YES;
    NSUInteger rowNo = indexPath.row;
    [cell.lbTitle setText:[_books objectAtIndex:rowNo]];
    [cell.lbContent setText:[_details objectAtIndex:rowNo]];
    [cell.ivIcon setImage:[NSImageUtil scaleToSize:[UIImage imageNamed:[_icons objectAtIndex:rowNo]] size:CGSizeMake(20, 20)]];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _books.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

@end