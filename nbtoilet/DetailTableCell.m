//
//  DetailTableCell.m
//  nbtoilet
//
//  Created by lz on 16/8/16.
//  Copyright © 2016年 bjcy. All rights reserved.
//

#import "DetailTableCell.h"

@implementation DetailTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        CGRect rect = [[UIScreen mainScreen] bounds];
        CGSize size = rect.size;
        CGFloat width = size.width;
        
        self.lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(60, 20, 100, 25)];
        self.lbTitle.text = @"";
        self.lbTitle.font = [UIFont systemFontOfSize:16];
        self.lbTitle.textColor = [UIColor blackColor];
        
        self.lbContent = [[UILabel alloc] initWithFrame:CGRectMake(width-210, 20, 200, 25)];
        self.lbContent.font=[UIFont systemFontOfSize:16];
        self.lbContent.textColor=[UIColor darkGrayColor];
        self.lbContent.textAlignment = NSTextAlignmentRight;
        self.lbContent.text=@"";
        
        self.ivIcon = [[UIImageView alloc] initWithFrame:CGRectMake(23, 23, 18, 18)];
        
        [self.contentView addSubview:self.ivIcon];
        [self.contentView addSubview:self.lbContent];
        [self.contentView addSubview:self.lbTitle];
    }
    return self;
}

@end
