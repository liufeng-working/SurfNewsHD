//
//  CheckUpgradeRequest.m
//  SurfNewsHD
//
//  Created by yuleiming on 13-1-5.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "CheckUpgradeRequest.h"

@implementation CheckUpgradeRequest

-(id) init
{
    if(self = [super init])
    {
        self.reqType = 0;   //目前貌似不提供手动检测更新功能，故写死为自动检测更新
    }
    return self;
}

@end





@implementation CheckUpgradeEnterpriseResponse

@synthesize sd = __ELE_TYPE_SoftUpdateInfo;


@end