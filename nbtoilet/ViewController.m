#import "ViewController.h"
#import "DescriptionViewController.h"
#import "NavigationViewController.h"
#import "NSImageUtil.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>

#define APIKey @"2292b5677dddaad976d5f522b650d57f"

@interface ViewController ()<MAMapViewDelegate,NSURLConnectionDataDelegate,UIActionSheetDelegate>{
    MAMapView *_mapView;
    NSMutableArray *annotations;
    CLLocationCoordinate2D lastCoordinate;
    NSArray *toiletArray;
    int selectIndex;
    
    BOOL isFirstLocated;
    BOOL isDetailViewShown;
    UIButton *btnSearch;
    UIButton *btnLocation;
    UIImageView *legendView;
    
    UIView *detailView;
    UILabel *toiletName;
    UILabel *toiletAddress;
    UIButton *btnDetail;
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
    _mapView.allowsBackgroundLocationUpdates = YES;//iOS9以上系统必须配置
    
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
    
    legendView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)-52, CGRectGetHeight(self.view.bounds)-98, 42, 88)];
    [legendView setImage:[NSImageUtil scaleToSize:[UIImage imageNamed:@"zoombg"] size:CGSizeMake(42, 88)]];
    
    UIButton* btnZoomIn = [UIButton buttonWithType:UIButtonTypeCustom];
    btnZoomIn.frame = CGRectMake(9, 10, 24, 24);
    [btnZoomIn setImage:[UIImage imageNamed:@"zoomin"] forState:UIControlStateNormal];
    [legendView addSubview:btnZoomIn];
    
    UIButton* btnZoomOut = [UIButton buttonWithType:UIButtonTypeCustom];
    btnZoomOut.frame = CGRectMake(9, 54, 24, 24);
    [btnZoomOut setImage:[UIImage imageNamed:@"zoomout"] forState:UIControlStateNormal];
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
    UIColor *dividerColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1];
    UIImage *hightlightedImage = [self imageWithColor:dividerColor size:CGSizeMake(CGRectGetWidth(self.view.bounds)/2-15, 34)];
    
    detailView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds)-130,CGRectGetWidth(self.view.bounds), 130)];
    detailView.backgroundColor =[UIColor whiteColor];
    detailView.center = CGPointMake(CGRectGetWidth(detailView.bounds)/2, CGRectGetHeight(self.view.bounds)+65);
    
    UIView* borderTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 0.3)];
    borderTop.backgroundColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1];
    [detailView addSubview:borderTop];
    
    toiletName = [[UILabel alloc] initWithFrame:CGRectMake(15, 8,CGRectGetWidth(self.view.bounds), 30)];
    toiletName.textColor = [UIColor blackColor];
    [toiletName setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16]];
    
    toiletAddress = [[UILabel alloc] initWithFrame:CGRectMake(15, 40,CGRectGetWidth(self.view.bounds), 20)];
    toiletAddress.textColor = [UIColor grayColor];
    [toiletAddress setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13]];
    
    UIView *divider = [[UIView alloc]initWithFrame:CGRectMake(15, 80, CGRectGetWidth(self.view.bounds)-30, 0.3)];
    divider.backgroundColor = dividerColor;
    UIView *divider1 = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)/2, 95, 0.3,20)];
    divider1.backgroundColor = dividerColor;
    
    btnDetail = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDetail.frame = CGRectMake(15,88, CGRectGetWidth(self.view.bounds)/2-15, 34);
    [btnDetail setBackgroundImage:hightlightedImage forState:UIControlStateHighlighted];
    [btnDetail setTitle:@"详情" forState:UIControlStateNormal];
    [btnDetail setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    btnDetail.titleLabel.font = [UIFont systemFontOfSize: 15.0];
    [btnDetail setImage:[NSImageUtil scaleToSize:[UIImage imageNamed:@"detail"] size:CGSizeMake(16, 16)]
               forState:UIControlStateNormal];
    [btnDetail addTarget:self action:@selector(onDetailClicked) forControlEvents:UIControlEventTouchUpInside];
    btnDetail.imageEdgeInsets = UIEdgeInsetsMake(0.0,(CGRectGetWidth(self.view.bounds)-30)/4-108, 0.0, 0.0);
    
    btnNavigation = [UIButton buttonWithType:UIButtonTypeCustom];
    btnNavigation.frame = CGRectMake(CGRectGetWidth(self.view.bounds)/2,88, CGRectGetWidth(self.view.bounds)/2-15, 34);
    [btnNavigation setBackgroundImage:hightlightedImage forState:UIControlStateHighlighted];
    [btnNavigation setTitle:@"去这里" forState:UIControlStateNormal];
    [btnNavigation setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    btnNavigation.titleLabel.font = [UIFont systemFontOfSize: 15.0];
    [btnNavigation setImage:[NSImageUtil scaleToSize:[UIImage imageNamed:@"navigation"] size:CGSizeMake(14, 16)]
                   forState:UIControlStateNormal];
    btnNavigation.imageEdgeInsets = UIEdgeInsetsMake(0.0,CGRectGetWidth(self.view.bounds)/4-108, 0.0, 0.0);
    [btnNavigation addTarget:self action:@selector(onNavigationClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [detailView addSubview:toiletName];
    [detailView addSubview:toiletAddress];
    [detailView addSubview:divider];
    [detailView addSubview:divider1];
    [detailView addSubview:btnDetail];
    [detailView addSubview:btnNavigation];
    [self.view addSubview:detailView];
}

- (void) showDetailView{
    [UIView animateWithDuration:0.4 animations:^{
        detailView.center = CGPointMake(CGRectGetWidth(detailView.bounds)/2, CGRectGetHeight(self.view.bounds)-65);
        btnLocation.center = CGPointMake(btnLocation.center.x,btnLocation.center.y-130);
        legendView.center = CGPointMake(legendView.center.x, legendView.center.y-130);
    }];
    isDetailViewShown = YES;
}

- (void) hideDetailView{
    if(!isDetailViewShown)
        return;
    if([annotations objectAtIndex:selectIndex]){
        MAAnnotationView *lastAnnotation = [annotations objectAtIndex:selectIndex];
        NSDictionary *dict = [toiletArray objectAtIndex:selectIndex];
        NSString *type = [dict objectForKey:@"ToiletType"];
        lastAnnotation.image = [NSImageUtil scaleToSize:[UIImage imageNamed:[self getIconByType:type andIsSelected:NO]] size:CGSizeMake(36, 36)];
    }
    [UIView animateWithDuration:0.2 animations:^{
        detailView.center = CGPointMake(CGRectGetWidth(detailView.bounds)/2, CGRectGetHeight(self.view.bounds)+65);
        btnLocation.center = CGPointMake(btnLocation.center.x,btnLocation.center.y+130);
        legendView.center = CGPointMake(legendView.center.x, legendView.center.y+130);
    }];
    isDetailViewShown = NO;
}

-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
updatingLocation:(BOOL)updatingLocation
{
    if(updatingLocation)
    {
        //取出当前位置的坐标
        //        NSLog(@"latitude : %f,longitude: %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
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
    NSConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if(connection){
        self.dataFromServer = [NSMutableData new];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.dataFromServer appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"%@", [error localizedDescription]);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSLog(@"请求完成！");
    annotations = [NSMutableArray array];
    toiletArray = [NSJSONSerialization
                   JSONObjectWithData:self.dataFromServer
                   options:NSJSONReadingAllowFragments
                   error:nil];
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
        annotationView.tag = annotations.count;
        [annotations addObject:annotationView];
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
    if([annotations objectAtIndex:selectIndex]){
        MAAnnotationView *lastAnnotation = [annotations objectAtIndex:selectIndex];
        NSDictionary *dict = [toiletArray objectAtIndex:selectIndex];
        NSString *type = [dict objectForKey:@"ToiletType"];
        lastAnnotation.image = [NSImageUtil scaleToSize:[UIImage imageNamed:[self getIconByType:type andIsSelected:NO]] size:CGSizeMake(36, 36)];
    }
    if(gesture.view){
        MAAnnotationView *view = gesture.view;
        MAPointAnnotation *annotation = view.annotation;
        selectIndex = [annotation.title intValue];
        if([toiletArray objectAtIndex:selectIndex]){
            NSDictionary *dict = [toiletArray objectAtIndex:selectIndex];
            NSString *name = [dict objectForKey:@"ToiletName"];
            NSString *address = [dict objectForKey:@"Address"];
            NSString *type = [dict objectForKey:@"ToiletType"];
            [toiletName setText:name];
            [toiletAddress setText:address];
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
}

- (void)onNavigationClicked{
    NavigationViewController *controller = [[NavigationViewController alloc]init];
    controller.startCoordinate = lastCoordinate;
    MAAnnotationView *lastAnnotation = [annotations objectAtIndex:selectIndex];
    MAPointAnnotation *annotation = lastAnnotation.annotation;
    controller.destinationCoordinate = annotation.coordinate;
    [NSImageUtil performViewController:self toDestination:controller];
    
    [self sendLocalNotification];
}

- (void) sendLocalNotification{
    // 1.创建本地通知
    UILocalNotification *localNote = [[UILocalNotification alloc] init];
    
    // 2.设置本地通知的内容
    // 2.1.设置通知发出的时间
    localNote.fireDate = [NSDate dateWithTimeIntervalSinceNow:60*20];
    // 2.2.设置通知的内容
    localNote.alertBody = @"请您对公厕进行评价！";
    // 2.3.设置滑块的文字（锁屏状态下：滑动来“解锁”）
    localNote.alertAction = @"解锁";
    // 2.4.决定alertAction是否生效
    localNote.hasAction = NO;
    // 2.5.设置点击通知的启动图片
    localNote.alertLaunchImage = @"123Abc";
    // 2.6.设置alertTitle
    localNote.alertTitle = @"你有一条新通知";
    // 2.7.设置有通知时的音效
    //    localNote.soundName = @"buyao.wav";
    // 2.8.设置应用程序图标右上角的数字
    localNote.applicationIconBadgeNumber = 1;
    
    NSDictionary *dict = [toiletArray objectAtIndex:selectIndex];
    NSString* toiletID = [dict objectForKey:@"ID"];
    NSLog(toiletID);
    // 2.9.设置额外信息
    localNote.userInfo = [NSDictionary dictionaryWithObject:toiletID forKey:@"toiletID"];
    
    // 3.调用通知
    [[UIApplication sharedApplication] scheduleLocalNotification:localNote];
}
@end
