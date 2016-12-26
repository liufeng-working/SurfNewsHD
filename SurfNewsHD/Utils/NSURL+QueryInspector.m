//
//  NSURL+QueryInspector.m
//  SurfNewsHD
//
//  Created by SYZ on 13-1-8.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "NSURL+QueryInspector.h"
#import "NSDictionary+QueryString.h"

@implementation NSURL (QueryInspector)

- (NSDictionary *)queryDictionary;
{
    return [NSDictionary dictionaryWithFormEncodedString:self.query];
}

@end
