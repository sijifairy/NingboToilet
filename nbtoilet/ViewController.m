#import "ViewController.h"
#import "DescriptionViewController.h"
#import "NavigationViewController.h"
#import "NSImageUtil.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "webTableViewController.h"
#define APIKey @"2292b5677dddaad976d5f522b650d57f"

@interface ViewController ()<MAMapViewDelegate,NSURLConnectionDataDelegate,UIActionSheetDelegate>{
    MAMapView *_mapView;
    MAAnnotationView *lastAnnotationView;
    NSString *lastAnnotationType;
    CLLocationCoordinate2D lastCoordinate;
    NSArray *toiletArray;
    int selectIndex;
    
    BOOL isFirstLocated;
    BOOL isDetailViewShown;
    UIButton *btnSearch;
    UIButton *btnLocation;
    UIButton *btnZoomIn;
    UIButton *btnZoomOut;
    UIView *legendView;
    
    UIView *detailView;
    UILabel *toiletName;
    UILabel *toiletAddress;
    UIButton *btnDetail;
    UIButton *btnFeedback;
    UIButton *btnNavigation;
}

@property (strong,nonatomic)NSMutableData *dataFromServer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    
    [self initMap];
    [self initControls];
    [self initDetailView];
    
    UIImageView *ivTopBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 75)];
    [ivTopBackground setImage:[NSImageUtil scaleToSize:[UIImage imageNamed:@"top_background"] size:CGSizeMake(CGRectGetWidth(self.view.bounds), 75)]];
    [self.view addSubview:ivTopBackground];
    
    UILabel *lbTitle = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)/2-150, 35, 300, 33)];
    [lbTitle setTextAlignment:NSTextAlignmentCenter];
    [lbTitle setText:@"宁 波 公 厕 导 视 系 统"];
    [lbTitle setTextColor:[UIColor darkGrayColor]];
    [lbTitle setFont:[UIFont fontWithName:@"Helvetica-Bold" size:21]];
    [self.view addSubview:lbTitle];
}

- (void)viewDidDisappear:(BOOL)animated{
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initMap{
    [AMapServices sharedServices].apiKey = APIKey;
    
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 73, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 73)];
    _mapView.delegate = self;
    _mapView.showsCompass = NO;
    _mapView.showsScale= NO;
    isFirstLocated = YES;
    _mapView.showsUserLocation = TRUE;
    _mapView.rotateEnabled= NO;    //NO表示禁用旋转手势，YES表示开启
    _mapView.rotateCameraEnabled= NO;    //NO表示禁用倾斜手势，YES表示开启
    _mapView.logoCenter = CGPointMake(CGRectGetWidth(self.view.bounds)-40, CGRectGetHeight(self.view.bounds)-95);
    _mapView.pausesLocationUpdatesAutomatically = NO;
    
    //添加手势
    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideDetailView)];
    [_mapView addGestureRecognizer:gesture];
    [self.view addSubview:_mapView];
}

- (void) initControls{
    btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSearch.frame = CGRectMake(CGRectGetWidth(self.view.bounds)/2-100, CGRectGetHeight(self.view.bounds)-100, 200, 50);
    btnSearch.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    btnSearch.backgroundColor = [UIColor colorWithRed:0 green:150/255.0 blue:255/255.0 alpha:1];
    btnSearch.layer.cornerRadius = 8;
    [btnSearch addTarget:self action:@selector(onSearchClicked) forControlEvents:UIControlEventTouchUpInside];
    [btnSearch setTitle:@"搜索附近公厕" forState:UIControlStateNormal];
    
    btnLocation = [UIButton buttonWithType:UIButtonTypeCustom];
    btnLocation.frame = CGRectMake(10, CGRectGetHeight(self.view.bounds)-50, 37, 40);
    btnLocation.backgroundColor = [UIColor whiteColor];
    btnLocation.alpha=0.9;
    btnLocation.layer.borderColor = [[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1] CGColor];
    btnLocation.layer.borderWidth = 0.3;
    btnLocation.layer.cornerRadius = 5;
    [btnLocation setImage:[NSImageUtil scaleToSize:[UIImage imageNamed:@"location"] size:CGSizeMake(37, 40)]
                 forState:UIControlStateNormal];
    [btnLocation setImage:[NSImageUtil scaleToSize:[UIImage imageNamed:@"location"] size:CGSizeMake(37, 40)]
                 forState:UIControlStateHighlighted];
    [btnLocation addTarget:self action:@selector(onLocationClicked) forControlEvents:UIControlEventTouchUpInside];
    
    legendView =[[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)-52, CGRectGetHeight(self.view.bounds)-98, 42, 88)];
    UIImageView *legendBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 42, 88)];
    [legendBackgroundView setImage:[NSImageUtil scaleToSize:[UIImage imageNamed:@"zoombg"] size:CGSizeMake(42, 88)]];
    [legendView addSubview:legendBackgroundView];
    
    btnZoomIn = [UIButton buttonWithType:UIButtonTypeCustom];
    btnZoomIn.frame = CGRectMake(9, 10, 24, 24);
    [btnZoomIn setImage:[UIImage imageNamed:@"zoomin"] forState:UIControlStateNormal];
    [btnZoomIn addTarget:self action:@selector(onZoomInClicked) forControlEvents:UIControlEventTouchUpInside];
    [legendView addSubview:btnZoomIn];
    
    btnZoomOut = [UIButton buttonWithType:UIButtonTypeCustom];
    btnZoomOut.frame = CGRectMake(9, 54, 24, 24);
    [btnZoomOut setImage:[UIImage imageNamed:@"zoomout"] forState:UIControlStateNormal];
    [btnZoomOut addTarget:self action:@selector(onZoomOutClicked) forControlEvents:UIControlEventTouchUpInside];
    [legendView addSubview:btnZoomOut];
    
    [self.view addSubview:legendView];
    
    
    UIImageView *ivLegend = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)-210, 85, 200, 44)];
    [ivLegend setImage:[NSImageUtil scaleToSize:[UIImage imageNamed:@"legend"] size:CGSizeMake(200, 44)]];
    [self.view addSubview:ivLegend];
    
    [self.view addSubview:btnSearch];
    [self.view addSubview:btnLocation];
}

- (void) initDetailView{
    isDetailViewShown = NO;
    UIColor *dividerColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:0.8];
    UIColor *textColor = [UIColor colorWithRed:64/255.0 green:64/255.0 blue:64/255.0 alpha:1];
    UIImage *hightlightedImage = [self imageWithColor:dividerColor size:CGSizeMake(CGRectGetWidth(self.view.bounds)/2-15, 34)];
    
    detailView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds)-116,CGRectGetWidth(self.view.bounds), 116)];
    detailView.backgroundColor =[UIColor whiteColor];
    detailView.center = CGPointMake(CGRectGetWidth(detailView.bounds)/2, CGRectGetHeight(self.view.bounds)+65);
    
    UIView* borderTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 0.6)];
    borderTop.backgroundColor = dividerColor;
    [detailView addSubview:borderTop];
    
    toiletName = [[UILabel alloc] initWithFrame:CGRectMake(15, 15,CGRectGetWidth(self.view.bounds), 20)];
    toiletName.textColor = [UIColor blackColor];
    [toiletName setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16]];
    
    toiletAddress = [[UILabel alloc] initWithFrame:CGRectMake(15, 40,CGRectGetWidth(self.view.bounds), 20)];
    toiletAddress.textColor = [UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1];
    [toiletAddress setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13]];
    
    UIView *divider = [[UIView alloc]initWithFrame:CGRectMake(0, 72, CGRectGetWidth(self.view.bounds), 0.6)];
    divider.backgroundColor = dividerColor;
    
    btnDetail = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDetail.frame = CGRectMake(0,77, CGRectGetWidth(self.view.bounds)/3, 34);
    [btnDetail setBackgroundImage:hightlightedImage forState:UIControlStateHighlighted];
    [btnDetail setTitle:@" 详情" forState:UIControlStateNormal];
    [btnDetail setTitleColor:textColor forState:UIControlStateNormal];
    btnDetail.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
    [btnDetail setImage:[NSImageUtil scaleToSize:[UIImage imageNamed:@"detail"] size:CGSizeMake(20, 20)]
               forState:UIControlStateNormal];
    [btnDetail addTarget:self action:@selector(onDetailClicked) forControlEvents:UIControlEventTouchUpInside];
    btnDetail.imageEdgeInsets = UIEdgeInsetsMake(0.0,(CGRectGetWidth(self.view.bounds)-30)/4-108, 0.0, 0.0);
    
    btnFeedback = [UIButton buttonWithType:UIButtonTypeCustom];
    btnFeedback.frame = CGRectMake(CGRectGetWidth(self.view.bounds)/3,77, CGRectGetWidth(self.view.bounds)/3, 34);
    [btnFeedback setBackgroundImage:hightlightedImage forState:UIControlStateHighlighted];
    [btnFeedback setTitle:@" 评价反馈" forState:UIControlStateNormal];
    [btnFeedback setTitleColor:textColor forState:UIControlStateNormal];
    btnFeedback.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
    [btnFeedback setImage:[NSImageUtil scaleToSize:[UIImage imageNamed:@"feedback"] size:CGSizeMake(20, 20)]
                   forState:UIControlStateNormal];
    btnFeedback.imageEdgeInsets = UIEdgeInsetsMake(0.0,CGRectGetWidth(self.view.bounds)/4-108, 0.0, 0.0);
    [btnFeedback addTarget:self action:@selector(onFeedbackClicked) forControlEvents:UIControlEventTouchUpInside];
    
    btnNavigation = [UIButton buttonWithType:UIButtonTypeCustom];
    btnNavigation.frame = CGRectMake(CGRectGetWidth(self.view.bounds)/3*2,77, CGRectGetWidth(self.view.bounds)/3, 34);
    [btnNavigation setBackgroundImage:hightlightedImage forState:UIControlStateHighlighted];
    [btnNavigation setTitle:@" 去这里" forState:UIControlStateNormal];
    [btnNavigation setTitleColor:textColor forState:UIControlStateNormal];
    btnNavigation.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
    [btnNavigation setImage:[NSImageUtil scaleToSize:[UIImage imageNamed:@"navigation"] size:CGSizeMake(20, 20)]
                   forState:UIControlStateNormal];
    btnNavigation.imageEdgeInsets = UIEdgeInsetsMake(0.0,CGRectGetWidth(self.view.bounds)/4-108, 0.0, 0.0);
    [btnNavigation addTarget:self action:@selector(onNavigationClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [detailView addSubview:toiletName];
    [detailView addSubview:toiletAddress];
    [detailView addSubview:divider];
    [detailView addSubview:btnDetail];
    [detailView addSubview:btnFeedback];
    [detailView addSubview:btnNavigation];
    [self.view addSubview:detailView];
}

- (void) showDetailView{
    [UIView animateWithDuration:0.4 animations:^{
        detailView.center = CGPointMake(CGRectGetWidth(detailView.bounds)/2, CGRectGetHeight(self.view.bounds)-58);
        btnLocation.center = CGPointMake(btnLocation.center.x,btnLocation.center.y-116);
        legendView.center = CGPointMake(legendView.center.x, legendView.center.y-116);
    }];
    isDetailViewShown = YES;
}

- (void) hideDetailView{
    if(!isDetailViewShown)
        return;
    if(lastAnnotationView){
        lastAnnotationView.image =[NSImageUtil scaleToSize:[UIImage imageNamed:[self getIconByType:lastAnnotationType andIsSelected:NO]] size:CGSizeMake(36, 36)];
    }
    [UIView animateWithDuration:0.2 animations:^{
        detailView.center = CGPointMake(CGRectGetWidth(detailView.bounds)/2, CGRectGetHeight(self.view.bounds)+58);
        btnLocation.center = CGPointMake(btnLocation.center.x,btnLocation.center.y+116);
        legendView.center = CGPointMake(legendView.center.x, legendView.center.y+116);
    }];
    isDetailViewShown = NO;
}

-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
updatingLocation:(BOOL)updatingLocation
{
    if(updatingLocation)
    {
        //取出当前位置的坐标
        //NSLog(@"latitude : %f,longitude: %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
        
        //fake location
        //lastCoordinate =CLLocationCoordinate2DMake(29.871158,121.603829);
        lastCoordinate =CLLocationCoordinate2DMake(userLocation.coordinate.latitude,userLocation.coordinate.longitude);
        if(isFirstLocated){
            [_mapView setCenterCoordinate:lastCoordinate animated:YES];
            [_mapView setZoomLevel:13 animated:YES];
            isFirstLocated = NO;
        }
    }
}

- (void)onLocationClicked
{
    [_mapView setCenterCoordinate:lastCoordinate animated:YES];
}

- (void)onZoomInClicked
{
    [_mapView setZoomLevel:_mapView.zoomLevel+1 animated:YES];
}

- (void)onZoomOutClicked
{
    [_mapView setZoomLevel:_mapView.zoomLevel-1 animated:YES];
}

- (void) onSearchClicked
{
    [btnSearch setAlpha:1];
    [UIButton animateWithDuration:0.5 animations:^{
        [btnSearch setAlpha:0];
    } completion:^(BOOL finished){
        NSLog(@"animation finished!");
    }];
    [UIView animateWithDuration:0.5 animations:^{
        [legendView setAlpha:1];
    }];
    
    NSString *strUrl = [NSString stringWithFormat:@"http://116.90.81.94:8023/webservice/Data.asmx/GetToiletsAll?para={\"LAT\":\"%f\",\"LNG\":\"%f\"}",lastCoordinate.latitude,lastCoordinate.longitude];
    strUrl = [strUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:strUrl];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    //NSURLRequest  *request=[NSURLRequest requestWithURL:url];
    NSConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if(connection){
        self.dataFromServer = [NSMutableData new];
    }
    //NSURLResponse *respone;//获取连接的响应信息，可以为nil
    //NSError *error;        //获取连接的错误时的信息，可以为nil
    //3.得到服务器数据
    //NSData  *data=[NSURLConnection sendSynchronousRequest:request returningResponse:&respone error:&error];
    

}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.dataFromServer appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"%@", [error localizedDescription]);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSLog(@"请求完成！");
    toiletArray = [NSJSONSerialization
                   JSONObjectWithData:self.dataFromServer
                   options:NSJSONReadingAllowFragments
                   error:nil];
    if(toiletArray == nil){
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"请求失败！" message:@"请查看手机网络状态，或联系管理人员。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    for(int i=0;i<toiletArray.count;i++){
        NSDictionary *dict = [toiletArray objectAtIndex:i];
        NSString *lat = [dict objectForKey:@"Latitude"];
        NSString *lng = [dict objectForKey:@"Longitude"];
        MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
        pointAnnotation.coordinate = CLLocationCoordinate2DMake([lat doubleValue], [lng doubleValue]);
        pointAnnotation.title = [NSString stringWithFormat:@"%d",i];
        
        [_mapView addAnnotation:pointAnnotation];
    }
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *reuseIndetifier = @"annotationReuseIndetifier";
        MAAnnotationView *annotationView = (MAAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:reuseIndetifier];
        }
        annotationView.canShowCallout = YES;       //设置气泡可以弹出，默认为NO
        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        int index = [annotation.title integerValue];
        NSDictionary *dict = [toiletArray objectAtIndex:index];
        NSString *type = [dict objectForKey:@"ToiletType"];
        annotationView.image = [NSImageUtil scaleToSize:[UIImage imageNamed:[self getIconByType:type andIsSelected:NO]] size:CGSizeMake(36, 36)];
        annotationView.userInteractionEnabled = YES;
        //添加手势
        UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onToiletOverlayClicked:)];
        [annotationView addGestureRecognizer:gesture];
        //设置中心点偏移，使得标注底部中间点成为经纬度对应点
        annotationView.centerOffset = CGPointMake(0, -18);
        return annotationView;
    }
    return nil;
}

- (NSString *) getIconByType :(NSString *)type andIsSelected: (bool) selected{
    if([type  isEqual: @"星级公厕"]){
        if(selected)
            return @"toilet_star_clicked";
        else
            return @"toilet_star";
    }else{
        if(selected)
            return @"toilet_normal_clicked";
        else
            return @"toilet_normal";
    }
}

-(void) onToiletOverlayClicked:(UITapGestureRecognizer *) gesture{
    if(lastAnnotationView){
        lastAnnotationView.image =[NSImageUtil scaleToSize:[UIImage imageNamed:[self getIconByType:lastAnnotationType andIsSelected:NO]] size:CGSizeMake(36, 36)];
    }
    if(gesture.view){
        MAAnnotationView *view = gesture.view;
        MAPointAnnotation *annotation = view.annotation;
        selectIndex = [annotation.title intValue];
        lastAnnotationView = view;
        if([toiletArray objectAtIndex:selectIndex]){
            NSDictionary *dict = [toiletArray objectAtIndex:selectIndex];
            NSString *name = [dict objectForKey:@"ToiletName"];
            NSString *address = [dict objectForKey:@"Address"];
            NSString *type = [dict objectForKey:@"ToiletType"];
            lastAnnotationType= type;
            NSString *distance = [dict objectForKey:@"Distance"];
            NSString *dis = [NSString stringWithFormat:@"%@距离%.2f千米",[address isEqualToString:@""]?@"":@"   ",[distance floatValue]/1000];
            [toiletName setText:name];
            [toiletAddress setText:[NSString stringWithFormat:@"%@%@",address,dis]];
            [_mapView setCenterCoordinate:annotation.coordinate animated:YES];
            view.image = [NSImageUtil scaleToSize:[UIImage imageNamed:[self getIconByType:type andIsSelected:YES]] size:CGSizeMake(48, 48)];
        }
        if(!isDetailViewShown){
            [self showDetailView];
        }
    }
}

- (UIImage *) imageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void) onDetailClicked{
    NSLog(@"detail clicked");
    DescriptionViewController *controller = [[DescriptionViewController alloc]init];
    controller.toiletDic = [toiletArray objectAtIndex:selectIndex];
    [NSImageUtil performViewController:self toDestination:controller];
    
    [self sendLocalNotification];
}

- (void)onFeedbackClicked{
    NSDictionary *dict = [toiletArray objectAtIndex:selectIndex];
    NSString* toiletID = [dict objectForKey:@"ID"];
    webTableViewController *controller = [[webTableViewController alloc]init];
    controller.toiletID = toiletID;
    [NSImageUtil performViewController:self toDestination:controller];
}

- (void)onNavigationClicked{
    NavigationViewController *controller = [[NavigationViewController alloc]init];
    controller.startCoordinate = lastCoordinate;
    MAPointAnnotation *annotation = lastAnnotationView.annotation;
    controller.destinationCoordinate = annotation.coordinate;
    [NSImageUtil performViewController:self toDestination:controller];
    
    [self sendLocalNotification];
}

- (void) sendLocalNotification{
    NSArray *narry=[[UIApplication sharedApplication] scheduledLocalNotifications];
    NSUInteger account=[narry count];
    for(int i=0;i < account;i++){
        UILocalNotification *myUILocalNotification = [narry objectAtIndex:i];
        [[UIApplication sharedApplication] cancelLocalNotification:myUILocalNotification];
    }
    
    UILocalNotification *localNote = [[UILocalNotification alloc] init];
    localNote.fireDate = [NSDate dateWithTimeIntervalSinceNow:60*20];
    localNote.alertBody = @"请您对公厕进行评价！";
    localNote.alertAction = @"解锁";
    localNote.hasAction = NO;
    localNote.alertTitle = @"你有一条新通知";
    localNote.applicationIconBadgeNumber = 1;
    
    NSDictionary *dict = [toiletArray objectAtIndex:selectIndex];
    NSString* toiletID = [dict objectForKey:@"ID"];
    localNote.userInfo = [NSDictionary dictionaryWithObject:toiletID forKey:@"toiletID"];
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNote];
}
@end
