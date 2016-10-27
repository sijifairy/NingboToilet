//
//  UILabel+createLabel.h
//  doctorApp
//
//  Created by richardYang on 3/22/14.
//  Copyright (c) 2014 richardYang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (createLabel)
+(UILabel *)generateUIlabelWithColor:(UIColor *)color andFont:(UIFont*)font andAlpha:(float)alpha;
+(UILabel *)generateUIlabelWithColor:(UIColor *)color andFont:(UIFont*)font;
@end
