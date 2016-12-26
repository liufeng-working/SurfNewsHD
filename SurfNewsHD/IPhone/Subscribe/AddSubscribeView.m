//
//  AddSubscribeView.m
//  SurfNewsHD
//
//  Created by SYZ on 13-5-30.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "AddSubscribeView.h"
#import "SubsChannelsListResponse.h"
#import "GetMagazineListResponse.h"
#import "GetMagazineSubsResponse.h"
#import "SubsChannelsManager.h"
#import "ImageUtil.h"

#define DEFAULT_CHANNEL_PER_PAGE  20

static UIImage *defaultImage = nil;

@implementation AddSubscribeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier search:(BOOL)search
{
    //表示搜索RSS频道状态 SYZ -- 2014/08/11
    isSearch = search;
    return [self initWithStyle:style reuseIdentifier:reuseIdentifier];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        iconBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8.0f, 7.5f, 40.0f, 40.0f)];
        [self.contentView addSubview:iconBgImageView];
        
        iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 9.5f, 36.0f, 36.0f)];
        [self.contentView addSubview:iconImageView];
        
        addSubsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:addSubsButton];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(58.0f, 10.0f, 130.0f, 30.0f)];
        nameLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        nameLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:nameLabel];
        
        divideView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 55.0f, 320.0f, 1.0f)];
        [self.contentView addSubview:divideView];
        
        if (!isSearch) {
            divideView.hidden = YES;
        }
        
        if (defaultImage == nil) {
            defaultImage = [ImageUtil imageCenterWithImage:[UIImage imageNamed:@"default_loading_image.png"]
                                                targetSize:CGSizeMake(iconImageView.frame.size.width, iconImageView.frame.size.height)
                                           backgroundColor:[UIColor colorWithHexValue:KImageDefaultBGColor]];
        }
        iconImageView.image = defaultImage;
    }
    return self;
}

//加载数据,有两种数据类型,要区分开来 SYZ -- 2014/08/11
- (void)loadSubsInfo:(id)info
{    
    if ([info isKindOfClass:[SubsChannel class]]) {
        SubsChannel *sc = (SubsChannel*)info;
        self.subsChannel = sc;
    } else if ([info isKindOfClass:[MagazineInfo class]]) {
        MagazineInfo *ma = (MagazineInfo*)info;
        self.magazine = ma;
    }
}

//加载栏目,分为搜索状态和一般状态 SYZ -- 2014/08/11
- (void)setSubsChannel:(SubsChannel *)subsChannel
{
    _subsChannel = subsChannel;
    
    iconImageView.image = defaultImage;
    nameLabel.text = _subsChannel.name;
    if (isSearch) {
        addSubsButton.frame = CGRectMake(270.0f, 2.5f, 50.0f, 50.0f);
    } else {
        iconBgImageView.frame = CGRectMake(18.0f, 7.5f, 40.0f, 40.0f);
        iconImageView.frame = CGRectMake(20.0f, 9.5f, 36.0f, 36.0f);
        addSubsButton.frame = CGRectMake(195.0f, 2.5f, 50.0f, 50.0f);
        nameLabel.frame = CGRectMake(68.0f, 10.0f, 130.0f, 30.0f);
    }
    
    if ([[SubsChannelsManager sharedInstance] channelSubsStatus:subsChannel.channelId]) {
        [addSubsButton setBackgroundImage:[UIImage imageNamed:@"already_subs.png"]
                                 forState:UIControlStateNormal];
        [addSubsButton removeTarget:self action:@selector(addChannelSubscribe:) forControlEvents:UIControlEventTouchUpInside];
        addSubsButton.userInteractionEnabled = NO;
    } else {
        [addSubsButton setBackgroundImage:[UIImage imageNamed:@"add_subs.png"]
                                 forState:UIControlStateNormal];
        [addSubsButton addTarget:self action:@selector(addChannelSubscribe:) forControlEvents:UIControlEventTouchUpInside];
        addSubsButton.userInteractionEnabled = YES;
    }
    
    NSString *imgPath = [PathUtil pathOfSubsChannelLogo:_subsChannel];
    NSFileManager* fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:imgPath]) { // 图片文件不存在
        ImageDownloadingTask *task = [ImageDownloadingTask new];
        [task setImageUrl:_subsChannel.ImageUrl];
        [task setUserData:_subsChannel];
        [task setTargetFilePath:imgPath];
        [task setCompletionHandler:^(BOOL succeeded, ImageDownloadingTask *idt) {
            if(succeeded && idt != nil && [idt.userData isEqual:_subsChannel]){
                UIImage *tempImg = [UIImage imageWithData:[idt resultImageData]];
                [iconImageView setImage:tempImg];
            }
        }];
        [[ImageDownloader sharedInstance] download:task];
    } else { //图片存在
        NSData *imgData = [NSData dataWithContentsOfFile:imgPath];
        [iconImageView setImage:[UIImage imageWithData:imgData]];
    }
}

//加载期刊
- (void)setMagazine:(MagazineInfo *)magazine
{
    _magazine = magazine;
    
    iconImageView.image = defaultImage;
    nameLabel.text = _magazine.magazineName;
    addSubsButton.frame = CGRectMake(270.0f, 2.5f, 50.0f, 50.0f);
    
    if ([[SubsChannelsManager sharedInstance] magazineSubsStatus:_magazine.magazineId]) {
        [addSubsButton setBackgroundImage:[UIImage imageNamed:@"already_subs.png"]
                                 forState:UIControlStateNormal];
        [addSubsButton removeTarget:self action:@selector(addMagazineSubscribe:) forControlEvents:UIControlEventTouchUpInside];
        addSubsButton.userInteractionEnabled = NO;
    } else {
        [addSubsButton setBackgroundImage:[UIImage imageNamed:@"add_subs.png"]
                                 forState:UIControlStateNormal];
        [addSubsButton addTarget:self action:@selector(addMagazineSubscribe:) forControlEvents:UIControlEventTouchUpInside];
        addSubsButton.userInteractionEnabled = YES;
    }
    
    NSString *imgPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld.img",magazine.magazineId]];;
    NSFileManager* fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:imgPath]) { // 图片文件不存在
        ImageDownloadingTask *task = [ImageDownloadingTask new];
        [task setImageUrl:magazine.iconUrl];
        [task setUserData:magazine];
        [task setTargetFilePath:imgPath];
        [task setCompletionHandler:^(BOOL succeeded, ImageDownloadingTask *idt) {
            if(succeeded && idt != nil && [idt.userData isEqual:magazine]){
                UIImage *tempImg = [UIImage imageWithData:[idt resultImageData]];
                [iconImageView setImage:tempImg];
            }
        }];
        [[ImageDownloader sharedInstance] download:task];
    } else { //图片存在
        NSData *imgData = [NSData dataWithContentsOfFile:imgPath];
        [iconImageView setImage:[UIImage imageWithData:imgData]];
    }
}

- (void)applyTheme:(BOOL)isNight
{
    if (isNight) {
        [iconBgImageView setImage:[UIImage imageNamed:@"subs_channel_bg_night.png"]];
        divideView.backgroundColor = [UIColor colorWithHexString:@"19191A"];
        nameLabel.textColor = [UIColor whiteColor];
        self.selectedBackgroundView.backgroundColor= [UIColor colorWithHexValue:kTableCellSelectedColor_N];
    } else {
        [iconBgImageView setImage:[UIImage imageNamed:@"subs_channel_bg.png"]];
        divideView.backgroundColor = [UIColor colorWithHexString:@"DCDBDB"];
        nameLabel.textColor = [UIColor colorWithHexString:@"34393D"];
        self.selectedBackgroundView.backgroundColor= [UIColor colorWithHexValue:kTableCellSelectedColor];
    }
}

/**
 SYZ -- 2014/08/11
 添加订阅的时候要注意这里有可能只是标记成一个状态,具体请参考使用到的方法的注释
 */
//添加栏目订阅
- (void)addChannelSubscribe:(id)sender
{
    if ([[SubsChannelsManager sharedInstance] isChannelReadyToUnsubscribed:_subsChannel.channelId]) {
        [[SubsChannelsManager sharedInstance] removeChannelFromToUnsubs:_subsChannel];
    } else if (![[SubsChannelsManager sharedInstance] isChannelSubscribed:_subsChannel.channelId]){
        [[SubsChannelsManager sharedInstance] addSubscription:_subsChannel];
    }
    
    if ([[SubsChannelsManager sharedInstance] channelSubsStatus:_subsChannel.channelId]) {
        [addSubsButton setBackgroundImage:[UIImage imageNamed:@"already_subs.png"]
                                 forState:UIControlStateNormal];
        [addSubsButton removeTarget:self action:@selector(addChannelSubscribe:) forControlEvents:UIControlEventTouchUpInside];
        addSubsButton.userInteractionEnabled = NO;
        
        [_delegate playAudioWhenAddSubs];
    }
}

//添加期刊订阅
- (void)addMagazineSubscribe:(id)sender
{
    MagazineSubsInfo *magazine = [[MagazineSubsInfo alloc] initWithMagazineInfo:_magazine];
    SubsChannelsManager *sm = [SubsChannelsManager sharedInstance];
    if ([sm isMagazineReadyToUnsubscribed:_magazine.magazineId]) {
        [sm removeMagazineFromToMagazineUnsubs:magazine];
    } else if (![[MagazineManager sharedInstance] isMagazineSubscribed:_magazine.magazineId]){
        [sm addMagazinze:magazine];
    }
    
    if ([[SubsChannelsManager sharedInstance] magazineSubsStatus:_magazine.magazineId]) {
        [addSubsButton setBackgroundImage:[UIImage imageNamed:@"already_subs.png"]
                                 forState:UIControlStateNormal];
        [addSubsButton removeTarget:self action:@selector(addMagazineSubscribe:) forControlEvents:UIControlEventTouchUpInside];
        addSubsButton.userInteractionEnabled = NO;
        
        [_delegate playAudioWhenAddSubs];
    }
}

@end

//******************************************************************************

@implementation AddSubscribeView

- (id)initWithFrame:(CGRect)frame search:(BOOL)search
{
    isSearch = search;
    return [self initWithFrame:frame];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 1.0f, self.frame.size.width, self.frame.size.height - 1.0f) style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        [tableView setDataSource:self];
        [tableView setDelegate:self];
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:tableView];
        
        footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, 65.0f)];
        footerView.backgroundColor = [UIColor clearColor];
        
        showAllResultButton = [UIButton buttonWithType:UIButtonTypeCustom];
        showAllResultButton.frame = CGRectMake((self.frame.size.width - 255.0f) / 2, 15.0f, 255.0f, 35.0f);
        [showAllResultButton.titleLabel setFont:[UIFont systemFontOfSize:16.0f]];
        [showAllResultButton setTitle:@"查看全部搜索结果" forState:UIControlStateNormal];
        [showAllResultButton addTarget:self action:@selector(showAllResult:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:showAllResultButton];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"addSubs" ofType:@"aiff"];
        //在这里判断以下是否能找到这个音乐文件
        if (path) {
            //从path路径中 加载播放器
            player = [[AVAudioPlayer alloc]initWithContentsOfURL:[[NSURL alloc]initFileURLWithPath:path]
                                                           error:nil];
            player.numberOfLoops = 0;
            player.volume = 1.0f;
        }
    }
    return self;
}

//加载该分类下的栏目
- (void)loadSubsCate:(NSArray *)array
{
    _dataArray = [array copy];
    [tableView reloadData];
}

//加载搜索到的订阅栏目
- (void)loadSubsChannels:(NSArray *)array
{
    if (_dataArray.count == [array count]) {
        return;
    }
    
    _dataArray = nil;
    _dataArray = [array copy];
    [tableView reloadData];
}

//加载期刊
- (void)loadMagazine:(NSArray *)array
{
    _dataArray = [array copy];
    [tableView reloadData];
}

- (void)applyTheme:(BOOL)isNight
{
    isNightMode = isNight;
    
    if (isNightMode) {
        showAllResultButton.backgroundColor = [UIColor colorWithHexValue:0xFF3C3D3E];
        [showAllResultButton setTitleColor:[UIColor colorWithHexValue:0xFFFFFFFF] forState:UIControlStateNormal];
    } else {
        showAllResultButton.backgroundColor = [UIColor colorWithHexValue:0xFFFFFFFF];
        [showAllResultButton setTitleColor:[UIColor colorWithHexValue:0xFF999292] forState:UIControlStateNormal];
    }
    
    NSArray *cells = [tableView visibleCells];
    for (UITableViewCell *tCell in cells) {
        AddSubscribeCell *cell = (AddSubscribeCell*)tCell;
        [cell applyTheme:isNight];
    }
}

- (void)showTableFooterView:(BOOL)show
{
    if (tableView.tableFooterView == nil) {
        tableView.tableFooterView = footerView;
    }
    tableView.tableFooterView.hidden = !show;
}

- (void)showAllResult:(id)sender
{
    _showAllResult = YES;
    [_delegate searchSubsChannelByName];
}

#pragma mark UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tView numberOfRowsInSection:(NSInteger)section
{
    return [_dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"addsubs_cell";
    AddSubscribeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[AddSubscribeCell alloc] initWithStyle:UITableViewCellStyleValue1
                                       reuseIdentifier:CellIdentifier
                                                search:isSearch];
        cell.delegate = self;
        cell.backgroundColor = [UIColor clearColor];
        UIView *bgView = [[UIView alloc] initWithFrame:[cell bounds]];
        bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        cell.selectedBackgroundView = bgView;
    }

    [cell loadSubsInfo:[_dataArray objectAtIndex:indexPath.row]];
    [cell applyTheme:isNightMode];
    
    return cell;
}

#pragma mark UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0f;
}

- (void)tableView:(UITableView *)tView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([_delegate respondsToSelector:@selector(channelSelected:)]) {
        [_delegate channelSelected:[_dataArray objectAtIndex:indexPath.row]];
    }
    
    if ([_delegate respondsToSelector:@selector(magazineSelected:)]) {
        [_delegate magazineSelected:[_dataArray objectAtIndex:indexPath.row]];
    }
}

#pragma mark UIScrollViewDelegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([_delegate respondsToSelector:@selector(viewScrolled)]) {
        [_delegate viewScrolled];
    }
    if ([_delegate respondsToSelector:@selector(loadMore)]) {
        //快要滚动到底部，自动加载更多数据
        float scrollContentHeight = scrollView.contentSize.height;
        float scrollHeight = scrollView.bounds.size.height;
        if (isSearch) {
            if (scrollView.contentOffset.y >= scrollContentHeight - scrollHeight - 40.0f &&
                _dataArray.count % DEFAULT_CHANNEL_PER_PAGE == 0 && _showAllResult) {
                [_delegate loadMore];
            }
        } else {
            if (scrollView.contentOffset.y >= scrollContentHeight - scrollHeight - 40.0f &&
                _dataArray.count % DEFAULT_CHANNEL_PER_PAGE == 0) {
                [_delegate loadMore];
            }
        }
    }
}

#pragma mark AddSubscribeCellDelegate methods
- (void)playAudioWhenAddSubs
{
    if (!player) return;
    
    if ([player isPlaying]) {
        [player stop];
    }
    player.currentTime = 0;
    [player play];
}

- (void)drawRect:(CGRect)rect
{
    if (isSearch) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (isNightMode) {
            CGContextSetStrokeColorWithColor(context, [UIColor colorWithHexString:@"19191A"].CGColor);
        } else {
            CGContextSetStrokeColorWithColor(context, [UIColor colorWithHexString:@"DCDBDB"].CGColor);
        }
        CGContextSetLineWidth(context, 1.0f);
        CGContextMoveToPoint(context, 0.0f, 1.0f);
        CGContextAddLineToPoint(context, kContentWidth, 1.0f);
        CGContextStrokePath(context);
    }
}

@end
