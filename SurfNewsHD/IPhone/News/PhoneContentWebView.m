//
//  PhoneContentWebView.m
//  SurfNewsHD
//
//  Created by xuxg on 14-6-10.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "PhoneContentWebView.h"
#import "UIView+NightMode.h"
#import "SurfHtmlGenerator.h"
#import "ThreadsManager.h"
#import "PathUtil.h"
#import "FileUtil.h"
#import "XmlUtils.h"
#import "AppSettings.h"

#import "ImageDownloader.h"
#import "NSString+Extensions.h"
#import "ThreadContentResolver.h"
#import "ThreadContentDownloader.h"
#import "NSDictionary+QueryString.h"
#import "PictureBox.h"
#import "FavsManager.h"
#import "AppDelegate.h"
#import "PhoneNewsController.h"
#import "PhoneReadController.h"
#import "ContentShareController.h"


@class PhoneSurfController;

@interface PhoneContentWebView () {
    ThreadSummary *_thread;
    ThreadContentResolvingResultV2* _contentRslvResult;
    NSMutableArray *_imageDownloaderArr;
    BOOL _loadContentWhenDomReady;      // 装备加载新闻内容
    BOOL _htmlDomReady;                 //取代UIWebview.loading，后者为NO时不代表html DOM树完全建立完成
    BOOL _showReloadButtonWhenDomReady; // 显示重新加载按钮
    BOOL _loadImgFinished;              // 标记图片是否加载完成
    
    // 微博分享使用的图片
    NSMutableArray *m_imgNewsShareArray;
    NSMutableArray *m_imgNewsShareArrayDefault;
}
@end





@implementation PhoneContentWebView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _webViewType = WebViewType_Content;
        
        _imageDownloaderArr = [NSMutableArray array];
        m_imgNewsShareArray = [NSMutableArray array];
        m_imgNewsShareArrayDefault = [NSMutableArray array];
        _loadImgFinished = NO;
        _showReloadButtonWhenDomReady = NO;   
    }
    return self;
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}

- (BOOL)canPerformAction:withSender{
    return YES;
}

// 打开新闻内容
-(void)openThreadContent:(ThreadSummary *)thread
{
    
    if(_thread && (!thread || _thread == thread || _thread.threadId == thread.threadId))
        return;
    
    // 清除旧数据
    _loadImgFinished = NO;
    [_imageDownloaderArr removeAllObjects];
    [m_imgNewsShareArray removeAllObjects];
    [m_imgNewsShareArrayDefault removeAllObjects];
    
    
    if (_thread) {
        ThreadsManager *mgr = [ThreadsManager sharedInstance];
        [mgr unlockThreadResource:_thread];
        [mgr lockThreadResource:thread];
    }
    
    //取消当前可能正在下载的正文任务
    ThreadContentDownloader *downLoader = [ThreadContentDownloader sharedInstance];
    [downLoader cancelDownload:_thread];
    _thread = thread;
    [self stopWebViewLoading];

    
    _loadContentWhenDomReady = NO;
    NSString* contentPath = [PathUtil pathOfThreadContent:thread];
    if(![FileUtil fileExists:contentPath])
    {
        self.hidden = YES;
        
        //正文不存在，需要下载，显示loading html
        [_webView loadHTMLString:[SurfHtmlGenerator generateWithThread:thread] baseURL:nil];

        _htmlDomReady = NO;
        _showReloadButtonWhenDomReady = NO;
        
        // 去下载新闻内容
        [downLoader download:thread withCompletionHandler:^(BOOL succeeded,NSString *content ,ThreadSummary *thread)
         {
             //正文下载成功
             if (succeeded) {
                 
                 if(_htmlDomReady) {
                     // 本地的加载界面已经加载完成，就加载新的新闻内容
                     [self invokeJsToReloadContent:content];//直接通过js更新正文
                     [self downloadImagesIfNecessary];
                 }
                 else {
                     _loadContentWhenDomReady = YES;        // 标记加载新闻内容
                 }
             }
             else{
                 //正文下载失败
                 if (_htmlDomReady){
                     // 本地的加载Html准备好，就直接显示 刷新按钮
                     [_webView stringByEvaluatingJavaScriptFromString:@"showReloadButton();"];
                 }
                 else{
                     _showReloadButtonWhenDomReady = YES;   // 标记显示刷新按钮
                 }
             }
         }];
    }
    else
    {
        //正文存在，直接显示正文html
        NSString *htmlContent = [NSString stringWithContentsOfFile:contentPath encoding:NSUTF8StringEncoding error:nil];
        NSString* content = [XmlUtils contentOfFirstNodeNamed:@"content" inXml:htmlContent];
        NSString* recommends = [XmlUtils recommendOfFirstNode:htmlContent];
        NSDictionary *imgsDict = [XmlUtils parseImagesNode:htmlContent];
        _contentRslvResult = [ThreadContentResolver resolveContentV2:content imgsDict:imgsDict OfThread:_thread];
        self.hidden = YES;
        [_webView loadHTMLString:[SurfHtmlGenerator generateWithThread:thread andResolvedContent:_contentRslvResult.resolvedContent recommendContent:recommends] baseURL:nil];
        _htmlDomReady = NO;
        [self downloadImagesIfNecessary];
    }
}

-(NSMutableArray *)getImgArray{
    if (!_loadImgFinished) {
        return m_imgNewsShareArrayDefault;
    }
    else{
        return m_imgNewsShareArray;
    }
}

#pragma mark 私有函数
-(void)invokeJsToReloadContent:(NSString*)xml
{
    if (xml == nil) {
        xml = [NSString stringWithContentsOfFile:[PathUtil pathOfThreadContent:_thread]
                                        encoding:NSUTF8StringEncoding error:nil];
    }
    NSString* content = [XmlUtils contentOfFirstNodeNamed:@"content" inXml:xml];
    //    NSString* recommends = [XmlUtils recommendOfFirstNode:xml];
    NSDictionary *imgsDict = [XmlUtils parseImagesNode:xml];
    _contentRslvResult = [ThreadContentResolver resolveContentV2:content imgsDict:imgsDict
                                                        OfThread:_thread];
    NSMutableString* resolvedContent = [NSMutableString stringWithString:_contentRslvResult.resolvedContent];
    [resolvedContent replaceOccurrencesOfString:@"'" withString:@"\\'" options:0 range:NSMakeRange(0, [resolvedContent length])];
    [resolvedContent replaceOccurrencesOfString:@"\n" withString:@"" options:0 range:NSMakeRange(0, [resolvedContent length])];
    [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setContent('%@');",resolvedContent]];
}

// 是否需要下载图片
-(void)downloadImagesIfNecessary
{
    // 取消所有下载的图片
    for(ImageDownloadingTask *task in _imageDownloaderArr){
        [[ImageDownloader sharedInstance] cancelDownload:task];
    }
    [_imageDownloaderArr removeAllObjects];
    [m_imgNewsShareArrayDefault removeAllObjects];
    
    for(ThreadContentImageInfoV2 * imageInfo in _contentRslvResult.contentImgInfoArray)
    {
        [m_imgNewsShareArrayDefault addObject:imageInfo.expectedLocalPath];
        //本地图片已经就绪，直接跳过，无须处理
        if(imageInfo.isLocalImageReady)
            continue;
        
        NSString* imgPath = imageInfo.expectedLocalPath;
        NSLog(@"string is %@", imgPath);
        
        //无须再次判断图片是否存在，直接下载即可
        ImageDownloadingTask *task = [[ImageDownloadingTask alloc] init];
        [task setImageUrl:imageInfo.imageUrl];
        
        task.userData = imageInfo;
        [task setTargetFilePath:imgPath];
        
        
        //下载进度处理模块
        task.progressHandler = ^(double percent,ImageDownloadingTask* idt)
        {
            if(_htmlDomReady)
            {
                [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setImgPercent('%@','%d%%');",imageInfo.imageId,(int)(percent * 100)]];
            }
        };
        
        //下载完成处理模块
        task.completionHandler = ^(BOOL succeeded, ImageDownloadingTask *idt)
        {
            if(succeeded && idt != nil &&[FileUtil fileExists:idt.targetFilePath])
            {
                _loadImgFinished = YES;
                NSString *path = [NSString stringWithFormat:@"%@",idt.targetFilePath];
                [m_imgNewsShareArray addObject:path];
                //下载完成，需要将
                ((ThreadContentImageInfoV2*)idt.userData).isLocalImageReady = YES;
                if(!_htmlDomReady) {
                    //webview尚未加载完成，需要等到完成后再更新img
                }
                else {
                    //立刻更新img
                    NSString *js = [NSString stringWithFormat:@"document.getElementById(\"%@\").src=\"file://%@\"",
                                    imageInfo.imageId,idt.targetFilePath];
                    [self stringByEvaluatingJavaScriptFromString:js];
                    
                    //隐藏下载进度
                    [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"hideImgPercentDiv('%@');",imageInfo.imageId]];
                    
                    //移除图片下载任务
                    [_imageDownloaderArr removeObject:idt];
                    
                }
            }
            else {
                //图片下载失败
                if (!_htmlDomReady){
                    //
                }
                else {
                    //设置图片成“下载失败，点击重试”
                    
                    //显示点击下载div
                    [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"showImgClickToDownloadDiv('%@');",imageInfo.imageId]];
                    
                    //设置前景图
                    [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setImgClickToDownloadDivFgImg('%@','file://%@');",imageInfo.imageId,[PathUtil pathOfResourceNamed:@"webview-img-load-failed.png"]]];
                    
                    //隐藏下载进度
                    [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"hideImgPercentDiv('%@');",imageInfo.imageId]];
                }
                DJLog(@"图片加载失败%@",idt.imageUrl);
            }
            
            // 通知图片加载完成surfWebViewDelegate
            SEL sel = @selector(webViewImageDownloadFinished:);
            if ([[self surfWebViewDelegate] respondsToSelector:sel]) {
                [[self surfWebViewDelegate] webViewImageDownloadFinished:imageInfo];
            }
        };
        [_imageDownloaderArr addObject:task];
        
        ReaderPicMode picMode = [[AppSettings sharedInstance] integerForKey:IntKey_ReaderPicMode];
        
        if(picMode == ReaderPicManually)
        {
            //手动加载图片
            //等待用户点击后再进行下载
        }
        else if(picMode == ReaderPicOn)
        {
            //自动加载图片
            //立刻进行下载
            [[ImageDownloader sharedInstance] download:task];
        }
    }
}

- (void)showMe {
	self.hidden = NO;
}

//重新下载正文内容
-(void)reloadThreadContent
{
    ThreadContentDownloader *downLoader = [ThreadContentDownloader sharedInstance];
    [downLoader cancelDownload:_thread];
    [self stopWebViewLoading];
    [self stringByEvaluatingJavaScriptFromString:@"hideReloadButton();"];
    [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"showLoadingAnimation(%@);",[[ThemeMgr sharedInstance] isNightmode] ? @"true" : @"false"]];
    
    [downLoader download:_thread withCompletionHandler:^(BOOL succeeded,NSString *content ,ThreadSummary *thread)
     {
         if (succeeded)
         {
             //正文下载成功
             //直接通过js更新正文
             [self invokeJsToReloadContent:content];
             [self downloadImagesIfNecessary];
         }
         else
         {
             [self stringByEvaluatingJavaScriptFromString:@"showReloadButton();"];
         }
     }];
}



#pragma mark 继承或虚函数
- (void)viewNightModeChanged:(BOOL)isNight
{
    [super viewNightModeChanged:isNight];
}

// (虚函数，子类实现)微博分享内容
-(NSString *)weiboShareContent{
    ThreadSummary *ts = _thread;
    NSString *content = [self userSelectContent];
    if ([content isEmptyOrBlank]) {
        content = [NSString stringWithFormat:@"#冲浪快讯# 《%@》 %@",
                   ts.title == nil ? @"" : ts.title,
                   ts.desc == nil ? @"" : ts.desc];
    }
    
    if (content.length > 120) {
        return [content substringToIndex:120];
    }
    return content;
}



#pragma mark Delegate函数
#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    
    //imageclick://
    if([request.URL.absoluteString hasPrefix:IMAGE_CLICK_PREFIX])
    {
        NSDictionary *paramsDict = [NSDictionary dictionaryWithFormEncodedString:request.URL.query];
        
        //src文件名为webview-img-click-to-download.png
        // 表示点击下载图片
        if([request.URL.path hasSuffix:@"webview-img-click-to-download.png"])
        {
            [self downloadImageByUserClick:[paramsDict objectForKey:@"imgid"]];
        }
        else
        {
            // 这个是打开 PictureBox
            int imageIndex = 0;
            ReaderPicMode picMode = [[AppSettings sharedInstance] integerForKey:IntKey_ReaderPicMode];
            NSMutableArray *imageArr = [NSMutableArray array];
            

            for (int i = 0 ; i< [_contentRslvResult.contentImgInfoArray count]; i++)
            {
                ThreadContentImageInfoV2 *imgInfo1 = [_contentRslvResult.contentImgInfoArray objectAtIndex:i];
                if(picMode == ReaderPicOn ||
                   (picMode == ReaderPicManually && imgInfo1.isLocalImageReady))
                {
                    [imageArr addObject:imgInfo1];
                    if ([imgInfo1.imageId isEqualToString:[paramsDict objectForKey:@"imgid"]]) {
                        imageIndex = [imageArr count]-1;
                    }
                }
            }
            
            // 打开图片浏览
            SEL sel = @selector(openPictureBox:images:imageIdx:);
            if ([self.surfWebViewDelegate respondsToSelector:sel]) {
                [self.surfWebViewDelegate openPictureBox:_thread.title
                                                  images:imageArr
                                                imageIdx:imageIndex];
            }
        }
    }else if([request.URL.absoluteString isEqualToString:RELOAD_CONTENT_CLICK_PREFIX])
    {
        //重新加载
        [self reloadThreadContent];
    }
    else if([request.URL.absoluteString isEqualToString:SOURCE_URL_CLICK_PREFIX])
    {
        //查看原文
        SEL sel = @selector(readURLClickPrefix:);
        if ([self.surfWebViewDelegate respondsToSelector:sel]) {
            [self.surfWebViewDelegate readURLClickPrefix:_thread.newsUrl];
        }
    }
    else if([request.URL.absoluteString hasPrefix:Recommend_Click_PREFIX])
    {
        // 相关推荐点击
        NSString *decoded = [request.URL.query urlDecodedString];
        NSDictionary *paramsDict = [NSDictionary dictionaryWithFormEncodedString:decoded];
        u_long coid = [[paramsDict objectForKey:@"coid"] doubleValue];
        u_long threadId = [[paramsDict objectForKey:@"newsid"] doubleValue];
        NSString *title = [[paramsDict objectForKey:@"newsTitle"] urlDecodedString];
        NSString *newsUrl = [[paramsDict objectForKey:@"newsUrl"] urlDecodedString];
        NSString *source = [[paramsDict objectForKey:@"source"] urlDecodedString];
        double serverTime = [[paramsDict objectForKey:@"serverTime"] doubleValue];
        
        
        ThreadsManager *tm = [ThreadsManager sharedInstance];
        ThreadSummary *ts = [tm getThreadSummaryForCoid:coid threadId:threadId];
        if (ts == nil) {// 本地没有相关帖子新闻
            ts = [ThreadSummary new];
            ts.threadId = threadId;
            ts.channelId = coid;
            ts.title = title;
            ts.time = serverTime;
            ts.threadM=HotChannelThread;
            ts.channelType = 0;     // 姜军解释  0：冲浪新闻  1 快讯新闻，  默认是快讯新闻 ，在相关推荐中都是冲浪新闻
            ts.newsUrl = newsUrl;
            ts.source = source;
            [ts ensureFileDirExist]; // 避免没有文件夹，会导致正文内容无法保存
        }
        
        
        SEL sel = @selector(openReceommend:);
        if ([self.surfWebViewDelegate respondsToSelector:sel]) {
            [self.surfWebViewDelegate openReceommend:ts];
        }
        
    }
    else if ([request.URL.absoluteString hasPrefix:Ad_Click_PREFIX]){
        // 正文广告点击事件
        NSString *decoded = [request.URL.query urlDecodedString];
        NSDictionary *paramsDict = [NSDictionary dictionaryWithFormEncodedString:decoded];
        NSString *newsUrl = [[paramsDict objectForKey:@"newsUrl"] urlDecodedString];
        SEL sel = @selector(readURLClickPrefix:);
        if ([self.surfWebViewDelegate respondsToSelector:sel]) {
            [self.surfWebViewDelegate readURLClickPrefix:newsUrl];
        }
    }
    return YES;
}
// webView 开始加载
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [super webViewDidStartLoad:webView];
    
//    [self surfWebViewDidFinishLoad];
    
    //for memory leak
//    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
//    [[NSURLCache sharedURLCache] removeAllCachedResponses];
//    [[NSURLCache sharedURLCache] setDiskCapacity:0];
//    [[NSURLCache sharedURLCache] setMemoryCapacity:0];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [super webViewDidStartLoad:webView];
    
    
    //OS 6.0+起必须延时来设置可见
    if([[[UIDevice currentDevice] systemVersion] isVersionHigherThanOrEqualsTo:@"6.0"])
        [self performSelector:@selector(showMe) withObject:nil afterDelay:0.2];
    else
        self.hidden = NO;
    _htmlDomReady = YES;
    if (_showReloadButtonWhenDomReady)
    {
        [self stringByEvaluatingJavaScriptFromString:@"showReloadButton();"];
    }
    if(_loadContentWhenDomReady)
    {
        [self invokeJsToReloadContent:nil];
        [self downloadImagesIfNecessary];
    }
    
    //复位
    _showReloadButtonWhenDomReady = NO;
    _loadContentWhenDomReady = NO;
    for (int i= [_imageDownloaderArr count]-1; i>=0; --i) {
        ImageDownloadingTask *idt = [_imageDownloaderArr objectAtIndex:i];
        //把已经完成下载的图片显示出来
        if (idt.finished) {
            ThreadContentImageInfoV2* imgInfo = (ThreadContentImageInfoV2*)idt.userData;
            if([FileUtil fileExists:idt.targetFilePath]) {
                //替换图片
                NSString *js = [NSString stringWithFormat:@"document.getElementById(\"%@\").src=\"file://%@\"",
                                imgInfo.imageId,idt.targetFilePath];
                [self stringByEvaluatingJavaScriptFromString:js];
                [_imageDownloaderArr removeObject:idt];
            }
            else {
                //把点击下载图片设成重试
                
                //显示点击下载div
                [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"showImgClickToDownloadDiv('%@');",imgInfo.imageId]];
                
                //设置前景图
                [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setImgClickToDownloadDivFgImg('%@','file://%@');",imgInfo.imageId,[PathUtil pathOfResourceNamed:@"webview-img-load-failed.png"]]];
            }
            
            //隐藏下载进度
            [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"hideImgPercentDiv('%@');",imgInfo.imageId]];
        }
    }
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [super webView:webView didFailLoadWithError:error];
}



-(void)downloadImageByUserClick:(NSString*)imgId
{
    for (ImageDownloadingTask* task in _imageDownloaderArr)
    {
        ThreadContentImageInfoV2* imgInfo = (ThreadContentImageInfoV2*)task.userData;
        if([imgId isEqual:imgInfo.imageId])
        {
            [[ImageDownloader sharedInstance] download:task];
            
            //隐藏“点击下载”div
            [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"hideImgClickToDownloadDiv('%@');",imgId]];
            
            //将下载进度div显示出来
            [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"showImgPercentDiv('%@');",imgId]];
            
            break;
        }
    }
}

@end
