//
//  PhoneNewAndFavsView.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-3-26.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhoneNewAndFavsView : UIView<UIScrollViewDelegate>
@property(nonatomic,readonly)NSInteger index;
@property(nonatomic,weak)SurfNewsViewController* controller;


- (void)refreshDate;

- (void)indexChanger:(void(^)(NSInteger idx))handle;

// 切换到手机报屏幕
- (void)changeToPhoneNewView;
- (void)changeToFavsView; // 切换到收藏屏幕
@end
