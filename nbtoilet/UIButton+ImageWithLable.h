//
//  UIButton+ImageWithLable.h
//  nbtoilet
//
//  Created by lz on 16/8/21.
//  Copyright © 2016年 bjcy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIButton (UIButtonImageWithLable)
- (void) setImage:(UIImage *)image withTitle:(NSString *)title forState:(UIControlState)stateType;
@end
