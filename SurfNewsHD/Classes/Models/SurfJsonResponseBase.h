//
//  SurfJsonResponseBase.h
//  SurfNewsHD
//
//  Created by yuleiming on 13-1-5.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SurfRespResult : NSObject

@property(nonatomic,strong) NSString* reCode;
@property(nonatomic,strong) NSString* resMessage;

@end

@interface SurfJsonResponseBase : NSObject

@property(nonatomic,strong) SurfRespResult* res;

@end
