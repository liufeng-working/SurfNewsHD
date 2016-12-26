//
//  DataGB2312Encoded.m
//  SurfNewsHD
//
//  Created by apple on 12-11-19.
//  Copyright (c) 2012年 apple. All rights reserved.
//

#import "DataGB2312Encoded.h"

@implementation DataGB2312Encoded
+(NSString *)dataGB2312EncodedString:(NSData *)data{
    NSStringEncoding enc =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString* aStr = [[NSString alloc] initWithData:data encoding:enc];
    return aStr;
}
@end
