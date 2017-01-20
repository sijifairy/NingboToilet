//
//  webTableViewController.m
//  nbtoilet
//
//  Created by lz on 16/9/3.
//  Copyright © 2016年 bjcy. All rights reserved.
//

#import "webTableViewController.h"
#import "UIWebView+replace_alert.h"

@interface webTableViewController ()

@end

@implementation webTableViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    UILabel *lbTitle = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)/2-100, 35, 200, 20)];
    [lbTitle setTextAlignment:NSTextAlignmentCenter];
    [lbTitle setText:@"请您评价"];
    [lbTitle setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
    [self.view addSubview:lbTitle];
    
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom ];
    btnBack.frame = CGRectMake(0, 35, 70, 20);
    [btnBack setTitle:@"返回" forState:UIControlStateNormal];
    btnBack.titleLabel.font = [UIFont systemFontOfSize:17];
    [btnBack setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [btnBack setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [btnBack addTarget:self action:@selector(onButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnBack];
    
    webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 70, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 70)];
    [webView setUserInteractionEnabled:YES];//是否支持交互
    //[webView setDelegate:self];
    webView.delegate=self;
    //[webView setOpaque:NO];//opaque是不透明的意思
    [webView setScalesPageToFit:YES];//自动缩放以适应屏幕
    [self.view addSubview:webView];
    
    //加载网页的方式
    //1.创建并加载远程网页
    NSString * strUrl = [NSString stringWithFormat:@"http://116.90.81.94:8023/Check/Consult.aspx?ToiletID=%@",self.toiletID];
    NSLog(strUrl);
    NSURL *url = [NSURL URLWithString:strUrl];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    //2.加载本地文件资源
    /* NSURL *url = [NSURL fileURLWithPath:filePath];
     NSURLRequest *request = [NSURLRequest requestWithURL:url];
     [webView loadRequest:request];*/
    //3.读入一个HTML，直接写入一个HTML代码
    //NSString *htmlPath = [[[NSBundle mainBundle]bundlePath]stringByAppendingString:@"webapp/loadar.html"];
    //NSString *htmlString = [NSString stringWithContentsOfURL:htmlPath encoding:NSUTF8StringEncoding error:NULL];
    //[webView loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:htmlPath]];
    
    opaqueView = [[UIView alloc]initWithFrame:CGRectMake(0, 70, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 70)];
    activityIndicatorView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 70, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 70)];
    [activityIndicatorView setCenter:opaqueView.center];
    [activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [opaqueView setBackgroundColor:[UIColor lightGrayColor]];
    [opaqueView setAlpha:0.6];
    [self.view addSubview:opaqueView];
    [opaqueView addSubview:activityIndicatorView];
    
    
}

- (void)onButtonClicked{
    [self dismissViewControllerAnimated:YES completion:^(){}];
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    [activityIndicatorView startAnimating];
    opaqueView.hidden = NO;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [activityIndicatorView startAnimating];
    opaqueView.hidden = YES;
}

//UIWebView如何判断 HTTP 404 等错误
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSURL *url = [NSURL URLWithString:@"http://www.baidu.com"];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if ((([httpResponse statusCode]/100) == 2)) {
        // self.earthquakeData = [NSMutableData data];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        [ webView loadRequest:[ NSURLRequest requestWithURL: url]];
        webView.delegate = self;
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:
                                  NSLocalizedString(@"HTTP Error",
                                                    @"Error message displayed when receving a connection error.")
                                                             forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"HTTP" code:[httpResponse statusCode] userInfo:userInfo];
        
        if ([error code] == 404) {
            NSLog(@"xx");
            webView.hidden = YES;
        }
        
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
