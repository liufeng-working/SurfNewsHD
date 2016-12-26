//
//  RankingInfoRequest.h
//  SurfNewsHD
//
//  Created by jsg on 14-11-27.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "SurfJsonRequestBase.h"

@interface RankingInfoRequest : SurfJsonRequestBase

@property NSInteger rankType;

- (id)initWithRankType:(NSInteger)type;

@end
