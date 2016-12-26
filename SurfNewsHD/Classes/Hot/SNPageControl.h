//
//  SNPageControl.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-6-25.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PageControlDelegate;

@interface SNPageControl : UIView

// Set these to control the PageControl.
@property (nonatomic) NSInteger currentPage;
@property (nonatomic) NSInteger numberOfPages;

@property(nonatomic) BOOL hidesForSinglePage;          // hide the the indicator if there is only one page. default is NO

// Customize these as well as the backgroundColor property.
@property (nonatomic, retain) UIColor *dotColorCurrentPage; // default blackColor
@property (nonatomic, retain) UIColor *dotColorOtherPage;   // default lightGrayColor

// Optional delegate for callbacks when user taps a page dot.
@property (nonatomic, assign) NSObject<PageControlDelegate> *delegate;


- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount;   // returns minimum size required to display dots for given page count. can be used to size control if page count could change
@end

@protocol PageControlDelegate<NSObject>
@optional
- (void)pageControlPageDidChange:(SNPageControl *)pageControl;
@end