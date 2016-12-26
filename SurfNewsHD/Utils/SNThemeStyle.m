//
//  SNThemeType.m
//  SurfNewsHD
//
//  Created by XuXg on 15/8/17.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "SNThemeStyle.h"

@implementation SNThemeStyle

+(SNThemeStyle *)sharedInstance
{
    static SNThemeStyle *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [SNThemeStyle new];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createTheme];
    }
    return self;
}


-(void)createTheme
{
    _theme = [NSMutableDictionary dictionary];
    
    [_theme setValue:[UIColor colorWithHexValue:0xFFe3e2e2]
              forKey:kColorKey_SeparatorLine];
    
    
    
}

-(id)valueForKey:(id)key
{
    return [_theme objectForKey:key];
}

@end
