//
//  LongPullServletResponse.h
//  SurfNewsHD
//
//  Created by SYZ on 14-3-26.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "SurfJsonResponseBase.h"

@interface LongPullServletResponse : NSObject

@property NSString *code;
@property NSString *identifier;
@property NSString *method;
@property NSString *msg;
@property NSString *uid;
@property NSString *sid;
@property NSString *suid;
@property NSString *cityId;
@property NSString *mob;

@end
