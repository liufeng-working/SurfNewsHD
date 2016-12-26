//
//  WeatherManager.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-2-26.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "WeatherManager.h"
#import "AppSettings.h"
#import "UpdateWeatherRequest.h"
#import "UpdateWeatherResponse.h"
#import "SurfRequestGenerator.h"
#import "GTMHTTPFetcher.h"
#import "NSString+Extensions.h"
#import "EzJsonParser.h"
#import "WeakRefArray.h"
#import "RSWeakifySelf.h"
#import "DispatchUtil.h"


//(北京市区坐标为:北纬39.9”,东经116. 3”。)
#define BJLongitude 116.3   // 北京经度
#define BJLatitude 39.9     // 北京纬度



@implementation SurfLocationHelper {
    
    NSMutableArray *_notifyList;
    
    SurfLocationHandle _localHandle;
}
+(SurfLocationHelper*)sharedInstance{
    static SurfLocationHelper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [SurfLocationHelper new];
        [instance initLocationManager];
    });
    return instance;
}

// 判断系统是否开启了定位服务和是否允许对本软件定位授权
+(BOOL)isLocationEnable
{
    if ([CLLocationManager locationServicesEnabled]) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            return YES;
        }
        
        CLAuthorizationStatus status = kCLAuthorizationStatusAuthorized;
        if([[[UIDevice currentDevice] systemVersion] isVersionHigherThanOrEqualsTo:@"8.0"]){
            status = kCLAuthorizationStatusAuthorizedAlways;
        }
        return ([CLLocationManager authorizationStatus] >= status);
    }
    return NO;
}


-(void)initLocationManager
{
    if (_locationManager ||
        ![[self class] isLocationEnable]) {
        return;
    }
    
    // 网络初始化
    _fetcher = [GTMHTTPFetcher new];
    [_fetcher setServicePriority:1];
    
    
    // 定位初始化
    _locationManager = [CLLocationManager new];
    _locationManager.delegate = self;   // 接收事件的实例
    // 设置距离过滤器，超过次距离就更新一次位置（缺省是不指定）
    _locationManager.distanceFilter = 30000;
    //定位精度3公里
    _locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    //    _locationManager.purpose = @"定位服务：提供城市天气定位服务。";
    
    [self startLocation];
}


// 定位城市发生改变
-(void)locationCityChanged:(SurfLocationHandle)handler
{
     _localHandle = handler;
}

/**
 *  开始定位
 */
-(void)startLocation
{
    if ([[[UIDevice currentDevice] systemVersion] isVersionHigherThanOrEqualsTo:@"8.0"] ) {
        [_locationManager requestWhenInUseAuthorization];
    }
    [_locationManager startUpdatingLocation];
}
-(void)stopLocation
{
    if (_locationManager) {
        [_locationManager stopUpdatingLocation];
    }
}

#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    // 取得经纬度
    CLLocationCoordinate2D coordinate = newLocation.coordinate;
    CLLocationDegrees latitude = coordinate.latitude;   // 纬度
    CLLocationDegrees longitude = coordinate.longitude; // 经度


//    经度范围：73°33′E至135°05′E
//    纬度范围：3°51′N至53°33′N
//
//    最北端在黑龙江省漠河乌苏里浅滩黑龙江主航道中心线上（53°33′47〃N）。
//    最南端在南海的南沙群岛中的立地暗沙（3°51′N，112°16′E）（在曾母暗沙西南约15海里）。
//    最东端在黑龙江省黑瞎子岛(48°27′N，135°05′E）。
//                 最西端在新疆帕米尔高原，约在中、塔、吉三国边界交点西南方约25公里处，那里有一座海拔5000米以上的雪峰。（39°15′N、73°33′E）。

//    最东端 东经135度2分30秒 黑龙江和乌苏里江交汇处
//    最西端 东经73度40分 帕米尔高原乌兹别里山口（乌恰县）
//    最南端 北纬3度52分 南沙群岛曾母暗沙
//    最北端 北纬53度33分 漠河以北黑龙江主航道（漠河县）2日本朝鲜韩国
//  我就直接取个整数了，免的麻烦，超出中国范围直接是中国北京(北京市区坐标为:北纬39.9”,东经116. 3”。)
    if(longitude < 72.f || longitude > 136.f ||
       latitude < 3.0f || latitude > 54.f)
    {
        longitude = BJLongitude;
        latitude = BJLatitude;
    }
    
    [self requestLocationCity:longitude latitude:latitude];
    
    // 停止定位
    [self performSelectorOnMainThread:@selector(stopLocation) withObject:nil waitUntilDone:NO];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)erro
{
    [self requestLocationCity:BJLongitude latitude:BJLatitude];
}

-(void)requestLocationCity:(double) longitude
                  latitude:(double) latitude
{
    if ([_fetcher isFetching]) {
        [_fetcher stopFetching];
    }
    
    NSURLRequest *request =
    [SurfRequestGenerator updateWeatherRequestByGPS:longitude
                                           latitude:latitude
                                         serverTime:nil];
    // 请求天气信息
    _fetcher.mutableRequest = [request mutableCopy];
    __block GTMHTTPFetcher *fetcher_block = _fetcher;
    [_fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error)
     {
         if (!error) {
             NSStringEncoding encoding = [[[fetcher_block response] textEncodingName] convertToStringEncoding];
             NSString* body = [[NSString alloc] initWithData:data
                                                    encoding:encoding];
             Class classType = [UpdateWeatherResponse class];
             UpdateWeatherResponse *resp =
             [EzJsonParser deserializeFromJson:body AsType:classType];
             
             if (resp && resp.cityId && ![resp.cityId isEmptyOrBlank]) {
                 _locationCityWeather = [[WeatherInfo alloc] initWithWeatherInfo:resp];
                 _cityName = resp.cityName;
             }
         }
         
         if (_localHandle) {
             _localHandle(_locationCityWeather);
             _localHandle = nil;
         }
     }];
}

@end



#pragma mark 天气管理器


@implementation WeatherManager
@synthesize weatherInfo = _curWeatherInfo;

+(WeatherManager*)sharedInstance{
    static WeatherManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [WeatherManager new];
    });   
    return instance;
}

- (id)init
{
    if (self = [super init]) {
        _curWeatherInfo = [WeatherInfo new];
        _weatherUpdateObservers = [WeakRefArray new];
        _cityIdChangedDelegates = [WeakRefArray new];
        
        // 设置城市
        NSString *cityN = [AppSettings stringForKey:StringKey_UserSelectCityName];      // 用户选择的城市
        if (!cityN || [cityN isEmptyOrBlank]) {
            // 用户没有选择，就使用默认城市
            _curWeatherInfo.cityName =
            [AppSettings stringForKey:StringKey_DefalutCityName];             _curWeatherInfo.cityId = [self defaultCityId];
        }
        else {
            _curWeatherInfo.cityName = cityN;
            _curWeatherInfo.cityId = [self userSelectCityId];
        }
    }
    return self;
}

// 更新天气信息
-(void)updateWeatherInfo
{
    if ([self isUserSelectCity]) {  // 用户选择城市
        // 使用用户选择的城市Id，去刷新天气信息      
        [self updateWeatherWithCity:[self userSelectCityId]];
    }
    else if([SurfLocationHelper isLocationEnable]){ // 定位
  
        // 定位城市天气
        [self weatherWillUpdate]; // 天气将要更新
        [self locationCityWeather:^(WeatherInfo *newWeather)
        {
            if (newWeather){
                [self weatherUpdated:YES weather:newWeather];
                [self notifyWeatherCityIDChanged:newWeather];
            }
            else {
                [self weatherUpdated:NO weather:nil];
            }
        }];
    }
    else{ // 使用默认城市去定位
        [self updateWeatherWithCity:[self defaultCityId]];
    }
}


#pragma mark private method 私有函数
// 通过城市ID更新天气
- (void)updateWeatherWithCity:(NSString *)cityId
{
    if (!cityId || [cityId isEmptyOrBlank]) {
        return;
    }
    
    [self weatherWillUpdate];
    NSURLRequest *request = nil;
    request = [SurfRequestGenerator updateWeatherRequestByCityID:cityId serverTime:nil];
    [self requestWeatherHTTP:request
                     handler:^(WeatherInfo *weather)
    {
        if (weather && weather.cityName.length > 0) {
            [self weatherUpdated:YES weather:weather];
            [self notifyWeatherCityIDChanged:weather];
        }
        else {
            [self weatherUpdated:NO weather:nil];
        }
    }];
}

// 使用经纬度来更新城市天气
-(void)updateWeatherWithGPS:(double)lon
                   latitude:(double)lat
                  completed:(void(^)(WeatherInfo* weather))completed
{
    NSURLRequest *request = nil;
    request = [SurfRequestGenerator updateWeatherRequestByGPS:lon
                                                     latitude:lat
                                                   serverTime:nil];
    [self requestWeatherHTTP:request
                     handler:completed];
}

// 用户是否选择城市
-(BOOL)isUserSelectCity{
    if ([self userSelectCityId].length > 0) {
        return YES;
    }
    return NO;
}

-(NSString *)userSelectCityId{
    return [AppSettings stringForKey:StringKey_UserSelectCityId];
}
- (NSString *)defaultCityId{
    return [AppSettings stringForKey:StringKey_DefaultCityId];
}

// 天气将要刷新
-(void)weatherWillUpdate{
    NSUInteger count = _weatherUpdateObservers.count;
    for (NSInteger i = 0; i < count; ++i) {
        id<WeatherUpdateDelegate> del = [_weatherUpdateObservers objectAtIndex:i];
        [del weatherWillUpdate];
    }
}

 // 天气发生更新
-(void)weatherUpdated:(BOOL)succeeded weather:(WeatherInfo*)info
{
    NSUInteger count = _weatherUpdateObservers.count;
    for (NSInteger i = 0; i < count; ++i) {
        id<WeatherUpdateDelegate> del = [_weatherUpdateObservers objectAtIndex:i];
        [del handleWeatherInfoChanged:succeeded weatherInfo:info];
    }
}


- (void)setCityInfoAndUpdateWeather:(NSString*)cityName
                             cityId:(NSString*)cityId
{
    if (!cityName || [cityName isEmptyOrBlank] ||
        !cityId || [cityId isEmptyOrBlank]) {
        return;
    }
    
    if (![_curWeatherInfo.cityName isEqual:cityName]) {
        [AppSettings setString:cityName forKey:StringKey_UserSelectCityName];
        [AppSettings setString:cityId forKey:StringKey_UserSelectCityId];
        [self updateWeatherInfo];
    }
}


- (void)addWeatherUpdatedNotify:(id<WeatherUpdateDelegate>)observer
{
    if (observer == nil || [_weatherUpdateObservers containsObject:observer])
        return;
    [_weatherUpdateObservers addObject:observer];
}

-(BOOL)isSuportLocationServices
{
    return [SurfLocationHelper isLocationEnable];
}


// 定位城市天气
-(void)locationCityWeather:(void (^)(WeatherInfo *newWeather))handler
{
    // 判断是否授权定位
    if (![SurfLocationHelper isLocationEnable]) {
        if (handler) {  handler(nil);    }
        return;
    }
    
    SurfLocationHelper *localHelper =
    [SurfLocationHelper sharedInstance];
    if (localHelper.locationCityWeather) {
        handler(localHelper.locationCityWeather);
    }
    else {
        [localHelper locationCityChanged:^(WeatherInfo *locationWeather) {
            handler(locationWeather);
        }];
        [localHelper startLocation];
    }
}


// 添加/删除cityID改变委托
- (void)addCityIdChangeDelegate:(id<CityIdChangeDelegate>)delegate
{
    if (delegate != nil && ![_cityIdChangedDelegates containsObject:delegate])
        [_cityIdChangedDelegates addObject:delegate];
}





#pragma mark 2015.1.22 修改
// 天气请求
- (void)requestWeatherHTTP:(NSURLRequest *)request
                   handler:(void(^)(WeatherInfo* weather))handler
{
    // 请求天气信息
    GTMHTTPFetcher *fetcher = [GTMHTTPFetcher new];
    fetcher.mutableRequest = [request mutableCopy];
    fetcher.mutableRequest.timeoutInterval = 15.f;
    [fetcher setServicePriority:1];
    __block GTMHTTPFetcher *fetcher_block = fetcher;
    [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error)
    {
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [[NSURLCache sharedURLCache] setDiskCapacity:0];
        [[NSURLCache sharedURLCache] setMemoryCapacity:0];
        WeatherInfo *weather = nil;
        if (!error)
        {
            NSStringEncoding encoding = [[[fetcher_block response] textEncodingName] convertToStringEncoding];
            NSString* body = [[NSString alloc] initWithData:data
                                                   encoding:encoding];
            Class classType = [UpdateWeatherResponse class];
            UpdateWeatherResponse *resp =
            [EzJsonParser deserializeFromJson:body AsType:classType];
            
            if (resp && resp.cityId && ![resp.cityId isEmptyOrBlank]) {
                weather = [[WeatherInfo alloc] initWithWeatherInfo:resp];
            }
        }
        
        if(handler)
            handler(weather);
    }];
}

// 通知天气城市ID发生改变
-(void)notifyWeatherCityIDChanged:(WeatherInfo*)newWeather
{
    NSString *oldCityId = _curWeatherInfo.cityId;
    _curWeatherInfo = newWeather;
    if (oldCityId && [oldCityId isEqualToString:newWeather.cityId]) {
        return;
    }
    
    for (NSUInteger i=0; i<_cityIdChangedDelegates.count; ++i) {
        id<CityIdChangeDelegate> del = [_cityIdChangedDelegates objectAtIndex:i];
        [del NotifyCityIdChanged:newWeather.cityId];
    }
}
@end
