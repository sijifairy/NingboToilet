//
//  UILabel+createLabel.m
//  doctorApp
//
//  Created by richardYang on 3/22/14.
//  Copyright (c) 2014 richardYang. All rights reserved.
//

#import "UILabel+createLabel.h"

@implementation UILabel (createLabel)
+(UILabel *)generateUIlabelWithColor:(UIColor *)color andFont:(UIFont*)font andAlpha:(float)alpha
{
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectZero];
    label.textColor=color;
    label.font=font;
    label.backgroundColor=[UIColor clearColor];
    label.lineBreakMode=NSLineBreakByTruncatingTail;
    label.alpha=alpha;
    return label;
}
+(UILabel *)generateUIlabelWithColor:(UIColor *)color andFont:(UIFont*)font
{
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectZero];
    label.textColor=color;
    label.font=font;
    label.backgroundColor=[UIColor clearColor];
    label.lineBreakMode=NSLineBreakByTruncatingTail;
    return label;
}
@end
