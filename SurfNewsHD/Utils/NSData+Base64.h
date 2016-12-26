//
//  NSData+Base64.h
//  SurfNewsHD
//
//  Created by SYZ on 13-2-1.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Base64)

+ (id)dataWithBase64EncodedString:(NSString *)string;     //  Padding '=' characters are optional. Whitespace is ignored.
- (NSString *)base64Encoding;

@end
