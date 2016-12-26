//
//  XmlUtils.m
//  SurfNewsHD
//
//  Created by yuleiming on 13-7-30.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "XmlUtils.h"
#import "HtmlUtil.h"
#import "NSString+Extensions.h"



@implementation XmlUtils

//由于逻辑比较简单，暂使用regex实现
+(NSString*) contentOfFirstNodeNamed:(NSString*)nodeName inXml:(NSString*)xml
{
    NSRegularExpression* reg = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"<\\s*%@\\s*>(?:<!\\[CDATA\\[)?(.*?)(?:\\]\\]>)?\\s*<\\s*/content\\s*>",nodeName] options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators error:nil];
    NSTextCheckingResult* m = [reg firstMatchInString:xml options:0 range:NSMakeRange(0, [xml length])];
    if(m)
    {
        return [xml substringWithRange:[m rangeAtIndex:1]];
    }
    else
        return @"";
}


// 上面的节点是不能获取到其它节点，我也不会修改，只能自己搞一个吧
// 获取相关推荐的内容
+ (NSString*)recommendOfFirstNode:(NSString*)xml
{
    if (xml &&xml.length > 0) {
        NSString *beginRecommend = @"<recommends";
        NSString *endRecommend = @"</recommends>";
        
        NSRange bR = [xml rangeOfString:beginRecommend options:NSBackwardsSearch];
        NSRange eR = [xml rangeOfString:endRecommend options:NSBackwardsSearch];
        
        if (bR.location != NSNotFound && eR.location != NSNotFound) {
            NSUInteger length = eR.location + eR.length - bR.location;
            return [xml substringWithRange:NSMakeRange(bR.location, length)];
        }
        
    }
    return @"";
}

// 解析images标签
+ (NSDictionary*)parseImagesNode:(NSString*)xml
{
    if (xml &&xml.length > 0) {        
        NSString *beginImgs = @"<images";
        NSString *endImgs = @"</images>";        
        NSRange bR = [xml rangeOfString:beginImgs options:NSBackwardsSearch];
        NSRange eR = [xml rangeOfString:endImgs options:NSBackwardsSearch];
        
        if (bR.location != NSNotFound && eR.location != NSNotFound) {
            NSUInteger length = eR.location + eR.length - bR.location;
            NSString *imgsContent = [xml substringWithRange:NSMakeRange(bR.location, length)];
            
            NSData* imgsData = [imgsContent dataUsingEncoding:NSUTF8StringEncoding];
            xmlDocPtr doc = htmlReadMemory([imgsData bytes], (int)[imgsData length],
                                           NULL,    //url
                                           "utf-8", //encoding
                                           HTML_PARSE_RECOVER |     //keep parsing even errors
                                           HTML_PARSE_NOWARNING |   //no warning reported
                                           HTML_PARSE_NOERROR |     //no error reported
                                           HTML_PARSE_NOBLANKS |    //remove blanks
                                           HTML_PARSE_NONET |
                                           HTML_PARSE_NOIMPLIED |
                                           HTML_PARSE_COMPACT);
            xmlNodePtr rootNode = xmlDocGetRootElement(doc);
            NSArray* imgsNodesArray = [HtmlUtil descendantsOfXmlNode:rootNode withName:@"img"];
            NSMutableDictionary *imgsDict = [NSMutableDictionary dictionaryWithCapacity:5];
            for (NSValue* imgNodeP in imgsNodesArray) {
                xmlNodePtr imgNode = (xmlNodePtr)[imgNodeP pointerValue];                
                // id
                xmlAttrPtr idAttr = xmlHasProp(imgNode, BAD_CAST "surf_img_id");
                xmlChar* idXmlCharVal = xmlGetProp(imgNode, BAD_CAST"surf_img_id");
                //scr
                xmlAttrPtr scrAttr = xmlHasProp(imgNode, BAD_CAST "src");
                xmlChar* scrXmlCharVal = xmlGetProp(imgNode, BAD_CAST"src");
                if (idAttr && idXmlCharVal && scrAttr && scrXmlCharVal) {
                    
                    NSString *key = [NSString stringWithUTF8String:(char*)idXmlCharVal];
                    NSString *object = [NSString stringWithUTF8String:(char*)scrXmlCharVal];
                    [imgsDict setObject:object forKey:key];
                }
            }
            
            // 释放内存
            xmlFreeDoc(doc);
            
            if (imgsDict.count > 0) {
                return imgsDict;
            }
        }
    }
    return nil;
}

// 解析title标签信息
+ (BOOL)parseThreadSummaryInfo:(ThreadSummary*)ts
                   xmlContent:(NSString*)xml
{
    BOOL isParse = NO;
    if (!xml || [xml isEmptyOrBlank])
        return isParse;
        
        
    if ([ts.title isEmptyOrBlank] ||
        [ts.source isEmptyOrBlank] ||
        ts.time <=0)
    {

 
        NSData* xmlData = [xml dataUsingEncoding:NSUTF8StringEncoding];
        xmlDocPtr doc = xmlParseMemory([xmlData bytes], (int)[xmlData length]);
        xmlNodePtr rootNode = xmlDocGetRootElement(doc);
        if (!rootNode) {
            return isParse;
        }
        
        
        
        NSInteger i=0;
        xmlNodePtr node;
        xmlChar *value;
        NSString *newID,*title,*from,*time;
        for(node=rootNode->children;node;node=node->next){
            if(xmlStrcasecmp(node->name,BAD_CAST"title")==0){
                ++i;
                value=xmlNodeGetContent(node);
                title = [NSString stringWithUTF8String:(char*)value];
                xmlFree(value);
            }
            else if (xmlStrcasecmp(node->name,BAD_CAST"id")==0){
                ++i;
                value=xmlNodeGetContent(node);
                newID = [NSString stringWithUTF8String:(char*)value];
                xmlFree(value);
            }
            else if (xmlStrcasecmp(node->name,BAD_CAST"from")==0){
                ++i;
                value=xmlNodeGetContent(node);
                from = [NSString stringWithUTF8String:(char*)value];
                xmlFree(value);
            }
            else if (xmlStrcasecmp(node->name,BAD_CAST"time")==0){
                ++i;
                value=xmlNodeGetContent(node);
                time = [NSString stringWithUTF8String:(char*)value];
                xmlFree(value);
            }
            if (i>=4) {
                break;
            }
        }

        if (newID.integerValue == ts.threadId) {
            isParse = YES;
            ts.time = [time doubleValue];
            ts.source = from;
            ts.title = title;
        }
        
        xmlFreeDoc(doc);
    }
    return isParse;
}
                                           
@end
