//
//  PhotoGalleryPreviewItem.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-10-23.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhotoGalleryPreviewItem.h"
#import "PhotoCollectionCell.h"
#import "PhotoCollectionData.h"
#import "PathUtil.h"
#import "FileUtil.h"
#import "ImageUtil.h"
#import "ImageDownloader.h"

#define kImageWidth 200
#define kImageHeight 100

@interface PhotoCollectionImage : UIImageView {
    UILabel* _titleLabel;
}

@property(nonatomic,weak)PhotoCollection *pc;

@end


@implementation PhotoCollectionImage
-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {        
        float fontSize = 12;
        float titleWidth = CGRectGetWidth(frame);
        UIFont *font = [UIFont systemFontOfSize:fontSize];
        float height = CGRectGetHeight(frame);
        float titleHeight = font.lineHeight;        
        CGRect titleRect = CGRectMake(0, height-titleHeight, titleWidth, titleHeight);
        _titleLabel = [[UILabel alloc] initWithFrame:titleRect];
        _titleLabel.font = font;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.backgroundColor = [UIColor colorWithHexValue:0xCC2B2B2B];
        [self addSubview:_titleLabel];        
    }
    return self;
}


-(void)setPc:(PhotoCollection *)pc{
    _pc = pc;
    _titleLabel.text = pc.title;
}
@end




@implementation PhotoGalleryPreviewItem

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _scrollView = [UIScrollView new];
        [self setScrollViewFrom:_scrollView];
        [self addSubview:_scrollView];
        
        
        // 更多相关图集
        float tX = 20.f;
        float tY = 10.f;
        float tW = CGRectGetWidth(frame)-tX - tX;
        float tH = 30.f;
        CGRect tRect = CGRectMake(tX, tY, tW, tH);
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:tRect];
        [titleLabel setText:@"更多相关图集"];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:22]];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setTextColor:[UIColor grayColor]];
        [titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self addSubview:titleLabel];
        
        UIImage *loadingImg = [UIImage imageNamed:@"loading"];
        _defalutIcon = [ImageUtil imageCenterWithImage:loadingImg
                                            targetSize:CGSizeMake(kImageWidth, kImageHeight)
                                       backgroundColor:[UIColor clearColor]];
        
        // 添加一个手势事件
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                             action:@selector(selectPhotoCollection:)];        
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (_scrollView) {
        [self setScrollViewFrom:_scrollView];
        [_scrollView setContentOffset:CGPointZero animated:NO];
    }
}


-(void)setScrollViewFrom:(UIScrollView*)sv
{
    float scrollTop = 50.f;
    float scrollBottom = kTabBarHeight;
    float scrollWidth = kImageWidth;
    float scrollX = (CGRectGetWidth(self.bounds)-scrollWidth)/2;
    float scrollHeight = CGRectGetHeight(self.bounds)-scrollTop - scrollBottom;
    sv.frame = CGRectMake(scrollX, scrollTop, scrollWidth, scrollHeight);
}


// 加载预览图片
- (void)loadPreviewData:(PreviewPhotoCollectionData*)data
{
    // 把ScrollView设置为第一事件响应
//    [self becomeFirstResponder];
    
    
    _photoCollectionData = data;

    NSMutableArray *subviews = [[_scrollView subviews] mutableCopy];
    [subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    
    if (subviews.count != data.PhotoCollectionListCount) {            
        while (data.PhotoCollectionListCount > subviews.count) {
            CGRect imageRect = CGRectMake(0, 0, kImageWidth, kImageHeight);
            id pci = [[PhotoCollectionImage alloc] initWithFrame:imageRect];
            [subviews addObject:pci];
        }
        
        while (data.PhotoCollectionListCount < subviews.count) {
            [subviews removeLastObject];
        }        
    }
    
    
    float totalH = 0;
    float subviewY = 10.f;
    float space = 20.f;
    for (int i=0; i<data.PhotoCollectionListCount; ++i) {
        
        PhotoCollection *pc = [data getPhotoCollectionAtIndex:i];
        PhotoCollectionImage *pci = subviews[i];
        pci.pc = pc;

        // 加载图片
        [self loadSubviewImage:pci photoCollection:pc];
    
        // 设置控件坐标区域
        float h = CGRectGetHeight(pci.bounds);
        totalH = subviewY + (h+space)*i;
        pci.frame = CGRectMake(0, totalH, kImageWidth, h);
        [_scrollView addSubview:pci];
    }
    [_scrollView setContentSize:CGSizeMake(kImageWidth, totalH + kImageHeight + 10)];
    
    
    // 设置焦点边框
    [self changeHeightlightItem];
    [subviews removeAllObjects];
    
}

-(void)loadSubviewImage:(PhotoCollectionImage*)imageView photoCollection:(PhotoCollection*)pc{    
    
    // 获取本地Icon路径
    NSString *iconPath = [PathUtil pathOfPhotoCollectionIcon:pc];
    if ([FileUtil fileExists:iconPath]) {
        imageView.image = [UIImage imageWithContentsOfFile:iconPath];
    }
    else{
        imageView.image = _defalutIcon;
        ImageDownloadingTask *task = [ImageDownloadingTask new];
        task.imageUrl = pc.imgUrl;
        task.targetFilePath = iconPath;
        task.userData = imageView;
        task.completionHandler = ^(BOOL succeeded,ImageDownloadingTask* t){
            if (succeeded) {
                ((PhotoCollectionImage*)t.userData).image = [UIImage imageWithData:[t resultImageData]];
            }
        };
        [[ImageDownloader sharedInstance] download:task];        
    }
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)selectPhotoCollection:(UITapGestureRecognizer*)gesture
{
    for (PhotoCollectionImage* view in _scrollView.subviews) {
        CGPoint p = [gesture locationInView:view];
        if (CGRectContainsPoint(view.bounds, p)) {
            [self notifySelectPhotoCollection:view.pc];
            return;
        }
    }
   
}

-(void)notifySelectPhotoCollection:(PhotoCollection*)pc
{
    if ([_photoCollectionData isContainsPhotoCollection:pc]) {
        [_photoCollectionData setSelectPhotoCollection:pc];
        
        // 设置焦点边框
        [self changeHeightlightItem];
        
        // 通知PictureBox 滑动
        if ([_delegate respondsToSelector:@selector(notifySelectPhotoCollection:)]) {
            [_delegate notifySelectPhotoCollection:pc];
        }
    }
}

- (void)changeHeightlightItem {    
    // 设置焦点边框
    NSArray *subviews = _scrollView.subviews;
    for (PhotoCollectionImage *pci in subviews) {
        if ([pci isKindOfClass:[PhotoCollectionImage class]]) {
            if (pci.pc.pcId ==  _photoCollectionData.selectPhotoCollection.pcId) {
                pci.layer.borderWidth = 1;
                pci.layer.borderColor = [UIColor whiteColor].CGColor;
            }
            else{
                pci.layer.borderWidth = 0;
                pci.layer.borderColor = [UIColor clearColor].CGColor;
            }
        }      
    }
}
@end





@implementation PreviewPhotoCollectionData
- (id)init
{
    if (self = [super init]) {
        _photoCollectionList = [NSMutableArray arrayWithCapacity:3];
    }
    return self;
}

- (NSUInteger)PhotoCollectionListCount
{
    return _photoCollectionList.count;
}



-(void)addPhotoCollectionList:(NSArray*)pcList
{
    if (pcList != nil && pcList.count > 0) {
        [_photoCollectionList addObjectsFromArray:pcList];
        _selectPhotoCollection = _photoCollectionList[0];
    }
}
-(PhotoCollection*)getPhotoCollectionAtIndex:(NSUInteger)index
{
    if (index < _photoCollectionList.count) {
        return [_photoCollectionList objectAtIndex:index];
    }
    return nil;
}

-(BOOL)isContainsPhotoCollection:(PhotoCollection*)pc
{
    for (PhotoCollection *p in _photoCollectionList) {
        if (pc.pcId == p.pcId) {
            return YES;
        }
    }
    return NO;
}
-(void)clearPhotoCollectionList{
    _selectPhotoCollection = nil;
    [_photoCollectionList removeAllObjects];
}
@end