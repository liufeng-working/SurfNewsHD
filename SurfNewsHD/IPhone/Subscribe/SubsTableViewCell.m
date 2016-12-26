//
//  SubsTableViewCell.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-5-24.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SubsTableViewCell.h"
#import "PathUtil.h"
#import "ImageDownloader.h"
#import "SubsChannelsManager.h"
#import "SubsChannelsListResponse.h"
#import "UIAlertView+Blocks.h"
#import "SubsChannelsView.h"
#import "NSString+Extensions.h"
#import "ThreadsManager.h"
#import "DateUtil.h"
#import "NSString+Extensions.h"

#define Icon_Width 36.f
#define Icon_Height 36.f
#define SubsNameFontSize 16.f
#define SubsDescFontSize 12.f
#define SubsCell_Height 56.f



@implementation SubsTableViewCell
+ (float)CellHeight{
    return SubsCell_Height;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}

- (void)reloadSubsChannel:(SubsChannel*)subs
                indexPath:(NSIndexPath*)path
                 onlySubs:(BOOL)only
{
    _subsChannel = subs;
    _cellIndex = path;
    [self loadIconImage:subs];// 加载图标
    [self viewNightModeChanged:[ThemeMgr sharedInstance].isNightmode];// 设置夜间模式
}


#pragma mark private method
-(void)viewNightModeChanged:(BOOL)isNight
{
    if (isNight) {
        _bgColor = [UIColor clearColor];
        _titleColor = [UIColor whiteColor];
        _lineColor = [UIColor colorWithHexValue:0xFF1b1b1c];
        _selectBgColor = [UIColor colorWithHexValue:kTableCellSelectedColor_N];
    }
    else {
        _bgColor = [UIColor clearColor];
        _titleColor = [UIColor colorWithHexValue:0xFF34393D];
        _lineColor = [UIColor colorWithHexValue:0xFFF0F0F0];
        _selectBgColor = [UIColor colorWithHexValue:kTableCellSelectedColor];
    }
    [self setNeedsDisplay];
}

#pragma mark private method

- (void)drawContentView:(CGRect)rect highlighted:(BOOL)highlighted
{
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    
    
    // 背景
    CGColorRef bgColor = _bgColor.CGColor;
    if (highlighted) {
        bgColor = _selectBgColor.CGColor;
    }
    CGContextSetFillColorWithColor(context, bgColor);
    CGContextFillRect(context, rect);
    

    // icon
    float iconX = 8.f;
    float iconY = (rect.size.height - Icon_Height) * 0.5;
    if (_iconImage) {
        [_iconImage drawInRect:CGRectMake(iconX, iconY, Icon_Width, Icon_Height)];
    }

    
    // 绘制订阅频道名
    if (_subsChannel.name.length > 0) {
        UIFont *nameFont = [UIFont boldSystemFontOfSize:SubsNameFontSize];
        CGFloat strX = iconX + Icon_Width + 10;
        CGFloat strY = rect.size.height*0.5 - nameFont.lineHeight;
        CGRect strRect = CGRectMake(strX, strY, 180, nameFont.lineHeight);
        [_subsChannel.name surfDrawString:strRect withFont:nameFont withColor:_titleColor lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
    }
    
    // 频道下的第一条新闻
    if (_subsChannel.newsTitle.length >0) {
        
        UIFont *nameFont = [UIFont boldSystemFontOfSize:SubsDescFontSize];
        CGFloat strX = iconX + Icon_Width + 10;
        CGFloat strY = rect.size.height*0.5 + 5;
        CGRect strRect = CGRectMake(strX, strY, 180, nameFont.lineHeight);
        [_subsChannel.newsTitle surfDrawString:strRect
                                      withFont:nameFont
                                     withColor:[UIColor colorWithHexValue:0xFF999292]
                                 lineBreakMode:NSLineBreakByCharWrapping
                                     alignment:NSTextAlignmentLeft];
        
    }
    
    
    //TODO: 时间
    double timeInterval = _subsChannel.threadsSummaryMaxTime;
    if (timeInterval > 0) {
        UIFont *timeFont = [UIFont systemFontOfSize:8];
        NSString *timeStr = [DateUtil calcTimeInterval:timeInterval/1000];
        CGSize timeSize = [timeStr surfSizeWithFont:timeFont constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) lineBreakMode:NSLineBreakByCharWrapping];;
        CGFloat tY = (height- timeSize.height)/2;
        CGFloat tX = width - 20 - timeSize.width;
        CGRect tR = CGRectMake(tX, tY, timeSize.width, timeSize.height);
        [timeStr surfDrawString:tR
                       withFont:timeFont
                      withColor:[UIColor blackColor]
                  lineBreakMode:NSLineBreakByCharWrapping
                      alignment:NSTextAlignmentCenter];
    }



    // 分割线
    CGFloat lineW = width;
    CGFloat lineH = height - 0.5f;
    CGContextSetStrokeColorWithColor(context, _lineColor.CGColor);
    CGContextMoveToPoint(context, 0, lineH);
    CGContextAddLineToPoint(context, lineW, lineH);
    CGContextStrokePath(context);
    
    UIGraphicsPopContext();
}


// 加载Icon图片
- (void)loadIconImage:(SubsChannel*)sc
{
    _iconImage = nil;
    if (sc == nil) {
        return;
    }
    
    // 给UIImageView 设置图片
    NSString *imgPath = [PathUtil pathOfSubsChannelLogo:sc];
    NSFileManager* fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:imgPath])
    {
        // 图片文件不存在
        ImageDownloadingTask *task = [ImageDownloadingTask new];
        [task setImageUrl:sc.ImageUrl];
        [task setUserData:sc];
        [task setTargetFilePath:imgPath];
        [task setCompletionHandler:^(BOOL succeeded, ImageDownloadingTask *idt)
         {
             if (succeeded && idt != nil )
             {
                 SubsChannel *subsChnl = idt.userData;
                 if (subsChnl.channelId == _subsChannel.channelId)
                 {
                     _iconImage = [UIImage imageWithData:[idt resultImageData]];
                     [self setNeedsDisplay];
                 }
             }
             else {
                 _iconImage = nil;
             }
         }];
        [[ImageDownloader sharedInstance] download:task];
    }
    else
    {
        // 图片存在
        dispatch_async(dispatch_get_main_queue(), ^{
            _iconImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:imgPath]];
            [self setNeedsDisplay];
        });
    }
}
@end





//////////////////////////////////////////////////////////////////
#import "ThreadSummary.h"
#import "PictureThreadView.h"

//#define SummaryCell_Height 90.f
//#define PictureWidth 90.f       // 图片宽度
//#define PictureHeight 90.f      // 图片高度
//#define ErrorFontSize 15



@implementation SubsThreadSummaryViewCell
// 加载状态和异常状态使用的高度
+ (float)LoadingOrErrorStateCellHeight
{
    return 90.f ;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
//        self.isNotMaxWidth = YES;
        _threads = [NSMutableArray arrayWithCapacity:3];
        _titleAlignment = NSTextAlignmentLeft;   
        self->selectedContentView.backgroundColor = [UIColor clearColor];
        
        
        // 添加手势监听        
        UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:nil];
        gesture.delegate = self;
        gesture.minimumPressDuration = 0.06f;
        [self addGestureRecognizer:gesture];
        
        
        _threadsViwe = [NSMutableArray arrayWithCapacity:3];
        
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_hotweel) {
        [_hotweel setFrame:self->contentView.bounds];
    }
    
    // 需要设置空间宽度。
    [_threadsViwe enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *v = (UIView*)obj;
        CGRect tmpRect = v.frame;
        tmpRect.size.width = CGRectGetWidth(self->contentView.bounds);
        v.frame = tmpRect;
    }];
}

- (void)reloadDataWithThreadSummaryArray:(NSArray*)threads isLoading:(BOOL)isLoading isError:(BOOL)error
{
    _status = 0;
    [self stopHotweel];
    [_threads removeAllObjects];
    Class classType = [ThreadSummary class];
    for (id object in threads){
        if ([object isKindOfClass:classType]){
            [_threads addObject:object];
        }
    }
    
    // 添加一样的Views，本来是不要加入到contentView中，直接在drawRect绘制，
    // 发现这样绘制下载好的图片不能通知刷屏，只好在加入到View中。
    while (_threads.count > _threadsViwe.count) {
        PictureThreadView *v = [[PictureThreadView alloc] initWithFrame:CGRectZero];
        [_threadsViwe addObject:v];
    }
    for (int i=0; i< _threadsViwe.count; ++i) {
        UIView *v = [_threadsViwe objectAtIndex:i];
        [v removeFromSuperview];
    }
    for (int i=0; i< _threads.count; ++i) {
        UIView *v = [_threadsViwe objectAtIndex:i];
        [self->contentView addSubview:v];
    }
    
    // 修改View绘制区域
    float viewY = 0;
    for (int i=0; i<_threads.count; ++i) {
        ThreadSummary *ts = _threads[i];
        PictureThreadView *v = _threadsViwe[i];        
        v.frame = CGRectMake(0, viewY, 0, 0);
        [v reloadThreadSummary:ts];
        viewY += CGRectGetHeight(v.bounds);
    }
    
    
    if (isLoading){
        _status = 1;
        [self startHotweel];
    }
    else if(error)
        _status = 2;    
    
    // 是否需要隐藏view
    [_threadsViwe enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ((UIView*)obj).hidden = (_status == 0) ? NO : YES;
    }];

}

-(ThreadSummary*)getSelectionThreadSummary
{
    if (!CGRectIsEmpty(_touchRect)) {
        for (int i=0; i<_threadsViwe.count; ++i) {
            UIView *v = _threadsViwe[i];
            if (CGRectContainsRect(v.frame, _touchRect)) {                
                return _threads[i];
            } 
        }
    }
    return nil;
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (!selected)
    {
        _touchRect = CGRectZero;
    }
}

// 启动风火轮
- (void)startHotweel
{
    if (_status == 1)
    {
        if (!_hotweel)
        {
            UIActivityIndicatorViewStyle style = [ThemeMgr sharedInstance].isNightmode ? UIActivityIndicatorViewStyleWhite:UIActivityIndicatorViewStyleGray;
            _hotweel = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
            [_hotweel startAnimating];
            [self->contentView addSubview:_hotweel];
            self.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
}
- (void)stopHotweel
{
    if (_hotweel)
    {
        [_hotweel stopAnimating];
        [_hotweel removeFromSuperview];
        _hotweel = nil;
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
}
- (void)viewNightModeChanged:(BOOL)isNight
{
    if (isNight) {
        _bgColor = [UIColor colorWithHexValue:0xFF2D2E2F];
        _titleColor = [UIColor colorWithHexValue:0xFF999292];
        _partinglineColor = [UIColor colorWithHexValue:0xFF1b1b1c];
        _selectBgColor = [UIColor colorWithHexValue:kTableCellSelectedColor_N];
    }
    else {
        _bgColor = [UIColor colorWithHexValue:0xFFF8F8F8];
        _titleColor = [UIColor colorWithHexValue:0xFF999292];
        _partinglineColor = [UIColor colorWithHexValue:0xFFF0F0F0];
        _selectBgColor = [UIColor colorWithHexValue:kTableCellSelectedColor];
    }
    [self setNeedsDisplay];
    
    // 注：这个地方很特别，发现在夜间模式切换的时候，放进self->contentView里面的View不刷新。导致字体颜色不切换。
    // 只好单独拿出来刷新。 by xuxg
    for (UIView *subView in _threadsViwe) {
        [subView setNeedsDisplay];
    }
}



- (void)drawContentView:(CGRect)rect highlighted:(BOOL)highlighted
{
    // 因自己绘制，不加这个，在高亮的时候，背景会绘制黑色的。    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    CGContextClearRect(context, rect);
    CGColorRef bgColorRef = _bgColor.CGColor;
    
    
    // 0 正常状态  1 加载状态   2 error
    if (_status == 0) {
        // 绘制单个的cell的高亮特效
        if (highlighted && !CGRectIsEmpty(_touchRect)) {
            CGContextSetFillColorWithColor(context, _selectBgColor.CGColor);
            CGContextFillRect(context, _touchRect);
            
            // 绘制订阅列表
            for (UIView *subView in _threadsViwe) {
                if (CGRectContainsRect(subView.frame, _touchRect)) {
                    [subView drawRect:subView.frame];
                }
            }
        }
        else{
            // 绘制背景
            CGContextSetFillColorWithColor(context, bgColorRef);
            CGContextFillRect(context, rect);
        }
    }
    else if (_status == 2) {
        // 绘制背景
        CGContextSetFillColorWithColor(context, bgColorRef);
        CGContextFillRect(context, rect);
        
        if (_errorFont== nil) {
            _errorFont = [UIFont systemFontOfSize:15];
        }
        float halfHeight = CGRectGetHeight(rect)*0.5;
        NSString *errStr1 = @"刷新失败";
        NSString *errStr2 = @"下拉列表重新获取频道内容";
        
        CGRect errRect1 = rect;
        errRect1.size.height = _errorFont.lineHeight;
        errRect1.origin.y = halfHeight -_errorFont.lineHeight;
        [errStr1 surfDrawString:errRect1
                       withFont:_errorFont
                      withColor:_titleColor
                  lineBreakMode:NSLineBreakByCharWrapping
                      alignment:NSTextAlignmentCenter];
        
        
        
        CGRect errRect2 = errRect1;
        errRect2.origin.y = halfHeight;
        [errStr2 surfDrawString:errRect2
                       withFont:_errorFont
                      withColor:_titleColor
                  lineBreakMode:NSLineBreakByCharWrapping
                      alignment:NSTextAlignmentCenter];
        
    }
    else if(_status == 1) {
        // 绘制背景
        CGContextSetFillColorWithColor(context, bgColorRef);
        CGContextFillRect(context, rect);
    }
    
    UIGraphicsPopContext();
}


// called before touchesBegan:withEvent: is called on the gesture recognizer for a new touch. return NO to prevent the gesture recognizer from seeing this touch
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (_hotweel) {
        return YES;
    }
    
    if (_status == 0)
    {
        CGPoint touchPoint = [touch locationInView:self];
        for (UIView* v in _threadsViwe) {
            if (CGRectContainsPoint(v.frame, touchPoint)) {
                _touchRect = v.frame;
                break;
            }
        }
    }
    return NO;
}
@end







///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
// 置顶和退订控件
@implementation CustomSubsChannelEditingView
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _topImage = [UIImage imageNamed:@"top"];
        _unsubsImage = [UIImage imageNamed:@"close1"];
        
        // 手势事件        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
        gesture.delegate = self;
        [self addGestureRecognizer:gesture];
    }
    return self;
}

- (void)setHidden:(BOOL)hidden{
    [super setHidden:hidden];
    _topHightlight = NO;
    _unsubsHightlight = NO;
}

// called before touchesBegan:withEvent: is called on the gesture recognizer for a new touch. return NO to prevent the gesture recognizer from seeing this touch
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{  
    _topHightlight = NO;
    _unsubsHightlight = NO;
    CGPoint touchPoint = [touch locationInView:self];
    if (touchPoint.x <= CGRectGetWidth(self.bounds)/2)
    {
        _topHightlight = YES;
    }
    else{
        _unsubsHightlight = YES;
    }
    [self setNeedsDisplay];
    return NO;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_topHightlight)
    {
        [self topButtonClick];
    }
    else if (_unsubsHightlight)
    {
        [self unSubscribeClick];
    }
    
    
    if (_topHightlight || _unsubsHightlight) {
        _topHightlight = NO;
        _unsubsHightlight = NO;
        [self setNeedsDisplay];
    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_topHightlight || _unsubsHightlight) {
        _topHightlight = NO;
        _unsubsHightlight = NO;
        [self setNeedsDisplay];
    }
}

#pragma mark Button Click
- (void)topButtonClick
{
    if (_subsChannel != nil)
    {
        SubsChannelsManager *scm = [SubsChannelsManager sharedInstance];
        NSMutableArray *subsArray = [scm visibleSubsChannels];
        
        for (SubsChannel* channel in subsArray)
        {
            if(channel.channelId == _subsChannel.channelId)
            {
                [subsArray removeObject:channel];
                [subsArray insertObject:channel atIndex:0];
                [scm commitChangesWithHandler:^(BOOL succeeded) {
                    if (!succeeded) {
                        [PhoneNotification autoHideWithText:@"网络异常，置顶失败"];
                    }
                }];
                break;
            }
        }
    }
    
    // 隐藏窗口
    [_operateView hiddenOperateView];
}

- (void)unSubscribeClick
{
    //最后一个栏目不能退订
    if ([[SubsChannelsManager sharedInstance] alreadyLastChannel])
    {
        // 恢复cell状态        
        [PhoneNotification autoHideWithText:@"您必须保留至少一个订阅栏目"];
        
        // 隐藏窗口
        [_operateView hiddenOperateView];
        return;
    }
    
    if (_subsChannel != nil)
    {
        NSString *title = [NSString stringWithFormat:@"是否确认退订\"%@\"",_subsChannel.name];
        RIButtonItem *cancel = [RIButtonItem itemWithLabel:@"取消" action:nil];
        RIButtonItem *ok = [RIButtonItem itemWithLabel:@"确定" action:
        ^{
            SubsChannelsManager *scm = [SubsChannelsManager sharedInstance];
            [scm removeSubscription:_subsChannel];
            [PhoneNotification manuallyHideWithIndicator];
            [scm commitChangesWithHandler:^(BOOL succeeded) {
                [PhoneNotification hideNotification];
                if (!succeeded) {
                    [PhoneNotification autoHideWithText:@"退订失败"];
                }
                else{
                    [PhoneNotification autoHideWithText:@"退订成功"];
                }
            }];
            
            
            // 隐藏窗口
            [_operateView hiddenOperateView];
        }];
        
        [[[UIAlertView alloc] initWithTitle:title message:nil
                           cancelButtonItem:cancel
                           otherButtonItems:ok, nil] show];
    }
}

-(void)viewNightModeChanged:(BOOL)isNight
{
    if (isNight)
    {
        _bgColor = [UIColor colorWithHexValue:0xFF1b1b1c];
        _btnTextHLColor = [UIColor colorWithHexValue:0xff999292];
        _btnHLBgColor = [UIColor colorWithHexValue:0xFFAD2F2F];
        _separatorColor = [UIColor colorWithHexValue:0xFF1B1B1C];
    }
    else
    {
        _bgColor = [UIColor colorWithHexValue:0xFFF1F1F1];
        _btnTextHLColor = [UIColor blackColor];
        _btnHLBgColor = [UIColor colorWithHexValue:0xFFAD2F2F];        
        _separatorColor = [UIColor colorWithHexValue:0xFFDCDBDB];
    }
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect
{    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);

    float drawX = 0;
    float drawY = 0;
    float drawWidth = CGRectGetWidth(rect);
    float drawHeight = CGRectGetHeight(rect);
    float halfWidth = drawWidth / 2;
    UIFont *btnFont = [UIFont systemFontOfSize:15.f];
    UIColor *btnColor = [UIColor colorWithHexValue:0xFF999292];
    CGContextSetFillColorWithColor(context, _bgColor.CGColor);    // 背景颜色
    CGContextFillRect(context, rect);
 

    
    // 置顶按钮
    // 按钮高亮背景
    if (_topHightlight)
    {
        CGRect topBgRect = CGRectMake(drawX, drawY, halfWidth-1, drawHeight);
        CGContextSetFillColorWithColor(context, _btnHLBgColor.CGColor);
        CGContextFillRect(context, topBgRect);
        
        // 设置文字颜色
        CGContextSetFillColorWithColor(context, _btnTextHLColor.CGColor);
    }
    else{
        CGContextSetFillColorWithColor(context, btnColor.CGColor);
    }
    
    float topImgX = drawX + 10.f;
    float topImgY = drawY + (drawHeight - _topImage.size.height) *0.5f;
    [_topImage drawAtPoint:CGPointMake(topImgX, topImgY)];
    
    NSString *topStr = @"置顶";
    CGSize topStrSize = SN_TEXTSIZE(topStr, btnFont);
    float topStrX = drawX + 35.f;
    float topStrY = drawY + (drawHeight-topStrSize.height) * 0.5f;
    [topStr surfDrawAtPoint:CGPointMake(topStrX, topStrY) withFont:btnFont];
    
    
    // 绘制分割线
    float separatorX = drawX + drawWidth / 2;
    float separatorW = drawHeight * 0.6;
    float separatorY = drawY + (drawHeight - separatorW) * 0.5f;
    CGContextSetStrokeColorWithColor(context, _separatorColor.CGColor);
    CGContextMoveToPoint(context, separatorX, separatorY);
    CGContextAddLineToPoint(context, separatorX, separatorY + separatorW);
    CGContextStrokePath(context);
    
    
    // 退订按钮
    if (_unsubsHightlight)
    {
        CGRect unsubsBgRect = CGRectMake(drawX + halfWidth+1, drawY, halfWidth, drawHeight);
        CGContextSetFillColorWithColor(context, _btnHLBgColor.CGColor);
        CGContextFillRect(context, unsubsBgRect);
        
        // 设置文字颜色
        CGContextSetFillColorWithColor(context, _btnTextHLColor.CGColor);
    }
    else{
        CGContextSetFillColorWithColor(context, btnColor.CGColor);
    }
    
    
    CGFloat unsubsImgX = drawX + separatorX + 10.f;
    CGFloat unsubsImgY = drawY + (drawHeight - _unsubsImage.size.height) *0.5f;
    [_unsubsImage drawAtPoint:CGPointMake(unsubsImgX, unsubsImgY)];
    
    
    NSString *unsubsStr = @"退订";
    CGFloat unsubsStrX = separatorX + 35;
    CGSize unsubsStrSize = SN_TEXTSIZE(unsubsStr, btnFont);
    CGFloat unsubsStrY = drawY + (drawHeight-unsubsStrSize.height) * 0.5f;
    [unsubsStr surfDrawAtPoint:CGPointMake(unsubsStrX, unsubsStrY) withFont:btnFont];
    
    UIGraphicsPopContext();
}

@end




/////////////////////////////////////////////////////////
// SubsChannelLoadMoreCell
/////////////////////////////////////////////////////////
@implementation SubsChannelLoadMoreCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
//        self.isNotMaxWidth = YES;
    }
    return self;
}


- (void)drawContentView:(CGRect)rect highlighted:(BOOL)highlighted
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    
    CGColorRef bgColorRef = _bgColor.CGColor;
    if (highlighted) {
        bgColorRef = _selectBgColor.CGColor;
    }
    
    // 绘制背景
    CGContextSetFillColorWithColor(context, bgColorRef);
    CGContextFillRect(context, rect);
    
    // 绘制文字
    UIFont *font = [UIFont systemFontOfSize:13];
    CGRect titleRect = CGRectInset(rect, 0, (rect.size.height - font.lineHeight )*0.5);
    [_title surfDrawString:titleRect
                  withFont:font
                 withColor:_titleColor
             lineBreakMode:NSLineBreakByTruncatingTail
                 alignment:NSTextAlignmentCenter];
    
    
    UIGraphicsPopContext();    
}

-(void)viewNightModeChanged:(BOOL)isNight
{
    if (isNight)
    {
        _bgColor = [UIColor colorWithHexValue:0xFF3C3D3E];
        _titleColor= [UIColor colorWithHexValue:0xFF999292];
        _selectBgColor = [UIColor colorWithHexValue:kTableCellSelectedColor_N];
    }
    else
    {
        _bgColor = [UIColor whiteColor];
        _titleColor = [UIColor colorWithHexValue:0xFF999292];
        _selectBgColor = [UIColor colorWithHexValue:kTableCellSelectedColor];
    }
    [self setNeedsDisplay];
}
@end


@implementation UITableViewEditingOperateView
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        CGRect editingRect = CGRectMake(0, 0, 145.f, 40);
        _subsChannelEidtingView = [[CustomSubsChannelEditingView alloc] initWithFrame:editingRect];
        _subsChannelEidtingView.hidden = YES;        
        _subsChannelEidtingView.operateView = self;
        
        _maskView = [[UIView alloc] initWithFrame:editingRect];
        [self addSubview:_maskView];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)showOperateView:(CGRect)cellRect subsChannel:(SubsChannel*)sc
{
    [self setUserInteractionEnabled:YES];
    [self setHidden:NO];
    [_subsChannelEidtingView setHidden:NO];
    _subsChannelEidtingView.subsChannel = sc;
    
    float cw = CGRectGetWidth(cellRect);
    float ch = CGRectGetHeight(cellRect);
    float w = CGRectGetWidth(_subsChannelEidtingView.bounds);
    float h = CGRectGetHeight(_subsChannelEidtingView.bounds);
    CGRect rect = _subsChannelEidtingView.bounds;
    rect.origin = CGPointMake(cw-w-15, cellRect.origin.y + (ch-h)/2);
    _subsChannelEidtingView.frame = rect;
    [_subsChannelEidtingView viewNightModeChanged:[ThemeMgr sharedInstance].isNightmode];
    [_subsChannelEidtingView setNeedsDisplay];
    
    
    CGRect endMaskRect = [self convertRect:rect fromView:_subsChannelEidtingView.superview];
    CGRect beginMaskRect = endMaskRect;
    endMaskRect.size.width = 0;

    _maskView.backgroundColor = [UIColor whiteColor];
    if ([ThemeMgr sharedInstance].isNightmode) {
         _maskView.backgroundColor = [UIColor colorWithHexValue:0xFF3c3d3e];
    }
    _maskView.frame = beginMaskRect;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _maskView.frame = endMaskRect;
    } completion:^(BOOL finished) {

    }];

}

- (void)hiddenOperateView
{
    [self setUserInteractionEnabled:NO];
    CGRect endMaskRect = _maskView.frame;
    endMaskRect.size.width = _subsChannelEidtingView.bounds.size.width;
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _maskView.frame = endMaskRect;        
    } completion:^(BOOL finished) {        
        
        [self setHidden:YES];
        [_subsChannelEidtingView setHidden:YES];
        
        if ([[self superview] isKindOfClass:[SubsChannelsView class]])
        {
            SubsChannelsView *scv = (SubsChannelsView*)[self superview];
            [scv handleEditingOperateViewHidderEvent];
        }
        
    }];
}


- (void)viewNightModeChanged:(BOOL)isNight
{
    [_subsChannelEidtingView viewNightModeChanged:isNight];
   
    if (isNight) {
        _maskView.backgroundColor = [UIColor colorWithHexValue:0xFF3c3d3e];
    }
    else{
        _maskView.backgroundColor = [UIColor whiteColor];
    }
}
#pragma mark touches

-(UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *v = [super hitTest:point withEvent:event];
    CGPoint editingViewPoint = [_subsChannelEidtingView convertPoint:point fromView:v];
    if (!_subsChannelEidtingView.hidden && CGRectContainsPoint(_subsChannelEidtingView.bounds, editingViewPoint)) {
        return _subsChannelEidtingView;
    }
    return v;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hiddenOperateView];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hiddenOperateView];
}
@end


