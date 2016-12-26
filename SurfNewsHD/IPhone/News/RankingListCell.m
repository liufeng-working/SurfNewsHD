//
//  RankingListCell.m
//  SurfNewsHD
//
//  Created by jsg on 14-11-25.
//  Copyright (c) 2014年 apple. All rights reserved.
//
#define RANKSTATUS      CGRectMake(285.0f, 20.0f, 15.0f, 15.0f)
#define RANKCOUNT       CGRectMake(304.0f, 21.0f, 35.0f, 35.0f)
#define RANKERENGY      CGRectMake(274.0f, 45.0f, 45.0f, 10.0f)

#import "RankingListCell.h"
#import "ImageDownloader.h"
#import "PathUtil.h"
#import "HotIconFlagManager.h"
#import "NSString+Extensions.h"


@interface RankingListCell() {
    NSString *_indexStr;
    __weak RankingNews * _rn;
    UIImage *_iconImage;
    UIImage *_statusImage;
    UIColor *_separatorColor;
    UIColor *_arrowColor;
    BOOL fistCell;
    
    UIFont *fontTitle;
    UIFont *fontIdx;
    UIFont *fontSource;
    UIFont *fontCount;
    UIFont *fontEnergy;
}
@end



@implementation RankingListCell

static UIImage* up_arrow = nil;
static UIImage* equal_arrow = nil;
static UIImage* down_arrow = nil;
static UIImage *sourceImage = nil;

-(id)initWithStyle:(UITableViewCellStyle)style
   reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!up_arrow) {
            up_arrow = [UIImage imageNamed:@"up_arrow.png"];
            equal_arrow = [UIImage imageNamed:@"equal_arrow.png"];
            down_arrow = [UIImage imageNamed:@"down_arrow.png"];
            sourceImage = [UIImage imageNamed:@"source.png"];
        }
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

-(void)loadDataWithRankingNews:(RankingNews*)obj atIndex:(NSInteger)idx
{
    if (!obj) {
        return;
    }
    _rn = obj;
    _indexStr = [NSString stringWithFormat:@"%@",@(idx)];
    _iconImage = nil;
    _statusImage = nil;
    
    if (_rn.iconPath && ![_rn.iconPath isEmptyOrBlank]) {
        HotIconFlagManager *iconM = [HotIconFlagManager sharedInstance];
        _iconImage = [iconM getHotIconWithUrl:_rn.iconPath
                         imgCompletionHandler:^(NSString *imgName, UIImage *iconImg) {
                             if ([_rn.iconPath rangeOfString:imgName options:NSBackwardsSearch].location != NSNotFound) {
                                 _iconImage = iconImg;
                                 [self setNeedsDisplay];
                             }
                         }];

    }
    
    fontIdx = [UIFont systemFontOfSize:12.0f];
    fontTitle = [UIFont systemFontOfSize:15.5f];
    fontSource = [UIFont systemFontOfSize:11.0f];
    fontCount = [UIFont systemFontOfSize:12.0f];
    fontEnergy = [UIFont systemFontOfSize:10.0f];
    
    // 箭头
    NSInteger seqUpdate = [_rn.seqUpdate intValue];
    if (seqUpdate > 0) {
        _statusImage = up_arrow;
        _arrowColor = [UIColor colorWithHexString:@"fb3c49"];
    }
    else if(seqUpdate == 0){
        _statusImage = equal_arrow;
        _arrowColor = [UIColor colorWithHexString:@"fb3c49"];
    }
    else if(seqUpdate < 0){
        _statusImage = down_arrow;
        _arrowColor = [UIColor colorWithHexString:@"7c7c7c"];
    }
    
    _separatorColor = [[ThemeMgr sharedInstance]isNightmode]?[UIColor colorWithHexValue:0xFFdcdbdb]:[UIColor colorWithHexValue:0xFFdcdbdb];
    
    [self setNeedsDisplay];
}

- (void)drawContentView:(CGRect)rect highlighted:(BOOL)highlighted
{
    fistCell = NO;
    BOOL isN = [[ThemeMgr sharedInstance] isNightmode];
    UIColor *indexColor =[[ThemeMgr sharedInstance]isNightmode]?[UIColor whiteColor]:[UIColor colorWithHexValue:kUnreadTitleColor];

    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    
    // 背景颜色
    UIColor *fillColor = [UIColor clearColor];
    
    if(highlighted){
        if (isN) {
            fillColor = [UIColor colorWithHexValue:kTableCellSelectedColor_N];
        }
        else {
            fillColor = [UIColor colorWithHexValue:kTableCellSelectedColor];
        }
    }
    
    CGContextSetFillColorWithColor(context, fillColor.CGColor);
    CGContextFillRect(context, rect);
    
    if (!fistCell) {
        float height = 0.0f;
        CGContextSetStrokeColorWithColor(context, _separatorColor.CGColor);
        CGContextMoveToPoint(context, rect.origin.x, height+rect.origin.y);
        CGContextAddLineToPoint(context, rect.origin.x+CGRectGetWidth(rect), height+rect.origin.y);
        CGContextStrokePath(context);
        fistCell = YES;
    }else{
        // 绘制分割线
        float height = CGRectGetHeight(rect);
        CGContextSetStrokeColorWithColor(context, _separatorColor.CGColor);
        CGContextMoveToPoint(context, rect.origin.x, height+rect.origin.y);
        CGContextAddLineToPoint(context, rect.origin.x+CGRectGetWidth(rect), height+rect.origin.y);
        CGContextStrokePath(context);
    }

    // 下标
    [indexColor setFill];
    float begin = 10.0f;
    [[UIColor colorWithHexString:@"8e8e8e"] set];
    if ([_indexStr length]> 1) {
        begin = 6.0f;
    }
    [_indexStr surfDrawAtPoint:CGPointMake(begin, (CGRectGetHeight(rect)-fontIdx.lineHeight)/2) withFont:fontIdx];
    
    // 标题
    float drawX = 27.f;
    if (_rn.title) {
        if ([_rn.title length] > 17) {
            NSString *str = [_rn.title substringToIndex:17];
            NSString *lastStr = [str stringByAppendingString:[NSString stringWithFormat:@"..."]];
            _rn.title = lastStr;
        }
        CGRect tR = CGRectMake(drawX, 15.0f, 246.0f, 28.0f);
        UIColor *colorTitle = [[ThemeMgr sharedInstance]isNightmode]?[UIColor whiteColor]:[UIColor colorWithHexValue:kUnreadTitleColor];
        [_rn.title surfDrawString:tR withFont:fontTitle withColor:colorTitle lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
    }
    
    //来源
    float drawBottomY = CGRectGetHeight(self.bounds) - 10.f;
    if (sourceImage) {
        float imgW = sourceImage.size.width;
        float imgH = sourceImage.size.height;
        CGRect sourceRect = CGRectMake(drawX, drawBottomY-imgH-5, imgW, imgH);
        [sourceImage drawInRect:sourceRect];
        drawX += imgW-2;
    }
    
    // 文章来源
    if(_rn.source){
        drawX += 6.f;
        float srW = 60.f;
        CGRect sr = CGRectMake(drawX, drawBottomY-fontSource.lineHeight-3, srW, fontSource.lineHeight);
        [_rn.source surfDrawString:sr withFont:fontSource withColor:[UIColor colorWithHexValue:kReadTitleColor] lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
        drawX += srW;
    }

    // 图标
    if(_iconImage) {
        NSInteger strCount = 0;
        if ([_rn.source length] > 2) {
            strCount = [_rn.source length];
        }
        else{
            strCount = 0;
        }
        drawX -= 30.f;
        float iconW = _iconImage.size.width / 2 - 8.0f;
        float iconH = _iconImage.size.height / 2 - 3.0;
        CGRect iconRect = CGRectMake(drawX+strCount*7, drawBottomY-iconH - 2.0f, iconW, iconH);
        [_iconImage drawInRect:iconRect];
    }
   
    //箭头
    if (_statusImage) {
        [_statusImage drawInRect:RANKSTATUS];
    }
    
    // 数量
    if(_rn.seqUpdate && ![_rn.seqUpdate isEmptyOrBlank]){
        int val = abs([_rn.seqUpdate intValue]);
        NSString* str = [NSString stringWithFormat:@"%i", val];
        CGRect sr = RANKCOUNT;
        [str surfDrawString:sr withFont:fontCount withColor:_arrowColor lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
    }
    
    // 能量值
    if(_rn.total_energy){
        CGRect sr = RANKERENGY;
        [_rn.total_energy surfDrawString:sr withFont:fontEnergy withColor:[UIColor colorWithHexString:@"cc0000"] lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
    }

    UIGraphicsPopContext();

}

@end
