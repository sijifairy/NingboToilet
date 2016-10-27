//
//  NSImageUtil.h
//  nbtoilet
//
//  Created by lz on 16/8/21.
//  Copyright © 2016年 bjcy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSImageUtil : NSObject

+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size;
+ (void)performViewController: (UIViewController *) source toDestination:(UIViewController*) destination;

@end
