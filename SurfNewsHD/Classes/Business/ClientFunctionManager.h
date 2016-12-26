//
//  ClientFunctionManager.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-11-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

// 客户端功能管理器，根据服务器的指示，开启一次隐藏功能
@interface ClientFunctionManager : NSObject{
    NSMutableArray *_funcInfoList;
}


+ (ClientFunctionManager*)sharedInstance;

// 刷新一下客户端需要开启的功能
- (void)refreshClientFunction;

// 是否开启网页正文相关推荐
- (BOOL)isOpenWebContentRecommend;
@end
