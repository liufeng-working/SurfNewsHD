//
//  XmlUtils.h
//  SurfNewsHD
//
//  Created by yuleiming on 13-7-30.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libxml/tree.h>
#import <libxml/parser.h>

@interface XmlUtils : NSObject

//从@xml中获取第一个名为@nodeName的节点的内容
+(NSString*) contentOfFirstNodeNamed:(NSString*)nodeName inXml:(NSString*)xml;
// 获取相关推荐的内容
+ (NSString*)recommendOfFirstNode:(NSString*)xml;

// 解析images标签
+ (NSDictionary*)parseImagesNode:(NSString*)xml;

// 解析title标签信息
+ (BOOL)parseThreadSummaryInfo:(ThreadSummary*)ts xmlContent:(NSString*)xml;
@end
