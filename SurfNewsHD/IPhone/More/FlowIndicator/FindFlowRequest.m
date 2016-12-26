//
//  FindFlowRequest.m
//  SurfNewsHD
//
//  Created by Jerry Yu on 13-6-13.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "FindFlowRequest.h"

@implementation FindFlowRequest


- (id)initWithUserId:(NSString *)userIdStr andISauto:(NSString *)isAutoStr
{
    self = [super init];
    if (self)
    {
        self.userid = userIdStr;
        self.isAuto = isAutoStr;
    }
    
    return self;
}

@end
