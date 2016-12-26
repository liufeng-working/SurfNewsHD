//
//  RankingInfoRequest.m
//  SurfNewsHD
//
//  Created by jsg on 14-11-27.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "RankingInfoRequest.h"

@implementation RankingInfoRequest
- (id)initWithRankType:(NSInteger)type
{
    if (self = [super init]) {
        self.rankType = type;
    }
    
    return self;
}
@end
