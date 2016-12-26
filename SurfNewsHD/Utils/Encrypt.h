//
//  Encrypt.h
//  SurfNewsHD
//
//  Created by SYZ on 13-3-25.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Encrypt : NSObject

+ (NSString*)encryptUseDES:(NSString *)plainText;
+ (NSString*)decryptUseDES:(NSString *)plainText;

@end
