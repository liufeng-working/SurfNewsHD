//
//  NotInteresButton.h
//  NotInterestNewsView
//
//  Created by NJWC on 16/2/23.
//  Copyright © 2016年 LF. All rights reserved.
//

#import <UIKit/UIKit.h>

//按钮的类型，用于判断弹出不感兴趣视图的类型
typedef NS_ENUM(NSInteger,ButtonType){
    ButtonTypeImageBig = 0,   //大图
    ButtonTypeImageSmall,     //小图
    //more...
};

@class NotInteresButton;
@protocol NotInteresButtonDelegate <NSObject>

@required
/**
 *  代理回调
 *
 *  @param sender 自身
 *  @param point  点击点的坐标
 */
-(void)notInteresButton:(NotInteresButton *)sender withClickPoint:(CGPoint)point;

@end

@interface NotInteresButton : UIButton
//增加一个属性，记录按钮类型
@property(nonatomic,assign)ButtonType type;
@property(nonatomic,assign)id<NotInteresButtonDelegate> delegate;

@end
