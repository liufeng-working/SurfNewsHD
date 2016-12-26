//
//  SearchResultView.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-3-15.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SearchResultView.h"
#import "PathUtil.h"
#import "ImageDownloader.h"
#import "SubscribeCenterCellSubitem.h"

#define SubsViewTBGap 20.f // 订阅窗口的上下间隔

@implementation SearchResultView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [self addSubview:_scrollView];        
        _searchArray = [NSMutableArray arrayWithCapacity:10];        
    }
    return self;
}

- (void)showSearchResutlWithSearchText:(NSString *)text subscribeArray:(NSArray *)array
{
    [_searchArray removeAllObjects];
    
    @try {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[c] %@", text];
        NSArray *resultArray = [array filteredArrayUsingPredicate:predicate];
        
        // 去重操作
        for (SubsChannel *subs1 in resultArray){
            bool isEquel = NO;
            for (SubsChannel *subs2 in _searchArray) {
                if (subs1.channelId == subs2.channelId) {
                    isEquel = YES;
                }
            }
            if (!isEquel) {
                [_searchArray addObject:subs1];
            }
        }
        
        
        [self reloadDataWithSubsChannels:_searchArray];
    } @catch (NSException *exc) {
        [_searchArray removeAllObjects];
    }
}


- (void)reloadDataWithSubsChannels:(NSArray*)subsChannels{
//    _scrollView subviews
    
    [self hiderSubsChannelView:YES];
    
    NSInteger subsCount = [subsChannels count];
    if (subsCount > 0) {
        [self buildSubsChannelViews:subsCount]; // 创建合适的SubsChannelView
        
        
        float width = CGRectGetWidth([self bounds]);
        CGSize subsSize = [SubscribeCenterCellSubitem suitableSize];
        int column = width / subsSize.width;
        NSArray *subsViews = [self subsChannelViews];
        if (column <= 0 || subsCount != [subsViews count]) {  // 说明控件一个子控件都放不下
            return;
        }
        
        CGRect itemRect = {{0.f,0.f},subsSize};
        float lrgap = (CGRectGetWidth([self bounds]) - subsSize.width * column) / (column+1);        
        for (int i = 0; i < subsCount; ++i) {
            SubsChannel* sc = subsChannels[i];
            int curRow = i / column;
            int curColumn = i % column;
            
            itemRect.origin.y = curRow*(subsSize.height + SubsViewTBGap) + SubsViewTBGap;
            itemRect.origin.x = curColumn * (subsSize.width + lrgap) + lrgap;
            
            SubscribeCenterCellSubitem *subitem = [subsViews objectAtIndex:i];
            [subitem setFrame:itemRect];
            [subitem reloadData:sc];            
            
        }
        [_scrollView setContentSize:CGSizeMake([self bounds].size.width, itemRect.origin.y + subsSize.height + SubsViewTBGap)];
        [self hiderSubsChannelView:NO];
        [self loadImages]; // 加载图片
        
    }
}

// 检查订阅状态
- (void)checkSubsChannelState{
    NSArray *views = [self subsChannelViews];    
    for (SubscribeCenterCellSubitem *subitem in views) {
        [subitem checkSubsButtonState];
    }
}

#pragma mark 工具函数
// 隐藏订阅窗口
- (void)hiderSubsChannelView:(BOOL)isHider{
    for (UIView *subsView in [_scrollView subviews]) {
        if ([subsView isKindOfClass:[SubscribeCenterCellSubitem class]]) {
            [subsView setHidden:isHider];
        }        
    }
}

// 创建订阅窗口(更具SubsChannel count)
- (void)buildSubsChannelViews:(NSInteger)viewCount{
    
    NSInteger buildCount = 0;
    for (UIView *subsView in [_scrollView subviews]) {
        if ([subsView isKindOfClass:[SubscribeCenterCellSubitem class]]){
            if (buildCount >= viewCount) {
                [subsView removeFromSuperview]; // 删除多余的subItem
            }
            else{
                ++buildCount;
            }        
        }
    }
    
    // 创建缺少的Subitem
    CGRect subitemRect = {{.0f,.0f}, [SubscribeCenterCellSubitem suitableSize]};
    while (buildCount < viewCount) {
        ++buildCount;
        SubscribeCenterCellSubitem *subitem = [[SubscribeCenterCellSubitem alloc] initWithFrame:subitemRect];
        [subitem setHidden:YES];
        [subitem setSubsCellSubitemClickDelegate:self];
        [_scrollView addSubview:subitem];
    }    
}

-(NSArray*)subsChannelViews{
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:20];
    for (UIView *subsView in [_scrollView subviews]) {
       if ([subsView isKindOfClass:[SubscribeCenterCellSubitem class]]){
           [mutableArray addObject:subsView];
       }
    }
    return mutableArray;
}

- (void)loadImages{
    NSArray* subsChannels = [self subsChannelViews];
    if ([subsChannels count] == 0) {
        return;
    }
    
    for (SubscribeCenterCellSubitem *subsItem in subsChannels) {
        if ([subsItem isKindOfClass:[SubscribeCenterCellSubitem class]]) {
            SubsChannel * subsChannel = [subsItem subsChannel];
            if (subsChannel != nil) {   // 加载图片数据
                NSFileManager* fm = [NSFileManager defaultManager];
                NSString *imgPath = [PathUtil pathOfSubsChannelLogo:subsChannel];
                if (![fm fileExistsAtPath:imgPath]) { // 图片文件不存在
                    ImageDownloadingTask *task = [ImageDownloadingTask new];
                    [task setImageUrl:subsChannel.imageUrl];
                    [task setUserData:subsItem];
                    [task setTargetFilePath:imgPath];
                    [task setCompletionHandler:^(BOOL succeeded, ImageDownloadingTask *idt)
                     {
                         if(succeeded && idt != nil){
                             UIImage* tempImg = [UIImage imageWithData:[idt resultImageData]];                            
                             [[idt userData] setIcon:tempImg];//更新图片
                         }
                     }];
                    [[ImageDownloader sharedInstance] download:task];
                }
                else{ // 图片存在，加载本地缓存图片
                     UIImage *tempImage = [UIImage imageWithContentsOfFile:imgPath];
                    [subsItem setIcon:tempImage];
                }
            }
        }        
    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
#pragma mark 
// 打开SubsChannelView
-(void)cellSubitemClick:(SubsChannel *)subsChannel{
    [[self delegate] openSubsChannelView:subsChannel];
}
@end
