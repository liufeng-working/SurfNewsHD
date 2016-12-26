//
//  WeiboManager.h
//  SurfNewsHD
//
//  Created by SYZ on 13-10-17.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTMHTTPFetcher.h"
#import "WeiboModel.h"
#import "EzJsonParser.h"

@interface WeiboManager : NSObject

+ (WeiboManager*)sharedInstance;

//获取新浪微博用户的关注列表
- (void)getSinaWeiboUserFriendsWithCursor:(NSInteger)cursor
                                 complete:(void(^)(BOOL, NSArray*, int, int))handler;

@end
