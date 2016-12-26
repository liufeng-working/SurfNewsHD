//
//  stockMarketInfoManager.h
//  SurfNewsHD
//
//  Created by jsg on 14-5-5.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface stockMarketInfoManager : NSObject

@property (nonatomic,readonly) NSMutableArray *stockMarketInfoList;
+ (stockMarketInfoManager*)sharedInstance;

// 刷新财经频道股市行情信息
- (void)refreshStockMarketInfo:(void (^)(BOOL succeeded,NSArray* stockList))completion;
@end
