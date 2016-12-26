//
//  UpdateSplashRequest.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-1-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "UpdateSplashRequest.h"

@implementation UpdateSplashRequest
-(id)init
{
    if(self=[super init])
    {
        CGSize size = [[UIScreen mainScreen] bounds].size;
        CGFloat scale = [UIScreen mainScreen].scale;
        self.resolution = [NSString stringWithFormat:@"%d*%d", (int)(size.width * scale), (int)(size.height * scale) ];
    }
    return self;
}
@end
