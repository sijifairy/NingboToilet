//
//  NavigationViewController.m
//  nbtoilet
//
//  Created by lz on 16/8/21.
//  Copyright © 2016年 bjcy. All rights reserved.
//

#import "NavigationViewController.h"
#import "UIButton+ImageWithLable.h"
#import "NSImageUtil.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "MANaviRoute.h"
#import "CommonUtility.h"
#import "GPSNaviViewController.h"

#define APIKey @"2292b5677dddaad976d5f522b650d57f"

const NSString *RoutePlanningViewControllerStartTitle       = @"起点";
const NSString *RoutePlanningViewControllerDestinationTitle = @"终点";
const NSInteger RoutePlanningPaddingEdge                    = 80;

@interface NavigationViewController ()<MAMapViewDelegate,AMapSearchDelegate>{
    MAMapView *_mapView;
    AMapSearchAPI *search;
    UIButton * btnCar;
    UIButton * btnBus;
    UIButton * btnWalk;
    UIButton *btnNavigation;
    BOOL isFirstLocated;
    BOOL isFirstWalk;
    UIButton *btnLocation;
    UIButton *btnZoomIn;
    UIButton *btnZoomOut;
    UIView *legendView;
    CLLocationCoordinate2D lastCoordinate;
}

/* 路径规划类型 */
@property (nonatomic) AMapRoutePlanningType routePlanningType;

@property (nonatomic, strong) AMapRoute *route;

@property (nonatomic, strong) AMapRoute *routeCar;

@property (nonatomic, strong) AMapRoute *routeBus;

@property (nonatomic, strong) AMapRoute *routeWalk;

/* 当前路线方案索引值. */
@property (nonatomic) NSInteger currentCourse;
/* 路线方案个数. */
@property (nonatomic) NSInteger totalCourse;

/* 用于显示当前路线方案. */
@property (nonatomic) MANaviRoute * naviRoute;

@property (nonatomic, strong) MAPointAnnotation *startAnnotation;
@property (nonatomic, strong) MAPointAnnotation *destinationAnnotation;

@end

@implementation NavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initMap];
    [self initNavigationBar];
    [self initButtons];
    [self addDefaultAnnotations];
    
    [self resetButtons];
    [self highlightButton:btnWalk withType:@"walk"];
    
    [self SearchNaviWithType:0];
    [self SearchNaviWithType:1];
    [self SearchNaviWithType:2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNavigationBar{
    self.view.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom ];
    btnBack.frame = CGRectMake(0, 35, 70, 20);
    [btnBack setTitle:@"返回" forState:UIControlStateNormal];
    btnBack.titleLabel.font = [UIFont systemFontOfSize:17];
    [btnBack setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [btnBack setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [btnBack addTarget:self action:@selector(onBackButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *lbTitle = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)/2-40, 35, 80, 20)];
    [lbTitle setText:@"路径规划"];
    [lbTitle setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
    
    UIColor *dividerColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:0.8];
    UIView *divider = [[UIView alloc]initWithFrame:CGRectMake(0, 65, CGRectGetWidth(self.view.bounds), 0.6)];
    divider.backgroundColor = dividerColor;
    
    [self.view addSubview:btnBack];
    [self.view addSubview:lbTitle];
    [self.view addSubview:divider];
    
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
    [self.view addSubview:btnLocation];
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

- (void)onBackButtonClicked{
    [self dismissViewControllerAnimated:YES completion:^(){}];
}

- (void)initButtons{
    btnCar = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCar.frame = CGRectMake(CGRectGetWidth(self.view.bounds)/2-60, 75, 120, 40);
    [btnCar setImage:[NSImageUtil scaleToSize:[UIImage imageNamed:@"car_off"] size:CGSizeMake(20, 20)] withTitle:@"--分钟" forState:UIControlStateNormal];
    [btnCar addTarget:self action:@selector(onCarClicked) forControlEvents:UIControlEventTouchUpInside];
    
    btnBus = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBus.frame = CGRectMake(CGRectGetWidth(self.view.bounds)/4*3-60, 75, 120, 40);
    [btnBus setImage:[NSImageUtil scaleToSize:[UIImage imageNamed:@"bus_off"] size:CGSizeMake(20, 20)] withTitle:@"--分钟" forState:UIControlStateNormal];
    [btnBus addTarget:self action:@selector(onBusClicked) forControlEvents:UIControlEventTouchUpInside];
    
    btnWalk = [UIButton buttonWithType:UIButtonTypeCustom];
    btnWalk.frame = CGRectMake(CGRectGetWidth(self.view.bounds)/4-60, 75, 120, 40);
    [btnWalk setImage:[NSImageUtil scaleToSize:[UIImage imageNamed:@"walk_off"] size:CGSizeMake(20, 20)] withTitle:@"--分钟" forState:UIControlStateNormal];
    [btnWalk addTarget:self action:@selector(onWalkClicked) forControlEvents:UIControlEventTouchUpInside];
    
    btnNavigation = [UIButton buttonWithType:UIButtonTypeCustom];
    btnNavigation.frame = CGRectMake(CGRectGetWidth(self.view.bounds)/2-100, CGRectGetHeight(self.view.bounds)-50, 200, 40);
    btnNavigation.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    btnNavigation.backgroundColor = [UIColor colorWithRed:0 green:150/255.0 blue:255/255.0 alpha:1];
    btnNavigation.layer.cornerRadius = 8;
    [btnNavigation addTarget:self action:@selector(onNavigationClicked) forControlEvents:UIControlEventTouchUpInside];
    [btnNavigation setTitle:@"导航" forState:UIControlStateNormal];
    btnNavigation.hidden = YES;
    
    [self.view addSubview:btnCar];
    [self.view addSubview:btnBus];
    [self.view addSubview:btnWalk];
    [self.view addSubview:btnNavigation];
}

- (void)onCarClicked{
    if(self.routeCar.paths.count>0){
        [self resetButtons];
        [self highlightButton:btnCar withType:@"car"];
        [self presentCurrentCourse:0];
    }else{
        
    }
}

- (void)onBusClicked{
    if(self.routeBus.transits.count>0){
        [self resetButtons];
        [self highlightButton:btnBus withType:@"bus"];
        [self presentCurrentCourse:2];
    } else{
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无公交路线" message:@"当前路线没有公交路线，请选择其他交通工具。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    }
}

- (void)onWalkClicked{
    if(self.routeWalk.paths.count>0){
        [self resetButtons];
        [self highlightButton:btnWalk withType:@"walk"];
        [self presentCurrentCourse:1];
    } else{
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无步行路线" message:@"当前路线距离过远，请选择驾车或公交前往。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    }
}

- (void) onNavigationClicked{
    GPSNaviViewController *controller = [[GPSNaviViewController alloc]init];
    controller.startCoordinate = self.startCoordinate;
    controller.destinationCoordinate = self.destinationCoordinate;
    [NSImageUtil performViewController:self toDestination:controller];
}

- (void)resetButtons{
    [btnCar setImage:[NSImageUtil scaleToSize:[UIImage imageNamed:@"car_off"] size:CGSizeMake(20, 20)] forState:UIControlStateNormal];
    [btnBus setImage:[NSImageUtil scaleToSize:[UIImage imageNamed:@"bus_off"] size:CGSizeMake(20, 20)] forState:UIControlStateNormal];
    [btnWalk setImage:[NSImageUtil scaleToSize:[UIImage imageNamed:@"walk_off"] size:CGSizeMake(20, 20)] forState:UIControlStateNormal];
    [btnCar setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btnBus setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btnWalk setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    btnNavigation.hidden = YES;
}

- (void)highlightButton:(UIButton *)button withType:(NSString *)type{
    if([type isEqual:@"car"]){
        btnNavigation.hidden = NO;
    }
    [button setImage:[NSImageUtil scaleToSize:[UIImage imageNamed:[type stringByAppendingString:@"_on"]] size:CGSizeMake(20, 20)] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:51/255.0 green:133/255.0 blue:1 alpha:1] forState:UIControlStateNormal];
}

- (void)initMap{
    [AMapServices sharedServices].apiKey = APIKey;
    
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 125, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 125)];
    _mapView.delegate = self;
    _mapView.showsCompass = NO;
    _mapView.showsScale= NO;
    isFirstLocated = YES;
    isFirstWalk = YES;
    _mapView.showsUserLocation = TRUE;
    _mapView.rotateEnabled= NO;    //NO表示禁用旋转手势，YES表示开启
    _mapView.rotateCameraEnabled= NO;    //NO表示禁用倾斜手势，YES表示开启
    _mapView.logoCenter = CGPointMake(CGRectGetWidth(self.view.bounds)-40, CGRectGetHeight(self.view.bounds)-95);
    _mapView.pausesLocationUpdatesAutomatically = NO;
    _mapView.allowsBackgroundLocationUpdates = YES;//iOS9以上系统必须配置
    _mapView.layer.borderColor = [[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1] CGColor];
    _mapView.layer.borderWidth = 0.8;
    
    search = [[AMapSearchAPI alloc] init];
    search.delegate = self;
    [self.view addSubview:_mapView];
}

-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if(updatingLocation)
    {
        lastCoordinate =CLLocationCoordinate2DMake(userLocation.coordinate.latitude,userLocation.coordinate.longitude);
    }
}

- (void)addDefaultAnnotations
{
    MAPointAnnotation *startAnnotation = [[MAPointAnnotation alloc] init];
    startAnnotation.coordinate = self.startCoordinate;
    startAnnotation.title      = (NSString*)RoutePlanningViewControllerStartTitle;
    startAnnotation.subtitle   = [NSString stringWithFormat:@"{%f, %f}", self.startCoordinate.latitude, self.startCoordinate.longitude];
    self.startAnnotation = startAnnotation;
    
    MAPointAnnotation *destinationAnnotation = [[MAPointAnnotation alloc] init];
    destinationAnnotation.coordinate = self.destinationCoordinate;
    destinationAnnotation.title      = (NSString*)RoutePlanningViewControllerDestinationTitle;
    destinationAnnotation.subtitle   = [NSString stringWithFormat:@"{%f, %f}", self.destinationCoordinate.latitude, self.destinationCoordinate.longitude];
    self.destinationAnnotation = destinationAnnotation;
    
    [_mapView addAnnotation:startAnnotation];
    [_mapView addAnnotation:destinationAnnotation];
}



/* 清空地图上已有的路线. */
- (void)clear
{
    [self.naviRoute removeFromMapView];
}

/* 将selectedIndex 转换为响应的AMapRoutePlanningType. */
- (AMapRoutePlanningType)searchTypeForSelectedIndex:(NSInteger)selectedIndex
{
    AMapRoutePlanningType navitgationType = 0;
    
    switch (selectedIndex)
    {
        case 0: navitgationType = AMapRoutePlanningTypeDrive;   break;
        case 1: navitgationType = AMapRoutePlanningTypeWalk; break;
        case 2: navitgationType = AMapRoutePlanningTypeBus;     break;
        default:NSAssert(NO, @"%s: selectedindex = %ld is invalid for RoutePlanning", __func__, (long)selectedIndex); break;
    }
    
    return navitgationType;
}


#pragma mark - MAMapViewDelegate

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[LineDashPolyline class]])
    {
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:((LineDashPolyline *)overlay).polyline];
        polylineRenderer.lineWidth   = 6;
        polylineRenderer.strokeColor = [UIColor redColor];
        
        return polylineRenderer;
    }
    if ([overlay isKindOfClass:[MANaviPolyline class]])
    {
        MANaviPolyline *naviPolyline = (MANaviPolyline *)overlay;
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:naviPolyline.polyline];
        
        polylineRenderer.lineWidth = 6;
        
        if (naviPolyline.type == MANaviAnnotationTypeWalking)
        {
            polylineRenderer.strokeColor = self.naviRoute.walkingColor;
        }
        else if (naviPolyline.type == MANaviAnnotationTypeRailway)
        {
            polylineRenderer.strokeColor = self.naviRoute.railwayColor;
        }
        else
        {
            polylineRenderer.strokeColor = self.naviRoute.routeColor;
        }
        
        return polylineRenderer;
    }
    if ([overlay isKindOfClass:[MAMultiPolyline class]])
    {
        MAMultiColoredPolylineRenderer * polylineRenderer = [[MAMultiColoredPolylineRenderer alloc] initWithMultiPolyline:overlay];
        
        polylineRenderer.lineWidth = 8;
        polylineRenderer.strokeColors = [self.naviRoute.multiPolylineColors copy];
        polylineRenderer.gradient = YES;
        
        return polylineRenderer;
    }
    
    return nil;
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *routePlanningCellIdentifier = @"RoutePlanningCellIdentifier";
        
        MAAnnotationView *poiAnnotationView = (MAAnnotationView*)[_mapView dequeueReusableAnnotationViewWithIdentifier:routePlanningCellIdentifier];
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                             reuseIdentifier:routePlanningCellIdentifier];
        }
        
        poiAnnotationView.canShowCallout = YES;
        poiAnnotationView.image = nil;
        
        if ([annotation isKindOfClass:[MANaviAnnotation class]])
        {
            switch (((MANaviAnnotation*)annotation).type)
            {
                case MANaviAnnotationTypeRailway:
                    poiAnnotationView.image = [UIImage imageNamed:@"railway_station"];
                    break;
                    
                case MANaviAnnotationTypeBus:
                    poiAnnotationView.image = [UIImage imageNamed:@"bus"];
                    break;
                    
                case MANaviAnnotationTypeDrive:
                    poiAnnotationView.image = [UIImage imageNamed:@"car"];
                    break;
                    
                case MANaviAnnotationTypeWalking:
                    poiAnnotationView.image = [UIImage imageNamed:@"man"];
                    break;
                    
                default:
                    break;
            }
        }
        else
        {
            /* 起点. */
            if ([[annotation title] isEqualToString:(NSString*)RoutePlanningViewControllerStartTitle])
            {
                poiAnnotationView.image = [NSImageUtil scaleToSize:[UIImage imageNamed:@"startPoint"] size:CGSizeMake(28, 38)];
            }
            /* 终点. */
            else if([[annotation title] isEqualToString:(NSString*)RoutePlanningViewControllerDestinationTitle])
            {
                poiAnnotationView.image = [NSImageUtil scaleToSize:[UIImage imageNamed:@"endPoint"] size:CGSizeMake(28, 38)];
            }
            
        }
        
        return poiAnnotationView;
    }
    
    return nil;
}


#pragma mark - AMapSearchDelegate

/* 路径规划搜索回调. */
- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response
{
    if (response.route == nil)
    {
        return;
    }
    
    /* 公交路径规划. */
    if ([request class] == [AMapTransitRouteSearchRequest class])
    {
        self.routeBus = response.route;
        if(self.routeBus.transits.count>0){
            [btnBus setTitle:[NSString stringWithFormat: @"%ld分钟", self.routeBus.transits[0].duration/60] forState:UIControlStateNormal];
        }else{
            [btnBus setTitle:@"" forState:UIControlStateNormal];
        }
    }
    else if ([request class] == [AMapWalkingRouteSearchRequest class])
    {
        self.routeWalk = response.route;
        if(self.routeWalk.paths.count>0){
            [btnWalk setTitle:[NSString stringWithFormat: @"%ld分钟", self.routeWalk.paths[0].duration/60] forState:UIControlStateNormal];
        }else{
            [btnWalk setTitle:@"" forState:UIControlStateNormal];
        }
        if(isFirstWalk)
        {
            [self presentCurrentCourse:1];
            isFirstWalk = false;
        }
    }else
    {
        self.routeCar = response.route;
        if(self.routeCar.paths.count>0){
            [btnCar setTitle:[NSString stringWithFormat:@"%ld分钟", self.routeCar.paths[0].duration/60] forState:UIControlStateNormal];
        }else{
            [btnCar setTitle:@"" forState:UIControlStateNormal];
        }
    }

    self.currentCourse = 0;
}

/* 展示当前路线方案. */
- (void)presentCurrentCourse :(NSInteger)type
{
    [self clear];
    
    /* 公交路径规划. */
    if (type==2)
    {
        if(self.routeBus.transits.count>0){
            self.naviRoute = [MANaviRoute naviRouteForTransit:self.routeBus.transits[self.currentCourse] startPoint:[AMapGeoPoint locationWithLatitude:self.startAnnotation.coordinate.latitude longitude:self.startAnnotation.coordinate.longitude] endPoint:[AMapGeoPoint locationWithLatitude:self.destinationAnnotation.coordinate.latitude longitude:self.destinationAnnotation.coordinate.longitude]];
        }else{
            
        }
    }
    else if (type==1)
    {
        if(self.routeWalk.paths.count>0){
            self.naviRoute = [MANaviRoute naviRouteForPath:self.routeWalk.paths[self.currentCourse] withNaviType:type showTraffic:YES startPoint:[AMapGeoPoint locationWithLatitude:self.startAnnotation.coordinate.latitude longitude:self.startAnnotation.coordinate.longitude] endPoint:[AMapGeoPoint locationWithLatitude:self.destinationAnnotation.coordinate.latitude longitude:self.destinationAnnotation.coordinate.longitude]];
        }else{
            
        }
    }
    else
    {
        if(self.routeCar.paths.count>0){
            self.naviRoute = [MANaviRoute naviRouteForPath:self.routeCar.paths[self.currentCourse] withNaviType:type showTraffic:YES startPoint:[AMapGeoPoint locationWithLatitude:self.startAnnotation.coordinate.latitude longitude:self.startAnnotation.coordinate.longitude] endPoint:[AMapGeoPoint locationWithLatitude:self.destinationAnnotation.coordinate.latitude longitude:self.destinationAnnotation.coordinate.longitude]];
        }else{
            
        }
    }
    
    [self.naviRoute setAnntationVisible:YES];
    [self.naviRoute addToMapView:_mapView];
    
    /* 缩放地图使其适应polylines的展示. */
    [_mapView setVisibleMapRect:[CommonUtility mapRectForOverlays:self.naviRoute.routePolylines]
                    edgePadding:UIEdgeInsetsMake(RoutePlanningPaddingEdge, RoutePlanningPaddingEdge, RoutePlanningPaddingEdge, RoutePlanningPaddingEdge)
                       animated:YES];
}

#pragma mark - RoutePlanning Search

/* 公交路径规划搜索. */
- (void)searchRoutePlanningBus
{
    AMapTransitRouteSearchRequest *navi = [[AMapTransitRouteSearchRequest alloc] init];
    
    navi.requireExtension = YES;
    navi.city             = @"beijing";
    
    /* 出发点. */
    navi.origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude
                                           longitude:self.startCoordinate.longitude];
    /* 目的地. */
    navi.destination = [AMapGeoPoint locationWithLatitude:self.destinationCoordinate.latitude
                                                longitude:self.destinationCoordinate.longitude];
    
    [search AMapTransitRouteSearch:navi];
}

/* 步行路径规划搜索. */
- (void)searchRoutePlanningWalk
{
    AMapWalkingRouteSearchRequest *navi = [[AMapWalkingRouteSearchRequest alloc] init];
    
    /* 提供备选方案*/
    navi.multipath = 1;
    
    /* 出发点. */
    navi.origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude
                                           longitude:self.startCoordinate.longitude];
    /* 目的地. */
    navi.destination = [AMapGeoPoint locationWithLatitude:self.destinationCoordinate.latitude
                                                longitude:self.destinationCoordinate.longitude];
    
    [search AMapWalkingRouteSearch:navi];
}

/* 驾车路径规划搜索. */
- (void)searchRoutePlanningDrive
{
    AMapDrivingRouteSearchRequest *navi = [[AMapDrivingRouteSearchRequest alloc] init];
    
    navi.requireExtension = YES;
    navi.strategy = 5;
    /* 出发点. */
    navi.origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude
                                           longitude:self.startCoordinate.longitude];
    /* 目的地. */
    navi.destination = [AMapGeoPoint locationWithLatitude:self.destinationCoordinate.latitude
                                                longitude:self.destinationCoordinate.longitude];
    
    [search AMapDrivingRouteSearch:navi];
}

/* 根据routePlanningType来执行响应的路径规划搜索*/
- (void)SearchNaviWithType:(AMapRoutePlanningType)searchType
{
    switch (searchType)
    {
        case AMapRoutePlanningTypeDrive:
        {
            [self searchRoutePlanningDrive];
            
            break;
        }
        case AMapRoutePlanningTypeWalk:
        {
            [self searchRoutePlanningWalk];
            
            break;
        }
        case AMapRoutePlanningTypeBus:
        {
            [self searchRoutePlanningBus];
            
            break;
        }
    }
}

/* 切换路径规划搜索类型. */
- (void)searchTypeAction:(NSInteger)interger
{
    self.routePlanningType = [self searchTypeForSelectedIndex:interger];
    
    self.route = nil;
    self.totalCourse   = 0;
    self.currentCourse = 0;
    
    /* 发起路径规划搜索请求. */
    [self SearchNaviWithType:self.routePlanningType];
}




@end
