//
//  SubscribeCenterCellSubitem.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-1-31.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SubscribeCenterCellSubitem.h"
#import "PathUtil.h"
#import "ImageDownloader.h"
#import "ContextUtil.h"
#import "SubsChannelsManager.h"


#define IconWidth 36.f
#define IconHeight 36.f
#define SubsFontSize 15.f // 订阅名称字体大小
#define ItemClickWidth 170.f

struct CGMarge{
    CGFloat top;
    CGFloat right;
    CGFloat bottom;
    CGFloat left;
};
typedef struct CGMarge CGMarge;


@implementation SubscribeCenterCellSubitem
static UIImage *defaultIcon = nil;
static UIFont *SubsFont = nil;

static CGMarge Marge = {5.f,5.f,5.f,5.f};
static CGSize ItemSize = {0.f,0.f};

@synthesize subsChannel = _subsChannel;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        if (defaultIcon == nil) {            
            SubsFont = [UIFont boldSystemFontOfSize:SubsFontSize];
            defaultIcon = [UIImage imageNamed:@"subsIcon"];
        }        
        
        
        // icon 图片
        _iconRect = CGRectMake(Marge.left, Marge.top, IconWidth, IconHeight);
        _iconView = [[UIImageView alloc] initWithFrame:_iconRect];
        [self addSubview:_iconView];
        
        _iconRect.size.height += 1;
        UIImageView *roundIconView = [[UIImageView alloc] initWithFrame:_iconRect];
        [roundIconView setImage:[UIImage imageNamed:@"roundIcon"]];
        [self addSubview:roundIconView];
        
        // 订阅名
        CGRect subsRect = CGRectMake(Marge.left + IconWidth + 9.f,
                                     (IconHeight - SubsFont.lineHeight)*0.5f + Marge.top, 118.f, SubsFont.lineHeight);
        _subsName = [[UILabel alloc]initWithFrame:subsRect];
        [_subsName setFont:SubsFont];
        [_subsName setBackgroundColor:[UIColor clearColor]];
        [_subsName setTextColor:[UIColor blackColor]];
        [self addSubview:_subsName];
        
        
        // 添加订阅按钮
        float buttonHeight = 25.f;
        _subsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _subsButton.frame = CGRectMake(173.f+Marge.left,
                                       (IconHeight - buttonHeight)*0.5f + Marge.top,
                                       55.f, buttonHeight);
        [_subsButton addTarget:self action:@selector(subsChannelButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_subsButton];
        
        [self setClearsContextBeforeDrawing:NO];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

+ (CGSize)suitableSize
{
    if (CGSizeEqualToSize(CGSizeZero, ItemSize)) {
        ItemSize.width = Marge.left+Marge.right + 228.f;
        ItemSize.height = IconHeight+Marge.top+Marge.bottom;
    }
    return ItemSize;
}

- (void)reloadData:(SubsChannel *)data
{
    _subsChannel = data;
    [_iconView setImage:defaultIcon];// 设置默认图片
    [self setIsLoadedIcon:NO];
    
    if (_subsChannel != nil) {
        
        // 订阅名称
        _subsName.text = _subsChannel.name;
        
        // 订阅按钮Title
        [self updateSubsButtonState];
    }
}

- (void)setIcon:(UIImage *)img{
    if (img != nil) {
        [self setIsLoadedIcon:YES];
        [_iconView setImage:img];
    }
    else{
        [self setIsLoadedIcon:NO];
        [_iconView setImage:defaultIcon];
    }
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if (_isClick) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        UIGraphicsPushContext(context);
        
        // 点击Item效果
        CGRect clickRect = [self bounds];
        clickRect.size.width = ItemClickWidth;
        
        CGContextSetFillColorWithColor(context, [[UIColor colorWithHexValue:kTableCellSelectedColor] CGColor]);
        CGContextFillRect(context, clickRect);
        
        UIGraphicsPopContext();
    }
}

// 设置订阅按钮状态
- (void)updateSubsButtonState{
    if (_subsChannel != nil) {
        _subsState = [[SubsChannelsManager sharedInstance] isChannelSubscribed:_subsChannel.channelId];
        UIImage *buttonImg = nil; 
        if (_subsState) {
            buttonImg = [UIImage imageNamed:@"unsubscribeButton"];
        }
        else{
            buttonImg = [UIImage imageNamed:@"subscribeButton"];
        }
        [_subsButton setBackgroundImage:buttonImg forState:UIControlStateNormal];        
    }
}

-(BOOL)checkSubsButtonState
{
    if (_subsChannel == nil) { return NO; }
    
    BOOL tempB = [[SubsChannelsManager sharedInstance] isChannelSubscribed:_subsChannel.channelId];
    if (_subsState != tempB) {
        [self updateSubsButtonState];
        return YES;
    }
    return NO;
}

// 订阅按钮事件
- (void)subsChannelButton:(UIButton*)sender{    
    if (_subsChannel != nil) {
        SubsChannelsManager *scm = [SubsChannelsManager sharedInstance];
        
        if ([scm isChannelSubscribed:_subsChannel.channelId]) {            
            [scm removeSubscription:_subsChannel];// 退订
        }
        else{
            [scm addSubscription:_subsChannel]; // 订阅
        }
        
        [self showLoadingAIV];// 显示加载动画
        
        // 提交更改
        [scm commitChangesWithHandler:^(BOOL succeeded) {

            if (succeeded) {               
                [self updateSubsButtonState];
                
                
                // 弹出提示信息
                if ([scm userSubsInfoUpSucesss]) {
                    NSString *notice = nil;
                    if (_subsState) {
                        notice = [NSString stringWithFormat:@"%@,订阅成功", [_subsChannel name]];
                    }
                    else{
                        notice = [NSString stringWithFormat:@"%@,退订成功", [_subsChannel name]];
                    }
                    [SurfNotification surfNotification:notice];
                }                
            }
            else{
                // 提交失败处理，弹出提示框
                if ([scm userSubsInfoUpSucesss]) {
                    NSString *notice = nil;
                    if (_subsState) {
                        notice = [NSString stringWithFormat:@"%@,退订失败", [_subsChannel name]];
                    }
                    else{
                        notice = [NSString stringWithFormat:@"%@,订阅失败", [_subsChannel name]];
                    }
                    [SurfNotification surfNotification:notice];
                }
            }         
            
            
            // 隐藏加载动画
            [self hideLoadingAIV];
        }];
    }
}


#pragma mark loadingAIV
// 加载风火轮动画
- (void)showLoadingAIV{
    if (_loadingAIV == nil){        
        _loadingAIV = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        float width = 20.0f;
        float height = 20.0f;
        float x = _subsButton.frame.origin.x + (_subsButton.frame.size.width - width) / 2;
        float y = _subsButton.frame.origin.y + (_subsButton.frame.size.height - height) / 2;
        [_loadingAIV setFrame:CGRectMake(x, y, width, height)];        
        [self addSubview:_loadingAIV];  
    }

    [_subsButton setHidden:YES];
    [_loadingAIV startAnimating];
}
- (void)hideLoadingAIV{
    
    if (_loadingAIV == nil)
        return;
    
    [_subsButton setHidden:NO];
    [_loadingAIV stopAnimating];// 会调用隐藏函数setHidden
}

#pragma mark Touch

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    BOOL isTouch = [super beginTrackingWithTouch:touch withEvent:event];
    if ([touch view] == self && [[event allTouches]count] == 1)
    {
        CGPoint tp =  [touch locationInView:self];
        CGRect rect = [self bounds];
        rect.size.width = ItemClickWidth;
        if (CGRectContainsPoint(rect, tp)) {
             _isClick = YES;
            isTouch = YES;
            [self setNeedsDisplayInRect:rect];
        }
    }
    return isTouch;
}
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    if ([touch view] == self && [[event allTouches]count] == 1){
        CGPoint  placard = [touch locationInView:self];
        CGRect rect = [self bounds];
        rect.size.width = ItemClickWidth;
        if (!CGRectContainsPoint(rect,  placard)) {
            if (_isClick) {
                _isClick = NO;
                [self setNeedsDisplayInRect:rect];
            }            
        }
        else{
            if (!_isClick) {
                _isClick = YES;
                [self setNeedsDisplayInRect:rect];
            }            
        }
        return YES;
    }
    return [super continueTrackingWithTouch:touch withEvent:event];
}
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super endTrackingWithTouch:touch withEvent:event];
    if (_isClick && [touch view] == self && [[event allTouches]count] == 1)
    {
        _isClick = NO;
        CGPoint placard = [touch locationInView:self];
        CGRect rect = [self bounds];
        rect.size.width = ItemClickWidth;
        if (CGRectContainsPoint(rect,  placard)){
            [[self subsCellSubitemClickDelegate] cellSubitemClick:_subsChannel];
        }
    }
    [self setNeedsDisplay];
}
- (void)cancelTrackingWithEvent:(UIEvent *)event{
    _isClick = NO;
    [super cancelTrackingWithEvent:event];
    [self setNeedsDisplay];
}

@end
