//
//  LeftAllSubsView.m
//  SurfNewsHD
//
//  Created by apple on 13-3-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "LeftAllSubsView.h"

#import "SubsChannelsListResponse.h"
#import "FileUtil.h"
#import "PathUtil.h"
#import "ImageDownloader.h"
#import "AppDelegate.h"
@implementation LeftAllSubsView
#define KLeftSubCellWidth 200.0f
@synthesize delegate;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithHexString:@"535353"];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                15.0f,
                                                                2.0f,
                                                                frame.size.height -30.0f)];
        view.backgroundColor = [UIColor colorWithPatternImage:
                                [UIImage imageNamed:@"splitLine"]];
        [self addSubview:view];
        
        UIView *titleLineTopView = [[UIView alloc] initWithFrame:CGRectMake(30.0f, 55.0f, kContentWidth - 140.0f, 2)];
        titleLineTopView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"hotchannel_item_border"]];
        [self addSubview:titleLineTopView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(titleLineTopView.frame),
                                                                   15.0f,
                                                                   80.0f,
                                                                   30.0f)];
        label.font = [UIFont boldSystemFontOfSize:18.0f];
        label.text = @"全部订阅";
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor colorWithHexString:@"969696"];
        [self addSubview:label];
        
        UIButton *manage_subs = [UIButton buttonWithType:UIButtonTypeCustom];
        manage_subs.frame = CGRectMake(CGRectGetMaxX(titleLineTopView.frame) - 95.0f,
                               16.0f,
                               95.0f,
                               33.0f);
        [manage_subs setBackgroundImage:[UIImage imageNamed:@"manage_subs"] forState:UIControlStateNormal];
        [manage_subs addTarget:self action:@selector(managerSubs) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:manage_subs];
        
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(view.frame),
                                                                    CGRectGetMinY(titleLineTopView.frame) +15.0f,
                                                                    frame.size.width- 4.0f,
                                                                    kContentHeight - CGRectGetMinY(titleLineTopView.frame) - 30.0f)];
        scrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:scrollView];
        
        [self reloadSubsList];

        SubsChannelsManager *manager = [SubsChannelsManager sharedInstance];
        [manager addChannelObserver:self];
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)reloadSubsList
{
    for (UIView *view in scrollView.subviews)
    {
        if ([view isKindOfClass:[LeftSubsChannelCell class]])
        {
            [view removeFromSuperview];
        }
    }
    SubsChannelsManager *manager = [SubsChannelsManager sharedInstance];
    NSInteger i = 0;
    float width = KLeftSubCellWidth+60;
    [scrollView setContentSize:CGSizeMake(CGRectGetWidth(scrollView.frame),
                                         (([manager.invisibleSubsChannels count]-1)/3 +1 )*50.0f)];

    for(SubsChannel *channel in manager.invisibleSubsChannels)
    {
        LeftSubsChannelCell *cell = [[LeftSubsChannelCell alloc] initWithFrame:CGRectMake(0, 0, width, 50.0f)];
        cell.observer = self;
        cell.channel = channel;
        if ([[manager loadLocalSubsChannels] count] <= 1) {
            cell.deleteBtn.hidden = YES;
        }
        cell.desLabel.text = channel.name;
        NSString *imagePath = [PathUtil pathOfSubsChannelLogo:channel];
        if ([FileUtil fileExists:imagePath]) {
            cell.logoImage.image = [UIImage imageWithContentsOfFile:imagePath];
        }else{
            ImageDownloadingTask *task = [ImageDownloadingTask new];
            task.targetFilePath = imagePath;
            task.imageUrl = channel.ImageUrl;
            [task setCompletionHandler:^(BOOL succeeded, ImageDownloadingTask *idt) {
                if(succeeded && idt != nil){
                    UIImage *img = [UIImage imageWithData:[idt resultImageData]];
                    // 通知图片发生改变
                    cell.logoImage.image = img;
                }
            }];
            ImageDownloader *downloader = [ImageDownloader sharedInstance];
            [downloader download:task];
        }
        [cell isCurrent:NO];
        cell.frame = CGRectMake(i%3*width+25.0f, i/3 * 50.0f, KLeftSubCellWidth+10 , 50.0f);
        [scrollView addSubview:cell];
        i++;
    }
}
-(void)subsChannelChanged
{
    [self reloadSubsList];
}
-(void)singleTapDetected:(SubsChannel *)channel
{
    [self.delegate singleTapDetected:channel];
}
-(void)managerSubs
{
    [self.delegate managerSubs];
}
@end
