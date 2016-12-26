//
//  ThemeMgr.m
//  SurfNewsHD
//
//  Created by yuleiming on 13-5-17.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "ThemeMgr.h"
#import "AppSettings.h"

@implementation ThemeMgr


+(ThemeMgr*)sharedInstance
{
    static ThemeMgr *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ThemeMgr alloc] init];
        sharedInstance->observers_ = [NSMutableArray new];
    });
    
    return sharedInstance;
}

-(BOOL)isNightmode
{
    return [AppSettings boolForKey:BOOLKEY_NightMode];
}
-(void)changeNightmode:(BOOL)night
{
    BOOL nightMode = [AppSettings boolForKey:BOOLKEY_NightMode];
    if(night != nightMode)
    {
        [AppSettings setBool:night forKey:BOOLKEY_NightMode];
        for (id <NightModeChangedDelegate> handler in observers_)
        {
            [handler nightModeChanged:night];
        }
    }
}

//注册夜间模式改变通知
//通常在一个页面展示出来时调用
-(void)registerNightmodeChangedNotification:(id <NightModeChangedDelegate>)handler
{
    if (![observers_ containsObject:handler]) {
        [observers_ addObject:handler];
    }
}

//取消注册夜间模式改变通知
//通常在一个页面即将消失时调用
-(void)unregisterNightmodeChangedNotification:(id <NightModeChangedDelegate>)handler
{
    if ([observers_ containsObject:handler]) {
        [observers_ removeObject:handler];
    }
}


@end
