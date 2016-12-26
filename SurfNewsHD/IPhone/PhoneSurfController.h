//
//  PhoneSurfController.h
//  SurfNewsHD
//
//  Created by apple on 13-6-4.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThemeMgr.h"

typedef enum {
    
    
    SNState_TopBar = 1,             // 顶部栏包含分割线
    SNState_TopBar_Title = 1 << 1,  // 顶部栏标题(居中显示)
    SNState_TopBar_GoBack_White = 1 << 2,   // 顶部栏返回按钮
    SNState_TopBar_GoBack_Gray = 1 << 3,    // 顶部栏返回按钮(默认)
    SNState_TopBar_NotBackgroundImage = 1 << 4, // Topbar 没有背景图片
    SNState_GestureGoBack = 1 << 5,         // 手势返回
    
    
    
    // 历史遗留代码
    // root界面拥有标题，分界线
    PhoneSurfControllerStateRoot = (SNState_TopBar | SNState_TopBar_Title),
    
    // 非root界面拥有标题，分界线，支持顶部手势返回
    PhoneSurfControllerStateTop = (SNState_TopBar |
                                   SNState_TopBar_Title |
                                   SNState_GestureGoBack |
                                   SNState_TopBar_GoBack_Gray),
    
    // 子界面没有任何背景
    PhoneSurfControllerStateNone = 0,
    
    // 子界面没有任何背景，只支持顶部手势返回
    PhoneSurfControllerStateDragOnly = SNState_GestureGoBack,
    
    
} PhoneSurfControllerState;

typedef enum {
    PresentAnimatedStateNone = 0,           // 没有动画
    PresentAnimatedStateFromRight = 3,      // 从右往左

} PresentAnimatedState;

@interface PhoneSurfController : UIViewController<UIGestureRecognizerDelegate,NightModeChangedDelegate>
{
    //点击事件专有
    UIImageView *_lastScreenShotView;
    UIView *_backgroundView;
    UIView *_blackMask;
    CGPoint _startTouch;
    BOOL _isMoving;
    float _startBackViewX;
    CGRect noGestureRecognizerRect; //不响应拖地事件，用于有按钮

    
    UIView *toolsBottomBar;

    
    
    UIButton *miniButton;
@public
    UIView *backGView;
}

@property(nonatomic,readonly) CGFloat StateBarHeight; // 默认45
@property (nonatomic) PhoneSurfControllerState titleState;

//注：在IOS7之后，会在SurfInteractive类中，通过KVC调用
@property (nonatomic) CGRect noGestureRecognizerRect;
//present
- (void)presentController:(UIViewController *)viewController animated:(PresentAnimatedState)state;
- (void)dismissControllerAnimated:(PresentAnimatedState)state;
- (void)dismissBackController;
- (void)didBackGestureEndHandle;// 提供子类实现（继承函数），用来实现右滑手势返回之后处理函数（类似返回通知函数）
//- (void)actionGestureRecognizer:(float)y;

// 之前代码不灵活，有的地方需要返回按钮，有的不需要，就很悲催了 by xuxg
// 也会因为没有返回按钮导致dismissBackController 函数不被调用。
- (void) initBottomToolsBar:(BOOL)isNeedBackButton;
- (UIView *)getBottomToolsBar;
- (UIView *)addBottomToolsBar;
- (BOOL)isSupportGestureGoBack; // 是否支持手势返回

/**
 *  顶部TabBar,如果你的没有包含SNState_TopBar，将返回nil;
 *
 *  @return TopBar
 */
- (UIView *)topBarView;
- (UIButton*)titleView;
- (UIButton*)topGoBackView;

- (void)addMiniKeyBoard;
- (void)dismissMiniKeyBoard;
- (void)KeyboardReturn:(id)sender;

@end
