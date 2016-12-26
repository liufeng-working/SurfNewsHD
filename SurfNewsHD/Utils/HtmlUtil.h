//
//  HtmlUtil.h
//  SurfNewsHD
//
//  Created by yuleiming on 13-6-5.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libxml/tree.h>
#import <libxml/parser.h>
#import <libxml/xmlreader.h>
#import <libxml/HTMLparser.h>
#import <libxml/HTMLtree.h>

@interface NSString (xmlCharComparing)
-(BOOL)isEqualToXmlChar:(const xmlChar*)name;
-(const xmlChar*)convertToXmlChar;
@end


@interface HtmlUtil : NSObject

//获取名称为@name的所有后代节点（包含自身）
+(NSMutableArray*)descendantsOfXmlNode:(xmlNodePtr)node
                              withName:(NSString*)name;

//获取第一个名称为@name的后代节点（包含自身）
+(xmlNodePtr)firstDescendantOfXmlNode:(xmlNodePtr)node
                             withName:(NSString*)name;

//获取第一个XML_TEXT_NODE类型的节点（包含自身）
+(xmlNodePtr)firstDescendantTextNodeOfXmlNode:(xmlNodePtr)node;

//获取第一个临近的XML_TEXT_NODE类型的节点（包含自身）
+(xmlNodePtr)firstSiblingTextNodeOfXmlNode:(xmlNodePtr)node;

//获取第一个指定id的节点(包含自身)
+(xmlNodePtr)firstDescendantOfXmlNode:(xmlNodePtr)node
                               withId:(NSString*)htmlId;
@end
