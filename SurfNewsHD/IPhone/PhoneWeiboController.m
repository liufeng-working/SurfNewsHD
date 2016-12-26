//
//  PhoneWeixinController.m
//  SurfNewsHD
//
//  Created by XuXg on 15/1/9.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "PhoneWeiboController.h"
#import "OauthWebViewController.h"
#import "ShareMenuView.h"
#import "AppDelegate.h"
#import <MessageUI/MessageUI.h>
#import "ContentShareController.h"
#import "PhoneShareWeiboView.h"
#import "DispatchUtil.h"

@interface PhoneWeiboController () <
OauthWebViewControllerDelegate,     // 新浪微博授权回调
QQApiInterfaceDelegate,             //QQ回调
MFMessageComposeViewControllerDelegate> {
    
    
    __weak PhoneShareWeiboView *_weiboView;
    PhoneshareWeiboInfo *_shareInfo;
}

@end


@implementation PhoneWeiboController

-(void)viewDidLoad
{
    [super viewDidLoad];

}


-(void)showShareView:(WeiboViewLayoutModel)viewType
           shareInfo:(PhoneshareWeiboInfo*)info
{
    if (_weiboView || !info) {
        return;
    }
    
    _shareInfo = info;

    // 创建微博窗口
    CGRect weiboR = self.view.bounds;
    PhoneShareWeiboView *wv = [[PhoneShareWeiboView alloc]initWithFrame:weiboR];
    wv.weiboViewBgColor = _shareInfo.weiboBGColor;
    [wv weiboModel:viewType weiboType:_shareInfo.showWeiboType];
    _weiboView = wv;
    [self.view addSubview:wv];
}

// 分享微博(这里是从选择微博View接受到的通知)
-(void)shareWeiboWithNum:(NSNumber*)weiboNum
{
    if (weiboNum) {
        WeiboType type = [weiboNum integerValue];
        [self shareWeiboWithType:type];
    }
}


- (void)shareWeiboWithType:(WeiboType)type
{
    // 删除微博View
    [DispatchUtil dispatch:^{
        [_weiboView removeFromSuperview];
    } after:0.5f];
    
    // 微博授权判断
    if (type == kSinaWeibo) {
        if (![self isOAuthed:SinaOAuth]) {
            [self oauthWebViewController:SinaOAuth];
            return;
        }
    }

    else if (type == kSMS) {
        // 短信分享
        [self sendSMS:_shareInfo];
        return;
    }
    else if (type == kPasteboard) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [_shareInfo newsUrl:kPasteboard];
        
        //调用延时，让提示信息延时显示
        [self performSelector:@selector(showAlert) withObject:nil afterDelay:0.5];
        
        return;
    }
    
    // 进入微博编写窗口
    [self entryWeiboEditeView:type];
}

//延时显示方法
-(void)showAlert
{
    [PhoneNotification autoHideWithText:@"已成功复制"];
}



-(void)sendSMS:(PhoneshareWeiboInfo*)shareInfo
{
    if(!shareInfo || ![MFMessageComposeViewController canSendText]){
        return;
    }
    
    NSMutableString *sendBody =[NSMutableString string];
    [sendBody appendString:[shareInfo title:kSMS]];
    [sendBody appendString:[shareInfo content:kSMS]];
    [sendBody appendString:[shareInfo newsUrl:kSMS]];

    theApp.nightModeShadow.hidden = YES;
    MFMessageComposeViewController *messageCtrll = [MFMessageComposeViewController new];
    messageCtrll.body = sendBody;
    messageCtrll.messageComposeDelegate = self;
    [self presentViewController:messageCtrll animated:YES completion:nil];
}


// 到这个函数，说明微博授权已经通过，进入微博编辑界面
- (void)entryWeiboEditeView:(WeiboType)type
{
    NSString *shareTitle = [_shareInfo title:type];
    NSString *shareContent = [_shareInfo content:type];
    NSString *shareNewsUrl = [_shareInfo newsUrl:type];

    if (type == kWeixin || type == kWeiXinFriendZone) {
        NSInteger scene = (type==kWeixin)?WXSceneSession:WXSceneTimeline;
        if (_shareInfo.weiboSource == kWeiboData_BeautyCell) {
            [theApp sendImageToWeixin:shareTitle
                          description:shareContent
                           shareImage:_shareInfo.picture
                                scene:scene];
        }
        else {
            [theApp sendWeixin:shareTitle
                   description:shareContent
                       newsUrl:shareNewsUrl
                    shareImage:_shareInfo.picture
                         scene:scene];
        }
    }
    else if (type == kQQFriend || type == kQZone){
        LFShareToQQ sType = (type == kQQFriend) ? LFShareToQQfriend : LFShareToQZone;
        if (_shareInfo.weiboSource == kWeiboData_BeautyCell) {
            [theApp sendImageToQQ:shareTitle
                      description:shareContent
                       shareImage:_shareInfo.picture
                             type:sType];
        }else{
            [theApp sendQQ:shareTitle
               description:shareContent
                   newsUrl:shareNewsUrl
                shareImage:_shareInfo.picture
                      type:sType];
        }
    }
    else if(type == kSinaWeibo) {
        NSMutableString *shareBody = [NSMutableString string];
        [shareBody appendString:shareTitle];
        [shareBody appendString:shareContent];
        shareBody = [self substring:shareBody];
        
        if (type == kSinaWeibo) {
            
            ContentShareController *csc = [ContentShareController new];
            ContentShareView* view = [csc curShareView];
            [view setShareWordText:shareBody];
            [view remainlab:shareBody];
            [view setShareMode:SinaWeibo];
            [view setShareAds:shareNewsUrl];
            [view setShareNewsAds:shareNewsUrl];
            [view setShareStr:shareBody];
            
            //提取图片
            [view setPic:_shareInfo.picture];
            [csc clearButtonOnToolsBar];
            [self presentController:csc animated:PresentAnimatedStateFromRight];
        }
    }
    else if (type == kMore){
        
        //创建分享内容
        NSString * title = shareTitle;
        UIImage * iconImage = [UIImage imageNamed:@"Icon"];
        NSURL * url = [NSURL URLWithString:shareNewsUrl];
        
        //创建系统的分享对象
        UIActivityViewController * activityVC = [[UIActivityViewController alloc]initWithActivityItems:@[title,iconImage,url] applicationActivities:nil];
        
        
        /*如果可用，这些都应该会被显示(我只能说应该)
         UIActivityTypePostToFacebook
         UIActivityTypePostToTwitter
         UIActivityTypeMail
         UIActivityTypePostToTencentWeibo
         UIActivityTypePostToFlickr
         UIActivityTypePostToVimeo
        */
        //设置哪些分享方式不显示
        activityVC.excludedActivityTypes = @[
            UIActivityTypeMessage,
            UIActivityTypePostToWeibo,
            UIActivityTypePrint,
            UIActivityTypeCopyToPasteboard,
            UIActivityTypeAssignToContact,
            UIActivityTypeSaveToCameraRoll,
            UIActivityTypeAddToReadingList,
            UIActivityTypeAirDrop,
//            UIActivityTypeOpenInIBooks    //iOS9 以后
            ];
        
        activityVC.completionHandler = ^ (NSString * __nullable activityType, BOOL completed){
            
            NSLog(@"%@-----%d",activityType,completed);

            /*  activityType----completed
             com.apple.reminders.RemindersEditorExtension-----1 提醒事项
             com.apple.mobilenotes.SharingExtension-----0       备忘录
             com.apple.UIKit.activity.Mail-----0                邮箱
             */
            
            //完全不清楚，为什么 提醒事项 不管点什么，返回的都是是YES
            if ([activityType containsCasInsensitive:@"RemindersEditorExtension"]) {
                return ;
            }
            
            //回调操作
            if (completed) {
                [theApp commitShareOperation];  // 分享成功
            }else{
                [PhoneNotification autoHideWithText:@"已取消"];
            }
            
        };
        
        //从底部弹出
        [self presentViewController:activityVC animated:YES completion:nil];
        
//        UIActivityItemProvider
//        UIActivityItemSource协议
    }
}

- (NSMutableString*)substring:(NSMutableString*)text{
    NSMutableString *strSub = [NSMutableString string];
    if ([text length] > 120) {
        [strSub appendFormat:@"%@...",[text substringToIndex:113]];
    }
    else{
        strSub = text;
    }
    return strSub;
}


//判断是否已授权
- (BOOL)isOAuthed:(OAuthClientType)type
{
    SurfDbManager *manager = [SurfDbManager sharedInstance];
    if (type == SinaOAuth) {
        NSDictionary *sinaDict = [manager getSinaWeiboInfoForUser:kDefaultID];
        if ([sinaDict valueForKey:@"access_token"] &&
            [sinaDict valueForKey:@"uid"]) {
            return YES;
        }
    }
    else if (type == TencentWeiboOAuth) {
        NSDictionary *tencentDict = [manager getTencentWeiboInfoForUser:kDefaultID];
        if ([tencentDict valueForKey:@"access_token"]) {
            return YES;
        }
    }
    else if (type == RenRenOAuth) {
        NSDictionary *renrenDict = [manager getRenrenWeiboInfoForUser:kDefaultID];
        if ([renrenDict valueForKey:@"access_token"]) {
            return YES;
        }
    }
    else if (type == ChinaMobielOAuth) {
        NSDictionary *cmDict = [manager getCMWeiboInfoForUser:kDefaultID];
        if ([cmDict valueForKey:@"access_token"]) {
            return YES;
        }
    }
    return NO;
}

//跳转到授权界面
- (void)oauthWebViewController:(OAuthClientType)type
{
    [theApp.oauthWebViewController setOAuthClientType:type];
    theApp.oauthWebViewController.delegate = self;
    [self presentViewController:theApp.oauthWebViewController
                     animated:YES completion:nil];
}


#pragma -mark OauthWebViewControllerDelegate
//授权成功
- (void)oauthResult:(OauthWebViewController *)controller
          oauthTpye:(OAuthClientType)type
{
    [controller dismissViewControllerAnimated:NO completion:nil];
    if (type == SinaOAuth) {
        [self shareWeiboWithType:kSinaWeibo];
    }
}

//授权失败
- (void)oauthFailed:(OauthWebViewController *)controller
          oauthTpye:(OAuthClientType)type
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    if (type == SinaOAuth)
        [PhoneNotification autoHideWithText:@"绑定新浪微博失败,请重试"];
    else if (type == TencentWeiboOAuth)
        [PhoneNotification autoHideWithText:@"绑定腾讯微博失败,请重试"];
    else if (type == RenRenOAuth)
        [PhoneNotification autoHideWithText:@"绑定人人网失败,请重试"];
    else if (type == ChinaMobielOAuth)
        [PhoneNotification autoHideWithText:@"绑定中国移动微博失败,请重试"];
}

#pragma mark MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if (result == MessageComposeResultSent) {
        [theApp commitShareOperation];  // 分享成功
    } else if (result == MessageComposeResultFailed) {
        [PhoneNotification autoHideWithText:@"短信分享失败"];
    }
    theApp.nightModeShadow.hidden = ![[ThemeMgr sharedInstance] isNightmode];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ****处理从QQ分享回来，结果是什么****
+(void)handleOpenUrl:(NSURL *)url
{
    [QQApiInterface handleOpenURL:url delegate:[self alloc]];
}

#pragma mark - ****QQ回调的代理方法****
/**
 处理来至QQ的响应
 */
- (void)onResp:(QQBaseResp *)resp
{
    //按常规思想，resp.result应该是一个枚举类型，进入QQ头文件，没有找到。。。。
    //0  -4  这两个值，是我测试得到的
    NSInteger result = [resp.result integerValue];
    if (result == 0) {
        
        [theApp commitShareOperation];      // 分享成功
    }else if(result == -4){
        [PhoneNotification autoHideWithText:@"已取消"];
    }else{
        [PhoneNotification autoHideWithText:@"分享失败"];
    }
}

/**
 处理来至QQ的请求
 */
- (void)onReq:(QQBaseReq *)req
{}
/**
 处理QQ在线状态的回调
 */
- (void)isOnlineResponse:(NSDictionary *)response
{}


#pragma mark- TencentSessionDelegate

/**
 * 登录成功后的回调
 */
- (void)tencentDidLogin
{
    
}

/**
 * 登录失败后的回调
 * \param cancelled 代表用户是否主动退出登录
 */
- (void)tencentDidNotLogin:(BOOL)cancelled
{
    
}

/**
 * 登录时网络有问题的回调
 */
- (void)tencentDidNotNetWork
{
    [PhoneNotification autoHideWithText:@"网络异常"];
}
@end
