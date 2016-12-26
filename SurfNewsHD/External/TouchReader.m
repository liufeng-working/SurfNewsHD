//
//  TouchReader.m
//  SimplerMaskTest
//

#import "TouchReader.h"
#import "MagnifierView.h"

@implementation TouchReader

@synthesize touchTimer;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.touchTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
												 target:self
												selector:@selector(addLoop)
											   userInfo:nil
												repeats:NO];

	// just create one loop and re-use it.
	if(loop == nil){
		loop = [[MagnifierView alloc] init];
		loop.viewToMagnify = self.superview;
	}
	
	UITouch *touch = [touches anyObject];
	loop.touchPoint = [touch locationInView:self.superview];
	[loop setNeedsDisplay];
}
- (void)touchesMoved:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint curP = [touch locationInView:self];
    if (CGRectContainsPoint(self.bounds, curP)) {
        [self handleAction:touches];
    }
    else {
        [self.touchTimer invalidate];
        self.touchTimer = nil;
        [loop removeFromSuperview];
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[self.touchTimer invalidate];
	self.touchTimer = nil;
	[loop removeFromSuperview];
}



- (void)addLoop {

    if (![[self.superview subviews] containsObject:loop]) {
        [self.superview addSubview:loop];
    }
}

- (void)handleAction:(id)timerObj
{
	NSSet *touches = timerObj;
	UITouch *touch = [touches anyObject];
	loop.touchPoint = [touch locationInView:self.superview];
	[loop setNeedsDisplay];
}

@end
