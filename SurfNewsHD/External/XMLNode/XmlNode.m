//
//  XmlNode.m
//  XML Fun
//
//  Created by mac os on 11-10-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "XmlNode.h"


@implementation XmlNode

@synthesize attributes;
@synthesize childs;
@synthesize name;
@synthesize value;
@synthesize haveChilds;
@synthesize haveAttribute;
@synthesize xmlString;

- (void)dealloc
{
    [attributes release];
    [childs release];
    [name release];
    [value release];
    [xmlString release];
    [super dealloc];
}

-(void)addAttribute:(NSDictionary *)att
{
    if (attributes==nil)
        attributes = [[NSMutableDictionary alloc]init];
    [attributes addEntriesFromDictionary:att];
    if (!haveAttribute)
        haveAttribute = YES;
}

-(void)addChild:(XmlNode *)node
{
    if (childs==nil)childs = [[NSMutableArray alloc]init];
    [childs addObject:node];
    if (!haveChilds)
        haveChilds = YES;
}

-(NSString *)getNodeValue:(NSString *)nodeName
{
    if (haveChilds) {
        for (int i=0;i<[childs count];i++) {
            XmlNode *node = [childs objectAtIndex:i];
            if ([node.name isEqualToString:nodeName]) {
                return node.value;
            }
        }
    }
    return nil;
}

-(NSString *)getAttributeValue:(NSString *)attName
{
    if (haveAttribute) {
        return [attributes objectForKey:attName];
    }
    return nil;
}

-(NSString *)getXmlString
{
    xmlString = [[NSMutableString alloc]init];
    [self getNodeStr:self string:xmlString];
    return xmlString;
}

-(NSString *)getXmlStrFromHead:(NSString *)head
{
    xmlString = [[NSMutableString alloc]init];
    [xmlString appendString:head];
    [self getNodeStr:self string:xmlString];
    return xmlString;
}

-(void)getNodeStr:(XmlNode *)node string:(NSMutableString *)str
{
    if (!node.haveChilds) {
        if (node.haveAttribute) {
            NSMutableString *str2=[[[NSMutableString alloc]init]autorelease];
            if (node.haveAttribute) {
                NSMutableDictionary *atts = [node attributes];
                NSEnumerator *kes = [atts keyEnumerator];
                id key;
                while (key=[kes nextObject]) {
                    [str2 appendFormat:@" %@=\"%@\"",key,[atts objectForKey:key]];
                }
            }
            if (node.value == nil) {
                node.value = @"";
            }
            NSString *res = [[NSString alloc]initWithFormat:@"<%@%@>%@</%@>",
                             node.name,
                             str2,
                             node.value,
                             node.name];
            [str appendString:res];
            [res release];
        }else{
            NSString *res = [[NSString alloc]initWithFormat:@"<%@>%@</%@>",
                             node.name,
                             node.value,
                             node.name];
            [str appendString:res];
            [res release];
        }
    }else{
        NSMutableString *a = [[[NSMutableString alloc]init]autorelease];
        NSMutableArray *nodelist = [node childs];
        for (int i=0;i<[nodelist count];i++) {
            XmlNode *node = [nodelist objectAtIndex:i];
            [node getNodeStr:node string:a];
        }
        if (node.haveAttribute) {
            NSMutableString *str3=[[[NSMutableString alloc]init]autorelease];
            if (node.haveAttribute) {
                NSMutableDictionary *atts = [node attributes];
                NSEnumerator *kes = [atts keyEnumerator];
                id key;
                while (key=[kes nextObject]) {
                    [str3 appendFormat:@" %@=\"%@\"",key,[atts objectForKey:key]];
                }
            }
            NSString *res = [[NSString alloc]initWithFormat:@"<%@%@>%@</%@>",
                             node.name,
                             str3,
                             a,
                             node.name];
            [str appendString:res];
            [res release];
        }else{
            NSString *res = [[NSString alloc]initWithFormat:@"<%@>%@</%@>",
                             node.name,
                             a,
                             node.name];
            [str appendString:res];
            [res release];
        }        
    }
}

@end
