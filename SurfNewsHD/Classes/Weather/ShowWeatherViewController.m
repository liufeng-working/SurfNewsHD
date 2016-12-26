//
//  ShowWeatherViewController.m
//  SurfNewsHD
//
//  Created by XuXg on 15/7/15.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "ShowWeatherViewController.h"
#import "TodayWeatherView.h"
#import "WeatherManager.h"
#import "ThreeDayWeatherView.h"
#import "PhoneSelectCityController.h"
#import "UIButton+Block.h"
#import "WeatherRefreshView.h"
#import "NetworkStatusDetector.h"
#import "DispatchUtil.h"
#import "PhoneNotification.h"

@interface ShowWeatherViewController () <WeatherUpdateDelegate,WeatherRefreshViewDelegate>{

    __weak TodayWeatherView *_todayWeather;
    __weak ThreeDayWeatherView *_threeeWeather;
    __weak UIImageView *_arrowView;
    __weak UIButton *_topRefreshBtn;
}

@property(nonatomic,strong)WeatherRefreshView * refreshView;

@end

@implementation ShowWeatherViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.titleState = SNState_TopBar | SNState_GestureGoBack | SNState_TopBar_Title | SNState_TopBar_GoBack_White | SNState_TopBar_NotBackgroundImage;
    }
    return self;
}

//懒加载
-(WeatherRefreshView *)refreshView
{
    if (!_refreshView) {
        CGFloat W = RefreshViewWidth;
        CGFloat H = RefreshViewHeight;
        CGFloat X = (self.view.frame.size.width - W) * 0.5;
        CGFloat Y = - RefreshViewHeight;
        CGRect rect = CGRectMake(X, Y, W, H);
        _refreshView = [[WeatherRefreshView alloc]initWithFrame:rect];
        _refreshView.delegate = self;   //设置代理
        [self.view addSubview:_refreshView];
    }
    return _refreshView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGFloat w = CGRectGetWidth(self.view.bounds);
    CGFloat h = CGRectGetHeight(self.view.bounds);
    
    // 设置字体颜色
    UIButton *titleView = [self titleView];
    [titleView setTitleColor:[UIColor whiteColor]
                    forState:UIControlStateNormal];
    
    [titleView setEnlargeEdgeWithTop:0 right:20 bottom:0 left:0];
    
    
    // topBar 增加向下箭头图片
    UIImage *arrowImg = [UIImage imageNamed:@"topTabBar_arrowDown"];
    UIImageView *arrowView = [[UIImageView alloc] initWithImage:arrowImg];
    [arrowView sizeToFit];
    [arrowView setHidden:YES];
    _arrowView = arrowView;
    [[self topBarView] addSubview:arrowView];
    

    // topBar 增加刷新按钮
    UIImage *btnImg = [UIImage imageNamed:@"topTabBar_refresh_white"];
    CGSize refreshSize = [self topGoBackView].bounds.size;
    CGFloat btnX = w - refreshSize.width;
    CGFloat btnY = self.StateBarHeight - refreshSize.height;
    CGFloat btnImgTop = (refreshSize.height - btnImg.size.height) / 2.f;
    CGFloat btnImgLeft = (refreshSize.width - btnImg.size.width) / 2.f;
    UIButton *refresh = [UIButton buttonWithType:UIButtonTypeCustom];
    _topRefreshBtn = refresh;
    [refresh setImage:btnImg forState:UIControlStateNormal];
    [refresh setImageEdgeInsets:UIEdgeInsetsMake(btnImgTop, btnImgLeft, btnImgTop, btnImgLeft)];
    [refresh setFrame:CGRectMake(btnX, btnY, refreshSize.width, refreshSize.height)];
    [refresh addTarget:self action:@selector(refreshWeatherClick:) forControlEvents:UIControlEventTouchUpInside];
    [[self topBarView] addSubview:refresh];
    
    
    // 今天天气区域
    CGSize threeSize = [ThreeDayWeatherView fitSize];
    TodayWeatherView *today = [TodayWeatherView new];
    _todayWeather = today;
    [today sizeToFit];
    CGFloat showHeight = h-threeSize.height;
    CGFloat todayHeight = CGRectGetHeight(today.bounds);
    if (showHeight < todayHeight) {
        CGFloat moveY = -(todayHeight - showHeight);
        today.transform = CGAffineTransformMakeTranslation(0,moveY);
    }
    else {
        showHeight = todayHeight;
    }
    [self.view addSubview:today];
    [self.view bringSubviewToFront:[self topBarView]];
    
    
    // 未来天气区域
    CGFloat fY = showHeight + (h-showHeight-threeSize.height)/2;
    CGFloat fX = (w - threeSize.width)/2;
    CGRect threeR = CGRectMake(fX, fY, threeSize.width, threeSize.height);
    ThreeDayWeatherView *threeWeather =
    [[ThreeDayWeatherView alloc] initWithFrame:threeR];
    _threeeWeather = threeWeather;
    [self.view addSubview:threeWeather];

    // 添加一个天气切换事件
    [[WeatherManager sharedInstance] addWeatherUpdatedNotify:self];
    
    //增加下拉刷新手势
    UIPanGestureRecognizer * panGR = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureRecognizerStart:)];
    [self.view addGestureRecognizer:panGR];
}

//下拉刷新手势
-(void)panGestureRecognizerStart:(UIPanGestureRecognizer *)pan
{
    //正在刷新，直接返回
    if(self.refreshView.isAnimation) return;
    CGPoint translationPoint = [pan translationInView:pan.view];
    
    //把移动的距离，传过去
    self.refreshView.pullDistance = translationPoint.y;
    
    //手势结束
    if (pan.state == UIGestureRecognizerStateEnded) {
        
        //把结束状态传过去
        self.refreshView.isEnd = YES;
    }
    
    //清空位移，防止累加
    [pan setTranslation:CGPointZero inView:pan.view];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    
    WeatherInfo *weather =
    [WeatherManager sharedInstance].weatherInfo;
    [self updateWeatherUI:weather];
}

// 更新未来天气信息
-(void)updateWeatherUI:(WeatherInfo *)weather
{
    // 标题
    if ([weather cityName] && [[weather cityName] length] > 0) {
        [self setTitle:[weather cityName]];
        
        
        UIButton *titleView = [self titleView];
        CGPoint arrowCenter = titleView.center;
        arrowCenter.x += ((CGRectGetWidth(titleView.bounds) + CGRectGetWidth(_arrowView.bounds)) / 2.f + 5.f);
        _arrowView.center = arrowCenter;
        [_arrowView setHidden:NO];
    }
    else {
        [_arrowView setHidden:YES];
    }
    
    
    // 今天数据
    [_todayWeather refreshWeatherInfo:weather];
    
    // TODO: 更新未来天气vCustomCellBackgroundViewv
    [_threeeWeather refreshWeatherFromFutureWeatherArray:weather.futureWeather];
}


#pragma mark - UIButton click
// 刷新天气按钮
- (void)refreshWeatherClick:(UIButton *)sender
{
    NetworkStatusType type = [NetworkStatusDetector currentStatus];
    if (type == NSTNoWifiOrCellular || type == NSTUnknown)
    {
        [PhoneNotification autoHideWithText:@"网络异常!"];
        return;
    }
    
    //检测是否正在刷新
    if(self.refreshView.isAnimation) return;

    //出现下拉刷新的效果
    CGRect oldR = self.refreshView.frame;
    oldR.origin.y = RefreshDistance;
    self.refreshView.frame = oldR;
    [self.refreshView startAnimation];
    
    //刷新天气，按钮转动
    [self refreshWeather];
}

// 按钮旋转动画
-(void)refreshWeather
{
    //设置为不可用，防止连续点击
    _topRefreshBtn.userInteractionEnabled = NO;
    
    CABasicAnimation * rotationAnimation =
    [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = @(M_PI * 2.0);
    rotationAnimation.duration = 1.f;
    rotationAnimation.repeatCount = MAXFLOAT;
    [_topRefreshBtn.layer addAnimation:rotationAnimation
                                forKey:@"kRotationAnimationKey"];
    
    //刷新天气
    WeatherManager *wm = [WeatherManager sharedInstance];
    [wm updateWeatherInfo];
    
}

//移除按钮转动动画
-(void)removeRefreshBtnAnimation
{
    [_topRefreshBtn.layer removeAnimationForKey:@"kRotationAnimationKey"];
    
    //没有这个延时，连续点击刷新按钮时，就会有点小问题
    [DispatchUtil dispatch:^{
        _topRefreshBtn.userInteractionEnabled = YES;
    } after:0.5];
}
// 标题按钮，需要继承次函数，才能监听事件
-(void)titleButtonClick:(UIButton *)sender
{
    // 进入现在城市按钮
    [self presentController:[PhoneSelectCityController new]
                   animated:PresentAnimatedStateFromRight];
}


#pragma mark - WeatherUpdateDelegate
/**
 *  天气将要更新
 */
- (void)weatherWillUpdate
{
    
}
/**
 *  天气信息发送改变
 *
 *  @param succeeded 是否更新成功
 *  @param info      天气信息
 */
- (void)handleWeatherInfoChanged:(BOOL)succeeded
                     weatherInfo:(WeatherInfo*)info
{
    if(succeeded) {
        [self updateWeatherUI:info];
        //延时移除
        [_refreshView performSelector:@selector(stopAnimation) withObject:nil afterDelay:3.f];
    }else{
        //如果天气更新失败，立即停止动画
        [PhoneNotification autoHideWithText:@"天气更新失败"];
        [_refreshView stopAnimation];
    }
}

#pragma mark - ****WeatherRefreshViewDelegate****
//代理回调来判断是否，刷新天气以及刷新按钮是否转动
-(void)shouldStartRefreshWeather
{
    NetworkStatusType type = [NetworkStatusDetector currentStatus];
    if (type == NSTNoWifiOrCellular || type == NSTUnknown)
    {
        //网络异常时，立即停止动画
        [_refreshView stopAnimation];
        [PhoneNotification autoHideWithText:@"网络异常!"];
        return;
    }
    
    //刷新按钮转动
    [self refreshWeather];
}

-(void)refreshAnimationDidEnd
{
    [self removeRefreshBtnAnimation];
}
@end
