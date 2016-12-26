//
//  ClientFunctionResponse.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-11-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfJsonResponseBase.h"

@interface ClientFunctionResponse : SurfJsonResponseBase
@property NSArray *item;
@property NSString *mobile;
@end


@interface ClientFunctionInfo : NSObject

@property(nonatomic) NSUInteger fId;            // 功能点ＩＤ json字段为  n
@property(nonatomic,strong) NSString *fDes;     // 功能点描述 json字段为  d
@property(nonatomic) BOOL isOpen;               // 功能点开启标志（0是关闭，1是开启)json字段为  f

@end

