//
//  CheckUpgradeResponse.h
//  SurfNewsHD
//
//  Created by yuleiming on 13-1-5.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfJsonResponseBase.h"

@interface AppUpgradeInfo : NSObject

@property NSString* verCode;

@end



@interface CheckUpgradeResponse : SurfJsonResponseBase

@property NSString* city;       //valid for CMWAP?
@property NSString* cityId;     //valid for CMWAP?
@property NSString* prov;       //valid for CMWAP?
@property long userid;          //valid for CMWAP?
@property AppUpgradeInfo* sd;

@property NSString *ih;

@end
