//
//  GetPeriodicalContentIndexRequest.m
//  SurfNewsHD
//
//  Created by apple on 13-5-30.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "GetPeriodicalContentIndexRequest.h"

@implementation GetPeriodicalContentIndexRequest
@synthesize magazineId;
@synthesize periodicalId;

- (id)initWithPeriodicalIndexWithMagazineId:(long)_magazineID
                               periodicalId:(long)_periodicalID
{
    if (self = [super init]) {
        self.magazineId = _magazineID;
        self.periodicalId = _periodicalID;
    }
    return self;
}

@end
