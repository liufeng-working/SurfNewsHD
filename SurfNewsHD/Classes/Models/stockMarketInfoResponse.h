//
//  stockMarketInfoResponse.h
//  SurfNewsHD
//
//  Created by jsg on 14-5-6.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "SurfJsonResponseBase.h"

@interface stockMarketInfo : NSObject

@property (nonatomic,strong) NSString *index; //index
@property (nonatomic,strong) NSString *name;  //股指名称
@property (nonatomic,strong) NSString *newest; //最新数值
@property (nonatomic,strong) NSString *ups;     //涨跌
@property (nonatomic,strong) NSString *range;   //涨幅
@end

@interface stockMarketInfoResponse : SurfJsonResponseBase
@property NSArray *item;
@end

