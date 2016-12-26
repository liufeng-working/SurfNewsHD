//
//  FindFlowRequest.h
//  SurfNewsHD
//
//  Created by Jerry Yu on 13-6-13.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SurfJsonRequestBase.h"

//流量查询
@interface FindFlowRequest : SurfJsonRequestBase
{
    
}
@property(nonatomic, copy)   NSString *userid;
@property(nonatomic, copy)   NSString *isAuto;

- (id)initWithUserId:(NSString *)userIdStr andISauto:(NSString *)isAutoStr;

@end
