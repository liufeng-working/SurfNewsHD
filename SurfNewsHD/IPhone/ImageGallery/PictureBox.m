//
//  PictureBox.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-5-13.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PictureBox.h"
#import "ImageUtil.h"
#import "CustomPageControl.h"
#import "SNPictureSummaryView.h"
#import "ImageDownloader.h"
#import "FileUtil.h"
#import "NSString+Extensions.h"
#import "ImageUtil.h"
#import "PhotoCollectionData.h"
#import "PathUtil.h"
#import "FileUtil.h"
#import "PhotoGalleryPreviewItem.h"
#import "PhotoCollectionManager.h"
#import "ThreadsManager.h"
#import "SurfNotification.h"
#import "AppSettings.h"
#import "UIButton+Block.h"
#import "PhoneshareWeiboInfo.h"
#import "PhoneWeiboController.h"



#define kItemViewGap 20.f       // PictureItem之间的间隔
#define kImageViewMaxScale 2.f  // 图片View的缩放比例
#define kPreviewPhotoCollectionTotal 3// 添加预览图集的总数

@class PictureItem;


@interface PictureItem : UIScrollView <UIScrollViewDelegate>
{
    UIImageView *imageView;
    UIImage *_viewImage;        // 旋转之前的图片
    CGRect _backupRect;    
    UIImageOrientation _imageOrientation;
    BOOL isAction;
    UIActivityIndicatorView *_hotwheel;
}
@property(nonatomic,weak)PhotoCollection *photoColl;// 图集


- (UIImage*)itemImage;
- (void)setItemImage:(UIImage*)img;
// 恢复图片比例
- (void)recoverImageScale;
- (void)recoverRotateNone;
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;
- (void)handleDoubleTap:(UIGestureRecognizer *)gesture;
-(void)rotateAndScale;


- (void)startHotwheel;
- (void)stopHotwheel;
//- (BOOL)isDefaultImage; // 显示的是默认图片
@end



///////////////////////////////////////////////////////////////
// PictureBox
///////////////////////////////////////////////////////////////
@interface PictureBox (){
    UIView *_customTabBar;
    UIButton *_rotateButton;
//    UIButton *offlineBtn;
    UIButton *_moreBtn;
    UIActivityIndicatorView *_hdImgactivity;
    
    UIInterfaceOrientation _orientation;// 控件方向
    float _width;
    float _height;
    float _scrollViewOffX; // 用来过滤ScrollView回弹事件处理
    
    NSMutableArray *_idleItems; // 暂时不用的items 包含PhotoGalleryPreviewItem 和PictureItem
    
    // 图集模式
    NSMutableArray *_previewDataArray;
    BOOL _isClickHider;   // 记录当前标题控件是否显示
    
    __weak UIControl *_moreMenuView; // 更多二级菜单
    
}
@property(nonatomic,strong)UIScrollView *pictureScrollView; //  图片滚动窗口
@property(nonatomic,strong)NSMutableArray* picturesArray;
@property(nonatomic,strong)UIImage *defaultImage;
@property(nonatomic,strong)CustomPageControl *pageCtrl;
@property(nonatomic,strong)SNPictureSummaryView *tipsView;
@property(nonatomic,strong)UIButton *hdImgDownloadBtn;// 高清图片下载按钮
@end

@implementation PictureBox


- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _width = CGRectGetWidth(frame);
        _height = CGRectGetHeight(frame);
        _idleItems = [NSMutableArray arrayWithCapacity:3];
        _picturesArray = [NSMutableArray arrayWithCapacity:10];
        
        CGRect pictureRect = CGRectMake(0, 0, CGRectGetWidth(frame) + kItemViewGap, CGRectGetHeight(frame));
        _pictureScrollView = [[UIScrollView alloc] initWithFrame:pictureRect];
        _pictureScrollView.delegate = self;
        _pictureScrollView.pagingEnabled = YES;
        _pictureScrollView.userInteractionEnabled = YES;
        _pictureScrollView.showsHorizontalScrollIndicator = NO;
        _pictureScrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:_pictureScrollView];
        
        
        float bgH = 49.f; // 底部状态栏高度       
        CGRect itemRect = self.bounds;
        [_idleItems addObject:[[PictureItem alloc] initWithFrame:itemRect]];
        [_idleItems addObject:[[PictureItem alloc] initWithFrame:itemRect]];
        [_idleItems addObject:[[PictureItem alloc] initWithFrame:itemRect]];
        
        //默认图片
        _defaultImage = [ImageUtil imageCenterWithImage:[UIImage imageNamed:@"loading"]
                                             targetSize:CGSizeMake(frame.size.width, frame.size.height)
                                        backgroundColor:[UIColor colorWithHexValue:KImageDefaultBGColor]];
        
        
        
        // tabBar 背景
        float ctrlWidth = CGRectGetWidth(frame);
        float ctrlHeight = CGRectGetHeight(frame);
        _customTabBar = [[UIView alloc] initWithFrame:CGRectMake(0.f, ctrlHeight - bgH, ctrlWidth, bgH)];
        _customTabBar.backgroundColor = [[UIColor alloc] initWithRed:0.f green:0.f blue:0.f alpha:0.6];
        [self addSubview:_customTabBar];
        {
            // 返回按钮
            UIImage *backImage = [UIImage imageNamed:@"backBar"];
            float bW = backImage.size.width;
            float bH = backImage.size.height;
            float bY = (bgH - bH) * 0.5;
            CGRect bRect = CGRectMake(0.f, bY, bW, bH);
            UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            backBtn.frame = bRect;
            [backBtn setBackgroundImage:backImage forState:UIControlStateNormal];
            [backBtn addTarget:self action:@selector(BackButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [_customTabBar addSubview:backBtn];
            
            // 离线下载按钮
            // 修改更多按钮
            UIImage *moreImg = [UIImage imageNamed:@"moreBar"];//128*98
            CGFloat mW = moreImg.size.width;
            CGFloat mH = moreImg.size.height;
            CGFloat mY = (bgH - mH) * 0.5f;
            CGRect mR = CGRectMake(ctrlWidth - mW, mY, mW, mH);
            _moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_moreBtn setFrame:mR];
            [_moreBtn setBackgroundImage:moreImg forState:UIControlStateNormal];
            [_moreBtn addTarget:self
                        action:@selector(moreButtonClick:)
              forControlEvents:UIControlEventTouchUpInside];
            [_customTabBar addSubview:_moreBtn];
            
            
            // pageControl
            float pageX = bRect.origin.x + bRect.size.width + 10;
            float pageW = ctrlWidth - bW - mW  - 10 - 10 - 10;
            CGRect pageRect = CGRectMake(pageX, bY, pageW, bH);
            _pageCtrl = [[CustomPageControl alloc] initWithFrame:pageRect];
            _pageCtrl.backgroundColor = [UIColor clearColor];
            _pageCtrl.userInteractionEnabled = NO;
            _pageCtrl.indicatorNormalColor = [UIColor colorWithHexValue:0xff999292];
            _pageCtrl.indicatorHighlightedColor = [UIColor colorWithHexValue:0xffAD2F2F];
            _pageCtrl.indicatorSize = CGSizeMake(15, 5);
            _pageCtrl.hidesForSinglePage = YES;
            [_customTabBar addSubview:_pageCtrl];
        }
        
        // 图片内容简介
        _tipsView = [[SNPictureSummaryView alloc] initWithBottomY:ctrlHeight - bgH];
        _tipsView.backgroundColor = [[UIColor alloc] initWithRed:0.f green:0.f blue:0.f alpha:0.6];
        [self addSubview:_tipsView];
        
        
        // 旋转按钮（2014.3.11 改成自动旋转开关功能按钮）
        _rotateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rotateButton.frame = CGRectMake(CGRectGetWidth(frame)- 50.0f, 10, 45, 45);
        [self UpdateLockScreenButtonBg];
        [_rotateButton addTarget:self action:@selector(lockScreenButtonClickEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_rotateButton];
        
        
        // 高清图片下载按钮
        _hdImgDownloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _hdImgDownloadBtn.hidden = YES;
        UIImage *sourceImage = [UIImage imageNamed:@"high-definition-source-url.png"];
        CGRect hdImgRect = CGRectMake(_rotateButton.frame.origin.x - 10 - sourceImage.size.width, 0,
                                      sourceImage.size.width, sourceImage.size.height);
        _hdImgDownloadBtn.frame = hdImgRect;
        CGPoint centerPoint = _hdImgDownloadBtn.center;
        centerPoint.y = _rotateButton.center.y;
        _hdImgDownloadBtn.center = centerPoint;
        [_hdImgDownloadBtn setBackgroundImage:sourceImage forState:UIControlStateNormal];
        [_hdImgDownloadBtn addTarget:self action:@selector(downloadHDImageButtonClick:)
                    forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_hdImgDownloadBtn];
        
        
        _hdImgactivity = [[UIActivityIndicatorView alloc] initWithFrame:_hdImgDownloadBtn.frame];
        _hdImgactivity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        _hdImgactivity.hidden = YES;
        [_hdImgactivity startAnimating];
        //        [self addSubview:_hdImgactivity];
        
        // 单击隐藏提示框
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(hiderTipsClick:)];
        tapGesture.delegate = self;
        [_pictureScrollView addGestureRecognizer:tapGesture];
        
        // 双击放大图片和缩小图片
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(handleDoubleTap:)];
        [doubleTapGesture setNumberOfTapsRequired:2];
        [_pictureScrollView addGestureRecognizer:doubleTapGesture];
        //如果不加下面的话，当单指双击时，会先调用单指单击中的处理，再调用单指双击中的处理
        [tapGesture requireGestureRecognizerToFail:doubleTapGesture];
        
        
        _previewDataArray = [NSMutableArray arrayWithCapacity:5];
        _orientation = UIInterfaceOrientationPortrait;
        
        
        [self addOrientationChangeNotification];
    }
    return self;
}




// 加载数据
- (void)reloadDataWithImageInfoV2Array:(NSString*)title
                            imageArray:(NSArray*)imgArray
                            imageIndex:(NSUInteger)imgIdx
                     isHightDefinition:(BOOL)hight
{
    isHightDefinition = hight;
    [[self picturesArray] removeAllObjects];
    [[self picturesArray] addObjectsFromArray:imgArray];

    
    NSUInteger imgCount = [_picturesArray count];
    _pageCtrl.numberOfPages = imgCount;
    _pageCtrl.currentPage = imgIdx;
    if (imgCount == 0) {
        return;
    }
    
    
    float scrollWidth = CGRectGetWidth([_pictureScrollView bounds]);
    float scrollHeight = CGRectGetHeight([_pictureScrollView bounds]);
    CGSize contentSize = CGSizeMake(scrollWidth * (imgCount > 3 ? 3 : imgCount), scrollHeight);
    [_pictureScrollView setContentSize:contentSize];
    
    
    NSUInteger imageIndex = imgIdx < imgCount ? imgIdx : 0;
    NSMutableArray *subviews = [NSMutableArray arrayWithArray:_pictureScrollView.subviews];
    
    [_idleItems addObjectsFromArray:subviews];
    [_idleItems makeObjectsPerformSelector:@selector(removeFromSuperview)];// scrollview 就没有子控件了
    [_idleItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        // 把PictureItem图片初始化成空
        if ([obj isKindOfClass:[PictureItem class]]) {
            [(PictureItem*)obj setTag:NSNotFound];
            [(PictureItem*)obj setItemImage:nil];
            [(PictureItem*)obj setFrame:_pictureScrollView.bounds];            
        }
    }];
    
    
    
    if ([_picturesArray count] == 1) {
        UIView* oneView = [self getPictureItemFromIdleItems];
        [_pictureScrollView addSubview:oneView];
        [oneView setTag:0];
        [self LoadPictureItemImageWithThreadContentImageInfoV2:(PictureItem*)oneView
                                                   imageInfoV2:[_picturesArray objectAtIndex:0]];
        
        // 一张图设置区域要大一点，不然就不滚动了
        contentSize.width += 1.f;
        [_pictureScrollView setContentSize:contentSize];
    }
    else if([_picturesArray count] == 2){
        NSUInteger index0, index1;
        if (imageIndex == 0) {
            index0 = imageIndex;
            index1 = imageIndex + 1;
            _pictureScrollView.contentOffset = CGPointZero;
        }
        else{
            index0 = imageIndex - 1;
            index1 = imageIndex;
            _pictureScrollView.contentOffset = CGPointMake(scrollWidth, 0.f);
        }
        
        UIView* oneView = [self getPictureItemFromIdleItems];
        [_pictureScrollView addSubview:oneView];
        [oneView setTag:index0];
        [self LoadPictureItemImageWithThreadContentImageInfoV2:(PictureItem*)oneView
                                                   imageInfoV2:[_picturesArray objectAtIndex:index0]];
        

        UIView* twoView = [self getPictureItemFromIdleItems];
        twoView.frame = CGRectOffset(twoView.frame, scrollWidth, 0);
        [twoView setTag:index1];
        [_pictureScrollView addSubview:twoView];
        [self LoadPictureItemImageWithThreadContentImageInfoV2:(PictureItem*)twoView
                                                   imageInfoV2:[_picturesArray objectAtIndex:index1]];
    }
    else if ([_picturesArray count] >= 3){
        NSUInteger index0, index1, index2;
        if (imageIndex == 0) {
            index0 = imageIndex;
            index1 = [self validImageIndex:imageIndex+1];
            index2 = [self validImageIndex:imageIndex+2];
            _pictureScrollView.contentOffset = CGPointZero;
        }
        else if(imageIndex == [_picturesArray count]-1){
            index0 = [self validImageIndex:imageIndex-2];
            index1 = [self validImageIndex:imageIndex-1];
            index2 = imageIndex;
            _pictureScrollView.contentOffset = CGPointMake(scrollWidth+scrollWidth, 0.f);
        }
        else{
            index0 = [self validImageIndex:imageIndex-1];
            index1 = imageIndex;
            index2 = [self validImageIndex:imageIndex+1];
            _pictureScrollView.contentOffset = CGPointMake(scrollWidth, 0.f);
        }
        
        UIView* oneView = [self getPictureItemFromIdleItems];
        [_pictureScrollView addSubview:oneView];
        [oneView setTag:index0];
        [self LoadPictureItemImageWithThreadContentImageInfoV2:(PictureItem*)oneView
                                                   imageInfoV2:[_picturesArray objectAtIndex:index0]];
        
        UIView* twoView = [self getPictureItemFromIdleItems];
        twoView.frame = CGRectOffset(twoView.frame, scrollWidth, 0);
        [twoView setTag:index1];
        [_pictureScrollView addSubview:twoView];
        [self LoadPictureItemImageWithThreadContentImageInfoV2:(PictureItem*)twoView
                                                   imageInfoV2:[_picturesArray objectAtIndex:index1]];
        
        
        UIView* threeView = [self getPictureItemFromIdleItems];
        threeView.frame = CGRectOffset(threeView.frame, scrollWidth + scrollWidth, 0);
        [threeView setTag:index2];
        [_pictureScrollView addSubview:threeView];
        [self LoadPictureItemImageWithThreadContentImageInfoV2:(PictureItem*)threeView
                                                   imageInfoV2:[_picturesArray objectAtIndex:index2]];
    }
    
    
    if ([AppSettings boolForKey:BOOLKey_AutoRotatePictureEnable]) {
        UIDevice *myDevice = [UIDevice currentDevice];
        UIDeviceOrientation deviceOrientation = [myDevice orientation];
        if (deviceOrientation != UIDeviceOrientationFaceUp &&
            deviceOrientation != UIDeviceOrientationFaceDown) {
            [self setOrientation:(UIInterfaceOrientation)deviceOrientation];
        }
        else {
            [self setOrientation:UIInterfaceOrientationPortrait];
        }
    }
    else{
        [self setOrientation:UIInterfaceOrientationPortrait];
    }
    
    // 添加一个定时器
    // 发现浏览图集的时候，快速滑到最后，图片需要很久才能加载，分析原因是图片在下载队列最后一个。、
    // 根据这个问题，做一个优化的策略。
    [self timerCheckCurrentItemImage];
    
    // 设置离线按钮状态
    [self setOfflineButtonStatus];
    [self setHDImageButtonStatus]; // 设置高清图片下载按钮状态
    ThreadContentImageInfoV2 *imgInfo = _picturesArray[imageIndex];
    [self setTipsViewData:title desc:imgInfo.imageText];   // 初始化提示框
}

// 预览图集列表中是否存在这个图集
- (BOOL)isExistPhotoCollectionInPreviewDataArray:(PhotoCollection*)pc
{
    for (PreviewPhotoCollectionData *data in _previewDataArray) {
        // 如果满足条件，说明图集已经存在
        if (data.curPhotoCollection.pcId == pc.pcId) {
            return YES;
        }
    }
    return NO;
}

-(void)removePieviewPhotoCollectionData:(PhotoCollection*)pc
{
    if (pc != nil) {
        for (PreviewPhotoCollectionData *data in _previewDataArray) {
            // 如果满足条件，说明图集已经存在
            if (data.curPhotoCollection.pcId == pc.pcId) {
                [_previewDataArray removeObject:data];
                break;
            }
        }
    } 
}

// 添加预览图集数据
-(void)addPieviewPhotoCollectionData:(PhotoCollection*)pc
{
    if (pc == nil || [self isExistPhotoCollectionInPreviewDataArray:pc]) {
        return;
    }
    
    PhotoCollectionManager *pcm = [PhotoCollectionManager sharedInstance];      // 图集管理器
    PhotoCollectionChannel *pcc = [pcm getPhotoCollectionChannelWithId:pc.coid];// 图集频道
    NSArray* pcList = [pcm loadLocalPhotoCollectionListForPCC:pcc];
    if (pcList != nil && pcList.count > 0) {
        NSInteger pcIndex = NSNotFound;
        for (int i=0; i<pcList.count; ++i) {
            PhotoCollection* tmpPc = pcList[i];
            if (tmpPc == pc || tmpPc.pcId == pc.pcId) {
                pcIndex = i;
                break;
            }
        }
        
        // 没有找到，就添加默认图集（不应该出现这样的情况）
        if (pcIndex == NSNotFound) {
            pcIndex = 0;
            pc = pcList[pcIndex];
        }
        
        // 创建预览数据
        PreviewPhotoCollectionData *data = [PreviewPhotoCollectionData new];
        data.curPhotoCollection = pc;
        
        // 添加预览的图集数据
        NSInteger beginIndex = pcIndex+1;
        NSInteger endIndex = beginIndex + kPreviewPhotoCollectionTotal-1;
        if (endIndex >= pcList.count) {
            endIndex = pcList.count - 1;            

            
            // 如果没有达到我们需要的个数，说明我们需要加载更多的图集列表
            [pcm getMorePhotoCollectionList:pcc withCompletionHandler:^(ThreadsFetchingResult *result) {
                if (result.succeeded && !result.noChanges && result.threads > 0) {
                    PreviewPhotoCollectionData* data= [self getPieviewPhotoCollectionData:pc];
                    NSMutableArray *pdArray = [NSMutableArray arrayWithCapacity:3];
                    NSInteger addCount = kPreviewPhotoCollectionTotal - data.PhotoCollectionListCount;
                    for (int i=0 ;i<result.threads.count && i<addCount; ++i) {
                        [pdArray addObject:result.threads[i]];
                    }
                    [data addPhotoCollectionList:pdArray];                
                }                
            }];
        }
        
        
        NSMutableArray *newList = [NSMutableArray arrayWithCapacity:3];
        for (NSInteger i= beginIndex; i<=endIndex; ++i) {
            [newList addObject:pcList[i]];
        }
        
        [data addPhotoCollectionList:newList];
        [_previewDataArray addObject:data];
        [newList removeAllObjects];
        
    }
}
// get预览图集数据
-(PreviewPhotoCollectionData*)getPieviewPhotoCollectionData:(PhotoCollection*)pc
{
    if (pc != nil) {
        for (PreviewPhotoCollectionData *data in _previewDataArray) {
            // 如果满足条件，说明图集已经存在
            if (data.curPhotoCollection.pcId == pc.pcId) {
                return data;
            }
        }
    }
    return nil;
}


// 针对图集使用
- (void)reloadDataWithPhotoDateArray:(PhotoCollection*)pc
{
    _shareUrl = nil;
    if (pc && pc.pcId > 0) {
        _shareUrl = [NSString stringWithFormat:@"%@",@(pc.pcId)];
    }
    
    _model = PictureBoxPhotoCollection;
    [self addPieviewPhotoCollectionData:pc];// 创建一个选择图集控件数据    
    
    PhotoCollectionManager *pcm = [PhotoCollectionManager sharedInstance];
    NSArray *photoList = [pcm getPhotoInfoListWithPhotoCollection:pc];
    
    isHightDefinition = NO;
    _pageCtrl.currentPage = 0;
    _pageCtrl.numberOfPages = photoList.count;
    if (photoList.count == 0) {
        return;
    }
    
    // 初始化一下scrollview 的contentSize
    float scrollWidth = CGRectGetWidth([_pictureScrollView bounds]);
    float scrollHeight = CGRectGetHeight([_pictureScrollView bounds]);
    _pictureScrollView.contentSize = CGSizeMake(scrollWidth * 3, scrollHeight);
    
    
    // 把不用的子控件放到闲置控件数组中，等待再次使用
    NSMutableArray *subviews = [NSMutableArray arrayWithArray:_pictureScrollView.subviews];
    [subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_idleItems addObjectsFromArray:subviews];
    [_idleItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        // 把PictureItem图片初始化成空
        if ([obj isKindOfClass:[PictureItem class]]) {
            [(PictureItem*)obj setTag:NSNotFound];
            [(PictureItem*)obj setItemImage:_defaultImage];
            [(PictureItem*)obj setPhotoColl:nil];
            [(PictureItem*)obj setFrame:_pictureScrollView.bounds];
        }
    }];
    
    
    // 添加子控件
    NSInteger i = 0;
    CGRect itemRect = _pictureScrollView.bounds;
    float itemWidth = CGRectGetWidth(itemRect);
    for (; i<3 && i<photoList.count; ++i) {
        PictureItem *item = [self getPictureItemFromIdleItems];
        item.frame = CGRectOffset(item.bounds, itemWidth*i, 0.f);
        [item setTag:i];
        [item setPhotoColl:pc];
        [_pictureScrollView addSubview:item];
        
        // 加载图片
        [self LoadPictureItemImageWithPhotoData:item photoData:photoList[i]];
    }
    // 图集中的图片列表少于3个，我们需要吧预览控件添加进去，
    if (photoList.count < 3) {        
        // 添加一个预览图片
        PhotoGalleryPreviewItem *item = [self getPhotoGalleryPreviewItemFromIdleItems];
        item.frame = CGRectOffset(item.bounds, itemWidth * (++i), 0.f);
        [item loadPreviewData:[self getPieviewPhotoCollectionData:pc]];
        [_pictureScrollView addSubview:item];
        
        // 添加一个空得PictureItem，用来占位
        if (photoList.count < 2)
        {
            PictureItem *item = [self getPictureItemFromIdleItems];
            item.frame = CGRectOffset(item.bounds, itemWidth * (++i), 0.f);
            [item setTag:NSNotFound];
            [item setPhotoColl:nil];
            [_pictureScrollView addSubview:item];
        }
    }
    _pictureScrollView.contentOffset = CGPointZero;
    
    
    if ([AppSettings boolForKey:BOOLKey_AutoRotatePictureEnable]) {
        UIDevice *myDevice = [UIDevice currentDevice];
        UIDeviceOrientation deviceOrientation = [myDevice orientation];
        if (deviceOrientation != UIDeviceOrientationFaceUp &&
            deviceOrientation != UIDeviceOrientationFaceDown) {
            [self setOrientation:(UIInterfaceOrientation)deviceOrientation];
        }
        else {
            [self setOrientation:UIInterfaceOrientationPortrait];
        }
    }
    else{
        [self setOrientation:UIInterfaceOrientationPortrait];
    }
    
    // 添加一个定时器
    // 发现浏览图集的时候，快速滑到最后，图片需要很久才能加载，分析原因是图片在下载队列最后一个。、
    // 根据这个问题，做一个优化的策略。
    [self timerCheckCurrentItemImage];
    
    // 设置离线按钮状态
    [self setOfflineButtonStatus];
    [self setHDImageButtonStatus];                      // 设置高清图片下载按钮状态
    
    
    // 初始化提示框
    PictureItem *curItem = (PictureItem*)[self getShowSubviewInScrollView];
    if ([curItem isKindOfClass:[PictureItem class]]) {
        PhotoData* pd = [self getPhotoDataWithPictureItem:curItem];
        [self setTipsViewData:pc.title desc:pd.title];
    }
    
  
}

-(void)addItemToIdleItems:(UIView*)item
{
    [item removeFromSuperview];
    if ([item isKindOfClass:[PictureItem class]]) {
        item.tag = NSNotFound;        
        [(PictureItem*)item setPhotoColl:nil];
        [(PictureItem*)item setItemImage:_defaultImage];
    }
    [_idleItems addObject:item];
}
-(PictureItem*)getPictureItemFromIdleItems
{
    PictureItem* item = nil;    
    for (PictureItem *pi in _idleItems) {
        if ([pi isKindOfClass:[PictureItem class]]) {
            item = pi;
            break;
        }
    }
    
    if (item != nil) {
        [_idleItems removeObject:item];
    }
    else{
        item = [[PictureItem alloc] initWithFrame:self.bounds];
    }
    item.frame = self.bounds;
    return item;
}

-(PhotoGalleryPreviewItem*)getPhotoGalleryPreviewItemFromIdleItems
{
    PhotoGalleryPreviewItem *item = nil;
    for (PhotoGalleryPreviewItem *pi in _idleItems) {
        if ([pi isKindOfClass:[PhotoGalleryPreviewItem class]]) {
            item = pi;
            break;
        }
    }
    
    if (item != nil) {
        [_idleItems removeObject:item];
    }
    else{
        item = [[PhotoGalleryPreviewItem alloc] initWithFrame:self.bounds];
        item.delegate = self;
    }
    

//    if (_orientation == UIInterfaceOrientationPortrait ||
//        _orientation == UIInterfaceOrientationPortraitUpsideDown) {
//          item.frame = CGRectMake(0, 0, _width, _height);
//    } 
//    else if(_orientation == UIInterfaceOrientationLandscapeRight ||
//            _orientation == UIInterfaceOrientationLandscapeLeft)
//    {
//         item.frame = CGRectMake(0, 0, _height, _width);
//    }
    
    return item;
}


// 有效的页面值
- (NSInteger)validImageIndex:(NSInteger)value
{
    NSInteger imgCount = [_picturesArray count];
    if(value == -1)
        value = imgCount - 1;
    if(value == imgCount) value = 0;
    return value;
}

// 开始拖拽
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    _scrollViewOffX = scrollView.contentOffset.x;
    [scrollView setUserInteractionEnabled:NO];
}
// scrollView 完成拖拽
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate){
        [scrollView setUserInteractionEnabled:YES];
        
        //round(x)返回x的四舍五入整数值
        // 过滤回弹处理
        if (round(_scrollViewOffX - scrollView.contentOffset.x) != 0) {
            [self scrollViewDidEndScroll:scrollView];
        }
    }
}
// 滚动窗口滑动完成
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [scrollView setUserInteractionEnabled:YES];
    //round(x)返回x的四舍五入整数值
    // 过滤回弹处理
    if (_scrollViewOffX != scrollView.contentOffset.x) {
        [self scrollViewDidEndScroll:scrollView];
    }
}

// 结束滚动
- (void)scrollViewDidEndScroll:(UIScrollView *)scrollView
{
    if (scrollView.subviews.count < 2) {
        return;
    }

    CGFloat width = CGRectGetWidth([scrollView bounds]);
    int page = floor((scrollView.contentOffset.x - width / 2) / width) + 1;  // 0 1 2

    // subviews sort
    NSMutableArray *subviews = [[_pictureScrollView subviews] mutableCopy];
    [subviews sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if([(UIView*)obj1 frame].origin.x < [(UIView*)obj2 frame].origin.x)
            return NSOrderedAscending; 
        return NSOrderedDescending;
    }];
    
    
    UIView *curView = [self getShowSubviewInScrollView];
    if ([curView isKindOfClass:[PictureItem class]]) {
        _pageCtrl.currentPage = curView.tag;
    }
    [self recoverPictureItemScale:scrollView];  // 恢复图片缩放比例
    
    if (page == 0) {
        if (scrollView.subviews.count >=3)
            [self pageMoveToRight:scrollView];
    }
    else if (page == 1) {
    }
    else if (page == 2) {
        [self pageMoveToLeft:scrollView];
    }
    
    [subviews removeAllObjects];
    subviews = nil;
    
    
    
    [self setHDImageButtonStatus]; // 设置高清图片下载按钮状态
    
    // 设置提示信息
    if (_model == PictureBoxNone) {
        ThreadContentImageInfoV2 *imgInfo = [[self picturesArray] objectAtIndex:_pageCtrl.currentPage];
        [_tipsView setDesc:imgInfo.imageText];
    }
    else if (_model == PictureBoxPhotoCollection){
        if ([curView isKindOfClass:[PictureItem class]]) {
            PhotoData *photo = [self getPhotoDataWithPictureItem:(PictureItem*)curView];
            [_tipsView setDesc:photo.title];
        }
        else
        {
            // 预览图集控件，需要隐藏状态控件
            
        }
        
        // 添加一个定时器
        // 发现浏览图集的时候，快速滑到最后，图片需要很久才能加载，分析原因是图片在下载队列最后一个。、
        // 根据这个问题，做一个优化的策略。
        [self timerCheckCurrentItemImage];
    }
    
    // 设置离线按钮状态
    [self setOfflineButtonStatus];
    
}

// 页面向右边移
- (void)pageMoveToRight:(UIScrollView *)scrollView
{
    // 控件排序
    NSMutableArray *subviews = [[_pictureScrollView subviews] mutableCopy];
    [subviews sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if([(UIView*)obj1 frame].origin.x < [(UIView*)obj2 frame].origin.x)
            return NSOrderedAscending;
        return NSOrderedDescending;
    }];
    
    
    UIView *view0 = (UIView*)subviews[0];
    UIView *view1 = (UIView*)subviews[1];
    UIView *view2 = (UIView*)subviews[2];
    CGRect rect0 = [view0 frame];
    CGRect rect1 = [view1 frame];
    CGRect rect2 = [view2 frame];
    
    
    NSInteger index = [view0 tag];
    if (_model == PictureBoxNone) {   
        if (index > 0 && index < [_picturesArray count]) {
            [view2 setFrame:rect0];
            [view1 setFrame:rect2];
            [view0 setFrame:rect1];
            view2.tag = --index;
            
            // 加载图片
            [scrollView setContentOffset:CGPointMake([scrollView bounds].size.width, 0.f)];
            [self LoadPictureItemImageWithThreadContentImageInfoV2:(PictureItem*)view2
                                                       imageInfoV2:[_picturesArray objectAtIndex:index]];
        }        
    }
    else{
        if ([view0 isKindOfClass:[PictureItem class]])
        {
            // 因预览图片无法知道用户需要加载那一个图集数据。
            if ([view1 isKindOfClass:[PhotoGalleryPreviewItem class]])
            {
                // 恢复标题控件显示
                [self hiderControlsWithPhotoCollection:NO];
                
                // view1 需要加载数据
                PhotoCollectionManager *pcm = [PhotoCollectionManager sharedInstance];
                PreviewPhotoCollectionData *data = [(PhotoGalleryPreviewItem*)view1 photoCollectionData];
                PhotoCollection *newPC = [data curPhotoCollection];
                
                
                // 请求图集内容
                NSArray *photoList = [pcm getPhotoInfoListWithPhotoCollection:newPC];
                _pageCtrl.currentPage = view0.tag;
                _pageCtrl.numberOfPages = photoList.count;                
                if (photoList == nil || photoList.count == 0) {
                    [pcm requestPhotoCollectionContent:newPC withCompletionHandler:^(ThreadsFetchingResult *result) {
                        if (result.succeeded && !result.noChanges && result.threads.count > 0)
                        {
                            _pageCtrl.numberOfPages = result.threads.count;
                            if (result.threads.count > 2) {
                                [self addItemToIdleItems:view0];
                                view0.frame = rect1;
                                view1.frame = rect2;
                                
                                PictureItem *newItem = [self getPictureItemFromIdleItems];
                                newItem.frame = rect0;
                                newItem.tag = view0.tag - 1;
                                newItem.photoColl = newPC;
                                [_pictureScrollView addSubview:newItem];
                                [scrollView setContentOffset:CGPointMake([scrollView bounds].size.width, 0.f)];
                                [self timerCheckCurrentItemImage];
                            }
                        }
                    }];
                    return;
                }
            }
            
            
            PhotoCollection *pc = [(PictureItem*)view0 photoColl];
            PhotoCollectionManager *pcm = [PhotoCollectionManager sharedInstance];
            NSArray *photoList = [pcm getPhotoInfoListWithPhotoCollection:pc];
            if (photoList == nil || photoList.count == 0) {
                return;
            }
            
            
            if (index - 1 >= 0) {
                view0.frame = rect1;
                view1.frame = rect2;
                [self addItemToIdleItems:view2];
                
                
                PictureItem *newItem = [self getPictureItemFromIdleItems];
                newItem.frame = rect0;
                newItem.tag = index - 1;
                newItem.photoColl = pc;
                [_pictureScrollView addSubview:newItem];
                [scrollView setContentOffset:CGPointMake([scrollView bounds].size.width, 0.f)];
                [self LoadPictureItemImageWithPhotoData:newItem photoData:[photoList objectAtIndex:newItem.tag]];// 加载图片
            }
            else{
                PreviewPhotoCollectionData *ppcData = [self getPieviewPhotoCollectionData:pc];
                if (ppcData != nil) {
                    NSInteger dataIndex = [_previewDataArray indexOfObject:ppcData];
                    if (dataIndex > 0) {
                        ppcData = [_previewDataArray objectAtIndex:dataIndex-1];                    
                        if (ppcData != nil && ppcData.PhotoCollectionListCount > 0 ) {
                            view0.frame = rect1;
                            view1.frame = rect2;
                            
                            // 到最后一个图片，需要添加图集选择控件
                            [self addItemToIdleItems:view2];
                            PhotoGalleryPreviewItem *newPreviewItem = [self getPhotoGalleryPreviewItemFromIdleItems];
                            newPreviewItem.frame = rect0;
                            [newPreviewItem loadPreviewData:ppcData];// 加载数据
                            [_pictureScrollView addSubview:newPreviewItem];
                            [scrollView setContentOffset:CGPointMake(CGRectGetWidth(scrollView.bounds), 0.f)];
                        }
                    }
                }
            }
        }
        else if([view0 isKindOfClass:[PhotoGalleryPreviewItem class]]){
            // 如何没有隐藏，我们设置为隐藏
            [self hiderControlsWithPhotoCollection:YES];          
            
            // 删除旧的预览图集数据
            if ([view1 isKindOfClass:[PictureItem class]]) {
                PhotoCollection *oldPc = [(PictureItem*)view1 photoColl];
                if (oldPc != nil) {
                    [self removePieviewPhotoCollectionData:oldPc];
                }
            }
            
            
            
            PhotoCollectionManager *pcm = [PhotoCollectionManager sharedInstance];
            PreviewPhotoCollectionData *data = [(PhotoGalleryPreviewItem*)view0 photoCollectionData];
            PhotoCollection *newPC = [data curPhotoCollection];
            NSArray *photoList = [pcm getPhotoInfoListWithPhotoCollection:newPC];            
            
            view0.frame = rect1;
            view1.frame = rect2;
            
            // 添加一个空得PictureItem
            [self addItemToIdleItems:view2];
            PictureItem *emptyItem = [self getPictureItemFromIdleItems];
            emptyItem.frame = rect0;
            emptyItem.tag = photoList.count-1;
            emptyItem.photoColl = newPC;
            [_pictureScrollView addSubview:emptyItem];
            [scrollView setContentOffset:CGPointMake([scrollView bounds].size.width, 0.f)];
            [self LoadPictureItemImageWithPhotoData:emptyItem photoData:[photoList lastObject]];
        }

        
      
        // 初始化提示框
        UIView *curView = [self getShowSubviewInScrollView];
        if ([curView isKindOfClass:[PictureItem class]]) {
            PhotoData* pd = [self getPhotoDataWithPictureItem:(PictureItem*)curView];
            if (pd != nil) {
                [self setTipsViewData:[(PictureItem*)curView photoColl].title desc:pd.title];
            }
        }else{
            [self setTipsViewData:nil desc:nil];
        }
    }
    
}

// 页面向左边移
- (void)pageMoveToLeft:(UIScrollView *)scrollView
{    
    // 控件排序
    NSMutableArray *subviews = [[_pictureScrollView subviews] mutableCopy];
    [subviews sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if([(UIView*)obj1 frame].origin.x < [(UIView*)obj2 frame].origin.x)
            return NSOrderedAscending;
        return NSOrderedDescending;
    }];
    
    
    UIView *view0 = (UIView*)subviews[0];
    UIView *view1 = (UIView*)subviews[1];
    UIView *view2 = (UIView*)subviews[2];
    CGRect rect0 = [view0 frame];
    CGRect rect1 = [view1 frame];
    CGRect rect2 = [view2 frame];
    
    
    NSInteger index = [view2 tag];
    if (_model == PictureBoxNone) {
        if (index > 0 && index < [_picturesArray count]-1) {            
            view0.frame = rect2;
            view1.frame = rect0;
            view2.frame = rect1;
            view0.tag = ++index;
            [scrollView setContentOffset:CGPointMake([scrollView bounds].size.width, 0.f)];
            [self LoadPictureItemImageWithThreadContentImageInfoV2:(PictureItem*)view0
                                                       imageInfoV2:[_picturesArray objectAtIndex:index]];
        }
    }
    else{
        if ([view2 isKindOfClass:[PictureItem class]]) {
            
            if ([view1 isKindOfClass:[PhotoGalleryPreviewItem class]]) {
                
                // 恢复控件显示状态
                [self hiderControlsWithPhotoCollection:NO];
                
                
                // view1 需要加载数据
                PhotoCollectionManager *pcm = [PhotoCollectionManager sharedInstance];
                PreviewPhotoCollectionData *data = [(PhotoGalleryPreviewItem*)view1 photoCollectionData];
                PhotoCollection *newPC = [data selectPhotoCollection];
                [(PictureItem*)view2 setPhotoColl:newPC];
                [(PictureItem*)view2 setItemImage:_defaultImage];
                [(PictureItem*)view2  startHotwheel];
                [self addPieviewPhotoCollectionData:newPC];
                
                
                // 请求图集内容
                NSArray *photoList = [pcm getPhotoInfoListWithPhotoCollection:newPC];
                _pageCtrl.currentPage = view2.tag;
                _pageCtrl.numberOfPages = photoList.count;
                
                if (photoList == nil || photoList.count == 0) {                    
                    [pcm requestPhotoCollectionContent:newPC withCompletionHandler:^(ThreadsFetchingResult *result) {
                        if (result.succeeded && !result.noChanges && result.threads.count > 0)
                        {
                            _pageCtrl.numberOfPages = result.threads.count;                            
                            if (result.threads.count > 2) {
                                [self addItemToIdleItems:view0];
                                view1.frame = rect0;
                                view2.frame = rect1;
                                
                                PictureItem *newItem = [self getPictureItemFromIdleItems];
                                newItem.frame = rect2;
                                newItem.tag = view2.tag + 1;
                                newItem.photoColl = newPC;
                                [_pictureScrollView addSubview:newItem];
                                [scrollView setContentOffset:CGPointMake([scrollView bounds].size.width, 0.f)];
                                [self timerCheckCurrentItemImage];
                                
                                // 设置当前的提示信息
                                PictureItem* curItem = (PictureItem*)[self getShowSubviewInScrollView];
                                PhotoData* pd = [self getPhotoDataWithPictureItem:curItem];
                                [self setTipsViewData:curItem.photoColl.title desc:pd.title];
                            }
                        }
                        else{
                            // 请求图集图片列表失败
                            [SurfNotification surfNotification:@"图集数据请求失败"];
                            [(PictureItem*)view2 stopHotwheel];
                        }
                    }];
                    return;
                }else{
                    if (view2.tag < photoList.count) {
                        PhotoData *data = photoList[view2.tag];
                        [self LoadPictureItemImageWithPhotoData:(PictureItem*)view2 photoData:data];
                    }
                }
            }
            
            
            PhotoCollection *pc = [(PictureItem*)view2 photoColl];
            PhotoCollectionManager *pcm = [PhotoCollectionManager sharedInstance];
            NSArray *photoList = [pcm getPhotoInfoListWithPhotoCollection:pc];
            if (photoList == nil || photoList.count == 0) {
                return;
            }
            
            
            if (index + 1 < photoList.count) {
                view1.frame = rect0;
                view2.frame = rect1;                
                
                [self addItemToIdleItems:view0];
                PictureItem *newItem = [self getPictureItemFromIdleItems];
                newItem.frame = rect2;
                newItem.tag = index + 1;
                newItem.photoColl = pc;
                [_pictureScrollView addSubview:newItem];
                [scrollView setContentOffset:CGPointMake([scrollView bounds].size.width, 0.f)];
                [self LoadPictureItemImageWithPhotoData:newItem photoData:[photoList objectAtIndex:newItem.tag]];// 加载图片
            }
            else{
                PreviewPhotoCollectionData *ppcData = [self getPieviewPhotoCollectionData:pc];
                if (ppcData != nil && ppcData.PhotoCollectionListCount > 0) {
                    view1.frame = rect0;
                    view2.frame = rect1;
                    
                    [self addItemToIdleItems:view0];
                    // 到最后一个图片，需要添加图集选择控件
                    PhotoGalleryPreviewItem *newPreviewItem = [self getPhotoGalleryPreviewItemFromIdleItems];
                    newPreviewItem.frame = rect2;
                    
                    [newPreviewItem loadPreviewData:ppcData];// 加载数据
                    [_pictureScrollView addSubview:newPreviewItem];
                    [scrollView setContentOffset:CGPointMake([scrollView bounds].size.width, 0.f)];
                }
                else {
                    // 图集后面没有更多的图集，不在滑动
                    
                    
                }
            }
        }
        else if([view2 isKindOfClass:[PhotoGalleryPreviewItem class]]){
            // 如何没有隐藏，我们设置为隐藏
            [self hiderControlsWithPhotoCollection:YES];
            
         
            view1.frame = rect0;
            view2.frame = rect1;
            
            // 添加一个空得PictureItem
            [self addItemToIdleItems:view0];
            PictureItem *emptyItem = [self getPictureItemFromIdleItems];
            emptyItem.frame = rect2;
            emptyItem.tag = 0;
            [_pictureScrollView addSubview:emptyItem];
            [scrollView setContentOffset:CGPointMake([scrollView bounds].size.width, 0.f)];
            [self LoadPictureItemImageWithPhotoData:emptyItem photoData:nil];
        }
        
        // 初始化提示框
        UIView *curView = [self getShowSubviewInScrollView];
        if ([curView isKindOfClass:[PictureItem class]]) {
            PhotoData* pd = [self getPhotoDataWithPictureItem:(PictureItem*)curView];
            if (pd != nil) {
                [self setTipsViewData:[(PictureItem*)curView photoColl].title desc:pd.title];
            }
        }else{
            [self setTipsViewData:nil desc:nil];
        }
    }
}

// 恢复图片缩放比例
- (void)recoverPictureItemScale:(UIScrollView *)scrollView{
    for (UIView* view in scrollView.subviews) {
        if ([view isKindOfClass:[PictureItem class]]) {
            [(PictureItem*)view recoverImageScale];
//            [(PictureItem*)view recoverRotateNone];
        }
    }
}

- (void)setTipsViewData:(NSString*)title desc:(NSString*)desc
{
//    [_tipsView setNormalState:NO];
    [_tipsView setTitle:title];
    [_tipsView setDesc:desc];
}

// 子视图加载图片(正对本地图片加载)
- (void)LoadPictureItemImageWithThreadContentImageInfoV2:(PictureItem*)subsView
                                             imageInfoV2:(ThreadContentImageInfoV2*)imgInfo;
{
    [subsView startHotwheel];
    [subsView setItemImage:_defaultImage];      
    if (imgInfo.isLocalImageReady) {
        [self asyncLoadReadyImage:imgInfo completionHandler:^(UIImage *image) {
            
            
            
            [subsView setItemImage:image];
            [subsView stopHotwheel];
            if ([self getShowSubviewInScrollView] == subsView)
            {
                [self setOfflineButtonStatus];
            }
        }];
    }
    else{
        // 这里就交个委托方法的回调函数。notifyImageInfoChenged
    }
}

- (void)LoadPictureItemImageWithPhotoData:(PictureItem*)subsView photoData:(PhotoData*)pd
{
    [subsView startHotwheel];               // 启动风火轮
    [subsView setItemImage:_defaultImage];  // 设置默认图片
    
    if (pd != nil) {
        NSString *imgPath = [PathUtil pathOfPhotoDataImage:pd];
        if ([FileUtil fileExists:imgPath]) {
            __weak typeof(subsView)_weakSubView = subsView;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
            {
                UIImage *img = [UIImage imageWithContentsOfFile:imgPath];
                if (img != nil) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [_weakSubView setItemImage:img];
                        [_weakSubView stopHotwheel];
                        if (_weakSubView == [self getShowSubviewInScrollView]) {
                            [self setOfflineButtonStatus];
                        }
                    });
                }
                else {
                    [_weakSubView stopHotwheel];
                    [_weakSubView setItemImage:_defaultImage]; // 图片加载异常，加载一张默认Loading图片
                    [FileUtil deleteFileAtPath:imgPath];
                }
            });
        }
    }

}

// 定时检查Item图集是否加载
- (void)timerCheckCurrentItemImage
{
    if (_model == PictureBoxPhotoCollection && !isDownLoadingImage) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            [self loadItemsImageTimer];
        });
    }
}

// 定时器回调函数
- (void)loadItemsImageTimer
{
    PhotoData *requestData = nil;
    NSUInteger index = NSNotFound;
    PhotoCollectionManager *pcm = [PhotoCollectionManager sharedInstance];
    
    // 检测当前是否需要加载图片
    UIView *curView = [self getShowSubviewInScrollView];
    if (curView != nil && [curView isKindOfClass:[PictureItem class]]) {
        PhotoCollection *pc = [(PictureItem*)curView photoColl];
        NSArray *photoList = [pcm getPhotoInfoListWithPhotoCollection:pc];
        if ([self isRequestServersImage:(PictureItem*)curView]) {
            index = curView.tag;
            requestData = photoList[index];
        }
    }
    

    // 检测右边的Item是否需要加载图片数据
    if (index == NSNotFound || requestData == nil) {
        UIView *rightView = [self getShowNextSubviewInScrollView];
        if (rightView != nil && [rightView isKindOfClass:[PictureItem class]]) {
            PhotoCollection *pc = [(PictureItem*)rightView photoColl];
            NSArray *photoList = [pcm getPhotoInfoListWithPhotoCollection:pc];            
            if ([self isRequestServersImage:(PictureItem*)rightView]) {
                index = rightView.tag;
                requestData = photoList[index];
            }
        }
    }
    
    
    // 自己和左边都不需要请求图片数据，就看左边是否需要加载图片数据
    if (index == NSNotFound || requestData == nil) {
        UIView *leftView = [self getShowPreSubviewInScrollView];
        if (leftView != nil && [leftView isKindOfClass:[PictureItem class]]) {
            PhotoCollection *pc = [(PictureItem*)leftView photoColl];
            NSArray *photoList = [pcm getPhotoInfoListWithPhotoCollection:pc];
            if ([self isRequestServersImage:(PictureItem*)leftView]) {
                index = leftView.tag;
                requestData = photoList[index];
            }
        }
    }
    
    // 都不需要加载数据，就关闭定时器
    if (index == NSNotFound || requestData == nil) {
        return;
    }
    
    isDownLoadingImage = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self asyncLoadImageWithPhotoData:requestData completionHandler:^(UIImage *image)
         {
             isDownLoadingImage = NO;
             [_pictureScrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 PictureItem *view = obj;
                 if ([view isKindOfClass:[PictureItem class]] &&
                     view.tag == index )
                 {
                     *stop = YES;
                     [view stopHotwheel];
                     [view setItemImage:image];
                     
                     // 设置离线按钮状态
                     [self setOfflineButtonStatus];
                     
                     // 继续请求图片
                     [self timerCheckCurrentItemImage];
                 }
             }];
         }];

    });
    
}

// 是否需要请求服务器图片
- (BOOL)isRequestServersImage:(PictureItem*)item
{    
    if ([item itemImage] == nil || [item itemImage] == _defaultImage){
        PhotoCollection *pc = [item photoColl];
        PhotoCollectionManager *pcm = [PhotoCollectionManager sharedInstance];
        NSArray *photoList = [pcm getPhotoInfoListWithPhotoCollection:pc];
        if (item.tag < photoList.count && pc != nil ) {
            PhotoData *pd = photoList[item.tag];
            if (!pd.isLoadingImage) {
                return YES;
            }
        }
    }
    return NO;
}


-(void)asyncLoadReadyImage:(ThreadContentImageInfoV2*)imgInfo completionHandler:(void(^)(UIImage*))handler
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        UIImage *image;
        if (_pictureType == PictureTypeHighDefinition){
            NSString *imgPath = [self buildHDImagePath:imgInfo];
            image = [UIImage imageWithContentsOfFile:imgPath];
        }
        
        // 加载图片模式的图片
        if (image == nil) {
            image = [UIImage imageWithContentsOfFile:imgInfo.expectedLocalPath];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            handler(image == nil ? _defaultImage : image);
        });
    });
}

-(void)asyncLoadImageWithPhotoData:(PhotoData*)pd completionHandler:(void(^)(UIImage*))handler
{
    // 请求图片
    pd.isLoadingImage = YES;
    ImageDownloadingTask *task = [ImageDownloadingTask new];
    task.targetFilePath = [PathUtil pathOfPhotoDataImage:pd];
    task.imageUrl = pd.img_path;
    task.userData = pd;
    task.imgPriority = kPriority_Higher;
    task.completionHandler = ^(BOOL succeeded, ImageDownloadingTask* task){
        if (succeeded && task.finished) {
            UIImage *downloadImage = [UIImage imageWithData:task.resultImageData];
            if (downloadImage) {
                handler(downloadImage);
            }
            else{
                handler(_defaultImage);
                [PhoneNotification autoHideWithText:@"图片下载失败"];
            }
        }
        else{
            handler(_defaultImage);
            [PhoneNotification autoHideWithText:@"图片下载失败"];
        }
        ((PhotoData*)task.userData).isLoadingImage = NO;
    };
    [[ImageDownloader sharedInstance] download:task];
}

// 图片发生改变
- (void)notifyImageInfoChenged:(ThreadContentImageInfoV2*)imgInfo{
    NSInteger imgIndex = [_picturesArray indexOfObject:imgInfo];
    if (imgIndex != NSNotFound) {
        [[_pictureScrollView subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[PictureItem class]]) {
                if ([(PictureItem*)obj tag] == imgIndex){
                    [self asyncLoadReadyImage:imgInfo completionHandler:^(UIImage *image) {
                        [(PictureItem*)obj stopHotwheel];
                        [(PictureItem*)obj setItemImage:image];
                        
                        // 设置离线按钮状态
                        [self setOfflineButtonStatus];
                    }];

                }
            }
        }];
    }
}



// 通知图片加载进度
-(void)notifyImageLoadingProgress:(ThreadContentImageInfoV2*)imgInfo{
    // 图片加载进度，暂时设计文档上没有要求，就空到
    
}


- (void)BackButtonClick:(id)sender{
    if ([_delegate respondsToSelector:@selector(pictureBoxShowFinish)]) {
        [_delegate pictureBoxShowFinish];
    }
}

// 检测离线下载按钮状态
- (void)setOfflineButtonStatus{
    UIView *item = [self getShowSubviewInScrollView];
    if ([item isKindOfClass:[PictureItem class]]) {
        BOOL isHiden = (((PictureItem*)item).itemImage == _defaultImage) ? YES : NO;
        _rotateButton.hidden = _moreBtn.hidden = isHiden;
    }
}

// 底部工具栏更多按钮点击
-(void)moreButtonClick:(id)sender
{
    if (!_moreMenuView)
    {
        CGFloat w = CGRectGetWidth(self.bounds);
        CGFloat h = CGRectGetHeight(self.bounds);
        
        // 显示二级菜单
        UIControl *bgCtrl = [[UIControl alloc] initWithFrame:self.bounds];
        [bgCtrl setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5f]];
        [bgCtrl addTarget:bgCtrl
                   action:@selector(removeFromSuperview)
         forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:bgCtrl];
        
        {
            // 分享
            UIImage *shareImg = [UIImage imageNamed:@"pop_share"];
            CGFloat sW = shareImg.size.width;
            CGFloat sH = shareImg.size.height;
            CGFloat sX = w - sW - 10.f;
            CGFloat sY = h - sH - kToolsBarHeight - sH - 10 - 10;
            UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [shareBtn setFrame:CGRectMake(sX, sY, sW, sH)];
            [shareBtn setBackgroundImage:shareImg
                                forState:UIControlStateNormal];
            [shareBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^{
                [self shareImageToWeibo];
            }];
            [bgCtrl addSubview:shareBtn];
        
        
            // 离线下载
            UIImage *offImg = [UIImage imageNamed:@"pop_download"];
            CGFloat oW = offImg.size.width;
            CGFloat oH = offImg.size.height;
            CGFloat oX = w - oW - 10.f;
            CGFloat oY = h - sH - kToolsBarHeight - 10;
            UIButton *offlineBtn =
            [UIButton buttonWithType:UIButtonTypeCustom];
            offlineBtn.frame = CGRectMake(oX , oY, oW, oH);
            [offlineBtn setBackgroundImage:offImg
                                  forState:UIControlStateNormal];
            [offlineBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^{
                [self savedImageToPhotosAlbum];
            }];
            [bgCtrl addSubview:offlineBtn];
            
            // 搞一个动画
            CGAffineTransform tf = CGAffineTransformMakeTranslation(0.f,20.f);
            offlineBtn.transform = shareBtn.transform = tf;
            [UIView animateWithDuration:0.3f animations:^{
                offlineBtn.transform = CGAffineTransformIdentity;
                shareBtn.transform = CGAffineTransformIdentity;
            }];
        }
        
        _moreMenuView = bgCtrl;
    }
    else{
        [_moreMenuView removeFromSuperview];
    }
  
}

-(void)shareImageToWeibo
{
    NSString *title = _tipsView.title;
    NSString *desc  = _tipsView.describe;
    [_moreMenuView removeFromSuperview];
    
    // 分享
    UIView *item = [self getShowSubviewInScrollView];
    UIImage *image = [(PictureItem*)item itemImage];
    if (image && image != _defaultImage)
    {
        PhoneWeiboController *weiboVC = [self findUserObject:[PhoneWeiboController class]];
        
        PhoneshareWeiboInfo *info;
        if (_model == PictureBoxNone) {
            // 正文图片分享
            info = [[PhoneshareWeiboInfo alloc] initWithWeiboSource:kWeiboData_Content];
        }
        else if (_model == PictureBoxPhotoCollection) {
            // 图集分享
            info = [[PhoneshareWeiboInfo alloc] initWithWeiboSource:kWeiboData_Gallery];
            info.showWeiboType = kWeixin|kWeiXinFriendZone|kSinaWeibo|kSMS;
        }
        
        [info setWeiboTitle:title desc:desc url:_shareUrl];
        [info setPicture:image];
        
        
        [weiboVC showShareView:kWeiboView_Center shareInfo:info];
    }
    else {
        [PhoneNotification autoHideWithText:@"无法分享，没有图像数据"];
    }
}

// 保存图片到相册中
- (void)savedImageToPhotosAlbum
{
    // 保存图片到相册中
    UIView *item = [self getShowSubviewInScrollView];
    if ([item isKindOfClass:[PictureItem class]])
    {
        UIImage *image = [(PictureItem*)item itemImage];        
        if (image && image != _defaultImage)
        {
            CGRect aR = CGRectMake(0, 0, 20.0f, 20.0f);
            UIActivityIndicatorView *activity =
            [[UIActivityIndicatorView alloc] initWithFrame:aR];
            activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
            activity.center = self.center;
            [activity startAnimating];
            [_moreMenuView addSubview:activity];
            
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(saveImagecompletion:didFinishSavingWithError:contextInfo:), nil);
        }
    }
}

- (void)saveImagecompletion:(UIImage *)image didFinishSavingWithError:(NSError *)error
                contextInfo:(void *)contextInfo
{
    // Was there an error?
    [_moreMenuView removeFromSuperview];
    
    if (error != NULL)
        [PhoneNotification autoHideWithText:@"保存失败！"];
    else
        [PhoneNotification autoHideWithText:@"保存成功！"];
}

// 处理图片单击事件，隐藏提示框
- (void)hiderTipsClick:(UITapGestureRecognizer *)gesture{
    
    if ([[self getShowSubviewInScrollView] isKindOfClass:[PhotoGalleryPreviewItem class]]) {
        return;
    }
    
    
    
    if (_tipsView.alpha > 0.99f) {
        [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
            _tipsView.alpha = 0.f;
            _customTabBar.alpha = 0.f;
            _hdImgDownloadBtn.alpha = 0.0f;
            _rotateButton.alpha = 0.0f;
            _hdImgactivity.alpha = 0.0f;
        } completion:^(BOOL finished) {
            _tipsView.hidden = YES;
            _customTabBar.hidden = YES;
            _hdImgDownloadBtn.hidden = YES;
            _hdImgactivity.hidden = YES;
            _rotateButton.hidden = YES;
            _isClickHider = YES;
        }];
    }
    else{
        _tipsView.hidden = NO;
        _customTabBar.hidden = NO;
        _rotateButton.hidden = NO;
        [self setHDImageButtonStatus];
        [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
            _tipsView.alpha = 1.f;
            _customTabBar.alpha = 1.f;
            _hdImgDownloadBtn.alpha = 1.0f;
            _hdImgactivity.alpha = 1.0f;
            _rotateButton.alpha = 1.0f;
            _isClickHider = NO;
        } completion:nil];
    }
}


// 图集模式下隐藏控件
- (void)hiderControlsWithPhotoCollection:(BOOL)isHider
{    
    // 状态控件被点击隐藏
    if (_isClickHider) {
        if (isHider) {
            _customTabBar.hidden = NO; // 显示自定义状态栏
            _customTabBar.alpha = 1.f;
            // 显示返回按钮
            [[_customTabBar subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[UIButton class]] && [(UIView*)obj frame].origin.x == 0.f) {
                    [(UIView*)obj setHidden:NO];
                }
                else{
                    [(UIView*)obj setHidden:YES];
                }
            }];
        }
        else{
            _customTabBar.hidden = YES; // 显示自定义状态栏
            _customTabBar.alpha = 0.f;
            [[_customTabBar subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [(UIView*)obj setHidden:NO];
            }];
        }
    }
    else{
        _tipsView.hidden = isHider;
        _rotateButton.hidden = isHider;
        if (isHider){
            _hdImgDownloadBtn.hidden = YES;
            _hdImgactivity.hidden = YES;
            
            // 显示返回按钮
            [[_customTabBar subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if (![obj isKindOfClass:[UIButton class]] || [(UIView*)obj frame].origin.x > 0.f) {
                    [(UIView*)obj setHidden:YES];
                }
            }];
        }
        else{
            [self setHDImageButtonStatus];
            
            [[_customTabBar subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [(UIView*)obj setHidden:NO];
            }];
        }
    }    
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gesture{
    UIView *item = [self getShowSubviewInScrollView];
    if ([item isKindOfClass:[PictureItem class]]) {
        [(PictureItem*)item handleDoubleTap:gesture];
    }
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isKindOfClass:[UIButton class]] ||
        [touch.view isKindOfClass:[PhotoGalleryPreviewItem class]]){
        return NO;
    }
    return YES;
}

// 选择按钮点击事件
- (void)lockScreenButtonClickEvent:(id)sender{
    //    PictureItem *item = [self getCurrentPictureItem];
    //    if (item)
    //        [item rotateAndScale];
    
    
//    UIInterfaceOrientation ori = UIInterfaceOrientationPortrait;
//    if(_orientation == UIInterfaceOrientationPortrait){
//        ori = UIInterfaceOrientationLandscapeRight;
//    }else if(_orientation == UIInterfaceOrientationLandscapeRight){
//        ori = UIInterfaceOrientationPortraitUpsideDown;
//    }else if(_orientation == UIInterfaceOrientationPortraitUpsideDown){
//        ori = UIInterfaceOrientationLandscapeLeft;
//    }else if(_orientation == UIInterfaceOrientationLandscapeLeft){
//        ori = UIInterfaceOrientationPortrait;
//    }
    
    // 改来改去，都不知道需要什么样的。真是一会一个想法，希望是站在产品的角度去思考问题。
//    UIInterfaceOrientation ori = UIInterfaceOrientationPortrait;
//    if(_orientation == UIInterfaceOrientationPortrait){
//        ori = UIInterfaceOrientationLandscapeRight;
//    }
//    
//    [self setOrientation:ori];
    
    
//    2014.3.11 改版自动旋转开启 开关
    BOOL isEnable = [AppSettings boolForKey:BOOLKey_AutoRotatePictureEnable];
    [AppSettings setBool:!isEnable forKey:BOOLKey_AutoRotatePictureEnable];
    [self UpdateLockScreenButtonBg];// 修改按钮背景图片
}

-(void)setOrientation:(UIInterfaceOrientation)orientation
{
    if (_orientation == orientation) {
        return;
    }
    
    [UIView animateWithDuration:0.3f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        NSMutableArray *subviews = [[_pictureScrollView subviews] mutableCopy];
        [subviews sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            if([(UIView*)obj1 frame].origin.x < [(UIView*)obj2 frame].origin.x)
                return NSOrderedAscending;
            return NSOrderedDescending;
        }];
        

        
        CGFloat scrWidth = CGRectGetWidth([_pictureScrollView bounds]);
        int page = floor((_pictureScrollView.contentOffset.x - scrWidth / 2) / scrWidth) + 1;
        
        
        if (orientation == UIInterfaceOrientationPortrait) {
            _orientation = UIInterfaceOrientationPortrait;
            self.transform = CGAffineTransformIdentity;
            self.bounds = CGRectMake(0, 0, _width, _height);
            
            // 旋转按钮坐标
            CGRect rotateButFrame = _rotateButton.frame;
            rotateButFrame.origin.x = _width - 50.0f;
            rotateButFrame.origin.y = 10;
            _rotateButton.frame = rotateButFrame;
            
            // 原图按钮坐标
            CGRect hdImgRect = _hdImgDownloadBtn.frame;
            hdImgRect.origin.x = _rotateButton.frame.origin.x - 10 - CGRectGetWidth(hdImgRect);
            _hdImgDownloadBtn.frame = hdImgRect;
            _hdImgactivity.frame = hdImgRect;
            
            // 图片滚动窗口
            NSInteger imgCount = subviews.count;
            float scrollWidth = _width + kItemViewGap;
            float scrollHeight = _height;
            
            _pictureScrollView.frame = CGRectMake(0, 0, scrollWidth, scrollHeight);
            CGSize contentSize = CGSizeMake(scrollWidth * (imgCount > 3 ? 3 : imgCount),scrollHeight);
            [_pictureScrollView setContentSize:contentSize];
            [_pictureScrollView setContentOffset:CGPointMake(page*scrollWidth, 0)];
            
            for (int i=0; i<subviews.count; ++i) {
                UIView *view = [subviews objectAtIndex:i];
                view.frame = CGRectMake(scrollWidth * i, 0, _width, _height);
                if ([view isKindOfClass:[PictureItem class]]) {
                    [(PictureItem*)view setItemImage:[(PictureItem*)view itemImage]];
                }
            }

            
            
            // 自定义状态栏
            float customTabBarH = CGRectGetHeight(_customTabBar.frame);
            CGRect customRect = _customTabBar.frame;
            customRect.origin.y = _height - customTabBarH;
            customRect.size.width = _width;
            _customTabBar.frame = customRect;
            {
                // 下载按钮
                CGRect offlineRect = _moreBtn.frame;
                float offlineW = CGRectGetWidth(offlineRect);
                offlineRect.origin.x = _width - offlineW;
                _moreBtn.frame = offlineRect;
                
                // pageControl
                CGRect pageRect = _pageCtrl.frame;
                pageRect.origin.x = (_width-CGRectGetWidth(_pageCtrl.bounds))/2;
                _pageCtrl.frame = pageRect;
            }
            
            
            // 图片内容简介
            CGRect tipsRect = _tipsView.frame;
            tipsRect.origin.x = (_width-CGRectGetWidth(tipsRect))/2;
            _tipsView.frame = tipsRect;
            [_tipsView setBottomY:_height-customTabBarH];
            
        }
        else if (orientation == UIInterfaceOrientationLandscapeRight)
        {
            _orientation = UIInterfaceOrientationLandscapeRight;
            self.transform = CGAffineTransformMakeRotation(M_PI_2);
            self.bounds = CGRectMake(0, 0, _height, _width);
            
            // 旋转按钮坐标
            CGRect rotateButFrame = _rotateButton.frame;
            rotateButFrame.origin.x = _height - 50.0f;
            rotateButFrame.origin.y = 10;
            _rotateButton.frame = rotateButFrame;
            
            // 原图按钮坐标
            CGRect hdImgRect = _hdImgDownloadBtn.frame;
            hdImgRect.origin.x = _rotateButton.frame.origin.x - 10 - CGRectGetWidth(hdImgRect);
            _hdImgDownloadBtn.frame = hdImgRect;
            _hdImgactivity.frame = hdImgRect;
            
            // 图片滚动窗口
            NSInteger imgCount = subviews.count;
            float scrollWidth = _height + kItemViewGap;
            float scrollHeight = _width;
            _pictureScrollView.frame = CGRectMake(0, 0, scrollWidth, scrollHeight);
            CGSize contentSize = CGSizeMake(scrollWidth * (imgCount > 3 ? 3 : imgCount),scrollHeight);
            [_pictureScrollView setContentSize:contentSize];
            [_pictureScrollView setContentOffset:CGPointMake(page*scrollWidth, 0)];
            
            for (int i=0; i<subviews.count; ++i) {
                UIView *view = [subviews objectAtIndex:i];
                view.frame = CGRectMake(scrollWidth * i, 0, _height, _width);
                if ([view isKindOfClass:[PictureItem class]]) {
                    [(PictureItem*)view setItemImage:[(PictureItem*)view itemImage]];
                }
            }
            
            
            // 自定义状态栏
            float customTabBarH = CGRectGetHeight(_customTabBar.frame);
            _customTabBar.frame = CGRectMake(0, _width-customTabBarH, _height, customTabBarH);
            {
                CGRect mRect = _moreBtn.frame;
                float offlineW = CGRectGetWidth(mRect);
                mRect.origin.x = _height-offlineW;
                _moreBtn.frame = mRect;
                
                
                // pageControl
                CGRect pageRect = _pageCtrl.frame;
                pageRect.origin.x = (_height-CGRectGetWidth(_pageCtrl.bounds))/2;
                _pageCtrl.frame = pageRect;
            }
            
            // 图片内容简介
            CGRect tipsRect = _tipsView.frame;
            tipsRect.origin.x = (_height-CGRectGetWidth(tipsRect))/2;
            _tipsView.frame = tipsRect;
            [_tipsView setBottomY:_width-customTabBarH];
        }
        else if(orientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            _orientation = UIInterfaceOrientationPortraitUpsideDown;
            self.transform = CGAffineTransformMakeRotation(M_PI);
            self.bounds = CGRectMake(0, 0, _width, _height);
            
            // 旋转按钮坐标
            CGRect rotateButFrame = _rotateButton.frame;
            rotateButFrame.origin.x = _width - 50.0f;
            _rotateButton.frame = rotateButFrame;
            
            // 原图按钮坐标
            CGRect hdImgRect = _hdImgDownloadBtn.frame;
            hdImgRect.origin.x = _rotateButton.frame.origin.x - 10 - CGRectGetWidth(hdImgRect);
            _hdImgDownloadBtn.frame = hdImgRect;
            _hdImgactivity.frame = hdImgRect;
            
            // 图片滚动窗口
            NSInteger imgCount = subviews.count;
            float scrollWidth = _width + kItemViewGap;
            float scrollHeight = _height;
            _pictureScrollView.frame = CGRectMake(0, 0, scrollWidth, scrollHeight);
            CGSize contentSize = CGSizeMake(scrollWidth * (imgCount > 3 ? 3 : imgCount),scrollHeight);
            [_pictureScrollView setContentSize:contentSize];
            [_pictureScrollView setContentOffset:CGPointMake(page*scrollWidth, 0)];
            
            for (int i=0; i<subviews.count; ++i) {
                UIView *view = [subviews objectAtIndex:i];
                view.frame = CGRectMake(scrollWidth * i, 0, _width, _height);
                if ([view isKindOfClass:[PictureItem class]]) {
                    [(PictureItem*)view setItemImage:[(PictureItem*)view itemImage]];
                }
            }
            
            
            // 自定义状态栏
            float customTabBarH = CGRectGetHeight(_customTabBar.frame);
            CGRect customRect = _customTabBar.frame;
            customRect.origin.y = _height - customTabBarH;
            customRect.size.width = _width;
            _customTabBar.frame = customRect;
            {
                // 下载按钮
                CGRect mRect = _moreBtn.frame;
                float offlineW = CGRectGetWidth(mRect);
                mRect.origin.x = _width - offlineW;
                _moreBtn.frame = mRect;
                
                // pageControl
                CGRect pageRect = _pageCtrl.frame;
                pageRect.origin.x = (_width-CGRectGetWidth(_pageCtrl.bounds))/2;
                _pageCtrl.frame = pageRect;
            }
            
            
            // 图片内容简介
            CGRect tipsRect = _tipsView.frame;
            tipsRect.origin.x = (_width-CGRectGetWidth(tipsRect))/2;
            _tipsView.frame = tipsRect;
            [_tipsView setBottomY:_height-customTabBarH];
            
        }
        else if (orientation == UIInterfaceOrientationLandscapeLeft) {
            _orientation = UIInterfaceOrientationLandscapeLeft;
            self.transform = CGAffineTransformMakeRotation(M_PI + M_PI_2);
            self.bounds = CGRectMake(0, 0, _height, _width);
            
            // 旋转按钮坐标
            CGRect rotateButFrame = _rotateButton.frame;
            rotateButFrame.origin.x = _height - 50.0f-20;// 多加20个像素是因为它和系统状态栏重叠，导致按钮不灵敏
            rotateButFrame.origin.y = 10;
            _rotateButton.frame = rotateButFrame;
            
            // 原图按钮坐标
            CGRect hdImgRect = _hdImgDownloadBtn.frame;
            hdImgRect.origin.x = _rotateButton.frame.origin.x - 10 - CGRectGetWidth(hdImgRect);
            _hdImgDownloadBtn.frame = hdImgRect;
            _hdImgactivity.frame = hdImgRect;
            
            // 图片滚动窗口
            NSInteger imgCount = subviews.count;
            float scrollWidth = _height + kItemViewGap;
            float scrollHeight = _width;
            _pictureScrollView.frame = CGRectMake(0, 0, scrollWidth, scrollHeight);
            CGSize contentSize = CGSizeMake(scrollWidth * (imgCount > 3 ? 3 : imgCount),scrollHeight);
            [_pictureScrollView setContentSize:contentSize];
            [_pictureScrollView setContentOffset:CGPointMake(page*scrollWidth, 0)];
            
            for (int i=0; i<subviews.count; ++i) {
                UIView *view = [subviews objectAtIndex:i];
                view.frame = CGRectMake(scrollWidth * i, 0, _height, _width);
                if ([view isKindOfClass:[PictureItem class]]) {
                    [(PictureItem*)view setItemImage:[(PictureItem*)view itemImage]];
                }
            }
            
            
            // 自定义状态栏
            float customTabBarH = CGRectGetHeight(_customTabBar.frame);
            _customTabBar.frame = CGRectMake(0, _width-customTabBarH, _height, customTabBarH);
            {
                CGRect mRect = _moreBtn.frame;
                float offlineW = CGRectGetWidth(mRect);
                mRect.origin.x = _height-offlineW;
                _moreBtn.frame = mRect;
                
                
                // pageControl
                CGRect pageRect = _pageCtrl.frame;
                pageRect.origin.x = (_height-CGRectGetWidth(_pageCtrl.bounds))/2;
                _pageCtrl.frame = pageRect;
            }
            
            // 图片内容简介
            CGRect tipsRect = _tipsView.frame;
            tipsRect.origin.x = (_height-CGRectGetWidth(tipsRect))/2;
            _tipsView.frame = tipsRect;
            [_tipsView setBottomY:_width-customTabBarH];
            
        }
        
    } completion:^(BOOL finished) {
        UIView *curItem = [self getShowSubviewInScrollView];
        [_pictureScrollView setContentOffset:curItem.frame.origin];
    }];
    
}


#pragma mark 高清图片下载
-(void)setHDImageButtonStatus{
    if (!isHightDefinition)
    {
        //不支持高清
        _hdImgDownloadBtn.hidden = YES;
        _hdImgactivity.hidden = YES;
        return;
    }
    if (!_hdImgactivity.superview) {
        [self addSubview:_hdImgactivity];
    }
    if (_model == PictureBoxNone) {
        UIView *curItem = [self getShowSubviewInScrollView];
        if ([curItem isKindOfClass:[PictureItem class]]) {
            ThreadContentImageInfoV2* info = [_picturesArray objectAtIndex:curItem.tag];
            NSString *path = [self buildHDImagePath:info];
            if (info.isLoadimgHDImage &&![FileUtil fileExists:path]) {
                //下载中
                _hdImgDownloadBtn.hidden = YES;
                _hdImgactivity.hidden = NO;
            }else if (!info.isLoadimgHDImage) {
                //未下载
                _hdImgDownloadBtn.hidden = NO;
                _hdImgactivity.hidden = YES;
            }else{
                //下载完成
                _hdImgDownloadBtn.hidden = YES;
                _hdImgactivity.hidden = YES;
            }
        }
        else{
            _hdImgDownloadBtn.hidden = YES;
            _hdImgactivity.hidden = YES;
        }
    }
    else if (_model == PictureBoxPhotoCollection){
        //        _hdImgDownloadBtn.hidden = YES;
    }
}

// 创建一个高清图片文件路径
-(NSString*)buildHDImagePath:(ThreadContentImageInfoV2*)info{
    if (info.isLocalImageReady) {
        return [NSString stringWithFormat:@"%@_HD",info.expectedLocalPath];
    }
    return nil;
}

// 是否显示高清按钮
-(BOOL)isShowHDButton:(ThreadContentImageInfoV2*)info{
    if (info.isLocalImageReady) {
        NSString *path = [self buildHDImagePath:info];
        if (path != nil && ![FileUtil fileExists:path]) {
            return YES;
        }
    }
    return NO;
}


-(void)downloadHDImageButtonClick:(id)sender{
    UIButton *btn = sender;
    btn.hidden = YES;
    _hdImgactivity.hidden = NO;
    UIView *item = [self getShowSubviewInScrollView];
    if ([item isKindOfClass:[PictureItem class]] && item.tag >= 0 && item.tag < _picturesArray.count) {
        ThreadContentImageInfoV2 *imgInfo = [_picturesArray objectAtIndex:item.tag];
        if (imgInfo.isLocalImageReady) {
            imgInfo.loadingHDImage = YES;
            NSString* imgHLUrl = [NSString stringWithFormat:@"%@&w=600",imgInfo.imageUrl];
            NSString* imgHLPath = [self buildHDImagePath:imgInfo];
            
            // 下载图片
            ImageDownloadingTask *task = [ImageDownloadingTask new];
            [task setImageUrl:imgHLUrl];
            [task setUserData:imgInfo];
            [task setTargetFilePath:imgHLPath]; // 保存图片
            [task setCompletionHandler:^(BOOL succeeded, ImageDownloadingTask *idt) {
                if(succeeded && idt != nil){
                    _hdImgactivity.hidden = YES;
                    ((ThreadContentImageInfoV2*)idt.userData).loadingHDImage = YES;
                    
                    NSMutableArray *subviews = [[_pictureScrollView subviews] mutableCopy];
                    [subviews sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                        if([(UIView*)obj1 frame].origin.x < [(UIView*)obj2 frame].origin.x)
                            return NSOrderedAscending;
                        return NSOrderedDescending;
                    }];

                    for (UIView *view in subviews) {
                        if ([view isKindOfClass:[PictureItem class]]) {
                            ThreadContentImageInfoV2 *tmpInfo = [_picturesArray objectAtIndex:view.tag];
                            if ([idt.userData isEqual:tmpInfo]){
                                [(PictureItem*)view setItemImage:[UIImage imageWithData:[idt resultImageData]]];
                            }
                        }                        
                    }
                }
                else
                {
                    _hdImgactivity.hidden = YES;
                }
            }];
            [[ImageDownloader sharedInstance] download:task];
        }
    }
}

-(UIView*)getShowSubviewInScrollView{
    NSArray *subviews = _pictureScrollView.subviews;
    for (UIView* v in subviews)
        if (round(v.frame.origin.x - _pictureScrollView.contentOffset.x) == 0)
            return v;
    return nil;
}

-(UIView*)getShowPreSubviewInScrollView
{
    UIView *view = nil;
    UIView *v = [self getShowSubviewInScrollView];
    if (v != nil && v.frame.origin.x > 0.f) {
        NSMutableArray *subviews = [NSMutableArray arrayWithArray:_pictureScrollView.subviews];
        [subviews removeObject:v];        
        
        for (UIView *subview in subviews) {
            if (round(subview.frame.origin.x - v.frame.origin.x) == 0) {
                view = subview;
                break;
            }
        }
    
        [subviews removeAllObjects];
        subviews = nil;
    }
    return view;
}

-(UIView*)getShowNextSubviewInScrollView
{
    UIView *view = nil;
    UIView *curView = [self getShowSubviewInScrollView];
    if (curView != nil) {
        NSMutableArray *subviews = [NSMutableArray arrayWithArray:_pictureScrollView.subviews];
        [subviews removeObject:curView];

        for (UIView *v in subviews) {            
            if ((v.frame.origin.x - curView.frame.origin.x) > 0){
                view = v;
                break;
            }            
        }
        
        [subviews removeAllObjects];
        subviews = nil;
    }
    return view;
}

-(PhotoData*)getPhotoDataWithPictureItem:(PictureItem*)item{
    if (item != nil) {
        NSUInteger index = item.tag;
        PhotoCollection *pc = [item photoColl];
        PhotoCollectionManager *pcm = [PhotoCollectionManager sharedInstance];
        NSArray *photoDataList = [pcm getPhotoInfoListWithPhotoCollection:pc];
        if (index < photoDataList.count) {
            return photoDataList[index];
        }
    }
    return nil;
}


#pragma PhotoGalleryPreviewItemDelegate 
// 通知选择图集
-(void)notifySelectPhotoCollection:(PhotoCollection*)pc
{
    UIView *nextView = [self getShowNextSubviewInScrollView];    
    if ([nextView isKindOfClass:[PictureItem class]]) {
        [(PictureItem*)nextView setPhotoColl:pc];
    }
    [_pictureScrollView setContentOffset:nextView.frame.origin animated:YES];
    [self performSelector:@selector(scrollViewDidEndScroll:) withObject:_pictureScrollView afterDelay:0.5];
}


#pragma mark 设备旋转通知
// 添加一个设备方向改变通知
- (void)addOrientationChangeNotification
{
//    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
//    [center addObserver:self selector:@selector(doRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];

    
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification *note) {
        [self doRotate:note];
    }];
}

// 删除一个设备方向改变通知
//- (void)removeOrientationChangeNotification
//{
//    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
//    [center removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
//}


- (void)doRotate:(NSNotification *)notification
{
    if ([AppSettings boolForKey:BOOLKey_AutoRotatePictureEnable]) {
        UIDevice *myDevice = [UIDevice currentDevice];
        UIDeviceOrientation deviceOrientation = [myDevice orientation];
        if (deviceOrientation != UIDeviceOrientationFaceUp &&
            deviceOrientation != UIDeviceOrientationFaceDown) {
            [self setOrientation:(UIInterfaceOrientation)deviceOrientation];
        }
    }
}

// 更新锁屏按钮图片背景
- (void)UpdateLockScreenButtonBg{
    BOOL isEnable = [AppSettings boolForKey:BOOLKey_AutoRotatePictureEnable];
    UIImage *bgImage = [UIImage imageNamed:isEnable ? @"unlocked.png" : @"lock.png"];
    [_rotateButton setBackgroundImage:bgImage forState:UIControlStateNormal];
}

@end




/////////////////////////////////////////////////////////////////////
#pragma mark PictureItem class
/////////////////////////////////////////////////////////////////////
@implementation PictureItem

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        imageView = [[UIImageView alloc]init];
        imageView.userInteractionEnabled = YES;
        [self addSubview:imageView];
        [self setContentSize:self.bounds.size];
        
        // 初始化风火轮
        float midX = CGRectGetMidX(self.bounds);
        float midY = CGRectGetMidY(self.bounds);
        _hotwheel = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _hotwheel.frame = CGRectMake(midX-20, midY-20, 40, 40);
        _hotwheel.hidden = YES;
        [self addSubview:_hotwheel];
    }
    return self;
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    
    if (_hotwheel) {
        float w = CGRectGetWidth(_hotwheel.bounds);
        float h = CGRectGetWidth(_hotwheel.bounds);
        float dx = (CGRectGetWidth(frame) - w)/ 2.f;
        float dy = (CGRectGetHeight(frame) - h)/ 2.f;
        _hotwheel.frame = CGRectOffset(_hotwheel.bounds, dx, dy);
    }
}

- (void)setItemImage:(UIImage*)img{
    [self recoverRotateNone];// 恢复默认状态
    [self setImage:img];
}

- (UIImage*)itemImage{
    return imageView.image;
}

-(void)setImage:(UIImage*)image{
    // 恢复数据
    if (imageView.image == image) {
        return;
    }
    imageView.image = image;
    self.minimumZoomScale = 1.f;
    self.maximumZoomScale = 1.f;
    self.zoomScale = 1.f;
    
    float imgW = image.size.width;
    float imgH = image.size.height;
    float width = CGRectGetWidth([self bounds])-1;
    float height = CGRectGetHeight([self bounds])-1;
    float zoomScale = [self calcImageZoomScale:image];
    


    CGRect imgViewRect = CGRectMake(0.f, 0.f, imgW * kImageViewMaxScale, imgH * kImageViewMaxScale);
    if (!CGRectIsEmpty(imgViewRect)) {
        imgViewRect.origin.x = (width - CGRectGetWidth(imgViewRect) * zoomScale) * 0.5;
        imgViewRect.origin.y = (height - CGRectGetHeight(imgViewRect) * zoomScale) * 0.5;
        [imageView setFrame:imgViewRect];

        
        // 设置ScrollView缩放比例
        [self setMinimumZoomScale:zoomScale];
        [self setMaximumZoomScale:zoomScale < 1.0 ? 1.0 : zoomScale + 0.5f];
        [self setZoomScale:zoomScale];
    }
}





// 恢复图片比例
- (void)recoverImageScale{
    self.zoomScale = self.minimumZoomScale;
    if (!CGRectEqualToRect(_backupRect, CGRectZero)) {
        imageView.frame = _backupRect;
        _backupRect = CGRectZero;
    }
}

// 绘图图片旋转
-(void)recoverRotateNone{
    if (_imageOrientation != UIImageOrientationUp) {
        _imageOrientation = UIImageOrientationUp;
        [self setItemImage:_viewImage];
    }
    _viewImage = nil;        
}

#pragma mark - Zoom methods

- (void)handleDoubleTap:(UIGestureRecognizer *)gesture
{
    if (!_hotwheel.hidden) {
        return;
    }
    
    
    if (self.zoomScale == self.minimumZoomScale) {
        _backupRect = imageView.frame;        
        [self setZoomScale:self.maximumZoomScale animated:YES];
        CGRect tempRect = imageView.frame;
        float width = CGRectGetWidth([self bounds]);
        float height = CGRectGetHeight([self bounds]);
        float contentWidth = self.contentSize.width;
        float contentHeight = self.contentSize.height;

        
        if (contentHeight < height)
            tempRect.origin.y = (height - contentHeight) * 0.5f;
        else
            tempRect.origin.y = 0.f;
        
        if (contentWidth < width)
            tempRect.origin.x = (width - contentWidth) * 0.5f;
        else
            tempRect.origin.x = 0.f;
        
        imageView.frame = tempRect;
    }
    else{
        [self setZoomScale:self.minimumZoomScale animated:YES];
        if (!CGRectEqualToRect(CGRectZero, _backupRect)) {
            imageView.frame = _backupRect;
            _backupRect = CGRectZero;
        }
    }
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect = [self zoomRectForScale:scale];
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

- (CGRect)zoomRectForScale:(float)scale
{
    CGRect zoomRect;
    zoomRect.size.height = self.frame.size.height / scale;
    zoomRect.size.width  = self.frame.size.width  / scale;
    return zoomRect;
}


- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self)
        return imageView;
    else
        return hitView;
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
}

// called before the scroll view begins zooming its content
//- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
//{
//    
//}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
//    [scrollView setZoomScale:scale animated:NO];

    
    // test 把控件居中显示
    CGRect tempRect = view.frame;
    float width = CGRectGetWidth([self bounds]);
    float height = CGRectGetHeight([self bounds]);
    float contentWidth = self.contentSize.width;
    float contentHeight = self.contentSize.height;
    if (contentHeight < height)
        tempRect.origin.y = (height - contentHeight) * 0.5f;
    else
        tempRect.origin.y = 0.f;
    
    if (contentWidth < width)
        tempRect.origin.x = (width - contentWidth) * 0.5f;
    else
        tempRect.origin.x = 0.f;
    
    [UIView animateWithDuration:0.2 animations:^{
        view.frame = tempRect;
    }];

    
    // test end
}

// 旋转并且放大
- (void)rotateAndScale{
    if (isAction) {
        return;
    }
    isAction = YES;
    // 恢复缩放比例
    [self recoverImageScale];
    if(_imageOrientation == UIImageOrientationRight){
        _imageOrientation = UIImageOrientationDown;
    
    }else if(_imageOrientation == UIImageOrientationDown){
        _imageOrientation = UIImageOrientationLeft;
        
    }else if(_imageOrientation == UIImageOrientationLeft){
        _imageOrientation = UIImageOrientationUp;
        
    }else if(_imageOrientation == UIImageOrientationUp){
        _imageOrientation = UIImageOrientationRight;
        
    }
    if (_viewImage == nil) {
        _viewImage = imageView.image;
        _imageOrientation = UIImageOrientationRight;
    }
    [UIView animateWithDuration:0.3f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        float screenScale = CGRectGetWidth(self.frame)/CGRectGetHeight(self.frame);
        float scale = CGRectGetHeight(imageView.frame)/CGRectGetWidth(imageView.frame);
        /**********************************************
         图片的宽高比例，和展示的宽高比例进行对比。
         因为要旋转180度，所以图片比例＝高/宽；展示比例＝宽/高
         当图片比例大于展示比例时，旋转后，宽度变为屏幕宽度；
         图片比例小于展示比例时，旋转后，高度变为屏幕高度
         by Lee。
        ************************************************/
        if (scale >screenScale)
        {
            scale =  CGRectGetWidth(self.frame)/ CGRectGetHeight(imageView.frame);
        }
        else
        {
            scale =  CGRectGetHeight(self.frame)/ CGRectGetWidth(imageView.frame);
        }
        CGAffineTransform tranform1 = CGAffineTransformMakeRotation(M_PI_2);
        CGAffineTransform tranform2 = CGAffineTransformMakeScale(scale, scale);
        self.transform = CGAffineTransformConcat(tranform1, tranform2);
    
    } completion:^(BOOL finished)
    {
        self.transform = CGAffineTransformIdentity;
        
        UIImage *newImage = [UIImage imageWithCGImage:_viewImage.CGImage
                                                scale:[UIScreen mainScreen].scale
                                          orientation:_imageOrientation];
        [self setImage:newImage];
        isAction = NO;
    }];
}


- (void)startHotwheel
{
    _hotwheel.hidden = NO;
    [_hotwheel startAnimating];
}
- (void)stopHotwheel
{
    [_hotwheel stopAnimating];
    _hotwheel.hidden = YES;
}

#pragma mark 私有函数
// 计算图片的缩放比例
-(float)calcImageZoomScale:(UIImage*)image{
    float zoomScale = 0.f;
    if (!CGSizeEqualToSize(image.size, CGSizeZero)) {
        float imgW = image.size.width;
        float imgH = image.size.height;
        float width = CGRectGetWidth([self bounds])-1;
        float height = CGRectGetHeight([self bounds])-1;
        
        if (imgW <= width && imgH <= height) {
            float imgViewMaxWidth = imgW * kImageViewMaxScale;
            float imgViewMaxHeight = imgH * kImageViewMaxScale;
            float scaleW = width / imgViewMaxWidth;
            float scaleH = height / imgViewMaxHeight;
            zoomScale = scaleW < scaleH ? scaleW : scaleH;
        }
        else{            
            float imgViewW, imgViewH;
            imgViewW = imgW * kImageViewMaxScale;
            imgViewH = imgH * kImageViewMaxScale;
            float minimumScaleW = width / imgViewW;
            float minimumScaleH = height / imgViewH;
            zoomScale = minimumScaleW < minimumScaleH ? minimumScaleW : minimumScaleH;
        }
    }
    return zoomScale;
}


@end
