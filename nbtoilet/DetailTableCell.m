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
        
        self.lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(60, 16, 100, 25)];
        self.lbTitle.text = @"";
        self.lbTitle.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        self.lbTitle.textColor = [UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1];
        
        self.lbContent = [[UILabel alloc] initWithFrame:CGRectMake(width-210, 16, 200, 25)];
        self.lbContent.font=[UIFont fontWithName:@"Helvetica-Bold" size:16];
        self.lbContent.textColor=[UIColor colorWithRed:107/255.0 green:107/255.0 blue:107/255.0 alpha:1];
        self.lbContent.textAlignment = NSTextAlignmentRight;	
        self.lbContent.text=@"";
        
        self.ivIcon = [[UIImageView alloc] initWithFrame:CGRectMake(23, 19, 18, 18)];
        
        [self.contentView addSubview:self.ivIcon];
        [self.contentView addSubview:self.lbContent];
        [self.contentView addSubview:self.lbTitle];
    }
    return self;
}

@end
