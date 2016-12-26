//
//  SNSpecialHeaderTableCell.m
//  SurfNewsHD
//
//  Created by XuXg on 15/8/17.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "SNSpecialHeaderTableCell.h"
#import "NSString+Extensions.h"
#import "SNNewsListUIHelper.h"


@implementation SNSpecialHeaderTableCell

-(id)initWithStyle:(UITableViewCellStyle)style
   reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _specialIcon = [UIImage imageNamed:@"special_Cell_Icon"];
    }
    return self;
}

-(void)setThread:(ThreadSummary *)thread
{
    _thread = thread;
    [self setNeedsDisplay];
}

-(void)drawContentView:(CGRect)rect highlighted:(BOOL)highlighted
{
    SNNewsListUIHelper *helper = [SNNewsListUIHelper sharedInstance];
    
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    CGFloat beginX = helper->_contentEdge.left;
    CGFloat lineW = [SNNewsListUIHelper lineWidthForSpecial];
    
    CGFloat iconW = [_specialIcon size].width;
    CGFloat iconH = [_specialIcon size].height;
    CGFloat iconX = width - helper->_contentEdge.right-iconW;
    CGFloat iconY = (height - iconH - lineW)/2.f + lineW;
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    CGContextSaveGState(context);
    
    
    // 顶部分割线
    CGContextSetLineWidth(context, lineW);
    [[SNTheme valueForKey:kColorKey_SeparatorLine] setStroke];
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, width, 0);
    CGContextStrokePath(context);
    
    // 底部分割线
    CGContextSetLineWidth(context, 0.5);
    CGContextMoveToPoint(context, 0, height);
    CGContextAddLineToPoint(context, width, height);
    CGContextStrokePath(context);
    
    
    // 标题
    if(_thread.title && ![_thread.title isEmptyOrBlank]){
        UIFont *f = helper->_titleFont;
        CGFloat tH = f.lineHeight;
        CGFloat tY = (height-tH-lineW) / 2.f + lineW;
        CGFloat tW = iconX - beginX - 10.f;
        CGRect tR = CGRectMake(beginX, tY, tW, tH);
        UIColor *tC = [UIColor colorWithHexValue:0xff333333];
        [_thread.title surfDrawString:tR
                             withFont:f
                            withColor:tC
                        lineBreakMode:NSLineBreakByWordWrapping
                            alignment:NSTextAlignmentLeft];
    }

    
    // 专题标志图片
    CGRect iconR = CGRectMake(iconX, iconY, iconW, iconH);
    [_specialIcon drawInRect:iconR];
    
    
    
    CGContextRestoreGState(context);
    UIGraphicsPopContext();
}
@end
