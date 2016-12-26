//
//  MoreViewController.m
//  iOSUIFrame
//
//  Created by Jerry Yu on 13-5-22.
//  Copyright (c) 2013年 adways. All rights reserved.
//

#import "MoreViewController.h"
#import "CollectViewController.h"
#import "AboutViewController.h"
#import "FlowIndicatorViewController.h"
#import "GuideViewController.h"
#import "AppDelegate.h"
#import "FileUtil.h"
#import "PathUtil.h"
#import "OfflineDownloader.h"
#import "HotChannelsManager.h"
#import "SubsChannelsManager.h"
#import "FavsManager.h"
#import "PhotoCollectionManager.h"
#import "MoreTableViewCell.h"
#import "NotificationManager.h"
#import "SNThreadViewerController.h"
#import "FileUtil.h"
#import "PhoneSurfController.h"
#import "LevelInfoViewController.h"
#import <QuartzCore/QuartzCore.h>
#define TABLEVIEW_SECTION_NUM       4

//#define UPDATE_ALT_TAG          8557521
#define REMOVEUSERINFO_ALT_TAG  8574134
#define CLEARCACHE              7655898
#define TABLEVIEWFRMAE2         CGRectMake(10, super.StateBarHeight + 15, 303, super.view.bounds.size.height - super.StateBarHeight)
#define TABLEVIEWFRMAE          CGRectMake(0, super.StateBarHeight, 320, super.view.bounds.size.height - super.StateBarHeight)

#define CELLICONFRAME       CGRectMake(15, 10, 30, 30)

#define FIRSTCILCK_KEY      [NSString stringWithFormat:@"%@_First", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]

//http://www.apple.com/itunes/affiliates/resources/documentation/itunes-store-web-service-search-api.html       检查更新接口

enum MenuItemIndex
{
    Section0 = 0,
    ItemUser = 0,   //注意：每个section中的第一项必须手动设为0
    ItemBandwidth,  //流量，可能会隐藏，如果隐藏，在判断索引时要注意
    ItemWeibo,
    ItemFavs,
    Section0ItemsCount,   //用来判断该section的最后一项，如果等于Section0ItemCount - 1，意味着是最后一项
    
    Section1 = Section0 + 1,
    ItemImageMode = 0,   //注意：每个section中的第一项必须手动设为0
    ItemFontSize,
    ItemNightMode,
    Section1ItemsCount,
    
    Section2 = Section1 + 1,
    ItemClearCache = 0,   //注意：每个section中的第一项必须手动设为0
    ItemClearMagOffline,
    Section2ItemsCount,
    
    Section3 = Section2 + 1,
     
    
#ifdef ENTERPRISE
    ItemCheckNewVersion = 0,   //注意：每个section中的第一项必须手动设为0
    ItemNewbeeGuide,
    ItemMilitary,
    ItemReview,
    ItemAbout,
    Section3ItemsCount
#else
    ItemNewbeeGuide=0,
    ItemReview,
    ItemAbout,
    ItemMilitary,
    Section3ItemsCount
#endif

};

@implementation LevelLabView
//等级的显示方法
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
//        if (!whiteImage) {
//            whiteImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 11, self.bounds.size.width / 3+5, self.bounds.size.height/3+2)];;
//            [whiteImage setImage:[UIImage imageNamed:@"whiteBottom"]];
//            [self addSubview:whiteImage];
//            
//        }
        if (!lvlLab) {
            lvlLab=[[UILabel alloc] initWithFrame:CGRectMake(6, 2, self.bounds.size.width / 2, self.bounds.size.height)];
            [lvlLab setFont:[UIFont systemFontOfSize:12]];
            [lvlLab setBackgroundColor:[UIColor clearColor]];
            [lvlLab setTextAlignment:NSTextAlignmentLeft];
            [lvlLab setTextColor:[UIColor whiteColor]];
            [self addSubview:lvlLab];
            
        }

        if (!titleLab) {
            titleLab=[[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width / 2, 0, self.bounds.size.width / 2, self.bounds.size.height)];
            [titleLab setFont:[UIFont systemFontOfSize:12]];
            [titleLab setBackgroundColor:[UIColor clearColor]];
            [titleLab setTextAlignment:NSTextAlignmentLeft];
            [titleLab setTextColor:[UIColor grayColor]];
#pragma mark - 暂时屏蔽了实习生之类的按钮，如果需要可以重新启用
            //[self addSubview:titleLab];
        }
    }
    
    return self;
}

- (void)setLvlLab:(NSString *)lvlStr{
    [lvlLab setText:lvlStr];
}

- (void)setTitleLab:(NSString *)lvlStr{
    [titleLab setText:lvlStr];
}

@end


@implementation ExpButtonView
//经验条的显示方法
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        
        if (!expLab) {
            expLab = [[UILabel alloc] initWithFrame:CGRectZero];
            [expLab setFont:[UIFont systemFontOfSize:12.0f]];
            [expLab setBackgroundColor:[UIColor clearColor]];
            [expLab setTextAlignment:NSTextAlignmentLeft];
            [expLab setTextColor:[UIColor whiteColor]];
            [self addSubview:expLab];
        }
        
        UIButton *exBt = [UIButton buttonWithType:UIButtonTypeCustom];
        [exBt setFrame:self.bounds];
        [exBt setBackgroundColor:[UIColor clearColor]];
        [exBt addTarget:self action:@selector(clickExBt) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:exBt];
    }
    
    return self;
}

- (void)clickExBt{
    if ([_delegate respondsToSelector:@selector(didExpButton)]) {
        [_delegate didExpButton];
    }
}

- (void)setExpLab:(NSString *)labName
{
    [expLab setText:labName];
    [expLab sizeToFit];
    CGFloat cx = CGRectGetMidX(self.bounds);
    CGFloat cy = CGRectGetMidY(self.bounds);
    expLab.center = CGPointMake(cx, cy);
}

@end

@implementation AccountView

- (id)initWithFrame:(CGRect)frame
{
    //账户一栏的按钮，未登陆前的状态 @"马上登陆领取积分",@"中国移动用户请登录"
    self = [super initWithFrame:frame];
    if (self) {
        
        touchView = [[UIView alloc] initWithFrame:self.bounds];
        touchView.backgroundColor = [UIColor grayColor];
        [touchView setHidden:YES];
        [self addSubview:touchView];
        
        CGFloat iconX = (CGRectGetWidth(frame) - 70)/2;
        iconImageView=[[UIImageView alloc] initWithFrame:CGRectMake(iconX, 20, 70, 70)];
        iconImageView.layer.masksToBounds = YES;
        iconImageView.layer.cornerRadius = iconImageView.frame.size.width/2;
        [self addSubview:iconImageView];
        
      
        titleLab=[[UILabel alloc] initWithFrame:CGRectMake(80, 40, 210, 30)];
        [titleLab setFont:[UIFont boldSystemFontOfSize:16]];
        [titleLab setBackgroundColor:[UIColor clearColor]];
        [titleLab setTextColor:[UIColor colorWithHexValue:0xfffff9a0]];
        [titleLab setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:titleLab];
        
        
        numLab = [[UILabel alloc] initWithFrame:CGRectMake(105, 65, 160, 30)];
        [numLab setBackgroundColor:[UIColor clearColor]];
        [numLab setTextAlignment:NSTextAlignmentLeft];
        [numLab setFont:[UIFont boldSystemFontOfSize:10]];
        [numLab setTextColor:[UIColor whiteColor]];
        [self addSubview:numLab];

    
        buttonLab = [UIButton buttonWithType:UIButtonTypeSystem];
        CGFloat W=[UIScreen mainScreen].bounds.size.width;
        CGFloat buttonLabX=(W-110)/2.0;
        buttonLab.frame = CGRectMake(buttonLabX, 95 , 110, 20);
        [buttonLab setTitle:@"立即登录" forState:UIControlStateNormal];
        [buttonLab setTintColor:[UIColor whiteColor]];
        buttonLab.contentVerticalAlignment = UIControlContentHorizontalAlignmentCenter;//居中对其
        buttonLab.userInteractionEnabled = NO;
        [buttonLab.layer setMasksToBounds:YES];
        [buttonLab.layer setCornerRadius:10.0f];
        [buttonLab.layer setBorderWidth:0.7f];
        [buttonLab.layer setBorderColor:[UIColor whiteColor].CGColor];

        
        buttonLab.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        [self addSubview:buttonLab];

        levelButton = [[ExpButtonView alloc] initWithFrame:CGRectMake(80, 120, 160, 20)];
        [levelButton setDelegate:self];
        [levelButton setBackgroundColor:[UIColor clearColor]];
        levelButton.layer.masksToBounds = YES;
        levelButton.layer.borderWidth = 0.6f;
        levelButton.layer.cornerRadius = 10;
        levelButton.layer.borderColor = [[UIColor whiteColor] CGColor];

        [self addSubview:levelButton];
        [levelButton setHidden:YES];
    }
    return self;
}

-(void)updateUserInfo
{
    // 更新头像
    if ([FileUtil fileExists:[PathUtil pathUserHeadPic]]) {
        UIImage *iconImage = [UIImage imageWithContentsOfFile:[PathUtil pathUserHeadPic]];
        [iconImageView setImage:iconImage];//若用户登录以后，再本地取到用户的头像，进行显示
    }
    else{
        UIImage *image = [UIImage imageNamed:@"headPicImageNew"];
        [iconImageView setImage:image];
        //默认的用户登录的头像
    }
    
    UserInfo *userInfo = [[UserManager sharedInstance] loginedUser];
    if (userInfo) {
   
        if (userInfo.userDes.nickName) {
            [titleLab setText:userInfo.userDes.nickName];
            [titleLab setHidden:NO];
        }
        else {
            [titleLab setText:@""];
        }
        CGSize tSize = [titleLab sizeThatFits:CGSizeMake(110, 30)];
        if (tSize.width > 110) {
            tSize.width = 110.f;
        }
        titleLab.frame = CGRectMake(55, 100, tSize.width, tSize.height);
        
        
        if (userInfo.phoneNum) {
            [numLab setText:[self cutNumStr:userInfo.phoneNum]];
            CGSize numSize = [numLab sizeThatFits:CGSizeZero];
            numLab.frame = CGRectMake(175, 90, numSize.width, numSize.height);
            
            [buttonLab setHidden:YES];
            [numLab setHidden:NO];
            [levelButton setHidden:NO];
            [iconImageView setHidden:NO];
        }
        else{
            [numLab setHidden:YES];
        }
        
        // 尼玛，非要居中用什么意思
        CGFloat tWidth = CGRectGetWidth(titleLab.bounds);
        CGFloat nWidth = CGRectGetWidth(numLab.bounds);
        CGFloat totalWidth = tWidth + nWidth + 10;
        CGFloat halfW = totalWidth / 2.f;
        
        CGFloat centerX = self.center.x;
        CGPoint tempP = titleLab.center;
        tempP.x = centerX - (halfW-tWidth/2);
        titleLab.center = tempP;
        
        tempP = numLab.center;
        tempP.x = centerX + (halfW-nWidth/2);
        tempP.y = titleLab.center.y;
        numLab.center = tempP;
  
        
        // 经验值
        if (userInfo.userGold) {
            UserTaskData *userTaskData = userInfo.userGold;
            if ([userTaskData.finishNum integerValue] < [userTaskData.totalNum integerValue]) {
                
                [levelButton setExpLab:@"领取经验值"];
                levelButton.userInteractionEnabled = YES;
                [levelButton setHidden:NO];
                
            }
            else
            {
                NSString *upgradeCreditStr =
                [NSString stringWithFormat:@"%@ 经验值 %@/%@",
                 userInfo.userDes.lvl,
                 userInfo.userDes.credit,
                 userInfo.userDes.upgradeCredit];
                [levelButton setExpLab:upgradeCreditStr];
                levelButton.userInteractionEnabled = NO;
                [levelButton setHidden:NO];
            }
        }
    }
    else{
        CGFloat W=[UIScreen mainScreen].bounds.size.width;

        
        [titleLab setHidden:NO];
        [titleLab setText:@"马上登录领取经验值"];
        titleLab.frame = CGRectMake(0, 40, W, 30);
        
        [numLab setText:@"中国移动用户请登录"];
        [numLab setFont:[UIFont boldSystemFontOfSize:11]];
        numLab.frame = CGRectMake(0, 65, W, 30);
        numLab.textAlignment=NSTextAlignmentCenter;
        [numLab setHidden:NO];
        [buttonLab setHidden:NO];
        [iconImageView setHidden:YES];
        
       
        
        [levelButton setExpLab:@""];
        levelButton.userInteractionEnabled = NO;
        [levelButton setHidden:YES];//经验值
    }
}

- (void)didLvlBt:(UIButton *)sender
{
    [[UserManager sharedInstance] postUserScoreWithCompletionHandler:^(BOOL succeeded, NSDictionary *dicData) {

        if (succeeded) {
            UserInfo *userInfo = [[UserManager sharedInstance] loginedUser];

            NSString *creditStr = [dicData objectForKey:@"credit"];
            NSUInteger creditCount = [creditStr integerValue] + [userInfo.userDes.credit integerValue];
            userInfo.userDes.credit = [NSString stringWithFormat:@"%ld", (unsigned long)creditCount];
            
            userInfo.userGold.finishNum = userInfo.userGold.totalNum;
            
            [[UserManager sharedInstance] savePathOfUserInfo];
            
            
            NSString *upgradeCreditStr =
            [NSString stringWithFormat:@"%@ 经验值 %@/%@",
             userInfo.userDes.lvl,
             userInfo.userDes.credit,
             userInfo.userDes.upgradeCredit];
            [levelButton setExpLab:upgradeCreditStr];
            
            if ([_delegate respondsToSelector:@selector(showCreditAnimalView:)]) {
                [_delegate showCreditAnimalView:creditStr];
            }
        }
    }];
}

- (NSString *)levelStr:(NSString *)lvlStr
{
    NSString *str1 = [lvlStr substringFromIndex:2];
    NSUInteger lvl_int = [str1 integerValue];
    NSArray *levles = @[@"实习生", @"试用期",@"职场新人",@"助理",
                        @"见习主管",@"主管",@"初级经理",@"中级经理",
                        @"高级经理",@"部门总监",@"区域总监",@"部门总裁",
                        @"区域总裁",@"副总裁"];
    if (lvl_int >0 && lvl_int <= [levles count]) {
        return levles[lvl_int-1];
    }
    return nil;
}

-(void)viewNightModeChanged:(BOOL)isNight
{
    UIColor *bgColor = [UIColor colorWithHexValue:isNight?kTableCellSelectedColor_N:kTableCellSelectedColor];
    [touchView setBackgroundColor:bgColor];
}

-(NSString*)cutNumStr:(NSString*)userIdStr
{
    NSString*str=[userIdStr copy];
    NSString*str1=[str substringToIndex:3];
    NSString*str2=[str substringFromIndex:7];
    return [NSString stringWithFormat:@"%@****%@",str1,str2];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [touchView setHidden:NO];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [touchView setHidden:YES];
    
    if ([_delegate respondsToSelector:@selector(didAccountView)]) {
        [_delegate didAccountView];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [touchView setHidden:YES];
}

#pragma mark ExpButtonViewDelegate
- (void)didExpButton{
    [self didLvlBt:nil];
}

@end



@implementation ShareCellView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        bindSinaImage = [UIImage imageNamed:@"bind_sina_logo"];
        unBindSinaImage = [UIImage imageNamed:@"unbind_sina_logo"];
    }
    return self;
}
//不需要的分享cell
#if 0
- (void)drawRect:(CGRect)rect
{//分享页面状态的显示
    [super drawRect:rect];
    
    if (!touchView) {
        touchView=[[UIView alloc] initWithFrame:rect];
        [touchView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:touchView];
    }
    
    if (!iconImageView) {
        iconImageView=[[UIImageView alloc] initWithFrame:CELLICONFRAME];
        [self addSubview:iconImageView];
    }
    
    if (!titleLab) {//未登陆
        titleLab=[[UILabel alloc] initWithFrame:CGRectMake(60, 10, 100, 30)];
        [titleLab setBackgroundColor:[UIColor clearColor]];
        [titleLab setText:@"分享绑定"];
        [titleLab setFont:[UIFont systemFontOfSize:14]];
        [titleLab setTextAlignment:NSTextAlignmentLeft];
        [self addSubview:titleLab];
    }
    
    if ([[ThemeMgr sharedInstance] isNightmode]) {
        [titleLab setTextColor:[UIColor whiteColor]];
        [iconImageView setImage:[UIImage imageNamed:@"shareIcon_night"]];
    }
    else{
        [titleLab setTextColor:[UIColor colorWithHexString:@"34393d"]];
        [iconImageView setImage:[UIImage imageNamed:@"shareIcon"]];
        
    }
    
    [self socialAccountStatus];
}

#endif
- (void)socialAccountStatus
{//游客登陆时的显示状态
    if (!sinaImageView) {
        sinaImageView=[[UIImageView alloc] initWithFrame:CGRectMake(131, 10, 30, 30)];
        [self addSubview:sinaImageView];
    }
 
    SurfDbManager *manager = [SurfDbManager sharedInstance];
    
    NSDictionary *sinaDict = [manager getSinaWeiboInfoForUser:kDefaultID];
    SocialBind *sinaWeibo = [SocialBind new];
    sinaWeibo.name = Sina;
    if ([sinaDict valueForKey:@"access_token"] && [sinaDict valueForKey:@"uid"]) {
        sinaWeibo.bind = YES;
        sinaImageView.image=bindSinaImage;
    } else {
        sinaWeibo.bind = NO;
        sinaImageView.image=unBindSinaImage;
    }  
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [touchView setBackgroundColor:[UIColor grayColor]];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [touchView setBackgroundColor:[UIColor clearColor]];
    
    if ([_delegate respondsToSelector:@selector(didShareCellView)]) {
        [_delegate didShareCellView];
    }
}


@end



@implementation IndicatorCellView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self buildUI];
    }
    return self;
}
- (void)buildUI
{
    touchView=[[UIView alloc] initWithFrame:self.bounds];
    [touchView setBackgroundColor:[UIColor grayColor]];
    [touchView setHidden:YES];
    [self addSubview:touchView];
    
    
    // 手机话费及流量cell，此版本中删除
    [telephonechargeimageview setHidden:NO];
    telephonechargeimageview = [[UIImageView alloc] initWithFrame:CGRectMake(60, 15, 15, 15)];
    [telephonechargeimageview setImage:[UIImage imageNamed:@"telephonechargeView"]];
    [self addSubview:telephonechargeimageview];
    
    
    [telephonelabel setHidden:NO];
    telephonelabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 10, 30, 25)];
    telephonelabel.text = @"话费";
    telephonelabel.font = [UIFont systemFontOfSize:12.0f];
    telephonelabel.backgroundColor = [UIColor clearColor];
    [self addSubview:telephonelabel];


    [flowimageview setHidden:NO];
    flowimageview = [[UIImageView alloc] initWithFrame:CGRectMake(215, 15, 15, 15)];
    [flowimageview setImage:[UIImage imageNamed:@"flowView"]];
    [self addSubview:flowimageview];
    flowlabel = [[UILabel alloc] initWithFrame:CGRectMake(240, 10, 30, 25)];
    flowlabel.text = @"流量";
    flowlabel.font = [UIFont systemFontOfSize:12.0f];
    flowlabel.backgroundColor = [UIColor clearColor];
    [self addSubview:flowlabel];


    detailLab=[[UILabel alloc] initWithFrame:CGRectMake(40, 40, 250, 25)];
    [detailLab setBackgroundColor:[UIColor clearColor]];
    [detailLab setTextAlignment:NSTextAlignmentLeft];
    [detailLab setFont:[UIFont systemFontOfSize:15]];
    [detailLab setTextColor:[UIColor colorWithHexString:@"999292"]];
    [self addSubview:detailLab];


    [numberlabel setHidden:NO];
    numberlabel = [[UILabel alloc] initWithFrame:CGRectMake(76, 37, 200, 25)];
    [numberlabel setBackgroundColor:[UIColor clearColor]];
    [numberlabel setTextAlignment:NSTextAlignmentLeft];
    [numberlabel setFont:[UIFont systemFontOfSize:20]];
    [numberlabel setTextColor:[UIColor redColor]];
        [self addSubview:numberlabel];


    [detailLabel2 setHidden:NO];
    detailLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(140, 40, 50, 25)];
    [detailLabel2 setBackgroundColor:[UIColor clearColor]];
    [detailLabel2 setTextAlignment:NSTextAlignmentLeft];
    [detailLabel2 setFont:[UIFont systemFontOfSize:12]];
    [detailLabel2 setTextColor:[UIColor colorWithHexString:@"999292"]];
    [self addSubview:detailLabel2];

   
    CGRect flowRect = CGRectMake(190, 40, 100, 10);
    whiteFlowImageView = [[UIImageView alloc] initWithFrame:flowRect];
    UIImage *whietFlowImg = [UIImage imageNamed:@"whiteFlowView"];
    [whiteFlowImageView setImage:[whietFlowImg stretchableImageWithLeftCapWidth:10 topCapHeight:0.0f]];
    [whiteFlowImageView setHidden:YES];
    [self addSubview:whiteFlowImageView];


    redFlowImageView = [[UIImageView alloc] initWithFrame:flowRect];
    UIImage *redFlowImg = [UIImage imageNamed:@"redFlowView"];
    [redFlowImageView setImage:[redFlowImg stretchableImageWithLeftCapWidth:5 topCapHeight:0.0f]];
    [redFlowImageView setHidden:YES];
    [self addSubview:redFlowImageView];

    
    usedLabel = [[UILabel alloc] initWithFrame:CGRectMake(185, 50, 100, 20)];
    [usedLabel setBackgroundColor:[UIColor clearColor]];
    [usedLabel setTextAlignment:NSTextAlignmentLeft];
    [usedLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [usedLabel setTextColor:[UIColor redColor]];
    [self addSubview:usedLabel];


    allLabel = [[UILabel alloc] initWithFrame:CGRectMake(244, 50, 100, 20)];
    [allLabel setBackgroundColor:[UIColor clearColor]];
    [allLabel setTextAlignment:NSTextAlignmentLeft];
    [allLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [allLabel setTextColor:[UIColor colorWithHexString:@"999292"]];
    [self addSubview:allLabel];
    
    BOOL isN = [[ThemeMgr sharedInstance] isNightmode];
    [self viewNightModeChanged:isN];
}

-(void)updateViewUI
{
    if ([_activityView isAnimating]) {
        return;
    }
    
    // 添加一个风火轮
    [self startActivity];
    
    __block typeof(self) weakSelf = self;
    [[UserManager sharedInstance] userFlowInfo:^(SNUserFlow *flowInfo) {
        [weakSelf stopActivity];
        if(flowInfo){
            [detailLabel2 setHidden:NO];
            [numberlabel setHidden:NO];
            [whiteFlowImageView setHidden:NO];
            [redFlowImageView setHidden:NO];
            [usedLabel setHidden:NO];
            [allLabel setHidden:NO];
            
            [detailLab setText:@"余额:"];
            [numberlabel setText:flowInfo.balance];
            [detailLabel2 setText:@"元"];
            [usedLabel setText:[NSString stringWithFormat:@"%@M",flowInfo.usedsum]];
            
            
            CGFloat w = 1.f;
            CGFloat totalV = [flowInfo.total floatValue];
            CGFloat usedV = [flowInfo.usedsum floatValue];
            if (totalV > 0) {
                w = usedV/totalV * CGRectGetWidth(whiteFlowImageView.bounds);
            }
            //totalV = 10.f;测试
            [allLabel setText:[NSString stringWithFormat:@"/%@ M",@(totalV)]];
            [redFlowImageView setFrame:CGRectMake(190, 40, w, 10)];
        }
        else {
            [detailLab setText:@"更新失败，点击查询"];
            detailLab.font = [UIFont systemFontOfSize:10.0f];
            
            [detailLabel2 setHidden:YES];
            [numberlabel setHidden:YES];
            [whiteFlowImageView setHidden:YES];
            [redFlowImageView setHidden:YES];
            [usedLabel setHidden:YES];
            [allLabel setHidden:YES];
        }
    }];
}

-(void)startActivity
{
    if (!_activityView) {
        BOOL isN = [[ThemeMgr sharedInstance] isNightmode];
        UIActivityIndicatorViewStyle style = UIActivityIndicatorViewStyleGray;
        if (isN) {
            style = UIActivityIndicatorViewStyleWhite;
        }
        _activityView =
        [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
        _activityView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        [self addSubview:_activityView];
    }
    
    if (![_activityView isAnimating]) {
        [_activityView startAnimating];
    }
}

-(void)stopActivity
{
    [_activityView stopAnimating];
}

-(void)viewNightModeChanged:(BOOL)isNight
{
    UIColor *tColor;
    if (isNight) {
        tColor = [UIColor whiteColor];
        [iconImageView setImage:[UIImage imageNamed:@"inductorIcon_night"]];
    }
    else{
        tColor = [UIColor colorWithHexValue:0xff34393d];
        [iconImageView setImage:[UIImage imageNamed:@"inductorIcon"]];
    }

    UIActivityIndicatorViewStyle style = UIActivityIndicatorViewStyleGray;
    if (isNight) {
        style = UIActivityIndicatorViewStyleWhite;
    }
    _activityView.activityIndicatorViewStyle = style;
    
    
    
    [titleLab setTextColor:tColor];
    telephonelabel.textColor = tColor;
    flowlabel.textColor = tColor;
    
    
    UIColor *bgColor = [UIColor colorWithHexValue:isNight?kTableCellSelectedColor_N:kTableCellSelectedColor];
    [touchView setBackgroundColor:bgColor];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [touchView setHidden:NO];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [touchView setHidden:YES];
    
    if ([_delegate respondsToSelector:@selector(didIndicatorView)]) {
        [_delegate didIndicatorView];
    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [touchView setHidden:YES];
}

@end


#pragma mark - moreButton~~~~~~~

#define  kMoreBtnIconWidth 47
#define  kMoreBtnIconHeight 47
@implementation MoreButton

+(CGSize)sizeWithFits
{
    return CGSizeMake(5+kMoreBtnIconWidth+20, kMoreBtnIconHeight+25);
}
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat w = CGRectGetWidth(frame);
        CGFloat h = CGRectGetHeight(frame);
        
        UIView *selectV =
        [[UIView alloc] initWithFrame:self.bounds
         ];
        _selectView = selectV;
        selectV.layer.cornerRadius = 5.f;
        [selectV setHidden:YES];
        [self addSubview:selectV];
        
        
        UIFont *titleFont = [UIFont systemFontOfSize:12];
        CGFloat tY = h - titleFont.lineHeight;
        CGRect titleRect = CGRectMake(0, tY, w, titleFont.lineHeight);
        UILabel *titleLab = [[UILabel alloc] initWithFrame:titleRect];
        _titleLab = titleLab;
        [titleLab setBackgroundColor:[UIColor clearColor]];
        [titleLab setTextAlignment:NSTextAlignmentCenter];
        [titleLab setFont:titleFont];
        [self addSubview:titleLab];
        
        
        CGFloat iconX = (w-kMoreBtnIconWidth)/2.f;
        CGRect iconRect = CGRectMake(iconX, 5, kMoreBtnIconWidth, kMoreBtnIconHeight);
        UIImageView *iconView =
        [[UIImageView alloc] initWithFrame:iconRect];
        _iconImageView = iconView;
        [self addSubview:iconView];
        
        BOOL isN = [[ThemeMgr sharedInstance] isNightmode];
        [self viewNightModeChanged:isN];
        
    }
    return self;
}

-(void)setBtnImage:(UIImage *)btnImage
{
    _btnImage = btnImage;
    _iconImageView.image = btnImage;
}

-(void)setTitleStr:(NSString *)titleStr
{
    _titleStr = titleStr;
    _titleLab.text = titleStr;
}



- (BOOL)beginTrackingWithTouch:(UITouch *)touch
                     withEvent:(UIEvent *)event
{
    [_selectView setHidden:NO];
    return [super beginTrackingWithTouch:touch withEvent:event];
}
- (void)endTrackingWithTouch:(UITouch *)touch
                   withEvent:(UIEvent *)event
{
    [_selectView setHidden:YES];
    [super endTrackingWithTouch:touch withEvent:event];
}
- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    [_selectView setHidden:YES];
    [super cancelTrackingWithEvent:event];
}


-(void)viewNightModeChanged:(BOOL)isNight
{
    if (isNight) {
        [_titleLab setTextColor:[UIColor whiteColor]];
        
        _selectView.backgroundColor =
        [UIColor colorWithHexValue:kTableCellSelectedColor_N];
    }
    else{
        [_titleLab setTextColor:
         [UIColor colorWithHexString:@"34393d"]];
        
        _selectView.backgroundColor =
        [UIColor colorWithHexValue:kTableCellSelectedColor];
    }
}

-(void)showNotifiMark
{
    if (!notifiMarkIamgeView) {
        notifiMarkIamgeView=[[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-20, 5, 6, 6)];
        [notifiMarkIamgeView setImage:[UIImage imageNamed:@"isnew"]];
    }
    if (![self.subviews containsObject:notifiMarkIamgeView]) {
        [self addSubview:notifiMarkIamgeView];
    }
}

-(void)removeFromnotifiMarkIamgeView
{
    if (notifiMarkIamgeView) {
        [notifiMarkIamgeView removeFromSuperview];
        notifiMarkIamgeView=Nil;
    }
}

@end


@interface MoreViewController ()
{
    UILabel * moreBt_collectLabel;
    UILabel * moreBt_mycommentLabel;
    UILabel * moreBt_advicefeedbackLabel;
    UILabel * moreBt_offlineLabel;
    UILabel * moreBt_isnightLabel;
    UILabel * moreBt_settingLabel;
    UIImageView * imageViewCollection;
    UIImage * imageCollection;
    UIImageView * imageViewComment;
    UIImage * imageComment;
    UIImageView * imageViewAdvertise;
    UIImage * imageAdvertise;
    UIImageView * imageViewNight;
    UIImage * imageNight;
    UIImageView * imageViewSetting;
    UIImage * imageSetting;
}

@end


@implementation MoreViewController

typedef NS_ENUM(NSInteger, MoreButtonType){
    MBType_Collect,     // 收藏
    MBType_Setting,     // 设置
    MBType_NightMode,   // 夜间模式
    MBType_Feedback,    // 意见反馈
    MBType_Product, // 产品信息
    MbType_productInfo,//产品信息
    MbType_InviteButton
};
- (id)init
{
    self = [super init];
    if (self)
    {
        // Custom initialization
        self.titleState = PhoneSurfControllerStateNone;
        
        UserManager *manager = [UserManager sharedInstance];
        [manager addUserLoginObserver:self];
    }
    return self;
}

- (void)dealloc
{
    UserManager *manager = [UserManager sharedInstance];
    [manager removeUserLoginObserver:self];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

// 显示标记(暂时不用)
-(void)showAllMark
{
    return;
    if ([self isShowLoginStatus]) {
        [self showNotifiMark];
    }
    else{
        if (notifiMarkIamgeView) {
            [notifiMarkIamgeView removeFromSuperview];
            notifiMarkIamgeView=Nil;
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self buildScrollView];
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    
    // 用户信息
    CGFloat vH1 = 170.f;
    accountView=[[AccountView alloc] initWithFrame:CGRectMake(0, 0, width, vH1)];
    [accountView setDelegate:self];
    [accountView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"redbase"]]];
    [_scrollView addSubview:accountView];
    
    
    // buttonItems
    sectionView2 = [UIView new];
    sectionView2.backgroundColor = [UIColor clearColor];
    {
        NSArray *btnTypes =
  @[@(MBType_Collect),
    @(MBType_Setting), @(MBType_Feedback), @(MBType_Product),@(MbType_InviteButton)];

        //@(MBType_NightMode) 可以加一个夜间模式，徐哥已经写好了，暂时去掉～
        CGFloat btnY = 20.f;
        NSInteger rowCount = 3; // 一行的总素
        CGSize btnSize = [MoreButton sizeWithFits];
        CGFloat btnSpaceH =
        (width - (btnSize.width * rowCount))/(rowCount+1); // 水平间隔
        CGFloat btnSpaceV = 20.f; // 垂直间隔
        CGFloat btnX = btnSpaceH;
        CGRect btnRect = CGRectZero;
        for (NSInteger i=0; i<[btnTypes count]; ++i) {
            CGFloat bX = btnX+(btnSize.width+btnSpaceH)*(i%rowCount);
            CGFloat bY = btnY+(btnSize.height + btnSpaceV)*(i/rowCount);
            btnRect = CGRectMake(bX, bY, btnSize.width, btnSize.height);
            
            MoreButton *mb = [self buildMoreButtonWithFrame:btnRect moreBtnType:[btnTypes[i] integerValue]];
            [sectionView2 addSubview:mb];
        }
        
        CGFloat svH = btnRect.origin.y + btnRect.size.height + 20.f;
        [sectionView2 setFrame:CGRectMake(0, vH1, width, svH)];
    
    }
    [_scrollView addSubview:sectionView2];
    
    [[UserManager sharedInstance] writeToSelectedMoreVC:@"YES"];
}

// 用户流量信息
-(void)userFlowInfoView
{
    // 用户流量（没有登录是不显示流量信息）
    if (indicatorCellView) {
        return;
    }
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat icvY = sectionView2.frame.origin.y + sectionView2.frame.size.height;
    CGFloat icvH = 80.f;
    indicatorCellView = [[IndicatorCellView alloc] initWithFrame:CGRectMake(0, icvY, width, icvH)];
    [indicatorCellView setDelegate:self];
    [indicatorCellView setBackgroundColor:[UIColor clearColor]];
    [_scrollView addSubview:indicatorCellView];
    [_scrollView setContentSize:CGSizeMake(width, icvY+icvH)];
    
    // 分割线
    CGFloat lX = 15.f;
    CGFloat lY = icvY;
    CGFloat lW = width - lX -lX;
    CGRect lR = CGRectMake(lX, lY ,lW, 1);
    UIImageView *line = [[UIImageView alloc] initWithFrame:lR];
    _line1 = line;
    [_scrollView addSubview:line];
    
    
    CGFloat midX = indicatorCellView.center.x;
    CGFloat lineW2 = CGRectGetHeight(indicatorCellView.bounds) - 20.f;
    CGRect lRect2 = CGRectMake(0, 0,lineW2 , 1);
    line = [[UIImageView alloc] initWithFrame:lRect2];
    _line2 = line;
    line.center = CGPointMake(midX, icvH / 2.f);
    line.transform = CGAffineTransformMakeRotation(M_PI_2);
    [indicatorCellView addSubview:line];
    
    
    CGFloat lX3 = 15.f;
    CGFloat lY3 = indicatorCellView.frame.origin.y + indicatorCellView.frame.size.height;
    CGFloat lW3 = width - lX -lX;
    CGRect lRect3 = CGRectMake(lX3, lY3 ,lW3, 1);
    line = [[UIImageView alloc] initWithFrame:lRect3];
    _line3 = line;
    [_scrollView addSubview:line];
    
    
    BOOL night = [[ThemeMgr sharedInstance] isNightmode];
    if (night) {
        UIImage *Nightimage = [UIImage imageNamed:@"moreCellLine_night"];
        [_line1 setImage:Nightimage];
        [_line2 setImage:Nightimage];
        [_line3 setImage:Nightimage];
    }
    else {
        UIImage *daytimeImage = [UIImage imageNamed:@"moreCellLine"];
        [_line1 setImage:daytimeImage];
        [_line2 setImage:daytimeImage];
        [_line3 setImage:daytimeImage];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    FavsManager *manager = [FavsManager sharedInstance];
    collectCount =  [manager threadsCount];
    
    if (!selectMoreSubController) {  //如果是从子界面返回到更多tab就不重新计算缓存
        cachesSize = nil;
        [self calccaches];
    }
    else {
        selectMoreSubController = NO;
    }
    

    [self showAllMark];
    
    if ([[UserManager sharedInstance] loginedUser]) {
        [self userFlowInfoView];
        [indicatorCellView updateViewUI];
    }
    else {
        [indicatorCellView removeFromSuperview];
        indicatorCellView = nil;
        [_line1 removeFromSuperview];
        [_line2 removeFromSuperview];
        [_line3 removeFromSuperview];
        _line1 = _line2 = _line3 = nil;
    }
    
    [accountView updateUserInfo]; // 更新用户信息
    
    //用户进入个人中心，自动领取经验值
    UserInfo * userInfo = [[UserManager sharedInstance] loginedUser];
    if (userInfo)
    {
        [accountView didLvlBt:nil];
    }
}

/**
 *   创建”更多“按钮，可以继续在else if 追加自定义按钮，
 *
 *  @param frame 按钮大小
 *  @param type  按钮类型
 *
 *  @return 返回对象
 */
-(MoreButton*)buildMoreButtonWithFrame:(CGRect)frame
                           moreBtnType:(MoreButtonType)type
{
    NSString *title;
    NSString *iconName;
    MoreButton *mb;
    if (type == MBType_Collect) {
        title = @"收藏夹";
        iconName = @"collectionview";
    }
    else if(type == MBType_Setting) {
        title = @"设置";
        iconName = @"settingview";
    }
    else if(type == MBType_NightMode) {
        title = @"夜间模式";
        iconName = @"nightViewView";
    }
    else if(type == MBType_Product) {
        title = @"产品信息";
        iconName = @"productView";
    }
    else if(type == MBType_Feedback) {
        title = @"意见反馈";
        iconName = @"advertiseview";
    }
    else if(type == MbType_productInfo) {
        title = @"产品信息";
        iconName = @"productView";
    
    }
    else if (type == MbType_InviteButton) {
        title = @"邀请好友";
        iconName = @"inviteview";
    
    }
    if (title && iconName) {
        mb = [[MoreButton alloc] initWithFrame:frame];
        mb.tag = type;
        [mb addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        mb.titleStr = title;
        mb.btnImage = [UIImage imageNamed:iconName];
        mb.backgroundColor = [UIColor clearColor];
    }
    return mb;
}

- (void)initTableView
{
    if ([UserManager sharedInstance].loginedUser.userID)
    {
        isHaveUserId = YES;
    }
    else
    {
        isHaveUserId = NO;
    }
    
}

-(BOOL)isShowLoginStatus
{
    //显示红点逻辑：
    if ([AppSettings stringForKey:StringLoginedUser] != nil &&
        ![UserManager sharedInstance].loginedUser.userID) {
        //用户没有登录（且用户userID存在）的情况下
        if ([[NSUserDefaults standardUserDefaults] objectForKey:StringIsShowMarkLogo]) {
            NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:StringIsShowMarkLogo];
            if (str && [str isEqualToString:@"YES"]) {
                [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:StringIsShowMarkLogo];
                return YES;
            }
            else{
                if ([str isEqualToString:@"NO"]) {
                    return NO;
                }
                return YES;
            }
        }
        else{
            return YES;
        }
        
    } else if ([AppSettings stringForKey:StringIMSIPhone] != nil)  {
        //用户反查到手机号码
        return YES;
    }

    return NO;
}

-(BOOL)isShowUpDateStatus{
    if ([iTunesLookupUtil sharedInstance].hasNewVersion&&![AppSettings stringForKey:FIRSTCILCK_KEY]) {
        return YES;
    }
    return NO;
}

-(void)showNotifiMark
{
    if (!notifiMarkIamgeView) {
        notifiMarkIamgeView=[[UIImageView alloc] initWithFrame:CGRectMake(accountView.frame.size.width-20, 20, 6, 6)];
        [notifiMarkIamgeView setImage:[UIImage imageNamed:@"isnew"]];
    }
    
    if (![accountView.subviews containsObject:notifiMarkIamgeView]) {
        [accountView addSubview:notifiMarkIamgeView];
    }
}


-(void)moreButtonClick:(MoreButton*)btn
{
    switch (btn.tag) {
        case MBType_Collect:
            [self shwoCollectViewController];
            break;
        case MBType_Setting:
            [self showSettingViewController];
            break;
        case MBType_Feedback:
            [self showFeedbackViewControler];
            break;
        case MBType_Product:
            [self showProductViewController];
            break;
        case MBType_NightMode:{
            BOOL isN = [[ThemeMgr sharedInstance] isNightmode];
             [[ThemeMgr sharedInstance] changeNightmode:!isN];
            break;
        case MbType_productInfo:
            [self showProductInfoViewController];
            case MbType_InviteButton:
            [self showInviteViewController];
        }
        default:
            break;
    }
}

// 登录界面
-(void)didAccountView
{
    if ([UserManager sharedInstance].loginedUser.userID){
        UserCenterViewController *userCenterController = [[UserCenterViewController alloc] init];
        [userCenterController setDelegate:self];
        [self presentController:userCenterController animated:PresentAnimatedStateFromRight];
    }
    else{
        PhoneLoginController *loginController = [[PhoneLoginController alloc] init];
        [self presentController:loginController animated:PresentAnimatedStateFromRight];
    }
}

- (void)showCreditAnimalView:(NSString *)credit_Str{
    UIView *bgView = [[UIView alloc] initWithFrame:self.view.bounds];
    [bgView setBackgroundColor:[UIColor blackColor]];
    [bgView setAlpha:0.2];
    [self.view addSubview:bgView];
    
    UILabel *creditLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    [creditLab setBackgroundColor:[UIColor clearColor]];
    [creditLab setFont:[UIFont systemFontOfSize:28]];
    [creditLab setTextColor:[UIColor yellowColor]];
    [creditLab setTextAlignment:NSTextAlignmentCenter];
    creditLab.center = bgView.center;
    [creditLab setText:[NSString stringWithFormat:@"+%@", credit_Str]];
    [self.view addSubview:creditLab];
    
    [UIView animateWithDuration:1 animations:^{
        creditLab.center = CGPointMake(bgView.center.x, bgView.center.y - 50);
    } completion:^(BOOL finished) {
        [creditLab removeFromSuperview];
        [bgView removeFromSuperview];
    }];
}
#pragma mark - 分享页面的点击相应
-(void)didShareCellView
{   selectMoreSubController = YES;//点击是否进入更多界面
    SocialAccountController *socialAccountController =
    [SocialAccountController new];
    [self presentController:socialAccountController animated:PresentAnimatedStateFromRight];
}

// 用户流量，金额等基本信息
-(void)didIndicatorView
{
    if ([UserManager sharedInstance].loginedUser.userID){
        FlowIndicatorViewController *flowIndicatorViewCrl = [[FlowIndicatorViewController alloc] init];
        [self presentController:flowIndicatorViewCrl animated:PresentAnimatedStateFromRight];
    }
    else {
        // 登录界面
        [self didAccountView];
    }
}

-(void)showOfflinesMagazineController{
    selectMoreSubController = YES;
    OfflinesMagazineController *offlinesMagazineCrl = [[OfflinesMagazineController alloc] init];
    offlinesMagazineCrl.title = @"期刊下载管理";
    [self presentController:offlinesMagazineCrl animated:PresentAnimatedStateFromRight];
}

-(void)shwoCollectViewController{
    selectMoreSubController = YES;
    CollectViewController *collectViewCrl = [[CollectViewController alloc] init];
    collectViewCrl.title = @"我的收藏";
    [self presentController:collectViewCrl animated:PresentAnimatedStateFromRight];
}

-(void)showSettingViewController{
    [AppSettings setString:@"FIRSTCILCK_KEY" forKey:FIRSTCILCK_KEY];
    selectMoreSubController = YES;
    SettingViewController *settingViewCrl = [[SettingViewController alloc] init];
    [self presentController:settingViewCrl animated:PresentAnimatedStateFromRight];
}
-(void)showProductInfoViewController {

    // 进入产品信息
        ProductInfoController *productViewCrl = [[ProductInfoController alloc] init];
        [self presentController:productViewCrl animated:PresentAnimatedStateFromRight];
    
}
-(void)showInviteViewController
{
    PhoneshareWeiboInfo *info = [[PhoneshareWeiboInfo alloc]initWithWeiboSource:kWeiboData_userCenter];
    [info setWeiboTitle:@"上冲浪快讯，品时事热点，参与幸运活动!"
                   desc:@"冲浪快讯全新升级，震撼你的视觉神经！"
                    url:@"https://itunes.apple.com/cn/app/shu-ju-an-qing/id1112846063?mt=8"];
    info.showWeiboType = kWeixin|kWeiXinFriendZone|kSinaWeibo|kQQFriend|kQZone;
    [self showShareView:kWeiboView_Center shareInfo:info];
}
-(void)showProductViewController
{
    selectMoreSubController = YES;

    // 进入产品信息
    ProductInfoController *productViewCrl = [[ProductInfoController alloc] init];
    [self presentController:productViewCrl animated:PresentAnimatedStateFromRight];
}
    // 意见反馈
-(void)showFeedbackViewControler
{
    selectMoreSubController = YES;
    [self presentController:[FeedbackViewController new]
                   animated:PresentAnimatedStateFromRight];
}
- (void)showAdvertiseViewController {
    selectMoreSubController = YES;
    FeedbackViewController *feedbackViewcrl = [[FeedbackViewController alloc] init];
    feedbackViewcrl.title = @"意见反馈";
    [self presentController:feedbackViewcrl animated:PresentAnimatedStateFromRight];

}
- (void)showWebViewController
{
    ThreadSummary* ts = [ThreadSummary new];
    ts.newsUrl = kActivityUrl;
    ts.webView = 1;
    SNThreadViewerController* vv = [[SNThreadViewerController alloc] initWithThread:ts];
    [self presentController:vv animated:PresentAnimatedStateFromRight];
}

- (void)buildScrollView
{
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    
    CGFloat sY = IOS7 ? 20 : 0;
    CGFloat sH = height - sY - kTabBarHeight;
    CGRect rect = CGRectMake(0, sY, width, sH);
    
    UIScrollView *scrollView =
    [[UIScrollView alloc] initWithFrame:rect];
    _scrollView = scrollView;
    [self.view addSubview:scrollView];
}


- (void)isNightView:(MoreTableViewCell *)cell
{
    ThemeMgr *mgr = [ThemeMgr sharedInstance];
    BOOL isNight = [mgr isNightmode];
    [cell.textLabel setHighlightedTextColor:[UIColor grayColor]];
    
    CustomCellBackgroundView *customCellBgView = (CustomCellBackgroundView *)cell.selectedBackgroundView;
    if (isNight)
    {
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell.textLabel setTextColor:[UIColor grayColor]];
        if(customCellBgView)
        {
            customCellBgView.fillColor = [UIColor colorWithHexValue:kTableCellSelectedColor_N];
            [customCellBgView setNeedsDisplay];
        }
    }
    else
    {
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell.textLabel setTextColor:[UIColor grayColor]];
        if(customCellBgView)
        {
            customCellBgView.fillColor = [UIColor colorWithHexValue:kTableCellSelectedColor];
            [customCellBgView setNeedsDisplay];
        }
    }
}
//清除缓存的方法
- (void)calccaches
{
    isCalcing = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void)
                   {
                       double size = [[ThreadsManager sharedInstance] calculateCachesSize] / (1024 * 1024);
                       NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:2 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
                       NSDecimalNumber *ouncesDecimal = [[NSDecimalNumber alloc] initWithFloat:size];
                       NSDecimalNumber *roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
                       dispatch_sync(dispatch_get_main_queue(), ^(void)
                                     {
                                         isCalcing = NO;
                                         cachesSize = [NSString stringWithFormat:@"%@", roundedOunces];
                                         [self updateCachesSize];
                                     });
                   });
}

- (void)updateCachesSize
{
    NSIndexPath *indexPath =[NSIndexPath indexPathForRow:ItemClearCache inSection:Section2];
    MoreTableViewCell *cell = (MoreTableViewCell*)[_tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.text = @"清除缓存";
    [cell showCacheSize:cachesSize];
}

- (void)clearCaches
{
    [PhoneNotification manuallyHideWithIndicator];
    [[ThreadsManager sharedInstance] asynCleanAllCachesWithCompletionHandler:^(BOOL success) {
        if (success) {
            [self calccaches];
            [PhoneNotification autoHideWithText:@"缓存已清除"];
        } else {
            [PhoneNotification autoHideWithText:@"清除缓存失败"];
        }
        [self updateCachesSize];
    }];
}

#pragma mark UserCenterViewCrlDelegate

- (void)quitAccount{
    [accountView setNeedsDisplay];
}

#pragma mark FeedbackViewControllerDelegate
- (void)didFinishi:(FeedbackViewController *)feedbackViewCrl
{
    
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (CLEARCACHE == alertView.tag)
    {
        if (buttonIndex == 1)
        {
            [self clearCaches];
        }
    }
    else if(REMOVEUSERINFO_ALT_TAG == alertView.tag)
    {
        if (buttonIndex == 1)
        {
            UserManager *manager = [UserManager sharedInstance];
            [manager removeUserInfo:nil];
            
            [AppSettings setString:nil forKey:kFlowIndicatior_Usedsum];
            [AppSettings setString:nil forKey:kFlowIndicatior_Balance];
            
            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:StringIsShowMarkLogo];
           
            
   
            
            [self showAllMark];
            
            
            
            //注销用户,发送设备信息到web端
            [[NotificationManager sharedInstance] sendNotifiWithDeviceInfo];
        }
    }
}

#pragma mark OfficialRequstUtilDelegate
- (void)didFinishiUpdate:(iTunesLookupUtil *)offR
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:offR.updateUrl]];
}

#pragma mark UserManagerObserver

-(void)currentUserLoginChanged
{
    [self initTableView];
}

#pragma mark - NightModeChangedDelegate
- (void)nightModeChanged:(BOOL)night
{
    [super nightModeChanged:night];
    

    if (night) {
        UIImage *Nightimage = [UIImage imageNamed:@"moreCellLine_night"];
        [_line1 setImage:Nightimage];
        [_line2 setImage:Nightimage];
        [_line3 setImage:Nightimage];
    }
    else
    {
        UIImage *daytimeImage = [UIImage imageNamed:@"moreCellLine"];
        [_line1 setImage:daytimeImage];
        [_line2 setImage:daytimeImage];
        [_line3 setImage:daytimeImage];
    }
    
    [[_scrollView subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if([obj respondsToSelector:@selector(viewNightModeChanged:)]) {
            [obj viewNightModeChanged:night];
        }
    }];
    
    [[sectionView2 subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if([obj respondsToSelector:@selector(viewNightModeChanged:)]) {
            [obj viewNightModeChanged:night];
        }
    }];
    
    [indicatorCellView viewNightModeChanged:night];
}


- (void)addTaskItem
{
    NSMutableArray *arr0 = [PhotoCollectionManager sharedInstance].photoCollecChannelList;
    
    if (arr0 && arr0.count > 0)
    {
        for (PhotoCollectionChannel *pcC in arr0)
        {
            ImageGalleryTask *Task = [[ImageGalleryTask alloc] init];
            [Task setPhotoCChannel:pcC];
            [[OfflineDownloader sharedInstance] addDownloadTask:Task];
        }
    }
}


@end





@implementation SettingViewController

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

- (void)dealloc
{

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES];
    
    self.title=@"设置";
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initTableView) name:CALLBACK object:nil];
    
    
    [self initSettingTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    cachesSize = nil;
    [self updateCachesSize];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [PhoneNotification hideNotification];
}

- (void)initSettingTableView{
    if (SettingTableView == nil)
    {
        SettingTableView = [[UITableView alloc] initWithFrame:TABLEVIEWFRMAE style:UITableViewStyleGrouped];
        [SettingTableView setDelegate:self];
        [SettingTableView setDataSource:self];
        [SettingTableView setBackgroundColor:[UIColor clearColor]];
        SettingTableView.backgroundView = nil;
        [SettingTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        SettingTableView.separatorColor = [UIColor colorWithHexString:@"e3e2e2"];
        [self.view addSubview:SettingTableView];
    }
    else
    {
        [SettingTableView reloadData];
    }
}

- (void)isNightView:(UITableViewCell *)cell
{
    ThemeMgr *mgr = [ThemeMgr sharedInstance];
    BOOL isNight = [mgr isNightmode];
    CustomCellBackgroundView *customCellBgView = (CustomCellBackgroundView *)cell.selectedBackgroundView;
    
    if (isNight)
    {
        [SettingTableView setBackgroundColor:[UIColor colorWithHexString:@"222223"]];//222223 2D2E2F
        [cell setBackgroundColor:[UIColor blackColor]];
        [cell.selectedBackgroundView setBackgroundColor:[UIColor colorWithHexValue:kTableCellSelectedColor_N]];
        //        [cell.textLabel setHighlightedTextColor:[UIColor grayColor]];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        
        if(customCellBgView)
        {
            customCellBgView.fillColor = [UIColor colorWithHexValue:kTableCellSelectedColor_N];
            [customCellBgView setNeedsDisplay];
        }
    }
    else
    {//[UIColor colorWithHexString:night?@"2D2E2F":@"F8F8F8"];
        [SettingTableView setBackgroundColor:[UIColor colorWithHexString:@"F8F8F8"]];
        [cell setBackgroundColor:[UIColor whiteColor]];
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithHexValue:kTableCellSelectedColor];
        //        [cell.textLabel setHighlightedTextColor:[UIColor grayColor]];
        [cell.textLabel setTextColor:[UIColor grayColor]];
        
        if(customCellBgView)
        {
            customCellBgView.fillColor = [UIColor colorWithHexValue:kTableCellSelectedColor];
            [customCellBgView setNeedsDisplay];
        }
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section) {
        return 3;
    }
    else if (1 == section)
        return 1;
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * cellid = [NSString stringWithFormat:@"cell%@%@", @(indexPath.section), @(indexPath.row)];
    
    MoreTableViewCell * cell = (MoreTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellid];
    
    if (!cell)
    {
        cell = [[MoreTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        [cell.textLabel setBackgroundColor:[UIColor clearColor]];
        [cell.textLabel setFont:[UIFont systemFontOfSize:15]];
    }
    if (IOS7 || IOS8) {
        cell.isIcon = YES;
    }
    else{
        cell.isIcon = NO;
    }
    CustomCellBackgroundViewPosition pos = CustomCellBackgroundViewPositionMiddle;
    
    CustomCellBackgroundView *bkgView = [[CustomCellBackgroundView alloc] initWithFrame:cell.bounds];
    [bkgView setBackgroundColor:[UIColor clearColor]];
    bkgView.borderColor = [UIColor clearColor];
    
    if (indexPath.section==0)
    {
        switch (indexPath.row)
        {
//            case 0:
//                cell.textLabel.text = @"正文图片";
//                [cell showImageModelView];
//                cell.imageView.image = [UIImage imageNamed:@"textImage_logo"];
//                break;
//            case 1:
//                cell.textLabel.text = @"夜间模式";
//                [cell showNightModelView];
//                cell.imageView.image = [UIImage imageNamed:@"night_logo"];
//                cell.selectionStyle = UITableViewCellSelectionStyleNone;
//                break;
            case 0:
                cell.textLabel.text = @"正文字号";
                [cell showTextModelView];
                cell.imageView.image = [UIImage imageNamed:@"textModel_logo"];
                break;
            case 1:
                cell.textLabel.text = @"要闻推送";
                [cell showNotifiSwitchBt];
                cell.imageView.image = [UIImage imageNamed:@"switch_logo"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                break;
            default:
                break;
        }
        
        if (IOS7 || IOS8) {
            pos = CustomCellBackgroundViewPositionMiddle;
        }
        else{
            pos = CustomCellBackgroundViewPositionTop;
        }
    }
    else if(1 == indexPath.section)
    {
        cell.textLabel.text = @"清除缓存";
        [self calccaches];
        cell.imageView.image = [UIImage imageNamed:@"calccaches_logo"];
    }
    
    bkgView.position = pos;
    [cell setSelectedBackgroundView: bkgView];
    
    
    [self isNightView:cell];
    
    [cell.textLabel setFrame:CGRectMake(30.0f, 0.0f, 300.0f, 51.0f)];
    
    return cell;
}

- (void)calccaches
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void)
                   {
                       double size = [[ThreadsManager sharedInstance] calculateCachesSize] / (1024 * 1024);
                       NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:2 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
                       NSDecimalNumber *ouncesDecimal = [[NSDecimalNumber alloc] initWithFloat:size];
                       NSDecimalNumber *roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
                       dispatch_sync(dispatch_get_main_queue(), ^(void)
                                     {
                                         cachesSize = [NSString stringWithFormat:@"%@", roundedOunces];
                                         [self updateCachesSize];
                                     });
                   });
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (1 == indexPath.section) {
        if (0 == indexPath.row) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"除收藏夹以外的本地缓存将被清除，确认继续？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认" , nil];
            [alertView setTag:CLEARCACHE];
            [alertView show];
        }
    }
    else if (0 == indexPath.section){
        if (IOS7) {
//            if (0 == indexPath.row){
//                ModelSettingViewController *modelViewCrl = [ModelSettingViewController new];
//                [modelViewCrl setModelEnum:IMGAE_ENUM];
//                [self presentController:modelViewCrl animated:PresentAnimatedStateFromRight];
//            }
          
                if (0 == indexPath.row){
                ModelSettingViewController *modelViewCrl = [ModelSettingViewController new];
                [modelViewCrl setModelEnum:TEXT_ENUM];
                [self presentController:modelViewCrl animated:PresentAnimatedStateFromRight];
            }
        }
    }
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (CLEARCACHE == alertView.tag)
    {
        if (buttonIndex == 1)
        {
            [self clearCaches];
        }
    }
}

- (void)clearCaches
{
    [PhoneNotification manuallyHideWithIndicator];
    [[ThreadsManager sharedInstance] asynCleanAllCachesWithCompletionHandler:^(BOOL success) {
        if (success) {
            [self calccaches];
            [PhoneNotification autoHideWithText:@"缓存已清除"];
        } else {
            [PhoneNotification autoHideWithText:@"清除缓存失败"];
        }
        [self updateCachesSize];
    }];
}

- (void)updateCachesSize
{
    NSIndexPath *indexPath =[NSIndexPath indexPathForRow:0 inSection:1];
    MoreTableViewCell *cell = (MoreTableViewCell*)[SettingTableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.text = @"清除缓存";
    [cell showCacheSize:cachesSize];
    
    // 向文件中写入已清空缓存
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([cachesSize isEqualToString:@"0"]) {
        [userDefaults setBool:NO forKey:@"hasCache"];
        [userDefaults synchronize];
    }
}

#pragma mark - NightModeChangedDelegate
- (void)nightModeChanged:(BOOL)night
{
    [super nightModeChanged:night];
    [self initSettingTableView];
    
    
    
}

@end



@interface ProductInfoController ()

@end

@implementation ProductInfoController

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES];
    self.title=@"产品信息";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initProductInfoTableView) name:CALLBACK object:nil];
    
    [self initProductInfoTableView];
}

- (void)initProductInfoTableView
{
    if (productInfoTableView == nil)
    {
        productInfoTableView = [[UITableView alloc] initWithFrame:TABLEVIEWFRMAE style:UITableViewStyleGrouped];
        [productInfoTableView setDelegate:self];
        [productInfoTableView setDataSource:self];
        [productInfoTableView setBackgroundColor:[UIColor clearColor]];
        productInfoTableView.backgroundView = nil;
        [productInfoTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        productInfoTableView.separatorColor = [UIColor colorWithHexString:@"e3e2e2"];
        
        [self.view addSubview:productInfoTableView];
    }
    else
    {
        [productInfoTableView reloadData];
    }
}

- (void)isNightView:(UITableViewCell *)cell
{
    ThemeMgr *mgr = [ThemeMgr sharedInstance];
    BOOL isNight = [mgr isNightmode];
    CustomCellBackgroundView *customCellBgView = (CustomCellBackgroundView *)cell.selectedBackgroundView;
    
    if (isNight)
    {
        [productInfoTableView setBackgroundColor:[UIColor colorWithHexString:@"2D2E2F"]];
        [cell setBackgroundColor:[UIColor colorWithRed:27/255.0f green:27/255.0f blue:28/255.0f alpha:1]];
        [cell.selectedBackgroundView setBackgroundColor:[UIColor colorWithHexValue:kTableCellSelectedColor_N]];
        //        [cell.textLabel setHighlightedTextColor:[UIColor grayColor]];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        
        
        if(customCellBgView)
        {
            customCellBgView.fillColor = [UIColor colorWithHexValue:kTableCellSelectedColor_N];
            [customCellBgView setNeedsDisplay];
        }
    }
    else
    {//[UIColor colorWithHexString:night?@"2D2E2F":@"F8F8F8"]
        [productInfoTableView setBackgroundColor:[UIColor colorWithHexString:@"F8F8F8"]];
        [cell setBackgroundColor:[UIColor whiteColor]];
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithHexValue:kTableCellSelectedColor];
        //        [cell.textLabel setHighlightedTextColor:[UIColor grayColor]];
        [cell.textLabel setTextColor:[UIColor grayColor]];
        
        if(customCellBgView)
        {
            customCellBgView.fillColor = [UIColor colorWithHexValue:kTableCellSelectedColor];
            [customCellBgView setNeedsDisplay];
        }
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#ifdef ENTERPRISE
    return 5;
#else
    return 4;
#endif
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * cellid = [NSString stringWithFormat:@"cell%@%@", @(indexPath.section), @(indexPath.row)];
    
    MoreTableViewCell * cell = (MoreTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellid];
    
    if (!cell)
    {
        cell = [[MoreTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        [cell.textLabel setBackgroundColor:[UIColor clearColor]];
        [cell.textLabel setFont:[UIFont systemFontOfSize:15]];
    }
    if (IOS7) {
        cell.isIcon=YES;
    }
    else{
        cell.isIcon=NO;
    }
    CustomCellBackgroundViewPosition pos = CustomCellBackgroundViewPositionMiddle;
    
    CustomCellBackgroundView *bkgView = [[CustomCellBackgroundView alloc] initWithFrame:cell.bounds];
    [bkgView setBackgroundColor:[UIColor clearColor]];
    bkgView.borderColor = [UIColor clearColor];
    
    if (indexPath.section==0)
    {
        switch (indexPath.row)
        {
#ifdef ENTERPRISE
            case 0:
                cell.textLabel.text = @"检查更新";
                cell.imageView.image = [UIImage imageNamed:@"update_logo"];
                break;
            case 1:
                cell.textLabel.text = @"新手向导";
                cell.imageView.image = [UIImage imageNamed:@"guide_logo"];
                break;
            case 2:
                cell.textLabel.text = @"反恐举报";
                cell.imageView.image = [UIImage imageNamed:@"itemMilitary_logo"];
                break;
            case 3:
                cell.textLabel.text = @"评分";
                cell.imageView.image = [UIImage imageNamed:@"review_logo"];
                break;
            case 4:
                cell.textLabel.text = @"关于";
                cell.imageView.image = [UIImage imageNamed:@"about_logo"];
                break;
#else
            case 0:
                cell.textLabel.text = @"新手向导";
                cell.imageView.image = [UIImage imageNamed:@"guide_logo"];
                break;
            case 1:
                cell.textLabel.text = @"评分";
                cell.imageView.image = [UIImage imageNamed:@"review_logo"];
                break;
            case 2:
                cell.textLabel.text = @"关于";
                cell.imageView.image = [UIImage imageNamed:@"about_logo"];
                break;
            case 3:
                cell.textLabel.text = @"反恐举报";
                cell.imageView.image = [UIImage imageNamed:@"itemMilitary_logo"];
                break;

#endif
            default:
                break;
        }
        
        if (IOS7) {
            pos = CustomCellBackgroundViewPositionMiddle;
            [cell showRightMarkImage];
        }
        else
            if(indexPath.row == 0)
                pos = CustomCellBackgroundViewPositionTop;
            else if(indexPath.row == Section1ItemsCount - 1)
                pos = CustomCellBackgroundViewPositionBottom;
        
    }
    
    bkgView.position = pos;
    [cell setSelectedBackgroundView: bkgView];
    
    [self isNightView:cell];
    
#ifdef ENTERPRISE
    [self refreshUpdateCell:cell andIndex:indexPath];
#endif
    
    [cell.textLabel setFrame:CGRectMake(30.0f, 0.0f, 300.0f, 51.0f)];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
#ifdef ENTERPRISE
    if (indexPath.row == ItemCheckNewVersion)
    {
        //检查更新
        if ([iTunesLookupUtil sharedInstance].isLoading)
        {
            //后台正在检测中，不响应操作
            return;
        }
        else
        {
            if ([iTunesLookupUtil sharedInstance].isError)
            {
                [iTunesLookupUtil sharedInstance].isMT = YES;
                [[iTunesLookupUtil sharedInstance] checkUpdate];
            }
            else
            {
                if ([iTunesLookupUtil sharedInstance].hasNewVersion)
                {
                    //#ifdef ENTERPRISE
                    if ([iTunesLookupUtil sharedInstance].enterpriseStr) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[iTunesLookupUtil sharedInstance].enterpriseStr]];
                    }
                    //#else
                    //                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/cn/app/sandman/id%d?mt=8",kAppAppleId]]];
                    //#endif
                }
                else
                {
                    [iTunesLookupUtil sharedInstance].isMT = YES;
                    [[iTunesLookupUtil sharedInstance] checkUpdate];
                }
            }
        }
    }
    else if(indexPath.row == ItemNewbeeGuide)
    {//新手向导
        GuideView *view = [[GuideView alloc] initWithFrame:theApp.rootController.view.frame];
        [view setAnimating:YES];
        [view setBackgroundColor:[UIColor clearColor]];
        [self.view.window addSubview:view];
    }
    else if(indexPath.row == ItemReview)
    {//评分
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/cn/app/sandman/id%d?mt=8",kAppAppleId]]];
    }
    else if(ItemAbout == indexPath.row)
    {
        AboutViewController *aboutViewCrl = [[AboutViewController alloc] init];
        aboutViewCrl.title = @"关于";
        [self presentController:aboutViewCrl animated:PresentAnimatedStateFromRight];
    }
    else if(ItemMilitary == indexPath.row)
    {
        ThreadSummary* ts = [ThreadSummary new];
        ts.newsUrl = kMilitaryUrl;
        ts.webView = 1;
        SNThreadViewerController* vv = [[SNThreadViewerController alloc] initWithThread:ts];
        [self presentController:vv animated:PresentAnimatedStateFromRight];
    }
    

#else
    
    if(indexPath.row == ItemNewbeeGuide)
    {//新手向导
        GuideView *view = [[GuideView alloc] initWithFrame:theApp.rootController.view.frame];
        [view setAnimating:YES];
        [view setBackgroundColor:[UIColor clearColor]];
        [self.view.window addSubview:view];
    }
    else if(indexPath.row == ItemReview)
    {//评分
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/cn/app/sandman/id%d?mt=8",kAppAppleId]]];
    }
    else if(ItemAbout == indexPath.row)
    {
        AboutViewController *aboutViewCrl = [[AboutViewController alloc] init];
        aboutViewCrl.title = @"关于";
        [self presentController:aboutViewCrl animated:PresentAnimatedStateFromRight];
    }
    else if(ItemMilitary == indexPath.row)
    {
        ThreadSummary* ts = [ThreadSummary new];
        ts.newsUrl = kMilitaryUrl;
        ts.webView = 1;
        SNThreadViewerController* vv = [[SNThreadViewerController alloc] initWithThread:ts];
        [self presentController:vv animated:PresentAnimatedStateFromRight];
    }
    
#endif
    
}

- (void)refreshUpdateCell:(MoreTableViewCell *)cell andIndex:(NSIndexPath *) indexPath
{
    if (0 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            if ([iTunesLookupUtil sharedInstance].isLoading)
            {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                lab = [[UILabel alloc] initWithFrame:CGRectMake(110, 20, 100, 20)];
                [lab setTag:87878];
                [lab setBackgroundColor:[UIColor clearColor]];
                [lab setText:@"检测中..."];
                [lab setFont:[UIFont systemFontOfSize:12]];
                [lab setTextAlignment:NSTextAlignmentCenter];
                [cell.contentView addSubview:lab];
            }
            else
            {
                [lab removeFromSuperview];
                
                BOOL b = [iTunesLookupUtil sharedInstance].hasNewVersion;
                if (b)
                {
                    [cell showUpdateSign];
                }
            }
        }
    }
}



#pragma mark - NightModeChangedDelegate
-(void) nightModeChanged:(BOOL) night
{
    [super nightModeChanged:night];
    
}


@end




@implementation UserCenterViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.titleState = PhoneSurfControllerStateTop;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    [self.navigationController setNavigationBarHidden:YES];
    self.title=@"我的资料";

    [self initTableView];
    
    UIButton *quitBt = [UIButton buttonWithType:UIButtonTypeCustom];
    quitBt.frame = CGRectMake(2.0f, 405.0f, 300.0f, 35.0f);
    //[quitBt setBackgroundImage:[UIImage imageNamed:@"login_register_button.png"] forState:UIControlStateNormal];
    quitBt.layer.borderWidth = 0.4f;
    quitBt.layer.borderColor = [UIColor grayColor].CGColor;
    quitBt.layer.masksToBounds = YES;
    quitBt.layer.cornerRadius = 5.0f;
    [quitBt setTitle:@"退出当前账号" forState:UIControlStateNormal];
    [quitBt setTitleColor:[UIColor
                           blackColor]
                      forState:UIControlStateNormal];
    [quitBt.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    [quitBt addTarget:self action:@selector(didQuitBt) forControlEvents:UIControlEventTouchUpInside];
    [userTableView addSubview:quitBt];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (userTableView) {
        [userTableView reloadData];
    }
}

- (NSString *)levelStr:(NSString *)lvlStr{
    NSString *str1 = [lvlStr substringFromIndex:2];
    NSUInteger lvl_int = [str1 integerValue];
    switch (lvl_int) {
        case 1:
            return @"实习生";
            break;
        case 2:
            return @"试用期";
            break;
        case 3:
            return @"职场新人";
            break;
        case 4:
            return @"助理";
            break;
        case 5:
            return @"见习主管";
            break;
        case 6:
            return @"主管";
            break;
        case 7:
            return @"初级经理";
            break;
        case 8:
            return @"中级经理";
            break;
        case 9:
            return @"高级经理";
            break;
        case 10:
            return @"部门总监";
            break;
        case 11:
            return @"区域总监";
            break;
        case 12:
            return @"部门总裁";
            break;
        case 13:
            return @"区域总裁";
            break;
        case 14:
            return @"副总裁";
            break;
            
        default:
            return nil;
            break;
    }
}


- (void)initTableView{
    if (userTableView == nil)
    {
        userTableView = [[UITableView alloc] initWithFrame:TABLEVIEWFRMAE2 style:UITableViewStyleGrouped];
        [userTableView setDelegate:self];
        [userTableView setDataSource:self];
        [userTableView setBackgroundColor:[UIColor clearColor]];
        userTableView.backgroundView = nil;
        [userTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        userTableView.separatorColor = [UIColor colorWithHexString:@"e3e2e2"];
        userTableView.showsVerticalScrollIndicator = NO;
        userTableView.separatorInset = UIEdgeInsetsMake(0, self.view.frame.size.width, 0, 0);//距左右边距,其实这里作用就是让Section里面的分割线消失
        [self.view addSubview:userTableView];
    }
    else
    {
        [userTableView reloadData];
    }
}


- (void)isNightView:(UITableViewCell *)cell
{
    ThemeMgr *mgr = [ThemeMgr sharedInstance];
    BOOL isNight = [mgr isNightmode];
    CustomCellBackgroundView *customCellBgView = (CustomCellBackgroundView *)cell.selectedBackgroundView;
    if (isNight)
    {
        [userTableView setBackgroundColor:[UIColor colorWithHexString:@"222223"]];
        [cell setBackgroundColor:[UIColor blackColor]];
        [cell.selectedBackgroundView setBackgroundColor:[UIColor colorWithHexValue:kTableCellSelectedColor_N]];
        [cell.textLabel setTextColor:[UIColor whiteColor]];

        if(customCellBgView)
        {
            customCellBgView.fillColor = [UIColor colorWithHexValue:kTableCellSelectedColor_N];
            [customCellBgView setNeedsDisplay];
        }
    }
    else
    {
        [userTableView setBackgroundColor:[UIColor clearColor]];//colorWithHexString:@"F8F8F8"
        [cell setBackgroundColor:[UIColor whiteColor]];
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithHexValue:kTableCellSelectedColor];
        [cell.textLabel setTextColor:[UIColor blackColor]];

        if(customCellBgView)
        {
            customCellBgView.fillColor = [UIColor colorWithHexValue:kTableCellSelectedColor];
            [customCellBgView setNeedsDisplay];
        }
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 15;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (User_Section0 == section)
        return 2;
    else if (User_Section1 == section)
        return 2;
    else if (User_Section2 == section)
        return 1;
    else if (User_Section3 == section)
        return 2;
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (User_Section0 == indexPath.section)
        if (indexPath.row == User_Rportrait)
            return 80;
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * cellid = [NSString stringWithFormat:@"cell%@%@", @(indexPath.section), @(indexPath.row)];
    
    UserCenterTableCell * cell = (UserCenterTableCell *)[tableView dequeueReusableCellWithIdentifier:cellid];
    
    if (!cell)
    {
        cell = [[UserCenterTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        [cell.textLabel setBackgroundColor:[UIColor clearColor]];
        [cell.textLabel setFont:[UIFont systemFontOfSize:14]];
    }
    
    CustomCellBackgroundViewPosition pos = CustomCellBackgroundViewPositionMiddle;
    
    CustomCellBackgroundView *bkgView = [[CustomCellBackgroundView alloc] initWithFrame:cell.bounds];
    [bkgView setBackgroundColor:[UIColor clearColor]];
    bkgView.borderColor = [UIColor clearColor];
    
    UserInfo *userInfo = [[UserManager sharedInstance] loginedUser];
    if (indexPath.section == User_Section0)
    {
        switch (indexPath.row)
        {
            case User_Rportrait:
                cell.textLabel.text = @"头像";
                [cell showHeadPic];
                pos = CustomCellBackgroundViewPositionTop;
                
                break;
            case User_NickName:
                cell.textLabel.text = @"昵称";
                if (userInfo.userDes.nickName) {
                    [cell setDesLab:userInfo.userDes.nickName];
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(278, 16, 12, 12)];
                    UIImage *image = [UIImage imageNamed:@"EditPerson"];
                    imageView.image = image;
                    [cell.contentView addSubview:imageView];
                }
                pos = CustomCellBackgroundViewPositionBottom;

                break;
            
            default:
                break;
        }
        
        if (IOS7) {
            pos = CustomCellBackgroundViewPositionMiddle;
        }

    }
    else if(User_Section1 == indexPath.section)
    {
        switch (indexPath.row)
        {
            case User_Sex:
                cell.textLabel.text = @"性别";
                if (userInfo.userDes.sex) {
                    [cell setDesLab:[userInfo.userDes.sex integerValue]?@"女":@"男"];
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(278, 15, 12, 12)];
                    UIImage *image = [UIImage imageNamed:@"EditPerson"];
                    imageView.image = image;
                    [cell.contentView addSubview:imageView];
                }
                
                if (IOS7)
                    pos = CustomCellBackgroundViewPositionMiddle;
                else
                    pos = CustomCellBackgroundViewPositionTop;

                break;
            case User_CellNum:
                cell.selectionStyle = UITableViewCellSelectionStyleNone;

                cell.textLabel.text = @"手机号";
                if (userInfo.phoneNum) {
                    [cell setDesLabPhone:userInfo.phoneNum];
                    //[cell setDesLab:userInfo.phoneNum];
                }
                
                break;
                
            default:
                break;
        }
    }
    else if (User_Section2 == indexPath.section){
        if (User_Experience == indexPath.row) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            cell.textLabel.text = @"我的经验值";
            
            if (userInfo.userDes.credit) {
                [cell setDesLabExp:userInfo.userDes.credit];
               // [cell setDesLab:userInfo.userDes.credit];
            }
        }
    }
    else if (User_Section3 == indexPath.section){
        if (User_Level == indexPath.row) {
            cell.textLabel.text = @"我的等级";
            if (userInfo.userDes.lvl) {
                [cell setDesLablevel:userInfo.userDes.lvl];
                
                [cell setDesLabInfo:[self levelStr:userInfo.userDes.lvl]];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            else if (User_LevelInfo == indexPath.row) {
                cell.textLabel.text = @"等级说明";
                //[cell performSelector:@selector(levelInfo:) withObject:nil afterDelay:0];
                UIImageView *rightView = [[UIImageView alloc] initWithFrame:CGRectMake(265, 3, 35, 35)];
                UIImage *rightView1 =[UIImage imageNamed:@"news_Right"];
                rightView.image = rightView1;
                [cell.contentView  addSubview:rightView];
        }

    }
    
    
    bkgView.position = pos;
    [cell setSelectedBackgroundView: bkgView];
    [self isNightView:cell];
    [cell.textLabel setFrame:CGRectMake(30.0f, 0.0f, 300.0f, 51.0f)];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == User_Section0)
    {
        switch (indexPath.row)
        {
            case User_Rportrait:{
                [self showUserAlertView:0];
            }
                break;
            case User_NickName:{
                ModifyNickNameViewController *modelViewCrl = [ModifyNickNameViewController new];
                [self presentController:modelViewCrl animated:PresentAnimatedStateFromRight];
            }
                break;
                
            default:
                break;
        }

    }
    else if(User_Section1 == indexPath.section)
    {
        switch (indexPath.row)
        {
            case User_Sex:{
                [self showUserAlertView:1];
            }
                break;
            case User_CellNum:
                
                break;
                
            default:
                break;
        }
    }
    else if (User_Section2 == indexPath.section){
        if (User_Experience == indexPath.row) {

        }
    }
    else if (User_Section3 == indexPath.section){
        if (User_Level == indexPath.row) {
           
            
        }
        else if (User_LevelInfo == indexPath.row) {
        //跳转等级说明的URL
        LevelInfoViewController *Wb = [[LevelInfoViewController alloc] init];
        [self presentController:Wb animated:PresentAnimatedStateFromRight];
        }
    }
}

- (void)didQuitBt{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确定要注销吗?" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认" , nil];
    [alertView setTag:REMOVEUSERINFO_ALT_TAG];
    [alertView show];

}

- (void)showUserAlertView:(NSUInteger)index{
    if (!bgView) {
        bgView = [[UIView alloc] initWithFrame:self.view.bounds];
        [bgView setBackgroundColor:[UIColor blackColor]];
        [bgView setAlpha:0.6];

    }
    if (![self.view.subviews containsObject:bgView]) {
        [self.view addSubview:bgView];
    }
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(UserClicked)];
    [bgView addGestureRecognizer:singleTap];
    
    if (0 == index) {
        userAlertView = [[UserAlertView alloc] initWithFrame:CGRectMake(0, 0, 300, 200) WithUserAlert_Type:User_Rportrait_Type];
        userAlertView.center = bgView.center;
        [userAlertView setDelegate:self];
        [self.view addSubview:userAlertView];
    }
    else{
        userAlertView = [[UserAlertView alloc] initWithFrame:CGRectMake(0, 0, 300, 200) WithUserAlert_Type:User_Sex_Type];
        userAlertView.center = bgView.center;
        [userAlertView setDelegate:self];
        [self.view addSubview:userAlertView];
    }
}

- (void)UserClicked{
    [userAlertView removeFromSuperview];
    userAlertView = nil;
    [bgView removeFromSuperview];
    bgView = nil;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        
        UserManager *manager = [UserManager sharedInstance];
        [manager removeUserInfo:nil];
        
        [AppSettings setString:nil forKey:kFlowIndicatior_Usedsum];
        [AppSettings setString:nil forKey:kFlowIndicatior_Balance];
        
        if ([_delegate respondsToSelector:@selector(quitAccount)]) {
            [_delegate quitAccount];
        }
        
        [self dismissBackController];
    }
}


#pragma mark UserCenterTableCellDelegate
- (void)didQuitBt:(id)sender{
    [self didQuitBt];
}

#pragma mark UserAlertViewDelegate

- (void)didAlertBt:(NSUInteger)index andAlert_Type:(UserAlert_Type)type{
    if (type == User_Rportrait_Type) {
        if (0 == index) {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            imagePicker.allowsEditing = YES;
            
            [self presentViewController:imagePicker animated:NO completion:nil ];
        }
        else{
            cameraViewCrl = [[CameraViewController alloc] init];
            [cameraViewCrl setDelegate:self];
            [self presentViewController:cameraViewCrl animated:YES completion:^{}];
        }
    }
    else{
        
    }
}

- (void)removeAlertView:(UserAlertView *)sendler{
    [self UserClicked];
    
    [userTableView reloadData];

}

#pragma mark CameraViewControllerDelegate
- (void)chooseImage:(UIImage *)chooseImage{
    [self UserClicked];
    [self saveImage:chooseImage WithName:[PathUtil pathUserHeadPic]];
    UIImageWriteToSavedPhotosAlbum(chooseImage, self, @selector(saveImagecompletion:didFinishSavingWithError:contextInfo:), nil);

    [userTableView reloadData];
    
}

#pragma mark UIImagePickerControllerDelegate
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image= [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    CGSize size = CGSizeMake(80, 80);
    UIImage *floatingViewBgImg = [FileUtil scaleToSize:image size:size];
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
//        UIImageWriteToSavedPhotosAlbum(floatingViewBgImg, self, @selector(saveImagecompletion:didFinishSavingWithError:contextInfo:), nil);

    }
    else if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary){
        [[UserManager sharedInstance] uploadHeadPic:floatingViewBgImg WithCompletionHandler:^(BOOL succeeded, NSDictionary *dicData) {
            if (succeeded) {
                [PhoneNotification autoHideWithText:@"上传成功"];
                [self UserClicked];
                [self saveImage:floatingViewBgImg WithName:[PathUtil pathUserHeadPic]];
                
                [picker dismissViewControllerAnimated:YES completion:^{
                    
                }];
            }
            else{
                [PhoneNotification autoHideWithText:@"上传失败"];
            }
        }];
    }
}

//保存图片到本地
- (void)saveImage:(UIImage *)tempImage WithName:(NSString *)imageName
{
    NSData* imageData = UIImagePNGRepresentation(tempImage);
    [imageData writeToFile:imageName atomically:NO];
}

//保存到图片库
- (void)saveImagecompletion:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL)
        [PhoneNotification autoHideWithText:@"保存失败！"];
    else
        [PhoneNotification autoHideWithText:@"保存成功！"];
}

@end


@implementation UserCenterTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
 
    [self.textLabel setFrame:CGRectMake(20.0f, self.contentView.bounds.size.height / 2 - 20, 100, 40)];
//    self.backgroundView.frame = CGRectMake(40.0f, 0.0f, 302.0f, 44.0f);
//    self.selectedBackgroundView .frame = CGRectMake(40.0f, 0.0f, 302.0f, 44.0f);
}

- (void)showQuitBt{    
    UIButton *quitBt = [UIButton buttonWithType:UIButtonTypeCustom];
    quitBt.frame = CGRectMake(10.0f, 0, 300.0f, 40.0f);
    quitBt.center = CGPointMake(self.center.x, self.center.y);
    [quitBt setBackgroundImage:[UIImage imageNamed:@"login_register_button.png"] forState:UIControlStateNormal];
    [quitBt setTitle:@"退出当前账号" forState:UIControlStateNormal];
    [quitBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [quitBt.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    [quitBt addTarget:self action:@selector(didQuitBt) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:quitBt];
}

- (void)showHeadPic{
    if (!headPicImageView) {
        headPicImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.contentView.bounds.size.width - 90, 10, 60, 60)];
        headPicImageView.layer.masksToBounds = YES;
        headPicImageView.layer.cornerRadius = headPicImageView.frame.size.height/2;
        [self.contentView addSubview:headPicImageView];
    }
    
    if ([FileUtil fileExists:[PathUtil pathUserHeadPic]]) {
        UIImage *iconImage = [UIImage imageWithContentsOfFile:[PathUtil pathUserHeadPic]];
        [headPicImageView setImage:iconImage];
    }
    else {
       
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"headPicImageNew" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:filepath];
    [headPicImageView setImage:image];
            //默认的用户登录的头像
        
    }
}

- (void)didQuitBt{
    if ([_delegate respondsToSelector:@selector(didQuitBt:)]) {
        [_delegate didQuitBt:self];
    }
}

- (void)setDesLab:(NSString *)desStr
{
    CGFloat width = CGRectGetWidth(self.contentView.bounds);
    if (!desLab) {
        desLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 40)];
        [desLab setBackgroundColor:[UIColor clearColor]];
        [desLab setFont:[UIFont systemFontOfSize:13]];
        [desLab setTextColor:[UIColor blackColor]];
        [self.contentView addSubview:desLab];
    }
    [desLab setText:desStr];
    [desLab sizeToFit];
    
   CGPoint centerP = self.contentView.center;
    centerP.x = width - CGRectGetWidth(desLab.bounds)/2 - 50;
    desLab.center = centerP;
}
- (void)setDesLabInfo:(NSString *)desStr {

    CGFloat width = CGRectGetWidth(self.contentView.bounds);
    if (!desLabInfo) {
        desLabInfo = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 40)];
        [desLabInfo setBackgroundColor:[UIColor clearColor]];
        [desLabInfo setFont:[UIFont systemFontOfSize:13]];
        [desLabInfo setTextColor:[UIColor blackColor]];
        [self.contentView addSubview:desLabInfo];
    }
    [desLabInfo setText:desStr];
    [desLabInfo sizeToFit];
    
    CGPoint centerP = self.contentView.center;
    centerP.x = width - CGRectGetWidth(desLabInfo.bounds)/2 - 32;
    desLabInfo.center = centerP;

}
- (void)setDesLablevel:(NSString *)desStr {
    CGFloat width = CGRectGetWidth(self.contentView.bounds);
    if (!desLab) {
        desLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 40)];
        [desLab setBackgroundColor:[UIColor clearColor]];
        [desLab setFont:[UIFont systemFontOfSize:13]];
        [desLab setTextColor:[UIColor blackColor]];
        desLab.textColor = [UIColor colorWithHexValue:0xffad2f2f];
        [self.contentView addSubview:desLab];
    }
    [desLab setText:desStr];
    [desLab sizeToFit];
    
    CGPoint centerP = self.contentView.center;
    centerP.x = width - CGRectGetWidth(desLab.bounds)/2 - 88;
    desLab.center = centerP;

    
}
- (void)setDesLabExp:(NSString *)desStr {

    CGFloat width = CGRectGetWidth(self.contentView.bounds);
    if (!desLab) {
        desLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 40)];
        [desLab setBackgroundColor:[UIColor clearColor]];
        [desLab setFont:[UIFont systemFontOfSize:13]];
        [desLab setTextColor:[UIColor grayColor]];
        desLab.textColor = [UIColor colorWithHexValue:0xffad2f2f];
        [self.contentView addSubview:desLab];
    }
    [desLab setText:desStr];
    [desLab sizeToFit];
    
    CGPoint centerP = self.contentView.center;
    centerP.x = width - CGRectGetWidth(desLab.bounds)/2 - 40;
    desLab.center = centerP;
    
}
- (void)setDesLabPhone:(NSString *)desStr {
    
        CGFloat width = CGRectGetWidth(self.contentView.bounds);
        if (!desLab) {
            desLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 40)];
            [desLab setBackgroundColor:[UIColor clearColor]];
            [desLab setFont:[UIFont systemFontOfSize:13]];
            [desLab setTextColor:[UIColor grayColor]];
            [self.contentView addSubview:desLab];
            //desLab.textColor = [UIColor grayColor];
            desLab.alpha = 0.7f;
        }
        [desLab setText:desStr];
        [desLab sizeToFit];
        
        CGPoint centerP = self.contentView.center;
        centerP.x = width - CGRectGetWidth(desLab.bounds)/2 - 25;
        desLab.center = centerP;
}
@end


@implementation UserAlertView
//“个人资料”页面点击事件
- (id)initWithFrame:(CGRect)frame WithUserAlert_Type:(UserAlert_Type)AlertType{
    self = [super initWithFrame:frame];
    if (self){
        alert_Type_ = AlertType;
        
        UIView *bgView = [[UIView alloc] initWithFrame:self.bounds];
        [bgView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:bgView];
        
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 50)];
        [titleLab setBackgroundColor:[UIColor clearColor]];
        [titleLab setFont:[UIFont boldSystemFontOfSize:18]];
        [titleLab setTextColor:[UIColor blackColor]];
        [bgView addSubview:titleLab];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 51, self.bounds.size.width, 1)];
        [line setBackgroundColor:[UIColor colorWithHexValue:kTableCellSelectedColor]];
        [bgView addSubview:line];
        
        if (User_Rportrait == alert_Type_) {
            [titleLab setText:@"更换头像"];
            
            UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, (self.bounds.size.height - 51) / 2 + 50, self.bounds.size.width, 1)];
            [line2 setBackgroundColor:[UIColor colorWithHexValue:kTableCellSelectedColor]];
            [bgView addSubview:line2];
            
            UIView *bg2 = [[UIView alloc] initWithFrame:CGRectMake(0, 52, self.bounds.size.width, (self.bounds.size.height - 51) / 2 - 2)];
            [bg2 setBackgroundColor:[UIColor clearColor]];
            [bgView addSubview:bg2];
            
            UIView *bg3 = [[UIView alloc] initWithFrame:CGRectMake(0, (self.bounds.size.height - 51) / 2 + 51, self.bounds.size.width, (self.bounds.size.height - 51) / 2 - 1)];
            [bg3 setBackgroundColor:[UIColor clearColor]];
            [bgView addSubview:bg3];
            
            
            UIImageView *iconImageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, 30, 30)];
            [iconImageView1 setImage:[UIImage imageNamed:@"photo_icon"]];
            [bg2 addSubview:iconImageView1];
            
            UIImageView *iconImageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, 30, 30)];
            [iconImageView2 setImage:[UIImage imageNamed:@"camera_icon"]];
            [bg3 addSubview:iconImageView2];
            
            UILabel *title1 = [[UILabel alloc] initWithFrame:CGRectMake(70, 0, 100, (self.bounds.size.height - 51) / 2 - 2)];
            [title1 setBackgroundColor:[UIColor clearColor]];
            [title1 setFont:[UIFont systemFontOfSize:15]];
            [title1 setTextColor:[UIColor grayColor]];
            [title1 setTextAlignment:NSTextAlignmentLeft];
            [title1 setText:@"相册"];
            [bg2 addSubview:title1];
            
            UILabel *title2 = [[UILabel alloc] initWithFrame:CGRectMake(70, 0, 100, (self.bounds.size.height - 51) / 2 - 2)];
            [title2 setBackgroundColor:[UIColor clearColor]];
            [title2 setFont:[UIFont systemFontOfSize:15]];
            [title2 setTextColor:[UIColor grayColor]];
            [title2 setTextAlignment:NSTextAlignmentLeft];
            [title2 setText:@"拍照"];
            [bg3 addSubview:title2];
            
            UIButton *bt1 = [UIButton buttonWithType:UIButtonTypeCustom];
            [bt1 setFrame:bg2.bounds];
            [bt1 setTag:0];
            [bt1 setBackgroundColor:[UIColor clearColor]];
            [bt1 addTarget:self action:@selector(clickBt:) forControlEvents:UIControlEventTouchUpInside];
            [bg2 addSubview:bt1];
            
            UIButton *bt2 = [UIButton buttonWithType:UIButtonTypeCustom];
            [bt2 setFrame:bg3.bounds];
            [bt2 setTag:1];
            [bt2 setBackgroundColor:[UIColor clearColor]];
            [bt2 addTarget:self action:@selector(clickBt:) forControlEvents:UIControlEventTouchUpInside];
            [bg3 addSubview:bt2];
        }
        else{
            [titleLab setText:@"更换性别"];
            
            UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, (self.bounds.size.height - 51) / 3 + 50, self.bounds.size.width, 1)];
            [line2 setBackgroundColor:[UIColor colorWithHexValue:kTableCellSelectedColor]];
            [bgView addSubview:line2];
            
            UIView *line3 = [[UIView alloc] initWithFrame:CGRectMake(0, (self.bounds.size.height - 51) / 3 + 100, self.bounds.size.width, 1)];
            [line3 setBackgroundColor:[UIColor colorWithHexValue:kTableCellSelectedColor]];
            [bgView addSubview:line3];
            
            
            UIView *bg2 = [[UIView alloc] initWithFrame:CGRectMake(0, 52, self.bounds.size.width, (self.bounds.size.height - 51) / 3 - 2)];
            [bg2 setBackgroundColor:[UIColor clearColor]];
            [bgView addSubview:bg2];
            
            UIView *bg3 = [[UIView alloc] initWithFrame:CGRectMake(0, (self.bounds.size.height - 51) / 3 * 2 + 1, self.bounds.size.width, (self.bounds.size.height - 51) / 3 - 1)];
            [bg3 setBackgroundColor:[UIColor clearColor]];
            [bgView addSubview:bg3];
            
            UIView *bg4 = [[UIView alloc] initWithFrame:CGRectMake(0, (self.bounds.size.height - 51) / 3 * 3 + 1, self.bounds.size.width, (self.bounds.size.height - 51) / 3 - 1)];
            [bg4 setBackgroundColor:[UIColor clearColor]];
            [bgView addSubview:bg4];
            
            UIButton *cancelBt = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [cancelBt setFrame:CGRectMake(0, 0, self.bounds.size.width / 2, 40)];
            [cancelBt setTitle:@"取消" forState:UIControlStateNormal];
//            [cancelBt setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            cancelBt.center = CGPointMake(bg4.center.x - 80, bg4.center.y);
            [cancelBt addTarget:self action:@selector(clickCancelBt) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:cancelBt];
            
            UIButton *sureBt = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [sureBt setFrame:CGRectMake(50, 0, self.bounds.size.width / 2, 40)];
            [sureBt setTitle:@"确定" forState:UIControlStateNormal];
            [sureBt setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//            sureBt.center = bg4.center;
            sureBt.center = CGPointMake(bg4.center.x + 80, bg4.center.y);
            [sureBt addTarget:self action:@selector(clickBt:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:sureBt];
            
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width / 2, (self.bounds.size.height - 51) / 3 + 100, 1, 50)];
            [lineView setBackgroundColor:[UIColor colorWithHexValue:kTableCellSelectedColor]];
            [bgView addSubview:lineView];

            UIImageView *image1 = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
            [image1 setBackgroundColor:[UIColor clearColor]];
            [bg2 addSubview:image1];
            ladyImageView = image1;
            UILabel *lab1 = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 50, bg2.bounds.size.height)];
            [lab1 setBackgroundColor:[UIColor clearColor]];
            [lab1 setTextColor:[UIColor colorWithHexValue:kTableCellSelectedColor]];
            [lab1 setFont:[UIFont systemFontOfSize:15]];
            [lab1 setText:@"女"];
            [bg2 addSubview:lab1];
            
            UIImageView *image2 = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
            [image2 setBackgroundColor:[UIColor clearColor]];
            [bg3 addSubview:image2];
            menImageView = image2;
            UILabel *lab2 = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 50, bg3.bounds.size.height)];
            [lab2 setBackgroundColor:[UIColor clearColor]];
            [lab2 setTextColor:[UIColor colorWithHexValue:kTableCellSelectedColor]];
            [lab2 setFont:[UIFont systemFontOfSize:15]];
            [lab2 setText:@"男"];
            [bg3 addSubview:lab2];
            
            UIButton *bt1 = [UIButton buttonWithType:UIButtonTypeCustom];
            [bt1 setFrame:bg2.bounds];
            [bt1 setTag:1];
            [bt1 setBackgroundColor:[UIColor clearColor]];
            [bt1 addTarget:self action:@selector(didSexBt:) forControlEvents:UIControlEventTouchUpInside];
            [bg2 addSubview:bt1];
            
            UIButton *bt2 = [UIButton buttonWithType:UIButtonTypeCustom];
            [bt2 setFrame:bg3.bounds];
            [bt2 setTag:0];
            [bt2 setBackgroundColor:[UIColor clearColor]];
            [bt2 addTarget:self action:@selector(didSexBt:) forControlEvents:UIControlEventTouchUpInside];
            [bg3 addSubview:bt2];
            UserInfo *userInfo = [[UserManager sharedInstance] loginedUser];
            if (userInfo.userDes.sex != nil) {
                sex_Index = [userInfo.userDes.sex integerValue];
                if (0 == sex_Index) {
                    [menImageView setImage:[UIImage imageNamed:@"change_icon"]];
                    [ladyImageView setImage:[UIImage imageNamed:@"unchange_icon"]];
                }
                else{
                    [menImageView setImage:[UIImage imageNamed:@"unchange_icon"]];
                    [ladyImageView setImage:[UIImage imageNamed:@"change_icon"]];
                }
            }
            else{
                sex_Index = 0;
                [menImageView setImage:[UIImage imageNamed:@"change_icon"]];
                [ladyImageView setImage:[UIImage imageNamed:@"unchange_icon"]];
            }
        }
    }
    return self;
}

- (void)clickCancelBt{
    if ([_delegate respondsToSelector:@selector(removeAlertView:)]) {
        [_delegate removeAlertView:self];
    }
}

- (void)didSexBt:(UIButton *)sender{
    NSLog(@"didSexBt: %ld", (long)sender.tag);
    sex_Index = sender.tag;
    if (0 == sender.tag) {
        [menImageView setImage:[UIImage imageNamed:@"change_icon"]];
        [ladyImageView setImage:[UIImage imageNamed:@"unchange_icon"]];
    }
    else{
        [menImageView setImage:[UIImage imageNamed:@"unchange_icon"]];
        [ladyImageView setImage:[UIImage imageNamed:@"change_icon"]];
    }
}

- (void)clickBt:(UIButton *)sender{
    if (alert_Type_ == User_Rportrait_Type){
        NSLog(@"%ld", (long)sender.tag);
        
        if ([_delegate respondsToSelector:@selector(didAlertBt:andAlert_Type:)]) {
            [_delegate didAlertBt:sender.tag andAlert_Type:alert_Type_];
        }
    }
    else{
        UserInfo *userInfo = [[UserManager sharedInstance] loginedUser];
        
        NSUInteger oldSex = [userInfo.userDes.sex integerValue];
        NSString *sexStr = [NSString stringWithFormat:@"%lu", (unsigned long)sex_Index];
        if (oldSex == sex_Index) {
            if ([_delegate respondsToSelector:@selector(removeAlertView:)]) {
                [_delegate removeAlertView:self];
            }
            return;
        }
        
        [[UserManager sharedInstance] modifyUserInfoNickName:nil andSex:sexStr WithCompletionHandler:^(BOOL succeeded, NSDictionary *dicData){
            if (succeeded) {
                [[UserManager sharedInstance] loginedUser].userDes.sex = sexStr;
                [[UserManager sharedInstance] savePathOfUserInfo];
                if ([_delegate respondsToSelector:@selector(removeAlertView:)]) {
                    [_delegate removeAlertView:self];
                }
                [PhoneNotification autoHideWithText:@"操作成功"];

            }
            else{
                [PhoneNotification autoHideWithText:@"操作失败"];
            }
        }];
    }
}

@end


@implementation ModifyNickNameViewController

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
    
    self.title = @"更换昵称";
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(10, 75, 50, 40)];
    [lab setBackgroundColor:[UIColor clearColor]];
    [lab setFont:[UIFont systemFontOfSize:15]];
    [lab setTextColor:[UIColor grayColor]];
    [lab setText:@"昵称:"];
    [lab setTextAlignment:NSTextAlignmentRight];
    [self.view addSubview:lab];
    
    UIView *phoneBg = [[UIView alloc] initWithFrame:CGRectMake(70, 75.0f, 250, 40.0f)];
    [phoneBg setBackgroundColor:[UIColor clearColor]];
    phoneBg.layer.cornerRadius = 1.0f;
    [self.view addSubview:phoneBg];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10, 115, [[UIScreen mainScreen] bounds].size.width - 20, 1)];
    [line setBackgroundColor:[UIColor colorWithHexValue:kTableCellSelectedColor]];
    [self.view addSubview:line];
    
    phoneTextField = [[UITextField alloc] initWithFrame:phoneBg.bounds];
    [phoneTextField setBackgroundColor:[UIColor clearColor]];
    [phoneTextField setFont:[UIFont systemFontOfSize:15.0f]];
    phoneTextField.delegate = self;
    phoneTextField.textColor = [UIColor colorWithHexString:@"999292"];
    phoneTextField.keyboardType = UIKeyboardTypeDefault;
    phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    phoneTextField.returnKeyType = UIReturnKeyDone;
    phoneTextField.contentVerticalAlignment = UIControlContentHorizontalAlignmentCenter;
    phoneTextField.text = [[UserManager sharedInstance] loginedUser].userDes.nickName;
    [phoneBg addSubview:phoneTextField];
    {
        UIView *accessory = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kContentWidth, 44)];
        accessory.backgroundColor = self.view.backgroundColor;
        
        
        // 隐藏键盘按钮
        // keyBoard 中的自定义隐藏keyboard 按钮
        UIImage *btnImg = [UIImage imageNamed:@"minikeyborad"];
        CGFloat eW = btnImg.size.width;
        CGFloat eH = btnImg.size.height;
        CGFloat eY = (CGRectGetHeight(accessory.bounds)-eH) / 2;
        CGFloat eX = CGRectGetWidth(accessory.bounds) - eW - 5;
        UIButton *exitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        exitBtn.frame = CGRectMake(eX, eY, eW, eH);
        [exitBtn setBackgroundImage:btnImg forState:UIControlStateNormal];
        [exitBtn addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventTouchUpInside];
        [accessory addSubview:exitBtn];
        
        
        phoneTextField.inputAccessoryView = accessory;
    }
    

    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(hideKeyboard)];
    singleFingerTap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:singleFingerTap];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self performSelector:@selector(popupKeyboard) withObject:nil afterDelay:0.4f];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [PhoneNotification hideNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark Observer methods
- (void)keyboardWillShow:(NSNotification *)notification
{
    keyboardShowing = YES;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    keyboardShowing = NO;
}

- (void)popupKeyboard
{
    [phoneTextField becomeFirstResponder];
}

- (void)hideKeyboard
{
    [phoneTextField resignFirstResponder];
}


#pragma mark UITextFieldDelegate methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
//    if (textField == phoneTextField) {
//        if (phoneTextField.text == nil || [phoneTextField.text isEmptyOrBlank]) {
//            [PhoneNotification autoHideWithText:@"请输入您的昵称"];
//            return NO;
//        }
//        
//    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == phoneTextField) {
        if (phoneTextField.text == nil || [phoneTextField.text isEmptyOrBlank]) {
            [PhoneNotification autoHideWithText:@"请输入您的昵称"];
            return NO;
        }
        
        [[UserManager sharedInstance] modifyUserInfoNickName:phoneTextField.text andSex:nil WithCompletionHandler:^(BOOL succeeded, NSDictionary *dicData) {
            if (succeeded) {
                [[UserManager sharedInstance] loginedUser].userDes.nickName = phoneTextField.text;
                [[UserManager sharedInstance] savePathOfUserInfo];
                [PhoneNotification autoHideWithText:@"操作成功"];
                [self dismissBackController];
            }
            else{
                [PhoneNotification autoHideWithText:@"操作失败"];
            }
        }];
    }
    return YES;
}

@end
