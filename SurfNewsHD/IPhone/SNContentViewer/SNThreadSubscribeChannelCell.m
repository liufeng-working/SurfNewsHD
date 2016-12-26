//
//  SNThreadSubscribeChannelCell.m
//  SurfNewsHD
//
//  Created by XuXg on 15/9/24.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "SNThreadSubscribeChannelCell.h"
#import "NSString+Extensions.h"
#import "SubsChannelsManager.h"


#define kIconHeight 50.f
#define kIconWidth 50.f
#define kTopMargin 5.f
#define kLeftMargin 15.f
#define kBottomMargin 5.f
#define kRightMargin 15.f
@interface SNThreadSubscribeChannelCell () {

    
    __weak UILabel *_titleLabel;
    __weak UILabel *_detailLabel;
    __weak UIImageView *_plusImageView;
    __weak UIImageView *_iconImageVIew;
    
    HotChannelRec *_hotchannelRec;
    BOOL _isSubscribe;
}


@end

@implementation SNThreadSubscribeChannelCell


+(CGFloat)cellSizeWithFits
{
    return kIconHeight + kTopMargin + kBottomMargin;
}


-(id)initWithStyle:(UITableViewCellStyle)style
   reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self buildCustomUI];
    }
    return self;
}


-(void)buildCustomUI
{
    CGFloat w = CGRectGetWidth(self.bounds);
    CGFloat h = [[self class] cellSizeWithFits];
    
    // icon
    CGRect iconR = CGRectMake(kLeftMargin, kTopMargin, kIconWidth, kIconHeight);
    UIImageView *iconV = [[UIImageView alloc] initWithFrame:iconR];
    _iconImageVIew = iconV;
    iconV.clipsToBounds = YES;
    [[self contentView] addSubview:iconV];
    
    
    // title
    UIImage *plusImg = [UIImage imageNamed:@"order_ok"];
    CGFloat plusX = w - kRightMargin - plusImg.size.width - 5;
    UIColor *tColor = [UIColor colorWithHexValue:0xff666666];
    CGFloat tX = kLeftMargin + kIconWidth + 20.f;
    CGFloat tW = w - tX - plusImg.size.width - 5;
    UIFont *tFont = [UIFont systemFontOfSize:15.f];
    CGFloat tY = h/2 - tFont.lineHeight;
    CGRect titleR =
    CGRectMake(tX, tY, tW, tFont.lineHeight);
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:titleR];
    _titleLabel = titleLabel;
    titleLabel.font = tFont;
    titleLabel.textColor = tColor;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.backgroundColor = [UIColor clearColor];
    [[self contentView] addSubview:titleLabel];
    
    
    // detail
    UIFont *dFont = [UIFont systemFontOfSize:10.f];
    CGFloat dY = (h + dFont.lineHeight)/2;
    CGRect dRect = CGRectMake(tX, dY, tW, dFont.lineHeight);
    UILabel *detail = [[UILabel alloc] initWithFrame:dRect];
    _detailLabel = detail;
    detail.text = @"点击查看";
    detail.textColor = tColor;
    detail.font = dFont;
    detail.textAlignment = NSTextAlignmentLeft;
    detail.backgroundColor = [UIColor clearColor];
    [[self contentView] addSubview:detail];

    
    // plus 添加一个添加订阅的图片
    CGFloat plusW = plusImg.size.width;
    CGFloat plusH = plusImg.size.height;
    CGFloat plusY = (h - plusImg.size.height ) /2.f;
    CGRect plusR = CGRectMake(plusX, plusY, plusW, plusH);
    UIImageView *plusV =
    [[UIImageView alloc] initWithFrame:plusR];
    _plusImageView = plusV;
    [[self contentView] addSubview:plusV];
}


-(void)loadDataWithHotChannelRec:(HotChannelRec*)rec
{
    if(_hotchannelRec && rec == _hotchannelRec)
        return;
    
    _hotchannelRec = rec;
    _titleLabel.text = rec.recname;
    _iconImageVIew.image = nil; // 最好给一个默认图片
    if (![rec.recimg isEmptyOrBlank]) {
        _iconImageVIew.image =
        [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:rec.recimg]]];
    }
    
    [self checkSubscribeState];
}

-(void)setSubscribeState:(BOOL)isSub
{
    if (_isSubscribe != isSub) {
        _isSubscribe = isSub;
        _plusImageView.image =
        [UIImage imageNamed:isSub?@"order_ok":@"order_add"];
    }
}
-(void)checkSubscribeState
{
    if (!_hotchannelRec) {
        return;
    }
    
    
    BOOL isSubscribe = [[SubsChannelsManager sharedInstance] isChannelSubscribed:_hotchannelRec.channelId];
    _isSubscribe = !isSubscribe;
    [self setSubscribeState:isSubscribe];
}



@end
