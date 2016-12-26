//
//  NewVersionGuideController.h
//  SurfBrowser
//
//  Created by SYZ on 12-8-30.
//
//

@protocol NewVersionGuideViewDelegate;

#import <UIKit/UIKit.h>
#import "UIColor+extend.h"

@interface NewVersionGuideView : UIView <UIScrollViewDelegate> {
    
    id<NewVersionGuideViewDelegate> delegate;
    NSArray *imageArray;
    UIScrollView *scrollView;
}

@property(nonatomic) id<NewVersionGuideViewDelegate> delegate;

@end

@protocol NewVersionGuideViewDelegate <NSObject>

- (void)removeNewVersionGuideControllerView:(NewVersionGuideView*)view;

@end