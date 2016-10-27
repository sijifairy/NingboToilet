//
//  webTableViewController.h
//  nbtoilet
//
//  Created by lz on 16/9/3.
//  Copyright © 2016年 bjcy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface webTableViewController : UIViewController<UIWebViewDelegate>
{
    
    IBOutlet UIWebView *webView;
    
    UIActivityIndicatorView *activityIndicatorView;
    UIView *opaqueView;
}

@property (nonatomic) NSString* toiletID;

@end
