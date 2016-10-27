//
//  UITextField+create.m
//  social
//
//  Created by richard on 11/21/15.
//  Copyright © 2015 com.richard. All rights reserved.
//

#import "UITextField+create.h"

@implementation UITextField(create)

+(UITextField *)generateUITextFieldWithColor:(UIColor *)color andFont:(UIFont*)font {
    UITextField *valueField = [[UITextField alloc] initWithFrame:CGRectZero];
    valueField.secureTextEntry = NO;
    valueField.borderStyle = UITextBorderStyleRoundedRect;
    valueField.placeholder = @"";
    valueField.font = font;
    valueField.textColor = color;
    valueField.keyboardType = UIKeyboardTypeDefault;
    valueField.clearButtonMode = UITextFieldViewModeWhileEditing;
    valueField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    valueField.returnKeyType = UIReturnKeyDone;
    return valueField;
}
@end
