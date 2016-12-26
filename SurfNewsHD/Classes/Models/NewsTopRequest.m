//
//
//  AutomaticCoder
//
//  Created by 张玺自动代码生成器  http://zhangxi.me
//  Copyright (c) 2012年 me.zhangxi. All rights reserved.
//
#import "NewsTopRequest.h"
@implementation NewsTopRequest


-(id)initWithScids:(NSString *)scids with:(NSInteger)page;
{
    self = [super init];
    if(self)
    {
        if(scids != nil)
        {
            self.count  = 4;
            CGSize size = [[UIScreen mainScreen] bounds].size;
            self.dm = [NSString stringWithFormat:@"%@*%@", @(size.width), @(size.height)];
            self.page  = page;
            self.scids  = scids;
        }
    }
    return self;
}

- (NSString *) description
{
    NSString *result = @"";
    result = [result stringByAppendingFormat:@"vercode : %d\n",self.vercode];
    result = [result stringByAppendingFormat:@"pm : %@\n",self.pm];
    result = [result stringByAppendingFormat:@"vername : %@\n",self.vername];
    result = [result stringByAppendingFormat:@"count : %@\n",@(self.count)];
    result = [result stringByAppendingFormat:@"cid : %@\n",self.cid];
    result = [result stringByAppendingFormat:@"os : %@\n",self.os];
    result = [result stringByAppendingFormat:@"sdkv : %@\n",self.sdkv];
    result = [result stringByAppendingFormat:@"dm : %@\n",self.dm];
    result = [result stringByAppendingFormat:@"did : %@\n",self.did];
    result = [result stringByAppendingFormat:@"page : %@\n",@(self.page)];
    result = [result stringByAppendingFormat:@"scids : %@\n",self.scids];
    
    return result;
}
@end
