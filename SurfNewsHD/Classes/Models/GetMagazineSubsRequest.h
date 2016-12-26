//
//  GetMagazineSubsRequest.h
//  SurfNewsHD
//
//  Created by SYZ on 13-5-23.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SurfJsonRequestBase.h"

//期刊订阅的json
@interface GetMagazineSubsJson : SurfJsonRequestBase

@property NSString *userId;

@end

//******************************************************************************

//期刊订阅关系request
@interface GetMagazineSubsRequest : NSObject

@property GetMagazineSubsJson *req;

- (id)initWithUserId:(NSString*)userId;

@end
