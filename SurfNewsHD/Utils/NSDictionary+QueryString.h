//
//  NSDictionary+QueryString.h
//  SurfNewsHD
//
//  Created by SYZ on 13-1-8.
//  Copyright (c) 2013年 apple. All rights reserved.
//

@interface NSDictionary (QueryString)

+ (NSDictionary *)dictionaryWithFormEncodedString:(NSString *)encodedString;
- (NSString *)stringWithFormEncodedComponents;

@end
