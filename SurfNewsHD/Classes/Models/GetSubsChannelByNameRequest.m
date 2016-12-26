//
//  GetSubsChannelByNameRequest.m
//  SurfNewsHD
//
//  Created by SYZ on 14-2-28.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "GetSubsChannelByNameRequest.h"

@implementation GetSubsChannelByNameRequest

- (id)initWithName:(NSString *)name page:(NSInteger)page
{
    if (self = [super init]) {
        self.cname = name;
        self.page = page;
        self.count = 20;
    }
    return self;
}

@end
