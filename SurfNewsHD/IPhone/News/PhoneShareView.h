//
//  PhoneShareView.h
//  SurfNewsHD
//
//  Created by apple on 13-6-24.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShareMenuView.h"
#import "ContentShareView.h"


@class PhoneShareView;


@protocol PhoneShareWeiboDelegate <NSObject>
@optional
- (void)hiddenShareView;
- (void)shareWeibo:(ShareWeiboType)type;         // 分享微博
@end

@interface PhoneShareView : UIView <ShareMenuViewDelegate>{
    UIView *_bgView;
    UIView *_shadowView;
}

@property(nonatomic, weak) id<PhoneShareWeiboDelegate> delegate;

// 显示分享面板
- (void)showShareView:(BOOL)isShow
             isAnimate:(BOOL)animate
            completion:(void (^)(BOOL finished))completion;
@end
