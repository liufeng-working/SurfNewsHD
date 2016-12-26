//
//  NSDictionary+DictionaryWithString.m
//  SurfNewsHD
//
//  Created by 潘俊申 on 15/7/7.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "NSDictionary+DictionaryWithString.h"

@implementation NSDictionary (DictionaryWithString)
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if (err) {
        NSLog(@"解析出错了%@ 解析出错了",err);
        return nil;
    }
    else {
        return dict;
    }
}
@end
