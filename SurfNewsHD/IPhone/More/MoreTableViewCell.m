//
//  MoreTableViewCell.m
//  SurfNewsHD
//
//  Created by Jerry Yu on 13-5-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "MoreTableViewCell.h"
#import "AppDelegate.h"
#import "ThemeMgr.h"
#import "AppSettings.h"
#import "SocialAccountController.h"
#import "SevenSwitch.h"
#import "NotificationManager.h"

#define MODEL_FRAME     CGRectMake(110, 12, 180, 25.0f)

@implementation MoreTableViewCell


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    CGFloat w = CGRectGetWidth(self.bounds);
    CGFloat h = CGRectGetHeight(self.bounds);
    
    if (self.isIcon) {
        CGFloat lX = 70.f;
        CGFloat lH = self.textLabel.font.lineHeight;
        CGFloat lY = (h - lH)/2;
        CGFloat lW = w-lX - 20.f;
        [self.textLabel setFrame:CGRectMake(lX, lY, lW, lH)];
        
        CGFloat imgH = 40.f, imgW = 40.f;
        CGFloat imgY = (h - imgH)/2;
        [self.imageView setFrame:CGRectMake(15, imgY, imgW, imgH)];
    }
    else
    {
        [self.textLabel setFrame:CGRectMake(20.0f, 0.0f, 300.0f, 50.0f)];
        [self.imageView setFrame:CGRectZero];
    }
    
    if (rightMarkIamgeView) {
        CGFloat markW= CGRectGetWidth(rightMarkIamgeView.bounds);
        CGPoint centerP = self.contentView.center;
        centerP.x = w - markW/2 -10.f - 30;//5.0版本修改了箭头 －30
        rightMarkIamgeView.center = centerP;
    }

    // 正负能量图片
    if (rankingMarkIamgeView) {
        CGFloat rankH = CGRectGetHeight(rankingMarkIamgeView.bounds);
        CGRect rankR = rankingMarkIamgeView.frame;
        rankR.origin.y = (h - rankH )/2;
        [rankingMarkIamgeView setFrame:rankR];
    }
}

- (void)showUpdateSign
{
    UIImageView *signView = [[UIImageView alloc] initWithFrame:CGRectMake(250, 20,6, 6)];
    [signView setImage:[UIImage imageNamed:@"isnew"]];
    [self.contentView addSubview:signView];
}


- (void)showImageModelView
{
    if (IOS7) {
        if (!detailLabel)
        {
            detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(230.0f, 0.0f, 50.0f, 51.0f)];
            [detailLabel setTextAlignment:NSTextAlignmentRight];
            [detailLabel setBackgroundColor:[UIColor clearColor]];
            [detailLabel setTextColor:[UIColor colorWithHexString:@"34393d"]];
            [detailLabel setFont:[UIFont systemFontOfSize:12]];
            [self.contentView addSubview:detailLabel];
        }
        
        ReaderPicMode picMode = [AppSettings integerForKey:IntKey_ReaderPicMode];
        if(picMode == ReaderPicOn)
        {
            [detailLabel setText:@"自动"];
        }
        else if(picMode == ReaderPicOff)
        {
            [detailLabel setText:@"无图"];
        }
        else if(picMode == ReaderPicManually)
        {
            [detailLabel setText:@"手动"];
        }
        
//        [self showRightMarkImage];
        
        self.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    else{
        if (!sliderSwicthView_Image) {
            sliderSwicthView_Image = [[SliderSwitch alloc] init];
            [sliderSwicthView_Image setDelegate:self];
            [sliderSwicthView_Image setModelChange:IMAGE_MODEL];
            [sliderSwicthView_Image setFrameHorizontal:MODEL_FRAME
                                        numberOfFields:3
                                      withCornerRadius:4.0];
            [sliderSwicthView_Image setText:@"自动" forTextIndex:1];
            [sliderSwicthView_Image setText:@"无图" forTextIndex:2];
            [sliderSwicthView_Image setText:@"手动" forTextIndex:3];
            [self.contentView addSubview:sliderSwicthView_Image];
        }
        [sliderSwicthView_Image refresh];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;

    }
}

- (void)showRightMarkImage
{
    if (!rightMarkIamgeView) {
        UIImage *markImg = [UIImage imageNamed:@"rightView"];
        CGRect rect = CGRectMake(0, 0, markImg.size.width, markImg.size.height);
        rightMarkIamgeView =  [[UIImageView alloc] initWithFrame:rect];
        [rightMarkIamgeView setImage:markImg];
        [self.contentView addSubview:rightMarkIamgeView];
    }
}

/**
 *  显示通知标记图片
 */
- (void)showNotifiMarkImage:(BOOL)isShow
{
    if (isShow) {
        if (!notifiMarkIamgeView) {
            notifiMarkIamgeView = [[UIImageView alloc] initWithFrame:CGRectMake(255, 10, 6, 6)];
            [notifiMarkIamgeView setImage:[UIImage imageNamed:@"isnew"]];
        }
        if (![self.contentView.subviews containsObject:notifiMarkIamgeView]) {
            [self.contentView addSubview:notifiMarkIamgeView];

        }
    }
    else{
        if (notifiMarkIamgeView) {
            if ([self.contentView.subviews containsObject:notifiMarkIamgeView]) {
                [notifiMarkIamgeView removeFromSuperview];
                notifiMarkIamgeView = nil;
            }
        }
    }
   
}

- (void)showTextModelView
{
    if (IOS7) {
        [self showRightMarkImage];
        
        if (!detailLabel)
        {
            detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(230.0f, 0.0f, 50.0f, 51.0f)];
            [detailLabel setTextAlignment:NSTextAlignmentRight];
            [detailLabel setBackgroundColor:[UIColor clearColor]];
            [detailLabel setTextColor:[UIColor colorWithHexString:@"34393d"]];
            [detailLabel setFont:[UIFont systemFontOfSize:12]];
            [self.contentView addSubview:detailLabel];
        }
        float model = [AppSettings floatForKey:FLOATKEY_ReaderBodyFontSize];
        if (model == kWebContentSize1)
        {
            [detailLabel setText:@"小"];
        }
        else if (model == kWebContentSize2)
        {
            [detailLabel setText:@"中"];
        }
        else if (model == kWebContentSize3)
        {
            [detailLabel setText:@"大"];
        }
        else if (model == kWebContentSize4)
        {
            [detailLabel setText:@"极大"];
        }
        
        self.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    else{
        if (!sliderSwicthView_Txt) {
            sliderSwicthView_Txt = [[SliderSwitch alloc] init];
            [sliderSwicthView_Txt setDelegate:self];
            [sliderSwicthView_Txt setModelChange:TEXT_MODEL];
            [sliderSwicthView_Txt setFrameHorizontal:MODEL_FRAME numberOfFields:4 withCornerRadius:4.0];
            [sliderSwicthView_Txt setText:@"小" forTextIndex:1];
            [sliderSwicthView_Txt setText:@"中" forTextIndex:2];
            [sliderSwicthView_Txt setText:@"大" forTextIndex:3];
            [sliderSwicthView_Txt setText:@"极大" forTextIndex:4];
            [self.contentView addSubview:sliderSwicthView_Txt];
        }
        [sliderSwicthView_Txt refresh];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;

    }
}

- (void)showNightSwitchView{
    if (!nightSwitch) {
        nightSwitch = [[SevenSwitch alloc] initWithFrame:CGRectZero andSwitch_Model:Night_Switch_Model];
            nightSwitch.center = CGPointMake(self.bounds.size.width * 0.5+110, self.bounds.size.height * 0.5+3);

        [self.contentView addSubview:nightSwitch];
    }
}

- (void)showNightModelView
{
    if (IOS7) {
        [self showNightSwitchView];
    }
    else{
        if (!sliderSwicthView_Night) {
            sliderSwicthView_Night = [[SliderSwitch alloc] init];
            [sliderSwicthView_Night setDelegate:self];
            [sliderSwicthView_Night setModelChange:NIGHT_MODEL];
            [sliderSwicthView_Night setFrameHorizontal:MODEL_FRAME numberOfFields:2 withCornerRadius:4.0];
            [sliderSwicthView_Night setText:@"关" forTextIndex:1];
            [sliderSwicthView_Night setText:@"开" forTextIndex:2];
            
            [self.contentView addSubview:sliderSwicthView_Night];
        }
        [sliderSwicthView_Night refresh];
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)showNotifiSwitchBt
{
    if (!mySwitch) {
        mySwitch = [[SevenSwitch alloc] initWithFrame:CGRectZero andSwitch_Model:Notification_Switch_Model];
        if (IOS7) {
            mySwitch.center = CGPointMake(self.bounds.size.width * 0.5+110, self.bounds.size.height * 0.5+3);
        }
        else{
            mySwitch.center = CGPointMake(self.bounds.size.width * 0.5+100, self.bounds.size.height * 0.5+3);
        }

        [self.contentView addSubview:mySwitch];
    }
}

- (void)showCacheSize:(NSString*)cacheSize
{
    NSString *str;
    if (cacheSize == nil) {
        str = @"缓存计算中...";
    } else {
        str = [NSString stringWithFormat:@"%@ M", cacheSize];
    }
    if (!detailLabel)
    {
        detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(190.0f, 0.0f, 130.0f, 51.0f)];
        [detailLabel setBackgroundColor:[UIColor clearColor]];
        [detailLabel setTextColor:[UIColor colorWithHexString:@"ce0000"]];
        [detailLabel setFont:[UIFont systemFontOfSize:15]];
    }
    [self.contentView addSubview:detailLabel];
    
    CGSize size = SN_TEXTSIZE(str, [UIFont systemFontOfSize:15]);
    [detailLabel setText:str];
    [detailLabel setFrame:CGRectMake(285 - size.width, 0.0f, size.width, 51.0f)];
}

- (void)detailLabelRemove
{
    [detailLabel removeFromSuperview];
}

-(void)slideView:(SliderSwitch *)slideswitch switchChangedAtIndex:(NSUInteger)index
{
    if (TEXT_MODEL == slideswitch.modelChange) {
        float size = 0;
        if (index == 0)
            size = kWebContentSize1;
        else if (index == 1)
            size = kWebContentSize2;
        else if (index == 2)
            size = kWebContentSize3;
        else if (index == 3)
            size = kWebContentSize4;
        [AppSettings setFloat:size forKey:FLOATKEY_ReaderBodyFontSize];
    }
    else if (IMAGE_MODEL == slideswitch.modelChange)
    {
        [AppSettings setInteger:index forKey:IntKey_ReaderPicMode];
    }
    else if (NIGHT_MODEL == slideswitch.modelChange)
    {
        [[ThemeMgr sharedInstance] changeNightmode:(index == 1)];
    }
}


//社交账号绑定状态
- (void)socialAccountStatus
{    
    SurfDbManager *manager = [SurfDbManager sharedInstance];
    
    NSDictionary *sinaDict = [manager getSinaWeiboInfoForUser:kDefaultID];
    SocialBind *sinaWeibo = [SocialBind new];
    sinaWeibo.name = Sina;
    if ([sinaDict valueForKey:@"access_token"] && [sinaDict valueForKey:@"uid"]) {
        sinaWeibo.bind = YES;
    } else {
        sinaWeibo.bind = NO;
    }
    
//    NSDictionary *tencentDict = [manager getTencentWeiboInfoForUser:kDefaultID];
//    SocialBind *tencentWeibo = [SocialBind new];
//    tencentWeibo.name = Tencent;
//    if ([tencentDict valueForKey:@"access_token"]) {
//        tencentWeibo.bind = YES;
//    } else {
//        tencentWeibo.bind = NO;
//    }

//    NSDictionary *cmDict = [manager getCMWeiboInfoForUser:kDefaultID];
//    SocialBind *cmWeibo = [SocialBind new];
//    cmWeibo.name = CM;
//    if ([cmDict valueForKey:@"access_token"]) {
//        cmWeibo.bind = YES;
//    } else {
//        cmWeibo.bind = NO;
//    }

}

@end


@implementation ModelSettingViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        // Custom initialization
        self.titleState = PhoneSurfControllerStateTop;
        
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    if (IMGAE_ENUM == model_enum) {
        self.title = @"正文图片设置";
        
        if (!imageViewSortBy) {
            imageViewSortBy = [[BGRadioView alloc] initWithFrame:CGRectMake(0, 65, 320, 150)];
            NSMutableArray *sortByItemsArray = [[NSMutableArray alloc] init];
            [sortByItemsArray addObject:@"自动"];
            [sortByItemsArray addObject:@"无图"];
            [sortByItemsArray addObject:@"手动"];
            imageViewSortBy.rowItems =  sortByItemsArray;
            imageViewSortBy.maxRow = [sortByItemsArray count];
            imageViewSortBy.editable = YES;
            imageViewSortBy.delegate = self;
            imageViewSortBy.tag = 1;
            ReaderPicMode picMode = [AppSettings integerForKey:IntKey_ReaderPicMode];
            imageViewSortBy.optionNo = picMode;
            
            [imageViewSortBy setBackgroundColor:[UIColor clearColor]];
            
            [self.view addSubview:imageViewSortBy];
        }
        
    }
    else if (TEXT_ENUM == model_enum){
        self.title = @"正文字号设置";
        
        if (!textViewSortBy) {
            textViewSortBy = [[BGRadioView alloc] initWithFrame:CGRectMake(0, 65, 320, 200)];
            NSMutableArray *sortByItemsArray = [[NSMutableArray alloc] init];
            [sortByItemsArray addObject:@"小"];
            [sortByItemsArray addObject:@"中"];
            [sortByItemsArray addObject:@"大"];
            [sortByItemsArray addObject:@"极大"];
            textViewSortBy.rowItems =  sortByItemsArray;
            textViewSortBy.maxRow = [sortByItemsArray count];
            textViewSortBy.editable = YES;
            textViewSortBy.delegate = self;
            textViewSortBy.tag = 2;
            float model = [AppSettings floatForKey:FLOATKEY_ReaderBodyFontSize];
            if (model == kWebContentSize1)
            {
                textViewSortBy.optionNo = 0;
            }
            else if (model == kWebContentSize2)
            {
                textViewSortBy.optionNo = 1;
            }
            else if (model == kWebContentSize3)
            {
                textViewSortBy.optionNo = 2;
            }
            else if (model == kWebContentSize4)
            {
                textViewSortBy.optionNo = 3;
            }
            
            [textViewSortBy setBackgroundColor:[UIColor clearColor]];
            
            [self.view addSubview:textViewSortBy];
        }
    }
    
    [self addBottomToolsBar];
}

- (void)setModelEnum:(Model_Setting_ENUM)model_E{
    model_enum = model_E;
}


#pragma mark Radio List Delegate
-(void)radioView:(BGRadioView *)radioView
 didSelectOption:(NSInteger)optionNo
          fortag:(NSInteger)tagNo
{
    if (tagNo == 1) {
        [AppSettings setInteger:optionNo forKey:IntKey_ReaderPicMode];
    }
    else if (tagNo == 2){
        float size = 0;
        if (optionNo == 0)
        {
            size = kWebContentSize1;
        }
        else if (optionNo == 1)
        {
            size = kWebContentSize2;
        }
        else if (optionNo == 2)
        {
            size = kWebContentSize3;
        }
        else if (optionNo == 3)
        {
            size = kWebContentSize4;
        }
        [AppSettings setFloat:size forKey:FLOATKEY_ReaderBodyFontSize];
    }
}

@end
