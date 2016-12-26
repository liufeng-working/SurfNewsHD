//
//  UpdateSplashResponse.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-1-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "UpdateSplashResponse.h"

@implementation UpdateSplashResponse

@end

@implementation SplashNewsThreadSummary

@end


@implementation SplashData
@synthesize desc = __KEY_NAME_description;

- (BOOL)isEqualToSplashData:(SplashData*)object
{
    //注意：两个NSString都是nil，也认为相等
    if(self.newsstart)
    {
        if(![self.newsstart isEqualToString:object.newsstart])
            return NO;
    }
    else if(object.newsstart)
        return NO;
    
    if(self.newsend)
    {
        if(![self.newsend isEqualToString:object.newsend])
            return NO;
    }
    else if(object.newsend)
        return NO;
    
    if(self.newsImage)
    {
        if(![self.newsImage isEqualToString:object.newsImage])
            return NO;
    }
    else if(object.newsImage)
        return NO;
    
    if(self.newsTitle)
    {
        if(![self.newsTitle isEqualToString:object.newsTitle])
            return NO;
    }
    else if(object.newsTitle)
        return NO;
    
    if(self.desc)
    {
        if(![self.desc isEqualToString:object.desc])
            return NO;
    }
    else if(object.desc)
        return NO;
    
    if(self.color)
    {
        if(![self.color isEqualToString:object.color])
            return NO;
    }
    else if(object.color)
        return NO;
    
    if(self.openType != object.openType)
        return NO;
    
    if(self.jumpUrl)
    {
        if(![self.jumpUrl isEqualToString:object.jumpUrl])
            return NO;
    }
    else if(object.jumpUrl)
        return NO;
    
    if(self.jumpId != object.jumpId)
        return NO;
   
    if(self.infoNews)
    {
        if(![self.infoNews isEqualToThread:object.infoNews])
            return NO;
    }
    else if(object.infoNews)
        return NO;
    
    return YES;
}

@end