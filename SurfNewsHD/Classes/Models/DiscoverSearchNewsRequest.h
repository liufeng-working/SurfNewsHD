//
//  DiscoverSearchNewsRequest.h
//  SurfNewsHD
//
//  Created by XuXg on 15/9/9.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SurfJsonRequestBase.h"
#import "SurfJsonResponseBase.h"


@interface DiscoverSearchNewsRequest : SurfJsonRequestBase

@property(nonatomic,strong)NSString* keyword;
@property(nonatomic) NSUInteger page;
@end


@interface DiscoverSearchNewsResponse : SurfJsonResponseBase

@property(nonatomic,strong)NSArray *item;
@end

