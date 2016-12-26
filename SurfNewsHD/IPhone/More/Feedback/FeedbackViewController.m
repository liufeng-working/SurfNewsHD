//
//  FeedbackViewController.m
//  SurfNewsHD
//
//  Created by Jerry Yu on 13-6-8.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "FeedbackViewController.h"
#import "UserManager.h"
#import "SurfRequestGenerator.h"
#import "GTMHTTPFetcher.h"
#import "NSString+Extensions.h"
#import "CustomAnimation.h"
#import "TQStarRatingView.h"
#import "CMCCFeedBack.h"
#import "DispatchUtil.h"


@interface FeedbackViewController ()

@end

//星星的个数
#define NumberOfStar          5
//与评论框相关UI的 宽度
#define COMMENTWIDTH          240.f
//APP推荐度 宽度
#define NameLabelWidth        75.f
//星星的宽度
#define StarWidth             160.f
//星星和分数的距离
#define StarANDScoreDis       3.f
//分数label的宽度
#define ScoreLabelWidth       39.f
//alertView tag值
#define SUCCESSFULALT_TAG     8768
//评论限制字数
#define MAXTEXTVIEWLENGTH     500
//分数的字体大小
#define ScoreFont             [UIFont systemFontOfSize:13];
//与星星相关的UI的 起始X坐标
#define StartX                (kContentWidth - SumWidth) / 2.0
//与评论框相关UI的 起始X坐标
#define COMMENTSTARTX         (kContentWidth - COMMENTWIDTH) / 2.0
//总宽度
#define SumWidth              (NameLabelWidth+StarWidth+ScoreLabelWidth+StarANDScoreDis)
//APP推荐度label的frame
#define StarFrame_Label1      CGRectMake(StartX, 10.0f, NameLabelWidth, 40.0f)
//使用满意度label的frame
#define StarFrame_Label2      CGRectMake(StartX, 45.0f, NameLabelWidth, 40.0f)
//分割线的frame
#define LineFrame             CGRectMake(StartX, 95.0f, SumWidth, 1.3f)
//第一行星星的frame
#define FirstStartFrame       CGRectMake(CGRectGetMaxX(StarFrame_Label1), 10.0f, StarWidth, 40.0f)
//第二行星星的frame
#define SecondStartFrame      CGRectMake(CGRectGetMaxX(StarFrame_Label2), 45.0f, StarWidth, 40.0f)
//输入框 frame
#define FEEDBACKTEXTVIEWFRAME CGRectMake(COMMENTSTARTX, 140, COMMENTWIDTH, 100)
//反馈意见 frame
#define CONTLABFRAME          CGRectMake(COMMENTSTARTX, 100, COMMENTWIDTH, 40)
//提交按钮 frame
#define SENDBTFRAME_PHONENUM  CGRectMake(COMMENTSTARTX, 270.0f, COMMENTWIDTH, 40.0f)

@implementation FeedbackViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.titleState = PhoneSurfControllerStateTop;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"意见反馈";
	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self initBgView];
    [self initFeedBackTextView];
    
    UserManager *manager = [UserManager sharedInstance];
    if (!manager.loginedUser) {
        isLogin = NO;
    }
    else {
        isLogin = YES;
    }
    
    _results = [NSMutableDictionary dictionaryWithCapacity:3];
    
    [self initButtons];
    [self initLab];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSNotificationCenter *notifyCenter = [NSNotificationCenter defaultCenter];
    
    [notifyCenter addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [notifyCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [notifyCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initLab
{
    if (!FirstLabel) {
        FirstLabel = [[UILabel alloc] initWithFrame:StarFrame_Label1];
        [FirstLabel setBackgroundColor:[UIColor clearColor]];
        [FirstLabel setText:@"APP推荐度"];
        FirstLabel.font = [UIFont systemFontOfSize:15.0f];
        [bgView addSubview:FirstLabel];
    }
    if (!SecondLabel) {
        SecondLabel = [[UILabel alloc] initWithFrame:StarFrame_Label2];
        [SecondLabel setBackgroundColor:[UIColor clearColor]];
        [SecondLabel setText:@"使用满意度"];
        SecondLabel.font = [UIFont systemFontOfSize:15.0f];
        [bgView addSubview:SecondLabel];
    }
    if (!Line) {
        Line = [[UIImageView alloc] initWithFrame:LineFrame];
        UIImage *timeImage = [UIImage imageNamed:@"moreCellLine"];
        [Line setImage:timeImage];
        [bgView addSubview:Line];
    }
    
    
    
    if (!contLab)
    {
        contLab = [[UILabel alloc] initWithFrame:CONTLABFRAME];
        [contLab setBackgroundColor:[UIColor clearColor]];
        [contLab setText:@"反馈意见:"];
        contLab.font = [UIFont systemFontOfSize:15.0f];
        [bgView addSubview:contLab];
    }
}

- (void)initButtons
{
    UIButton *sendBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendBt setFrame:SENDBTFRAME_PHONENUM];
    [sendBt setBackgroundImage:[UIImage imageNamed:@"login_register_button"]forState:UIControlStateNormal];
    [sendBt setTitle:@"提交" forState:UIControlStateNormal];
    [sendBt addTarget:self action:@selector(sendCMCCRequst:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:sendBt];
}

- (void)clickCancelBt
{
    [self dismissControllerAnimated:PresentAnimatedStateFromRight];
}


// 发送移动意见反馈
-(void)sendCMCCRequst:(UIButton*)btn
{
#if TARGET_IPHONE_SIMULATOR
    
    [PhoneNotification autoHideWithText:@"模拟器不支持评分"];
    
#else
    
    if (_starRatingView.selectStar <= 0) {
        [PhoneNotification autoHideWithText:@"您还没有给APP推荐度评分"];
        return;
    }
    else if(_starRatingViewSecond.selectStar <= 0){
        [PhoneNotification autoHideWithText:@"您还没有进行使用满意度评分"];
        return;
    }
    
    UserInfo *userInfo = [[UserManager sharedInstance] loginedUser];
    NSString *phoneNum;
    NSString *userName;
    if (userInfo){
        phoneNum = userInfo.phoneNum;
        userName = userInfo.userDes.nickName;
    }


// app key 申请网址：http://fb.kfz.so/feedback/apply
#if ENTERPRISE
    NSString *const appkey = @"8a5cb8f7229fb9ba";// 企业
#else 
    
    // bundleId = com.c-platform.SurfNews
    NSString *appkey = @"14c0072f9df5e805";
    
    NSString* bundleID = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString*) kCFBundleIdentifierKey];
    if ([bundleID isEqualToString:@"com.chinamobile.SurfNews"]) {
        // bundleId = com.chinamobile.SurfNews
        appkey = @"6cbceac82de0c900";
    }
#endif
    
    
    // 用户信息
    CMCCFBUserInfo *fbUserInfo =
    [CMCCFBUserInfo initWithPhone:phoneNum
                             name:userName];
    
    // 软件信息
    __block typeof(self)weakSelf = self;
    CMCCAppInfo *cmccAppInfo = [CMCCAppInfo initWithAppKey:appkey];
    
   
    [btn setEnabled:NO];
    
    // 意见反馈
    if (feedBackTextView.text && ![feedBackTextView.text isEmptyOrBlank]) {
        
        CMCCFBInfo *fbInfo =
        [CMCCFBInfo initWithType1:@"全部"
                            type2:nil
                            type3:nil
                          content:feedBackTextView.text];
        
        [_results setObject:@(0) forKey:@"fbInfo"];
        [[CMCCFeedBack initWithFBInfo:fbInfo
                             userInfo:fbUserInfo
                              appInfo:cmccAppInfo]
         asyncSendWithHandler:^(BOOL rst,NSString* msg){
             DJLog(@"意见反馈： %@", msg);
            if (rst && [msg contains:@"成功"]) {
                [_results setObject:@(1) forKey:@"fbInfo"];
            }
            else {
                [_results setObject:@(2) forKey:@"fbInfo"];
            }
            [weakSelf performSelectorOnMainThread:@selector(cmccCallback)
                                        withObject:nil
                                     waitUntilDone:NO];
         }];
    }
    
  
    
    
    // 软件评分
    [_results setObject:@(0) forKey:@"npsInfo"];
    CMCCFBInfo *npsInfo =
    [CMCCFBInfo initWithNPS:_starRatingView.selectStar];
    [[CMCCFeedBack initWithFBInfo:npsInfo
                         userInfo:fbUserInfo
                          appInfo:cmccAppInfo]
     asyncSendWithHandler:^(BOOL rst,NSString* msg){
         DJLog(@"软件评分： %@", msg);
         if (rst && [msg contains:@"成功"]) {
             [_results setObject:@(1) forKey:@"npsInfo"];
         }
         else {
              [_results setObject:@(2) forKey:@"npsInfo"];
         }
         
         [weakSelf performSelectorOnMainThread:@selector(cmccCallback)
                                    withObject:nil
                                 waitUntilDone:NO];
         
     }];

    
    // 满意度评分
    CMCCFBInfo *sfnInfo =
    [CMCCFBInfo initWithSFN:_starRatingViewSecond.selectStar];
    [_results setObject:@(0) forKey:@"sfnInfo"];
    [[CMCCFeedBack initWithFBInfo:sfnInfo
                         userInfo:fbUserInfo
                          appInfo:cmccAppInfo]
     asyncSendWithHandler:^(BOOL rst,NSString* msg){
         DJLog(@"满意度评分： %@", msg);
         if (rst && [msg contains:@"成功"]) {
             [_results setObject:@(1) forKey:@"sfnInfo"];
         }
         else {
             [_results setObject:@(2) forKey:@"sfnInfo"];
         }
         
         [weakSelf performSelectorOnMainThread:@selector(cmccCallback)
                                    withObject:nil
                                 waitUntilDone:NO];
     }];

    
    // 直接返回，不等待返回结果，结果太坑爹了
    [self dismissBackController];
    [PhoneNotification autoHideWithText:@"意见反馈提交成功"];
#endif
}


-(void)cmccCallback
{
    return;
    NSInteger sfn = [_results[@"sfnInfo"] integerValue];
    NSInteger apn = [_results[@"npsInfo"] integerValue];
    NSInteger fbn = [_results[@"fbInfo"] integerValue];
    
    if (3 == [_results count]) {
        if (1== sfn && 1== apn && 1 == fbn ) {
            [self dismissBackController];
            [PhoneNotification autoHideWithText:@"意见反馈提交成功"];
        }
        else if(2 == sfn || 2 == apn || 2 == fbn){
            [self dismissBackController];
//            [PhoneNotification autoHideWithText:@"意见反馈提交失败"];
        }
    }
    else if(2 == [_results count])
    {
        if (1== sfn && 1== apn) {
            [self dismissBackController];
            [PhoneNotification autoHideWithText:@"意见反馈提交成功"];
        }
        else if (2 == sfn || 2 == apn){
            [self dismissBackController];
            [PhoneNotification autoHideWithText:@"意见反馈提交失败"];
        }
    }
}

- (void)isSuccessful:(NSString *)body
{
    NSDictionary *dict = [body objectFromJSONString];
    NSDictionary *resultsDic = [dict objectForKey:@"res"];
    NSString *reCodeStr = [resultsDic objectForKey:@"reCode"];

    if (reCodeStr)
    {
        if ([reCodeStr isEqualToString:@"1"])
        {
            [PhoneNotification autoHideWithText:@"意见反馈提交成功"];
            [super dismissBackController];
        }
        else
        {
            [PhoneNotification autoHideWithText:@"发表失败"];
        }
    }
}

-(void)dismissBackController
{
    [self hiddenResign];
    [super dismissBackController];
}
- (void)dismissControllerAnimated:(PresentAnimatedState)state
{
    [self hiddenResign];
    [super dismissControllerAnimated:state];
}

- (void)hiddenResign
{
    if (feedBackTextView)
        [feedBackTextView resignFirstResponder];
}

- (void)initBgView
{
    CGRect bgRect;
    if (IOS7) {
        bgRect = CGRectMake(0, 65, kContentWidth, kScreenHeight - 52);
    }
    else{
        bgRect = CGRectMake(0, 52, kContentWidth, kScreenHeight - 52);
    }
    
    if (!bgView)
    {
        bgView = [[BgScrollView alloc] initWithFrame:bgRect];
        [bgView setDelegate:self];
        [bgView setBgSvDelegate:self];
        [bgView setContentSize:CGSizeMake(kContentWidth, (kScreenHeight - 81) * 2 - 200)];
        [self.view addSubview:bgView];

        _starRatingView = [[TQStarRatingView alloc] initWithFrame:FirstStartFrame numberOfStar:NumberOfStar];
        _starRatingView.delegate =self;
        [_starRatingView setScore:0.0f withAnimation:NO];
        _starRatingView.userInteractionEnabled = YES;
        [bgView addSubview:_starRatingView];
        
        _starRatingViewSecond = [[TQStarRatingView alloc] initWithFrame:SecondStartFrame numberOfStar:NumberOfStar];
        _starRatingViewSecond.delegate = self;
        [_starRatingViewSecond setScore:0.0f withAnimation:NO];
        [bgView addSubview:_starRatingViewSecond];
        
        for (NSInteger i=0; i<2; i++) {
            
            UILabel * scoreLabel = [[UILabel alloc]init];
            scoreLabel.textColor = [UIColor colorWithHexString:@"cacecd"];
            scoreLabel.text = @"未选择";
            scoreLabel.font = ScoreFont
            scoreLabel.textAlignment = NSTextAlignmentCenter;
            scoreLabel.backgroundColor = [UIColor clearColor];
            [bgView addSubview:scoreLabel];
            if (i == 0) {
                //用于显示 APP推荐度 分数
                scoreLabel.frame = CGRectMake(CGRectGetMaxX(FirstStartFrame) + StarANDScoreDis, CGRectGetMinY(FirstStartFrame), ScoreLabelWidth, CGRectGetHeight(FirstStartFrame));
                _npsLabel = scoreLabel;
            }else if (i == 1)
                //用于显示 用户满意度 分数
                scoreLabel.frame = CGRectMake(CGRectGetMaxX(SecondStartFrame) + StarANDScoreDis, CGRectGetMinY(SecondStartFrame), ScoreLabelWidth, CGRectGetHeight(SecondStartFrame));
            _sfnLabel = scoreLabel;
        }
    }
}

+(TQStarRatingView *)shareManager {
    static TQStarRatingView *shareTQManageInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        shareTQManageInstance = [[TQStarRatingView alloc] init];
    });
    return shareTQManageInstance;
}
- (void)initFeedBackTextView
{
    if (!feedBackBgView)
    {
        feedBackBgView = [[UIView alloc] initWithFrame:FEEDBACKTEXTVIEWFRAME];
        [bgView addSubview:feedBackBgView];
    }
    if (!feedBackTextView)
    {
        feedBackTextView = [[UITextView alloc] initWithFrame:FEEDBACKTEXTVIEWFRAME];
        placeHoldLab = [[UILabel alloc] initWithFrame:CGRectMake(COMMENTSTARTX + 2.f, 140, COMMENTWIDTH, 20)];
        placeHoldLab.text = @"在此输入您遇到的问题或修改意见";
        placeHoldLab.font = ScoreFont;
        placeHoldLab.textColor = [UIColor grayColor];
        placeHoldLab.alpha = 0.7;
        [bgView addSubview:placeHoldLab];
        placeHoldLab2  = [[UILabel alloc] initWithFrame:CGRectMake(COMMENTSTARTX + 2.f, 160, COMMENTWIDTH, 20)];
        placeHoldLab2.text = @"(500字以内，非必填)";
        placeHoldLab2.font = ScoreFont;
        placeHoldLab2.textColor = [UIColor grayColor];
        placeHoldLab2.alpha = 0.7;
        [bgView addSubview:placeHoldLab2];
        [feedBackTextView setDelegate:self];
        [feedBackTextView setBackgroundColor:[UIColor clearColor]];
        feedBackTextView.returnKeyType = UIReturnKeyDone;
        feedBackTextView.font = [UIFont fontWithName:@"Arial" size:14.0];
        feedBackTextView.autocorrectionType = UITextAutocorrectionTypeNo;
        feedBackTextView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [bgView addSubview:feedBackTextView];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    placeHoldLab.hidden = YES;
    placeHoldLab2.hidden = YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
   
}

#pragma mark UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (textView == feedBackTextView)
    {
        [bgView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *expectedString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if ([expectedString length] > MAXTEXTVIEWLENGTH)
    {
        [PhoneNotification autoHideWithText:@"您超过了输入字数限制~"];
        return NO;
    }
    return YES;
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (SUCCESSFULALT_TAG == alertView.tag)
    {
        if (buttonIndex == 0)
        {
            [self dismissControllerAnimated:PresentAnimatedStateFromRight];
        }
    }

}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [bgView setContentOffset:CGPointMake(0, 100) animated:YES];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.location > 20)
    {
        return NO;
    }
    return YES;
}

#pragma mark BgScrollViewDelegate
- (void)cilickBgScrollView:(BgScrollView *)bgScroll
{
    [self hiddenResign];
}


#pragma mark NightModeChangedDelegate
-(void) nightModeChanged:(BOOL) night
{
    if (night)
    {
        [bgView setBackgroundColor:[UIColor colorWithHexString:@"2D2E2F"]];
        [feedBackBgView setBackgroundColor:[UIColor blackColor]];
        [contLab setTextColor:[UIColor grayColor]];
        [FirstLabel setTextColor:[UIColor grayColor]];
        [SecondLabel setTextColor:[UIColor grayColor]];
        [feedBackTextView setTextColor:[UIColor whiteColor]];
    }
    else
    {
        [bgView setBackgroundColor:[UIColor clearColor]];
        [feedBackBgView setBackgroundColor:[UIColor colorWithHexString:@"F3F1F1"]];
        [contLab setTextColor:[UIColor blackColor]];
        [feedBackTextView setTextColor:[UIColor blackColor]];
    }
    
    [super nightModeChanged:night];
}

#pragma mark - ****StarRatingViewDelegate****
-(void)starRatingView:(TQStarRatingView *)view score:(float)score
{
    //没有分数，则不显示分数
    if (score <= 0) return;
    
    if (view == _starRatingView) {
        
        _npsLabel.text = [NSString stringWithFormat:@"%.f分",score];
        
    }else if(view == _starRatingViewSecond){
        
        _sfnLabel.text = [NSString stringWithFormat:@"%.f分",score];
        
    }
}

#pragma mark Observer methods
- (void)keyboardWillShow:(NSNotification *)notification
{
    if (keyboardShowing) {
        return;
    }
    
    [super addMiniKeyBoard];
    
    CGFloat animDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    //获取键盘的高度
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSInteger height = keyboardRect.size.height;
    
    if (!keyboardShowing) {
        [UIView animateWithDuration:animDuration
                              delay:0.0f
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                            
                             CGRect toolsBottomBarFrame = toolsBottomBar.frame;
                             toolsBottomBarFrame.origin.y -= height;
                             toolsBottomBar.frame = toolsBottomBarFrame;
                         }
                         completion:nil
         ];
    }
    keyboardShowing = YES;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (!keyboardShowing){
        return;
    }

    [super dismissMiniKeyBoard];
    
    CGFloat animDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    //获取键盘的高度
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSInteger height = keyboardRect.size.height;
    
    if (keyboardShowing) {
        
        [UIView animateWithDuration:animDuration
                              delay:0.0f
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             
                             CGRect toolsBottomBarFrame = toolsBottomBar.frame;
                             toolsBottomBarFrame.origin.y += height;
                             toolsBottomBar.frame = toolsBottomBarFrame;
                         }
                         completion:nil
         ];
    }
    keyboardShowing = NO;
}


-(void)keyboardWillChangeFrame:(NSNotification*)notification
{
    if (!keyboardShowing) {
        return;
    }
    
    CGRect endRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float btnW = CGRectGetWidth(toolsBottomBar.bounds);
    float btnH = CGRectGetHeight(toolsBottomBar.bounds);
    float btnY = kContentHeight - endRect.size.height - btnH;
    float btnX = endRect.origin.x + CGRectGetWidth(endRect) - btnW;
    toolsBottomBar.frame = CGRectMake(btnX, btnY, btnW, btnH);
}

@end
