//
//  GetMagazineSubsRequest.m
//  SurfNewsHD
//
//  Created by SYZ on 13-5-23.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "GetMagazineSubsRequest.h"

@implementation GetMagazineSubsJson

@end

//******************************************************************************

@implementation GetMagazineSubsRequest

- (id)initWithUserId:(NSString*)userId
{
    if (self = [super init]) {
        _req = [GetMagazineSubsJson new];
        _req.userId = userId;
    }
    return self;
}

@end
