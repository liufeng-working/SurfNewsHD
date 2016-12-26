//
//  PictureThreadView.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-1-16.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PictureThreadView.h"
#import "PathUtil.h"
#import "ImageDownloader.h"
#import "ThreadsManager.h"
#import "ImageUtil.h"
#import "NSString+Extensions.h"
#import "FileUtil.h"
#import "HotIconFlagManager.h"
#import "NSString+Extensions.h"
#import "ThreadSummary.h"
#import "SNNewsListUIHelper.h"
#import "HotChannelsListResponse.h"

#ifdef ipad
    #define PictureThreadViewHeight 113.0f
    #define PictureWidth 128.0f     // 图片宽度
    #define PictureHeight 90.0f     // 图片高度
    #define TitleFontSize 21.0f     // 标题字体大小
    #define ContentFontSize 14.0f   // 内容字体大小
    #define GAP 10.f
#endif


/////////////////////////////////////////////////////////////////////////////////////////
// PictureThreadView
/////////////////////////////////////////////////////////////////////////////////////////
@implementation PictureThreadView
static UIImage *defImage = nil;         // 默认图片
static UIColor *readColorTitle = nil;
static UIColor *unReadColorTitle = nil;
static UIColor *unReadColorTitle_Night = nil;
static UIColor *sourceColor = nil;

+ (CGFloat)viewHeight:(ThreadSummary*)ts
{
    return [[SNNewsListUIHelper sharedInstance] calcHeightWithThreadSummary:ts];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {        
        __unsafe_unretained PictureThreadView* this = self;
        regThread = ^(ThreadSummary* thread,BOOL read){           
            if (this->threadSum != nil && read && this->threadSum == thread) {                      
                [this setNeedsDisplay];
            }
        };
        [[ThreadsManager sharedInstance] registerThreadReadChangedHandler:regThread];
        
        // 添加默认图片
        if (defImage == nil) {
            defImage = [UIImage imageNamed:@"loading"]; // 80*60
            
            // 文字颜色
            readColorTitle = [UIColor colorWithHexValue:kReadContentColor];
            unReadColorTitle = [UIColor colorWithHexValue:kUnreadTitleColor];
            unReadColorTitle_Night = [UIColor colorWithHexValue:kUnreadTitleColor_Night];
            sourceColor = readColorTitle;
        }
        
        lineColor = [UIColor colorWithHexValue:0xFFe3e2e2];
        
        [self setOpaque:NO];
        
        _imagesTalk = [NSMutableArray array];
        _images = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc{
    [[ThreadsManager sharedInstance] unregisterThreadReadChangedHandler:regThread];
}

- (void)reloadThreadSummary:(ThreadSummary*)_ts
{
    for (NSInteger i=0; i<[_imagesTalk count]; ++i){
        ImageDownloadingTask* t = [_imagesTalk objectAtIndex:i];
        [[ImageDownloader sharedInstance] cancelDownload:t];
    }
    [_imagesTalk removeAllObjects];
    
    
    threadSum = _ts;
    threadImg = nil;
    hotImage = nil;
    
    // 加载图片
    if([_ts isNeedLoadImage])
        [self loadingImage:_ts];    // 加载图片
    
    CGRect tempFrame = self.frame;
    tempFrame.size.height = [[SNNewsListUIHelper sharedInstance] calcHeightWithThreadSummary:_ts];
    self.frame = tempFrame;
    
    
    // 加载热点图标
    if (threadSum.iconPath != nil &&
        ![threadSum.iconPath isEmptyOrBlank])
    {
        HotIconFlagManager *iconFlagM = [HotIconFlagManager sharedInstance];
        hotImage = [iconFlagM getHotIconWithUrl:threadSum.iconPath
                           imgCompletionHandler:^(NSString *imgName, UIImage *iconImg) {
                               if ([threadSum.iconPath rangeOfString:imgName options:NSBackwardsSearch].location != NSNotFound){
                                   hotImage = iconImg;
                                   [self setNeedsDisplay];
                               }
                           }];
    }
    
    [self setNeedsDisplay];
}

// 工具函数
- (void)loadingImage:(ThreadSummary *)ts
{
    NSFileManager* fm = [NSFileManager defaultManager];
    threadImg = defImage;
    SNNewsListUIHelper *uiHelper =
    [SNNewsListUIHelper sharedInstance];
    CGSize imgSize = [uiHelper newsImageSize];
    if (ts.showType == TSShowType_Image_mutable) {
        [_images setObject:defImage forKey:@(0)];
        [_images setObject:defImage forKey:@(1)];
        [_images setObject:defImage forKey:@(2)];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_group_t group = dispatch_group_create();
        for (NSInteger i = 0; i<[ts.multiImgUrl count] && i<3; ++i) {
            NSString *imgPath = [PathUtil pathOfThreadMultiLogo:ts atImageIndex:i];
            NSString *url = [(SNMultiImageUrl*)ts.multiImgUrl[i] imgUrl];
            if (![fm fileExistsAtPath:imgPath]) {
                if ( url && ![url isEmptyOrBlank]) {
                    [self requestImage:url
                           saveImgPath:imgPath
                            imageIndex:@(i)
                               imgSize:imgSize];
                }
            }
            else {
                // 加载本地图片
                dispatch_group_async(group, queue, ^{
                    UIImage *img = [self loadLocalImage:imgPath imgSize:imgSize];
                    if (img) {
                        [_images setObject:img forKey:@(i)];
                    }
                });
            }
        }
        
               
        // 通知更新UI
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            [self setNeedsDisplay];
        });
        
        #if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
        dispatch_release(group);
        #endif
    }
    else{
        NSString *imgUrl = ts.imgUrl;
        NSString *imgPath = [PathUtil pathOfThreadLogo:ts];
        if ([ts isBigImageType]) {
            imgUrl = ts.bannerUrl;
            imgSize = [uiHelper newsBigImageSize];
        }
        
        if (![fm fileExistsAtPath:imgPath]) { // 图片文件不存在
            // 请求图片数据
            if (imgUrl && ![imgUrl isEmptyOrBlank]){
                [self requestImage:imgUrl saveImgPath:imgPath imageIndex:@(0) imgSize:imgSize];
            }
        }
        else{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                threadImg = [self loadLocalImage:imgPath imgSize:imgSize];
                [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
                
            });
        }
    }
}


-(void)drawRect:(CGRect)rect
{
    if (threadSum == nil) {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
   
    // 绘制分割线
    float height = CGRectGetHeight(rect);
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);   // 分割线颜色
    if (_isFirstCell)
    {
        CGContextMoveToPoint(context, rect.origin.x, height+rect.origin.y);
        CGContextAddLineToPoint(context, CGRectGetWidth(rect), height+rect.origin.y);
        CGContextStrokePath(context);
    }
    CGContextMoveToPoint(context, rect.origin.x, height+rect.origin.y);
    CGContextAddLineToPoint(context, rect.origin.x+CGRectGetWidth(rect), height+rect.origin.y);
    CGContextStrokePath(context);    
    if([threadSum isBigImageType] ||
       threadSum.showType == TSShowType_Adver_BigImage) {
        [self drawRect_bigImage:context drawRect:rect];
    }
    else if (threadSum.showType == TSShowType_Image_None)
    {
        // 无图模式
        [self drawRect_noimage:context drawRect:rect];
    }
    else if(threadSum.showType == TSShowType_Image_mutable){
        // 多图模式
        [self drawRect_multiImage:context drawRect:rect];
    }
    else if(threadSum.showType == TSShowType_Image_Only ||
            threadSum.showType == TSShowType_Adver_SmallImage){
        // 单图模式
        [self drawRect_image:context drawRect:rect];
    }
    
    UIGraphicsPopContext();
}


// 有图片风格绘制
- (void)drawRect_image:(CGContextRef)context drawRect:(CGRect)rect
{
    SNNewsListUIHelper *ptdh = [SNNewsListUIHelper sharedInstance];
    
    // 间隔
    UIColor *titleColor = nil;
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    CGFloat PictureWidth =[ptdh newsImageSize].width;
    CGFloat PictureHeight =[ptdh newsImageSize].height;
    CGFloat topMarger = ptdh->_contentEdge.top + rect.origin.y;
    CGFloat leftMarger = ptdh->_contentEdge.left + rect.origin.x;
    CGFloat rightMarger = ptdh->_contentEdge.right;
    CGFloat imageAndTextSpace = ptdh->_imageAndTextSpace_image;
    CGFloat drawTextWidth = width-leftMarger-rightMarger-imageAndTextSpace-PictureWidth;
    CGFloat titleAndSource = ptdh->_titleAndSourceSpace_image;
    BOOL isRead = [[ThreadsManager sharedInstance] isThreadRead:threadSum];
    if(isRead){
        titleColor = readColorTitle;
    }else{
        ThemeMgr *mgr = [ThemeMgr sharedInstance];
        if (mgr.isNightmode) {
            titleColor = unReadColorTitle_Night;
        }
        else{
            titleColor = unReadColorTitle;
        }
    }
    
    UIFont *titleFont = ptdh->_titleFont;
    CGFloat fontLineSpacing = [SNNewsListUIHelper fontLineSpace];
    CGFloat titleHeight = ceil(titleFont.lineHeight + fontLineSpacing + titleFont.lineHeight);
    
    
    // 绘制标区域
    CGFloat titleX = leftMarger;
    CGFloat titleY = topMarger;
    CGFloat titleW = drawTextWidth;
    CGFloat titleH = titleHeight;

    // 绘制标题文字
    CGSize maxSize = CGSizeMake(titleW, MAXFLOAT);
    CGFloat calcTitleH = [threadSum.title surfSizeWithFont:titleFont
                                       constrainedToSize:maxSize
                                           lineBreakMode:NSLineBreakByWordWrapping
                          fontLineSpacing:fontLineSpacing].height;
    if (calcTitleH <= titleHeight) {
        titleH = calcTitleH;
    }
    
    //如果标题是一行，y坐标下移 10
    if (calcTitleH <= ceil(titleFont.lineHeight+fontLineSpacing)) {
        titleY += 10;
        titleH -= fontLineSpacing;//如果是一行，需要减去标题之间的间隔
    }
   
    CGRect titleRect = CGRectMake(titleX, titleY, titleW, titleH);
    // 绘制标题
    [threadSum.title surfDrawString:titleRect
                           withFont:titleFont
                          withColor:titleColor
                      lineBreakMode:NSLineBreakByWordWrapping
                          alignment:NSTextAlignmentLeft
                    fontLineSpacing:fontLineSpacing];
    
    // 绘制图片
    CGFloat imageX = width-rightMarger-PictureWidth;
    CGFloat imageY = (rect.origin.y + height-PictureHeight) * 0.5f;
    
    CGRect imgRect = CGRectMake(imageX, imageY, PictureWidth, PictureHeight);
    if (threadImg == defImage) {
        CGFloat defImgW = defImage.size.width;
        CGFloat defImgH = defImage.size.height;
        imgRect = CGRectInset(imgRect, (PictureWidth- defImgW)/2.f, (PictureHeight - defImgH)/2.f);
    }
    [threadImg drawInRect:imgRect];
    
    //绘制视频播放标志（如果是视频频道的话）
    if (threadImg != defImage && [self.hotchannel isVideoChannel]) {
        UIImage * movieImage=[UIImage imageNamed:@"movie_shadow1"];
        CGFloat movieW = movieImage.size.width;
        CGFloat movieH = movieImage.size.height;
        CGFloat movieX = imageX + (CGRectGetWidth(imgRect) - movieW)/2.0;
        CGFloat movieY = imageY + (CGRectGetHeight(imgRect) - movieH)/2.0;
        CGRect movieRect = CGRectMake( movieX, movieY, movieW, movieH);
        [movieImage drawInRect:movieRect];
    }

    // 绘制底部状态
    CGFloat footH = ptdh->_footHeight;
    CGFloat footY = titleY + titleH + titleAndSource;
    CGRect footR = CGRectMake(leftMarger, footY, drawTextWidth, footH);
    [self drawFoot:context drawRect:footR];
}

-(void)drawRect_bigImage:(CGContextRef)context drawRect:(CGRect)rect
{
    SNNewsListUIHelper *ptdh = [SNNewsListUIHelper sharedInstance];
    
    // 间隔
    UIColor *titleColor = nil;
    CGFloat width = CGRectGetWidth(rect);
    CGFloat imgW = [ptdh newsBigImageSize].width;
    CGFloat imgH = [ptdh newsBigImageSize].height;
    if (threadSum.showType == TSShowType_Adver_BigImage) {
        imgW = [ptdh newsAdBigImageSize].width;
        imgH = [ptdh newsAdBigImageSize].height;
    }
    
    CGFloat topMarger = ptdh->_contentEdge.top + rect.origin.y;
    CGFloat leftMarger = ptdh->_contentEdge.left + rect.origin.x;
    CGFloat rightMarger = ptdh->_contentEdge.right;
    CGFloat drawTextWidth = width-leftMarger-rightMarger;
    CGFloat vSpace = ptdh->_verticalSpace; 
    BOOL isRead = [[ThreadsManager sharedInstance] isThreadRead:threadSum];
    if(isRead){
        titleColor = readColorTitle;
    }else{
        ThemeMgr *mgr = [ThemeMgr sharedInstance];
        if (mgr.isNightmode) {
            titleColor = unReadColorTitle_Night;
        }
        else{
            titleColor = unReadColorTitle;
        }
    }
    
    
    UIFont *titleFont = ptdh->_titleFont;
    CGFloat fontLineSpacing = [SNNewsListUIHelper fontLineSpace];
    CGFloat titleHeight = ceil(titleFont.lineHeight + fontLineSpacing + titleFont.lineHeight);
    
    
    // 绘制标区域
    CGFloat titleY = topMarger;
    CGRect titleRect = CGRectMake(leftMarger, titleY, drawTextWidth,titleHeight);
    
    // 绘制标题文字
    CGSize maxSize = CGSizeMake(drawTextWidth, MAXFLOAT);
    CGFloat calcTitleH = [threadSum.title surfSizeWithFont:titleFont
                                         constrainedToSize:maxSize
                                             lineBreakMode:NSLineBreakByWordWrapping
                                           fontLineSpacing:fontLineSpacing].height;
    if (calcTitleH <= titleHeight) {
        titleRect.size.height = calcTitleH;
    }
    //如果标题是一行
    if (calcTitleH <= ceil(titleFont.lineHeight+fontLineSpacing)) {
        titleRect.size.height -= fontLineSpacing;//如果是一行，需要减去标题之间的间隔
    }
    
    // 绘制标题
    [threadSum.title surfDrawString:titleRect
                           withFont:titleFont
                          withColor:titleColor
                      lineBreakMode:NSLineBreakByWordWrapping
                          alignment:NSTextAlignmentLeft
                    fontLineSpacing:fontLineSpacing];
    
    // 绘制图片
    CGFloat imageX = leftMarger;
    CGFloat imageY = titleRect.origin.y + CGRectGetHeight(titleRect) +
    vSpace;
    CGRect imgRect = CGRectMake(imageX, imageY, imgW, imgH);
    if (threadImg == defImage) {
        CGFloat defImgW = defImage.size.width;
        CGFloat defImgH = defImage.size.height;
        imgRect = CGRectInset(imgRect, (imgW- defImgW)/2.f, (imgH - defImgH)/2.f);
    }
    [threadImg drawInRect:imgRect];
    
    // 绘制底部状态
    CGFloat footH = ptdh->_footHeight;
    CGFloat footY = CGRectGetMaxY(imgRect) + vSpace-1;
    CGRect footR = CGRectMake(leftMarger, footY, drawTextWidth, footH);
    [self drawFoot:context drawRect:footR];
}


// 没有图片风格绘制
- (void)drawRect_noimage:(CGContextRef)context drawRect:(CGRect)rect
{
    SNNewsListUIHelper *ptdh = [SNNewsListUIHelper sharedInstance];
    
    // 参数
    UIColor *titleColor = nil;
    CGFloat topMarger = ptdh->_contentEdge.top+ rect.origin.y;
    CGFloat leftMarger = ptdh->_contentEdge.left+ rect.origin.x;
    CGFloat rightMarger = ptdh->_contentEdge.right;
    CGFloat drawTextWidth = CGRectGetWidth(rect)-leftMarger-rightMarger;
    CGFloat titleAndSource = ptdh->_titleAndSourceSpace_noimage;
    BOOL isRead = [[ThreadsManager sharedInstance] isThreadRead:threadSum];
    if(isRead){
        titleColor = readColorTitle;
    }else{
        ThemeMgr *mgr = [ThemeMgr sharedInstance];
        if (mgr.isNightmode) {
            titleColor = unReadColorTitle_Night;
        }
        else{
            titleColor = unReadColorTitle;
        }
    }

    CGFloat FontLineSpacing = [SNNewsListUIHelper fontLineSpace];
    
    
    // 绘制标题文字
    UIFont *titleFont = ptdh->_titleFont;
    CGFloat titleWidth = drawTextWidth;
    CGFloat maxTitleH = ceil(titleFont.lineHeight + titleFont.lineHeight + FontLineSpacing);
    // 判断是否是T+新闻
    if ([threadSum isTPlusNews]) {
        titleWidth -= 15.f;
    }
    CGFloat titleHeight = [threadSum.title
                           surfSizeWithFont:titleFont
                           constrainedToSize:CGSizeMake(titleWidth, MAXFLOAT)
                           lineBreakMode:NSLineBreakByWordWrapping
                           fontLineSpacing:FontLineSpacing].height;
    titleHeight = titleHeight > maxTitleH ? maxTitleH : titleHeight;
    //如果标题是一行
    if (titleHeight <= ceil(titleFont.lineHeight+FontLineSpacing)) {
        titleHeight -= FontLineSpacing;//如果是一行，需要减去标题之间的间隔
    }
    
    CGRect titleRect = CGRectMake(leftMarger, topMarger, titleWidth, titleHeight);
    
    [threadSum.title surfDrawString:titleRect withFont:titleFont withColor:titleColor lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft fontLineSpacing:FontLineSpacing];

    // 底部状态栏
    CGFloat footH = ptdh->_footHeight;
    CGFloat footY=topMarger + titleHeight + titleAndSource;
    CGRect footR = CGRectMake(leftMarger,footY,drawTextWidth,footH);
    [self drawFoot:context drawRect:footR];
}

// 多图片风格绘制
- (void)drawRect_multiImage:(CGContextRef)context drawRect:(CGRect)rect
{
    SNNewsListUIHelper *ptdh = [SNNewsListUIHelper sharedInstance];
    
    // 参数
    UIColor *titleColor = nil;
    float topMarger = ptdh->_contentEdge.top+ rect.origin.y;
    float leftMarger = ptdh->_contentEdge.left+ rect.origin.x;
    float rightMarger = ptdh->_contentEdge.right;
    float drawTextWidth = CGRectGetWidth(rect)-leftMarger-rightMarger;
    BOOL isRead = [[ThreadsManager sharedInstance] isThreadRead:threadSum];
    if(isRead){
        titleColor = readColorTitle;
    }else{
        ThemeMgr *mgr = [ThemeMgr sharedInstance];
        if (mgr.isNightmode) {
            titleColor = unReadColorTitle_Night;
        }
        else{
            titleColor = unReadColorTitle;
        }
    }
    
    // 绘制标题文字
    UIFont *titleFont = ptdh->_titleFont;
    CGFloat FontLineSpacing = [SNNewsListUIHelper fontLineSpace];
    CGFloat titleMaxH = ceil(titleFont.lineHeight + titleFont.lineHeight + FontLineSpacing);
    CGFloat titleH = [threadSum.title surfSizeWithFont:titleFont
                                         constrainedToSize:CGSizeMake(drawTextWidth, MAXFLOAT)
                                             lineBreakMode:NSLineBreakByWordWrapping
                                           fontLineSpacing:FontLineSpacing].height;
    if (titleH > titleMaxH) {
        titleH = titleMaxH;
    }
    //如果标题是一行
    if (titleH <= ceil(titleFont.lineHeight+FontLineSpacing)) {
        titleH -= FontLineSpacing;//如果是一行，需要减去标题之间的间隔
    }
    
    CGRect tRect = CGRectMake(leftMarger, topMarger, drawTextWidth, titleH);
    // 绘制标题
    [threadSum.title surfDrawString:tRect
                           withFont:titleFont
                          withColor:titleColor
                      lineBreakMode:NSLineBreakByWordWrapping
                          alignment:NSTextAlignmentLeft
                    fontLineSpacing:FontLineSpacing];
    
    // 绘制多图
    float imgLRSpace = ptdh->_imagesLRSpace_multiImg; // 图片左右间隔
    float imgAndSourceSpace = ptdh->_imagesAndSourceUDSpace_multiImg;// 图片和来源的上下间隔
    float imgBeginY = tRect.origin.y + CGRectGetHeight(tRect) + ptdh->_titleAndImagesUDSpace_multiImg;
    
    CGFloat imageWidth = [ptdh newsImageSize].width;
    CGFloat imageHeight = [ptdh newsImageSize].height;
    CGRect imgRect0 = CGRectMake(leftMarger, imgBeginY, imageWidth, imageHeight);
    CGRect imgRect1 = CGRectOffset(imgRect0, imageWidth+imgLRSpace, 0);
    CGRect imgRect2 = CGRectOffset(imgRect1, imageWidth+imgLRSpace, 0);
    

    UIImage *img0 = [_images objectForKey:@(0)];
    UIImage *img1 = [_images objectForKey:@(1)];
    UIImage *img2 = [_images objectForKey:@(2)];
    
    CGFloat defImgW = defImage.size.width;
    CGFloat defImgH = defImage.size.height;
    if (img0 == defImage) {
        imgRect0 = CGRectInset(imgRect0, (imageWidth- defImgW)/2.f, (imageHeight - defImgH)/2.f);
    }
    if (img1 == defImage) {
        imgRect1 = CGRectInset(imgRect1, (imageWidth- defImgW)/2.f, (imageHeight - defImgH)/2.f);
    }
    if (img2 == defImage) {
        imgRect2 = CGRectInset(imgRect2, (imageWidth- defImgW)/2.f, (imageHeight - defImgH)/2.f);
    }
    
    
    [img0 drawInRect:imgRect0];
    [img1 drawInRect:imgRect1];
    [img2 drawInRect:imgRect2];
    
    
    // 绘制底部状态标记
    CGFloat footH = ptdh->_footHeight;
    float footY = imgBeginY + imageHeight + imgAndSourceSpace;
    CGRect footR = CGRectMake(leftMarger, footY, drawTextWidth, footH);
    [self drawFoot:context drawRect:footR];
}

// 绘制底部标记功能（来源，热点，正能量）
-(void)drawFoot:(CGContextRef)context drawRect:(CGRect)rect
{
    CGFloat drawX = rect.origin.x;
    CGFloat drawY = rect.origin.y;
//    CGFloat drawH = CGRectGetHeight(rect);
    BOOL isNight = [[ThemeMgr sharedInstance] isNightmode];
    SNNewsListUIHelper *ptdh = [SNNewsListUIHelper sharedInstance];
    HotIconFlagManager *iconM = [HotIconFlagManager sharedInstance];
    CGFloat footSpace = ptdh->_footSpace;
    UIFont *sourceFont = ptdh->_sourceFont;
    // 1. hot图片
    CGFloat hotH = hotImage.size.height * 0.5;//17
    if (hotImage) {
        CGFloat hotW = hotImage.size.width * 0.5;//29
        CGFloat hotY = drawY;
        [hotImage drawInRect:CGRectMake(drawX, hotY, hotW, hotH)];
        drawX += hotW;
        drawX += footSpace;
    }
    
    // 2. 正负能量图标
    CGFloat enH=0;
    if (threadSum.is_energy) {
        BOOL isPositive = (threadSum.positive_energy >= labs(threadSum.negative_energy));
        
        UIImage *enImg;
        if (isPositive) {
            enImg = iconM.pEnergyImg;
        }else {
            enImg = isNight?iconM.nEnergyImg_night:iconM.nEnergyImg;
        }
        
        CGFloat enW = enImg.size.width - 2.f;//-2 为了保持和来源文字同高
                enH = enImg.size.height - 2.f;
        CGFloat enY = drawY;

        //如果有热图
        if(hotImage)
        {
//            enW = hotH;
//            enH = hotH;
            enY += (hotH-enH)/2.f;
        }

        [enImg drawInRect:CGRectMake(drawX, enY, enW, enH)];
        drawX += enW;
        drawX += footSpace;
    }
    
    
    // 来源数据
    CGFloat sourceMaxWidth = CGRectGetWidth(rect);
    
    // 评论 + 评论数
    if([threadSum isComment] && threadSum.comment_count > 0) {
        
        NSString *commentStr =
        [NSString stringWithFormat:@"%@",@(threadSum.comment_count)];
        CGSize cStrSize = [commentStr surfSizeWithFont:sourceFont constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        CGFloat strX = rect.origin.x + rect.size.width - cStrSize.width-2.f;

        CGFloat strY=drawY;
       if (hotImage){
            strY = drawY + (hotH - cStrSize.height)/2.f;
       }else if (enH) {
           strY = drawY + (enH - cStrSize.height)/2.f;
       }
        
        CGRect strR = CGRectMake(strX, strY, cStrSize.width, cStrSize.height);
        [commentStr surfDrawString:strR
                          withFont:sourceFont
                         withColor:sourceColor
                     lineBreakMode:NSLineBreakByWordWrapping
                         alignment:NSTextAlignmentRight];
        
        // 绘制评论标记
        UIImage *commentFlag = [iconM commentFlag];
        if (commentFlag) {
            CGFloat flagX = strX - commentFlag.size.width-footSpace;
            CGFloat flagY = strY + 2 ;//加2 是为了对齐
            [commentFlag drawAtPoint:CGPointMake(flagX, flagY)];
        }
        
        sourceMaxWidth = strX - 20;
    }

    // 3. 绘制来源
    sourceMaxWidth -= drawX;
    CGFloat sourceX = drawX;
    CGFloat sourceY = drawY;
    CGFloat sourceW = sourceMaxWidth;
    CGFloat sourceH = sourceFont.lineHeight;
    if (hotImage){
        sourceY = drawY + (hotH - sourceH)/2.f;
    }else if (enH) {
        sourceY = drawY + (enH - sourceH)/2.f;
    }
    CGRect sourceRect = CGRectMake(sourceX, sourceY, sourceW, sourceH);

    [threadSum.source surfDrawString:sourceRect
                            withFont:sourceFont
                           withColor:sourceColor
                       lineBreakMode:NSLineBreakByCharWrapping
                           alignment:NSTextAlignmentLeft];
}



-(void)viewNightModeChanged:(BOOL)isNight{
    [self setNeedsDisplay];
}

- (NSString *)TimeFormat:(NSDate *)date{
    if (date == nil) {
        return @"";
    }
    
    
    NSDateFormatter *df = [NSDateFormatter new];
    df.dateFormat = @"yyyy-MM-dd";
    NSString *dateString = [df stringFromDate:date];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|kCFCalendarUnitHour|kCFCalendarUnitMinute|kCFCalendarUnitSecond
                                               fromDate:date toDate:[NSDate date] options:0];
    
    // 居然发现，服务器给我超前时间，对所有超前时间都显示最新
    if ([components year] < 0 || [components month] < 0 || [components day] < 0 || [components hour] < 0) {
         dateString = @"最新";
    }
    else if ([components hour] < 12 && [components day] == 0 &&
        [components month] == 0 && [components year] == 0) {
        if ([components hour] == 0){ // 1 小时之内的时间
            if ([components minute] > 0) {
                dateString = [NSString stringWithFormat:@"%@分钟之前", @([components minute])];
            }
            else if ([components second] > 0){
                dateString = [NSString stringWithFormat:@"%@秒之前", @([components second])];
            }
            else{
                dateString = @"最新";
            }
        }
        else {            
            dateString = [NSString stringWithFormat:@"%@小时之前", @([components hour])];
        }
    }
    return dateString;
}

#pragma mark UIImage tool 
// 请求服务器图片并保存
- (void)requestImage:(NSString *)imgUrl
         saveImgPath:(NSString *)savePath
          imageIndex:(NSNumber *)imgIdx
             imgSize:(CGSize)imgSize
{
    ImageDownloadingTask *task = [ImageDownloadingTask new];
    [_imagesTalk addObject:task];
    [task setImageUrl:imgUrl];
    [task setUserData:imgIdx];
    [task setUserData2:threadSum];
    [task setTargetFilePath:savePath];
    [task setCompletionHandler:^(BOOL succeeded, ImageDownloadingTask *idt)
    {
        if (idt) {
            [_imagesTalk removeObject:idt];
        }
        
        if(succeeded && idt.userData2 != nil ){
            ThreadSummary *tempTs = idt.userData2;
            if (tempTs == threadSum ||
                threadSum.threadId == tempTs.threadId)
            {
                UIImage *tempImg = [UIImage imageWithData:[idt resultImageData]];
                
                if (tempImg) {
                    if (tempTs.showType == TSShowType_Image_mutable) {
                        [_images setObject:tempImg forKey:idt.userData];
                    }
                    else {
                        threadImg = tempImg;
                    }
                    [self setNeedsDisplay];
                }
            }
        }
    }];
    [[ImageDownloader sharedInstance] download:task];
    
}


// 加载本地图片
-(UIImage*)loadLocalImage:(NSString*)imgPath imgSize:(CGSize)imgSize
{
//    NSData *imgData = [NSData dataWithContentsOfFile:imgPath];
//    return [ImageUtil imageWithImage:[UIImage imageWithData:imgData]
//     scaledToSizeWithSameAspectRatio:imgSize
//                     backgroundColor:[UIColor colorWithHexValue:KImageDefaultBGColor]];
    
    NSData *imgData = [NSData dataWithContentsOfFile:imgPath];
    return [UIImage imageWithData:imgData];
}
@end