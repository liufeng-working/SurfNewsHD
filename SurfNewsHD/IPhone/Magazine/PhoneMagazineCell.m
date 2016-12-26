//
//  PhoneMagazineCell.m
//  SurfNewsHD
//
//  Created by SYZ on 13-5-22.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhoneMagazineCell.h"
#import "ImageDownloader.h"
#import "SubsChannelsManager.h"
#import "ImageUtil.h"
#import "NSString+Extensions.h"

#define kUIControlStateCustomState (1 << 16)

@implementation MagazineIconAndNameView

- (id)initWithTarget:(id)target
{
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        
        dividerLineView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 300.0f, 0.5f)];
        [self addSubview:dividerLineView];
        
        logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 7.5f, 30.0f, 30.0f)];
        [self addSubview:logoImageView];
        
        redBg = [[UIImageView alloc] initWithFrame:CGRectMake(33.0f, 4.0f, 10.0f, 10.0f)];//13.0f
        redBg.image = [UIImage imageNamed:@"magazine_new_periodical_count"];
        [self addSubview:redBg];
        
//        periodsCountLabel = [[UILabel alloc] initWithFrame:redBg.frame];
//        periodsCountLabel.backgroundColor = [UIColor clearColor];
//        periodsCountLabel.textColor = [UIColor whiteColor];
//        periodsCountLabel.font = [UIFont boldSystemFontOfSize:6.0f];
//        periodsCountLabel.textAlignment = UITextAlignmentCenter;
//        [self addSubview:periodsCountLabel];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(52.0f, 8.0f, 220.0f, 30.0f)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = [UIFont systemFontOfSize:13.0f];
        [self addSubview:nameLabel];
        
        setTopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        setTopButton.frame = CGRectMake(255.0f, 0.0f, 45.0f, 45.0f);
        [setTopButton setBackgroundImage:[UIImage imageNamed:@"magazine_setTop.png"] forState:UIControlStateNormal];
        
        SEL topBtnClickSel = NSSelectorFromString(@"setTopButtonClick:");
        [setTopButton addTarget:target action:topBtnClickSel
               forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:setTopButton];
        
        SEL selectSel = NSSelectorFromString(@"selected:");
        [self addTarget:target action:selectSel
       forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}

- (void)applyTheme
{
    if ([[ThemeMgr sharedInstance] isNightmode]) {
        nameLabel.textColor = [UIColor whiteColor];
        dividerLineView.backgroundColor = [UIColor colorWithHexValue:0xFF1B1B1C];

    } else {
        nameLabel.textColor = [UIColor colorWithHexString:@"34393D"];
        dividerLineView.backgroundColor = [UIColor colorWithHexValue:0xFFE6E6E6];
    }
}


- (void)loadData:(UpdatePeriodicalInfo *)up
{
    NSString *rootPath = [PathUtil pathOfMagazineId:up.magazineId];
    NSArray *localPeriodicals = [FileUtil getSubdirNamesOfDir:rootPath];
    NSInteger count = up.periodNum - localPeriodicals.count;
    if (count > 0) {
        redBg.hidden = NO;
//        periodsCountLabel.hidden = NO;
        if (count > 99) {
//            periodsCountLabel.text = @"99+";
        } else {
//            periodsCountLabel.text = [NSString stringWithFormat:@"%d", count];
        }
    } else { //没有新一期的期刊时不显示
        redBg.hidden = YES;
//        periodsCountLabel.hidden = YES;
    }
    nameLabel.text = up.magazineName;
    logoImageView.image = [UIImage imageNamed:@"default_loading_image.png"];
    
    NSString *imgPath = [PathUtil pathOfMagazineLogoWithMagazineId:up.magazineId];
    NSFileManager* fm = [NSFileManager defaultManager];
    MagazineSubsInfo *magazine = [[MagazineManager sharedInstance] getMagazineWithMagazineId:up.magazineId];
    if (![fm fileExistsAtPath:imgPath]) { // 图片文件不存在
        ImageDownloadingTask *task = [ImageDownloadingTask new];
        [task setImageUrl:magazine.imageUrl];
        [task setUserData:up];
        [task setTargetFilePath:imgPath];
        [task setCompletionHandler:^(BOOL succeeded, ImageDownloadingTask *idt) {
            if(succeeded && idt != nil && [idt.userData isEqual:up]){
                UIImage *tempImg = [UIImage imageWithData:[idt resultImageData]];
                [logoImageView setImage:tempImg];
            }
        }];
        [[ImageDownloader sharedInstance] download:task];
    } else { //图片存在
        NSData *imgData = [NSData dataWithContentsOfFile:imgPath];
        [logoImageView setImage:[UIImage imageWithData:imgData]];
    }
}

- (void)sendActionsForControlEvents:(UIControlEvents)controlEvents
{
    if (controlEvents == UIControlEventTouchUpInside) {
        if ([[ThemeMgr sharedInstance] isNightmode]) {
            self.backgroundColor = [UIColor colorWithHexValue:kTableCellSelectedColor_N];
        } else {
            self.backgroundColor = [UIColor colorWithHexValue:kTableCellSelectedColor];
        }
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}

//点击时显示点击效果 SYZ -- 2014/08/11
#pragma mark Touch
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if ([touch view] == self && [[event allTouches]count] == 1) {
        CGPoint tp =  [touch locationInView:self];
        CGRect rect = [self bounds];
        if (CGRectContainsPoint(rect, tp)) {
            [self sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self sendActionsForControlEvents:0];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    [self sendActionsForControlEvents:0];
}

@end

//******************************************************************************

static UIImage *loadingImage = nil;

@implementation PhoneMagazineCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        bgView = [[UIView alloc] init];
        bgView.layer.borderWidth = 1.0f;
        bgView.layer.cornerRadius = 2.0f;
        [self.contentView addSubview:bgView];
        
        gradient = [CAGradientLayer layer];
        [bgView.layer addSublayer:gradient];
        
        if (!loadingImage) {
            loadingImage = [ImageUtil imageCenterWithImage:[UIImage imageNamed:@"default_loading_image.png"]
                                                targetSize:CGSizeMake(300.0f, 150.0f)
                                           backgroundColor:[UIColor colorWithHexValue:KImageDefaultBGColor]];
        }
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(1.0f, 0.0f, 300.0f, 150.0f)];
        imageView.hidden = YES;
        imageView.image = loadingImage;
        imageView.backgroundColor = [UIColor clearColor];
        [bgView addSubview:imageView];
        
        imageTitleBgView = [[UIView alloc] initWithFrame:CGRectMake(1.0f, 125.0f, 300.0f, 25.0f)];
        imageTitleBgView.hidden = YES;
        imageTitleBgView.backgroundColor = [UIColor grayColor];
        imageTitleBgView.alpha = 0.7f;
        [bgView addSubview:imageTitleBgView];
        
        imageTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(11.0f, 125.0f, 280.0f, 25.0f)];
        imageTitleLabel.backgroundColor = [UIColor clearColor];
        imageTitleLabel.textColor = [UIColor whiteColor];
        imageTitleLabel.font = [UIFont systemFontOfSize:15.0f];
        imageTitleLabel.hidden = YES;
        [bgView addSubview:imageTitleLabel];
        
        timeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(266.0f, CellSpace - 4.0f, 40.0f, 30.0f)];
        timeImageView.image = [UIImage imageNamed:@"magazine_updateTime_bg"];
        [self.contentView addSubview:timeImageView];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 25.0f)];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textColor = [UIColor whiteColor];
        [timeLabel setTextAlignment:NSTextAlignmentCenter];
        timeLabel.font = [UIFont systemFontOfSize:12.0f];
        timeLabel.shadowOffset = CGSizeMake(0, -1.0f);
        [timeImageView addSubview:timeLabel];
        
        titleLabel1 = [[UILabel alloc] init];
        titleLabel1.tag = 1;
        titleLabel1.font = [UIFont systemFontOfSize:15.0f];
        [bgView addSubview:titleLabel1];
        
        lineView1 = [[UIImageView alloc] init];
        [bgView addSubview:lineView1];
        
        titleLabel2 = [[UILabel alloc] init];
        titleLabel2.tag = 2;
        titleLabel2.font = [UIFont systemFontOfSize:15.0f];
        [bgView addSubview:titleLabel2];
        
        lineView2 = [[UIImageView alloc] init];
        [bgView addSubview:lineView2];
        
        titleLabel3 = [[UILabel alloc] init];
        titleLabel3.tag = 3;
        titleLabel3.font = [UIFont systemFontOfSize:15.0f];
        [bgView addSubview:titleLabel3];
        
        iconAndNameView = [[MagazineIconAndNameView alloc] initWithTarget:self];
        [bgView addSubview:iconAndNameView];
        
        UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(cellPanGes:)];
        panGes.delegate = self;
        panGes.delaysTouchesBegan = YES;
        panGes.cancelsTouchesInView = NO;
        [bgView addGestureRecognizer:panGes];
        
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapGes:)];
        tapGes.delegate = self;
        [bgView addGestureRecognizer:tapGes];
    }
    return self;
}

- (void)loadUpdatePeriodicalInfo:(UpdatePeriodicalInfo *)up
{
    _updatePeriodicalInfo = up;
    
    gradient.hidden = YES;
    
    PeriodicalInfo *info;
    PeriodicalHeadInfo *head;
    if ([up.periods count] > 0) {
        info = up.periods[0];
        head = (PeriodicalHeadInfo *)info.head;
    }
    if (!head) {
        for (UIView *view in self.contentView.subviews) {
            view.hidden = YES;
        }
        return;
    } else {
        for (UIView *view in self.contentView.subviews) {
            view.hidden = NO;
        }
    }
    
    //有新闻图和无新闻图的情况
    BOOL haveImage = (![head.iconViewPath isEmptyOrBlank] && head.iconViewPath) ? YES : NO;
    float cellHeight = haveImage ? CellHeightWithImage : CellHeightNoImage;
    float marginTop = haveImage ? 0.0f : 5.0f;
    imageView.hidden = !haveImage;
    imageTitleBgView.hidden = !haveImage;
    imageTitleLabel.hidden = !haveImage;
    
    NSArray *content = head.contentTitle;
    if (haveImage) {
        titleLabel1.frame = CGRectMake(11.0f, imageView.frame.origin.y + imageView.frame.size.height + 5.0f, 280.0f, 26.0f);
        NSFileManager* fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:[PathUtil pathOfUpdatePeriodical:up]]) {
            [fm createDirectoryAtPath:[PathUtil pathOfUpdatePeriodical:up] withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *imgPath = [PathUtil pathOfUpdatePeriodicalImage:up];
        if ([fm fileExistsAtPath:imgPath]) {
            [self loadLocalImageWithUpdatePeriodicalImage:up];
        } else {
            imageView.image = loadingImage;
            [self downloadLocalImageWithUpdatePeriodicalImage:up imageURL:head.iconViewPath];
        }
    } else {
        titleLabel1.frame = CGRectMake(11.0f, 5.0f + marginTop, 280.0f, 26.0f);
    }
    
    timeImageView.frame = CGRectMake(266.0f, CellSpace - 4.0f, 40.0f, 30.0f);
    lineView1.frame = CGRectMake(11.0f, titleLabel1.frame.origin.y + titleLabel1.frame.size.height, 280.0f, 1.0f);
    titleLabel2.frame = CGRectMake(11.0f, lineView1.frame.origin.y + lineView1.frame.size.height, 280.0f, 26.0f);
    lineView2.frame = CGRectMake(11.0f, titleLabel2.frame.origin.y + titleLabel2.frame.size.height, 280.0f, 1.0f);
    titleLabel3.frame = CGRectMake(11.0f, lineView2.frame.origin.y + lineView2.frame.size.height, 280.0f, 26.0f);
    titleLabel1.backgroundColor = [UIColor clearColor];
    titleLabel2.backgroundColor = [UIColor clearColor];
    titleLabel3.backgroundColor = [UIColor clearColor];
    //坑爹啊,不知道这里会有几条标题啊 SYZ -- 2014/08/11
    if (content.count == 0 || content == nil) {
        bgView.frame = CGRectMake(9.0f, CellSpace, 302.0f, cellHeight - 90.0f - marginTop);
        iconAndNameView.frame = CGRectMake(1.0f, haveImage ? imageView.frame.origin.y + imageView.frame.size.height : 0.0f, 300.0f, 45.0f);
        titleLabel1.hidden = YES;
        lineView1.hidden = YES;
        titleLabel2.hidden = YES;
        lineView2.hidden = YES;
        titleLabel3.hidden = YES;
    } else if (content.count == 1) {
        bgView.frame = CGRectMake(9.0f, CellSpace, 302.0f, cellHeight - 54.0f);
        iconAndNameView.frame = CGRectMake(1.0f, titleLabel1.frame.origin.y + titleLabel1.frame.size.height + 5.0f, 300.0f, 45.0f);
        titleLabel1.hidden = NO;
        lineView1.hidden = YES;
        titleLabel2.hidden = YES;
        lineView2.hidden = YES;
        titleLabel3.hidden = YES;
    } else if (content.count == 2) {
        bgView.frame = CGRectMake(9.0f, CellSpace, 302.0f, cellHeight - 27.0f);
        iconAndNameView.frame = CGRectMake(1.0f, titleLabel2.frame.origin.y + titleLabel2.frame.size.height + 5.0f, 300.0f, 45.0f);
        titleLabel1.hidden = NO;
        lineView1.hidden = NO;
        titleLabel2.hidden = NO;
        lineView2.hidden = YES;
        titleLabel3.hidden = YES;
    } else if (content.count == 3) {
        bgView.frame = CGRectMake(9.0f, CellSpace, 302.0f, cellHeight);
        iconAndNameView.frame = CGRectMake(1.0f, titleLabel3.frame.origin.y + titleLabel3.frame.size.height + 5.0f, 300.0f, 45.0f);
        titleLabel1.hidden = NO;
        lineView1.hidden = NO;
        titleLabel2.hidden = NO;
        lineView2.hidden = NO;
        titleLabel3.hidden = NO;
    }
    [UIView animateWithDuration:0.0f
                     animations:^{
                         [gradient setFrame:CGRectMake(2.0f, bgView.frame.size.height, bgView.frame.size.width - 4.0f, CellShadowHeight)];
                     }
                     completion:^(BOOL finished) {
                         gradient.hidden = NO;
                     }
     ];
    
    timeLabel.text = [self formatterTime:up.lastPeriodLongDate];
    imageTitleLabel.text = head.iconTitle;
    
    if (content) {
        for (NSInteger i = 1; i <= content.count; i++) {
            PeriodicalHeadContentTitle *contentTitle = (PeriodicalHeadContentTitle *)content[i - 1];
            UILabel *label = (UILabel *)[self.contentView viewWithTag:i];
            label.text = contentTitle.title;
        }
    }
    
    [iconAndNameView loadData:up];
}

//获得本地图片
- (void)loadLocalImageWithUpdatePeriodicalImage:(UpdatePeriodicalInfo *)up
{
    dispatch_queue_t imagequeue = dispatch_queue_create("syz.imageLoadingQueue", NULL);
    
    __block UIImage *image = nil;
    // Start the background queue
    dispatch_async(imagequeue, ^{
        NSString *imgPath = [PathUtil pathOfUpdatePeriodicalImage:up];
        NSData *imgData = [NSData dataWithContentsOfFile:imgPath];
        image = [UIImage imageWithData:imgData];
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = image;
        }); //end of main thread queue
    }); //end of imagequeue
    
//    dispatch_release(imagequeue);
}

//从网络上下载图片
- (void)downloadLocalImageWithUpdatePeriodicalImage:(UpdatePeriodicalInfo *)up
                                           imageURL:url
{
    NSString *imgPath = [PathUtil pathOfUpdatePeriodicalImage:up];
    ImageDownloadingTask *task = [ImageDownloadingTask new];
    [task setImageUrl:url];
    [task setUserData:up];
    [task setTargetFilePath:imgPath];
    [task setImageTargetSize:CGSizeMake(0.0f, 0.0f)];
    [task setCompletionHandler:^(BOOL succeeded, ImageDownloadingTask *idt) {
        if(succeeded && idt != nil && [idt.userData isEqual:up]){
            UIImage *image = [UIImage imageWithData:[idt resultImageData]];
            imageView.image = image;
        }
    }];
    [[ImageDownloader sharedInstance] download:task];
}

- (void)applyTheme
{
    [iconAndNameView applyTheme];
    
    if ([[ThemeMgr sharedInstance] isNightmode]) {
        bgView.backgroundColor = [UIColor colorWithHexValue:0xFF2D2E2F];
        bgView.layer.borderColor = [UIColor colorWithHexValue:0xFF202021].CGColor;
        //这个东西是阴影
        NSMutableArray *colors = [NSMutableArray array];
        [colors addObject:(id)[[UIColor colorWithHexValue:0xFF1D1E1F] CGColor]];
        [colors addObject:(id)[[UIColor colorWithHexValue:0xFF28292A] CGColor]];
        gradient.colors = colors;
        
        titleLabel1.textColor = [UIColor whiteColor];
        lineView1.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"magazine_dash_line_night"]];
        titleLabel2.textColor = [UIColor whiteColor];
        lineView2.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"magazine_dash_line_night"]];
        titleLabel3.textColor = [UIColor whiteColor];
    } else {
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.layer.borderColor = [UIColor colorWithHexValue:0xFFF1F1F1].CGColor;
        //这个东西是阴影
        NSMutableArray *colors = [NSMutableArray array];
        [colors addObject:(id)[[UIColor colorWithHexValue:0xFFEEEEEE] CGColor]];
        [colors addObject:(id)[[UIColor colorWithHexValue:0xFFF7F7F7] CGColor]];
        gradient.colors = colors;
        
        titleLabel1.textColor = [UIColor colorWithHexValue:0xFF34393D];
        lineView1.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"magazine_dash_line"]];
        titleLabel2.textColor = [UIColor colorWithHexValue:0xFF34393D];
        lineView2.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"magazine_dash_line"]];
        titleLabel3.textColor = [UIColor colorWithHexValue:0xFF34393D];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

//点击事件,setTopButton的置顶点击事件
- (void)setTopButtonClick:(id)sender
{
    if (_updatePeriodicalInfo != nil) {
        NSInteger index = [[MagazineManager sharedInstance] getMagazineIndexWithMagazineId:_updatePeriodicalInfo.magazineId];
        [_delegate setReloadMode:ReloadSetTop atIndex:index];
        
        MagazineManager *mm = [MagazineManager sharedInstance];
        NSMutableArray *magazinesArray = [mm subsMagazines];
        NSInteger idex = [[MagazineManager sharedInstance] getMagazineIndexWithMagazineId:_updatePeriodicalInfo.magazineId];
        if (idex != NSNotFound && index != 0) {
            id tempObj = [magazinesArray objectAtIndex:idex];//防止这里的弱引用会释放。
            [magazinesArray removeObject:tempObj];
            [magazinesArray insertObject:tempObj atIndex:0];
            [[SubsChannelsManager sharedInstance] commitChangesWithHandler:^(BOOL succeeded) {
                if (!succeeded) {
                    [PhoneNotification autoHideWithText:@"网络异常，置顶失败"];
                }
            }];
        }
    }
}

//点击事件,SetTopOrCancleSubsView的退订点击事件
- (void)cancleSubsClick:(id)sender
{
    if (_updatePeriodicalInfo != nil) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"是否确认退订\"%@\"",_updatePeriodicalInfo.magazineName]
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定",nil];
        [alertView show];
    }
}

//点击事件,MagazineIconAndNameView的点击事件
- (void)selected:(id)sender
{
    MagazineSubsInfo *magazine = [[MagazineManager sharedInstance] getMagazineWithMagazineId:_updatePeriodicalInfo.magazineId];
    NSInteger index = [[MagazineManager sharedInstance] getMagazineIndexWithMagazineId:_updatePeriodicalInfo.magazineId];
    [_delegate setReloadMode:ReloadNormal atIndex:index];
    [_delegate tableViewRowSelected:magazine];
}

//格式化时间
- (NSString *)formatterTime:(long long)time
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time / 1000];
    NSString *updateTimeString = [formatter stringFromDate:date];
    NSString *currentTimeString = [formatter stringFromDate:[NSDate date]];
    
    NSString *formatterTime;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    if ([currentTimeString isEqualToString:updateTimeString]) {
        df.dateFormat = @"HH:mm";
        formatterTime = [df stringFromDate:date];
    } else {
        df.dateFormat = @"MM-dd";
        formatterTime = [df stringFromDate:date];
    }
    
    return formatterTime;
}

#pragma mark UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSInteger index = [[MagazineManager sharedInstance] getMagazineIndexWithMagazineId:_updatePeriodicalInfo.magazineId];
        [_delegate setReloadMode:ReloadDelete atIndex:index];
        [PhoneNotification manuallyHideWithIndicator];
        MagazineSubsInfo *magazine = [[MagazineManager sharedInstance] getMagazineWithMagazineId:_updatePeriodicalInfo.magazineId];
        [[SubsChannelsManager sharedInstance] removeMagazine:magazine];
        [[SubsChannelsManager sharedInstance] commitChangesWithHandler:^(BOOL succeeded) {
            if (!succeeded) {
                [PhoneNotification autoHideWithText:@"退订失败"];
            } else {
                [PhoneNotification autoHideWithText:@"退订成功"];
            }
        }];
    }
}

//滑动手势事件
- (void)cellPanGes:(UIPanGestureRecognizer *)panGes
{
    CGPoint pointer = [panGes locationInView:bgView];
    if (panGes.state == UIGestureRecognizerStateBegan) {
        x = pointer.x;
        
        if ([_delegate respondsToSelector:@selector(resetCellViewFrame)]) {
            [_delegate resetCellViewFrame];
        }
    } else if (panGes.state == UIGestureRecognizerStateChanged) {
        [self initDeleteButton];   //初始化删除按钮
        
        float moveX =  bgView.frame.origin.x + pointer.x - x;
        if (moveX >= 0) {
            moveX = 9.0f;
        }
        if (moveX < -100 + 9.0f) {
            moveX = -100 + 9.0f;
        }
        
        CGRect bgViewFrame = bgView.frame;
        bgViewFrame.origin.x = moveX;
        bgView.frame = bgViewFrame;
        
        CGRect timeImageViewFrame = timeImageView.frame;
        timeImageViewFrame.origin.x = 266.0f + moveX - 9.0f;
        timeImageView.frame = timeImageViewFrame;
    } else if (panGes.state == UIGestureRecognizerStateEnded) {
        float moveX = bgView.frame.origin.x + pointer.x - x;
        if (moveX >= 0) {
            moveX = 9.0f;
            CGRect bgViewFrame = bgView.frame;
            bgViewFrame.origin.x = moveX;
            bgView.frame = bgViewFrame;
            
            CGRect timeImageViewFrame = timeImageView.frame;
            timeImageViewFrame.origin.x = 266.0f + moveX - 9.0f;
            timeImageView.frame = timeImageViewFrame;
        } else if (moveX < -100.0f + 9.0f) {
            moveX = -100.0f + 9.0f;
            CGRect bgViewFrame = bgView.frame;
            bgViewFrame.origin.x = moveX;
            bgView.frame = bgViewFrame;
            
            CGRect timeImageViewFrame = timeImageView.frame;
            timeImageViewFrame.origin.x = 266.0f + moveX - 9.0f;
            timeImageView.frame = timeImageViewFrame;
        } else if (0 > moveX > -100.0f + 9.0f) {
            [self resetViewFrame];
        }
    } else if (panGes.state == UIGestureRecognizerStateCancelled) {
        float moveX = bgView.frame.origin.x + pointer.x - x;
        if (moveX >= 0) {
            moveX = 9.0f;
            CGRect bgViewFrame = bgView.frame;
            bgViewFrame.origin.x = moveX;
            bgView.frame = bgViewFrame;
            
            CGRect timeImageViewFrame = timeImageView.frame;
            timeImageViewFrame.origin.x = 266.0f + moveX - 9.0f;
            timeImageView.frame = timeImageViewFrame;
        } else if (moveX < -100.0f + 9.0f) {
            moveX = -100.0f + 9.0f;
            CGRect bgViewFrame = bgView.frame;
            bgViewFrame.origin.x = moveX;
            bgView.frame = bgViewFrame;
            
            CGRect timeImageViewFrame = timeImageView.frame;
            timeImageViewFrame.origin.x = 266.0f + moveX - 9.0f;
            timeImageView.frame = timeImageViewFrame;
        } else if (0 > moveX > -100.0f + 9.0f) {
            [self resetViewFrame];
        }
    } else if (panGes.state == UIGestureRecognizerStateFailed) {
        [self resetViewFrame];
    }
}

//单次手势点击事件
- (void)cellTapGes:(UITapGestureRecognizer *)tapGes
{
    MagazineSubsInfo *magazine = [[MagazineManager sharedInstance] getMagazineWithMagazineId:_updatePeriodicalInfo.magazineId];
    [_delegate readPeriodicalContent:magazine];
}

//view的动画
- (void)viewAnimate
{
    if ([_delegate respondsToSelector:@selector(resetCellViewFrame)]) {
        [_delegate resetCellViewFrame];
    }
    
    [UIView animateWithDuration:0.3f
                     animations:^{
                         CGRect bgViewFrame = bgView.frame;
                         bgViewFrame.origin.x = bgViewFrame.origin.x - 100.0f;
                         bgView.frame = bgViewFrame;
                         
                         CGRect timeImageViewFrame = timeImageView.frame;
                         timeImageViewFrame.origin.x = timeImageViewFrame.origin.x - 100.0f;
                         timeImageView.frame = timeImageViewFrame;
                     }
                     completion:^(BOOL finished) {
        
                     }
     ];
}

- (void)resetViewFrame
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         CGRect bgViewFrame = bgView.frame;
                         bgViewFrame.origin.x = 9.0f;
                         bgView.frame = bgViewFrame;
                         
                         CGRect timeImageViewFrame = timeImageView.frame;
                         timeImageViewFrame.origin.x = 266.0f;
                         timeImageView.frame = timeImageViewFrame;
                     }
                     completion:^(BOOL finished) {
                         
                     }
     ];
}

//初始化删除按钮
- (void)initDeleteButton
{
    if (deleteButton) {
        deleteButton.frame = CGRectMake(237.5f, (bgView.frame.size.height - 25.0f) / 2, 55.0f, 25.0f);
        return;
    }
    
    deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.frame = CGRectMake(237.5f, (bgView.frame.size.height - 25.0f) / 2, 55.0f, 25.0f);
    [deleteButton setBackgroundImage:[UIImage imageNamed:@"magazine_delete"]
                            forState:UIControlStateNormal];
    [deleteButton setBackgroundImage:[UIImage imageNamed:@"magazine_delete_click"]
                            forState:UIControlStateHighlighted];
//    [deleteButton setImageEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor colorWithHexValue:0xFFCE0000]
                       forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor whiteColor]
                       forState:UIControlStateHighlighted];
    [deleteButton setTitleEdgeInsets:UIEdgeInsetsMake(1.0f, 0.0f, 0.0f, -15.0f)];
    [deleteButton.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    deleteButton.layer.borderColor = [UIColor colorWithHexValue:0xFFCE0000].CGColor;
    deleteButton.layer.borderWidth = 1.0f;
    deleteButton.layer.cornerRadius = 1.0f;
    [deleteButton addTarget:self action:@selector(cancleSubsClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView insertSubview:deleteButton atIndex:0];
}

#pragma mark * UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self];
        return fabs(translation.x) > fabs(translation.y);
    } else if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        //当触摸点在iconAndNameView区域时不响应手势事件 SYZ -- 2014/08/11
        CGPoint point = [(UITapGestureRecognizer *)gestureRecognizer locationInView:bgView];
        if (CGRectContainsPoint(iconAndNameView.frame, point)) {
            return NO;
        }
        return YES;
    }
    return YES;
}

@end
