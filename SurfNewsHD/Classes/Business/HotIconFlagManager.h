//
//  HotIconFlagManager.h
//  SurfNewsHD
//
//  Created by XuXg on 14/12/17.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HotIconFlagManager : NSObject

+ (HotIconFlagManager*)sharedInstance;
@property(nonatomic,readonly)UIImage *pEnergyImg;   // 正能量图片
@property(nonatomic,readonly)UIImage *nEnergyImg;   // 负能量图片
@property(nonatomic,readonly)UIImage *nEnergyImg_night;

@property(nonatomic,readonly)UIImage *commentFlag; // 评论标记图片


// 获取热点标记
// 如果缓存中存在，直接返回，不在调用回调函数
- (UIImage*)getHotIconWithUrl:(NSString*)imgUrl
         imgCompletionHandler:(void(^)(NSString*imgName , UIImage* iconImg))handler;

@end
