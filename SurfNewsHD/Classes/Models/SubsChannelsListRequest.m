//
//  SubsChannelsListRequest.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-1-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SubsChannelsListRequest.h"

@implementation SubsChannelsListRequest

-(id)initWithCateId:(long)cateId page:(NSInteger)page
{
    if(self = [super init])
    {
        self.page = page;
        self.cateId = cateId;
    }
    return self;
}


@end


@implementation DefaultSubsChannelsListJson
@end

@implementation DefaultSubsChannelsListRequest

- (id)init
{
    if (self = [super init]) {
        _req = [DefaultSubsChannelsListJson new];
    }
    return self;
}

@end


@implementation UserSubsChannelsListRequest

-(id)initWithUserId:(NSString*)userId
{
    if(self = [super init])
    {
        self.userId = userId;
    }
    return self;
}

@end
