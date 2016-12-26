//
//  FeedbackRequest.m
//  SurfNewsHD
//
//  Created by Jerry Yu on 13-6-13.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "FeedbackRequest.h"

@implementation FeedbackRequest


- (id)initWithUserId:(NSString *)userIdStr andCont:(NSString *)contStr andPhoneNum:(NSString *)phoneNumStr
{
    self = [super init];
    if (self)
    {
        self.userId = userIdStr;
        self.cont = contStr;
        self.mobile = phoneNumStr;
        self.type = @"1";
        self.mail = nil;
    }
    
    return self;
}

@end
