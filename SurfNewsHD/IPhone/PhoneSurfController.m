//
//  PhoneSurfController.m
//  SurfNewsHD
//
//  Created by apple on 13-6-4.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhoneSurfController.h"
#import "AppDelegate.h"
#import "PhoneRootViewController.h"
#import "NotificationManager.h"
#import "PhoneSurfViewControllerTransition.h"
#import "DispatchUtil.h"
#import "UIImage+Resize.h"
#import "UIImage+Extensions.h"


#define kAnimateTime 0.4f
#define kStartX -200        // 背景视图起始frame.x




@interface PhoneSurfController ()
<UINavigationControllerDelegate,
UIViewControllerTransitioningDelegate>
{
    __weak UIView *_topBar; // 顶部栏
    __weak UIImageView *_topBarBGImg;
    __weak UIButton *_titleBtn;
    __weak UIButton *_topGoBack;
}


@property(nonatomic,strong) SurfInteractive *interactive;
@end




@implementation PhoneSurfController
@synthesize titleState;
@synthesize noGestureRecognizerRect;
- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        _StateBarHeight = 45.0f;
        self.titleState = PhoneSurfControllerStateNone;
        
        if (IOS7) {
            _StateBarHeight = 65;
        }
        
        noGestureRecognizerRect = CGRectZero;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // 添加手势返回
    if (!IOS7) {
        if ([self isSupportGestureGoBack])
        {
            //添加手势
            UILongPressGestureRecognizer *gr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action: @selector(longPressGestureReceive:)];
            gr.minimumPressDuration = 0.0f;
            gr.delegate = self;
            [self.view addGestureRecognizer:gr];
        }
    }
    
    CGFloat w = CGRectGetWidth(self.view.bounds);
    
    
	// Do any additional setup after loading the view.
    if ([self isSupportTopBar]) {
        
        CGRect tbR = CGRectMake(0.0f, 0.0f, w, _StateBarHeight);
        UIView *topBar = [[UIView alloc] initWithFrame:tbR];
        _topBar = topBar;
        [self.view addSubview:topBar];

        //这里是设置UIview里面字体的大小，距离，颜色之类的
        // 背景图片
        if (!(titleState & SNState_TopBar_NotBackgroundImage)) {
            UIImageView *bgImg =
            [[UIImageView alloc] initWithFrame:tbR];
            _topBarBGImg = bgImg;
            [bgImg setUserInteractionEnabled:NO];
            [topBar addSubview:bgImg];
        }
 
        
        
        if (titleState & SNState_TopBar_Title) {
            // 居中标题
            UIFont *tF = [UIFont boldSystemFontOfSize:22.0f];
            UIButton *tBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            _titleBtn = tBtn;
            [tBtn setHidden:YES];
            [tBtn.titleLabel setFont:tF];
            [tBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
            [tBtn setTitleColor:[UIColor colorWithHexValue:0xffad2f2f] forState:UIControlStateNormal];
            [tBtn addTarget:self action:@selector(titleButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [topBar addSubview:tBtn];
        }
        
        // go back
        if (titleState & SNState_TopBar_GoBack_Gray ||
            titleState & SNState_TopBar_GoBack_White) {
            // 顶部返回按钮
            CGSize btnSize = {75,45};
            UIImage *btnImg;
            if (titleState & SNState_TopBar_GoBack_Gray) {
                btnImg = [UIImage imageNamedNewImpl:@"topTabBar_goBack_gray"];
            }
            else {
                btnImg = [UIImage imageNamedNewImpl:@"topTabBar_goBack_white"];
            }
            
            CGFloat imgW = btnImg.size.width;
            CGFloat imgH = btnImg.size.height;
            CGFloat top = (btnSize.height - imgH)/2.f;
            CGFloat left = 15.f;
            UIButton *backBtn =
            [UIButton buttonWithType:UIButtonTypeCustom];
            _topGoBack = backBtn;
            backBtn.frame = CGRectMake(0.0f, _StateBarHeight-btnSize.height,btnSize.width,btnSize.height);
            
            [backBtn setImage:btnImg forState:UIControlStateNormal];
            [backBtn setImage:[UIImage imageNamed:@"topTabBar_goBack_highlighted"] forState:UIControlStateHighlighted];
            [backBtn setImageEdgeInsets:UIEdgeInsetsMake(top, left, top, btnSize.width-imgW-left)];
            [backBtn addTarget:self action:@selector(dismissBackController) forControlEvents:UIControlEventTouchUpInside];
            [topBar addSubview:backBtn];
        }
    }
    
    // 背景层i
    if (!backGView) {
        backGView=[[UIView alloc] initWithFrame:self.view.bounds];
        [backGView setUserInteractionEnabled:NO];
        BOOL isN = [[ThemeMgr sharedInstance] isNightmode];
        UIColor *bgColor =
        [UIColor colorWithHexValue:isN ? 0xFF2D2E2F:0xFFF8F8F8];
        backGView.backgroundColor = bgColor;
        [self.view insertSubview:backGView atIndex:0];
    }
  
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    // 这里需要延迟加载，因为这样子类就可以兼顾到

    ThemeMgr *mgr = [ThemeMgr sharedInstance];
    [self nightModeChanged:[mgr isNightmode]];
 
    
    [[ThemeMgr sharedInstance] registerNightmodeChangedNotification:self];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    ThemeMgr *mgr = [ThemeMgr sharedInstance];
    [mgr unregisterNightmodeChangedNotification:self];
}

-(void)setTitle:(NSString *)title
{
    // 不要super,如果super会造成Tabbar上出现重叠的title
    // 子类中不要在init方法中使用self.title,在viewDidLoad里使用self.title
    if (_titleBtn) {
        if (title && ![title isEmptyOrBlank]) {
            [_titleBtn setHidden:NO];
            [_titleBtn setTitle:title forState:UIControlStateNormal];
            
            CGSize tSize = [_titleBtn sizeThatFits:CGSizeZero];
            [_titleBtn setFrame:CGRectMake(0, 0, tSize.width, tSize.height)];
            CGPoint tCenter = _topBar.center;
            if (IOS7) {
                tCenter.y += 10;
            }
            _titleBtn.center = tCenter;
        }
        else
        {
            [_titleBtn setHidden:YES];
        }
    }
}

- (void)initBottomToolsBar:(BOOL)isNeedBackButton
{
    if (toolsBottomBar) {
        return;
    }
    
    CGRect barR = CGRectMake(0.0f, CGRectGetHeight(self.view.frame) - kToolsBarHeight,
                             self.view.frame.size.width, kToolsBarHeight);
    toolsBottomBar = [[UIView alloc] initWithFrame:barR];
    toolsBottomBar.backgroundColor = self.view.backgroundColor;
    
    // 这个东西是一个状态栏顶部的阴影
    NSMutableArray *colors = [NSMutableArray array];
    [colors addObject:(id)[[UIColor colorWithWhite:1.0f alpha:0.0] CGColor]];
    [colors addObject:(id)[[UIColor colorWithWhite:0.0f alpha:0.2] CGColor]];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    [gradient setFrame:CGRectMake(0, -2.0f,toolsBottomBar.frame.size.width,2.0f)];
    gradient.colors = colors;
    [toolsBottomBar.layer insertSublayer:gradient atIndex:0];
    [self.view addSubview:toolsBottomBar];
    
    if (isNeedBackButton) {
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.frame = CGRectMake(0.0f, 0.0f, 64.0f, 49.0f);
        [backButton setBackgroundImage:[UIImage imageNamed:@"backBar.png"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(dismissBackController) forControlEvents:UIControlEventTouchUpInside];
        [toolsBottomBar addSubview:backButton];
    }
}
- (UIView *)getBottomToolsBar
{
    return toolsBottomBar;
}
- (UIView *)addBottomToolsBar
{
    [self initBottomToolsBar:YES];
    return  toolsBottomBar;
}

/**
 *  顶部TabBar View
 *
 *  @return uIView
 */
- (UIView *)topBarView
{
    return _topBar;
}
-(UIButton*)titleView {
    return _titleBtn;
}
- (UIButton*)topGoBackView
{
    return _topGoBack;
}


- (void)KeyboardReturn:(id)sender{
     [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    UIButton *btn = (UIButton*)sender;
    [btn removeFromSuperview];
}

- (void)addMiniKeyBoard
{
    miniButton = [UIButton buttonWithType:UIButtonTypeCustom];
    miniButton.frame = CGRectMake(320.0f - 50.0f, 7.0f, 34.0f, 34.0f);
    [miniButton setBackgroundImage:[UIImage imageNamed:@"minikeyborad.png"] forState:UIControlStateNormal];
    [miniButton addTarget:self action:@selector(KeyboardReturn:) forControlEvents:UIControlEventTouchUpInside];
    [toolsBottomBar addSubview:miniButton];
}

// 是否支持手势返回
- (BOOL)isSupportGestureGoBack
{
    return (titleState & SNState_GestureGoBack);
}
// 是否支持TopBar
- (BOOL)isSupportTopBar
{
    return (titleState & SNState_TopBar);
}



- (void)dismissMiniKeyBoard{
    [miniButton removeFromSuperview];
}

// 标题按钮，需要继承次函数，才能监听事件
-(void)titleButtonClick:(UIButton *)sender
{
    
    
}

-(void)dismissBackController
{
    [self dismissControllerAnimated:PresentAnimatedStateFromRight];
}


- (void)presentController:(UIViewController *)viewController
                 animated:(PresentAnimatedState)state
{
    if(!IOS7)
    {
        // 截图操作
        [theApp screenAddCapture];

        //切换试图
        [super presentViewController:viewController animated:NO completion:nil];
        
        //记录顶层VC
        [theApp pushTopMostVC:viewController];
        
        if (state == PresentAnimatedStateNone){
            return;
        }

        CGRect rect = viewController.view.layer.frame;
        UIImage *lastScreenShot = [theApp.screenShotsList lastObject];
        
        CGRect frame = CGRectMake(0, 0, rect.size.width , rect.size.height);
        UIView *bgView = [[UIView alloc]initWithFrame:frame];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:lastScreenShot];//背景图
        [bgView addSubview:imageView];
        UIView* blackMask = [[UIView alloc]initWithFrame:imageView.bounds];
        blackMask.backgroundColor = [UIColor blackColor];
        blackMask.alpha = 0.f;
        [bgView addSubview:blackMask];

        // 整体向右移动
        viewController.view.layer.frame = CGRectMake(rect.size.width, rect.origin.y, rect.size.width, rect.size.height);
        bgView.frame = CGRectOffset(bgView.frame, -rect.size.width,0.f);    
        [viewController.view insertSubview:bgView atIndex:0];    

        [UIView animateWithDuration:kAnimateTime animations:^
         {
             //回到原来状态
             viewController.view.layer.frame = CGRectMake(rect.origin.x,
                                                          rect.origin.y,
                                                          rect.size.width, rect.size.height);
             blackMask.alpha = 0.4f;
             bgView.frame = CGRectOffset(bgView.frame, -kStartX, 0.f);
             
         } completion:^(BOOL finished)
         {
             [bgView removeFromSuperview];
         }];
    }
    else
    {   // IOS7 之后的Controller切换动画
        // 截图操作
        [theApp screenAddCapture];
        
        
        [viewController setTransitioningDelegate:self];
        
        // 控件是否支持手势切换
        if ([viewController isKindOfClass:[PhoneSurfController class]]) {
            if ([(PhoneSurfController*)viewController isSupportGestureGoBack]) {
                _interactive = [SurfInteractive new];
                [_interactive addPopGesture:viewController];
            }
        }
       
        
        //切换试图
        [super presentViewController:viewController
                            animated:YES completion:nil];

        
        //记录顶层VC
        [theApp pushTopMostVC:viewController];
    }
}

- (void)dismissControllerAnimated:(PresentAnimatedState)state
{
    AppDelegate *appDelegate = theApp;
    if (!IOS7)
    {
        if (state == PresentAnimatedStateNone){
            [appDelegate screenDeleteCapture];
            [super dismissViewControllerAnimated:NO completion:nil];
            [appDelegate popTopMostVC];
        }else{
        
            CGRect rect = self.view.layer.frame;
            UIImage *lastScreenShot = [appDelegate.screenShotsList lastObject];
            [appDelegate screenDeleteCapture];
            
            
            // 没有从上到下或从下道上，全部改成从左向右
            CGRect frame = CGRectMake(kStartX, 0, rect.size.width , rect.size.height);
            UIView *bgView = [[UIView alloc]initWithFrame:frame];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:lastScreenShot];//背景图
            [bgView addSubview:imageView];
            UIView* blackMask = [[UIView alloc]initWithFrame:imageView.bounds];
            blackMask.backgroundColor = [UIColor blackColor];
            blackMask.alpha = 0.4f;
            [bgView addSubview:blackMask];
            [self.view insertSubview:bgView atIndex:0];
            
            
            [UIView animateWithDuration:kAnimateTime animations:^
             {
                 //回到原来状态
                 blackMask.alpha = 0.f;
                 bgView.frame = CGRectMake(-rect.size.width, 0.f, rect.size.width, rect.size.height);
                 self.view.layer.frame = CGRectMake(rect.origin.x + rect.size.width, rect.origin.y,
                                                    rect.size.width, rect.size.height);
                 
             } completion:^(BOOL finished)
             {
                 //[bgView removeFromSuperview];
                 [self dismissControllerAnimated:PresentAnimatedStateNone];
             }];
        }
    }
    else{
        //切换试图
        [appDelegate screenDeleteCapture];
        
        // _ismoving 表示是手势返回过来的
        if (_isMoving) {
            [super dismissViewControllerAnimated:NO completion:nil];
        }
        else{
            [super dismissViewControllerAnimated:YES completion:nil];
        }
        
        [appDelegate popTopMostVC];

    }
}

#pragma mark - 点击事情
- (void)moveViewWithX:(float)x
{
    x = x < 0 ? 0 : x;
    x = x > kContentWidth ? kContentWidth : x;
    
    CGRect frame = self.view.frame;
    frame.origin.x = x;
    self.view.frame = frame;
    
    float alpha = 0.4 - (x/800);    
    _blackMask.alpha = alpha;
    
    CGFloat aa = fabs(_startBackViewX) / kContentWidth;
    CGFloat moveX = x * aa;
    CGFloat lastScreenShotViewHeight = kContentHeight;
    [_lastScreenShotView setFrame:CGRectMake(_startBackViewX+moveX, 0,
                                             kContentWidth,
                                             lastScreenShotViewHeight)];
    
}

- (void)longPressGestureReceive:(UIPanGestureRecognizer *)recoginzer
{    
    CGPoint touchPoint = [recoginzer locationInView:[[UIApplication sharedApplication] keyWindow]];    
    if (recoginzer.state == UIGestureRecognizerStateBegan) {        
        _isMoving = YES;
        _startTouch = touchPoint;
        
        if (!_backgroundView)
        {
            // 创建背景View
            CGRect frame = self.view.frame;
            frame.origin.x = 0;
            
            _backgroundView = [[UIView alloc] initWithFrame:frame];
            _blackMask = [[UIView alloc]initWithFrame:_backgroundView.bounds];
            _blackMask.backgroundColor = [UIColor blackColor];
            [_backgroundView addSubview:_blackMask];
            
            [self.view.superview insertSubview:_backgroundView belowSubview:self.view];
        }
        
        _backgroundView.hidden = NO;
        if (_lastScreenShotView){
            [_lastScreenShotView removeFromSuperview];
            _lastScreenShotView = nil;
        }
        
        _startBackViewX = kStartX;
        UIImage *lastScreenShot = [theApp.screenShotsList lastObject];
        _lastScreenShotView = [[UIImageView alloc]initWithImage:lastScreenShot];
        [_lastScreenShotView setFrame:CGRectMake(_startBackViewX, 0,
                                                 _lastScreenShotView.frame.size.height,
                                                 _lastScreenShotView.frame.size.width)];
        [_backgroundView insertSubview:_lastScreenShotView belowSubview:_blackMask];
        
    }else if (recoginzer.state == UIGestureRecognizerStateEnded){        
        if (touchPoint.x - _startTouch.x > 50) {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:kContentWidth];
            } completion:^(BOOL finished) {
                [self dismissControllerAnimated:PresentAnimatedStateNone];
                _isMoving = NO;
                if ([self respondsToSelector:@selector(didBackGestureEndHandle)]) {
                    [self performSelector:@selector(didBackGestureEndHandle)];
                }
            }];
        }
        else
        {            
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:0];
            } completion:^(BOOL finished) {
                _isMoving = NO;
                _backgroundView.hidden = YES;
            }];
        }
        return;        
    }else if (recoginzer.state == UIGestureRecognizerStateCancelled){        
        [UIView animateWithDuration:0.3 animations:^{
            [self moveViewWithX:0];
        } completion:^(BOOL finished) {
            _isMoving = NO;
            _backgroundView.hidden = YES;
        }];
        return;
    }
    
    if (_isMoving) {
        [self moveViewWithX:touchPoint.x - _startTouch.x];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)recognizer
{
    CGPoint p = [recognizer locationInView: self.view];
    if (p.x > 20.f || (toolsBottomBar && p.y > toolsBottomBar.frame.origin.y)) {
        return NO;
    }
    return !CGRectContainsPoint(noGestureRecognizerRect, p);
}
#pragma mark - NightModeChangedDelegate
-(void) nightModeChanged:(BOOL) night
{
    self.view.backgroundColor = [UIColor colorWithHexValue:night?0xFF2D2E2F:0xFFF8F8F8];
    toolsBottomBar.backgroundColor = self.view.backgroundColor;
    _topBarBGImg.image = [UIImage imageNamed:night ? @"navBg_night" : @"navBg"];
    backGView.backgroundColor = [UIColor colorWithHexValue:night?0xFF2D2E2F:0xFFF8F8F8];
    
    if (IOS7)
    {
        if (night) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        }
        else{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        }
    }
}

// 手势返回的处理函数
- (void)didBackGestureEndHandle
{
    NSLog(@"手势返回：%s", __func__);
}


#pragma mark - UIViewControllerTransitioningDelegate
// ios7之后的controller  present/dismiss之间的转场动画
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [PresentAnimation new];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [DismissAnimation new];
}

// present/dismiss之间的交互转场动画
- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator
{
    return  nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator
{
   return _interactive.interacting ? _interactive : nil;
}

#pragma mark - UINavigationControllerDelegate
// 动画特效
// ios7 last controller Push/Pop 之间的转场动画，非交互自定义
// 这个代码暂时用不到
- (id<UIViewControllerAnimatedTransitioning>) navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    
    /**
     *  typedef NS_ENUM(NSInteger, UINavigationControllerOperation) {
     *     UINavigationControllerOperationNone,
     *     UINavigationControllerOperationPush,
     *     UINavigationControllerOperationPop,
     *  };
     */
    //push的时候用我们自己定义的customPush
    if (operation == UINavigationControllerOperationPush) {
//        return customPush;
    }
    else if (operation == UINavigationControllerOperationPop) {
//        return customPop;
    }
    return nil;
}
@end