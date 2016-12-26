//
//  PhoneBeautyChannelCell.m
//  SurfNewsHD
//
//  Created by XuXg on 15/1/6.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "PhoneBeautyChannelCell.h"
#import "NSString+Extensions.h"
#import "PathUtil.h"
#import "ImageDownloader.h"
#import "UIView+NightMode.h"
#import "PhoneWeiboController.h"

#define kPanelHeigth 45.f // 菜单面板高度


@protocol BeautyCellMenuPanelDelegate <NSObject>

-(void)saveImageToPhotosAlbum;

-(void)shareImageToWeixin;
@end




@interface PhoneBeautyCellHelper : NSObject

@property(nonatomic,strong,readonly)UIImage *defaultImage;
@property(nonatomic,strong,readonly)UIImage *dateIcon;
@property(nonatomic,strong,readonly)UIImage *praiseImg;

+(PhoneBeautyCellHelper*) sharedInstance;

@end

@implementation PhoneBeautyCellHelper

+(PhoneBeautyCellHelper*)sharedInstance
{
    static PhoneBeautyCellHelper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [PhoneBeautyCellHelper new];
    });
    return sharedInstance;
}

-(id)init
{
    self = [super init];
    if (self) {
        _defaultImage = [UIImage imageNamed:@"loading"];
        _dateIcon = [UIImage imageNamed:@"time"];
        _praiseImg = [UIImage imageNamed:@"beauty_cell_menu_praise"];
        
    }
    return self;
}
@end




// 美女cell菜单
@interface BeautyCellMenuPanel : UIView {
    
    UIImageView *_icon;
    UILabel *_timeLabel;
    UILabel *_titleLabel;
    UIButton *_moreBtn;
    UIButton *_saveBtn;
    UIButton *_shareBtn;
    
    CGFloat _offX;
}

@property(nonatomic,weak)id<BeautyCellMenuPanelDelegate> delegate;
-(void)loadingTheradSummary:(ThreadSummary*)ts;
@end

@implementation BeautyCellMenuPanel
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        PhoneBeautyCellHelper *helper = [PhoneBeautyCellHelper sharedInstance];
        {
            self.backgroundColor = [UIColor colorWithHexString:@"e6e6e0"];
            self.alpha = 0.8;
            UIImage *moreImg = [UIImage imageNamed:@"beauty_cell_more"];
            UIFont *btnF = [UIFont systemFontOfSize:15.f];
            UIImage *hlBg = [UIImage imageNamed:@"navBtnBG"];
            UIColor *btnTitleC = [UIColor colorWithHexValue:0xFF34393D];
            
            
            CGFloat iconX = 10.f;
            CGFloat iconY = 10.f;
            CGSize iconS = helper.dateIcon.size;
            CGRect iconR = {{iconX,iconY},iconS};
            _icon = [[UIImageView alloc] initWithImage:helper.dateIcon];
            [_icon setFrame:iconR];
            [self addSubview:_icon];
            
            
            // 时间
            UIFont *sF = [UIFont systemFontOfSize:8.f];
            CGFloat sW = 50.f;
            CGFloat sH = sF.lineHeight;
            CGFloat sX = iconX + iconS.width + 5.f;
            CGFloat sY = iconY + (iconS.height-sH) / 2;
            CGRect timeStrR = CGRectMake(sX, sY, sW, sH);
            _timeLabel = [[UILabel alloc] initWithFrame:timeStrR];
            [_timeLabel setBackgroundColor:[UIColor clearColor]];
            [_timeLabel setTextAlignment:NSTextAlignmentLeft];
            [_timeLabel setTextColor:[UIColor grayColor]];
            [_timeLabel setFont:sF];
            [self addSubview:_timeLabel];
            
            
            // 标题
            CGFloat tX = 10.f;
            CGFloat tY = iconS.height + iconY + 5.f;
            CGFloat tW = CGRectGetWidth(frame)-moreImg.size.width-tX;
            UIFont *tF = [UIFont systemFontOfSize:12.f];
            CGRect tR = CGRectMake(tX, tY, tW, tF.lineHeight);
            _titleLabel = [[UILabel alloc] initWithFrame:tR];
            [_titleLabel setBackgroundColor:[UIColor clearColor]];
            [_titleLabel setFont:tF];
            [_titleLabel setTextColor:[UIColor colorWithHexValue:0xFF34393D]];
            [_titleLabel setTextAlignment:NSTextAlignmentLeft];
            [self addSubview:_titleLabel];

            
            // btn
            CGFloat moreBtnW = moreImg.size.width;
            CGFloat moreBtnH = CGRectGetHeight(frame);
            CGFloat moreBtnX = _offX = CGRectGetWidth(frame)-moreBtnW;
            CGRect moreR = CGRectMake(moreBtnX, 0.f, moreBtnW, moreBtnH);
            _moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_moreBtn setFrame:moreR];
            [_moreBtn setImage:moreImg forState:UIControlStateNormal];
            [_moreBtn setBackgroundImage:hlBg
                                 forState:UIControlStateHighlighted];
            [_moreBtn addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_moreBtn];
            
            // 保存
            CGFloat saveW = 80.f;
            CGFloat saveX = moreBtnX+moreBtnW + 30.f;
            _saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            _saveBtn.titleLabel.font = btnF;
            [_saveBtn setTitle:@"保存" forState:UIControlStateNormal];
            [_saveBtn setTitleColor:btnTitleC
                           forState:UIControlStateNormal];
            [_saveBtn setBackgroundImage:hlBg
                                forState:UIControlStateHighlighted];
            [_saveBtn setFrame:CGRectMake(saveX, 0, saveW, moreBtnH)];
            {
                UIImage *saveIcon = [UIImage imageNamed:@"beauty_cell_menu_download"];
                [_saveBtn setImage:saveIcon forState:UIControlStateNormal];
                CGFloat iW = saveIcon.size.width;
                CGFloat iH = saveIcon.size.height;
                CGFloat t = (moreBtnH - iH) / 2.f;
                CGFloat l = -10.f;
                CGFloat b = t;
                CGFloat r = saveW - iW - l;
                _saveBtn.imageEdgeInsets = UIEdgeInsetsMake(t, l, b, r);
                _saveBtn.titleEdgeInsets = UIEdgeInsetsMake(0,-35,0,5);
            }
            [_saveBtn addTarget:self action:@selector(saveButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_saveBtn];
            
            // 分享           
            CGFloat shareW = 80.f;
            CGFloat shareX = saveX + saveW + 10;
            _shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            _shareBtn.titleLabel.font = btnF;
            [_shareBtn setTitle:@"分享" forState:UIControlStateNormal];
            [_shareBtn setTitleColor:btnTitleC
                            forState:UIControlStateNormal];
            [_shareBtn setBackgroundImage:hlBg
                                 forState:UIControlStateHighlighted];
            [_shareBtn setFrame:CGRectMake(shareX, 0, shareW, moreBtnH)];
            {
                UIImage *shareIcon = [UIImage imageNamed:@"beauty_cell_menu_share"];
                [_shareBtn setImage:shareIcon forState:UIControlStateNormal];
                CGFloat iW = shareIcon.size.width;
                CGFloat iH = shareIcon.size.height;
                CGFloat t = (moreBtnH - iH) / 2.f;
                CGFloat l = -10;
                CGFloat b = t;
                CGFloat r = shareW-iW-l;
                _shareBtn.imageEdgeInsets = UIEdgeInsetsMake(t, l, b, r);
                _shareBtn.titleEdgeInsets = UIEdgeInsetsMake(0,-35,0,5);
            }
            [_shareBtn addTarget:self action:@selector(shareButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_shareBtn];
        }
    }
    return self;
}

-(void)loadingTheradSummary:(ThreadSummary*)ts
{
    _timeLabel.text = nil;
    _titleLabel.text = nil;
    _timeLabel.text = ts.timeStr;
    _titleLabel.text = ts.title;
    
    if(_moreBtn.tag == 1){
        _moreBtn.tag = 0;
        [self subViewsOffset:(_offX)];
        UIImage *moreImg = [UIImage imageNamed:@"beauty_cell_more"];
        [_moreBtn setImage:moreImg forState:UIControlStateNormal];
    }
}

-(void)subViewsOffset:(CGFloat)offX
{
    [[self subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGRect r = [(UIView*)obj frame];
        r.origin.x += offX;
        [(UIView*)obj setFrame:r];
    }];
}

-(void)moreButtonClick:(id)sender
{
    UIButton *btn = sender;
    [btn setEnabled:NO];
    

    BOOL recover = btn.tag == 1;
    btn.tag = btn.tag == 0 ? 1 : 0;
    [UIView animateWithDuration:0.3f animations:^{
        [self subViewsOffset:recover ? _offX : -_offX];
    } completion:^(BOOL finished) {
        [btn setEnabled:YES];
        
        UIImage *btnImg = [UIImage imageNamed:@"beauty_cell_more"];
        [btn setImage:btnImg forState:UIControlStateNormal];
    }];
}


-(void)saveButtonClick:(id)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(saveImageToPhotosAlbum)]) {
        [_delegate saveImageToPhotosAlbum];
    }
}

-(void)shareButtonClick:(id)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(shareImageToWeixin)]) {
        [_delegate shareImageToWeixin];
    }
}

@end

@interface PhoneBeautyChannelCell ()<BeautyCellMenuPanelDelegate> {
    __weak ThreadSummary *_ts;
    
    UIImage *_img;

    
    __weak PhoneBeautyCellHelper *_beautyHelper;
    
    
    // 菜单面板
    BeautyCellMenuPanel *_menuPanel;
}

@end
@implementation PhoneBeautyChannelCell

-(id)initWithStyle:(UITableViewCellStyle)style
   reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _beautyHelper = [PhoneBeautyCellHelper sharedInstance];
        
        // 设置更多按钮位置
        UIEdgeInsets imgEdgeInsets = [PhoneBeautyChannelCell imageEdgeInsets];
        CGFloat w = CGRectGetWidth(self.bounds)-imgEdgeInsets.left-imgEdgeInsets.right;
        CGRect menuR = CGRectMake(imgEdgeInsets.left, 0, w, kPanelHeigth);
        _menuPanel =
        [[BeautyCellMenuPanel alloc] initWithFrame:menuR];
        _menuPanel.delegate = self;
        _menuPanel.layer.masksToBounds = YES;
        [self addSubview:_menuPanel];
        
        
        self.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}

+(UIEdgeInsets)imageEdgeInsets
{
    return UIEdgeInsetsMake(15.f, 10.f, 5.f, 10.f);
}

-(void)loadingDataWithThreadSummary:(ThreadSummary *)ts
{
    _ts = ts;
    _img = nil;
    
    
    [self loadingBeautyImage];
    
    // 初始化菜单面板
    [self initMenuPanel];
    
    
    [self setNeedsDisplay];
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    
    
    CGFloat pH = CGRectGetHeight(_menuPanel.bounds);
    CGFloat h = CGRectGetHeight(self.bounds);
    CGFloat cX = _menuPanel.center.x;
    CGFloat cY = h - pH/2.f - [PhoneBeautyChannelCell imageEdgeInsets].bottom;
    _menuPanel.center = CGPointMake(cX, cY);
    
}


// 初始化菜单面板
-(void)initMenuPanel
{
    [_menuPanel loadingTheradSummary:_ts];
}

// 加载美女图片
-(void)loadingBeautyImage
{
    NSString *imgPath = [PathUtil pathOfThreadLogo:_ts];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSLog(@"%@",_ts.imgUrl);
    
    // 图片文件不存在
    if (![fm fileExistsAtPath:imgPath])
    {
        // 请求图片数据
        if (_ts.imgUrl && ![_ts.imgUrl isEmptyOrBlank])
        {
            ImageDownloadingTask *task = [ImageDownloadingTask new];
            [task setImageUrl:_ts.imgUrl];
            [task setUserData:_ts];
            [task setTargetFilePath:imgPath];
            [task setCompletionHandler:^(BOOL succeeded, ImageDownloadingTask *idt) {
                if(succeeded && idt && _ts == idt.userData){
                    _img = [UIImage imageWithData:idt.resultImageData];\
                    [self setNeedsDisplay];
                }
            }];
            [[ImageDownloader sharedInstance] download:task];
        }
    }
    else{
        NSData *imgData = [NSData dataWithContentsOfFile:imgPath];
        _img = [UIImage imageWithData:imgData];
    }
}

- (void)drawContentView:(CGRect)rect highlighted:(BOOL)highlighted
{
    rect = UIEdgeInsetsInsetRect(rect, [PhoneBeautyChannelCell imageEdgeInsets]);
    CGFloat w = CGRectGetWidth(rect);
    CGFloat h = CGRectGetHeight(rect);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    CGContextSaveGState(context);
    
    // 绘制默认图片
    if(!_img) {
        [[UIColor colorWithHexValue:KImageDefaultBGColor] setFill];
        CGContextFillRect(context, rect);
    
        CGFloat imgX = (w - _beautyHelper.defaultImage.size.width ) / 2;
        CGFloat imgY = (h - _beautyHelper.defaultImage.size.height) / 2;
        imgX += rect.origin.x;
        imgY += rect.origin.y;
        [_beautyHelper.defaultImage drawAtPoint:CGPointMake(imgX, imgY)];
    }
    else {
        [_img drawInRect:rect];
    }
    
    
    // 亲密度
    {
        CGFloat pW = _beautyHelper.praiseImg.size.width;
        CGFloat pH = _beautyHelper.praiseImg.size.height;
        CGFloat pX = rect.origin.x +  w - pW - 15.f;
        CGFloat pY = rect.origin.y + 15.f;
        [_beautyHelper.praiseImg drawAtPoint:CGPointMake(pX, pY)];
        
       
        CGFloat pStrW = pW + pW;
        CGFloat pStrX = pX + pW / 2 - pStrW / 2;
        CGFloat pStrY = pY + pH + 5.f;
        UIFont *pStrF = [UIFont systemFontOfSize:10.f];
        NSString *praiseStr = [NSString stringWithFormat:@"%@",@(_ts.intimacyDegree)];
        CGRect pStrR = CGRectMake(pStrX, pStrY, pStrW, pStrF.lineHeight);
        [praiseStr surfDrawString:pStrR
                         withFont:pStrF
                        withColor:[UIColor redColor]
                    lineBreakMode:NSLineBreakByWordWrapping
                        alignment:NSTextAlignmentCenter];
    
    }
    
    
    // 因结构问题，panel 背景需要在这里绘制
    {
        [[UIColor colorWithWhite:0.8f alpha:0.5f] setFill];
        CGRect panelR = _menuPanel.frame;
        CGContextFillRect(context, panelR);
    }
    
    
    CGContextRestoreGState(context);
    UIGraphicsPopContext();
}


// 保存图片到相册中
#pragma -mark BeautyCellMenuPanelDelegate
-(void)saveImageToPhotosAlbum
{
    // 保存图片到相册中
    if(_img){
        SEL completionSelector = @selector(saveImagecompletion:didFinishSavingWithError:contextInfo:);
        UIImageWriteToSavedPhotosAlbum(_img, self,completionSelector, nil);
    }
    else {
        [PhoneNotification autoHideWithText:@"无法保存，没有图像数据"];
    }
}

-(void)shareImageToWeixin
{
    // 分享图片到微博
    if(_img){
        PhoneWeiboController *pwc =
        [self findUserObject:[PhoneWeiboController class]];
        PhoneshareWeiboInfo *info = [[PhoneshareWeiboInfo alloc]initWithWeiboSource:kWeiboData_BeautyCell];
        [info setThread:_ts isShareEnergy:NO];
        [info setPicture:_img];
        info.showWeiboType = kWeixin|kWeiXinFriendZone|kSinaWeibo|kQQFriend|kQZone;
        info.weiboBGColor = [UIColor clearColor];
        [pwc showShareView:kWeiboView_Center shareInfo:info];
    }
    else {
        [PhoneNotification autoHideWithText:@"无法分享，没有图像数据"];
    }
}


- (void)saveImagecompletion:(UIImage *)image
   didFinishSavingWithError:(NSError *)error
                contextInfo:(void *)contextInfo
{
    // Was there an error?
    if (error != NULL){
        // Show error message...
        [PhoneNotification autoHideWithText:@"保存失败！"];
    }
    else{
        [PhoneNotification autoHideWithText:@"保存成功！"];
    }
}

@end
