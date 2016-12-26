//
//  GetPeriodicalListRequest.m
//  SurfNewsHD
//
//  Created by SYZ on 13-5-23.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "GetPeriodicalListRequest.h"

@implementation GetPeriodicalListJson

@end

//******************************************************************************

@implementation GetPeriodicalListRequest

- (id)initWithMagazineId:(long)magazineId serverTime:(long long)serverTime
{
    if (self = [super init]) {
        _req = [GetPeriodicalListJson new];
        _req.magazineId = magazineId;
        _req.serverTime = serverTime;
    }
    return self;
}

@end

//******************************************************************************

@implementation GetUpdatePeriodicalListJson

- (id)initWithItem:(NSArray *)array
{
    if (self = [super init]) {
        _item = array;
    }
    return self;
}

@end

//******************************************************************************

@implementation GetUpdatePeriodicalListRequest

- (id)initWithMagazineIdArray:(NSArray *)array
{
    if (self = [super init]) {
        _req = [[GetUpdatePeriodicalListJson alloc] initWithItem:array];
    }
    return self;
}

@end