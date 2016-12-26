//
//  GetPeriodicalContentIndexRequest.h
//  SurfNewsHD
//
//  Created by apple on 13-5-30.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfJsonRequestBase.h"


//期刊列表request
@interface GetPeriodicalContentIndexRequest : SurfJsonRequestBase

//@property GetPeriodicalContentIndexJson *req;

- (id)initWithPeriodicalIndexWithMagazineId:(long)_magazineID
                               periodicalId:(long)_periodicalID;
@property long magazineId;
@property long periodicalId;

@end
