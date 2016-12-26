//
//  LoadingView.m
//  SurfNewsHD
//
//  Created by apple on 13-1-17.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "LoadingView.h"

#define kPROffsetY 60.f
#define kPRMargin 5.f
#define kPRLabelHeight 20.f
#define kPRLabelWidth 100.f
#define kPRArrowWidth 20.f
#define kPRArrowHeight 40.f

#define kTextColor [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0]
#define kPRBGColor [UIColor clearColor]
#define kPRAnimationDuration .18f


#define kNormalArr  [NSArray arrayWithObjects:@"下拉刷新",@"上拉加载更多",@"下拉查看上一页", @"上拉查看下一页", nil]
#define kLoadingArr [NSArray arrayWithObjects:@"释放刷新",@"释放加载更多",@"释放查看上一页",@"释放查看下一页",nil]
#define kPullingArr [NSArray arrayWithObjects:@"正在刷新",@"正在加载",@"正在刷新",@"正在加载",nil]
#define kTheEndArr  [NSArray arrayWithObjects:@"没有了哦",@"没有了哦",@"没有了哦",@"没有了哦",nil]

#define kNormal kNormalArr[style]
#define kLoading kLoadingArr[style]
#define kPulling kPullingArr[style]
#define kTheEnd kTheEndArr[style]

@interface LoadingView ()
- (void)updateRefreshDate :(NSDate *)date;
- (void)layouts;
@end

@implementation LoadingView
@synthesize atTop = _atTop;
@synthesize state = _state;
@synthesize loading = _loading;
@synthesize style;



//Default is at top
- (id)initWithFrame:(CGRect)frame atTop:(BOOL)top {

    self = [super initWithFrame:frame];
    if (self) {
        style = StateDescriptionTableStyleTop;
        self.atTop = top;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = kPRBGColor;
        //        self.backgroundColor = [UIColor clearColor];
        UIFont *ft = [UIFont systemFontOfSize:12.f];
        _stateLabel = [[UILabel alloc] init ];
        _stateLabel.font = ft;
        _stateLabel.textColor = kTextColor;
        [_stateLabel setTextAlignment:NSTextAlignmentCenter];
        _stateLabel.backgroundColor = kPRBGColor;
        _stateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        _stateLabel.text = kNormal;
        [self addSubview:_stateLabel];
        
        _dateLabel = [[UILabel alloc] init ];
        _dateLabel.font = ft;
        _dateLabel.textColor = kTextColor;
        [_dateLabel setTextAlignment:NSTextAlignmentCenter];
        _dateLabel.backgroundColor = kPRBGColor;
        _dateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_dateLabel];
        
        _arrow = [CALayer layer];
        _arrow.frame = CGRectMake(0, 0, 20, 20);
        _arrow.contentsGravity = kCAGravityResizeAspect;
        _arrow.contents = (id)[UIImage imageWithCGImage:[UIImage imageNamed:@"webArrow.png"].CGImage scale:1 orientation:UIImageOrientationDown].CGImage;
        
        [self.layer addSublayer:_arrow];
        
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:_activityView];
        
        [self layouts];
        
    }
    return self;
}

- (void)layouts {
    
    CGSize size = self.frame.size;
    CGRect stateFrame,dateFrame,arrowFrame;
    
    float x = 0,y,margin;
    margin = (kPROffsetY - 2*kPRLabelHeight)/2;
    if (self.isAtTop) {
        y = size.height - margin - kPRLabelHeight;
        dateFrame = CGRectMake(0,y,size.width,kPRLabelHeight);
        
        y = y - kPRLabelHeight;
        stateFrame = CGRectMake(0, y, size.width, kPRLabelHeight);
        
        
        x = kPRMargin;
        y = size.height - margin - kPRArrowHeight;
        arrowFrame = CGRectMake(4*x, y, kPRArrowWidth, kPRArrowHeight);
        
        UIImage *arrow = [UIImage imageNamed:@"webArrow.png"];
        _arrow.contents = (id)arrow.CGImage;
        
    } else {    //at bottom
        y = margin;
        stateFrame = CGRectMake(0, y, size.width, kPRLabelHeight );
        
        y = y + kPRLabelHeight;
        dateFrame = CGRectMake(0, y, size.width, kPRLabelHeight);
        
        x = kPRMargin;
        y = margin;
        arrowFrame = CGRectMake(4*x, y, kPRArrowWidth, kPRArrowHeight);
        
        UIImage *arrow = [UIImage imageNamed:@"webArrowDown.png"];
        _arrow.contents = (id)arrow.CGImage;
    }
    _stateLabel.text = kNormal;
    _stateLabel.frame = stateFrame;
    _dateLabel.frame = dateFrame;
    //_arrowView.frame = arrowFrame;
    //_activityView.center = _arrowView.center;
    
    float activityCenterX = CGRectGetMidX(arrowFrame);
    float activityCenterY = CGRectGetMidY(arrowFrame);
    CGRect activityRect = CGRectMake(activityCenterX-20, activityCenterY-20, 40, 40);
    _activityView.frame = activityRect;
    
    
    _arrow.frame = arrowFrame;
    _arrow.transform = CATransform3DIdentity;
}


- (void)setState:(PRState)state {
    [self setState:state animated:YES];
}

- (void)setState:(PRState)state animated:(BOOL)animated{
    float duration = animated ? kPRAnimationDuration : 0.f;
    if (_state != state) {
        PRState oldState = _state;
        _state = state;
        if (_state == kPRStateLoading) {    //Loading
            
            _arrow.hidden = YES;
            _activityView.hidden = NO;
            [_activityView startAnimating];
            
            _loading = YES;
            if (self.isAtTop) {
                _stateLabel.text = kPulling;
            } else {
                _stateLabel.text = kPulling;
            }
            
        } else if (_state == kPRStatePulling && !_loading) {    //Scrolling
            
            _arrow.hidden = NO;
            _activityView.hidden = YES;
            [_activityView stopAnimating];
            
            [CATransaction begin];
            [CATransaction setAnimationDuration:duration];
            _arrow.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            [CATransaction commit];
            
            if (self.isAtTop) {
                _stateLabel.text = kLoading;
            } else {
                _stateLabel.text = kLoading;
            }
            
        } else if (_state == kPRStateLocalDisplay && !_loading){    //Reset
            
            _arrow.hidden = NO;         // 箭头显示
            _activityView.hidden = YES; // 风火轮动画隐藏
            [_activityView stopAnimating];// 停止动画
            
            [CATransaction begin];
            [CATransaction setAnimationDuration:duration];
            _arrow.transform = CATransform3DIdentity;
            [CATransaction commit];
            
            if (self.isAtTop) {
                _stateLabel.text = kNormal;
            } else {
                _stateLabel.text = kNormal;
            }
            
            // 更新时间显示
            if (oldState == kPRStateNormal){
                 [self updateRefreshDate:refreshDate];// 更新显示时间
            }
        } else if (_state == kPRStateHitTheEnd) {
            if (!self.isAtTop) {    //footer
                _arrow.hidden = YES;
                _stateLabel.text = kTheEnd;
            }
        }
        else if(_state == kPRStateNormal){
            _arrow.hidden = NO;
            _activityView.hidden = YES;
            [_activityView stopAnimating];
            
            [CATransaction begin];
            [CATransaction setAnimationDuration:duration];
            _arrow.transform = CATransform3DIdentity;
            [CATransaction commit];
        }            
    }
}

- (void)setLoading:(BOOL)loading {
    _loading = loading;
}
-(void)updateRefreshTitle:(NSString *)title
{
    _dateLabel.text = title;
}

- (void)updateRefreshDate :(NSDate *)date{
    if (date == nil) {
        _dateLabel.text = @"上次刷新:从未";
        return;
    }
    
    if(refreshDate != date)
        refreshDate = date;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd HH:mm";
    NSString *dateString = [df stringFromDate:date];
    NSString *title = @"今天";
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|kCFCalendarUnitHour|kCFCalendarUnitMinute|kCFCalendarUnitSecond
                                               fromDate:date toDate:[NSDate date] options:0];
    NSInteger year = [components year];
    NSInteger month = [components month];
    NSInteger day = [components day];
    bool isToday = NO;
    if (year == 0 && month == 0 && day < 3) {
        if (day == 0) {
            isToday = YES;            
            if ([components hour] == 0) {
                if ([components minute] == 0){
                    if([components second] > 5){
                        dateString = [NSString stringWithFormat:@"%@秒之前", @([components second])];
                    }
                    else{
                        dateString = @"刚刚";
                    }
                }
                else{
                    dateString = [NSString stringWithFormat:@"%@分钟之前", @([components minute])];
                }
            }
            else{
                  dateString = [NSString stringWithFormat:@"%@小时之前", @([components hour])];
            }
            
        } else if (day == 1) {
            title = @"昨天";
            df.dateFormat = [NSString stringWithFormat:@"%@ HH:mm",title];
            dateString = [df stringFromDate:date];
        } else if (day == 2) {
            title = @"前天";
            df.dateFormat = [NSString stringWithFormat:@"%@ HH:mm",title];
            dateString = [df stringFromDate:date];
        }
    }
    
    if(isToday){
        _dateLabel.text =[NSString stringWithFormat:@"%@: %@",
                          @"上次刷新", dateString];
    }
    else{
        _dateLabel.text = [NSString stringWithFormat:@"%@: %@",
                           @"最后更新", dateString];
    }    
}

-(void)viewNightModeChanged:(BOOL)isNight{
    if (isNight) {
        // 风火轮颜色
        _activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    }
    else{
        _activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    }
}
@end