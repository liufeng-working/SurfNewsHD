//
//  GetPeriodicalListResponse.m
//  SurfNewsHD
//
//  Created by SYZ on 13-5-24.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "GetPeriodicalListResponse.h"

@implementation PeriodicalHeadContentTitle

@end

@implementation PeriodicalHeadInfo

@synthesize contentTitle = __ELE_TYPE_PeriodicalHeadContentTitle;

@end

@implementation PeriodicalInfo

@end

@implementation GetPeriodicalListResponse

@synthesize item = __ELE_TYPE_PeriodicalInfo;

@end

//**********************************更新的期刊************************************

@implementation UpdatePeriodicalInfo

@synthesize periods = __ELE_TYPE_PeriodicalInfo;

@end

@implementation UpdatePeriodicalListResponse

@synthesize item = __ELE_TYPE_UpdatePeriodicalInfo;

@end