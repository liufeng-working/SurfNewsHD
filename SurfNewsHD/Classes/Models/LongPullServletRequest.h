//
//  LongPullServletRequest.h
//  SurfNewsHD
//
//  Created by SYZ on 14-3-26.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "SurfJsonRequestBase.h"
#import "DeviceIdentifier.h"

@interface LongPullServletRequest : SurfJsonRequestBase

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *imsi;
@property (nonatomic) NSInteger type;

- (id)initWithIdentifier:(NSString *)identifier;

@end
