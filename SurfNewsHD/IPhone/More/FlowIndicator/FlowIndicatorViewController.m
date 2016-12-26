//
//  FlowIndicatorViewController.m
//  SurfNewsHD
//
//  Created by Jerry Yu on 13-5-23.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "FlowIndicatorViewController.h"
#import "GTMHTTPFetcher.h"
#import "SurfRequestGenerator.h"
#import "UserManager.h"
#import "NSString+Extensions.h"
#import "FindFlowRequest.h"
#import "PackflowData.h"
#import "CustomAnimation.h"
#import "AppSettings.h"
#import "PhoneReadController.h"



#define LABTEXT_COLOR   [UIColor colorWithHexString:@"999292"]

@interface AllPreView ()

@end

@implementation AllPreView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Custom initialization
        
    }
    return self;
}
#pragma mark - 流量使用状态的图标，流动图
//流量使用状态的图标，流动图
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGRect rect1 = CGRectMake(20, 20, 280, 40);
    CGRect rect3 = CGRectMake(20, 65, 280, 50);
    CGRect rect2 = CGRectMake(20, 135, 280, 20);
    CGRect rect4 = CGRectMake(20, 170, 280, 40);
    
    used = 0.0;
    remain = 0.0;
    for (PackflowData *data in self.flowData.packDataArr)
    {
        used = used + [data.used floatValue];
        remain = remain + [data.remain floatValue];
    }
    
    UIColor *textColor;
    ThemeMgr *mgr = [ThemeMgr sharedInstance];
    if ([mgr isNightmode]) {
        textColor = [UIColor whiteColor];
    }
    else
    {
        textColor = [UIColor blackColor];
    }
    
    usedintLab = [[UILabel alloc] initWithFrame:rect1];
    [usedintLab setBackgroundColor:[UIColor clearColor]];
    [usedintLab setTextAlignment:NSTextAlignmentLeft];
    [usedintLab setFont:[UIFont systemFontOfSize:15]];
    [usedintLab setTextColor:textColor];
    [usedintLab setTextColor:LABTEXT_COLOR];
    
    remainintLab = [[UILabel alloc] initWithFrame:rect2];
    [remainintLab setBackgroundColor:[UIColor clearColor]];
    [remainintLab setTextAlignment:NSTextAlignmentRight];
    [remainintLab setFont:[UIFont systemFontOfSize:12]];
    [remainintLab setTextColor:textColor];
    [remainintLab setTextColor:LABTEXT_COLOR];
    
    AllPreViewProgressView * progressView = [[AllPreViewProgressView alloc] initWithFrame:rect3];
    [progressView setFlowData:self.flowData];
    [progressView setProgressType:ALL_MODEL];
    [progressView setBackgroundColor:[UIColor clearColor]];
    
    if (!self.isTwenty)
    {
        [self addSubview:progressView];
        
        float usedCont = [self.flowData.usedsumStr floatValue];
        if (usedCont > used + remain)
        {
//            [usedintLab setText:[NSString stringWithFormat:@"本月流量已使用:%.0fM/%.0fM", usedCont, used + remain]];
            
            [remainintLab setText:[NSString stringWithFormat:@"超出:%.0fM", usedCont - (remain + used)]];
            [remainintLab setTextColor:[UIColor colorWithHexString:@"AD2F2F"]];
            
            [usedintLab setTextColor:textColor];
            [usedintLab setText:@"本月流量已使用:"];
            UILabel *usedValue = [[UILabel alloc] initWithFrame:CGRectMake(150, 20, 100, 40)];
            [usedValue setBackgroundColor:[UIColor clearColor]];
            [usedValue setFont:[UIFont systemFontOfSize:15]];
            [usedValue setTextColor:[UIColor colorWithHexString:@"AD2F2F"]];
            [usedValue setText:[NSString stringWithFormat:@"%.0fM/%.0fM", usedCont, (used + remain)]];
            [usedValue setTextAlignment:NSTextAlignmentLeft];
            [self addSubview:usedValue];
            
            [progressView setIsFull:YES];
        }
        else
        {
//            [usedintLab setText:[NSString stringWithFormat:@"本月流量已使用:%.0fM/%.0fM", usedCont, used + remain]];
            
            [remainintLab setTextColor:[UIColor colorWithHexString:@"AD2F2F"]];
            [remainintLab setText:[NSString stringWithFormat:@"剩余:%.0fM", remain]];
            
            [usedintLab setTextColor:textColor];
            [usedintLab setText:@"本月流量已使用:"];
            UILabel *usedValue = [[UILabel alloc] initWithFrame:CGRectMake(150, 20, 100, 40)];
            [usedValue setBackgroundColor:[UIColor clearColor]];
            [usedValue setFont:[UIFont systemFontOfSize:15]];
            [usedValue setTextColor:[UIColor colorWithHexString:@"AD2F2F"]];
            [usedValue setText:[NSString stringWithFormat:@"%.0fM", usedCont]];
            [usedValue setTextAlignment:NSTextAlignmentLeft];
            [self addSubview:usedValue];
            
            UILabel *countValue = [[UILabel alloc] initWithFrame:CGRectMake(190, 20, 70, 40)];
            [countValue setBackgroundColor:[UIColor clearColor]];
            [countValue setFont:[UIFont systemFontOfSize:15]];
            [countValue setTextColor:textColor];
            [countValue setText:[NSString stringWithFormat:@"   / %.0fM", (used + remain)]];
            [countValue setTextAlignment:NSTextAlignmentLeft];
            [self addSubview:countValue];
        }
        
    }
    else
    {
        NSString *str1 = self.flowData.usedsumStr;
        [usedintLab setTextColor:textColor];
        [usedintLab setText:[NSString stringWithFormat:@"本月流量已使用:%.0fM", [str1 floatValue]]];
        UILabel *twentiLab = [[UILabel alloc] initWithFrame:rect3];
        [twentiLab setBackgroundColor:[UIColor clearColor]];
        [twentiLab setFont:[UIFont systemFontOfSize:12]];
        [twentiLab setTextAlignment:NSTextAlignmentCenter];
        [twentiLab setTextColor:LABTEXT_COLOR];
        twentiLab.lineBreakMode = NSLineBreakByWordWrapping;
        twentiLab.numberOfLines = 0;
        [twentiLab setText:@"   您是20元封顶(CMWAP)套餐用户\n建议选用CMWAP联网方式,避免产生额外的流量费用"];
        [self addSubview:twentiLab];
    }
    
    balanceLab = [[UILabel alloc] initWithFrame:rect4];
    [balanceLab setBackgroundColor:[UIColor clearColor]];
    [balanceLab setTextAlignment:NSTextAlignmentLeft];
    [balanceLab setFont:[UIFont systemFontOfSize:15]];
    [balanceLab setTextColor:textColor];
    [balanceLab setText:[NSString stringWithFormat:@"话费余额:%@元", self.flowData.balance]];
    
    CGRect  rect5 = CGRectMake(35, self.bounds.size.height / 2 + 40, 100, 40);
    CGRect  rect6 = CGRectMake(110, self.bounds.size.height / 2 + 40, 100, 40);
    /*
     UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
     loginButton.frame = CGRectMake(10.0f, 125.0f, 300.0f, 40.0f);
     [loginButton setBackgroundImage:[UIImage imageNamed:@"login_register_button.png"]
     forState:UIControlStateNormal];
     [loginButton setTitle:@"登  录" forState:UIControlStateNormal];
     [loginButton setTitleColor:[UIColor whiteColor]
     forState:UIControlStateNormal];
     [loginButton.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
     [loginButton addTarget:self
     action:@selector(didLogin:)
     forControlEvents:UIControlEventTouchUpInside];
     [self addSubview:loginButton];
     */
    rechargebt = [UIButton buttonWithType:UIButtonTypeCustom];
    [rechargebt setTag:50];
//    [rechargebt setBackgroundColor:[UIColor colorWithHexString:@"AD2F2F"]];
    [rechargebt setBackgroundImage:[UIImage imageNamed:@"login_register_button.png"] forState:UIControlStateNormal];
    [rechargebt setTitle:@"充值话费" forState:UIControlStateNormal];
    [rechargebt setFrame:rect5];
    [rechargebt addTarget:self action:@selector(clickBt:) forControlEvents:UIControlEventTouchUpInside];
    
    lobbybt = [UIButton buttonWithType:UIButtonTypeCustom];
    [lobbybt setTag:100];
//    [lobbybt setBackgroundColor:[UIColor colorWithHexString:@"AD2F2F"]];
    [lobbybt setBackgroundImage:[UIImage imageNamed:@"login_register_button.png"] forState:UIControlStateNormal];
    [lobbybt setTitle:@"进入掌营" forState:UIControlStateNormal];
    [lobbybt setFrame:rect6];
    [lobbybt addTarget:self action:@selector(clickBt:) forControlEvents:UIControlEventTouchUpInside];
    
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [formatter stringFromDate:date];
    NSLog(@"时间  %@", dateStr);
    [AppSettings setString:dateStr forKey:kFlowIndicatior_Time];

    CGRect  rect7 = CGRectMake(20, self.bounds.size.height - 70, 300, 40);
    CGRect  rect8 = CGRectMake(20, self.bounds.size.height - 50, 300, 40);
    CGRect  rect9 = CGRectMake(20, self.bounds.size.height - 90, 300, 40);
    
    UILabel *infoLab1 = [[UILabel alloc] initWithFrame:rect7];
    [infoLab1 setBackgroundColor:[UIColor clearColor]];
    [infoLab1 setTextAlignment:NSTextAlignmentLeft];
    [infoLab1 setFont:[UIFont systemFontOfSize:12]];
    [infoLab1 setTextColor:LABTEXT_COLOR];
    [infoLab1 setText:[NSString stringWithFormat:@"·以上数据仅供参考"]];
    
    UILabel *infoLab2 = [[UILabel alloc] initWithFrame:rect8];
    [infoLab2 setBackgroundColor:[UIColor clearColor]];
    [infoLab2 setTextAlignment:NSTextAlignmentLeft];
    [infoLab2 setFont:[UIFont systemFontOfSize:12]];
    [infoLab2 setTextColor:LABTEXT_COLOR];
    [infoLab2 setText:[NSString stringWithFormat:@"·部分流量套餐信息暂不支持查询"]];
    
    UILabel *infoLab3 = [[UILabel alloc] initWithFrame:rect9];
    [infoLab3 setBackgroundColor:[UIColor clearColor]];
    [infoLab3 setTextAlignment:NSTextAlignmentLeft];
    [infoLab3 setFont:[UIFont systemFontOfSize:12]];
    [infoLab3 setTextColor:LABTEXT_COLOR];
    [infoLab3 setText:[NSString stringWithFormat:@"·更新时间:%@", dateStr]];
    
    [self addSubview:usedintLab];
    [self addSubview:remainintLab];
    [self addSubview:balanceLab];
    //[self addSubview:rechargebt];
    [self addSubview:lobbybt];
    [self addSubview:infoLab1];
    [self addSubview:infoLab2];
    [self addSubview:infoLab3];
}


- (void)clickBt:(UIButton *)bt
{
    if ([self.allPreDelegate respondsToSelector:@selector(clickBt:)])
    {
        [self.allPreDelegate clickBt:bt];
    }
}

@end


@interface AllPreViewProgressView ()

@end

@implementation AllPreViewProgressView

#define MAXPROGRESS         self.bounds.size.width
#define PROGRESSBG_FRMAE    CGRectMake(0, self.bounds.size.height / 2, MAXPROGRESS, VIEW_HEIGHT)
#define VIEW_HEIGHT         self.bounds.size.height / 2

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Custom initialization
        self.isFull = NO;
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    UIColor *textColor;
    ThemeMgr *mgr = [ThemeMgr sharedInstance];
    if ([mgr isNightmode]) {
        textColor = [UIColor whiteColor];
    }
    else
    {
        textColor = [UIColor blackColor];
    }
    
    if (!progressBg)
    {
        progressBg = [[UIImageView alloc] initWithFrame:PROGRESSBG_FRMAE];
        [progressBg setBackgroundColor:[UIColor colorWithRed:(188.0f/255.0f) green:(188.0f/255.0f) blue:(188.0f/255.0f) alpha:1]];//
        
//        progressBg.layer.shadowColor = [UIColor blackColor].CGColor;
//        progressBg.layer.shadowOpacity = 0.7f;
//        progressBg.layer.shadowOffset = CGSizeZero;
//        progressBg.layer.masksToBounds = NO;
    }
    if (![self.subviews containsObject:progressBg])
    {
        [self addSubview:progressBg];
    }
    
    if (!progressView)
    {
        progressView = [[UIView alloc] initWithFrame:CGRectMake(2, self.bounds.size.height / 2 + 2, 0, self.bounds.size.height / 2 - 4)];
        [progressView setBackgroundColor:[UIColor colorWithHexString:@"AD2F2F"]];
    }
    if (![self.subviews containsObject:progressView])
    {
        [self addSubview:progressView];
    }
    
    if (!usedLab)
    {
        usedLab = [[UILabel alloc] initWithFrame:PROGRESSBG_FRMAE];
        [usedLab setBackgroundColor:[UIColor clearColor]];
        [usedLab setTextAlignment:NSTextAlignmentCenter];
        [usedLab setFont:[UIFont systemFontOfSize:14]];
        [usedLab setTextColor:LABTEXT_COLOR];
    }
    
    if (![self.subviews containsObject:usedLab])
    {
        [self addSubview:usedLab];
    }
    
    if (!allLab)
    {
        allLab = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bounds.size.height / 2, MAXPROGRESS - 2, self.bounds.size.height / 2)];
        [allLab setBackgroundColor:[UIColor clearColor]];
        [allLab setTextAlignment:NSTextAlignmentRight];
        [allLab setFont:[UIFont systemFontOfSize:12]];
        [allLab setTextColor:[UIColor colorWithRed:(188.0f/255.0f) green:(188.0f/255.0f) blue:(188.0f/255.0f) alpha:1]];
    }
    
    float used = 0;
    float remain = 0;
    for (PackflowData *data in self.flowData.packDataArr)
    {
        used = used + [data.used floatValue];
        remain = remain + [data.remain floatValue];
    }
    
    if (ALL_MODEL == self.progressType)
    {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(2, 2, progressBg.frame.size.width - 4, progressBg.frame.size.height - 4)];
        [bgView setBackgroundColor:[UIColor whiteColor]];
        [progressBg addSubview:bgView];
        
        dayIndexIamgeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -3, 45, 30)];
        [dayIndexIamgeView setBackgroundColor:[UIColor clearColor]];
        [dayIndexIamgeView setImage:[UIImage imageNamed:@"coordinate"]];
        if (![self.subviews containsObject:dayIndexIamgeView])
        {
            [self addSubview:dayIndexIamgeView];
        }
        
        NSDate *date = [NSDate date];
        NSCalendar *c = [NSCalendar currentCalendar];
        NSRange dayRange = [c rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
        NSUInteger daysCount = dayRange.length;
        NSUInteger day = [c ordinalityOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
        
        UILabel *infoLab = [[UILabel alloc] initWithFrame:CGRectMake(0, -5, 45, 30)];
        [infoLab setBackgroundColor:[UIColor clearColor]];
        [infoLab setTextColor:[UIColor whiteColor]];
        [infoLab setTextAlignment:NSTextAlignmentCenter];
        [infoLab setFont:[UIFont systemFontOfSize:12]];
        [infoLab setText:[NSString stringWithFormat:@"第%@天", @(day)]];
        if (![dayIndexIamgeView.subviews containsObject:infoLab])
        {
            [dayIndexIamgeView addSubview:infoLab];
        }
        
        if (self.isFull)
        {
            [progressView setFrame:PROGRESSBG_FRMAE];
            [usedLab setText:[NSString stringWithFormat:@"100%%"]];
            
            [UIView beginAnimations:nil context:nil];//@"animationName"
            [UIView setAnimationDuration:1]; //动画持续的秒数
            [UIView setAnimationDelegate:self];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [dayIndexIamgeView setFrame:CGRectMake(MAXPROGRESS / daysCount * day - 30, -3, 45, 30)];
            [UIView commitAnimations];
        }
        else
        {
            if ((used + remain) > 0)
            {
                x = used / (used + remain) * 100;
            }
            else
            {
                x = 0;
            }
            
            [usedLab setText:[NSString stringWithFormat:@"已使用:%.0f%%", x]];
            
            [allLab setText:[NSString stringWithFormat:@"%.0fM", used + remain]];

            float with = MAXPROGRESS * x / 100;
            
            [UIView beginAnimations:nil context:nil]; //@"animationName"
            [UIView setAnimationDuration:1]; //动画持续的秒数
            [UIView setAnimationDelegate:self];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
 
            [progressView setFrame:CGRectMake(2, self.bounds.size.height / 2 + 2, with, self.bounds.size.height / 2 - 4)];

            [dayIndexIamgeView setFrame:CGRectMake(MAXPROGRESS / daysCount * day - 15, -3, 45, 30)];
            
            [UIView commitAnimations];          
        }
    }
    else if(MEAL_MODEL == self.progressType)
    {
        if (![self.packData.isTwenty boolValue]) {
            CGRect rect = CGRectMake(0, self.bounds.size.height - 50, MAXPROGRESS, 20);
            [progressBg setFrame:rect];
            [progressView setFrame:CGRectMake(2, self.bounds.size.height - 50 + 2, 0, 20)];
            [usedLab setFrame:rect];
            [allLab setFrame:CGRectMake(0, self.bounds.size.height - 20, MAXPROGRESS - 2, 20)];
            
            UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(2, 2, progressBg.frame.size.width - 4, progressBg.frame.size.height - 4)];
            [bgView setBackgroundColor:[UIColor whiteColor]];
            [progressBg addSubview:bgView];
            
            UILabel *infoLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, MAXPROGRESS, self.bounds.size.height - 40)];
            [infoLab setBackgroundColor:[UIColor clearColor]];
            [infoLab setTextColor:textColor];
//            [infoLab setTextColor:[UIColor colorWithHexString:@"AD2F2F"]];
            [infoLab setTextAlignment:NSTextAlignmentLeft];
            [infoLab setFont:[UIFont systemFontOfSize:14]];
//            [infoLab setText:[NSString stringWithFormat:@"%@ %.0fM/%.0fM", self.packData.packname, used, used + remain]];
            [infoLab setText:[NSString stringWithFormat:@"%@", self.packData.packname]];
            [self addSubview:infoLab];
            
            float used = [self.packData.used floatValue];
            float remain = [self.packData.remain floatValue];
            
            float count = (used + remain);
            if (count > 0)
            {
                
            }
            else
            {
                count = 1;
            }
            
            [allLab setTextColor:[UIColor colorWithHexString:@"AD2F2F"]];
            [allLab setText:[NSString stringWithFormat:@"剩余%.0fM", remain]];
            [usedLab setText:[NSString stringWithFormat:@"%.0f%%", used * 100 / (used + remain)]];
            
            float with = MAXPROGRESS * (used * 100 / count) / 100;
            [progressView setFrame:CGRectMake(2, self.bounds.size.height - 50 + 2, with, 16)];
                        
            if (![self.subviews containsObject:allLab])
            {
                [self addSubview:allLab];
            }
        }
        else
        {
            UILabel *infoLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, MAXPROGRESS, self.bounds.size.height - 40)];
            [infoLab setBackgroundColor:[UIColor clearColor]];
            [infoLab setTextColor:textColor];
            [infoLab setTextAlignment:NSTextAlignmentLeft];
            [infoLab setFont:[UIFont systemFontOfSize:16]];
            [infoLab setText:[NSString stringWithFormat:@"20元封顶(CMWAP)"]];
            [self addSubview:infoLab];
            
            UILabel *usedLabInfo = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, MAXPROGRESS, 40)];
            [usedLabInfo setBackgroundColor:[UIColor clearColor]];
            [usedLabInfo setTextColor:[UIColor colorWithHexString:@"AD2F2F"]];
            [usedLabInfo setTextAlignment:NSTextAlignmentLeft];
            [usedLabInfo setFont:[UIFont systemFontOfSize:12]];
            [usedLabInfo setText:[NSString stringWithFormat:@"      已使用%@ M", self.flowData.usedsumStr]];
            [self addSubview:usedLabInfo];
            
            [progressBg setAlpha:0];
        }
    }
}

- (void)setProgressViewBgColor:(UIColor *)colorSet
{
    [progressView setBackgroundColor:colorSet];
}


@end


@interface MealView ()

@end

@implementation MealView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Custom initialization
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self initBgScrollView];
    [self initViews];
    
//    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(50, 50, 200, 100)];
//    [lab setText:@"lkjsdbclksbcd"];
//    [bgScrollView addSubview:lab];
}

- (void)initBgScrollView
{
    if (!bgScrollView)
    {
        bgScrollView = [[BgScrollView alloc] initWithFrame:CGRectMake(0, 0, kContentWidth + 1, self.frame.size.height)];
        [bgScrollView setBackgroundColor:[UIColor clearColor]];
        bgScrollView.pagingEnabled = YES;
        bgScrollView.showsHorizontalScrollIndicator = NO;
        bgScrollView.showsVerticalScrollIndicator = NO;
        bgScrollView.scrollsToTop = NO;
        bgScrollView.delegate = self;
        bgScrollView.bounces = NO;
    }
    
    if (![self.subviews containsObject:bgScrollView])
    {
        [self addSubview:bgScrollView];
    }
}

- (void)initViews
{
    //CGRectMake(20, 65, 280, 80)
    for (NSInteger i = 0; i < self.flowData.packDataArr.count; i++)
    {
        PackflowData *packData = [self.flowData.packDataArr objectAtIndex:i];
        AllPreViewProgressView *progressView = [[AllPreViewProgressView alloc] initWithFrame:CGRectMake(20, 100 * i, 280, 100)];
        [progressView setBackgroundColor:[UIColor clearColor]];
        [progressView setProgressType:MEAL_MODEL];
        [progressView setFlowData:self.flowData];
        [progressView setPackData:packData];
        [bgScrollView addSubview:progressView];
        
//        if (i % 2 == 0)
//        {
//            [progressView setProgressViewBgColor:[UIColor colorWithRed:(250.0f/255.0f) green:(105.0f/255.0f) blue:(0.0f/255.0f) alpha:1]];
//        }
        
        if (progressView.frame.origin.y + progressView.frame.size.height >= kContentHeight - 107)
        {
            [bgScrollView setContentSize:CGSizeMake(kContentWidth, progressView.frame.origin.y + progressView.frame.size.height + 80)];
        }
    }
}


#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
}

@end



#define PICKFRAME       CGRectMake(10, 60, 300, 100)
#define BGFRAME         CGRectMake(0.0f, [self StateBarHeight], kContentWidth, kContentHeight - [self StateBarHeight] - 47)//CGRectMake(0, 51, [[UIScreen mainScreen] bounds].size.width, kScreenHeight - 118)
#define ROTFRAME        CGRectMake(50, 270, 135, 5)
#define REMAINLABFRAME  CGRectMake(200, 200, 120, 20)
#define USEDLANBFRAME   CGRectMake(200, 240, 120, 20)

@interface FlowIndicatorViewController ()

@end

@implementation FlowIndicatorViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        // Custom initialization
        self.titleState = (SNState_TopBar |
                           SNState_TopBar_GoBack_Gray|
                           SNState_GestureGoBack);
        isTwenty = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    [self findFlowRequst];
}

- (void)initBgScrollView
{
    if (!bgScrollView)
    {
        bgScrollView = [[BgScrollView alloc] initWithFrame:BGFRAME];
        [bgScrollView setBackgroundColor:[UIColor clearColor]];
        bgScrollView.pagingEnabled = YES;
        bgScrollView.showsHorizontalScrollIndicator = NO;
        bgScrollView.showsVerticalScrollIndicator = NO;
        bgScrollView.scrollsToTop = NO;
        bgScrollView.delegate = self;
        bgScrollView.bounces = NO;
        bgScrollView.contentSize = CGSizeMake(kContentWidth * 2, bgScrollView.frame.size.height);
    }
    
    if (![self.view.subviews containsObject:bgScrollView] && loadingImageView)
    {
        [self.view insertSubview:bgScrollView belowSubview:loadingImageView];
    }
}

- (void)initTitleBts
{
    UIView *topBar = [self topBarView];
    UIView *goBack = [self topGoBackView];
    
    CGFloat btX =goBack.frame.origin.x + goBack.frame.size.width;
    allPreviewBt = [UIButton buttonWithType:UIButtonTypeCustom];
    allPreviewBt.frame = CGRectMake(btX, .0f, 65.0f, 40.0f);
    allPreviewBt.tag = 50;
    allPreviewBt.center = CGPointMake(allPreviewBt.center.x, goBack.center.y);
    [allPreviewBt.titleLabel setFont:[UIFont boldSystemFontOfSize:22.0f]];
    [allPreviewBt setTitle: @"总览" forState:UIControlStateNormal];
    [allPreviewBt setTitleColor:[UIColor colorWithHexString:@"AD2F2F"] forState:UIControlStateNormal];
    [allPreviewBt addTarget:self action:@selector(clickTitleBt:) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:allPreviewBt];
    
    
    btX += CGRectGetWidth(allPreviewBt.frame);
    mealBt = [UIButton buttonWithType:UIButtonTypeCustom];
    mealBt.frame = CGRectMake(btX, .0f, 65.0f, 40.0f);
    mealBt.tag = 100;
    mealBt.center = CGPointMake(mealBt.center.x, goBack.center.y);
    [mealBt.titleLabel setFont:[UIFont boldSystemFontOfSize:22.0f]];
    [mealBt setTitle: @"套餐" forState:UIControlStateNormal];
    [mealBt setTitleColor:[UIColor colorWithHexString:@"999292"] forState:UIControlStateNormal];
    [mealBt addTarget:self action:@selector(clickTitleBt:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mealBt];
    
    self.noGestureRecognizerRect = CGRectMake(0.0f, 5.0f, 130.0f, 40.0f);
}

- (void)clickTitleBt:(UIButton *)button
{
    if (button.tag == 50)
    {
        [bgScrollView setContentOffset:CGPointZero animated:YES];
        [allPreviewBt setTitleColor:[UIColor colorWithHexString:@"AD2F2F"] forState:UIControlStateNormal];
        [mealBt setTitleColor:[UIColor colorWithHexString:@"999292"] forState:UIControlStateNormal];
    }
    else if (button.tag == 100)
    {
        [bgScrollView setContentOffset:CGPointMake(bgScrollView.frame.size.width, 0.0f) animated:YES];
        [allPreviewBt setTitleColor:[UIColor colorWithHexString:@"999292"] forState:UIControlStateNormal];
        [mealBt setTitleColor:[UIColor colorWithHexString:@"AD2F2F"] forState:UIControlStateNormal];
    }
}

- (void)showLoadingView
{
    if (!loadingImageView)
    {
        loadingImageView = [[UIImageView alloc] initWithFrame:BGFRAME];
//        loadingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0, kContentWidth, kContentHeight - 47)];
//        [loadingImageView setImage:[UIImage imageNamed:@""]];
        [loadingImageView setBackgroundColor:[UIColor clearColor]];
    }
    if (![self.view.subviews containsObject:loadingImageView])
    {
        [self.view addSubview:loadingImageView];
    }
    
//    [PhoneNotification manuallyHideWithText:@"xxx" indicator:YES];
    
    if (!_activityView)
    {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    float w = CGRectGetWidth(loadingImageView.frame);
    float h = CGRectGetHeight(loadingImageView.frame);
    float aW = CGRectGetWidth(_activityView.bounds);
    float aH = CGRectGetHeight(_activityView.bounds);
    _activityView.frame = CGRectMake((w-aW)*0.5f, (h-aH)*0.5f, aW, aH);
    if (![loadingImageView.subviews containsObject:_activityView])
    {
        [loadingImageView addSubview:_activityView];
    }
    [_activityView startAnimating];
    
    ThemeMgr *mgr = [ThemeMgr sharedInstance];
    BOOL isNight = [mgr isNightmode];
    
    UILabel *messageLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    messageLab.center = CGPointMake(_activityView.center.x, _activityView.center.y + 20);
    [messageLab setFont:[UIFont systemFontOfSize:14]];
    [messageLab setBackgroundColor:[UIColor clearColor]];
    [messageLab setTextAlignment:NSTextAlignmentLeft];
    if (isNight) {
        [messageLab setTextColor:[UIColor grayColor]];
        [_activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    }
    else
    {
        [messageLab setTextColor:[UIColor colorWithHexString:@"34393d"]];
//        [_activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    }
    
    [messageLab setText:@"正在为您查询流量数据,请稍侯…"];
    
    [loadingImageView addSubview:messageLab];
}

- (void)animationLoadingImageView
{
//    [PhoneNotification hideNotification];
    [_activityView stopAnimating];
    if ([self.view.subviews containsObject:loadingImageView])
    {
        [UIView beginAnimations:@"animationName" context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(removeLoadingImageView)];
        [UIView setAnimationDuration:0.08];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];        
        [loadingImageView setAlpha:0.0];
        [UIView commitAnimations];
    }
}

- (void)removeLoadingImageView
{
    if ([self.view.subviews containsObject:loadingImageView])
    {
        [_activityView removeFromSuperview];
        [loadingImageView removeFromSuperview];
        
        _activityView = nil;
        loadingImageView = nil;
    }
}

- (void)findFlowRequst
{
    
    [self showLoadingView];
    [[UserManager sharedInstance] userFlowInfo:^(SNUserFlow *flowInfo) {
        
        if (flowInfo) {
            [self flowWithStr:flowInfo];
        }
        else {
            [PhoneNotification hideNotification];
            [PhoneNotification autoHideWithText:@"请求超时"];
            [self clickCloseBt];
        }
        [self animationLoadingImageView];
    }];
}

- (void)clickCloseBt
{
    [self dismissControllerAnimated:PresentAnimatedStateFromRight];
}

- (void)flowWithStr:(SNUserFlow *)flowInfo
{
    if (!flowData) {
        flowData = [[FlowData alloc] init];
    }
    

    flowData.balance = flowInfo.balance;
    flowData.usedsumStr =
    [NSString stringWithFormat:@"%@", flowInfo.usedsum];
    flowData.prepaidUrlStr = flowInfo.prepaidUrl;
    flowData.loginbusUrlStr = flowInfo.loginbusUrl;
    
    NSArray *voicepackflow = [flowInfo voicepackflow];
    if ([voicepackflow count] ) {
        VoicePackFlowData* flow = [voicepackflow lastObject];
        flowData.total = flow.total;
    }
    
    //保存数据  以供更多tab显示
    [AppSettings setString:flowData.usedsumStr forKey:kFlowIndicatior_Usedsum];
    [AppSettings setString:flowData.balance forKey:kFlowIndicatior_Balance];
    [AppSettings setString:flowData.total forKey:KFlowIndicatior_Total];

    NSArray *packflowArr = flowInfo.packflow;
    for (PackflowData *pkData in packflowArr) {
        if ([pkData.isTwenty boolValue]) {
            isTwenty = YES;
            break;
        }
    }
    
    flowData.packDataArr = packflowArr;
    
    [self initTitleBts];
    [self initBgScrollView];
    [self initAllPreView:isTwenty];
    [self initMealView];
}

- (void)initAllPreView:(BOOL)twenty
{
    if (bgScrollView && [self.view.subviews containsObject:bgScrollView])
    {
        AllPreView *allPview = [[AllPreView alloc] initWithFrame:CGRectMake(0, 0, kContentWidth, kContentHeight - [self StateBarHeight] - 47)];
        [allPview setAllPreDelegate:self];
        [allPview setBackgroundColor:[UIColor clearColor]];
        [allPview setIsTwenty:twenty];
        [allPview setFlowData:flowData];
        [bgScrollView addSubview:allPview];
    }
}

- (void)initMealView
{
    if (bgScrollView && [self.view.subviews containsObject:bgScrollView])
    {
        if (!mealView)
        {
            mealView = [[MealView alloc] initWithFrame:CGRectMake(kContentWidth, 0, kContentWidth, kContentHeight - [self StateBarHeight] - 47)];
            [mealView setBackgroundColor:[UIColor clearColor]];
            [mealView setFlowData:flowData];
        }
        if (![bgScrollView.subviews containsObject:mealView])
        {
            [bgScrollView addSubview:mealView];
        }
    }
}

#pragma mark UIScrollViewDelegate methods
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger page = floor((scrollView.contentOffset.x - scrollView.frame.size.width / 2) / scrollView.frame.size.width) + 1;
    
    if (page == 0)
    {
        [allPreviewBt setTitleColor:[UIColor colorWithHexString:@"AD2F2F"] forState:UIControlStateNormal];
        [mealBt setTitleColor:[UIColor colorWithHexString:@"999292"] forState:UIControlStateNormal];
    }
    else if (page == 1)
    {
        [allPreviewBt setTitleColor:[UIColor colorWithHexString:@"999292"] forState:UIControlStateNormal];
        [mealBt setTitleColor:[UIColor colorWithHexString:@"AD2F2F"] forState:UIControlStateNormal];
    }
}

#pragma mark - NightModeChangedDelegate
-(void) nightModeChanged:(BOOL) night
{
    [super nightModeChanged:night];
}

#pragma mark AllPreViewDelegate

- (void)clickBt:(UIButton *)bt
{
    if (50 == bt.tag)
    {
        if (flowData.prepaidUrlStr)
        {
            PhoneReadController *controller = [PhoneReadController new];
            controller.webUrl = flowData.prepaidUrlStr;
            [self presentController:controller
                           animated:PresentAnimatedStateFromRight];
        }
    }
    else if(100 == bt.tag)
    {
        if (flowData.loginbusUrlStr)
        {
            PhoneReadController *controller = [PhoneReadController new];
            controller.webUrl = flowData.loginbusUrlStr;
            [self presentController:controller
                           animated:PresentAnimatedStateFromRight];
        }
    }
}

@end
