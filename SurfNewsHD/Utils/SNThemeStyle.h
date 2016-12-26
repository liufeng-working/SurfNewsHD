//
//  SNThemeType.h
//  SurfNewsHD
//
//  Created by XuXg on 15/8/17.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>


#define SNTheme [SNThemeStyle sharedInstance]


#pragma mark- UIColorKey
#define kColorKey_SeparatorLine @"key001"




#pragma mark- other









@interface SNThemeStyle : NSObject {
    
    
    NSMutableDictionary *_theme;
    
}

+(SNThemeStyle *)sharedInstance;


-(id)valueForKey:(id)key;
@end
