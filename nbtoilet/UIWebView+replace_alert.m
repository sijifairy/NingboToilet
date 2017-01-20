//
//  UIWebView+replace_alert.m
//  nbtoilet
//
//  Created by lz on 1/20/17.
//  Copyright © 2017 bjcy. All rights reserved.
//

#import "UIWebView+replace_alert.h"

@implementation UIWebView (replace_alert)

- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame {
    
    
    UIAlertView* customAlert = [[UIAlertView alloc] initWithTitle:@""
                                                          message:message
                                                         delegate:nil
                                                cancelButtonTitle:@"确定"
                                                otherButtonTitles:nil];
    
    [customAlert show];
//    [customAlert release];
    
}
@end
