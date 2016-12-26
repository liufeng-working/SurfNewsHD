//
//  PeriodicalHtmlResolving.m
//  SurfNewsHD
//
//  Created by apple on 13-5-30.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PeriodicalHtmlResolving.h"
#import "XmlNode.h"
#import "XmlResolve.h"
#import "JSONKit.h"
#import "PathUtil.h"
#import "XmlUtils.h"

#import "ThreadContentResolver.h"
#import <libxml/tree.h>
#import <libxml/parser.h>
#import <libxml/HTMLparser.h>
#import <libxml/HTMLtree.h>
#import "NSString+Extensions.h"

#import "HtmlUtil.h"
#import "AppSettings.h"
#import "EzJsonParser.h"
#import "FileUtil.h"
#import "SurfHtmlGenerator.h"

#import "ImageUtil.h"
@implementation PeriodicalLinkInfo
@end

@implementation PeriodicalHtmlResolvingResult
@end
@implementation PeriodicalLinkImageMapping
-(id)init
{
    return nil;
}
-(id)initWithPeriodicalLink:(PeriodicalLinkInfo*)info
{
    if(self = [super init])
    {
        linkInfo = info;
        NSString *rootPath =[PathUtil pathOfPeriodicalContentWithLinkInfo:info];
    
        mappingPath_ = [rootPath stringByAppendingPathComponent:@"imgmapping.txt"];
        
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
-(NSString*)getImgLocalFilePathWithUrl:(NSString*)url
{
    NSString *name = [self getImgLocalFileNameWithUrl:url];
    if (name) {
        NSString *rootPath =[PathUtil pathOfPeriodicalContentWithLinkInfo:linkInfo];
        return  [rootPath stringByAppendingPathComponent:name];
    }
    return nil;
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

@implementation PeriodicalHtmlResolving

#pragma mark - 索引页以及正文页解析
+(PeriodicalHtmlResolvingResult *)generateWithPeriodical:(PeriodicalInfo *)periodicalInfo
              andResolvedHtml:(NSData *)data
{
    PeriodicalHtmlResolvingResult *result = [PeriodicalHtmlResolvingResult new];
    result.herfArr= [NSMutableArray new];
    
    NSString *string = [[NSString alloc ]initWithData:data encoding:NSUTF8StringEncoding];
    
    NSMutableString *mutableString =[NSMutableString stringWithString:[XmlUtils contentOfFirstNodeNamed:@"content"
                                                                                                  inXml:string]];

    NSArray *nodeDomains = [[XmlResolve new] getList:@"domain" xmlData:data];
    NSString *html = mutableString;
    for (NSInteger i = 0 ; i<[nodeDomains count]; i++) {

        XmlNode *node = [nodeDomains objectAtIndex:i];
        NSDictionary *dict = node.attributes;
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<%%=%@%%>",[dict objectForKey:@"name"]]
                                               withString:[dict objectForKey:@"value"]];
    }
    
    NSRegularExpression* reg = [NSRegularExpression regularExpressionWithPattern:@"<\\s*a[^<>]*?href\\s*=\\s*['\"]?([^'\"><]+)['\"]?" options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators error:nil];
    NSArray* matches = [reg matchesInString:html options:0 range:NSMakeRange(0, [html length])];
    
    NSInteger i = 0;
    for (NSTextCheckingResult* m in matches)
    {
        NSString* pHtml = [html substringWithRange:[m rangeAtIndex:1]];
        if (pHtml.length <= 0) {
            continue;
        }
        PeriodicalLinkInfo *info = [PeriodicalLinkInfo new];
        info.linkId = [NSString stringWithFormat:@"link%@",@(i)];
        info.linkUrl = pHtml;
        info.magazineId = periodicalInfo.magazineId;
        info.periodicalId = periodicalInfo.periodicalId;
        [result.herfArr addObject:info];
        i++;
    }
    
    //移除顶部距离
    NSString* patten = @"<\\s*body[^>]+?(margin-top:\\d+px)";
    reg = [NSRegularExpression regularExpressionWithPattern:patten options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators error:nil];

    NSTextCheckingResult* m = [reg firstMatchInString:html options:0 range:NSMakeRange(0, [html length])];
    html = [html stringByReplacingCharactersInRange:[m rangeAtIndex:1] withString:@""];
    
    mutableString = [NSMutableString stringWithString:html];
    NSRange range = [mutableString rangeOfString:@"</head>"];


    NSString *insertString =[NSString stringWithFormat:@"<link rel=\"stylesheet\"  id=\"CustomCSS\"\
                             href=\"file://%@\" />",[PathUtil pathOfResourceNamed:[[ThemeMgr sharedInstance] isNightmode]?@"mag_index_n.css":@"mag_index_d.css" ]];
    
    [mutableString insertString:insertString
                        atIndex:range.location];
    
    result.resolvedContent = mutableString;

 
    return result;
}
+(PeriodicalHtmlResolvingResult *)generateOfflinesWithPeriodical:(PeriodicalInfo *)periodicalInfo
{
    PeriodicalHtmlResolvingResult *result = [PeriodicalHtmlResolvingResult new];
    result.herfArr= [NSMutableArray new];

    NSString *string = [PathUtil pathOfflinesOfPeriodicalIndexWithPeriodicalId:periodicalInfo.periodicalId
                                                                  inMagazineId:periodicalInfo.magazineId];
    
    XmlNode *xmlResolve = [[XmlResolve new] getObject:@"journal"
                                                 xmlData:[NSData dataWithContentsOfFile:string]];
    string = [xmlResolve getNodeValue:@"page"];
    NSInteger i = 0 ;
    NSString *offlinesPath = [PathUtil pathOfflinesOfPeriodicalWithPeriodicalId:periodicalInfo.periodicalId
                                                                        inMagazineId:periodicalInfo.magazineId];

    NSString *path = offlinesPath;
    for(NSString *str in string.pathComponents)
    {
        if (i != 0)
        {
            path = [path stringByAppendingPathComponent:str];
        }
        i++;
        
    }
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    
    html = [html stringByReplacingOccurrencesOfString:string.pathComponents[0]
                                           withString:[NSString stringWithFormat:@"file://%@",offlinesPath]];

    DJLog(@"%@",html);
    for (XmlNode *xmlNode in xmlResolve.childs) {
        if ([xmlNode.name isEqualToString:@"contents"]) {
            for (XmlNode *node in xmlNode.childs) {
                PeriodicalLinkInfo *info = [PeriodicalLinkInfo new];
                info.linkId = [node getNodeValue:@"id"];
                info.linkUrl = [[node getNodeValue:@"url"] stringByReplacingOccurrencesOfString:string.pathComponents[0]
                                                       withString:[NSString stringWithFormat:@"file://%@",offlinesPath]];
                info.linkTitle = [node getNodeValue:@"title"];
                info.magazineId = periodicalInfo.magazineId;
                info.periodicalId = periodicalInfo.periodicalId;
                [result.herfArr addObject:info];
                
            }
        }

    }
    NSString* patten = @"<\\s*body[^>]+?(margin-top:\\d+px)";
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:patten options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators error:nil];
    
    NSTextCheckingResult* m = [reg firstMatchInString:html options:0 range:NSMakeRange(0, [html length])];
    html = [html stringByReplacingCharactersInRange:[m rangeAtIndex:1] withString:@""];
    
    NSRange range = [html rangeOfString:@"</head>"];
    NSString *insertString =[NSString stringWithFormat:@"<link rel=\"stylesheet\"  id=\"CustomCSS\"\
                             href=\"file://%@\" />",[PathUtil pathOfResourceNamed:[[ThemeMgr sharedInstance] isNightmode]?@"mag_index_n.css":@"mag_index_d.css" ]];
    NSMutableString *mutableString = [NSMutableString stringWithString:html];
    [mutableString insertString:insertString
                        atIndex:range.location];

    result.resolvedContent = mutableString;
    return result;
}
+(PeriodicalHtmlResolvingResult *)generateWithPeriodicalContent:(PeriodicalLinkInfo *)linkInfo
                                                               :(NSData *)data
{
    PeriodicalHtmlResolvingResult *result = [PeriodicalHtmlResolvingResult new];
    result.herfArr= [NSMutableArray new];
    NSString *html;
    NSMutableString *mutableString;
    BOOL isOffline  = NO;
    if ([linkInfo.linkUrl rangeOfString:@"file://"].location != NSNotFound){
        //离线下载
        isOffline = YES;
        html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

        NSString *offlinesPath = [PathUtil pathOfflinesOfPeriodicalWithPeriodicalId:linkInfo.periodicalId
                                                                       inMagazineId:linkInfo.magazineId];
        html = [html stringByReplacingOccurrencesOfString:@"\".."
                                               withString:[NSString stringWithFormat:@"\"file://%@",offlinesPath]];
        DJLog(@"%@ %@",offlinesPath,html);
    }else{
        
        NSString *string = [[NSString alloc ]initWithData:data encoding:NSUTF8StringEncoding];
        
        mutableString =[NSMutableString stringWithString:
                                         [XmlUtils contentOfFirstNodeNamed:@"content" inXml:string]];
        NSArray *nodeDomains = [[XmlResolve new] getList:@"domain" xmlData:data];
        //标签替换规则
        html = mutableString;
        for (NSInteger i = 0 ; i<[nodeDomains count]; i++) {
            
            XmlNode *node = [nodeDomains objectAtIndex:i];
            NSDictionary *dict = node.attributes;
            html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<%%=%@%%>",[dict objectForKey:@"name"]]
                                                   withString:[dict objectForKey:@"value"]];
        }
        
    }
    
    //获取IMG标签
    NSData* htmlData = [html dataUsingEncoding:NSUTF8StringEncoding];
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
    //图片模式
    ReaderPicMode picMode = [AppSettings integerForKey:IntKey_ReaderPicMode];
    NSArray* imgNodesArray = [HtmlUtil descendantsOfXmlNode:rootNode withName:@"img"];
    PeriodicalLinkImageMapping *imgMapping;
    if (!isOffline) {
         imgMapping= [[PeriodicalLinkImageMapping alloc] initWithPeriodicalLink:linkInfo];
    }

    
    
    NSInteger i = 0;
    for (NSValue* imgNodeP in imgNodesArray)
    {
        xmlNodePtr imgNode = (xmlNodePtr)[imgNodeP pointerValue];

        
        //modified by yuleiming
        //如果img外层有锚点，则该图片点击后打开mobile safari，不进行大图模式展示
        if ([@"a" isEqualToXmlChar:imgNode->parent->name]) 
        {
            //获取href并设置给img
            xmlChar* ahref = xmlGetProp(imgNode->parent, BAD_CAST"href");
            xmlSetProp(imgNode, BAD_CAST"ahref", ahref);
            xmlFree(ahref);
            
            //禁用parent锚点
            xmlSetProp(imgNode->parent, BAD_CAST"href", BAD_CAST"");
        }
        
        
        if(picMode != ReaderPicOff)
        {
            ///非无图模式
            
            xmlAttrPtr srcAttr = xmlHasProp(imgNode, BAD_CAST "src");
            xmlChar* srcXmlCharVal = xmlGetProp(imgNode, BAD_CAST"src");
            
            if(srcAttr && srcXmlCharVal)
            {
                ThreadContentImageInfoV2* imgInfo = [ThreadContentImageInfoV2 new];
                
                xmlNodePtr txtOfImg = [HtmlUtil firstSiblingTextNodeOfXmlNode:imgNode];
                if(txtOfImg)
                {
                    xmlChar* t = xmlNodeGetContent(txtOfImg);
                    imgInfo->_imageText = [NSString stringWithUTF8String:(void*)t];
                    xmlFree(t);
                }
                else
                {
                    //把alt取出来作为图片文字描述
                    xmlChar* alt = xmlGetProp(imgNode, BAD_CAST"alt");
                    if(alt)
                    {
                        imgInfo->_imageText = [NSString stringWithUTF8String:(void*)alt];
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
                NSString* idVal = [@"img" stringByAppendingFormat:@"%@",@(i)];
                xmlSetProp(imgNode, BAD_CAST"id", [idVal convertToXmlChar]);
                NSString* srcAttrVal = [NSString stringWithUTF8String:(void*)srcXmlCharVal];
                
                [result.herfArr addObject:imgInfo];
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
                    NSURL* remoteUri = [NSURL URLWithString:[srcAttrVal stringByUnescapingFromHTML]];
                    NSString* remoteUrl = [remoteUri absoluteString];
                    imgInfo->_imageUrl = remoteUrl;
                    
                    //新增一个originalSrc属性，放置RemoteUri，以备日后需要用
                    xmlNewProp(imgNode, BAD_CAST"originalSrc", [remoteUrl convertToXmlChar]);
                    
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
                    if (!isOffline) {
                        NSString* imgLocalPath = nil;
                        if ([imgMapping containsUrl:remoteUrl])
                        {
                            //映射中存在
                            imgLocalPath = [imgMapping getImgLocalFilePathWithUrl:remoteUrl];
                        }
                        else
                        {
                            //立刻加入映射
                            [imgMapping addMappingWithUrl:remoteUrl andImgLocalFileName:idVal];
                            
                            NSString *rootPath =[PathUtil pathOfPeriodicalContentWithLinkInfo:linkInfo];
                            imgLocalPath =  [rootPath stringByAppendingPathComponent:idVal];
                        }
                        imgInfo->_expectedLocalPath = imgLocalPath;
                        
                        //本地图片文件确实存在
                        if([FileUtil fileExists:imgLocalPath])
                        {
                            //图像文件已经就绪
                            //直接改写src
                            CGSize size =  [ImageUtil getImageSize:imgLocalPath];
                            NSString* imgLocalPath = [@"file://" stringByAppendingString:[imgMapping getImgLocalFilePathWithUrl:remoteUrl]];
                            

                            if (size.width > ImgTagMaxWidth && size.height != 0){
                                float ratio = size.width / size.height;
                                xmlSetProp(imgNode, BAD_CAST"width", [[NSString stringWithFormat:@"%f",ImgTagMaxWidth] convertToXmlChar]);
                                NSString* heightV = [NSString stringWithFormat:@"%f",ImgTagMaxWidth / ratio];
                                xmlSetProp(imgNode, BAD_CAST"height", BAD_CAST([heightV UTF8String]));

                            }
                            
                            xmlSetProp(imgNode, BAD_CAST"src", [imgLocalPath convertToXmlChar]);
                            
                            imgInfo.isLocalImageReady = YES;
                        }
                        else
                        {
                            //图像文件尚未就绪，需要下载
                            imgInfo.isLocalImageReady = NO;
                            
                            //改写src成“点击加载”图片
                            xmlSetProp(imgNode, BAD_CAST"src", [[NSString stringWithFormat:@"file://%@",[PathUtil pathOfResourceNamed:@"webview-img-click-to-download.png"]] convertToXmlChar]);
                            
#ifdef ipad
                            
#else
                            if(xmlHasProp(imgNode, BAD_CAST"width") &&
                               xmlHasProp(imgNode, BAD_CAST"height"))
                            {
                                //img 有宽高
                                xmlChar* w = xmlGetProp(imgNode, BAD_CAST"width");
                                xmlChar* h = xmlGetProp(imgNode, BAD_CAST"height");
                                NSString* wStr = [NSString stringWithUTF8String:(void*)w];
                                NSString* hStr = [NSString stringWithUTF8String:(void*)h];
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
                                else if(width < 80 && height < 80)
                                {
                                    //宽高都小于100时，目前没有好的方案来展示【点击下载】和【下载进度】
                                    //因此暂时直接不显示
                                    xmlSetProp(imgNode, BAD_CAST"style", BAD_CAST"display:none;");
                                    i++;
                                    continue;
                                }
                            }
                            else
                            {
                                //TODO???
                                //img 无宽高
                                
                                xmlSetProp(imgNode, BAD_CAST"width", [[NSString stringWithFormat:@"%f",ImgTagMaxWidth] convertToXmlChar]);
                                xmlSetProp(imgNode, BAD_CAST"height", [[NSString stringWithFormat:@"%f",ImgTagMaxWidth] convertToXmlChar]);
                            }
                            
                            
#endif
                            
                            //修改<img>附近的代码，使得最终效果形如：
                            //<div style="position:relative">
                            //  <img src="iamanimage.jpg" class="center"/>
                            //  <div style="position:absolute;top:50%;left:50%;margin-left:-25px;margin-top:-25px;width:50px;height:50px;background-color:yellow">
                            //      <img src="file://~/downloading-persent.jpg"/>
                            //  </div>
                            //</div>
                            //我们的目的是为了在原img上层覆盖一个下载进度的div，里面包含进度图
                            //和进度文字
                            
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
                            
                            
                            //设置divOutsizeImg的children
                            xmlAddChildList(divOutsideImg, imgNode);
                            
                            //将divOutsizeImg加入树中
                            xmlAddChild(parentOfImg, divOutsideImg);
                        }
                    }else
                        {
                            //离线文件下载好了
                            DJLog(@"%@",remoteUrl);
                            imgInfo.isLocalImageReady = YES;
                            imgInfo->_expectedLocalPath = [srcAttrVal stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                        }

                }
                //class=center
                //使图片水平居中
                xmlSetProp(imgNode, BAD_CAST"class", BAD_CAST"center");

                //onclick
                xmlSetProp(imgNode, BAD_CAST"onclick", BAD_CAST"onImgClick();");
                
                //onload
                xmlSetProp(imgNode, BAD_CAST"onload", BAD_CAST"imgOnLoad();");
                
                xmlFree(srcXmlCharVal);
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
    
    //输出修改过后的html
    xmlBufferPtr buffer = xmlBufferCreate();
    htmlNodeDump(buffer, doc, rootNode);

    mutableString = [NSMutableString stringWithUTF8String:(void*)buffer->content];
    xmlBufferFree(buffer);
    //
    NSRange range = [mutableString rangeOfString:@"<head>"];
    float model = [AppSettings floatForKey:FLOATKEY_ReaderBodyFontSize];
    if (model == kWebContentSize1)
    {
        model = 80;
    }
    else if (model == kWebContentSize2)
    {
        model = 100;
    }
    else if (model == kWebContentSize3)
    {
        model = 120;
    }
    else if (model == kWebContentSize4)
    {
        model = 140;
    }
    NSString *insertString =[NSString stringWithFormat:@"<script type=\"text/javascript\">\
    function onImgClick()\
    {\
        var img = event.srcElement;\
        var width = img.width;\
        var height = img.height;\
        if(img.getAttribute('ahref')){\
            if(img.src.indexOf('webview-img-click-to-download.png') != -1 || img.src.indexOf('webview-img-load-failed.png') != -1){\
                     window.open(\""IMAGE_CLICK_PREFIX"\"+ img.src+'?imgid='+img.id);\
             }\
             else{\
                 window.open(\""OPEN_URL_WITH_SAFARI"\"+ encodeURIComponent(img.getAttribute('ahref').toString()));\
             }\
        }\
        else\
        {\
            window.open(\""IMAGE_CLICK_PREFIX"\"+ img.src+'?imgid='+img.id);\
        }\
    }\
    function getOffset( el ) {\
        var _x = 0;\
        var _y = 0;\
        while( el && !isNaN( el.offsetLeft ) && !isNaN( el.offsetTop ) ) {\
            _x += el.offsetLeft - el.scrollLeft;\
            _y += el.offsetTop - el.scrollTop;\
            el = el.offsetParent;\
        }\
    return { top: _y, left: _x };\
    }\
    function setImgSrc(id,src)\
    {\
        var img = document.getElementById(id);\
        img.src = src;\
    }\n\
    function showImgClickToDownloadDiv(imgId)\
    {\
        var div = document.getElementById(imgId+'_ctd');\
        div.style.display = 'inline';\
    }\
    function setImgClickToDownloadDivFgImg(imgId,imgSrc)\
    {\
        var img = document.getElementById(imgId+'_ctd_fg');\
        img.src = imgSrc;\
    }\
    function hideImgClickToDownloadDiv(imgId)\
    {\
        var div = document.getElementById(imgId+'_ctd');\
        div.style.display = 'none';\
    }\
    function showImgPercentDiv(imgId)\
    {\
        var div = document.getElementById(imgId+'_pct');\
        div.style.display = 'inline';\
    }\n\
    function hideImgPercentDiv(imgId)\
    {\
        var div = document.getElementById(imgId+'_pct');\
        div.style.display = 'none';\
    }\n\
    function setImgPercent(id,pct)\
    {\
        var div = document.getElementById(id+'_pcttxt');\
        div.innerHTML = pct;\
    }\n\
    function setImgSrcAndSize(imgId,imgSrc,width,height)\
    {\
        var img = document.getElementById(imgId);\
        img.src = imgSrc;\
        if(width > %f)\
        {\
            var ratio = width / height;\
            img.width = %f;\
            img.height = %f / ratio;\
        }else\
        {\
            img.width = width;\
            img.hegiht = hegiht;\
        }\
    }\
    function setArticleFontSize(px)\
    {\
        var ratio = 100;\
        if(px == %d)\
        {\
            ratio = 80;\
        }else if(px == %d)\
        {\
            ratio = 100;\
        }else if(px == %d)\
        {\
            ratio = 120;\
        }else if(px == %d)\
        {\
            ratio = 140;\
        }\
        document.getElementById('content').style.webkitTextSizeAdjust= ratio+'\%%';\
    }\
    </script>\
    <style type=\"text/css\">\
        img.center{display: block; margin-left: auto; margin-right: auto;border:1px solid #cccccc;}\
    </style>",ImgTagMaxWidth,ImgTagMaxWidth,ImgTagMaxWidth,
                             kWebContentSize1,kWebContentSize2,kWebContentSize3,kWebContentSize4];

    [mutableString insertString:insertString
                        atIndex:range.location+range.length];
    //添加css样式
    range = [mutableString rangeOfString:@"</head>"];
    insertString =[NSString stringWithFormat:@"<link rel=\"stylesheet\"  id=\"CustomCSS\"\
                             href=\"file://%@\" />",[PathUtil pathOfResourceNamed:[[ThemeMgr sharedInstance] isNightmode]?@"mag_article_n.css":@"mag_article_d.css" ]];
    [mutableString insertString:insertString
                        atIndex:range.location];
    
    result.resolvedContent = mutableString;
    
    if (model != 100)
    {
        //字体大小样式
        NSString *jsSize = [NSString stringWithFormat:@"<script language='javascript'>document.getElementById('content').style.webkitTextSizeAdjust= '%f\%%'</script>",model];
        [mutableString appendString:jsSize];
        
    }
    
    result.resolvedContent = mutableString;
    
    NSString* patten = @"<h\\d>(.+?)</h\\d>";
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:patten options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators error:nil];
    
    NSTextCheckingResult* m = [reg firstMatchInString:mutableString options:0 range:NSMakeRange(0, [mutableString length])];
    linkInfo.linkTitle = [mutableString substringWithRange:[m rangeAtIndex:1]];

    return result;
}
@end
