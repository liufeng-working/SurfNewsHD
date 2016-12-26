//
//  DiscoverSearchNewsRequest.m
//  SurfNewsHD
//
//  Created by XuXg on 15/9/9.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "DiscoverSearchNewsRequest.h"


@implementation DiscoverSearchNewsRequest

-(id)init{
    self = [super init];
    if (self) {
        _page = 1;
    }
    return self;
}
@end




@implementation DiscoverSearchNewsResponse
@synthesize item = __ELE_TYPE_ThreadSummary;
@end