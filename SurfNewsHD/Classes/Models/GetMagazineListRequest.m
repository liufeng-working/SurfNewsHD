//
//  GetMagazineListRequest.m
//  SurfNewsHD
//
//  Created by SYZ on 13-5-23.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "GetMagazineListRequest.h"

@implementation GetMagazineListJson

@end

//******************************************************************************

@implementation GetMagazineListRequest

- (id)initWithPage:(NSInteger)page
{
    if (self = [super init]) {
        _req = [GetMagazineListJson new];
        _req.page = page;
    }
    return self;
}

@end
