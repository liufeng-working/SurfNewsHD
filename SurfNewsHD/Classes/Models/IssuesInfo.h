//
//  IssuesInfo.h
//  SurfNewsHD
//
//  Created by SYZ on 13-8-6.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IssuesInfo : NSObject

@property long magId;
@property long issId;
@property long zipBytes;
@property NSString *name;
@property NSString *zipUrl;
@property NSString *localFileName;

@end

@interface OfflinesMagazines : NSObject

@property NSMutableArray *issues;

@end