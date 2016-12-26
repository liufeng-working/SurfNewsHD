//
//  SNEnergyTableCell.m
//  SurfNewsHD
//
//  Created by XuXg on 15/8/21.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "SNEnergyTableCell.h"
#import "NSString+Extensions.h"
#import "CGContextUtil.h"



@implementation SNEnergyTableCell

+(CGFloat)energyCellHeight
{
    return 150.f;
}

-(id)initWithStyle:(UITableViewCellStyle)style
   reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _titleFont = [UIFont boldSystemFontOfSize:22];
        _pIcon = [UIImage imageNamed:@"positive_big"];
        _nIcon = [UIImage imageNamed:@"negative_big"];
        
        
        _rArrow = [UIImage imageNamed:@"bticon"];   // 右箭头
        _p_en_flag = [UIImage imageNamed:@"good50"];// 正能量标记图片
        _n_en_flag = [UIImage imageNamed:@"bad50"];
    }
    return self;
}

//SNToolBar
-(void)loadEnergyInfo:(SNNewsExtensionInfo*)info;
{
    _energyInfo = info;
    [self setNeedsDisplay];
}

-(void)viewNightModeChanged:(BOOL)isNight
{
    if (isNight) {
        _nIcon = [UIImage imageNamed:@"bad_icon_night"];
    }
    else {
        _nIcon = [UIImage imageNamed:@"negative_big"];
    }
    
    [self setNeedsDisplay];
}

- (void)drawContentView:(CGRect)rect
            highlighted:(BOOL)highlighted
{
    if (!_energyInfo)   return;
    
    
    CGFloat l_edge = 10.f; // 左边距
    CGFloat t_edge = 10.f; // 上边距
    CGFloat r_edge = 10.f; // 右边距
    CGFloat width = CGRectGetWidth(self.bounds);
    BOOL isN = [[ThemeMgr sharedInstance] isNightmode];
    
    // 能量总数
    CGFloat pEnergy = _energyInfo.positive_energy.longValue; // 正能量
    CGFloat nEnergy = _energyInfo.negative_energy.longValue; // 负能力
    CGFloat energyCount = pEnergy + fabs(nEnergy); // 能量总数
    BOOL isPoEnergy = pEnergy >= fabs(nEnergy);
    
    
    // 正能量百分比
    CGFloat poPercent;
    if (isPoEnergy) {
        poPercent = floor(pEnergy*100 / energyCount);
    }
    else {
        poPercent = ceil(pEnergy*100 / energyCount);
    }
    
    // 表态人数
    NSInteger poCount = isPoEnergy?_energyInfo.positive_count.longValue:_energyInfo.negative_count.longValue;// 5.0.0改版

    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    CGContextSaveGState(context);
    

    if (highlighted) {
        if ([ThemeMgr sharedInstance].isNightmode) {
            [[UIColor colorWithHexValue:kTableCellSelectedColor_N] setFill];
        }
        else{
            [[UIColor colorWithHexValue:kTableCellSelectedColor] setFill];
        }
        CGContextFillRect(context, rect);
    }
    

    UIColor *titleColor = [UIColor colorWithHexValue:0xffcc0000];

    
    // 正负能量区域
    CGFloat eH = 15.f;      // 正负能量槽高度
    CGFloat radius = 2.f;   // 圆角
    CGFloat eSpace = 2.f;   // 正负能量槽间隔
    CGFloat eWidth = width - l_edge - r_edge - eSpace;
    CGFloat eY = t_edge;
    UIFont *f = [UIFont boldSystemFontOfSize:10.f];
    UIFont *plusFont = [UIFont boldSystemFontOfSize:15.f];
    CGFloat iconW = _pIcon.size.width;
    CGFloat iconH = _pIcon.size.height;
    CGFloat p_percent = poPercent;
    CGFloat n_percent = 100 - p_percent;
    
    // 正能量
    CGFloat pW = eWidth * (poPercent<30?30:(poPercent>70?70:poPercent))/100;
    CGFloat p_p_Y = eY + iconH + 5.f; // 正能量进度条Y
    CGRect p_p_Rect = CGRectMake(l_edge, p_p_Y, pW, eH);;
    {
        CGFloat pIconX = l_edge + (pW - iconW);
        [_pIcon drawAtPoint:CGPointMake(pIconX, eY + 1)]; // +1 才能对齐，由于字体的原因
        
        // 正能量数
        NSString *pEnergyStr =
        [NSString stringWithFormat:@"+%@", @(pEnergy)];
        CGFloat strY = eY+iconH-f.pointSize;
        CGRect strRect = CGRectMake(l_edge, strY, pW-iconW, f.lineHeight);
        [pEnergyStr surfDrawString:strRect
                          withFont:f
                         withColor:titleColor
                     lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
        
        
        // 正能量槽进度
        CGPathRef pPath =
        [CGContextUtil RoundedRectPathRef:p_p_Rect radius:radius];
        [titleColor setFill];
        CGContextAddPath(context, pPath);
        CGContextFillPath(context);
        
        // 绘制百分比
        NSString *percentStr =
        [NSString stringWithFormat:@"%@%%",@(p_percent)];
        CGRect strR = CGRectInset(p_p_Rect, 0, (CGRectGetHeight(p_p_Rect)-f.lineHeight)/2);
        [percentStr surfDrawString:strR
                          withFont:f
                         withColor:[UIColor whiteColor]
                     lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
        
        // 加号标记
        NSString *plusFlat = @"+";
        CGFloat plusInsetY = CGRectGetHeight(strR)-plusFont.pointSize;
        strR = CGRectInset(strR, 5, plusInsetY);
        strR.size.height = plusFont.lineHeight;
        [plusFlat surfDrawString:strR
                        withFont:plusFont
                       withColor:[UIColor whiteColor]
                   lineBreakMode:NSLineBreakByWordWrapping
                       alignment:NSTextAlignmentRight];
    }
    
    // 负能量
    {
        // icon
        CGFloat nIconX = l_edge + pW + eSpace;
        [_nIcon drawAtPoint:CGPointMake(nIconX, eY)];
        
        // 负能量数
        CGFloat nWidth = eWidth - pW;
        NSString *nEnergyStr =
        [NSString stringWithFormat:@"%@", @(nEnergy)];
        CGFloat strY = eY+iconH-f.pointSize;
        CGRect strRect = CGRectMake(nIconX+iconW, strY, nWidth-iconW, f.lineHeight);
        [nEnergyStr surfDrawString:strRect
                          withFont:f
                         withColor:isN?[UIColor whiteColor]:[UIColor blackColor]
                     lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentRight];
        
        
        
        CGRect n_p_Rect = CGRectOffset(p_p_Rect, pW + eSpace, 0.f);
        n_p_Rect.size.width = nWidth;
        CGPathRef nPath =
        [CGContextUtil RoundedRectPathRef:n_p_Rect radius:radius];
        CGContextAddPath(context, nPath);
        [[UIColor blackColor] setFill];
        CGContextFillPath(context);
        
        
        
        // 绘制百分比
        NSString *percentStr =
        [NSString stringWithFormat:@"%@%%" ,@(n_percent)];
        CGRect strR = CGRectInset(n_p_Rect, 0, (CGRectGetHeight(n_p_Rect)-f.lineHeight)/2);
        [percentStr surfDrawString:strR
                          withFont:f
                         withColor:[UIColor whiteColor]
                     lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
        
        // 减号标记
        NSString *minusFlat = @"­­–";
        CGFloat plusInsetY = CGRectGetHeight(strR)-plusFont.pointSize;
        strR = CGRectInset(strR, 5, plusInsetY);
        [minusFlat surfDrawString:strR
                         withFont:plusFont
                        withColor:[UIColor whiteColor]
                    lineBreakMode:NSLineBreakByWordWrapping
                        alignment:NSTextAlignmentLeft];

    }

    
    UIFont *desFont = [UIFont systemFontOfSize:11.f];
    NSString *des0, *des1;
    if(isPoEnergy){
        des0 = [NSString stringWithFormat:@"%@%%的人对这条新闻释放了 正能量，",@(p_percent)];
        des1 = @"满满的都是爱！";

    }
    else {
        des0 = [NSString stringWithFormat:@"%@%%的人对这条新闻释放了 负能量，",@(n_percent)];
        des1 = @"简直无法忍受了！";
    }
    
    CGFloat desWidth0 = [des0 surfSizeWithFont:desFont constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].width;
    CGFloat desWidth1 = [des1 surfSizeWithFont:desFont constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].width;
    CGFloat desX0 = (width-(desWidth0+desWidth1))/2.f;
    CGFloat desX1 = desX0 + desWidth0;
    CGFloat desY = p_p_Rect.origin.y + CGRectGetHeight(p_p_Rect)+10.f;
    
    CGRect desRect0 =  CGRectMake(desX0, desY, desWidth0, desFont.lineHeight);
    [des0 surfDrawString:desRect0
                withFont:desFont
               withColor: isN?[UIColor whiteColor]:[UIColor blackColor]
           lineBreakMode:NSLineBreakByWordWrapping
               alignment:NSTextAlignmentLeft];
    
    CGRect desRect1 =  CGRectMake(desX1, desY, desWidth1, desFont.lineHeight);
    [des1 surfDrawString:desRect1
                withFont:desFont
               withColor:titleColor
           lineBreakMode:NSLineBreakByWordWrapping
               alignment:NSTextAlignmentLeft];
    
    
    // 总计*人点击了
    UIImage *flagImg = isPoEnergy?_p_en_flag:_n_en_flag;
    CGFloat flagH = flagImg.size.height;
    CGFloat flagY = desY + desFont.lineHeight + 10.f;
    UIFont *countStrFont = [UIFont systemFontOfSize:13.f];
    NSString *countStr = [NSString stringWithFormat:@"总计%@人点击了",@(poCount)];
    CGFloat countStrW = [countStr surfSizeWithFont:countStrFont constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].width;
    CGFloat countStrY = flagY + (flagH-countStrFont.pointSize)/2;
    CGRect countStrRect = CGRectMake(l_edge, countStrY, countStrW, countStrFont.lineHeight);
    [countStr surfDrawString:countStrRect
                    withFont:countStrFont
                   withColor:isN?[UIColor whiteColor]:[UIColor blackColor]
               lineBreakMode:NSLineBreakByWordWrapping
                   alignment:NSTextAlignmentLeft];
    [flagImg drawAtPoint:CGPointMake(l_edge+countStrW+5, flagY)];
    
    
    // 我要表态
    CGFloat arrowW = _rArrow.size.width;
    CGFloat arrowX = width-r_edge-arrowW;
    CGFloat arrowY = flagY;
    [_rArrow drawAtPoint:CGPointMake(arrowX, arrowY)];
    
    NSString *myAttitudeStr = @"我要表态";
    CGFloat myAttStrWidth =
    [myAttitudeStr surfSizeWithFont:countStrFont
                  constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                      lineBreakMode:NSLineBreakByWordWrapping].width;
    CGFloat myAttStrX = arrowX-5-myAttStrWidth;
    CGFloat myAttStrY = countStrY;
    CGRect attRect = CGRectMake(myAttStrX, myAttStrY, myAttStrWidth, countStrFont.lineHeight);
    [myAttitudeStr surfDrawString:attRect
                         withFont:countStrFont
                        withColor:isN?[UIColor whiteColor]:[UIColor blackColor]
                    lineBreakMode:NSLineBreakByWordWrapping
                        alignment:NSTextAlignmentLeft];
    
    CGContextRestoreGState(context);
    UIGraphicsPopContext();
}
@end
