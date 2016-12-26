//
//  NSDictionary+QueryString.h
//  SurfNewsHD
//
//  Created by SYZ on 13-1-8.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "NSDictionary+QueryString.h"
#import "NSString+Extensions.h"

@implementation NSDictionary (QueryString)

+ (NSDictionary *)dictionaryWithFormEncodedString:(NSString *)encodedString
{
    NSMutableDictionary* result = [NSMutableDictionary dictionary];
    NSArray* pairs = [encodedString componentsSeparatedByString:@"&"];
    
    for (NSString* kvp in pairs) {
        if ([kvp length] == 0)
            continue;
        
        NSRange pos = [kvp rangeOfString:@"="];
        NSString *key;
        NSString *val;
        
        if (pos.location == NSNotFound) {
            key = [kvp urlEncodedString];
            val = @"";
        } else {
            key = [[kvp substringToIndex:pos.location] urlEncodedString];
            val = [[kvp substringFromIndex:pos.location + pos.length] urlEncodedString];
        }
        
        if (!key || !val)
            continue; // I'm sure this will bite my arse one day
        
        [result setObject:val forKey:key];
    }
    return result;
}

- (NSString *)stringWithFormEncodedComponents
{
    NSMutableArray* arguments = [NSMutableArray arrayWithCapacity:[self count]];
    for (NSString* key in self) {
        [arguments addObject:[NSString stringWithFormat:@"%@=%@",
                              [key urlEncodedString],
                              [[[self objectForKey:key] description] urlEncodedString]]];
    }
    
    return [arguments componentsJoinedByString:@"&"];
}

@end
