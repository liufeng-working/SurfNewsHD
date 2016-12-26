//
//  SNPageControl.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-6-25.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SNPageControl.h"

#define kCurDotDiameter 5.0 // 高亮点直径
#define kDotDiameter 2.5    // 点的直径
#define kDotSpacer 7.5      // 点的间隔


@implementation SNPageControl
@synthesize dotColorCurrentPage;
@synthesize dotColorOtherPage;
@synthesize delegate;
@synthesize currentPage = _currentPage;
@synthesize numberOfPages = _numberOfPages;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.dotColorCurrentPage = [UIColor blackColor];
        self.dotColorOtherPage = [UIColor lightGrayColor];
    }
    return self;
}

- (void)setCurrentPage:(NSInteger)page
{
    _currentPage = MIN(MAX(0, page), _numberOfPages-1);
    [self setNeedsDisplay];
}


- (void)setNumberOfPages:(NSInteger)pages
{
    _numberOfPages = MAX(0, pages);
    _currentPage = MIN(MAX(0, _currentPage), _numberOfPages-1);
    [self setNeedsDisplay];
}

// returns minimum size required to display dots for given page count. can be used to size control if page count could change
- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount
{
    NSInteger count = MAX(0, pageCount - 1);
    float dotW = kCurDotDiameter + count * kDotDiameter;    // 圆点总宽度
    float spacerW = count * kDotSpacer;                     // 圆点间隔宽度
    float width = dotW + spacerW;
    float height = kDotDiameter + kDotDiameter;
    return CGSizeMake(width, height);
}


- (void)drawRect:(CGRect)rect
{
    if (_numberOfPages == 1 && _hidesForSinglePage) {
        return;
    }

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, true);
    
    CGRect currentBounds = self.bounds;
    float offsetV = (kCurDotDiameter-kDotDiameter)/2.f;
    CGFloat x = offsetV;
    CGFloat y = CGRectGetMidY(currentBounds)-kDotDiameter/2;
    for (int i=0; i<_numberOfPages; i++)
    {
        CGRect circleRect = CGRectMake(x, y, kDotDiameter, kDotDiameter);
        if (i == _currentPage) {
            circleRect = CGRectMake(x-offsetV, y-offsetV, kCurDotDiameter, kCurDotDiameter);
            CGContextSetFillColorWithColor(context, self.dotColorCurrentPage.CGColor);
        }
        else {
            CGContextSetFillColorWithColor(context, self.dotColorOtherPage.CGColor);
        }
        CGContextFillEllipseInRect(context, circleRect);
        x += kDotDiameter + kDotSpacer;
    }
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.delegate) return;
    
    CGPoint touchPoint = [[[event touchesForView:self] anyObject] locationInView:self];
    
    CGFloat dotSpanX = self.numberOfPages*(kDotDiameter + kDotSpacer);
    CGFloat dotSpanY = kDotDiameter + kDotSpacer;
    
    CGRect currentBounds = self.bounds;
    CGFloat x = touchPoint.x + dotSpanX/2 - CGRectGetMidX(currentBounds);
    CGFloat y = touchPoint.y + dotSpanY/2 - CGRectGetMidY(currentBounds);
    
    if ((x<0) || (x>dotSpanX) || (y<0) || (y>dotSpanY)) return;
    
    self.currentPage = floor(x/(kDotDiameter+kDotSpacer));
    if ([self.delegate respondsToSelector:@selector(pageControlPageDidChange:)])
    {
        [self.delegate pageControlPageDidChange:self];
    }
}


@end
