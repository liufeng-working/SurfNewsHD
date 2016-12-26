//
//  GetMagazineListRequest.h
//  SurfNewsHD
//
//  Created by SYZ on 13-5-23.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfJsonRequestBase.h"

@interface GetMagazineListJson : NSObject

@property NSInteger page;

@end

//******************************************************************************

//期刊列表request
@interface GetMagazineListRequest : SurfJsonRequestBase

@property (nonatomic, strong) GetMagazineListJson *req;

- (id)initWithPage:(NSInteger)page;

@end
