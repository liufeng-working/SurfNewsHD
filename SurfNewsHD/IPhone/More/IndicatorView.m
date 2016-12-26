//
//  IndicatorView.m
//  iOSUIFrame
//
//  Created by Jerry Yu on 13-5-22.
//  Copyright (c) 2013年 adways. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "IndicatorView.h"


@implementation IndicatorView
@synthesize activityIndicator = activityIndicator_;
@synthesize messageLabel = messageLabel_;
//@synthesize delegate = delegate_;
@synthesize containerView = containerView_;

- (id) initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor clearColor];
        containerView_ = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 120.0, 100.0)];
        containerView_.center = self.center;
        containerView_.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
        containerView_.layer.cornerRadius = 10.0;
        UIActivityIndicatorViewStyle indicatorViewStyle = UIActivityIndicatorViewStyleWhite;
//        if (IS_PAD) {
//            indicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
//        }
		activityIndicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:indicatorViewStyle];
		CGPoint actIndicatorCenter = CGPointMake(containerView_.bounds.size.width/2.0, containerView_.bounds.size.height/2.0 - 15.0);
        activityIndicator_.center = actIndicatorCenter;
        
        messageLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, containerView_.bounds.size.width, 50.0)];
        CGPoint messageLabelCenter = CGPointMake(containerView_.bounds.size.width/2.0, containerView_.bounds.size.height/2.0 + 20.0);
        messageLabel_.backgroundColor = [UIColor clearColor];
        messageLabel_.center = messageLabelCenter;
        messageLabel_.textColor = [UIColor whiteColor];
        messageLabel_.shadowColor = [UIColor blackColor];
        messageLabel_.shadowOffset = CGSizeMake(0.0, -1.0);
        messageLabel_.font = [UIFont systemFontOfSize:17.0];
        [messageLabel_ setTextAlignment:NSTextAlignmentCenter];
        messageLabel_.text = @"正在加载...";
        
        [containerView_ addSubview:activityIndicator_];
        [containerView_ addSubview:messageLabel_];
		[self addSubview:containerView_];
	}
	return self;
}
- (id) initWithOutBgWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor clearColor];
        containerView_ = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 120.0, 100.0)];
        containerView_.center = self.center;
        containerView_.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1];
        containerView_.layer.cornerRadius = 10.0;
        UIActivityIndicatorViewStyle indicatorViewStyle = UIActivityIndicatorViewStyleWhite;
//        if (IS_PAD) {
//            indicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
//        }
		activityIndicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:indicatorViewStyle];
		CGPoint actIndicatorCenter = CGPointMake(containerView_.bounds.size.width/2.0, containerView_.bounds.size.height/2.0 - 15.0);
        activityIndicator_.center = actIndicatorCenter;
        
        messageLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, containerView_.bounds.size.width, 50.0)];
        CGPoint messageLabelCenter = CGPointMake(containerView_.bounds.size.width/2.0, containerView_.bounds.size.height/2.0 + 20.0);
        messageLabel_.backgroundColor = [UIColor clearColor];
        messageLabel_.center = messageLabelCenter;
        messageLabel_.textColor = [UIColor whiteColor];
        messageLabel_.shadowColor = [UIColor blackColor];
        messageLabel_.shadowOffset = CGSizeMake(0.0, -1.0);
        messageLabel_.font = [UIFont systemFontOfSize:17.0];
        [messageLabel_ setTextAlignment:NSTextAlignmentCenter];
        messageLabel_.text = @"正在加载...";
        
        [containerView_ addSubview:activityIndicator_];
        [containerView_ addSubview:messageLabel_];
		[self addSubview:containerView_];
	}
	return self;
}
- (void)hideCloseButton:(BOOL)hidden {
    if (hidden) {
        if (closeButton_) {
            closeButton_.hidden = YES;
        }
    } else {
        if (!closeButton_) {
            closeButton_ = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 50.0)];
            [closeButton_ setImage:[UIImage imageNamed:@"closebox.png"] forState:UIControlStateNormal];
            [closeButton_ addTarget:self action:@selector(tapCloseButton) forControlEvents:UIControlEventTouchUpInside];
            closeButton_.center = CGPointMake(containerView_.frame.origin.x+containerView_.frame.size.width, containerView_.frame.origin.y+containerView_.frame.size.height);
            [self addSubview:closeButton_];
        }
        closeButton_.hidden = NO;
    }
}

- (void)tapCloseButton {
    if ([delegate_ respondsToSelector:@selector(indicatorViewDidTapCloseButton:)]) {
        [delegate_ indicatorViewDidTapCloseButton:self];
    }
}

//- (void) dealloc {
//    [activityIndicator_ removeFromSuperview];
//    [messageLabel_ removeFromSuperview];
//    [containerView_ removeFromSuperview];
//	[activityIndicator_ release];
//    [messageLabel_ release];
//    [containerView_ release];
//	[super dealloc];
//}
@end
