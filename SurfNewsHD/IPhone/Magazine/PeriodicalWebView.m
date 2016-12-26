//
//  PeriodicalWebView.m
//  SurfNewsHD
//
//  Created by apple on 13-5-31.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PeriodicalWebView.h"
#import "MagazineManager.h"
#import "UIWebView+Clean.h"
#import "ImageDownloader.h"
#import "ThreadContentResolver.h"
#import "FileUtil.h"
#import "PathUtil.h"
#import "AppSettings.h"
#import "ImageUtil.h"
#import "ThemeMgr.h"
#import "NSString+Extensions.h"

@implementation PeriodicalWebView
@synthesize webViewDelegate;
@synthesize contentResolvingResult;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        UIScrollView* sView = (UIScrollView *)self.subviews[0];
        sView.delegate = self;
        [self hideGradientBackground:self];
        
        imageDownloaderArr = [NSMutableArray array];
        
        activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(frame.size.width/2-20.0f,
                                                                             frame.size.height/2-20.0f,
                                                                             40.0f, 40.0f)];
        activity.activityIndicatorViewStyle  = [[ThemeMgr sharedInstance] isNightmode]?UIActivityIndicatorViewStyleWhiteLarge:UIActivityIndicatorViewStyleGray;

        [activity startAnimating];
        self.hidden = YES;
        self.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    }
    return self;
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
-(PeriodicalLinkInfo *)currentLinkInfo
{
    return info;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)hrefReloadWeb:(PeriodicalLinkInfo *)item
{
    if ([info.linkUrl isEqualToString:item.linkUrl]) {
        return;
    }

    if (!activity.superview) {
        [self.superview addSubview:activity];
    }
    self.hidden = YES;
    MagazineManager *manager = [MagazineManager sharedInstance];
    [manager cancelPeriodicalLinkInfo:info];
    info = item;
    if (self.loading) {
        [self stopLoading];
    }
    
    [manager getPeriodicalContent:info complete:^(BOOL success, PeriodicalHtmlResolvingResult *result) {
        htmlDomReady = NO;
        contentResolvingResult = result;
        [self loadHTMLString:result.resolvedContent baseURL:nil];
        [self downloadImagesIfNecessary:result];
    }];


}
- (void)showMe {
	self.hidden = NO;
}
-(void)phoneWebViewDidFinishLoad
{
    htmlDomReady = YES;
    if([[[UIDevice currentDevice] systemVersion] isVersionHigherThanOrEqualsTo:@"6.0"])
        [self performSelector:@selector(showMe) withObject:nil afterDelay:0.3];
    else
        self.hidden = NO;
    
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
                CGSize size = [ImageUtil getImageSize:idt.targetFilePath];
                NSString *js = [NSString stringWithFormat:@"setImgSrcAndSize('%@','file://%@','%f','%f');",
                                imgInfo.imageId,idt.targetFilePath,size.width,size.height];
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
-(void)webWillDealloc
{
    MagazineManager *manager = [MagazineManager sharedInstance];
    [manager cancelPeriodicalLinkInfo:info];
    [self cleanForDealloc];
}
#pragma mark - DownloadImages
-(void)downloadImagesIfNecessary:(PeriodicalHtmlResolvingResult *)result
{
    for(ImageDownloadingTask *task in imageDownloaderArr)
    {
        [[ImageDownloader sharedInstance] cancelDownload:task];
    }
    [imageDownloaderArr removeAllObjects];
    
    for(ThreadContentImageInfoV2 * imageInfo in result.herfArr)
    {
        //本地图片已经就绪，直接跳过，无须处理
        if(imageInfo.isLocalImageReady)
            continue;
        
        NSString* imgPath = imageInfo.expectedLocalPath;
        
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
                //下载完成，需要将
                ((ThreadContentImageInfoV2*)idt.userData).isLocalImageReady = YES;
                if(!htmlDomReady)
                {
                    //webview尚未加载完成，需要等到完成后再更新img
                }
                else
                {
                    //立刻更新img
                    CGSize size = [ImageUtil getImageSize:idt.targetFilePath];
                    NSString *js = [NSString stringWithFormat:@"setImgSrcAndSize('%@','file://%@','%f','%f');",
                                    imageInfo.imageId,idt.targetFilePath,size.width,size.height];
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
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [webViewDelegate webViewDidEndDragging:scrollView willDecelerate:NO];
}

-(void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    activity.activityIndicatorViewStyle  = [[ThemeMgr sharedInstance] isNightmode]?UIActivityIndicatorViewStyleWhiteLarge:UIActivityIndicatorViewStyleGray;

    activity.hidden = !hidden;
}
-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    activity.frame = CGRectMake(frame.size.width/2-20.0f +
                                frame.origin.x,
                                frame.size.height/2-20.0f,
                                40.0f, 40.0f);
}

@end
