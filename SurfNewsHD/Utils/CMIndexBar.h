//
//  indexBar.h
//
//  Created by Craig Merchant on 07/04/2011.
//  Copyright 2011 RaptorApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QuartzCore/QuartzCore.h"

@protocol CMIndexBarDelegate;

@interface CMIndexBar : UIView {	
	UIColor *highlightedBackgroundColor;
}

- (id)init;
- (id)initWithFrame:(CGRect)frame;
- (void) setIndexes:(NSArray*)indexes;
- (void) clearIndex;

@property (nonatomic, unsafe_unretained) __unsafe_unretained NSObject<CMIndexBarDelegate> *delegate;
@property (nonatomic, strong) UIColor *highlightedBackgroundColor;
@property (nonatomic, strong) UIColor *textColor;
@property(nonatomic) NSInteger textFontSize;

@end

@protocol CMIndexBarDelegate<NSObject>
@optional
- (void)indexSelectionDidChange:(CMIndexBar *)IndexBar :(NSInteger)index :(NSString*)title;

- (void)touchEnd;
@end