//
//  PhoneNewsManager.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-3-28.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhoneNewsData.h"


//@interface PhoneNewsResult : NSObject
//
//@property BOOL succeeded;   //操作是否成功
//@property BOOL noChanges;   //是否无新数据
//@property long channelId;   //刷新的频道id
//@property(nonatomic,strong) NSArray* threads;   //该操作返回的帖子列表
//
//@end



@interface PhoneNewsManager : NSObject

+(PhoneNewsManager*)sharedInstance;

- (BOOL)isRequestNews;
- (NSArray*)getLocalPhoneNew; // 获取本地手机列表
- (void)refreshPhoneNewsList:(void(^)(BOOL, NSArray*))handler;   // 刷新手机列表
//- (void)loadMorePhoneNewsList:(void(^)(BOOL, NSArray*))handler;  // 加载更多手机列表

// 获取手机报Html数据
- (void)getPhoneNewsHtmlDate:(PhoneNewsData*)newData complete:(void(^)(BOOL, NSString*))handler;

// 获取手机报封面图片
- (void)getPhoneNewsCoverImg:(PhoneNewsData*)newData complete:(void(^)(BOOL, UIImage*))handler;

// 取消手机报收藏
- (void)cancelPhoneNewsFavs:(PhoneNewsData*)newData complete:(void(^)(BOOL))handler;

// 路径
- (NSString*)getUnzipPath:(PhoneNewsData*)data;
@end
