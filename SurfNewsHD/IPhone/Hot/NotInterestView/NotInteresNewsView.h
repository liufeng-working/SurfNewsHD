//
//  NotInteresNewsView.h
//  NotInterestNewsView
//
//  Created by NJWC on 16/1/27.
//  Copyright © 2016年 LF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotInteresButton.h"

//定义代理
@protocol NotInteresNewsViewDelegate <NSObject>
@required
/**
 *  确认按钮已经点击了
 *
 *  @param reasonArray 选择的理由，以字符串的形式装进数组
 */
-(void)sureBtnDidClickWithSelectReason:(NSArray *)reasonArray;

@optional
/**
 *  遮罩层已经被点击了
 */
-(void)shadowControlDidClick;

@end


@interface NotInteresNewsView : UIView

//代理
@property(nonatomic,weak)id<NotInteresNewsViewDelegate> delegate;

/**
 *  初始化方法
 *
 *  @param clickPoint 点击点的坐标
 *
 *  @param type 点击按钮的类型
 *
 *  @return view对象
 */
-(instancetype)initWithClickPoint:(CGPoint)clickPoint withType:(ButtonType)type;

/**
 *  从父视图移除自己
 */
-(void)removeViewFromSuperview;

@end


/**
 *  自定义按钮
 */
@interface NotInteresNewsButton : UIButton

@end
