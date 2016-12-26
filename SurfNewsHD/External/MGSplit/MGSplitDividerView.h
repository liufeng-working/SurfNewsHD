//
//  MGSplitDividerView.h
//  MGSplitView
//
//  Created by Matt Gemmell on 26/07/2010.
//  Copyright 2010 Instinctive Code.
//
#ifdef ipad
#import <UIKit/UIKit.h>
typedef enum {
    MGSplitDividerBeganStyleMin = 0,
    MGSplitDividerBeganStyleMiddle = 1,
    MGSplitDividerBeganStyleMax = 2,
    MGSplitDividerBeganStyleNone = 3
} MGSplitDividerBeganStyle;

@class MGSplitViewController;
@interface MGSplitDividerView : UIView {
	MGSplitViewController *splitViewController;
	BOOL allowsDragging;
    MGSplitDividerBeganStyle style;
}

@property (nonatomic, assign) MGSplitViewController *splitViewController; // weak ref.
@property (nonatomic, assign) BOOL allowsDragging;

- (void)drawGripThumbInRect:(CGRect)rect;

@end
#endif