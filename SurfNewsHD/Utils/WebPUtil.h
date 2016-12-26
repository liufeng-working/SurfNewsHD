//
//  WebPUtil.h
//  SurfNewsHD
//
//  Created by yuleiming on 13-1-21.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebPUtil : NSObject

//将webp转换成jpeg或者png
//如果webp原图带半透明，则转换成png
//如果webp原图不带半透明，则转换成jpg
//建议@targetPath不要带后缀，防止后缀名和实际文件格式不符
+(BOOL) convertWebP:(NSString *)srcPath saveAsJpgOrPng:(NSString *)targetPath;

+(BOOL) convertWebPData:(NSData *)data saveAsJpgOrPng:(NSString *)targetPath;

+(NSData*) convertWebPDataToJpgOrPngData:(NSData *)data;

@end
