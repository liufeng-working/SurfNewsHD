//
//  SNLoadingMoreCell.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-6-24.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SNLoadingMoreCell.h"

@implementation SNLoadingMoreCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _title = @"正在加载...";

        self.backgroundColor = [UIColor clearColor];
        _bgColorForDay = _bgColorForNight = [UIColor clearColor];
        _titleColorForDay = [UIColor colorWithHexValue:0xFF999292];
        _titleColorForNight = [UIColor colorWithHexValue:0xFF999292];
        _selectBgColorForNight = [UIColor colorWithHexValue:kTableCellSelectedColor_N];
        _selectBgColorForDay = [UIColor colorWithHexValue:kTableCellSelectedColor];     
        
        
        // 风火轮
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_activityView sizeToFit];
        _activityView.center = self.center;
        [self->contentView addSubview:_activityView];
        self->contentView.backgroundColor = [UIColor clearColor];
    }
    return self;
}


// 隐藏风火轮
-(void)hiddenActivityView:(BOOL)hidden
{
    _activityView.hidden = hidden;
    if (hidden) {
        [_activityView stopAnimating];
    }
    else {
        [_activityView startAnimating];
    }
}

-(void)viewNightModeChanged:(BOOL)isNight
{
    if (isNight) {
        self->contentView.backgroundColor = _bgColorForNight;
        _activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    }
    else{
        self->contentView.backgroundColor = _bgColorForDay;
        _activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    }
    [self setNeedsDisplay];
}


- (void)drawContentView:(CGRect)rect
            highlighted:(BOOL)highlighted
{
    BOOL isN = [[ThemeMgr sharedInstance] isNightmode];
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    
    if (highlighted) {
        UIColor *bgColor = isN?_selectBgColorForNight:_selectBgColorForDay;
        CGContextSetFillColorWithColor(context, bgColor.CGColor);
        CGContextFillRect(context, rect);
    }
    
    
    UIFont *font = [UIFont systemFontOfSize:12];
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGSize titleSize = SN_TEXTSIZE(_title, font);
    CGFloat titleX = (width-titleSize.width) / 2.f;
    UIColor *bgC = isN ?_titleColorForNight:_titleColorForDay;
    CGContextSetFillColorWithColor(context, bgC.CGColor);
    [_title surfDrawAtPoint:CGPointMake(titleX, (height-titleSize.height)/2) withFont:font];
    
    
    CGRect activRect = _activityView.frame;
    activRect.origin.x = titleX - CGRectGetWidth(activRect)-5;
    _activityView.frame = activRect;
    
    UIGraphicsPopContext();
}

@end
