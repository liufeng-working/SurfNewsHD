 //
//  SNToolBar.m
//  SurfNewsHD
//
//  Created by yuleiming on 14-7-11.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "SNToolBar.h"
#import "FavsManager.h"
#import "SliderSwitch.h"
#import "AppSettings.h"
#import "PhoneShareView.h"
#import "OAuth2Client.h"
#import "AppDelegate.h"
#import "FileUtil.h"
#import "UIView+NightMode.h"
#import <MessageUI/MessageUI.h>
#import "ContentShareController.h"
#import "PhoneSinaWeiboUserFriendsController.h"
#import "FirstRunView.h"
#import "ThreadsManager.h"


#define energyBtn_E_Tag 50


typedef enum {
    SNToolBarStateNormal,
    SNToolBarStateAnimatingToNormal,
    SNToolBarStateAnimatingToFullScreen,
    SNToolBarStateFullScreen
} SNToolBarState;



typedef enum {
    
    SNTBBtnType_Back,       // 返回按钮
    SNTBBtnType_Share,      // 分享按钮
    SNTBBtnType_Comment,    // 评论
    SNTBBtnType_More,       // 更多
    SNTBBtnType_Energy,     // 正能量
    SNTBBtnType_Collect,    // 收藏
    SNTBBtnType_Report,     // 举报
    

    
    // 美女频道
    SNTBBtnType_Belle_Praise,   // 点赞按钮
    SNTBBtnType_Belle_Download, // 下载按钮
    
    
    
} SNToolBarButtonType;


@interface SNToolBar () <SliderSwitchDelegate>
{
    SNToolBarState      mState;
    SNToolBarType       mType;
    __weak ThreadSummary*      mThreadSummary;
    

    __weak UIView*      mIconsView;
    NSMutableDictionary *mToolsBtns;

    
    
    // 二级界面—— 设置界面
    __weak UIView*         mSettingView;
    __weak UIImageView *mFontImageView;
    __weak UILabel *mFontSizeTitle;

    __weak SliderSwitch *mFontSwicth; // 字体设置开关
    
    
    // 二级界面————微博选择界面
    __weak UIView* mSelectShareView;
    
    id      shareInfo;      // 分享的object
    long    m_energy;
    BOOL    m_shareEnergy;  // 能量值分享
    
    
    // 评论按钮红点标记
    __weak CATextLayer *_redPoint;
}

@end


@implementation SNToolBar

- (id)initWithToolBarType:(SNToolBarType)type
                   thread:(ThreadSummary*)ts
{
    self = [super init];
    if (self) {
        mType = type;
        mThreadSummary = ts;
        mToolsBtns = [NSMutableDictionary dictionaryWithCapacity:5];
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        CGFloat toolBarHeight = screenBounds.size.height;
        
        if(!IOS7) {
            toolBarHeight -= [[UIApplication sharedApplication] statusBarFrame].size.height;
        }
        
        self.frame = CGRectMake(0, 0, screenBounds.size.width, toolBarHeight);
        mState = SNToolBarStateNormal;
        
        UIView* icons = [[UIView alloc]initWithFrame:CGRectMake(0, self.bounds.size.height - [SNToolBar normalHeight], self.bounds.size.width, [SNToolBar normalHeight])];
        [self addSubview:icons];
        mIconsView = icons;
        
        
        //增加tap事件
        UITapGestureRecognizer *singleFingerTap = 
        [[UITapGestureRecognizer alloc] initWithTarget:self 
                                                action:@selector(handleSingleTap:)];
        [self addGestureRecognizer:singleFingerTap];
        [self loadToolsBarButtons:mType thread:mThreadSummary];
        
        // 初始化夜间模式
        [self viewNightModeChanged:[[ThemeMgr sharedInstance] isNightmode]];
    }
    return self;
}

/**
 *  获取底部工具栏按钮
 *
 *  @param type 按钮类型
 *
 *  @return 返回按钮
 *  注：如果这些按钮不能满足需要，就在这里继续添加按钮类型
 */
-(UIButton*)getToolBarButton:(SNToolBarButtonType)type
{
    id btnKey = @(type);
    UIButton *btn = [mToolsBtns objectForKey:btnKey];
    if (!btn) {
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [mToolsBtns setValue:btn forKey:btnKey];
        
        if(type == SNTBBtnType_Back)
        {
            // 返回
            [btn setBackgroundImage:[UIImage imageNamed:@"backBar"]
                               forState:UIControlStateNormal];
            [btn addTarget:self
                    action:@selector(goBackButtonClicked:)// 回调父类中的函数
          forControlEvents:UIControlEventTouchUpInside];
        }
        else if (type == SNTBBtnType_Share)
        {
            // 分享
            [btn setBackgroundImage:[UIImage imageNamed:@"shareBar.png"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"shareBar_highlighted.png"] forState:UIControlStateHighlighted];
            [btn addTarget:self
                    action:@selector(shareButtonClicked:)
          forControlEvents:UIControlEventTouchUpInside];
        }
        else if (type == SNTBBtnType_Comment)
        {
            // 评论
            UIImage *btnImg = [UIImage imageNamed:@"comment_toolBar"];
            UIImage * btnImgH=[UIImage imageNamed:@"comment_toolBar_highlighted.png"];
            
            [btn setBackgroundImage:btnImg forState:UIControlStateNormal];
            [btn setBackgroundImage:btnImgH forState:UIControlStateHighlighted];
            [btn addTarget:self
                    action:@selector(newsCommentButtonClicked:)
          forControlEvents:UIControlEventTouchUpInside];
            
            // 添加小红原点
            CGFloat pW = 10.f, pH = 10.f;
            CGFloat pX = btnImg.size.width-pW-13;
            CGFloat pY = 8.f;
            UIFont* f = [UIFont systemFontOfSize:8];
            CATextLayer *redPoint = [CATextLayer layer];
            _redPoint = redPoint;
            redPoint.fontSize = f.pointSize;
            redPoint.font = (__bridge CFTypeRef)f.fontName;
            redPoint.alignmentMode = kCAAlignmentCenter;
            redPoint.contentsGravity = kCAGravityCenter;
            redPoint.frame = CGRectMake(pX, pY, pW, pH);
            redPoint.cornerRadius = pH / 2;
            redPoint.contentsScale = [[UIScreen mainScreen] scale];
            redPoint.backgroundColor = [UIColor redColor].CGColor;
            redPoint.foregroundColor = [UIColor whiteColor].CGColor;
            [btn.layer addSublayer:redPoint];
        }
        else if (type == SNTBBtnType_More)
        {
            // 更多
            [btn setBackgroundImage:[UIImage imageNamed:@"moreBar"] forState:UIControlStateNormal];
            [btn addTarget:self
                    action:@selector(moreButtonClicked:)
          forControlEvents:UIControlEventTouchUpInside];
        }
        else if (type == SNTBBtnType_Energy)
        {
            // 正能量
            [btn setTag:energyBtn_E_Tag];
            UIImage *img = [UIImage imageNamed:@"default_big"];
            [btn setImage:img forState:UIControlStateNormal];
            [btn addTarget:self
                    action:@selector(clickEnergyBt:)
          forControlEvents:UIControlEventTouchUpInside];
        }
        else if(type == SNTBBtnType_Belle_Praise)
        {
            // 美女图片点赞
            UIImage *btnImg = [UIImage imageNamed:@"menu_praise"];
            [btn setBackgroundImage:btnImg
                           forState:UIControlStateNormal];
            [btn addTarget:self
                    action:@selector(clickLikeBelleGirlBt:)
          forControlEvents:UIControlEventTouchUpInside];
        }
        else if(type == SNTBBtnType_Belle_Download)
        {
            // 美女图片下载
            UIImage *btnImg = [UIImage imageNamed:@"beauty_cell_menu_download"];
            [btn setBackgroundImage:btnImg
                           forState:UIControlStateNormal];
            [btn addTarget:self
                    action:@selector(clickBelleDownBtn:)
          forControlEvents:UIControlEventTouchUpInside];
        }
        else if(type == SNTBBtnType_Collect) {
            // 收藏
            [btn addTarget:self
                    action:@selector(collectButtonClick:)
          forControlEvents:UIControlEventTouchUpInside];
            [self changeCollectBtnState:btn];
        }else if(type == SNTBBtnType_Report) {
            // 举报
            [btn setBackgroundImage:[UIImage imageNamed:@"tb_report"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"tb_report_highlighted"] forState:UIControlStateHighlighted];
            [btn addTarget:self
                    action:@selector(reportButtonClicked:)
          forControlEvents:UIControlEventTouchUpInside];
        }
        else {
            DJLog(@"没有自定义按钮类型，需要添加");
        }
    }
    return btn;
}


/**
 *  构建工具栏按钮布局
 */
-(void)buildBoolbarButtonsLayout:(SNToolBarType)toolBarType
{
    CGFloat w = CGRectGetWidth(mIconsView.bounds);
    CGFloat h = CGRectGetHeight(mIconsView.bounds);
    
    CGFloat space = 0;
    CGFloat btnW = 64.f, btnH = 49.f;
    CGFloat btnY = (h - btnH) / 2;
    NSArray *btns = [self getToolsBarButtons:toolBarType];
    if(toolBarType == SNToolBarTypeNews ||
       toolBarType == SNToolBarTypeWeb){
        // 评论|正能量|分享|收藏|举报
        space = (w - btnW * 5) / 4;
    }
    else if(toolBarType == SNBelleGirlType){
        // 返回|分享|点赞|下载|更多
        space = (w - btnW * 5) / 4;
    }
    
    [btns enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setFrame:CGRectMake(idx*(space+btnW), btnY, btnW, btnH)];
    }];
}
/**
 *  加载工具栏按钮
 *
 *  @param type 工具栏类型
 *  @param ts   新闻帖子数据
 */
-(void)loadToolsBarButtons:(SNToolBarType)type thread:(ThreadSummary*)ts
{
    mThreadSummary = ts;
    
    // 删除按钮和父类的关系
    SEL removeSuperView = @selector(removeFromSuperview);
    [[mToolsBtns allValues] makeObjectsPerformSelector:removeSuperView];

    
    // 添加按钮控件
    NSArray *btns = [self getToolsBarButtons:type];
    [btns enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [mIconsView addSubview:obj];
    }];

    // 自动布局
    [self buildBoolbarButtonsLayout:type];
    
    // 对按钮做业务处理
    if (type == SNBelleGirlType) // 美女频道
    {
        // 返回|分享|点赞|下载|更多
        
        
        // 检查点赞按钮状态
        [self clickBeautyPraise];
        
    }
    else if (type == SNToolBarTypeNews)    // 新闻正文
    {
        // 检测是否支持新闻评论
        [self clickCommentButton:ts];
        
        // 检测正负能量状态
        [self clickEnergyState:ts];
        
        UIButton *collect =
        [self getToolBarButton:SNTBBtnType_Collect];
        [self changeCollectBtnState:collect];
    }
    else if (type == SNToolBarTypeWeb) {

        // 检测是否支持新闻评论
        [self clickCommentButton:ts];
        
        // 检测正负能量状态
        [self clickEnergyState:ts];
    }
}

/**
 *  获取按钮数组
 *
 *  @param type 工具栏类型
 *
 *  @return
 */
-(NSArray*)getToolsBarButtons:(SNToolBarType)type
{
    NSArray *btns = nil;
    if (type == SNToolBarTypeNews ||
        type == SNToolBarTypeWeb) {
        // 评论|正能量|收藏|分享|举报
        id comment = [self getToolBarButton:SNTBBtnType_Comment];
        id energy = [self getToolBarButton:SNTBBtnType_Energy];
        id collect = [self getToolBarButton:SNTBBtnType_Collect];
        id share = [self getToolBarButton:SNTBBtnType_Share];
        id report = [self getToolBarButton:SNTBBtnType_Report];
        btns = @[comment,energy,collect,share,report];
    }
    else if (type == SNBelleGirlType) {
        // 返回|分享|点赞|下载|更多
        id back = [self getToolBarButton:SNTBBtnType_Back];
        id share = [self getToolBarButton:SNTBBtnType_Share];
        id praise = [self getToolBarButton:SNTBBtnType_Belle_Praise];
        id down = [self getToolBarButton:SNTBBtnType_Belle_Download];
        id more = [self getToolBarButton:SNTBBtnType_More];
        btns = @[back, share,praise,down,more];
    }
    return btns;
}



-(void)changeBarType:(SNToolBarType)type thread:(ThreadSummary*)ts;
{
    mThreadSummary = ts;
    if (mType != type) {
        mType = type;
    }
}
// 刷新工具栏
-(void)refreshToolsBar
{
    [self loadToolsBarButtons:mType thread:mThreadSummary];
}


-(void)refreshCommentItem
{
    // 检测是否支持新闻评论
    [self clickCommentButton:mThreadSummary];
}
//正文状态下再判断一次正在浏览的正文能量
- (void)refreshToolsBarWithSelectThread:(ThreadSummary *)selectThread
{
//    if (mType == SNToolBarTypeNews) {
//        [mNewsBottons makeObjectsPerformSelector:@selector(removeFromSuperview)];
//        [mNewsWithEnergyBottons makeObjectsPerformSelector:@selector(removeFromSuperview)];
//        
//        if (selectThread){
//            if ([[FavsManager sharedInstance] isEnergyInTs:selectThread]) {
//                for (UIView *v in mNewsWithEnergyBottons) {
//                [mIconsView addSubview:v];
//            }
//            }
//            else
//            {
//                for (UIView *v in mNewsBottons) {
//                    [mIconsView addSubview:v];
//                }
//            }
//        }
//        
//        BOOL isCollect = NO;
//        if (selectThread) {
//            isCollect = [[FavsManager sharedInstance] isThreadInFav:selectThread];
//        }
//        [self setStar:isCollect];
//    }
}


// 获取toolBar类型
-(SNToolBarType)toolBarType
{
    return mType;
}

/**
 *  toolsBar 处理点击事件
 *
 *  @param recognizer <#recognizer description#>
 */
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    
    if(mState == SNToolBarStateFullScreen) {
        [self animateToNormal];
        [self hiddenSettingBar:YES];
        [self hiddenSelectShareView:YES];
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if(mState == SNToolBarStateNormal)
    {
        CGFloat h = [SNToolBar normalHeight];
        return CGRectContainsPoint(CGRectMake(0, self.bounds.size.height - h, self.bounds.size.width, h), point);
    } else {
        return YES;
    }
}

+ (CGFloat)normalHeight
{
    return 44;
}

-(void)setShareType:(ShareWeiboType)type withInfo:(id)info
{
//    shareInfo = info;
//    [self animateToNormal];
//    [self shareWeibo:type];
//    m_shareEnergy = NO;
}

-(void)setShareType:(ShareWeiboType)type energy:(long)value{
//    m_energy = value;
//    m_shareEnergy = YES;
//    [self shareWeibo:type];
}

- (void)animateToNormal
{
    if(mState == SNToolBarStateNormal
       || mState == SNToolBarStateAnimatingToNormal)
        return;
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         //背景色
                         self.backgroundColor = [UIColor clearColor];
                         
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             mState = SNToolBarStateNormal;
                         }
                     }];
    mState = SNToolBarStateAnimatingToNormal;
}

- (void)animateToFullScreen
{
    if(mState == SNToolBarStateFullScreen ||
       mState == SNToolBarStateAnimatingToFullScreen)
        return;
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         //背景色
                         self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];

                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             mState = SNToolBarStateFullScreen;
                         }
                     }];
    mState = SNToolBarStateAnimatingToFullScreen;
}


-(void)goBackButtonClicked:(id)sender
{
    if ([_deletage respondsToSelector:@selector(toolBarActionExit)]) {
        [_deletage toolBarActionExit];
    }
}

//美女频道
- (void)clickBelleDownBtn:(id)sender{
    if ([_deletage respondsToSelector:@selector(toolBarActionBelleGirlDown:)]) {
        [_deletage toolBarActionBelleGirlDown:mThreadSummary];
    }
}

- (void)clickBelleMoreBt:(id)sender{
    if ([_deletage respondsToSelector:@selector(toolBarActionBelleMore:)]) {
        [_deletage toolBarActionBelleMore:mThreadSummary];
    }
}

- (void)setLikeGirlBt
{
    // 对按钮做业务处理
    if (mType == SNBelleGirlType) { // 美女频道
        [self clickBeautyPraise];
    }
}

- (void)clickLikeBelleGirlBt:(id)sender{
    [self setLikeGirlBt];
    
    if ([_deletage respondsToSelector:@selector(toolBarActionLikeBelleGirl:)]) {
        [_deletage toolBarActionLikeBelleGirl:mThreadSummary];
    }
}


-(void)shareButtonClicked:(id)sender
{
    if ([_deletage respondsToSelector:@selector(toolBarActionShare:)]) {
        [_deletage toolBarActionShare:mThreadSummary];
    }
}

/**
 *  新闻评论按钮点击事件
 *
 *  @param sender UIButton对象
 */
-(void)newsCommentButtonClicked:(id)sender
{
    //TODO: 跳转到新闻评论界面
    if ([_deletage respondsToSelector:@selector(toolBarActionNewComment:)]) {
        [_deletage toolBarActionNewComment:mThreadSummary];
    }
}

- (void)clickEnergyBt:(id)sender
{
    if (mThreadSummary) {
        if ([_deletage respondsToSelector:@selector(toolBarActionEnergy:)]) {
            [_deletage toolBarActionEnergy:mThreadSummary];
        }
    }
}


-(void)clickEnergyState:(ThreadSummary *)ts
{
    // 检测是否支持新闻评论
    UIButton* energy = [self getToolBarButton:SNTBBtnType_Energy];
    [energy setEnabled:ts.is_energy==1];
    
    if (1 == ts.is_energy) {
        [energy setEnabled:YES];
        
        BOOL isPo = ts.positive_energy > labs(ts.negative_energy);
        UIImage *img = [UIImage imageNamed:isPo?@"positive_bigbig":@"negative_bigbig"];
        [energy setImage:img forState:UIControlStateNormal];
    }
    else {
        [energy setEnabled:NO];
    }
    
}
// 检测评论按钮状态
-(void)clickCommentButton:(ThreadSummary *)ts
{
    // 检测是否支持新闻评论
    UIButton* comment = [self getToolBarButton:SNTBBtnType_Comment];
    if (ts.isComment) {
        [comment setEnabled:YES];// 检查新闻是否支持评论
        NSInteger commentCount = [ts comment_count];
        commentCount = commentCount > 99 ? 99 : commentCount;
        [_redPoint setHidden:(commentCount <= 0)];
        _redPoint.string = [NSString stringWithFormat:@"%@",@(commentCount)];
    }
    else {
        [comment setEnabled:NO];// 检查新闻是否支持评论
        [_redPoint setHidden:YES];
    }
}

// 检查美女频道是否点赞
-(void)clickBeautyPraise
{
    BOOL isNight = [[ThemeMgr sharedInstance] isNightmode];
    UIButton *praise = [self getToolBarButton:SNTBBtnType_Belle_Praise];
    if ([[ThreadsManager sharedInstance] isThreadRated:mThreadSummary]) {
        [praise setBackgroundImage:(isNight?[UIImage imageNamed:@"menu_praise_on"]:[UIImage imageNamed:@"menu_praise_day_on"]) forState:UIControlStateNormal];
    }
    else{
        [praise setBackgroundImage:(isNight?[UIImage imageNamed:@"menu_praise"]:[UIImage imageNamed:@"menu_praise_day"]) forState:UIControlStateNormal];
        
    }
}
-(void)moreButtonClicked:(id)sender
{
    [self showFontsSettingView];
}

// 设置页面字体
-(void)showFontsSettingView
{
    if (mType == SNBelleGirlType) {
        if ([_deletage respondsToSelector:@selector(toolBarActionBelleMore:)]) {
            [_deletage toolBarActionBelleMore:mThreadSummary];
        }
    }
    else {
        if(mState == SNToolBarStateFullScreen
           || mState == SNToolBarStateAnimatingToFullScreen) {
            [self animateToNormal];
            [self hiddenSettingBar:YES];        // 隐藏更多二级菜单
        }
        else {
            [self animateToFullScreen];
            [self buildSettingView];
            [self hiddenSettingBar:NO];// 移动到屏幕可视区域
        }
    }
}

// 创建一个设置窗口， 用一次创建一次，不用就删除
-(void)buildSettingView
{
    if (mSettingView) {
        return;
    }
    
    // 字号创建
    CGFloat settingHeight = 100.f;
    CGFloat w = CGRectGetWidth(self.bounds);
    CGFloat h = CGRectGetHeight(self.bounds);
    

    CGRect bgVR = CGRectMake(0.f, h, w, settingHeight);
    UIView *dockView = [[UIView alloc] initWithFrame:bgVR];
    mSettingView = dockView;
    [self addSubview:dockView];

    
    UIImage *temp = [UIImage imageNamed:@"more_fontFlag"];
    CGFloat btnW = temp.size.width;
    CGFloat btnH = temp.size.height;
    UIFont *font = [UIFont systemFontOfSize:15.0f];

    // 字体图片
    {
        UIImageView *fontSize = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, btnW, btnH)];
        [fontSize setUserInteractionEnabled:NO];
        mFontImageView = fontSize;
        [mSettingView addSubview:fontSize];
        
        // 字体说明文字
        CGFloat sizeW = 70.f, sizeH = 25.f;
        CGFloat sizeX = fontSize.center.x - sizeW / 2;
        CGFloat sizeY = fontSize.frame.origin.y + btnH;
        CGRect sizeRect = CGRectMake(sizeX, sizeY,sizeW, sizeH);
        UILabel *sizeLabel = [[UILabel alloc] initWithFrame:sizeRect];
        sizeLabel.text = @"字体大小";
        sizeLabel.backgroundColor = [UIColor clearColor];
        [sizeLabel setTextAlignment:NSTextAlignmentCenter];
        sizeLabel.font = font;
        [sizeLabel setUserInteractionEnabled:NO];
        mFontSizeTitle = sizeLabel;
        [mSettingView addSubview:sizeLabel];
        
        
        CGFloat swicthH = 40.0f;
        CGFloat swicthY = (mFontSizeTitle.frame.origin.y + mFontSizeTitle.frame.size.height- mFontImageView.frame.origin.y - swicthH)/2 + mFontImageView.frame.origin.y;
        SliderSwitch *fontSwicth = [SliderSwitch new];
        [fontSwicth setDelegate:self];
        [fontSwicth setModelChange:TEXT_MODEL];
        [fontSwicth setFrameHorizontal:CGRectMake(100.0f, swicthY, 200.0f, swicthH) numberOfFields:4 withCornerRadius:4.0];
        [fontSwicth setText:@"小" forTextIndex:1];
        [fontSwicth setText:@"中" forTextIndex:2];
        [fontSwicth setText:@"大" forTextIndex:3];
        [fontSwicth setText:@"极大" forTextIndex:4];
        [fontSwicth refresh];
        [fontSwicth setTextFont:[UIFont systemFontOfSize:14]];
        mFontSwicth = fontSwicth;
        [mSettingView addSubview:fontSwicth];
    }

    [self changedSettingNightMode:NO]; // 设置夜间模式
}

- (void)changedSettingNightMode:(BOOL)isNight
{
    if (isNight) {
        UIColor *color = [UIColor colorWithHexValue:0xFF2D2E2F];
        [mSettingView setBackgroundColor:color];
        [mFontSizeTitle setTextColor:[UIColor whiteColor]];
        [mFontImageView setImage:[UIImage imageNamed:@"more_fontFlag_n"]];
        
  
    }
    else {
        UIColor *color = [UIColor colorWithHexValue:0xFF999292];
        [mSettingView setBackgroundColor:[UIColor whiteColor]];
        [mFontSizeTitle setTextColor:color];
        [mFontImageView setImage:[UIImage imageNamed:@"more_fontFlag"]];
    }
}

/**
 *  改版收藏按钮状态
 */
-(void)changeCollectBtnState:(UIButton*)collectBtn
{
    if (!mThreadSummary) return;
    
    
    UIImage *img = [UIImage imageNamed:self.isCollect?@"collectionedBar":@"collectionBar"];
    [collectBtn setImage:img forState:UIControlStateNormal];
}

-(void)refreshButtonHandle:(id)sender
{
    if ([_deletage respondsToSelector:@selector(toolBarActionRefresh)]) {
        [_deletage toolBarActionRefresh];
    }
}

#pragma mark-- SliderSwitchDelegate
-(void)slideView:(SliderSwitch *)slideswitch switchChangedAtIndex:(NSUInteger)index
{
    if (TEXT_MODEL == slideswitch.modelChange) {
        if ([_deletage respondsToSelector:@selector(toolBarActionFontSizeChanged:)]) {
            float fontSize = kWebContentSize1;
            if (index == 1) {
                fontSize = kWebContentSize2;
            }
            else if (index == 2) {
                fontSize = kWebContentSize3;
            }
            else if (index == 3) {
                fontSize = kWebContentSize4;
            }
            [AppSettings setFloat:fontSize
                                            forKey:FLOATKEY_ReaderBodyFontSize];
            [_deletage toolBarActionFontSizeChanged:fontSize];
        }
    }
    
    [self animateToNormal];
    [self hiddenSettingBar:YES];
}


/**
 *  更多->夜间模式,切换按钮点击事件
 *
 *  @param sender
 */
-(void)nightModelButtonClick:(id)sender
{
    ThemeMgr *mgr = [ThemeMgr sharedInstance];
    BOOL isNight = [mgr isNightmode];
    [mgr changeNightmode:!isNight];
    [self changedSettingNightMode:!isNight];
    
    
    [self animateToNormal];
    [self hiddenSettingBar:YES];
}

/**
 *  更多->收藏按钮点击事件
 */

-(void)collectButtonClick:(id)sender
{
    
    if (self.isMySelect == YES) {
        [PhoneNotification autoHideWithText:@"点太快啦，稍微休息会吧"];
        self.isMySelect = NO;
        return;
    }
    
    
    if (!mThreadSummary) {
        return;
    }
    
//    FavsManager *fav = [FavsManager sharedInstance];
//    BOOL isCollect = [fav isThreadInFav:mThreadSummary];
    if (self.isCollect)
    {
        
        id req = [SurfRequestGenerator unSubscribeCollect:mThreadSummary];
        GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:req];
        [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error){
//            BOOL isSucceed = NO;
            self.isMySelect = YES;
            if(!error)
            {
                NSString* body = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
                SurfJsonResponseBase *res = [SurfJsonResponseBase objectWithKeyValues:body];
//                isSucceed = [res.res.reCode isEqualToString:@"1"];
                if ([res.res.reCode isEqualToString:@"1"])
                {
                    [PhoneNotification autoHideWithText:@"取消收藏成功"];
                    self.isCollect = NO;
                }
                else if ([res.res.reCode isEqualToString:@"2"])
                {
                    
                }
                else if ([res.res.reCode isEqualToString:@"0"])
                {
                    [PhoneNotification autoHideWithText:@"取消收藏失败"];
                }
            }
            [self changeCollectBtnState:sender];
        }];

    }
    else
    {
        UserInfo *userInfo = [[UserManager sharedInstance] loginedUser];
        if (userInfo == nil) {
            [_deletage toolBarGotoLogin];
            return;
        }
        
//        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:userInfo.userID,@"uid",[NSString stringWithFormat:@"%ld",mThreadSummary.threadId],@"Id",[NSString stringWithFormat:@"%ld",mThreadSummary.channelId],@"Coid",[NSString stringWithFormat:@"%ld",mThreadSummary.type],@"Type", @"addCollect",@"method",nil];
        id req = [SurfRequestGenerator addCollect:mThreadSummary];
        GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:req];
        [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error){
//            BOOL isSucceed = NO;
            self.isMySelect = YES;
            if(!error)
            {
                NSString* body = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
                SurfJsonResponseBase *res = [SurfJsonResponseBase objectWithKeyValues:body];
                if ([res.res.reCode isEqualToString:@"1"])
                {
                    [PhoneNotification autoHideWithText:@"收藏成功"];
                    self.isCollect = YES;
                    
                }
                else if ([res.res.reCode isEqualToString:@"2"])
                {
                    [PhoneNotification autoHideWithText:@"已收藏"];
                    self.isCollect = YES;
                }
                else if ([res.res.reCode isEqualToString:@"0"])
                {
                    [PhoneNotification autoHideWithText:@"收藏失败"];
                }
            }
            [self changeCollectBtnState:sender];
        }];
    }
    
}

-(void)reportButtonClicked:(UIButton*)btn
{
    if (!mThreadSummary) {
        return;
    }
    
    // TODO: 举报
    if ([_deletage respondsToSelector:@selector(toolBarActionReport:)]) {
        [_deletage toolBarActionReport:mThreadSummary];
    }
}
- (void)hiddenSettingBar:(BOOL)ishidden
{
    if (mSettingView == nil) {
        return;
    }
    
    [[mIconsView subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIButton class]]) {
            [obj setUserInteractionEnabled:ishidden];
        }
    }];
    

    
    if (ishidden) {
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
            float settingH = CGRectGetHeight(mSettingView.bounds);
            mSettingView.frame = CGRectOffset(mSettingView.frame, 0.f, settingH);
        } completion:^(BOOL finished) {
            [mSettingView removeFromSuperview];
            mSettingView = nil;
        }];
    }
    else {
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
            float settingH = CGRectGetHeight(mSettingView.bounds);
            mSettingView.frame = CGRectOffset(mSettingView.frame, 0.f, -settingH);
        } completion:^(BOOL finished) {

        }];
    }
}

// 选择分享窗口
-(void)hiddenSelectShareView:(BOOL)hidden
{
    if (mSelectShareView == nil) {
        return;
    }
    
    // 让toolBar的按钮失去焦点或设置焦点
    [[mIconsView subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIButton class]]) {
           [obj setUserInteractionEnabled:hidden];
        }
    }];
    
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction;
    if (hidden) {
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:options
                         animations:^{
             float vH = CGRectGetHeight(mSelectShareView.bounds);
             mSelectShareView.frame = CGRectOffset(mSelectShareView.frame, 0.f, vH);
         } completion:^(BOOL finished) {
             [mSelectShareView removeFromSuperview];
             mSelectShareView = nil;
         }];
    }
    else {
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:options
                         animations:^{
             float vH = CGRectGetHeight(mSelectShareView.bounds);
             mSelectShareView.frame = CGRectOffset(mSelectShareView.frame, 0.f, -vH);
         } completion:nil];
    }
}


// 获取帖子的Logo图片
-(UIImage*)getThreadLogo:(ThreadSummary*)t
{
    UIImage *image = nil;
    if (t) {
        NSString *logoPath = [PathUtil pathOfThreadLogo:t];
        if ([FileUtil fileExists:logoPath]) {
            NSData *imgData = [NSData dataWithContentsOfFile:logoPath];
            image = [UIImage imageWithData:imgData];
        }
    }
    return image;
}

//提取正文图片
- (NSMutableArray *)getContentWebViewImg
{
    return [_deletage getContentImgArr];
}

// UIView 夜间模式切换
-(void)viewNightModeChanged:(BOOL)isNight
{
    if (mType == SNBelleGirlType) {
        if (mIconsView) {
            mIconsView.backgroundColor = [UIColor colorWithHexValue:isNight?0xFF2D2E2F:0xFFF8F8F8];
            [mIconsView setAlpha:1];
        }
        
        [self clickBeautyPraise];
    }
    else{
        if (mIconsView) {
            mIconsView.backgroundColor =
            [UIColor colorWithHexValue:isNight?0xFF2D2E2F:0xFFF8F8F8];
            [mIconsView setAlpha:1];
        }
    }
    
}

@end
