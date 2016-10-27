//
//  NSImageUtil.m
//  nbtoilet
//
//  Created by lz on 16/8/21.
//  Copyright © 2016年 bjcy. All rights reserved.
//

#import "NSImageUtil.h"

@implementation NSImageUtil

+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    CGImageRef imgRef = img.CGImage;
    CGSize srcSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    if (CGSizeEqualToSize(srcSize, size)) {
        return img;
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);//[UIScreen mainScreen].scale
    CGContextRef context = UIGraphicsGetCurrentContext();
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

+ (void)performViewController: (UIViewController *) source toDestination:(UIViewController*) destination
{
    CGRect sourceFrame = source.view.frame;
    sourceFrame.origin.x = -sourceFrame.size.width;
    
    CGRect destFrame = destination.view.frame;
    destFrame.origin.x = destination.view.frame.size.width;
    destination.view.frame = destFrame;
    
    destFrame.origin.x = 0;
    [source.view.superview addSubview:destination.view];
    [UIView animateWithDuration:.5
                     animations:^{
                         source.view.frame = sourceFrame;
                         destination.view.frame = destFrame;
                     }
                     completion:^(BOOL finished) {
                         [source presentViewController:destination animated:NO completion:nil];
                     }];
}

@end
