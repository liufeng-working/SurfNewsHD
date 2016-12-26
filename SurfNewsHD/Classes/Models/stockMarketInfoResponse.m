//
//  stockMarketInfoResponse.m
//  SurfNewsHD
//
//  Created by jsg on 14-5-6.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "stockMarketInfoResponse.h"

@implementation stockMarketInfo
@synthesize index = __KEY_NAME_index;
@synthesize name = __KEY_NAME_name;
@synthesize newest = __KEY_NAME_newest;
@synthesize ups = __KEY_NAME_ups;
@synthesize range = __KEY_NAME_range;
@end

@implementation stockMarketInfoResponse
@synthesize item = __ELE_TYPE_stockMarketInfo;
@end

