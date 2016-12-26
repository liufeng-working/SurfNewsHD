//
//  PhoneSelectCityController.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-5-22.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhoneSelectCityController.h"
#import "WeatherManager.h"
#import "SearchBoxControl.h"
#import "SearchBoxView.h"
#import "PhoneSearchCityView.h"
#import "CGContextUtil.h"
#import "UIColor+extend.h"
#import "TouchReader.h"
#import "UIView+NightMode.h"
#import "JSONKit.h"

////////////////////////////////////////////////////////////////////////////
// LocationCityCell
////////////////////////////////////////////////////////////////////////////
typedef enum {
    LocationCellStatusNone,
    LocationCellStatusLoading,
    LocationCellStatusNotFindCity,
    LocationCellStatusServiceDisable,
    
} LocationCellStatus;
@interface SNLocationCityCell : UITableViewCell{
    UIActivityIndicatorView *_activityView; // 风火轮
    NSUInteger _status;
    CGRect _locationCityRect;               // 定位城市的绘制区域
    BOOL _isKeyDownLocationCity;            // 是否点击定位的城市
    WeatherInfo *_locationCityInfo;
    BOOL _isKeydownCell;                    // 定位失败触摸按下的状态
    CGRect _touchDownRect;                  // 定位失败的背景区域
}

-(void)reLoadRequestLocationCity; // 重新请求定位城市

@end


@implementation SNLocationCityCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.contentView addSubview:_activityView];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self reLoadRequestLocationCity];   // 重新请求定位城市天气
        
        
        // 手势事件
        UILongPressGestureRecognizer *gesture;
        gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(gestureEvent:)];
//        gesture.delegate = self;
        gesture.minimumPressDuration = 0.f;
        [self addGestureRecognizer:gesture];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    CGFloat w = CGRectGetWidth(frame);
    CGFloat h = CGRectGetHeight(frame);
    CGFloat aW = CGRectGetWidth(_activityView.bounds);
    CGFloat aH = CGRectGetHeight(_activityView.bounds);
    _activityView.frame = CGRectMake((w-aW)*0.5f, (h-aH)*0.5f, aW, aH);
    

    CGFloat cityRectHeigth = 26.f;
    _locationCityRect = CGRectMake(10, (h-cityRectHeigth) * 0.5, 80, cityRectHeigth);
    _touchDownRect = CGRectInset(self.bounds, 10, 10);
}

// 重新请求定位城市
-(void)reLoadRequestLocationCity
{
    [_activityView startAnimating];
    _status = LocationCellStatusLoading; 

    // 查看App 是否支持定位服务
    if ([[WeatherManager sharedInstance] isSuportLocationServices]) {
        // 请求GPS定位
        
        [[WeatherManager sharedInstance] locationCityWeather:^(WeatherInfo *newWeather)
        {
            _status = LocationCellStatusNotFindCity;
            if (newWeather) {
                _locationCityInfo = newWeather;
                _status = LocationCellStatusNone;
            }
            [_activityView stopAnimating];
            [self setNeedsDisplay];
        }];
    }
    else{      
        _status = LocationCellStatusServiceDisable;
        [_activityView stopAnimating];        
    }
    
    [self setNeedsDisplay];
}



- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    CGContextClearRect(context, rect);

    UIFont *strFont = [UIFont systemFontOfSize:15.f];
    if (_status > 0) {        
        NSString *titleStr;
        if (_status == LocationCellStatusLoading) {
            titleStr = @"正在定位. . .";
        }
        else if (_status == LocationCellStatusNotFindCity){
            titleStr = @"定位失败，点击重新获取地理位置";
            
            // 按钮背景图片
            if (_isKeydownCell) {
                CGContextSetFillColorWithColor(context, [UIColor colorWithHexValue:0xFFad2f2f].CGColor);
                CGContextFillRect(context, _touchDownRect);
            }
        }
        else if (_status == LocationCellStatusServiceDisable){
            titleStr = @"无法定位，定位服务已被关闭";
        }
        
        // 显示提示文字      
        if (titleStr.length > 0) {            
            UIColor *strColor = [UIColor colorWithHexValue:0xFF999292];
            CGRect strRect = CGRectZero;
            strRect.size = SN_TEXTSIZE(titleStr, strFont);
            strRect.origin.x = (CGRectGetWidth(self.bounds) - CGRectGetWidth(strRect)) * 0.5;
            strRect.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(strRect)) * 0.5;
            [titleStr surfDrawString:strRect
                            withFont:strFont
                           withColor:strColor
                       lineBreakMode:NSLineBreakByWordWrapping
                           alignment:NSTextAlignmentLeft];
        }
    }
    else {
        if (!_locationCityInfo) {
            return;
        }
        
        
        CGColorRef cityBgColor, cityHLColor;
        CGColorRef cityMargeColor = [UIColor colorWithHexValue:0xffBFBEC1].CGColor;
        UIColor *strColor = [UIColor colorWithHexValue:0xFF999292];
        if ([ThemeMgr sharedInstance].isNightmode) {
            cityBgColor = [UIColor colorWithHexValue:0xff1b1b1c].CGColor;
            cityHLColor = [UIColor colorWithHexValue:0xffAD2F2F].CGColor;
        }
        else{
            cityBgColor = [UIColor colorWithHexValue:0xffFFFFFF].CGColor;
            cityHLColor = [UIColor colorWithHexValue:0xffAD2F2F].CGColor;
        }
        
        
        // button 圆角矩形路径
        CGPathRef pathRef = [CGContextUtil RoundedRectPathRef:_locationCityRect radius:2];

        // Button 背景矩形
        if (_isKeyDownLocationCity) {
            CGContextSetFillColorWithColor(context, cityHLColor);
        }
        else{
            CGContextSetFillColorWithColor(context, cityBgColor);
        }
        CGContextAddPath(context, pathRef);
        CGContextFillPath(context);
        
        
        
        // Button 边框
        CGContextSetStrokeColorWithColor(context, cityMargeColor); // 圆角边距矩形颜色
        CGContextAddPath(context, pathRef);
        CGContextStrokePath(context);
      
        
        
        // 绘制城市名
        CGRect textRect = _locationCityRect;
        textRect.origin.y += (textRect.size.height-strFont.lineHeight) * 0.5f;
        textRect.size.height = strFont.lineHeight;        
        [_locationCityInfo.cityName surfDrawString:textRect withFont:strFont withColor:strColor lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
        
    }
    
    
    UIGraphicsPopContext();
}

- (void)gestureEvent:(UIGestureRecognizer*)gestureRecognizer{    
    CGPoint touchPoint = [gestureRecognizer locationInView:self];
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:            
            if (_status == LocationCellStatusNotFindCity) {
                _isKeydownCell = YES;
                [self setNeedsDisplay]; // 点击效果;       
            }
            else if(_status == LocationCellStatusNone){
                if(_locationCityInfo && !CGRectIsEmpty(_locationCityRect)){
                    if (CGRectContainsPoint(_locationCityRect, touchPoint)) {
                        // 城市点击效果。
                        _isKeyDownLocationCity = YES;
                        [self setNeedsDisplay]; // 点击效果
                    }
                }
            }
            break;
        case UIGestureRecognizerStateEnded:
            if (_status == LocationCellStatusNotFindCity) {
                if (CGRectContainsPoint(_touchDownRect, touchPoint)) {
                    _isKeydownCell = NO;
                    [self reLoadRequestLocationCity];
                    [self setNeedsDisplay];
                }
            }
            else if(_status == LocationCellStatusNone)
            {
                // 定位城市 _locationCityInfo在定位的时候就已经获取天气了.
                if (_locationCityInfo && !CGRectIsEmpty(_locationCityRect) &&
                    CGRectContainsPoint(_locationCityRect, touchPoint)) {
                    WeatherManager *wm = [WeatherManager sharedInstance];
                    [wm setCityInfoAndUpdateWeather:_locationCityInfo.cityName
                                             cityId:_locationCityInfo.cityId];
                    _isKeyDownLocationCity = NO;
                    [self setNeedsDisplay];
                    
                    // 触发点击事件
                    Class classType = [PhoneSelectCityController class];
                    PhoneSelectCityController *controller = [self findUserObject:classType];
                    if ([controller isKindOfClass:classType]) {
                        [controller didBack];
                    }
                }
            }
            break;
        case UIGestureRecognizerStateChanged:
             if (_status == LocationCellStatusNotFindCity) {
                 if (CGRectContainsPoint(_touchDownRect, touchPoint)) {
                     if (!_isKeydownCell) {
                         _isKeydownCell = YES;
                         [self setNeedsDisplay];
                     }
                 }
                 else{
                     if (_isKeydownCell) {
                         _isKeydownCell = NO;
                         [self setNeedsDisplay];
                     }
                 }
             }
             else if (_status == LocationCellStatusNone){                 
                 if (CGRectContainsPoint(_locationCityRect, touchPoint)) {
                     if (!_isKeyDownLocationCity) {
                         _isKeyDownLocationCity = YES;
                         [self setNeedsDisplay];
                     }
                 }
                 else{
                     if (_isKeyDownLocationCity) {
                         _isKeyDownLocationCity = NO;
                         [self setNeedsDisplay];
                     }
                 }
             }
            break;
        default:
            _isKeydownCell = NO;
            _isKeyDownLocationCity = NO;
            [self setNeedsDisplay];
            break;
    }
}
@end


////////////////////////////////////////////////////////////////////////////
// PhoneSelectCityController
////////////////////////////////////////////////////////////////////////////
@implementation PhoneSelectCityController {
    TouchReader *_touchReader;
}

- (id)init {
    self = [super init];
    if (self) {
        cityArray = [NSMutableArray new];
        groupCityArray = [NSMutableArray new];
        letterArray = [NSMutableArray new];
        
        self.titleState = PhoneSurfControllerStateTop;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"城市天气"];
    
    
    // 搜索控件
    CGFloat searchMaxH = 50.f;
    CGFloat searchHeight = 30.f;
    CGFloat searchX = 10.f;
    CGFloat searchY = [self StateBarHeight] + (searchMaxH-searchHeight) *0.5f;
    CGFloat searchWidth = 280.f;
    CGRect searchRect = CGRectMake(searchX, searchY, searchWidth, searchHeight);
    _searchBoxControl = [[SearchBoxControl alloc] initWithFrame:searchRect tipString:@"搜索城市"];
    [_searchBoxControl addTarget:self action:@selector(showSearchCityView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_searchBoxControl];
    
    // 初始化天气列表
    CGRect tableRect = CGRectMake(.0f,
                                  [self StateBarHeight] + searchMaxH,
                                  kContentWidth,
                                  kContentHeight - searchMaxH - [self StateBarHeight]-3);
    tableView = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.backgroundView = nil;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];


    
    // 解析城市XML文件
    [self parseCityXml];

}


- (void)didBack
{
    [self dismissControllerAnimated:PresentAnimatedStateFromRight];
}

//解析xml
- (void)parseCityXml
{
    [cityArray removeAllObjects];
    NSString * cityPath =[[NSBundle mainBundle] pathForResource:@"Citys" ofType:@"xml"];
    NSData *citysData = [NSData dataWithContentsOfFile:cityPath];
    
    // 解析xml文件内容
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:citysData];
    [parser setDelegate:self];
    [parser parse];
}

//按拼音分组城市
- (void)groupCityArray
{
    float maxWidth = kContentWidth - 20.f;
    [groupCityArray removeAllObjects];
    [letterArray removeAllObjects];
    
    // 获取热门城市
    NSString *hotCityFormat = @"(isHot == '1')";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:hotCityFormat];
    NSArray *hotCityArray = [cityArray filteredArrayUsingPredicate:predicate];
    SelectCityCellData *cellData = [[SelectCityCellData alloc] initWithCities:hotCityArray showWidth:maxWidth];
    [groupCityArray addObject:cellData];
    
    // 根据firstLetter字段来获取拼音队列
    NSString *groupPath = @"@distinctUnionOfObjects.firstLetter";
    [letterArray addObjectsFromArray:[cityArray valueForKeyPath:groupPath]];
    
    
    for (NSString *groupValue in letterArray) {
        NSString *format = [NSString stringWithFormat:@"(%@ == '%@')", @"firstLetter", groupValue];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:format];
        NSArray *array = [cityArray filteredArrayUsingPredicate:predicate];
        NSSortDescriptor* enDescriptor = [[NSSortDescriptor alloc]
                                          initWithKey:@"en"
                                          ascending:YES];
        NSArray* sortDescriptors = [NSArray arrayWithObject:enDescriptor];
        array = [array sortedArrayUsingDescriptors:sortDescriptors];        
        cellData = [[SelectCityCellData alloc] initWithCities:array showWidth:maxWidth];
        [groupCityArray addObject:cellData];
    }
    [letterArray insertObject:@"#" atIndex:0];
}


#pragma mark NSXMLParserDelegate method
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"city"]) {
        NSString *string = [attributeDict JSONString];
        CityInfo *city = [EzJsonParser deserializeFromJson:string AsType:[CityInfo class]];
        city.firstLetter = [city.en substringToIndex:1];
        [cityArray addObject:city];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    //解析错误
}

// xml解析完成
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    [self groupCityArray];  //按拼音分组城市
    [tableView reloadData];
}

-(void)nightModeChanged:(BOOL)night{
    
    [super nightModeChanged:night];

}

#pragma mark -  UITableViewDataSource
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tView
{
    CGFloat barWidth = 20.f;
    CGRect rect = tableView.frame;
    rect.origin.x = rect.size.width-barWidth - 5.f;
    rect.origin.y = [self StateBarHeight] + 5.f;
    rect.size.width = barWidth;
    rect.size.height = kContentHeight - rect.origin.y;
    
    
    // 放大镜控件
    TouchReader *tr = [[TouchReader alloc] initWithFrame:rect];
    _touchReader = tr;
    [self.view addSubview:tr];
    
    rect.origin = CGPointZero;
    CMIndexBar *customIndex = [[CMIndexBar alloc] initWithFrame:rect];
    customIndex.textFontSize = 12.f;
    [customIndex setIndexes:letterArray];
    customIndex.delegate = self;
    [tr addSubview:customIndex];
    
    
    
    if ([ThemeMgr sharedInstance].isNightmode) {
        customIndex.textColor = [UIColor whiteColor];
        customIndex.backgroundColor = [UIColor colorWithHexValue:0x222223];
    }
    else{
        customIndex.textColor = [UIColor colorWithHexValue:0xFF34393D];
        customIndex.backgroundColor = [UIColor colorWithHexValue:0xCCF3F1F1];
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [groupCityArray count] + 1; // 1 是定位城市的Section
}

- (NSInteger)tableView:(UITableView *)tView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"定位到的城市";
    }
    else if (section == 1) {
        return @"热门城市";
    }
    
    //第一个肯定不会为空的
    return [letterArray objectAtIndex:section-1];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 60.f;
    }
    
    SelectCityCellData *cellData = [groupCityArray objectAtIndex:indexPath.section-1];
    return [cellData CellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        NSString * gpsLocationIdentifier = @"locationCell"; 
        cell = [tView dequeueReusableCellWithIdentifier:gpsLocationIdentifier];
        if (!cell) {
            cell = [[SNLocationCityCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:gpsLocationIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
        }
    }
    else{
        
        static NSString *identifier = @"cell"; 
        cell = [tView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[PhoneSelectCityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            [(PhoneSelectCityCell*)cell setSelectCityDelegate:self];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
        }
        
        if (indexPath.section - 1 < [groupCityArray count]) {
            [(PhoneSelectCityCell*)cell reloadCities:[groupCityArray objectAtIndex:indexPath.section - 1]];
        }
    }
    return cell;
}


#pragma mark -  UITableViewDelegate methods
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    for (id cell in tableView.visibleCells) {
        if ([cell isKindOfClass:[PhoneSelectCityCell class]]) {
            [cell recoverCellState];
        }
    }
}
- (UIView *)tableView:(UITableView *)tView viewForHeaderInSection:(NSInteger)section
{
    UILabel *title = [UILabel new];
    title.text = [NSString stringWithFormat:@"   %@", [self tableView:tableView titleForHeaderInSection:section]];
    title.font = [UIFont systemFontOfSize:15.0f];
   
    if ([ThemeMgr sharedInstance].isNightmode) {
        title.backgroundColor = [UIColor colorWithHexValue:0xFF222223];
        title.textColor = [UIColor whiteColor];
    }
    else{
        title.backgroundColor = [UIColor colorWithHexValue:0xFFF3F1F1];
        title.textColor =[UIColor colorWithHexValue:0xFF34393D];
    }
    return title;
}

- (void)indexSelectionDidChange:(CMIndexBar *)IndexBar :(NSInteger)index :(NSString*)title
{
    NSIndexPath *indexPath;
    if (index == 1) {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    else{
        indexPath = [NSIndexPath indexPathForRow:0 inSection:index];
    }
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

#pragma mark SelectCityDelegate
// 选择城市
-(void)selectCity:(CityInfo *)cityInfo
{
    if (!cityInfo)
        return;
    
    WeatherManager *weatherMgr = [WeatherManager sharedInstance];
    if (![cityInfo.name isEqualToString:(weatherMgr.weatherInfo.cityName)])
    {
        [weatherMgr setCityInfoAndUpdateWeather:cityInfo.name
                                         cityId:cityInfo.cityId];
    }
    [self didBack];
}



// 搜索城市
- (void)showSearchCityView {
    if (_searchView) return;
    
    CGRect rect = CGRectMake(0, 0, kContentWidth, kContentHeight);
    _searchView = [[PhoneSearchCityView alloc] initWithFrame:rect];
    _searchView.dateSource = cityArray;
    [self.view addSubview:_searchView];
}
- (void)hiderSearchCityView {
    if (_searchView) {
        _searchView.hidden = YES;
        [_searchView removeFromSuperview];
        _searchView = nil;
    }
}

//- (void)nightModeChanged:(BOOL)night{
//    [super nightModeChanged:night];
//}


@end
