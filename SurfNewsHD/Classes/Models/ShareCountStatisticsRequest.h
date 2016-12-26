//
//  ShareCountStatisticsRequest.h
//  SurfNewsHD
//
//  Created by SYZ on 14-5-15.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "SurfJsonRequestBase.h"

@interface ShareCountStatisticsRequest : SurfJsonRequestBase

@property (nonatomic, strong) NSString *activeId;
@property (nonatomic) NSInteger shareType;

- (id)initWithActiveId:(NSString *)activeId shareType:(NSInteger)type;

@end
