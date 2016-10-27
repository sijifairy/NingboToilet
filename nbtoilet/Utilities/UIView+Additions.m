//
//  UIView+Additions.m
//  WXWeibo
//
//  Created by 成旭 杨 on 21/12/13.

//

#import "UIView+Additions.h"

@implementation UIView (Additions)
-(UIViewController*)viewController
{
   UIResponder *next=[self nextResponder];
    do{
        if([next isKindOfClass:[UIViewController class]])
        {
            return (UIViewController*)next;
        }else
        {
            next=[self nextResponder];
        }
   }while(true);
}
@end
