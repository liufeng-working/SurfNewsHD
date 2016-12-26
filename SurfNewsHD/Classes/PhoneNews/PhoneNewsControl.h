//
//  PhoneNewsControl.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-3-25.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhoneNewsData.h"


@interface PNCtrlBase : UIControl{
    UIButton *_deleteButton;
}
@property(nonatomic,strong) void(^deleteClickEvent)(id);
@property(nonatomic,strong) void(^clickEvent)(id);

+ (CGSize)fitSize;

- (id)initWithPoint:(CGPoint)point;
- (void)setFrame:(CGRect)frame NS_DEPRECATED_IOS(2_0, 3_0);
- (id)initWithFrame:(CGRect)frame NS_DEPRECATED_IOS(2_0, 3_0);
@end




// 手机报控件
@interface PhoneNewCtrl : PNCtrlBase
@property(nonatomic,strong)PhoneNewsData *phoneData;
- (id)initWithPoint:(CGPoint)point;
- (void)reloadDate:(PhoneNewsData*)newData;
@end


// 收藏帖子控件
@interface FavsThreadCtrl : PNCtrlBase
@property(nonatomic,weak) FavThreadSummary *favTS;    // 收藏帖子内容

- (id)initWithPoint:(CGPoint)point;
- (void)reloadDate:(FavThreadSummary*)favTS;

@end


@interface PhoneNewsDateView : UIView
+ (CGSize)fitSize;
- (id)initWithPoint:(CGPoint)point;
- (void)setFrame:(CGRect)frame NS_DEPRECATED_IOS(2_0, 3_0);
- (id)initWithFrame:(CGRect)frame NS_DEPRECATED_IOS(2_0, 3_0);

- (void)relaodDate:(NSDate*)date;
@end