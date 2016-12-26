//
//  AppSettings.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-1-10.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "AppSettings.h"

@implementation AppSettings
static AppSettings *sharedAppSettings = nil;


#pragma 设置


+ (void)setInteger:(NSInteger)value forKey:(NSString *)keyName
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setInteger:value forKey:keyName];
    [ud synchronize];
}

+ (void)setFloat:(float)value forKey:(NSString *)keyName
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setFloat:value forKey:keyName];
    [ud synchronize];
}
+ (void)setDouble:(double)value forKey:(NSString *)keyName
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setDouble:value forKey:keyName];
    [ud synchronize];
}
+ (void)setBool:(BOOL)value forKey:(NSString *)keyName
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:value forKey:keyName];
    [ud synchronize];
}

+ (void)setString:(NSString *)value forKey:(NSString *)keyName
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:value forKey:keyName];
    [ud synchronize];
}

+ (void)setURL:(NSURL *)value forKey:(NSString *)keyName
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setURL:value forKey:keyName];
    [ud synchronize];
}
+ (void)setDate:(NSDate*)value forkey:(NSString *)keyName
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:value forKey:keyName];
    [ud synchronize];
}






+ (NSInteger)integerForKey:(NSString *)keyName
{
    NSInteger defValue = 0;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
 
    if (![ud objectForKey:keyName]) {
        // TODO 添加其它默认参数
        if([keyName isEqualToString:IntKey_ReaderPicMode])
            defValue = ReaderPicOn;
    }
    else{
        defValue = [ud integerForKey:keyName];
    }
    return defValue;
}

+ (NSString *)stringForKey:(NSString *)keyName
{
    NSString *defValue = nil;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (![ud objectForKey:keyName]){
        if ([keyName isEqualToString:StringKey])
            defValue = nil;// 根据业务需要，填写默认值
        else if([keyName isEqualToString:StringLastRunVersion])
            defValue = @"0.0.0";
        else if([keyName isEqualToString:StringKey_DefaultCityId])
            defValue = @"101010100"; // 北京城市Id
        else if([keyName isEqualToString:StringKey_DefalutCityName])
            defValue = @"北京";
    }
    else{
        defValue = [ud stringForKey:keyName];
    }
    return defValue;
}

+ (float)floatForKey:(NSString *)keyName
{
    float defValue = 0.0f;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    // 在没有值的情况下设置默认值
    if (![ud objectForKey:keyName]){
        if ([keyName isEqualToString:FLOATKEY_ReaderBodyFontSize]){
            defValue = kWebContentSize2;
        }
        // TODO 添加其它默认参数
    }
    else{
        defValue = [ud floatForKey:keyName];
    }    
    return defValue;
}

+ (double)doubleForKey:(NSString *)keyName
{
    double defValue = 0.0;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (![ud objectForKey:keyName]){
        if([keyName isEqualToString:DoubleKey]){
            defValue = 0.0;// 根据业务需要，填写默认值
        }
        else if([keyName isEqualToString:DoubleKey_Ad_UpdateTime])
            defValue = [[NSDate date] timeIntervalSince1970];
        // TODO 添加其它默认参数
    
    }
    else{
        defValue = [ud doubleForKey:keyName];
    }    
    return defValue;
}
+ (BOOL)boolForKey:(NSString *)keyName
{
    BOOL defValue = NO;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if(![ud objectForKey:keyName]){
        if ([keyName isEqualToString:BOOLKEY_NightMode]){
            defValue = NO;// 根据业务需要，填写默认值
        }
        else if ([keyName isEqualToString:BOOLKey_AutoRotatePictureEnable]){
            defValue = YES; // 默认开启自动旋转开关
        }
        // TODO 添加其它默认参数
        else if([keyName isEqualToString:ENABLE_STATE]){
            defValue = YES; //默认要闻推送为开启状态
        }
    }
    else{
        defValue = [ud boolForKey:keyName];
    }
    return defValue;
}

+ (NSURL *)urlForKey:(NSString *)keyName
{
    NSURL *defValue = nil;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (![ud objectForKey:keyName]) {
        if ([keyName isEqualToString:UrlKey]) {
            defValue = nil;
        }
        // TODO 添加其它默认参数

        
    }
    else{
        defValue = [ud URLForKey:keyName];
    }
    return defValue;
}

+ (NSDate*)dateForKey:(NSString *)keyName
{
    NSDate *defValue = nil;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (![ud objectForKey:keyName]) {
        if ([keyName isEqualToString:DateKey_NewestNews]) {
            defValue = nil;
        }
        // TODO 添加其它默认参数
        
        
    }
    else{
        defValue = [ud objectForKey:keyName];
    }  
    return defValue;
}

@end

