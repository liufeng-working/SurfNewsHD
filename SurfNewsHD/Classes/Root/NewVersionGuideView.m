//
//  NewVersionGuideController.m
//  SurfBrowser
//
//  Created by SYZ on 12-8-30.
//
//

#import "NewVersionGuideView.h"

@interface NewVersionGuideView ()

@end

@implementation NewVersionGuideView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Custom initialization
        imageArray = [NSArray arrayWithObjects:@"guide_image1", @"guide_image2", @"guide_image3", nil];
        
        
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,
                                                                    frame.size.width,
                                                                    frame.size.height)];
        [scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [scrollView setDelegate:self];
        [scrollView setBackgroundColor:[UIColor clearColor]];
        [scrollView setAutoresizesSubviews:YES];
        [scrollView setPagingEnabled:YES];
        scrollView.bounces = NO;
        [scrollView setShowsVerticalScrollIndicator:NO];
        [scrollView setShowsHorizontalScrollIndicator:NO];
        [scrollView setContentSize:CGSizeMake([imageArray count] * frame.size.width, frame.size.height)];
        [self addSubview:scrollView];
        
        NSInteger guidePage = 0;
        for (NSString *imageName in imageArray) {
            UIImageView *guideImageView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width * guidePage,
                            0.0f,
                            frame.size.width,
                            frame.size.height)];
            [guideImageView setImage:[UIImage imageNamed:imageName]];
            [scrollView addSubview:guideImageView];
            guidePage ++;
        }
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [backBtn setBackgroundColor:[UIColor clearColor]];
        backBtn.frame = CGRectMake(scrollView.frame.size.width* ([imageArray count]) -200,
                                   scrollView.frame.size.height - 120.0f,
                                   200.0f, 120.0f);
        [backBtn addTarget:self action:@selector(removeSelf) forControlEvents:UIControlEventTouchUpInside];
        [scrollView  addSubview:backBtn];
    }
    return self;
}

#pragma mark UIScrollViewDelegate methods
- (void)removeSelf
{
    [delegate removeNewVersionGuideControllerView:self];
}


@end
