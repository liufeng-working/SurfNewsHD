//
//  PhoneWebView.m
//  SurfNewsHD
//
//  Created by apple on 13-5-27.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhoneWebView.h"
#import "SurfHtmlGenerator.h"
#import "ThreadContentDownloader.h"
#import "ThreadsManager.h"
#import "PathUtil.h"
#import "FileUtil.h"
#import "XmlUtils.h"
#import "ImageDownloader.h"
#import "AppSettings.h"
#import "NSString+Extensions.h"
#import "UIWebView+Clean.h"
#import "ThreadsManager.h"
#import "NotificationManager.h"
#import "PhoneReadController.h"


@implementation PhoneWebView

@synthesize webViewDelegate;
@synthesize contentResolvingResult = contentRslvResult_;
@synthesize m_contentShareCtl;

-(NSString*)generateWhatTheFuckWebViewApiString
{
    //_setDrawInWebThread
    return [@"_s" stringByAppendingFormat:@"%@raw%@eb%@ad:",@"etD",@"InW",@"Thre"];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        BOOL yes = YES;
        NSString* str = [self generateWhatTheFuckWebViewApiString];
        NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:NSSelectorFromString(str)]];
        [invocation setTarget:self];
        [invocation setSelector:NSSelectorFromString(str)];
        [invocation setArgument:&yes atIndex:2];
        [invocation invoke];

        
        loadImgFinished = NO;
        showReloadButtonWhenDomReady = NO;
        imageDownloaderArr = [NSMutableArray array];
        self.backgroundColor = [UIColor clearColor];
        [self hideGradientBackground:self];
        
        UIScrollView* sView = (UIScrollView *)self.subviews[0];
        sView.delegate = self;

        ThemeMgr *themeMgr = [ThemeMgr sharedInstance];
        [self stringByEvaluatingJavaScriptFromString:
         [NSString stringWithFormat:@"document.body.style.backgroundColor='%@';",
          [themeMgr isNightmode]?NightBackgroundColor:DayBackgroundColor]];


        activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(frame.size.width/2-20.0f +
                                                                             frame.origin.x,
                                                                             frame.size.height/2-20.0f,
                                                                             40.0f, 40.0f)];
        activity.activityIndicatorViewStyle  = [themeMgr isNightmode]?UIActivityIndicatorViewStyleWhiteLarge:UIActivityIndicatorViewStyleGray;
        [activity startAnimating];
        
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        
        UIMenuItem *shareItem = [[UIMenuItem alloc] initWithTitle:@"分享" action:@selector(share)];
        
        NSArray *array = [NSArray arrayWithObjects:shareItem,nil];
        
        [menuController setMenuItems:array];
        
        m_imgNewsShareArray = [[NSMutableArray alloc] init];
        m_imgNewsShareArrayDefault = [[NSMutableArray alloc] init];
        
        // 感觉webView 滚动慢，看看这个效果如何
        self.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    }
    return self;
}

-(void)share{
    [webViewDelegate shareViewPopped:self.tag];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(share))
    {
        return YES;
    }
    return [super canPerformAction:action withSender:sender];
}

- (void) hideGradientBackground:(UIView*)theView
{
    for (UIView * subview in theView.subviews)
    {
        if ([subview isKindOfClass:[UIImageView class]])
            subview.hidden = YES;
//            subview.backgroundColor = [UIColor clearColor];
        
        [self hideGradientBackground:subview];
    }
}
-(ThreadSummary *)threadCurrent
{
    return thread_;
}
-(void)invokeJsToReloadContent:(NSString*)xml
{
    if (xml == nil) {
        xml = [NSString stringWithContentsOfFile:[PathUtil pathOfThreadContent:thread_]
                                        encoding:NSUTF8StringEncoding error:nil];
    }
    NSString* content = [XmlUtils contentOfFirstNodeNamed:@"content" inXml:xml];
//    NSString* recommends = [XmlUtils recommendOfFirstNode:xml];
    NSDictionary *imgsDict = [XmlUtils parseImagesNode:xml];
    contentRslvResult_ = [ThreadContentResolver resolveContentV2:content imgsDict:imgsDict 
                                                OfThread:thread_];
    NSMutableString* resolvedContent = [NSMutableString stringWithString:contentRslvResult_.resolvedContent];
    [resolvedContent replaceOccurrencesOfString:@"'" withString:@"\\'" options:0 range:NSMakeRange(0, [resolvedContent length])];
    [resolvedContent replaceOccurrencesOfString:@"\n" withString:@"" options:0 range:NSMakeRange(0, [resolvedContent length])];
    [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setContent('%@');",resolvedContent]];
}


-(void)downloadImagesIfNecessary
{
    for(ImageDownloadingTask *task in imageDownloaderArr)
    {
        [[ImageDownloader sharedInstance] cancelDownload:task];
    }
    
    [imageDownloaderArr removeAllObjects];
    [m_imgNewsShareArrayDefault removeAllObjects];
    
    for(ThreadContentImageInfoV2 * imageInfo in contentRslvResult_.contentImgInfoArray)
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
            if(htmlDomReady)
            {
                [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setImgPercent('%@','%d%%');",imageInfo.imageId,(int)(percent * 100)]];
            }
        };
        
        //下载完成处理模块
        task.completionHandler = ^(BOOL succeeded, ImageDownloadingTask *idt)
        {
            if(succeeded && idt != nil &&[FileUtil fileExists:idt.targetFilePath])
            {
                loadImgFinished = YES;
                NSString *path = [NSString stringWithFormat:@"%@",
                                idt.targetFilePath];
                NSLog(@"path is %@", path);

                [m_imgNewsShareArray addObject:path];


                NSLog(@"NEWS DownloadingSucceed ImageUrl is %@", idt.imageUrl);
                
                //下载完成，需要将
                ((ThreadContentImageInfoV2*)idt.userData).isLocalImageReady = YES;
                if(!htmlDomReady)
                {
                    //webview尚未加载完成，需要等到完成后再更新img
                }
                else
                {
                    //立刻更新img
                    NSString *js = [NSString stringWithFormat:@"document.getElementById(\"%@\").src=\"file://%@\"",
                                    imageInfo.imageId,idt.targetFilePath];
                    [self stringByEvaluatingJavaScriptFromString:js];
                    
                    //隐藏下载进度
                    [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"hideImgPercentDiv('%@');",imageInfo.imageId]];
                    
                    //移除图片下载任务
                    [imageDownloaderArr removeObject:idt];
                    
                }
            }
            else
            {
                //图片下载失败
                if (!htmlDomReady)
                {
                    //
                }
                else
                {
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
            [self.webViewDelegate webViewImageDownloadFinished:imageInfo];
        };
        [imageDownloaderArr addObject:task];
        
        ReaderPicMode picMode = [AppSettings integerForKey:IntKey_ReaderPicMode];
        
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
- (void)phoneWebViewDidFinishLoad
{
    //OS 6.0+起必须延时来设置可见
    if([[[UIDevice currentDevice] systemVersion] isVersionHigherThanOrEqualsTo:@"6.0"])
        [self performSelector:@selector(showMe) withObject:nil afterDelay:0.2];
    else
        self.hidden = NO;
    htmlDomReady = YES;
    if (showReloadButtonWhenDomReady)
    {
        [self stringByEvaluatingJavaScriptFromString:@"showReloadButton();"];
    }
    if(loadContentWhenDomReady)
    {
        [self invokeJsToReloadContent:nil];
        [self downloadImagesIfNecessary];
    }
    
    //复位
    showReloadButtonWhenDomReady = NO;
    loadContentWhenDomReady = NO;
    for (NSInteger i= [imageDownloaderArr count]-1; i>=0; --i)
    {
        ImageDownloadingTask *idt = [imageDownloaderArr objectAtIndex:i];
        
        //把已经完成下载的图片显示出来
        if (idt.finished)
        {
            ThreadContentImageInfoV2* imgInfo = (ThreadContentImageInfoV2*)idt.userData;
            
            if([FileUtil fileExists:idt.targetFilePath])
            {
                DJLog(@"加载图片 %@ ",idt.targetFilePath);

                //替换图片
                NSString *js = [NSString stringWithFormat:@"document.getElementById(\"%@\").src=\"file://%@\"",
                                imgInfo.imageId,idt.targetFilePath];
                [self stringByEvaluatingJavaScriptFromString:js];
                
                [imageDownloaderArr removeObject:idt];
            }
            else
            {
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

-(void)downloadImageByUserClick:(NSString*)imgId
{
    for (ImageDownloadingTask* task in imageDownloaderArr)
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

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [webViewDelegate webViewWillBeginDragging:scrollView];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [webViewDelegate webViewDidScroll:scrollView];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [webViewDelegate webViewDidEndDragging:scrollView willDecelerate:decelerate];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [webViewDelegate webViewDidEndDragging:scrollView willDecelerate:NO];
}

-(void)webWillDealloc
{
    [self cleanForDealloc];
    
    for(ImageDownloadingTask *task in imageDownloaderArr)
    {
        [[ImageDownloader sharedInstance] cancelDownload:task];
        
    }

    [imageDownloaderArr removeAllObjects];
    imageDownloaderArr = nil;
    [m_imgNewsShareArray removeAllObjects];
    m_imgNewsShareArray = nil;
    [m_imgNewsShareArrayDefault removeAllObjects];
    m_imgNewsShareArrayDefault = nil;
    
    ThreadContentDownloader *downLoader = [ThreadContentDownloader sharedInstance];
    [downLoader cancelDownload:thread_];

    //解锁
    [[ThreadsManager sharedInstance] unlockThreadResource:thread_];
    contentRslvResult_ = nil;
    thread_ = nil;
}
-(void)dealloc{


}
-(void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    
    if(!hidden)
    {
        if(activity)
        {
            [activity removeFromSuperview];
            activity = nil;
        }
    }
    else
    {
        if(activity)
        {
            activity.activityIndicatorViewStyle  = [[ThemeMgr sharedInstance] isNightmode]?UIActivityIndicatorViewStyleWhiteLarge:UIActivityIndicatorViewStyleGray;
            
            activity.hidden = NO;
        }
    }
   
}
-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if(activity)
        activity.frame = CGRectMake(frame.size.width/2-20.0f +
                                frame.origin.x,
                                frame.size.height/2-20.0f,
                                40.0f, 40.0f);
}

#pragma mark - PopShareContent
#pragma mark ----------------------------------------


#pragma mark - Weixin
-(void)popShareContentToWeixin:(ThreadSummary *)thread
{
    NSString *words;
    //分享数据
    NSString *str = [self stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];
    if (str) {
        if ([str isEqualToString:@""]) {
            words = thread.desc;
        } else {
            words = str;
        }
    }
    thread.desc = words;
    
    UIImage *image = nil;
    if([PathUtil pathOfThreadLogo:thread]) {
        NSData *imgData = [NSData dataWithContentsOfFile:[PathUtil pathOfThreadLogo:thread]];
        image = [UIImage imageWithData:imgData];
    }
    [theApp sendThreadToWeinxin:thread shareImage:image];
}

#pragma mark - WeiXinTimeline
-(void)popShareContentToWeixinTimeline:(ThreadSummary *)thread
{
    NSString *words;
    //分享数据
    NSString *str = [self stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];
    if (str) {
        if ([str isEqualToString:@""]) {
            words = thread.desc;
        } else {
            words = str;
        }
    }
    thread.desc = words;
    
    UIImage *image = nil;
    if([PathUtil pathOfThreadLogo:thread]) {
        NSData *imgData = [NSData dataWithContentsOfFile:[PathUtil pathOfThreadLogo:thread]];
        image = [UIImage imageWithData:imgData];
    }
    [theApp sendThreadToWeinxinTimeline:thread shareImage:image];
}

#pragma mark - SinaWeibo
-(void)popShareContentToSinaWeibo:(ThreadSummary *)thread
{
    m_contentShareCtl = [[ContentShareController alloc] init];
    [m_contentShareCtl setTitle:@"分享到新浪微博"];
    ContentShareView *shareView = [m_contentShareCtl curShareView];

    NSString *words;
    
    NSString *text = [NSString stringWithFormat:@"#冲浪快讯# 《%@》 %@",
                      thread.title == nil ? @"" : thread.title,
                      thread.desc == nil ? @"" : thread.desc];
    
    //分享数据
    NSString *str = [self stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];
    if (str) {
        if ([text isEqualToString:@""]) {
            if ([text length] > 120) {
                words = [text substringToIndex:120];
            }
            else{
                words = text;
            }
            [shareView setShareWordText:words];
        }
        else{
            if ([text length] > 120) {
                words = [str substringToIndex:120];
            }
            else{
                if ([str isEqualToString:@""]) {
                    words = text;
                }
                else{
                    words = str;
                }
            }
            [shareView setShareWordText:words];
        }
    }

    [shareView setShareWordText:words];

    [shareView remainlab:words];
    [shareView setShareMode:SinaWeibo];
    [shareView setShareNewsAds:thread.newsUrl];
    [shareView setShareStr:text];

//    if (loadImgFinished) {
//        m_contentShareCtl.m_contentShareView.m_numOfPhotos = m_imgNewsShareArray;
//        [m_contentShareCtl.m_contentShareView reloadPhotosOnline];
//    }
//    else{
//        m_contentShareCtl.m_contentShareView.m_numOfPhotos = m_imgNewsShareArrayDefault;
//        [m_contentShareCtl.m_contentShareView reloadPhotosOffline];
//    }

    

    id object = [self nextResponder];
    while (![object isKindOfClass:[PhoneSurfController class]] &&
           object != nil) {
        object = [object nextResponder];

    }
    
    PhoneSurfController * ob = object;
    [ob presentController:m_contentShareCtl animated:PresentAnimatedStateFromRight];
    
    return;
    
}

#pragma mark - TencentWeibo
-(void)popShareContentToTencentWeibo:(ThreadSummary *)thread{
    
    m_contentShareCtl = [[ContentShareController alloc] init];
     [m_contentShareCtl setTitle:@"分享到腾讯微博"];
    ContentShareView *shareView = [m_contentShareCtl curShareView];

    NSString *words;
    
    NSString *text = [NSString stringWithFormat:@"#冲浪快讯# 《%@》 %@",
                      thread.title == nil ? @"" : thread.title,
                      thread.desc == nil ? @"" : thread.desc];
    
    //分享数据
    NSString *str = [self stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];
    if (str) {
        if ([text isEqualToString:@""]) {
            if ([text length] > 120) {
                words = [text substringToIndex:120];
            }
            else{
                words = text;
            }
            [shareView setShareWordText:words];
        }
        else{
            if ([text length] > 120) {
                words = [str substringToIndex:120];
            }
            else{
                if ([str isEqualToString:@""]) {
                    words = text;
                }
                else{
                    words = str;
                }
            }
            [shareView setShareWordText:words];
        }
        
    }
    
    [shareView remainlab:words];
    [shareView setShareMode:TencentWeibo];
    [shareView setShareNewsAds:thread.newsUrl];
    [shareView setShareStr:text];
    [m_contentShareCtl clearButtonOnToolsBar];
    
    
    
    id object = [self nextResponder];
    while (![object isKindOfClass:[PhoneSurfController class]] &&
           object != nil) {
        object = [object nextResponder];
    }
    
    PhoneSurfController * ob = object;
    [ob presentController:m_contentShareCtl animated:PresentAnimatedStateFromRight];
    
}

#pragma mark - Renren
-(void)popShareContentToRenren:(ThreadSummary *)thread
{
    m_contentShareCtl = [[ContentShareController alloc] init];
    ContentShareView *shareView = [m_contentShareCtl curShareView];
    
    NSString *words;
    //分享数据
    NSString *str = [self stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];
    if (str) {
        if ([str isEqualToString:@""]) {
            if ([thread.desc length] > 120) {
                words = [thread.desc substringToIndex:120];
            }
            else{
                words = thread.desc;
            }
            [shareView setShareWordText:words];
            [shareView setShareStr:thread.desc];
        }
        else{
            if ([str length] > 120) {
                words = [str substringToIndex:120];
            }
            else{
                words = str;
            }
            [shareView setShareWordText:words];
        }
        
        
        id object = [self nextResponder];
        while (![object isKindOfClass:[PhoneSurfController class]] &&
               object != nil) {
            object = [object nextResponder];
        }
        
        PhoneSurfController * ob = object;
        [ob presentController:m_contentShareCtl animated:PresentAnimatedStateFromRight];
        
        
        return;

    }
}

#pragma mark - ChinaMobileWeibo
-(void)popShareContentToChinaMobileWeibo:(ThreadSummary *)thread
{
    m_contentShareCtl = [[ContentShareController alloc] init];
    [m_contentShareCtl setTitle:@"分享到中国移动微博"];
    ContentShareView *shareView = [m_contentShareCtl curShareView];
    
    NSString *words;
    
    NSString *text = [NSString stringWithFormat:@"#冲浪快讯# 《%@》 %@",
                      thread.title == nil ? @"" : thread.title,
                      thread.desc == nil ? @"" : thread.desc];
    
    //分享数据
    NSString *str = [self stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];
    if (str) {
        if ([text isEqualToString:@""]) {
            if ([text length] > 120) {
                words = [text substringToIndex:120];
            }
            else{
                words = text;
            }
            [shareView setShareWordText:words];
        }
        else{
            if ([text length] > 120) {
                words = [str substringToIndex:120];
            }
            else{
                if ([str isEqualToString:@""]) {
                    words = text;
                }
                else{
                    words = str;
                }
            }
              [shareView setShareWordText:words];
        }
        
    }
    
    [shareView remainlab:words];
    [shareView setShareMode:ChinaMobileWeibo];
    [shareView setShareNewsAds:thread.newsUrl];
    [shareView setShareStr:text];
    [m_contentShareCtl clearButtonOnToolsBar];

    
    id object = [self nextResponder];
    while (![object isKindOfClass:[PhoneSurfController class]] &&
           object != nil) {
        object = [object nextResponder];
    }
    
    PhoneSurfController * ob = object;
    [ob presentController:m_contentShareCtl animated:PresentAnimatedStateFromRight];

}
@end
