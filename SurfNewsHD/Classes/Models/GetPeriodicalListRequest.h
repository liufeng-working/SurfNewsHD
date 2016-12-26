//
//  GetPeriodicalListRequest.h
//  SurfNewsHD
//
//  Created by SYZ on 13-5-23.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfJsonRequestBase.h"

//一种期刊列表的json
@interface GetPeriodicalListJson : SurfJsonRequestBase

@property long magazineId;
@property long long serverTime;

@end

//******************************************************************************

//一种期刊列表request
@interface GetPeriodicalListRequest : NSObject

@property GetPeriodicalListJson *req;

- (id)initWithMagazineId:(long)magazineId serverTime:(long long)serverTime;

@end

//******************************************************************************

//期刊列表的json
@interface GetUpdatePeriodicalListJson : NSObject

@property NSArray *item;

- (id)initWithItem:(NSArray *)array;

@end

//******************************************************************************

//期刊列表request
@interface GetUpdatePeriodicalListRequest : SurfJsonRequestBase

@property GetUpdatePeriodicalListJson *req;

- (id)initWithMagazineIdArray:(NSArray *)array;

@end