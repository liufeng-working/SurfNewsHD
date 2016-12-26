//
//  PhoneSplashView.h
//  SurfNewsHD
//
//  Created by apple on 13-6-20.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhoneHotRootController.h"
@class SplashData;

@interface DesControl : UIControl
{
    UILabel *desLabel;
}

- (void)setLabel:(NSString *)des color:(NSString *)color;

@end

@interface PhoneSplashView : UIView<UIGestureRecognizerDelegate>
{
    CGFloat x;
    SplashData *sdData;
    BOOL singleTap;
    CGFloat adRectH;
}
@property(nonatomic,weak) PhoneHotRootController *newsController;

-(id)initWithSplashData:(SplashData*)sd;
-(void)splashAnimate:(NSInteger)type;

@end
