//
//  HtmlUtil.m
//  SurfNewsHD
//
//  Created by yuleiming on 13-6-5.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "HtmlUtil.h"
#import "NSString+Extensions.h"

@implementation NSString (xmlCharComparing)
-(BOOL)isEqualToXmlChar:(const xmlChar*)name
{
    return [self isEqualToStringCaseInsensitive:[NSString stringWithUTF8String:(const char*)name]];
}
-(const xmlChar*)convertToXmlChar
{
    return BAD_CAST[self cStringUsingEncoding:NSUTF8StringEncoding];
}
@end


@implementation HtmlUtil

//获取名称为@name的所有后代节点（包含自身）
+(NSMutableArray*)descendantsOfXmlNode:(xmlNodePtr)node
                              withName:(NSString*)name
{
    //NSString* nn = [NSString stringWithUTF8String:node->name];
    //NSLog(@"%@",nn);

//    NSMutableArray* array = [NSMutableArray new];
//
//    xmlNodePtr child = node->children;
//    if (child)
//    {
//        [array addObjectsFromArray:[self descendantsOfXmlNode:child withName:name]];
//    }
//    
//    //从邻居中搜索
//    xmlNodePtr sibNode = node->next;
//    if(sibNode)
//    {
//        [array addObjectsFromArray:[self descendantsOfXmlNode:sibNode withName:name]];
//    }
//    
//    //该节点本身符合条件
//    if(node->name && [name isEqualToXmlChar:node->name])
//        [array addObject:[NSValue valueWithPointer:node]];
//
//    return array;
    
    
    NSMutableArray* array = [NSMutableArray new];
    
    //该节点本身符合条件
    if(node->name && [name isEqualToXmlChar:node->name])
        [array addObject:[NSValue valueWithPointer:node]];
    
    if(node->children)  //node还有子节点
    {
        //node的第一个子节点
        [array addObjectsFromArray:[self descendantsOfXmlNode:node->children withName:name]];
        
        //遍历node的其余子节点
        node = node->children->next;
        while(node)
        {
            [array addObjectsFromArray:[self descendantsOfXmlNode:node withName:name]];
            node = node->next;
        }
    }
    
    return array;
}

//获取第一个名称为@name的后代节点（包含自身）
+(xmlNodePtr)firstDescendantOfXmlNode:(xmlNodePtr)node
                             withName:(NSString*)name
{
    if(node->name && [name isEqualToXmlChar:node->name])
        return node;
    
    if(node->children)  //node还有子节点
    {
        //在第一个子节点的后代中寻找，如果找到则将其返回
        xmlNodePtr n = [self firstDescendantOfXmlNode:node->children withName:name];
        if(n)
            return n;
        
        //在其余子节点的后代中寻找，如果找到则返回
        node = node->children->next;
        while(node)
        {
            n = [self firstDescendantOfXmlNode:node withName:name];
            if(n)
                return n;
            node = node->next;
        }
    }
    return NULL;
}

//获取第一个XML_TEXT_NODE类型的节点（包含自身）
+(xmlNodePtr)firstDescendantTextNodeOfXmlNode:(xmlNodePtr)node
{
    if(node->type == XML_TEXT_NODE && !xmlIsBlankNode(node))
        return node;
    else if(node->children) //node 还有子节点
    {
        //在第一个子节点的后代中寻找
        xmlNodePtr n = [self firstDescendantTextNodeOfXmlNode:node->children];
        if(n)
            return n;
        
        //在其余子节点的后代中寻找
        node = node->children->next;
        while(node)
        {
            n = [self firstDescendantTextNodeOfXmlNode:node];
            if(n)
                return n;
            node = node->next;
        }
    }
    return NULL;
}

+(xmlNodePtr)firstSiblingTextNodeOfXmlNode:(xmlNodePtr)node
{
    //自身是文字节点
    if(node->type == XML_TEXT_NODE && !xmlIsBlankNode(node))
        return node;
    
    //从兄弟节点中寻找
    xmlNodePtr p = node->next;
    while (p)
    {
        if(p->type == XML_TEXT_NODE && !xmlIsBlankNode(p))
            return p;
        p = p->next;
    }
    
    //从所有的兄弟中都找不到文字节点
    //尝试从父亲的兄弟的后代中寻找
    xmlNodePtr parent = node->parent;
    p = parent->next;
    while (p)
    {
        xmlNodePtr t = [self firstDescendantTextNodeOfXmlNode:p];
        if(t)
            return t;
        p = p->next;
    }

    return NULL;
}

+(xmlNodePtr)firstDescendantOfXmlNode:(xmlNodePtr)node
                               withId:(NSString*)htmlId
{
    //检测自身
    if(xmlHasProp(node, BAD_CAST"id"))
    {
        xmlChar* idVal = xmlGetProp(node, BAD_CAST"id");
        BOOL match = [htmlId isEqualToXmlChar:idVal];
        xmlFree(idVal);
        if (match)
        {
            return node;
        }
    }
    
    if(node->children) //node 还有子节点
    {
        //在第一个子节点的后代中寻找
        xmlNodePtr n = [self firstDescendantOfXmlNode:node->children withId:htmlId];
        if(n)
            return n;
        
        //在其余子节点的后代中寻找
        node = node->children->next;
        while(node)
        {
            n = [self firstDescendantOfXmlNode:node withId:htmlId];
            if(n)
                return n;
            node = node->next;
        }
    }
    return NULL;
}

@end
