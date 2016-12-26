//
//  EGORefreshTableFootView.m
//  SurfNewsHD
//
//  Created by Jerry Yu on 13-5-28.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "EGORefreshTableFootView.h"

@implementation EGORefreshTableFootView

#define  RefreshViewHight 65.0f
#define TEXT_COLOR          [UIColor colorWithRed:(153.0f/255.0f) green:(153.0f/255.0f) blue:(153.0f/255.0f) alpha:1.0]// [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]

#define FLIP_ANIMATION_DURATION 0.18f


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        //		self.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
        
        self.backgroundColor = [UIColor clearColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f, self.frame.size.width, 20.0f)];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        label.font = [UIFont systemFontOfSize:12.0f];
        label.textColor = TEXT_COLOR;
        label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
        label.shadowOffset = CGSizeMake(0.0f, 1.0f);
        label.backgroundColor = [UIColor clearColor];
        [label setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:label];
        _lastUpdatedLabel=label;
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 58.0f, self.frame.size.width, 20.0f)];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        label.font = [UIFont boldSystemFontOfSize:13.0f];
        label.textColor = TEXT_COLOR;
        label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
        label.shadowOffset = CGSizeMake(0.0f, 1.0f);
        label.backgroundColor = [UIColor clearColor];
        [label setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:label];
        _statusLabel=label;
        
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(25.0f, frame.size.height - 65.0f, 30.0f, 55.0f);
        layer.contentsGravity = kCAGravityResizeAspect;
        layer.contents = (id)[UIImage imageNamed:@"blueArrow.png"].CGImage;
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
            layer.contentsScale = [[UIScreen mainScreen] scale];
        }
#endif
        
        [[self layer] addSublayer:layer];
        _arrowImage=layer;
        
        UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        view.frame = CGRectMake(/*25.0f*/145.0f, frame.size.height - 38.0f, 20.0f, 20.0f);
        [self addSubview:view];
        _activityView = view;
        
        [self setState:EGOOPullRefreshNormal];
        
        grayArrow = [[UIImageView alloc] initWithFrame:CGRectMake(0, frame.size.height - 50, 320, 35)];
        [grayArrow setImage:[UIImage imageNamed:@"load2_1.jpg"]];
        [self addSubview:grayArrow];
        
        
        [self setState:EGOOPullRefreshNormal];

    }
    return self;
}

- (void)setState:(EGOPullRefreshState)aState{
    
    switch (aState) {
        case EGOOPullRefreshPulling:
            
            _statusLabel.text = NSLocalizedString(@"松开即可刷新...", @"Release to refresh status");
            [CATransaction begin];
            [CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
            _arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
            [CATransaction commit];
            
            break;
        case EGOOPullRefreshNormal:
            
            if (_state == EGOOPullRefreshPulling) {
                [CATransaction begin];
                [CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
                _arrowImage.transform = CATransform3DIdentity;
                [CATransaction commit];
            }
            
            _statusLabel.text = NSLocalizedString(@"加载更多...", @"Pull down to refresh status");
            [_activityView stopAnimating];
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            _arrowImage.hidden = NO;
            _arrowImage.transform = CATransform3DIdentity;
            [CATransaction commit];
            
            [self refreshLastUpdatedDate];
            
            break;
        case EGOOPullRefreshLoading:
            
            _statusLabel.text = NSLocalizedString(@"加载中..", @"Loading Status");
            [_activityView startAnimating];
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            _arrowImage.hidden = YES;
            [CATransaction commit];
            
            break;
        default:
            break;
    }
    
    _state = aState;
}

- (void)refreshLastUpdatedDate {
    
    if ([_tableFootDelegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceLastUpdated:)]) {
        
//NSDate *date = [_delegate egoRefreshTableHeaderDataSourceLastUpdated:self];
        
//        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//        [formatter setAMSymbol:@"AM"];
//        [formatter setPMSymbol:@"PM"];
//        [formatter setDateFormat:@"MM/dd/yyyy hh:mm:a"];
//_lastUpdatedLabel.text = [NSString stringWithFormat:@"Last Updated: %@", [formatter stringFromDate:date]];
        [[NSUserDefaults standardUserDefaults] setObject:_lastUpdatedLabel.text forKey:@"EGORefreshTableView_LastRefresh"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    } else {
        
        _lastUpdatedLabel.text = nil;
        
    }
    
}


- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (_state == EGOOPullRefreshLoading) {
        
        CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
        offset = MIN(offset, 60);
        scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
        
    } else if (scrollView.isDragging) {
        
        BOOL _loading = NO;
        if ([_tableFootDelegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
            _loading = [_tableFootDelegate egoRefreshTableHeaderDataSourceIsLoading:self];
        }
        
        if (_state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !_loading) {
            [self setState:EGOOPullRefreshNormal];
        } else if (_state == EGOOPullRefreshNormal && scrollView.contentOffset.y + (scrollView.frame.size.height) > scrollView.contentSize.height + RefreshViewHight && !_loading) {
            [self setState:EGOOPullRefreshPulling];
        }
        
        if (scrollView.contentInset.top != 0) {
            scrollView.contentInset = UIEdgeInsetsZero;
        }
        
    }
    
}

- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
    
    BOOL _loading = NO;
    if ([_tableFootDelegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
        _loading = [_tableFootDelegate egoRefreshTableHeaderDataSourceIsLoading:self];
    }
    
    if (scrollView.contentOffset.y + (scrollView.frame.size.height) > scrollView.contentSize.height + RefreshViewHight && !_loading) {
        
        if ([_tableFootDelegate respondsToSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:)]) {
            [_tableFootDelegate egoRefreshTableHeaderDidTriggerRefresh:self];
        }
        
        [self setState:EGOOPullRefreshLoading];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        scrollView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
        [UIView commitAnimations];
        
    }
    
}

- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.3];
    [scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [UIView commitAnimations];
    
    [self setState:EGOOPullRefreshNormal];
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
