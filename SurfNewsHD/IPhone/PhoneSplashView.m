//
//  PhoneSplashView.m
//  SurfNewsHD
//
//  Created by apple on 13-6-20.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhoneSplashView.h"
#import "PathUtil.h"
#import "UpdateSplashResponse.h"
#import "PhoneReadController.h"
#import "PhoneRootViewController.h"
#import "AddMagazineSubsController.h"


@implementation DesControl

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        desLabel = [[UILabel alloc] initWithFrame:self.bounds];
        desLabel.backgroundColor = [UIColor clearColor];
        desLabel.numberOfLines = 0;
        desLabel.font = [UIFont systemFontOfSize:12.0f];
        [self addSubview:desLabel];
    }
    
    return self;
}

- (void)setLabel:(NSString *)des color:(NSString *)color
{
    if (color.length >= 6) {
        desLabel.textColor = [UIColor colorWithHexString:color];
    } else {
        desLabel.textColor = [UIColor colorWithHexString:@"FFFFFF"];
    }
    desLabel.text = des ? des : @"";
}

@end

@implementation PhoneSplashView
@synthesize newsController;
-(id)initWithSplashData:(SplashData*)sd
{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        // Initialization code
        sdData = sd;
        self.backgroundColor = [UIColor colorWithHexString:[[ThemeMgr sharedInstance] isNightmode]?@"2D2E2F":@"FFFFFF"];
        
        
        CGFloat width = CGRectGetWidth(self.bounds);
        CGFloat height = CGRectGetHeight(self.bounds);
        CGFloat imgScale = 640.f / 912.f; // 图片尺寸 640*912的
        CGFloat scale = [[UIScreen mainScreen] scale];
        
        // 广告图片View
        CGFloat imgH = adRectH =  width / imgScale;
        CGRect imgR = CGRectMake(0, 0, width, imgH);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imgR];
//        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:imageView];
        
        
        // 固定布局的底部区域
        CGFloat bottomH = height - imgH;
        if (bottomH < 60) {
            bottomH = 60;
            imgH = adRectH = height - bottomH;
            imgR.size.height = imgH;
            [imageView setFrame:imgR];
        }
       
        // 广告图片
        UIImage *adImg = [UIImage imageNamed:@"splash_surf_2016"];
        CGFloat adH = adImg.size.height;
        CGFloat adW = adImg.size.width;
        CGFloat adX = (width - adW) / 2.0;
        CGFloat adY = imgH + (bottomH-adH)/2.0;
        CALayer *adLayer = [CALayer layer];
        adLayer.frame = CGRectMake(adX, adY, adW,adH);
        adLayer.contents = (id)adImg.CGImage;
        adLayer.contentsScale = scale;
        adLayer.masksToBounds = YES;
        [self.layer addSublayer:adLayer];
        
        //战略性删除
        /*
        // 版权文字
        CATextLayer *copyrightLayer = [CATextLayer layer];
        copyrightLayer.string=@"Copyright © 2015 go.10086.cn All Rights Reserved";
        copyrightLayer.foregroundColor=[[UIColor colorWithHexValue:0xFFbdb9b9] CGColor];
        copyrightLayer.fontSize = 10.f;
        copyrightLayer.alignmentMode = @"center";
        copyrightLayer.contentsScale = scale;
        copyrightLayer.frame = CGRectMake(0, height-20, width, 20);
        [self.layer addSublayer:copyrightLayer];//将层加到当前View的默认layer下
         
        // 箭头按钮
        UIImage *btnBG = [UIImage imageNamed:@"splash_arrow"];
        CGFloat btnW = btnBG.size.width;
        CGFloat btnH = btnBG.size.height;
        CGFloat btnX = width - btnW - 20.f;
        CGFloat btnY = adY + (adH-btnH)/2;
        CALayer *arrayLayer = [CALayer layer];
        arrayLayer.frame = CGRectMake(btnX, btnY, btnW, btnH);
        arrayLayer.contents = (id)btnBG.CGImage;
        arrayLayer.contentsScale = scale;
        arrayLayer.masksToBounds = YES;
        [self.layer addSublayer:arrayLayer];
        */
        
        
        
        if (sd) {
            NSString* imgPath = [PathUtil pathOfSplashNewsImage];
            imageView.image = [UIImage imageWithContentsOfFile:imgPath];
        }
        else{
            imageView.image = [UIImage imageNamed:@"splash_default"];
        }
    }
    
    
    return self;
}

// 点击事件
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    singleTap = YES;
    x = [[touches anyObject] locationInView:self].x;
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    singleTap = NO;
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    float moveX =  self.frame.origin.x + touchPoint.x - x;
    if (moveX > 0) {
        moveX = 0;
    }
    self.frame = CGRectMake(moveX, 0.0f,
                            self.frame.size.width, self.frame.size.height);
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    if (singleTap) {
        NSInteger openT = 4;
        if (touchPoint.y <= adRectH) {
            if (sdData) {
                openT = sdData.openType;
            }
        }
        [self splashAnimate:openT];
    }
    else{
        CGFloat moveX = self.frame.origin.x + touchPoint.x - x;
        [self splashAnimate:moveX < -40.0f ?4:5];
    }
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    if (singleTap) {
        NSInteger openT = 4;
        if (touchPoint.y <= adRectH) {
            if (sdData) {
                openT = sdData.openType;
            }
        }
        [self splashAnimate:openT];
    }
    else {
        CGFloat moveX =  self.frame.origin.x + touchPoint.x - x;
         [self splashAnimate:moveX < -40.0f ?4:5];
    }
}

-(void)splashAnimate:(NSInteger)type
{
    [UIView animateWithDuration:0.3 animations:^
     {
         CGFloat w = CGRectGetWidth(self.bounds);
         CGFloat h = CGRectGetHeight(self.bounds);
         CGFloat nx = (type != 5) ? -w : w;
        self.frame = CGRectMake(nx, 0.f,w, h);
     }
    completion:^(BOOL finished)
     {
         switch (type)
         {
             case 0: //跳热推新闻
             {
                 SNThreadViewerController* controller = [[SNThreadViewerController alloc] initWithThread:sdData.infoNews];
     
                 
                 /*
                  channelType写死为0，服务器端搞不定，为1请求失败.....下次版本升级更改。
                  原因：后台Type和正文Type不一样。
                  */
                 sdData.infoNews.channelType = 0;
                 [newsController presentController:controller
                                          animated:PresentAnimatedStateFromRight];
                 [self removeFromSuperview];
                 self.hidden = YES;
                 break;
             }
             case 1: //跳热推栏目
             {
                 PhoneRootViewController *tabBar =(PhoneRootViewController *)newsController.tabBarController;
                 UINavigationController* navi = (UINavigationController*)[tabBar.viewControllers objectAtIndex:0];
                 PhoneHotRootController* hot = (PhoneHotRootController*)[navi.viewControllers objectAtIndex:0];
                 [hot selectChannelFromSpalshWithChannelId:sdData.jumpId];
                 [self removeFromSuperview];
                 self.hidden = YES;
                 break;
             }
              /* case 2: 跳期刊订阅中心
             {
                 PhoneRootViewController *tabBar =(PhoneRootViewController *)newsController.tabBarController;
                 tabBar.selectedIndex = 2;
                 [tabBar reloadTableBar];
                 UINavigationController *nav =  (UINavigationController *)tabBar.selectedViewController;
                 PhoneSurfController *controller = (PhoneSurfController *)nav.topViewController;
                 AddMagazineSubsController *newController = [[AddMagazineSubsController alloc] init];
                 [controller presentController:newController
                                      animated:PresentAnimatedStateFromRight];
                 [self removeFromSuperview];
                 self.hidden = YES;
                 
                 
                 break;
             }*/
             case 3: //跳url
             {
                 PhoneReadController *controller = [PhoneReadController new];
                 controller.webUrl = [sdData.jumpUrl completeUrl];
                 [newsController presentController:controller
                                          animated:PresentAnimatedStateFromRight];
                 [self removeFromSuperview];
                 self.hidden = YES;
                 break;
             }
             case 4:  //返回root界面
             {
                 [self removeFromSuperview];
                 self.hidden = YES;
                 break;
             }
             case 5://返回原始状态
             {
                 break;
             }
                 
             default:
                 break;
         }
     }];
}

@end
