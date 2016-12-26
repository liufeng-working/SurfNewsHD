//
//  WeiboModel.h
//  SurfNewsHD
//
//  Created by SYZ on 13-10-17.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SurfDbManager.h"
#import "EzJsonParser.h"
#import "NSString+Extensions.h"
#import "NSDictionary+QueryString.h"

//获取新浪微博用户关注列表的请求字段
@interface GetSinaWeiboUserFriendsRequest : NSObject

@property NSString *access_token;
@property long long uid;
@property int count;
@property NSInteger cursor;
@property int trim_status;

@end

//新浪微博用户的详细字段,具体请参考新浪微博开发文档
@interface SinaWeiboUserInfo : NSObject

@property long long uid;
@property NSString *screen_name;
@property NSString *name;
@property NSString *profile_image_url;

@property BOOL isSelected;          //本地属性,发微薄是否要 @ 此用户

@end

//获取新浪微博用户关注列表的响应信息
@interface GetSinaWeiboUserFriendsResponse : NSObject

@property NSArray *users;
@property int next_cursor;
@property int previous_cursor;
@property int total_number;

@end

//-------------------------------以下为请求的生成类--------------------------------

@interface WeiboRequestGenerator : NSObject

//生成获取新浪微博用户关注列表的请求
+ (NSURLRequest*)getSinaWeiboUserFriendsRequestWithCursor:(NSInteger)cursor;

@end

