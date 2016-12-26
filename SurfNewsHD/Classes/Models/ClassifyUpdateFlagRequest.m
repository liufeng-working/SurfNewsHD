//
//  ClassifyUpdateFlagRequest.m
//  SurfNewsHD
//
//  Created by XuXg on 14-10-24.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "ClassifyUpdateFlagRequest.h"

@implementation ClassifyUpdateFlagRequest

-(id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _coids = @"";
    _mids = @"";
    return self;
}

@end
