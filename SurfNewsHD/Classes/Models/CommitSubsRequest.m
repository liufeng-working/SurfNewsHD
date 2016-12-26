//
//  CommitSubsRequest.m
//  SurfNewsHD
//
//  Created by SYZ on 13-1-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "CommitSubsRequest.h"
#import "Encrypt.h"

@implementation CommitSubsRequest

- (id)initWithUserId:(long)userId coids:(NSString*)coids
{
    if (self = [super init]) {
        NSString *str = [Encrypt encryptUseDES:[NSString stringWithFormat:@"%ld",userId] ];
        self.userId = str;
        self.coids = coids;
    }
    return self;
}

@end
