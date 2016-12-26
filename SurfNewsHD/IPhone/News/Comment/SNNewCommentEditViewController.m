//
//  SNNewCommentEditViewController.m
//  SurfNewsHD
//
//  Created by XuXg on 15/6/16.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "SNNewCommentEditViewController.h"
#import "DispatchUtil.h"
#import "GTMHTTPFetcher.h"
#import "NSString+Extensions.h"
#import "SurfJsonResponseBase.h"
#import "MJExtension.h"
#import "NewsCommentManager.h"
#import "WeatherManager.h"
#import "UserManager.h"
#import "PhoneLoginController.h"


#define kMaxTextLenght 120  // 最大的文字长度
#define RemainStr(intV) [NSString stringWithFormat:@"还可输入 : %@字",@(intV)];

@interface SNNewCommentEditViewController () <UITextViewDelegate>{
    __weak UITextView *_inputText;
    __weak UILabel *_placeholder;
    __weak UILabel *_remainLab;
    
    __weak ThreadSummary* _thread;
    
    BOOL _isLogin;
}

@end

@implementation SNNewCommentEditViewController

-(id)initWithThreadSummery:(ThreadSummary*)thread
{
    self = [super init];
    if (self) {
        _thread = thread;
        self.titleState = PhoneSurfControllerStateTop;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"评论";
    [self initUI];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    // 确保用户登录，没有登录进入登录入口
//    if (![[UserManager sharedInstance] loginedUser]) {
//        // 不能反复的跳转
//        if (!_isLogin) {
//            _isLogin = YES;
//            PhoneLoginController *loginController = [[PhoneLoginController alloc] init];
//            [self presentController:loginController animated:PresentAnimatedStateFromRight];
//        }
//        else {
//            // 没有登录或注册成功的用户，直接返回。
//            [self dismissBackController];
//        }
//    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_inputText becomeFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_inputText resignFirstResponder];
    [PhoneNotification hideNotification];
}


#pragma mark private methods
-(void)initUI
{
    // 初始化编辑框
    CGFloat tX = 10.f;
    CGFloat tH = 150.f;
    CGFloat tY = self.StateBarHeight + 10.f;
    CGFloat tW = kContentWidth - tX - 10.f;
    CGRect tR = CGRectMake(tX, tY, tW, tH);
    UIFont *font = [UIFont systemFontOfSize:15.0f];
    BOOL isN = [[ThemeMgr sharedInstance] isNightmode];
    UITextView *text = [[UITextView alloc] initWithFrame:tR];
    _inputText = text;
    
    [text setDelegate:self];
    [text setTextColor:[UIColor colorWithHexValue:0xFF8B8782]];
    [text setFont:font];
    [text setReturnKeyType:UIReturnKeySend];
    [text setBackgroundColor:[UIColor clearColor]];
    text.layer.borderWidth = 0.7f;
    text.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.7].CGColor;
    text.layer.cornerRadius = 5.f;
    [self.view addSubview:text];
    
    // tH
    NSString *str = @"请文明发言，遵守互联网7条上网公约";
    CGRect pR = CGRectMake(5, 8, 0, 0);
    UILabel *placeholder = [[UILabel alloc] initWithFrame:pR];
    _placeholder = placeholder;
    placeholder.text = str;
    placeholder.textColor = [UIColor colorWithWhite:0.5 alpha:0.7];
    placeholder.userInteractionEnabled = NO;
    placeholder.lineBreakMode = NSLineBreakByClipping;
    placeholder.backgroundColor = [UIColor clearColor];
    [placeholder sizeToFit];
    [text addSubview:placeholder];
    
    // keyboard accessoryView
    {
        UIView *accessory = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kContentWidth, 40)];
        accessory.backgroundColor = self.view.backgroundColor;
        
        // 隐藏键盘按钮
        // keyBoard 中的自定义隐藏keyboard 按钮
        UIImage *btnImg = [UIImage imageNamed:@"minikeyborad"];
        CGFloat eW = btnImg.size.width;
        CGFloat eH = btnImg.size.height;
        CGFloat eY = (CGRectGetHeight(accessory.bounds)-eH) / 2;
        CGFloat eX = CGRectGetWidth(accessory.bounds) - eW - 5;
        UIButton *exitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        exitBtn.frame = CGRectMake(eX, eY, eW, eH);
        [exitBtn setBackgroundImage:btnImg forState:UIControlStateNormal];
        [exitBtn addTarget:self action:@selector(exitKeyboardButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [accessory addSubview:exitBtn];
        
        
        text.inputAccessoryView = accessory;
    }
    
    
    // 还可输入 : %@字
    UIFont *rFont = [UIFont systemFontOfSize:12];
    NSString *remainStr = RemainStr(120);
    CGSize rS = [remainStr surfSizeWithFont:rFont
                          constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                              lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat rY = tR.origin.y + tR.size.height + 10;
    CGFloat rX = tR.origin.x + tR.size.width-rS.width;
    CGRect rR = CGRectMake(rX, rY, rS.width, rS.height);
    UILabel *remain = [[UILabel alloc]initWithFrame:rR];
    _remainLab = remain;
    remain.text = remainStr;
    remain.font = rFont;
    remain.textColor = isN ? [UIColor whiteColor]:[UIColor colorWithHexValue:0xFF34393d];
    remain.lineBreakMode = NSLineBreakByClipping;
    remain.backgroundColor = [UIColor clearColor];
    [self.view addSubview:remain];
}

/**
 *  发送新闻评论
 */
-(void)sendCommentRequest
{
    if (!_thread) {
        return;
    }
    
    
    // 检查是否包含表情符号
    if ([_inputText.text isContainsEmoji]) {
        [PhoneNotification autoHideWithText:@"发表内容包含表情符号，暂不支持"];
        return;
    }
    
    [PhoneNotification manuallyHideWithIndicator];
    id req = [SurfRequestGenerator commitNewsComment:_thread commentContent: _inputText.text];
    GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:req];
    __block GTMHTTPFetcher* weakFetcher = fetcher;
    [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error)
     {
         BOOL succeed = NO;
         if (!error) {
              NSString* body = [[NSString alloc] initWithData:data encoding:[[[weakFetcher response] textEncodingName] convertToStringEncoding]];
            
             
             // json to model
             // 结果值 0：成功 -1:失败
             SurfJsonResponseBase *resp =
             resp = [SurfJsonResponseBase objectWithKeyValues:body];
             if ([resp.res.reCode isEqualToString:@"1"]) {
                 succeed = YES;
                 
                 // TODO:创建一个评论，添加到新闻评论管理器中
                 NewComment *newComment = [NewComment new];
                 newComment.content = _inputText.text;
                 newComment.location = [[WeatherManager sharedInstance] weatherInfo].cityName;
                 newComment.createtime = [[NSDate date] timeIntervalSince1970] * 1000;
                 
                UserInfo *userInfo = [[UserManager sharedInstance] loginedUser];
                 if (userInfo.userDes) {
                     newComment.nickname = userInfo.userDes.nickName;
                     newComment.headPic = userInfo.userDes.headPic;
                 }
                 
                 [[NSNotificationCenter defaultCenter]
                  postNotificationName:kNotiication_AddNewsComment
                  object:newComment];
                 _thread.comment_count += 1; // 评论数加1
             }
         }
         
         if (!succeed) {
             [PhoneNotification autoHideWithText:@"新闻评论发表失败"];
         }
         
         
         [PhoneNotification hideNotification];
         
         // 返回新闻评论controller
         [self dismissBackController];

     }];
}

#pragma mark Deletage
// UITextViewDelegate
// UItextView 将要改变文字
-(BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        
        if([textView.text length] <= 0) {
            [PhoneNotification autoHideWithText:@"输入内容不能为空"];
            return NO;
        }
        
        
        // 隐藏键盘
        [textView resignFirstResponder];
        [textView setUserInteractionEnabled:NO];
        
        
        // TODO:发送评论请求
        [self sendCommentRequest];
        
        
        return NO;
    }
    
    //限制字数120字
    NSString *finalString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if ([finalString length] > kMaxTextLenght) {
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [_placeholder setHidden:[textView.text length] > 0];

    
    // 检查是否包含表情符号
    if ([textView.text isContainsEmoji]) {
        [PhoneNotification autoHideWithText:@"发表内容包含表情符号，暂不支持"];
    }
    
    
    if ([textView.text length] > kMaxTextLenght) {
        textView.text = [textView.text substringToIndex:kMaxTextLenght];
        [PhoneNotification autoHideWithText:[NSString stringWithFormat:@"评论文字长度不能超过%@",@(kMaxTextLenght)]];
    }
     _remainLab.text = RemainStr(120 - [textView.text length]);
}


-(void)exitKeyboardButtonClick:(id)sender
{
    // 隐藏keyBoard
    [_inputText resignFirstResponder];
}

@end
