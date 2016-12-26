//
//  
//  AutomaticCoder
//
//  Created by 张玺自动代码生成器   http://zhangxi.me
//  Copyright (c) 2012年 me.zhangxi. All rights reserved.
//


#import "SurfJsonRequestBase.h"

@interface NewsTopRequest : SurfJsonRequestBase

@property NSInteger count;
@property NSString *dm;
@property NSInteger page;
@property NSString *scids;


-(id)initWithScids:(NSString *)scids with:(NSInteger)page;

@end
