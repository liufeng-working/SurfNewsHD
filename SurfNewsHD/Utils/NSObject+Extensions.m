//
//  NSObject+Extensions.m
//  SurfNewsHD
//
//  Created by yuleiming on 13-1-16.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "NSObject+Extensions.h"

@implementation NSObject(SurfExtensions)

-(NSNumber*)hashForDictionaryKey
{
    return [NSNumber numberWithUnsignedInteger:[self hash]];
}

@end
