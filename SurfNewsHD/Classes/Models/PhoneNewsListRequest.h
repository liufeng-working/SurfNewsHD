//
//  PhoneNewsListRequest.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-3-25.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfJsonRequestBase.h"

@interface PhoneNewsReq : NSObject
@property(nonatomic)NSString *uid;     // 统一账号登录用户uid
@property(nonatomic)NSInteger number;  // 一次请求条数（默认10条)
@property(nonatomic)NSInteger page;    // 请求页数
@property(nonatomic)int from;    // 请求来源 0 快讯 1 冲浪浏览器

@end



//	手机报同步更新列表请求
@interface PhoneNewsListRequest : SurfJsonRequestBase
@property(nonatomic,readonly) PhoneNewsReq *req;

- (id)initWithUid:(NSString*)uid page:(NSInteger)page;
- (void)setListCount:(NSUInteger)count; // 请求列表的总数，默认是10个
@end




////////////////////////////////////////////////////////////////
// 取消收藏请求体
//{
//    "req":  {
//        "uid": "jamesqian",
//        "hashcode": "adbcd1232fegsddg",
//        "type": "1",
//        "from": "0",
//    }
//    
//}


// 手机报取消收藏请求体
@interface CancelFacData : NSObject
@property(nonatomic)NSString *uid;          // 统一账号登录用户uid
@property(nonatomic)NSString *hashcode;     // 统一账号登录用户uid
@property(nonatomic)int type;         // 统一账号登录用户uid
@property(nonatomic)int from;         // 请求来源 0 快讯 1 冲浪浏览器
@end

@interface PhoneNewsCancelFavsRequest : SurfJsonRequestBase

@property(nonatomic,readonly) CancelFacData *req;


- (id)initWithUid:(NSString*)uid hashcode:(NSString*)hash;
@end


