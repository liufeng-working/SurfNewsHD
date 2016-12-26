//
//  ThreadContentResolver.m
//  SurfNewsHD
//
//  Created by yuleiming on 13-1-22.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "ThreadContentResolver.h"
#import "SurfHtmlGenerator.h"
#import "HtmlUtil.h"
#import "PathUtil.h"
#import "NSString+Extensions.h"
#import "ThreadsManager.h"
#import "EzJsonParser.h"
#import "FileUtil.h"
#import "AppSettings.h"
#import "ThemeMgr.h"
#import "ClientFunctionManager.h"
//#import "Recommends.h"
#import "ThreadSummary.h"
//#import "AdvertisementManager.h"

@implementation ThreadContentImageInfo
@end

@implementation ThreadContentImageInfoV2
@end


@implementation ThreadContentResolvingResultV2
-(id)init
{
    if(self = [super init])
    {
        self->_contentImgInfoArray = [NSMutableArray new];
    }
    return self;
}

-(BOOL)_hasUndownloadedImage
{
    for (ThreadContentImageInfoV2 *img in self.contentImgInfoArray)
    {
        if(!img.isLocalImageReady)
            return YES;
    }
    return NO;
}
@end

@implementation ThreadContentImageMapping
-(id)init
{
    return nil;
}
-(id)initWithThread:(ThreadSummary*)thread
{
    if(self = [super init])
    {
        mappingPath_ = [PathUtil pathOfThreadImageMapping:thread];
        
        //从文件读取映射关系
        NSData* data = [NSData dataWithContentsOfFile:mappingPath_];
        if(data)
        {
            dict_ = [EzJsonParser deserializeFromJson:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] AsType:[NSMutableDictionary class]];
        }
        else
        {
            dict_ = [NSMutableDictionary new];
        }
    }
    return self;
}
-(BOOL)containsUrl:(NSString*)url
{
    return [dict_ objectForKey:url] != nil;
}
-(NSString*)getImgLocalFileNameWithUrl:(NSString*)url
{
    return [dict_ objectForKey:url];
}
-(void)addMappingWithUrl:(NSString*)url andImgLocalFileName:(NSString*)fileName
{
    [dict_ setObject:[fileName lastPathComponent] forKey:url];
    [[EzJsonParser serializeObjectWithUtf8Encoding:dict_] writeToFile:mappingPath_ atomically:YES encoding:NSUTF8StringEncoding error:nil];
}
-(void)removeMappingWithUrl:(NSString*)url
{
    [dict_ removeObjectForKey:url];
    [[EzJsonParser serializeObjectWithUtf8Encoding:dict_] writeToFile:mappingPath_ atomically:YES encoding:NSUTF8StringEncoding error:nil];
}
@end


@implementation ThreadContentResolver

#pragma mark - 手机报
+(NSString*) resolveContent:(NSString*)content
                                OfPhoneNewsData:(PhoneNewsData*)thread
{
    if (!content || content.length <=0) {
        return nil;
    }
    NSRegularExpression* reg = [NSRegularExpression regularExpressionWithPattern:@"(?:<a\\s+href\\s*=\\s*['\"]([^'\"]+)['\"][^>]*?\\s*>\\s*)?(<img\\b[^>]+>\\s*<\\s*/img\\s*>|<img\\b[^<>]+>)" options:NSRegularExpressionCaseInsensitive |  NSRegularExpressionDotMatchesLineSeparators error:nil];
    NSArray* matches = [reg matchesInString:content options:0 range:NSMakeRange(0, [content length])];
    

    int i = 0;
    int idxOffset = 0;
    NSMutableString* sb = [[NSMutableString alloc] initWithCapacity:[content length]];
    [sb setString:content];
    for (NSTextCheckingResult* m in matches)
    {
        //imgHtml形如：<img src='bigboobs.jpg' />
        NSString* imgHtml = [content substringWithRange:[m rangeAtIndex:2]];
        NSData* imgData = [imgHtml dataUsingEncoding:NSUTF8StringEncoding];
        xmlDocPtr doc = htmlReadMemory([imgData bytes], (int)[imgData length], "", 0, HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR | HTML_PARSE_NOBLANKS | HTML_PARSE_NONET | HTML_PARSE_NOIMPLIED);
        
        xmlNodePtr root = xmlDocGetRootElement(doc);
        xmlNodePtr imgNode = [HtmlUtil firstDescendantOfXmlNode:root withName:@"img"];
        xmlAttrPtr srcAttr = xmlHasProp(imgNode, BAD_CAST "src");
        xmlChar* srcXmlCharVal = xmlGetProp(imgNode, BAD_CAST"src");
//        NSString* srcAttrVal1 = [NSString stringWithUTF8String:(char*)srcXmlCharVal];
//        DJLog(@"%@",srcAttrVal1);
        if(srcAttr && srcXmlCharVal)
        {
            //改写id
            NSString* idVal = [@"img" stringByAppendingFormat:@"%d",i];
            xmlSetProp(imgNode, BAD_CAST"id", [idVal convertToXmlChar]);
            NSString* srcAttrVal = [NSString stringWithUTF8String:(char*)srcXmlCharVal];
            
            if([[srcAttrVal trimLeft] hasPrefixCaseInsensitive:@"data:image/"])
            {
                //Data URI方式的src
            }
            else
            {
                PhoneNewsManager *manager = [PhoneNewsManager sharedInstance];
                NSString* originalUrl = [manager getUnzipPath:thread];
                NSString *path = [NSString stringWithFormat:@"file://%@/%@",originalUrl,srcAttrVal];
                xmlSetProp(imgNode, BAD_CAST"src", [path
                                                    convertToXmlChar]);
                DJLog(@"%@",path);
            }

            //改写width,height
            //imgNode.Attributes.Remove("width");
            //imgNode.Attributes.Remove("height");
            //imgNode.SetAttributeValue("width", "400px");
            //imgNode.SetAttributeValue("height", "auto");
            
            //onclick
            if(xmlHasProp(imgNode, BAD_CAST"onclick"))
                xmlSetProp(imgNode, BAD_CAST"onclick", BAD_CAST"onImgClick();");
            else
                xmlNewProp(imgNode, BAD_CAST"onclick", BAD_CAST"onImgClick();");
            
            //onload
            if(xmlHasProp(imgNode, BAD_CAST"onload"))
                xmlSetProp(imgNode, BAD_CAST"onload", BAD_CAST"imgOnLoad();");
            else
                xmlNewProp(imgNode, BAD_CAST"onload", BAD_CAST"imgOnLoad();");
            
            //该img被包在<a></a>中
            if ([m rangeAtIndex:1].location != NSNotFound)
            {
                //将href保存在img中，以备以后需要用
                xmlNewProp(imgNode, BAD_CAST"img_href", [[content substringWithRange:[m rangeAtIndex:1]] convertToXmlChar]);
            }
            
            //输出修改过后的img标签的html
            xmlBufferPtr buffer = xmlBufferCreate();
            htmlNodeDump(buffer, doc, imgNode);
            NSString* imgFixed = [NSString stringWithUTF8String:(char*)buffer->content];
            xmlBufferFree(buffer);
            
            //更新html页面源码
            [sb replaceCharactersInRange:NSMakeRange([m rangeAtIndex:2].location + idxOffset, [imgHtml length]) withString:imgFixed];
            idxOffset += [imgFixed length] - [imgHtml length];
            
            xmlFree(srcXmlCharVal);
        }
        i++;
        xmlFreeDoc(doc);
    }
    
//    [self resolveATags:sb];
    sb = [self resolvePTags:sb];
    return sb;

}

+(NSMutableString*)resolvePTags:(NSString*)content
{
    //把每个<p>都设置成 class="pStyle"
    NSRegularExpression* reg = [NSRegularExpression regularExpressionWithPattern:@"<p[^/<>]*?/>|<p[^>]*>.+?<\\s*/p>" options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators error:nil];
    NSArray* matches = [reg matchesInString:content options:0 range:NSMakeRange(0, [content length])];
    
    int i = 0;
    int idxOffset = 0;
    NSMutableString* sb = [[NSMutableString alloc] initWithCapacity:[content length]];
    [sb setString:content];
    for (NSTextCheckingResult* m in matches)
    {
        NSString* pHtml = [content substringWithRange:m.range];
        NSData* pData = [pHtml dataUsingEncoding:NSUTF8StringEncoding];
        xmlDocPtr doc = htmlReadMemory([pData bytes], (int)[pData length], "", 0, HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR | HTML_PARSE_NOBLANKS | HTML_PARSE_NONET | HTML_PARSE_NOIMPLIED);
        
        xmlNodePtr root = xmlDocGetRootElement(doc);
        xmlNodePtr pNode = [HtmlUtil firstDescendantOfXmlNode:root withName:@"p"];
        
        xmlAttrPtr classAttr = xmlHasProp(pNode, BAD_CAST "class");
        if(classAttr)
            xmlSetProp(pNode, BAD_CAST"class", [@"pStyle" convertToXmlChar]);
        else
            xmlNewProp(pNode, BAD_CAST"class", [@"pStyle" convertToXmlChar]);
        
        if(xmlHasProp(pNode, BAD_CAST"align"))
            xmlSetProp(pNode, BAD_CAST"align", [@"left" convertToXmlChar]);
        else
            xmlNewProp(pNode, BAD_CAST"align", [@"left" convertToXmlChar]);
       
#ifndef ipad
        if([pHtml rangeOfString:@"<img"].location != NSNotFound)
        {
            //该<p>中包含<img>，则该<p>无须设置style="text-indent:2em"
            if(xmlHasProp(pNode, BAD_CAST"style"))
                xmlSetProp(pNode, BAD_CAST"style", [@"" convertToXmlChar]);
            else
                xmlNewProp(pNode, BAD_CAST"style", [@"" convertToXmlChar]);
        }
#endif
        
        //去掉p正文的前导空格符
        xmlNodePtr pTxt = [HtmlUtil firstDescendantTextNodeOfXmlNode:pNode];
        if(pTxt)
        {
            xmlChar* txt = xmlNodeGetContent(pTxt);
            if(txt)
            {
                NSString* strTxt = [NSString stringWithUTF8String:(char*)txt];
                strTxt = [strTxt trimLeft];
                const xmlChar* txtMod = [strTxt convertToXmlChar];
                xmlNodeSetContent(pTxt, txtMod);
            }
            xmlFree(txt);
        }
        
        //输出修改过后的img标签的html
        xmlBufferPtr buffer = xmlBufferCreate();
        htmlNodeDump(buffer, doc, pNode);
        NSString* pFixed = [NSString stringWithUTF8String:(char*)buffer->content];
        xmlBufferFree(buffer);
        
        //更新html页面源码
        [sb replaceCharactersInRange:NSMakeRange(m.range.location + idxOffset, [pHtml length]) withString:pFixed];
        idxOffset += [pFixed length] - [pHtml length];

        i++;
        xmlFreeDoc(doc);
    }
    
    return sb;
}

//@imgDict: key--image_id;value--image_src
+(ThreadContentResolvingResultV2*) resolveContentV2:(NSString*)content
                                           imgsDict:(NSDictionary*)imgDict
                                           OfThread:(ThreadSummary*)thread
{
 
    
    ThreadContentResolvingResultV2* result = [ThreadContentResolvingResultV2 new];
    
    ThreadContentImageMapping* imgMapping = [[ThreadContentImageMapping alloc] initWithThread:thread];
    

    NSMutableString* contentFixed = [NSMutableString stringWithString:content];
    //去掉<content>BODY</content>的前后缀
    NSString* contentPrefix = @"<content>";
    NSString* contentSuffix = @"</content>";
    if([contentFixed hasPrefixCaseInsensitive:contentPrefix])
        [contentFixed deleteCharactersInRange:NSMakeRange(0, [contentPrefix length])];
    if([contentFixed hasSuffixCaseInsensitive:contentSuffix])
        [contentFixed deleteCharactersInRange:NSMakeRange([contentFixed length] - [contentSuffix length], [contentSuffix length])];
    
    // modified by xuxg on 2014.9.1
    // 只有“订阅频道"的正文才干掉 <a>标签和<font>标签
    if (thread.threadM == SubChannelThread) {
        ///////去掉所有<a>和</a>
        NSRegularExpression* reg = [NSRegularExpression regularExpressionWithPattern:@"</?a[^>]*>" options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators error:nil];
        [reg replaceMatchesInString:contentFixed
                            options:0
                              range:NSMakeRange(0, [contentFixed length])
                       withTemplate:@""];
        
        ///////干掉所有的<FONT depth="10" size="1" id="surf_id3">...</FONT>
        //防止影响正文字体大小
        NSRegularExpression* reg5 = [NSRegularExpression regularExpressionWithPattern:@"</?font[^>]*>" options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators error:nil];
        [reg5 replaceMatchesInString:contentFixed options:0 range:NSMakeRange(0, [contentFixed length]) withTemplate:@""];
        
        ///////干掉所有<SPAN></SPAN>
        // 用来区分文本与文件之间的差异
        NSRegularExpression* reg3 = [NSRegularExpression regularExpressionWithPattern:@"</?span[^>]*>" options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators error:nil];
        [reg3 replaceMatchesInString:contentFixed options:0 range:NSMakeRange(0, [contentFixed length]) withTemplate:@""];
    }

    
    ////////干掉所有<h1></h1>、<h6></h6>节点
    NSRegularExpression* reg1 = [NSRegularExpression regularExpressionWithPattern:@"<h[1-6]\\s*[^>]*\\s*>.*?</h[1-6]\\s*>" options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators error:nil];
    [reg1 replaceMatchesInString:contentFixed options:0 range:NSMakeRange(0, [contentFixed length]) withTemplate:@""];
    
    ///////干掉所有<DT><DL><DD>
    NSRegularExpression* reg2 = [NSRegularExpression regularExpressionWithPattern:@"</?d[ltd][^>]*?>" options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators error:nil];
    [reg2 replaceMatchesInString:contentFixed options:0 range:NSMakeRange(0, [contentFixed length]) withTemplate:@""];
    
 
    
    ///////干掉所有的bgcolor，防止影响夜间模式
    NSRegularExpression* reg4 = [NSRegularExpression regularExpressionWithPattern:@"\\s*bgcolor\\s*=\\s*\\S+" options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators error:nil];
    [reg4 replaceMatchesInString:contentFixed options:0 range:NSMakeRange(0, [contentFixed length]) withTemplate:@""];
    

    
    NSData* htmlData = [contentFixed dataUsingEncoding:NSUTF8StringEncoding];
    xmlDocPtr doc = htmlReadMemory([htmlData bytes], (int)[htmlData length],
                                   NULL,    //url
                                   "utf-8", //encoding
                                   HTML_PARSE_RECOVER | //keep parsing even errors
                                   HTML_PARSE_NOWARNING |   //no warning reported
                                   HTML_PARSE_NOERROR |     //no error reported
                                   HTML_PARSE_NOBLANKS |    //remove blanks
                                   HTML_PARSE_NONET |
                                   HTML_PARSE_NOIMPLIED |
                                   HTML_PARSE_COMPACT);
    
    xmlNodePtr rootNode = xmlDocGetRootElement(doc);
    

    
    
    
    ////////对【新鲜送】进行特殊处理
    BOOL isFromXinXianSong = (thread.channelId == 59232681 && SubChannelThread==thread.threadM);
    BOOL isXinXianSongTitlePFixed = NO; //是否已经把冗余标题段落干掉过
    
    ////////处理所有p节点
    NSArray* pNodesArray = [HtmlUtil descendantsOfXmlNode:rootNode withName:@"p"];
    for (NSValue* pNodeP in pNodesArray)
    {
        xmlNodePtr pNode = (xmlNodePtr)[pNodeP pointerValue];
        
        ////////对【新鲜送】进行特殊处理
        //干掉如下的段落
        //<P align="center" depth="2">人生六大阶段该如何护眼？
        //<BR depth="3"/>[2013-06-06 07:40]</P>
        if(isFromXinXianSong && !isXinXianSongTitlePFixed)
        {
            xmlChar* pContent = xmlNodeGetContent(pNode);
            if(pContent)
            {
                NSString* pContentStr = [NSString stringWithUTF8String:(char*)pContent];
                NSRegularExpression* reg = [NSRegularExpression regularExpressionWithPattern:@"\\[\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}\\]$" options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators error:nil];
                NSUInteger m = [reg numberOfMatchesInString:pContentStr options:0 range:NSMakeRange(0, [pContentStr length])];
                if(m == 1)
                {
                    isXinXianSongTitlePFixed = YES;
                    xmlUnlinkNode(pNode);
                    xmlFreeNode(pNode);
                    xmlFree(pContent);
                    continue;
                }
            }
            xmlFree(pContent);
        }
        
        //原文中有些带有text-indent:2em，有些没带
        //这里统一加上
        xmlSetProp(pNode, BAD_CAST"style", BAD_CAST"text-indent:2em");
        
        //去除前导空格
        xmlNodePtr pTxt = [HtmlUtil firstDescendantTextNodeOfXmlNode:pNode];
        if(pTxt)
        {
            xmlChar* txt = xmlNodeGetContent(pTxt);
            if(txt)
            {
                NSString* strTxt = [NSString stringWithUTF8String:(char*)txt];
                strTxt = [strTxt trimLeft];
                const xmlChar* txtMod = [strTxt convertToXmlChar];
                xmlNodeSetContent(pTxt, txtMod);
            }
            xmlFree(txt);
        }
    
        /*
        //如果p的align=center，则干掉text-indent:2em，否则不居中
        if(xmlHasProp(pNode, BAD_CAST"align"))
        {
            xmlChar* align = xmlGetProp(pNode, BAD_CAST"align");
            if([@"center" isEqualToXmlChar:align])
            {
                xmlSetProp(pNode, BAD_CAST"style", BAD_CAST"");
            }
            xmlFree(align);
        }
         */
    }

    ////////处理id="articleText"的节点，将其style清空，否则有可能出现style="width:930px;"
    //这种情况，导致页面超长。这是服务端的一个bug，只能在客户端进行捡漏了
    xmlNodePtr pArticleText = [HtmlUtil firstDescendantOfXmlNode:rootNode withId:@"articleText"];
    if(pArticleText)
    {
        xmlSetProp(pArticleText, BAD_CAST"style", BAD_CAST"");
    }
    
    //2013-11-15,处理div,把<div class="imgLoding">...</div>整个unlink掉，此段是安卓的loading图方案
    NSArray* divNodesArray = [HtmlUtil descendantsOfXmlNode:rootNode withName:@"div"];
    for (NSValue* divNodeP in divNodesArray)
    {
        xmlNodePtr divNode = (xmlNodePtr)[divNodeP pointerValue];
        if(xmlHasProp(divNode, BAD_CAST"class"))
        {
            xmlChar* clsVal = xmlGetProp(divNode, BAD_CAST"class");
            if(clsVal)
            {
                NSString* clsStr = [NSString stringWithUTF8String:(char*)clsVal];
                if([clsStr isEqualToStringCaseInsensitive:@"imgLoding"])
                {
                    xmlUnlinkNode(divNode);
                    xmlFreeNode(divNode);
                }
            }
            xmlFree(clsVal);
        }
    }
    
    ////////处理所有img节点
    ReaderPicMode picMode = [AppSettings integerForKey:IntKey_ReaderPicMode];
  
    NSArray* imgNodesArray = [HtmlUtil descendantsOfXmlNode:rootNode withName:@"img"];
    int i = 0;
    for (NSValue* imgNodeP in imgNodesArray)
    {
        xmlNodePtr imgNode = (xmlNodePtr)[imgNodeP pointerValue];
        
        ///////对【新鲜送】进行特殊处理
        //搞死【新鲜送】中的快讯广告图
        //广告图一定是第一个img，所以仅需要i==0时检测即可
        //59232681为新鲜送的channelid
        if(i == 0 && isFromXinXianSong)
        {
            xmlChar* w = xmlGetProp(imgNode, BAD_CAST"width");
            xmlChar* h = xmlGetProp(imgNode, BAD_CAST"height");
            BOOL isAd = (xmlStrcmp(w, BAD_CAST"180") == 0
            && xmlStrcmp(h, BAD_CAST"55") == 0);
            xmlFree(w);
            xmlFree(h);
            if(isAd)
            {
                //广告img后面可能紧跟三个BR，也搞死
                xmlNodePtr br = imgNode->next;
                while (br && xmlStrncasecmp(br->name, BAD_CAST"br", 2) == 0)
                {
                    xmlNodePtr n = br;
                    br = br->next;
                    xmlUnlinkNode(n);
                    xmlFreeNode(n);
                }
                
                xmlUnlinkNode(imgNode);
                xmlFreeNode(imgNode);
                
                i++;
                continue;
            }
        }
        
        if(picMode != ReaderPicOff)
        {
            ///非无图模式
            
            //////////added 2013-11-14，兼容安卓版的webp方案正文
            if(imgDict)
            {
                ////有img字典的情况
                
                //获取该img的id
                xmlChar* idXmlCharVal = xmlGetProp(imgNode, BAD_CAST"id");
                if(idXmlCharVal)
                {
                    NSString* idAttrVal = [NSString stringWithUTF8String:(char*)idXmlCharVal];
                    NSString* realSrc = [imgDict objectForKey:idAttrVal];
                    if(realSrc && ![realSrc isEmptyOrBlank])
                    {
                        //找到真实src
                        //塞回去
                        xmlSetProp(imgNode, BAD_CAST"src", [realSrc convertToXmlChar]);
                    }
                    xmlFree(idXmlCharVal);
                }
            }
            //干掉<div class="imgbox" id="surf_div_0" style="display:none">的style
            xmlChar* imgPclass = xmlGetProp(imgNode->parent, BAD_CAST"class");
            if(imgPclass)
            {
                NSString* imgPclassStr = [NSString stringWithUTF8String:(char*)imgPclass];
                if([imgPclassStr isEqualToStringCaseInsensitive:@"imgbox"])
                {
                    xmlSetProp(imgNode->parent, BAD_CAST"style", BAD_CAST"");
                }
                xmlFree(imgPclass);
            }
            
            
            xmlAttrPtr srcAttr = xmlHasProp(imgNode, BAD_CAST "src");
            xmlChar* srcXmlCharVal = xmlGetProp(imgNode, BAD_CAST"src");
            
            if(srcAttr && srcXmlCharVal)
            {
                ThreadContentImageInfoV2* imgInfo = [ThreadContentImageInfoV2 new];
                
                xmlNodePtr txtOfImg = [HtmlUtil firstSiblingTextNodeOfXmlNode:imgNode];
                if(txtOfImg)
                {
                    xmlChar* t = xmlNodeGetContent(txtOfImg);
                    imgInfo->_imageText = [NSString stringWithUTF8String:(char*)t];
                    xmlFree(t);
                }
                else
                {
                    //把alt取出来作为图片文字描述
                    xmlChar* alt = xmlGetProp(imgNode, BAD_CAST"alt");
                    if(alt)
                    {
                        imgInfo->_imageText = [NSString stringWithUTF8String:(char*)alt];
                    }
                    else
                    {
                        imgInfo->_imageText = @"";
                    }
                    xmlFree(alt);
                }
                //顺手把alt清空，因为实际展示中我们用不到它，它还可能还会影响
                //我们的半透明loading图
                xmlSetProp(imgNode, BAD_CAST"alt", BAD_CAST"");
                
                //改写id
                NSString* idVal = [@"img" stringByAppendingFormat:@"%d",i];
                xmlSetProp(imgNode, BAD_CAST"id", [idVal convertToXmlChar]);
                NSString* srcAttrVal = [NSString stringWithUTF8String:(char*)srcXmlCharVal];
                
                [result.contentImgInfoArray addObject:imgInfo];
                imgInfo->_imageId = idVal;
                
                BOOL isEmoticon = NO;   //当前处理的img是否是表情小图标
                if(thread.channelId == 110150) {
                    ////【微博精选】频道
                    xmlChar *type = xmlGetProp(imgNode, BAD_CAST"type");
                    if(type && [[NSString stringWithUTF8String:(char*)type] isEqualToString:@"face"]) {
                        //表情符号，不需要换行
                        isEmoticon = YES;
                    }
                    xmlFree(type);
                }
                
                if([[srcAttrVal trimLeft] hasPrefixCaseInsensitive:@"data:image/"])
                {
                    //Data URI方式的src
                    imgInfo.isLocalImageReady = YES;
                    imgInfo->_imageUrl = [srcAttrVal trimLeft];
                    imgInfo->_expectedLocalPath = @"";
                }
                else
                {
                    NSString* originalUrl = thread.newsUrl;
                    originalUrl = [originalUrl completeUrl];
                    NSURL* remoteUri = [NSURL URLWithString:[srcAttrVal stringByUnescapingFromHTML] relativeToURL:[NSURL URLWithString:originalUrl]];
                    NSString* remoteUrl = [remoteUri absoluteString];
                    
                    if(!remoteUrl) {
                        /////不合法的url，则干掉该img标签
                        [result.contentImgInfoArray removeObject:imgInfo];
                        
                        xmlUnlinkNode(imgNode);
                        xmlFreeNode(imgNode);
                        
                        i++;
                        continue;
                    }
                    
                    
                    imgInfo->_imageUrl = remoteUrl;
                    
                    //新增一个originalSrc属性，放置RemoteUri，以备日后需要用
                    //xmlNewProp(imgNode, BAD_CAST"originalSrc", [remoteUrl convertToXmlChar]);
                    
                    /****************************************************
                     处理映射文件
                     疑问：每次解析时已经可以根据图片id判断出对应的本地图片了，
                     为何还需要一个额外的映射文件？
                     答疑：因为不敢保证解析逻辑发生变化，即有可能以后改成图片id跟
                     对应的本地图片文件名不一致的情况。一旦出现这样的变化，已经
                     存在于本地的按照旧规则命名的图片，将变作无效文件。
                     因此我们需要一个映射文件来维持对应关系，即便规则发生了变化也能
                     正确找到图片对应的本地文件。
                     ***************************************************/
                    NSString* imgLocalPath = nil;
                    if ([imgMapping containsUrl:remoteUrl])
                    {
                        //映射中存在
                        imgLocalPath = [imgMapping getImgLocalFileNameWithUrl:remoteUrl];
                        imgLocalPath = [[PathUtil pathOfThread:thread] stringByAppendingPathComponent:imgLocalPath];
                    }
                    else
                    {
                        //立刻加入映射
                        [imgMapping addMappingWithUrl:remoteUrl andImgLocalFileName:idVal];
                        
                        imgLocalPath = [[PathUtil pathOfThread:thread] stringByAppendingPathComponent:idVal];
                    }
                    imgInfo->_expectedLocalPath = imgLocalPath;
                    
                    
                    ////改写<img width/height>
                    if(xmlHasProp(imgNode, BAD_CAST"width") &&
                       xmlHasProp(imgNode, BAD_CAST"height"))
                    {
                        //img 有宽高
                        xmlChar* w = xmlGetProp(imgNode, BAD_CAST"width");
                        xmlChar* h = xmlGetProp(imgNode, BAD_CAST"height");
                        NSString* wStr = [NSString stringWithUTF8String:(char*)w];
                        NSString* hStr = [NSString stringWithUTF8String:(char*)h];
                        xmlFree(w);
                        xmlFree(h);
                        
                        float width = [wStr floatValue];
                        float height = [hStr floatValue];
                        
                        //宽度超过ImgTagMaxWidth，直接缩放至ImgTagMaxWidth
                        if(width > ImgTagMaxWidth && height != 0)
                        {
                            float ratio = width / height;
                            xmlSetProp(imgNode, BAD_CAST"width", [[NSString stringWithFormat:@"%f",ImgTagMaxWidth] convertToXmlChar]);
                            NSString* heightV = [NSString stringWithFormat:@"%f",ImgTagMaxWidth / ratio];
                            xmlSetProp(imgNode, BAD_CAST"height", BAD_CAST([heightV UTF8String]));
                        }
                        //thread.channelId != 110150是为了将【微博精选】加为例外
                        //【微博精选】的标题中有个作者的头像，大小为50x50
                        else if(thread.channelId != 110150 && width < 80 && height < 80)
                        {
                            //宽高都小于80时，目前没有好的方案来展示【点击下载】和【下载进度】
                            //因此暂时直接不显示
                            xmlSetProp(imgNode, BAD_CAST"style", BAD_CAST"display:none;");
                            i++;
                            continue;
                        }
                    }
                    else    //img 无宽高
                    {
                        //无须特别处理，img.onload事件处理函数imgOnLoad()中
                        //会实时检测img真实size，如果超过ImgMaxWidth，会自动缩放
                        //从而保证图片不会超宽
                    }
                                       
                    //本地图片文件确实存在
                    if([FileUtil fileExists:imgLocalPath])
                    {
                        imgInfo.isLocalImageReady = YES;
                        
                        //图像文件已经就绪
                        //直接改写src
                        NSString* imgLocalPath = [@"file://" stringByAppendingString:[[PathUtil pathOfThread:thread] stringByAppendingPathComponent:[imgMapping getImgLocalFileNameWithUrl:remoteUrl]]];
                        xmlSetProp(imgNode, BAD_CAST"src", [imgLocalPath convertToXmlChar]);
                    }
                    else
                    {
                        //图像文件尚未就绪，需要下载
                        imgInfo.isLocalImageReady = NO;
                        
                        if(isEmoticon) {
                            /////////表情图片进行特殊处理
                            
                            if(picMode == ReaderPicOn) {
                                
                                ////只在自动加载图片模式下才显示表情小图
                                ////因为表情小图上面根本无法展示下载进度，也无法放置“点击下载”按钮。
                                xmlSetProp(imgNode, BAD_CAST"src", [@"" convertToXmlChar]);
                                
                            }
                        } else {
                            //改写src成“点击加载”图片
                            xmlSetProp(imgNode, BAD_CAST"src", [[NSString stringWithFormat:@"file://%@",[PathUtil pathOfResourceNamed:@"webview-img-click-to-download.png"]] convertToXmlChar]);
                            
                            /**********修改<img>附近的代码，使得最终效果形如：
                             //<div style="position:relative">
                             //  <img src="iamanimage.jpg" class="center"/>
                             //  <div style="position:absolute;top:50%;left:50%;margin-left:-25px;margin-top:-25px;width:50px;height:50px;background-color:yellow">
                             //      <img src="file://~/downloading-percent.jpg"/>
                             //  </div>
                             //</div>
                             //我们的目的是为了在原img上层覆盖一个下载进度的div，里面包含进度图
                             //和进度文字
                             **********/
                            
                            xmlNodePtr parentOfImg = imgNode->parent;
                            xmlUnlinkNode(imgNode); //将img从树中断开
                            
                            //创建外层div
                            xmlNodePtr divOutsideImg = xmlNewNode(imgNode->ns, BAD_CAST"div");
                            //设置style
                            xmlNewProp(divOutsideImg, BAD_CAST"style", BAD_CAST"position:relative");
                            
                            //创建imgNode的sibling div，此div用于覆盖在imgNode上层
                            xmlNodePtr divCover = xmlNewNode(imgNode->ns, BAD_CAST"div");
                            xmlNewProp(divCover, BAD_CAST"id", [[idVal stringByAppendingString:@"_pct"] convertToXmlChar]);
                            //设置style
                            //手动加载图片时，进度div需要先隐藏
                            if(picMode == ReaderPicManually)
                                xmlNewProp(divCover, BAD_CAST"style", BAD_CAST"display:none;position:absolute;top:50%;left:50%;margin-left:-30px;margin-top:-14px;width:60px;height:28px;pointer-events:none;background-color:transparent");
                            else
                                xmlNewProp(divCover, BAD_CAST"style", BAD_CAST"position:absolute;top:50%;left:50%;margin-left:-30px;margin-top:-14px;width:60px;height:28px;pointer-events:none;background-color:transparent");
                            //进度div
                            xmlNodePtr fontDiv = xmlNewNode(imgNode->ns, BAD_CAST"font");
                            xmlNewProp(fontDiv, BAD_CAST"class", BAD_CAST"progress");
                            xmlNewProp(fontDiv, BAD_CAST"size", BAD_CAST"5px");
                            xmlNewProp(fontDiv, BAD_CAST"face", BAD_CAST"Courier New");
                            xmlNodePtr progressDiv = xmlNewNode(imgNode->ns, BAD_CAST"div");
                            xmlNewProp(progressDiv, BAD_CAST"id", [[idVal stringByAppendingString:@"_pcttxt"] convertToXmlChar]);
                            xmlAddChild(progressDiv, xmlNewText(BAD_CAST"0%"));
                            xmlAddChild(divCover, fontDiv);
                            xmlAddChild(fontDiv, progressDiv);
                            xmlAddNextSibling(imgNode, divCover);
                            
                            //增加【点击下载】/【重试下载】外层div
                            xmlNodePtr clickToDownloadDiv = xmlNewNode(imgNode->ns, BAD_CAST"div");
                            xmlNewProp(clickToDownloadDiv, BAD_CAST"id", [[idVal stringByAppendingString:@"_ctd"] convertToXmlChar]);
                            
                            //由于retina、非retina公用一套图，原图都是适配retina的
                            //所以这里的宽高必须是原图的一半
                            int ctdFgImgW = 75; 
                            int ctdFgImgH = 45;
                            if(picMode == ReaderPicManually)
                            {
                                //手动加载图片时，显示【点击下载】
                                xmlNewProp(clickToDownloadDiv, BAD_CAST"style", [[NSString stringWithFormat:@"position:absolute;top:50%%;left:50%%;margin-left:-%dpx;margin-top:-%dpx;width:%dpx;height:%dpx;pointer-events:none;",ctdFgImgW / 2,ctdFgImgH / 2,ctdFgImgW,ctdFgImgH] convertToXmlChar]);
                                xmlNodePtr ctdTextDiv = xmlNewNode(imgNode->ns, BAD_CAST"div");
                                xmlNodePtr ctdFgDiv = xmlNewNode(imgNode->ns, BAD_CAST"img");
                                xmlNewProp(ctdFgDiv, BAD_CAST"width", [[NSString stringWithFormat:@"%d",ctdFgImgW] convertToXmlChar]);
                                xmlNewProp(ctdFgDiv, BAD_CAST"height", [[NSString stringWithFormat:@"%d",ctdFgImgH] convertToXmlChar]);
                                xmlSetProp(ctdFgDiv, BAD_CAST"src", [[NSString stringWithFormat:@"file://%@",[PathUtil pathOfResourceNamed:@"webview-img-click-to-download-fg.png"]] convertToXmlChar]);
                                xmlSetProp(ctdFgDiv, BAD_CAST"id", [[idVal stringByAppendingString:@"_ctd_fg"] convertToXmlChar]);
                                xmlAddChild(ctdTextDiv, ctdFgDiv);
                                xmlAddChild(clickToDownloadDiv, ctdTextDiv);
                                xmlAddSibling(imgNode, clickToDownloadDiv);
                            }
                            else if(picMode == ReaderPicOn)
                            {
                                //自动加载图片时，显示【重试下载】,但初始化时是隐藏的
                                xmlNewProp(clickToDownloadDiv, BAD_CAST"style", [[NSString stringWithFormat:@"display:none;position:absolute;top:50%%;left:50%%;margin-left:-%dpx;margin-top:-%dpx;width:%dpx;height:%dpx;pointer-events:none;",ctdFgImgW / 2,ctdFgImgH / 2,ctdFgImgW,ctdFgImgH] convertToXmlChar]);
                                xmlNodePtr ctdTextDiv = xmlNewNode(imgNode->ns, BAD_CAST"div");
                                xmlNodePtr ctdFgDiv = xmlNewNode(imgNode->ns, BAD_CAST"img");
                                xmlNewProp(ctdFgDiv, BAD_CAST"width", [[NSString stringWithFormat:@"%d",ctdFgImgW] convertToXmlChar]);
                                xmlNewProp(ctdFgDiv, BAD_CAST"height", [[NSString stringWithFormat:@"%d",ctdFgImgH] convertToXmlChar]);
                                xmlSetProp(ctdFgDiv, BAD_CAST"src", [[NSString stringWithFormat:@"file://%@",[PathUtil pathOfResourceNamed:@"webview-img-load-failed.png"]] convertToXmlChar]);
                                xmlSetProp(ctdFgDiv, BAD_CAST"id", [[idVal stringByAppendingString:@"_ctd_fg"] convertToXmlChar]);
                                //xmlSetProp(ctdFgDiv, BAD_CAST"style", BAD_CAST"display:none;");
                                xmlAddChild(ctdTextDiv, ctdFgDiv);
                                xmlAddChild(clickToDownloadDiv, ctdTextDiv);
                                xmlAddSibling(imgNode, clickToDownloadDiv);
                            }
                            
                            
                            //设置divOutsideImg的children
                            xmlAddChildList(divOutsideImg, imgNode);
                            
                            //将divOutsideImg加入树中
                            xmlAddChild(parentOfImg, divOutsideImg);
                        }
                        
                    }
                }
                
                //class=center
                //使图片水平居中
                if(!isEmoticon) {
                    xmlSetProp(imgNode, BAD_CAST"class", BAD_CAST"center");
                }
                
                //去掉img可能存在的style
                xmlSetProp(imgNode, BAD_CAST"style", BAD_CAST"");
                
                //onclick
                xmlSetProp(imgNode, BAD_CAST"onclick", BAD_CAST"onImgClick();");
                
                //onload
                xmlSetProp(imgNode, BAD_CAST"onload", BAD_CAST"imgOnLoad();");
               
                xmlFree(srcXmlCharVal);
            }
            else    //img.src不存在，直接搞死
            {
                xmlFree(srcXmlCharVal);
                xmlUnlinkNode(imgNode);
                xmlFreeNode(imgNode);
            }
        }
        else
        {
            //无图模式
            xmlUnlinkNode(imgNode);
            xmlFreeNode(imgNode);
        }
        i++;
    }
    
    
    /*
    // 相关推荐的创建
    if ([[ClientFunctionManager sharedInstance] isOpenWebContentRecommend] && [recommends length] > 0 )
    {
        DJLog(@"相关推荐内容 = %@", recommends);
        // 数据类型如下
//        <div>
//            <ul>
//                <dt>
//                    <table>
//                        <tr>
//                            <td width=12 align="center">
//                                <img src="http://i1.sinaimg.cn/dy/deco/2013/0313/videoNewsLeft.gif"/>
//                            </td>
//                            <td style="padding-left:5px;">相关推荐</td>
//                        </tr>
//                    </table>
//                </dt>
//                <li>
//                    <hr color=#ce0000 size=1 />
//                    <a onclick='javascript:window.open(...)'> 推荐内容</a>
//                </li>
//            </ul>
//        </div>
        
        Recommends *rec = [[Recommends alloc] initWithRecommendContent:recommends];
        NSArray *recList = [rec getRecommendList];
        if (recList.count > 0) {
            // <ul>标签的style 属性在SurfHtmlGenerator 类里面全局设置了
            // 找到div标签的根节点
            xmlNodePtr divNode = [HtmlUtil firstDescendantOfXmlNode:rootNode withName:@"div"];
      
            // 创建一个相关推荐数据块
            xmlNodePtr divRecommendNode = xmlNewNode(divNode->ns, BAD_CAST"div");
            xmlAddSibling(divNode, divRecommendNode);
            
            
            xmlNodePtr ulNode = xmlNewNode(divRecommendNode->ns, BAD_CAST"ul");
            xmlAddChild(divRecommendNode, ulNode);
            
            {
                // <dt>相关推荐</dt>
                NSString *title = @"相关推荐";
                xmlNodePtr titleNode = xmlNewNode(ulNode->ns, BAD_CAST"dt");

                // <table>
                xmlNodePtr tableNode = xmlNewNode(titleNode->ns, BAD_CAST"table");
                xmlAddChildList(titleNode, tableNode);
                
                // <tr>
                xmlNodePtr tableTrNode = xmlNewNode(tableNode->ns, BAD_CAST"tr");
                xmlAddChildList(tableNode, tableTrNode);
                
                // <td>
                xmlNodePtr tableTdNode = xmlNewNode(tableTrNode->ns, BAD_CAST"td");
                xmlNewProp(tableTdNode,BAD_CAST"width", BAD_CAST"12");
                xmlNewProp(tableTdNode,BAD_CAST"align", BAD_CAST"center");
                xmlAddChildList(tableTrNode, tableTdNode);
                
                // <img>
                xmlNodePtr imgNode = xmlNewNode(tableTdNode->ns, BAD_CAST"img");                
                NSString *iconPath = [PathUtil pathOfResourceNamed:@"newsRecommend.png"];
                iconPath = [NSString stringWithFormat:@"file://%@",iconPath];
                xmlNewProp(imgNode,BAD_CAST"src", [iconPath convertToXmlChar]);
                xmlNewProp(imgNode,BAD_CAST"width", BAD_CAST"12");
                xmlNewProp(imgNode,BAD_CAST"height", BAD_CAST"12");
                xmlAddChildList(tableTdNode, imgNode);
                
                // <td>
                xmlNodePtr tableTdNode2 = xmlNewNode(tableTrNode->ns, BAD_CAST"td");
                xmlNewProp(tableTdNode2,BAD_CAST"style", BAD_CAST"padding-left:4px;");
                xmlAddChildList(tableTdNode2, xmlNewText([title convertToXmlChar]));
                xmlAddChildList(tableTrNode, tableTdNode2);
                
                xmlAddChildList(ulNode, titleNode);
                
                
                // 推荐链接
                NSMutableString *hrStyleString = [[NSMutableString alloc] initWithString:@"height:1px;border:0;border-bottom-width:1px;border-bottom-style:solid; border-bottom-color:red;margin-bottom:10;"];
                if ([[ThemeMgr sharedInstance] isNightmode]) {
                    [hrStyleString appendString:[NSString stringWithFormat:@"border-bottom-color:%@;",recommendHrBorderColor_night]];
                }
                else{                    
                    [hrStyleString appendString:[NSString stringWithFormat:@"border-bottom-color:%@;",recommendHrBorderColor_day]];
                }
                const xmlChar *hrStyle = [hrStyleString convertToXmlChar];                
                for (int i=0; i<recList.count; ++i) {
                    RecommendInfo *info = recList[i];
                    if ([info isKindOfClass:[RecommendInfo class]]) {
                        xmlNodePtr liNode = xmlNewNode(ulNode->ns, BAD_CAST"li");
                        xmlAddChildList(ulNode,liNode);
                        
                        if (i == 0) {
                            // <hr color=#ce0000 size=1 />
                            xmlNodePtr hrNode = xmlNewNode(liNode->ns, BAD_CAST"hr");                          
                            xmlNewProp(hrNode, BAD_CAST"style", hrStyle);                             
                            xmlNewProp(hrNode, BAD_CAST"name", BAD_CAST"recommendHr");// 郁闷这个吊东西还要夜间模式，哎！！！
                            xmlAddChildList(liNode,hrNode);
                        }
                        
                        
                        // 添加<a>标签
                        xmlNodePtr aNode = xmlNewNode(liNode->ns, BAD_CAST"a");
                        NSString *aOnclick = [NSString stringWithFormat:@"javascript:window.open('%@?coid=%@&newsid=%@&newsTitle=%@&serverTime=%f&newsUrl=%@&source=%@')",
                                              Recommend_Click_PREFIX,info.coid,info.channelId,info.title,info.time,
                                              info.newsUrl,info.source];
                        xmlNewProp(aNode, BAD_CAST"onclick", [aOnclick convertToXmlChar]);
                        xmlAddChild(aNode, xmlNewText([info.title convertToXmlChar]));
                        xmlAddChildList(liNode,aNode);
                        
                        // <hr>分割线
                        xmlNodePtr hrNode = xmlNewNode(liNode->ns, BAD_CAST"hr");
                        xmlNewProp(hrNode, BAD_CAST"style",hrStyle);
                        xmlNewProp(hrNode, BAD_CAST"name", BAD_CAST"recommendHr");// 郁闷这个吊东西还要夜间模式，哎！！！
                        xmlAddChildList(liNode,hrNode);
                    }
                }
            }            
        }
    }
    */
    
    // 2014.5.5 xuxg 添加广告位
    /*
    NSArray *adList = [[AdvertisementManager sharedInstance] getAdvertisementOfCoid:thread.coid];
    if (adList!= nil && [adList count] > 0) {
    

<div style="margin:0px">
    <a style="margin-bottom:10px;padding-left:10px;font-size:15px;color:#87CEEB;">成人用儿童霜反而会伤皮肤</a><br>
    <a style="margin-bottom:10px;padding-left:10px;font-size:15px;color:#87CEEB;">最常见的诱发头痛的坏习惯</a><br>
    <a style="margin-bottom:10px;">
        <img align ="center"/>
    </a>
</div>
      */
        /*
        // 找到div标签的根节点
        xmlNodePtr divNode = [HtmlUtil firstDescendantOfXmlNode:rootNode withName:@"div"];
        // 创建一个相关推荐数据块
        xmlNodePtr divAdNode = xmlNewNode(divNode->ns, BAD_CAST"div");
        xmlNewProp(divAdNode, BAD_CAST"style",[@"margin-top:10px" convertToXmlChar]);
        xmlAddSibling(divNode, divAdNode);
        

        const xmlChar *text_a_style = [@"margin-bottom:10px;padding-left:10px;font-size:15px;color:#87CEEB;" convertToXmlChar];
//        const xmlChar *img_a_style = [@"margin-bottom:20px;" convertToXmlChar];
        for (int i=0; i<[adList count]; ++i) {
            AdvertisementInfo *adInfo = [adList objectAtIndex:i];
            if ([[adInfo type] isEqualToString:@"0"]) {// 文字新闻
                // a标签
                xmlNodePtr aNode = xmlNewNode(divAdNode->ns, BAD_CAST"a");
                NSString *aOnclick = [NSString stringWithFormat:@"javascript:window.open('%@?newsUrl=%@')",
                                      Ad_Click_PREFIX, adInfo.newsUrl];
                xmlNewProp(aNode, BAD_CAST"onclick", [aOnclick convertToXmlChar]);
                xmlNewProp(aNode, BAD_CAST"style",text_a_style);
                xmlAddChild(aNode, xmlNewText([adInfo.title convertToXmlChar]));
                xmlAddChild(divAdNode, aNode);
                
                xmlAddChild(divAdNode, xmlNewNode(divAdNode->ns, BAD_CAST"br"));
            }
            else if ([[adInfo type] isEqualToString:@"1"]) {// 图片新闻
                // a标签
                xmlNodePtr aNode = xmlNewNode(divAdNode->ns, BAD_CAST"a");
                NSString *aOnclick = [NSString stringWithFormat:@"javascript:window.open('%@?newsUrl=%@')",
                                      Ad_Click_PREFIX, adInfo.newsUrl];
                xmlNewProp(aNode, BAD_CAST"onclick", [aOnclick convertToXmlChar]);
//                xmlNewProp(aNode, BAD_CAST"style",img_a_style);
                xmlAddChild(divAdNode, aNode);
         
                
                // img 标签
                xmlNodePtr imgNode = xmlNewNode(aNode->ns, BAD_CAST"img");
                NSString *imgPath = [NSString stringWithFormat:@"file://%@",[PathUtil pathOfAdvertisementImage:adInfo]];
                xmlNewProp(imgNode,BAD_CAST"src", [imgPath convertToXmlChar]);
                xmlNewProp(imgNode,BAD_CAST"width", [@"295" convertToXmlChar]);
                xmlAddChild(aNode, imgNode);
            }
        }
    }*/
    
    
    
    //输出修改过后的html
    xmlBufferPtr buffer = xmlBufferCreate();
    htmlNodeDump(buffer, doc, rootNode);
    NSMutableString* finalContent = [NSMutableString stringWithUTF8String:(char*)buffer->content];
    
    //去掉<body>content</body>的前后缀
    NSRange bodyPrefix = [finalContent rangeOfString:@"<body>" options:NSCaseInsensitiveSearch];
    NSRange bodySuffix = [finalContent rangeOfString:@"</body>" options:NSBackwardsSearch|NSCaseInsensitiveSearch];
    if(bodySuffix.length > 0)
        [finalContent deleteCharactersInRange:NSMakeRange(bodySuffix.location, [finalContent length] - bodySuffix.location)];
    if(bodyPrefix.length > 0)
        [finalContent deleteCharactersInRange:NSMakeRange(0, bodyPrefix.length + bodyPrefix.location)];

    
    result->_resolvedContent = finalContent;
    xmlBufferFree(buffer);
    xmlFreeDoc(doc);
    
    return result;
}

+(NSArray*) extractImgNodesFromContent:(NSString*)content
                              OfThread:(ThreadSummary*)thread;
{
    NSData* htmlData = [content dataUsingEncoding:NSUTF8StringEncoding];
    xmlDocPtr doc = htmlReadMemory([htmlData bytes], (int)[htmlData length],
                                   NULL,    //url
                                   "utf-8", //encoding
                                   HTML_PARSE_RECOVER | //keep parsing even errors
                                   HTML_PARSE_NOWARNING |   //no warning reported
                                   HTML_PARSE_NOERROR |     //no error reported
                                   HTML_PARSE_NOBLANKS |    //remove blanks
                                   HTML_PARSE_NONET |
                                   HTML_PARSE_NOIMPLIED);
    
    xmlNodePtr rootNode = xmlDocGetRootElement(doc);
    
    NSMutableArray* imgInfoArray = [NSMutableArray new];
        ThreadContentImageMapping* imgMapping = [[ThreadContentImageMapping alloc] initWithThread:thread];
    NSArray* imgNodesArray = [HtmlUtil descendantsOfXmlNode:rootNode withName:@"img"];
    ////////对【新鲜送】进行特殊处理
    BOOL isFromXinXianSong = (thread.channelId == 59232681 && SubChannelThread==thread.threadM);
    
    int i = 0;
    for (NSValue* imgNodeP in imgNodesArray)
    {
        xmlNodePtr imgNode = (xmlNodePtr)[imgNodeP pointerValue];
        
        ///////对【新鲜送】进行特殊处理
        //排除【新鲜送】中的快讯广告图
        //广告图一定是第一个img，所以仅需要i==0时检测即可
        //59232681为新鲜送的channelid
        if(i == 0 && isFromXinXianSong)
        {
            xmlChar* w = xmlGetProp(imgNode, BAD_CAST"width");
            xmlChar* h = xmlGetProp(imgNode, BAD_CAST"height");
            BOOL isAd = (xmlStrcmp(w, BAD_CAST"180") == 0
                         && xmlStrcmp(h, BAD_CAST"55") == 0);
            xmlFree(w);
            xmlFree(h);
            if(isAd)
            {
                i++;
                continue;
            }
        }
        
        xmlAttrPtr srcAttr = xmlHasProp(imgNode, BAD_CAST "src");
        xmlChar* srcXmlCharVal = xmlGetProp(imgNode, BAD_CAST"src");
        
        if(srcAttr && srcXmlCharVal)
        {
            //改写id
            NSString* idVal = [@"img" stringByAppendingFormat:@"%d",i];
            NSString* srcAttrVal = [NSString stringWithUTF8String:(char*)srcXmlCharVal];
            
            ThreadContentImageInfoV2* imgInfo = [ThreadContentImageInfoV2
                                                 new];
            [imgInfoArray addObject:imgInfo];
            imgInfo->_imageId = idVal;
            
            if([[srcAttrVal trimLeft] hasPrefixCaseInsensitive:@"data:image/"])
            {
                //Data URI方式的src
                imgInfo.isLocalImageReady = YES;
                imgInfo->_imageUrl = [srcAttrVal trimLeft];
                imgInfo->_expectedLocalPath = @"";
            }
            else
            {
                NSString* originalUrl = thread.newsUrl;
                originalUrl = [originalUrl completeUrl];
                NSURL* remoteUri = [NSURL URLWithString:[srcAttrVal stringByUnescapingFromHTML] relativeToURL:[NSURL URLWithString:originalUrl]];
                NSString* remoteUrl = [remoteUri absoluteString];
                imgInfo->_imageUrl = remoteUrl;
                
                
                /****************************************************
                 处理映射文件
                 疑问：每次解析时已经可以根据图片id判断出对应的本地图片了，
                 为何还需要一个额外的映射文件？
                 答疑：因为不敢保证解析逻辑发生变化，即有可能以后改成图片id跟
                 对应的本地图片文件名不一致的情况。一旦出现这样的变化，已经
                 存在于本地的按照旧规则命名的图片，将变作无效文件。
                 因此我们需要一个映射文件来维持对应关系，即便规则发生了变化也能
                 正确找到图片对应的本地文件。
                 ***************************************************/
                NSString* imgLocalPath = nil;
                if ([imgMapping containsUrl:remoteUrl])
                {
                    //映射中存在
                    imgLocalPath = [imgMapping getImgLocalFileNameWithUrl:remoteUrl];
                    imgLocalPath = [[PathUtil pathOfThread:thread] stringByAppendingPathComponent:imgLocalPath];
                }
                else
                {
                    //立刻加入映射
                    [imgMapping addMappingWithUrl:remoteUrl andImgLocalFileName:idVal];
                    
                    imgLocalPath = [[PathUtil pathOfThread:thread] stringByAppendingPathComponent:idVal];
                }
                imgInfo->_expectedLocalPath = imgLocalPath;
                
                //本地图片文件确实存在
                if([FileUtil fileExists:imgLocalPath])
                {
                    imgInfo.isLocalImageReady = YES;
                }
                else
                {
                    //图像文件尚未就绪，需要下载
                    imgInfo.isLocalImageReady = NO;
                }
            }
            xmlFree(srcXmlCharVal);
        }
        i++;
    }
    
    xmlFreeDoc(doc);
    return imgInfoArray;
}


@end
