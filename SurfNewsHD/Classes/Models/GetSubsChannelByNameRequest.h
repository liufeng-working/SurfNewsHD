//
//  GetSubsChannelByNameRequest.h
//  SurfNewsHD
//
//  Created by SYZ on 14-2-28.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetSubsChannelByNameRequest : SurfJsonRequestBase

@property (nonatomic, strong) NSString *cname;
@property NSInteger page;
@property NSInteger count;

- (id)initWithName:(NSString *)name page:(NSInteger)page;

@end
