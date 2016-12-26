//
//  MagnifierView.m
//  SimplerMaskTest
//

#import "MagnifierView.h"
#import <QuartzCore/QuartzCore.h>

@implementation MagnifierView
@synthesize viewToMagnify, touchPoint;

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:CGRectMake(0, 0, 60, 60)]) {
		// make the circle-shape outline with a nice border.
		self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
		self.layer.borderWidth = 3;
		self.layer.cornerRadius = 30;
		self.layer.masksToBounds = YES;
	}
	return self;
}

- (void)setTouchPoint:(CGPoint)pt
{
	touchPoint = pt;
	// whenever touchPoint is set, 
	// update the position of the magnifier (to just above what's being magnified)
	self.center = CGPointMake(pt.x, pt.y-60);
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
	CGContextTranslateCTM(context,1*(self.frame.size.width*0.5),1*(self.frame.size.height*0.5));
	CGContextScaleCTM(context, 1.5, 1.5);
	CGContextTranslateCTM(context,-1*(touchPoint.x),-1*(touchPoint.y));
	[self.viewToMagnify.layer renderInContext:context];
}

@end
