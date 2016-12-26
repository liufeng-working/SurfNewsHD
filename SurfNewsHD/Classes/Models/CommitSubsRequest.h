//
//  CommitSubsRequest.h
//  SurfNewsHD
//
//  Created by SYZ on 13-1-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfJsonRequestBase.h"

@interface CommitSubsRequest : SurfJsonRequestBase

@property NSString *userId;
@property NSString *coids;

- (id)initWithUserId:(long)userId coids:(NSString*)coids;

@end
