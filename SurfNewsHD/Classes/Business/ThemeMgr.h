//
//  ThemeMgr.h
//  SurfNewsHD
//
//  Created by yuleiming on 13-5-17.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

//主题管理器
//目前仅应对夜间

@protocol NightModeChangedDelegate <NSObject>

-(void) nightModeChanged:(BOOL) night;

@end

@interface ThemeMgr : NSObject
{
    __strong NSMutableArray* observers_;
    
}
+(ThemeMgr*)sharedInstance;

-(BOOL)isNightmode;
-(void)changeNightmode:(BOOL)night;

//注册夜间模式改变通知
//通常在一个页面展示出来时调用
-(void)registerNightmodeChangedNotification:(id <NightModeChangedDelegate>)handler;

//取消注册夜间模式改变通知
//通常在一个页面即将消失时调用
-(void)unregisterNightmodeChangedNotification:(id <NightModeChangedDelegate>)handler;

@end
