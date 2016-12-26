//
//  StockMarketThreadView.m
//  SurfNewsHD
//
//  Created by jsg on 14-4-29.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "StockMarketThreadView.h"
#import "stockMarketInfoResponse.h"
#import "stockMarketInfoManager.h"
#import "DispatchUtil.h"


#define viewWidthPX 95.0f
#define viewHeightPx 60.0f

#define spaceX_Px 5.0f
#define spaceY_Px 7.0f
#define distance 4.0f

#define viewWidthBannerPX 101.0f
#define viewHeightBannerPx 20.0f

#define viewWidthLabelPX 95.0f
#define viewHeightLabelPx 23.0f

#define viewWidthTimePX 95.0f
#define viewHeightTimePx 12.5f

@implementation StockMarketThreadView

@synthesize array;
@synthesize _SeparatorLine;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _RectBanner = CGRectMake(0, 0, viewWidthBannerPX, viewHeightBannerPx);
        _ShanghaiBanner = [[UIImageView alloc]initWithFrame:_RectBanner];
        _ShenZhenBanner = [[UIImageView alloc]initWithFrame:_RectBanner];
        _StartupBanner = [[UIImageView alloc]initWithFrame:_RectBanner];
        
        CGRect Rect= CGRectMake(spaceX_Px, spaceY_Px, viewWidthBannerPX , viewHeightPx);
        _ShanghaiStock = [[UIControl alloc] initWithFrame:Rect];
        _ShanghaiStock.tag = stockTagShangHai;
        [_ShanghaiStock addTarget:self action:@selector(addWebUrl:) forControlEvents:UIControlEventTouchUpInside];
        _ShanghaiStock.backgroundColor = [UIColor colorWithHexString:@"EDEDED"];
        [self addLabel:Rect position:0];
//        _upOrdownSH = [[UIImageView alloc] initWithFrame:CGRectMake(82, 6, 12, 6)];
//        [_ShanghaiBanner addSubview:_upOrdownSH];
        [_ShanghaiStock addSubview:_ShanghaiBanner];
        [self addSubview:_ShanghaiStock];
        
        CGRect Rect1= CGRectMake(spaceX_Px+viewWidthBannerPX+distance, spaceY_Px, viewWidthBannerPX, viewHeightPx);
        _ShenZhenStock = [[UIControl alloc] initWithFrame:Rect1];
        _ShenZhenStock.tag = stockTagShenZhen;
        [_ShenZhenStock addTarget:self action:@selector(addWebUrl:) forControlEvents:UIControlEventTouchUpInside];
        _ShenZhenStock.backgroundColor = [UIColor colorWithHexString:@"EDEDED"];
        [self addLabel:Rect1 position:1];
//        _upOrdownSZ = [[UIImageView alloc] initWithFrame:CGRectMake(82, 6, 12, 6)];
//        [_ShenZhenBanner addSubview:_upOrdownSZ];
        [_ShenZhenStock addSubview:_ShenZhenBanner];
        [self addSubview:_ShenZhenStock];
        
        CGRect Rect2= CGRectMake(spaceX_Px + viewWidthBannerPX*2 + distance*2, spaceY_Px, viewWidthBannerPX,viewHeightPx);
        _StartupStock = [[UIControl alloc] initWithFrame:Rect2];
        _StartupStock.tag = stockTagStartup;
        [_StartupStock addTarget:self action:@selector(addWebUrl:) forControlEvents:UIControlEventTouchUpInside];
        _StartupStock.backgroundColor = [UIColor colorWithHexString:@"EDEDED"];
        [self addLabel:Rect2 position:2];
//        _upOrdownSS = [[UIImageView alloc] initWithFrame:CGRectMake(82, 6, 12, 6)];
//        [_StartupBanner addSubview:_upOrdownSS];
        [_StartupStock addSubview:_StartupBanner];
        [self addSubview:_StartupStock];
        
        CGRect RectTime = CGRectMake(spaceX_Px + viewWidthBannerPX*2 + distance*2 - 8.0f, spaceY_Px + viewHeightPx + 3.0f, viewWidthTimePX+12.0f, viewHeightTimePx-3.0f);
        timeLabel = [[UILabel alloc] initWithFrame:RectTime];
        [timeLabel setBackgroundColor:[UIColor colorWithHexString:@"D1D1D1"]];
        [timeLabel setText:[self GetLocalTime]];
        timeLabel.userInteractionEnabled = NO;
        timeLabel.font = [UIFont fontWithName:@"Helvetica" size:8.8f];
        [timeLabel setTextColor:[UIColor whiteColor]];
        [self addSubview:timeLabel];
        
        
        
        CGRect SeparatorLine = CGRectMake(0.0f, spaceY_Px + viewHeightPx + 3.0f + viewHeightTimePx, frame.size.width, 1.0f);
        _SeparatorLine = [[UIView alloc] initWithFrame:SeparatorLine];
        _SeparatorLine.userInteractionEnabled = NO;
        [_SeparatorLine setBackgroundColor:[UIColor colorWithHexValue:0xffdcdbdb]];
        [self addSubview:_SeparatorLine];
        
        [self requestStock];
    }
    return self;
}

- (void)initWithModel:(NSMutableArray*)arr
{
    array = arr;
    
    for (stockMarketInfo *stock in array) {
        if ([stock.index intValue] == 0) {
            [_nameSH setText:stock.name];
            [_newestSH setText:stock.newest];
            [_upsSH setText:stock.ups];
            [_rangeSH setText:stock.range];

            [self reloadUpsOrRange:0 direction:[stock.range floatValue]];
        }
        else if([stock.index intValue] == 1)
        {
            [_nameSZ setText:stock.name];
            [_newestSZ setText:stock.newest];
            [_upsSZ setText:stock.ups];
            [_rangeSZ setText:stock.range];
            [self reloadUpsOrRange:1 direction:[stock.range floatValue]];
        }
        else if ([stock.index intValue] == 2) {
            [_nameSS setText:stock.name];
            [_newestSS setText:stock.newest];
            [_upsSS setText:stock.ups];
            [_rangeSS setText:stock.range];
            [self reloadUpsOrRange:2 direction:[stock.range floatValue]];
        }
    }
}

// 请求股票数据
-(void)requestStock
{
    stockMarketInfoManager *stockMgr = [stockMarketInfoManager sharedInstance];
    [stockMgr refreshStockMarketInfo:^(BOOL succeeded, NSArray *stockList) {
        if (succeeded && [stockList count] > 0) {
            NSMutableArray *stocks = [stockList mutableCopy];
            [self initWithModel:stocks];
        }
        else
        {
            if (++_httpRequestCount < 3) {
                [DispatchUtil dispatch:^{
                    [self requestStock];
                } after:2];
            }
        }
    }];
}

- (void)addLabel:(CGRect)rect position:(NSInteger)place{
    CGFloat widthHeight = viewWidthLabelPX;
    CGFloat labelHeight = viewHeightLabelPx;

    CGRect nameRect = CGRectMake(5.0f, 0, widthHeight, labelHeight);
    CGRect newestRect = CGRectMake(22.0f, labelHeight-4.5f, widthHeight, labelHeight);
    CGRect upsRect = CGRectMake(7.0f, labelHeight*2-11.0f, widthHeight-43.0f, labelHeight);
    CGRect rangeRect = CGRectMake(widthHeight/2 + 11.0f, labelHeight*2-11.0f, widthHeight/2, labelHeight);
    
    switch (place) {
        case 0:
            _nameSH = [[UILabel alloc] initWithFrame:nameRect];
            _nameSH.center = _ShanghaiBanner.center;
            _nameSH.backgroundColor = [UIColor clearColor];
            [_nameSH setTextColor:[UIColor whiteColor]];
            _nameSH.textAlignment = NSTextAlignmentCenter;
            _nameSH.font = [UIFont fontWithName:@"Helvetica" size:13.0f];
            _newestSH = [[UILabel alloc] initWithFrame:newestRect];
            _newestSH.font = [UIFont fontWithName:@"Helvetica" size:14.0f];
            _newestSH.backgroundColor = [UIColor clearColor];

            
            _upsSH = [[UILabel alloc] initWithFrame:upsRect];
            _upsSH.font = [UIFont fontWithName:@"Helvetica" size:12.0f];
            _upsSH.backgroundColor = [UIColor clearColor];

            
            _rangeSH = [[UILabel alloc] initWithFrame:rangeRect];
            _rangeSH.font = [UIFont fontWithName:@"Helvetica" size:12.0f];
            _rangeSH.backgroundColor = [UIColor clearColor];

            break;
        case 1:
            _nameSZ = [[UILabel alloc] initWithFrame:nameRect];
            _nameSZ.center = _ShenZhenBanner.center;
            _nameSZ.backgroundColor = [UIColor clearColor];
            _nameSZ.font = [UIFont fontWithName:@"Helvetica" size:13.0f];
            [_nameSZ setTextColor:[UIColor whiteColor]];
            _nameSZ.textAlignment = NSTextAlignmentCenter;
            _newestSZ = [[UILabel alloc] initWithFrame:newestRect];
            _newestSZ.font = [UIFont fontWithName:@"Helvetica" size:14.0f];
            _newestSZ.backgroundColor = [UIColor clearColor];

            
            _upsSZ = [[UILabel alloc] initWithFrame:upsRect];
            _upsSZ.font = [UIFont fontWithName:@"Helvetica" size:12.0f];
            _upsSZ.backgroundColor = [UIColor clearColor];

            _rangeSZ = [[UILabel alloc] initWithFrame:rangeRect];
            _rangeSZ.font = [UIFont fontWithName:@"Helvetica" size:12.0f];
            _rangeSZ.backgroundColor = [UIColor clearColor];
            
            break;
        case 2:
            _nameSS = [[UILabel alloc] initWithFrame:nameRect];
            _nameSS.center = _StartupBanner.center;
            _nameSS.backgroundColor = [UIColor clearColor];
            _nameSS.font = [UIFont fontWithName:@"Helvetica" size:13.0f];
            [_nameSS setTextColor:[UIColor whiteColor]];
            _nameSS.textAlignment = NSTextAlignmentCenter;
            _newestSS = [[UILabel alloc] initWithFrame:newestRect];
            _newestSS.font = [UIFont fontWithName:@"Helvetica" size:14.0f];
            _newestSS.backgroundColor = [UIColor clearColor];
            
            _upsSS = [[UILabel alloc] initWithFrame:upsRect];
            _upsSS.font = [UIFont fontWithName:@"Helvetica" size:12.0f];
            _upsSS.backgroundColor = [UIColor clearColor];

            _rangeSS = [[UILabel alloc] initWithFrame:rangeRect];
            _rangeSS.font = [UIFont fontWithName:@"Helvetica" size:12.0f];
            _rangeSS.backgroundColor = [UIColor clearColor];

            break;
            
        default:
            break;
    }
}


- (void)reloadUpsOrRange:(NSInteger)index direction:(float)UpOrRange{
//    UIImage *upsImg = [UIImage imageNamed:@"ups.png"];
//    UIImage *rangeImg = [UIImage imageNamed:@"range.png"];
    switch (index) {
        case 0:
            if (UpOrRange >= 0) {
//                [_upOrdownSH setImage:upsImg];
                [_ShanghaiBanner setBackgroundColor:[UIColor colorWithHexString:@"CD0100"]];
                [_newestSH setTextColor:[UIColor colorWithHexString:@"CD0100"]];
                [_upsSH setTextColor:[UIColor colorWithHexString:@"CD0100"]];
                [_rangeSH setTextColor:[UIColor colorWithHexString:@"CD0100"]];
            }
            else{
                
//                [_upOrdownSH setImage:rangeImg];
                [_ShanghaiBanner setBackgroundColor:[UIColor colorWithHexString:@"00B210"]];
                [_newestSH setTextColor:[UIColor colorWithHexString:@"00B210"]];
                [_upsSH setTextColor:[UIColor colorWithHexString:@"00B210"]];
                [_rangeSH setTextColor:[UIColor colorWithHexString:@"00B210"]];
            }
            
            [_ShanghaiBanner addSubview:_nameSH];
            [_ShanghaiStock addSubview:_newestSH];
            [_ShanghaiStock addSubview:_upsSH];
            [_ShanghaiStock addSubview:_rangeSH];

            break;
        case 1:
            if (UpOrRange >= 0) {
//                [_upOrdownSZ setImage:upsImg];
                [_ShenZhenBanner setBackgroundColor:[UIColor colorWithHexString:@"CD0100"]];
                [_newestSZ setTextColor:[UIColor colorWithHexString:@"CD0100"]];
                [_upsSZ setTextColor:[UIColor colorWithHexString:@"CD0100"]];
                [_rangeSZ setTextColor:[UIColor colorWithHexString:@"CD0100"]];
            }
            else{
//                [_upOrdownSZ setImage:rangeImg];
                [_ShenZhenBanner setBackgroundColor:[UIColor colorWithHexString:@"00B210"]];
                [_newestSZ setTextColor:[UIColor colorWithHexString:@"00B210"]];
                [_upsSZ setTextColor:[UIColor colorWithHexString:@"00B210"]];
                [_rangeSZ setTextColor:[UIColor colorWithHexString:@"00B210"]];
            }
            
            [_ShenZhenBanner addSubview:_nameSZ];
            [_ShenZhenStock addSubview:_newestSZ];
            [_ShenZhenStock addSubview:_upsSZ];
            [_ShenZhenStock addSubview:_rangeSZ];
            
            break;
        case 2:
            if (UpOrRange >= 0) {
//                [_upOrdownSS setImage:upsImg];
                [_StartupBanner setBackgroundColor:[UIColor colorWithHexString:@"CD0100"]];
                [_newestSS setTextColor:[UIColor colorWithHexString:@"CD0100"]];
                [_upsSS setTextColor:[UIColor colorWithHexString:@"CD0100"]];
                [_rangeSS setTextColor:[UIColor colorWithHexString:@"CD0100"]];
            }
            else{
//                [_upOrdownSS setImage:rangeImg];
                [_StartupBanner setBackgroundColor:[UIColor colorWithHexString:@"00B210"]];
                [_newestSS setTextColor:[UIColor colorWithHexString:@"00B210"]];
                [_upsSS setTextColor:[UIColor colorWithHexString:@"00B210"]];
                [_rangeSS setTextColor:[UIColor colorWithHexString:@"00B210"]];
            }
            
            [_StartupBanner addSubview:_nameSS];
            [_StartupStock addSubview:_newestSS];
            [_StartupStock addSubview:_upsSS];
            [_StartupStock addSubview:_rangeSS];
            
            break;
            
        default:
            break;
    }
}

- (NSString*)GetLocalTime{
    
    NSDate *now = [NSDate date];
    
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:@"MM-dd HH:mm EEE"];

    NSString *  locationString=[dateformatter stringFromDate:now];
    
    if([locationString rangeOfString:@"Mon"].location != NSNotFound ||
       [locationString rangeOfString:@"Tue"].location != NSNotFound ||
       [locationString rangeOfString:@"Wed"].location != NSNotFound ||
       [locationString rangeOfString:@"Thu"].location != NSNotFound ||
       [locationString rangeOfString:@"Fri"].location != NSNotFound ||
       
       [locationString rangeOfString:@"周一"].location != NSNotFound ||
       [locationString rangeOfString:@"周二"].location != NSNotFound ||
       [locationString rangeOfString:@"周三"].location != NSNotFound ||
       [locationString rangeOfString:@"周四"].location != NSNotFound ||
       [locationString rangeOfString:@"周五"].location != NSNotFound)
    {
        NSInteger hour = [[locationString substringWithRange:NSMakeRange(6,2)] intValue];
        NSInteger min = [[locationString substringWithRange:NSMakeRange(9,2)] intValue];
        
        //if{在周一到周五     9am--3pm}   显示获得数据时间
        if ((hour >= 9 && hour<= 14) || (hour == 15 && min == 0)){
            NSString *newStr = [locationString substringToIndex:11];
            locationString = newStr;
        }
        //if{在周一到周五     3pm--9am}   晚上期间显示当天的3pm
        if ((hour >= 15 && min > 1) || (hour > 15 && hour <= 23) ){
            NSString* string;
            NSString *string1= [locationString substringWithRange:NSMakeRange(1,5)];
            NSString *string2 = @"15:00";
            string = [NSString stringWithFormat:@"%@%@", string1, string2];
            locationString = string;
        }
        
        //if{在周一到周五     3pm--9am} 白天凌晨区间显示前一天的3pm
        if ((hour >= 0 && hour <= 8) ){
            
            //if{周一0--9am}    显示周五的3pm
            if ([locationString rangeOfString:@"Mon"].location != NSNotFound ||
                [locationString rangeOfString:@"周一"].location != NSNotFound) {
                NSCalendar *calendar = [NSCalendar currentCalendar];
                NSDateComponents *comps;
                comps = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[[NSDate alloc] init]];
                [comps setHour:-24*3]; //+24表示获取下一天的date，-24表示获取前一天的date；
                [comps setMinute:0];
                [comps setSecond:0];
                NSDate *prevDate = [calendar dateByAddingComponents:comps toDate:now options:0];
                
                NSDateFormatter  *prevDateForMatter=[[NSDateFormatter alloc] init];
                
                [prevDateForMatter setDateFormat:@"MM-dd HH:mm"];
                
                NSString *  prevDateStr=[prevDateForMatter stringFromDate:prevDate];
                NSLog(@"%@",prevDateStr);
                NSString* string;
                NSString *string1= [prevDateStr substringWithRange:NSMakeRange(1,5)];
                NSString *string2 = @"15:00";
                string = [NSString stringWithFormat:@"%@%@", string1, string2];
                locationString = string;
            }
            //周二到周五 白天凌晨区间显示前一天的3pm
            else
            {
                NSCalendar *calendar = [NSCalendar currentCalendar];
                NSDateComponents *comps;
                comps = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[[NSDate alloc] init]];
                [comps setHour:-24]; //+24表示获取下一天的date，-24表示获取前一天的date；
                [comps setMinute:0];
                [comps setSecond:0];
                NSDate *prevDate = [calendar dateByAddingComponents:comps toDate:now options:0];
                
                NSDateFormatter  *prevDateForMatter=[[NSDateFormatter alloc] init];
                
                [prevDateForMatter setDateFormat:@"MM-dd HH:mm"];
                
                NSString *  prevDateStr=[prevDateForMatter stringFromDate:prevDate];
                NSLog(@"%@",prevDateStr);
                NSString* string;
                NSString *string1= [prevDateStr substringWithRange:NSMakeRange(1,5)];
                NSString *string2 = @"15:00";
                string = [NSString stringWithFormat:@"%@%@", string1, string2];
                locationString = string;
            }
        }
        
        NSLog(@"%@",locationString);
    }
    
    if([locationString rangeOfString:@"Sat"].location != NSNotFound ||
       [locationString rangeOfString:@"周六"].location != NSNotFound)
    {
        //if{周6，周日，周一0--am}    显示周五的3pm
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *comps;
        comps = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[[NSDate alloc] init]];
        [comps setHour:-24]; //+24表示获取下一天的date，-24表示获取前一天的date；
        [comps setMinute:0];
        [comps setSecond:0];
        NSDate *prevDate = [calendar dateByAddingComponents:comps toDate:now options:0];
        
        NSDateFormatter  *prevDateForMatter=[[NSDateFormatter alloc] init];
        
        [prevDateForMatter setDateFormat:@"MM-dd HH:mm"];
        
        NSString *  prevDateStr=[prevDateForMatter stringFromDate:prevDate];
        NSLog(@"%@",prevDateStr);
        NSString* string;
        NSString *string1= [prevDateStr substringWithRange:NSMakeRange(1,5)];
        NSString *string2 = @"15:00";
        string = [NSString stringWithFormat:@"%@%@", string1, string2];
        locationString = string;
    
        NSLog(@"%@",locationString);
    }


    if([locationString rangeOfString:@"Sun"].location != NSNotFound ||
       [locationString rangeOfString:@"周日"].location != NSNotFound)
    {
        //if{周6，周日，周一0--am}    显示周五的3pm
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *comps;
        comps = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[[NSDate alloc] init]];
        [comps setHour:-24*2]; //+24表示获取下一天的date，-24表示获取前一天的date；
        [comps setMinute:0];
        [comps setSecond:0];
        NSDate *prevDate = [calendar dateByAddingComponents:comps toDate:now options:0];
        
        NSDateFormatter  *prevDateForMatter=[[NSDateFormatter alloc] init];
        
        [prevDateForMatter setDateFormat:@"MM-dd HH:mm"];
        
        NSString *  prevDateStr=[prevDateForMatter stringFromDate:prevDate];
        NSLog(@"%@",prevDateStr);
        NSString* string;
        NSString *string1= [prevDateStr substringWithRange:NSMakeRange(1,5)];
        NSString *string2 = @"15:00";
        string = [NSString stringWithFormat:@"%@%@", string1, string2];
        locationString = string;
        
        NSLog(@"%@",locationString);
    }

    NSString *  str = [NSString stringWithFormat:@"  数据更新于: %@", locationString];
    NSLog(@"%@",str);
    
    return str;
}

#pragma mark - ****点击事件****
- (void)addWebUrl:(UIControl *)sender
{
    if ([_delegate respondsToSelector:@selector(addUrlWithTag:)]) {
        [_delegate addUrlWithTag:sender.tag];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
