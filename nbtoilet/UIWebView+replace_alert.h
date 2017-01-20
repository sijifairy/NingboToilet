//
//  UIWebView+replace_alert.h
//  nbtoilet
//
//  Created by lz on 1/20/17.
//  Copyright © 2017 bjcy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebView (replace_alert)

- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame;
@end
