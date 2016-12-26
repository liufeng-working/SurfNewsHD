//
//  MGSplitDividerView.m
//  MGSplitView
//
//  Created by Matt Gemmell on 26/07/2010.
//  Copyright 2010 Instinctive Code.
//

#import "MGSplitDividerView.h"
#import "MGSplitViewController.h"


@implementation MGSplitDividerView


#pragma mark -
#pragma mark Setup and teardown


- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame])) {
		self.userInteractionEnabled = NO;
		self.allowsDragging = NO;
		self.contentMode = UIViewContentModeRedraw;
        self.backgroundColor = [UIColor whiteColor];
	}
	return self;
}


- (void)dealloc
{
	self.splitViewController = nil;
	[super dealloc];
}


#pragma mark -
#pragma mark Drawing


- (void)drawRect:(CGRect)rect
{
	if (splitViewController.dividerStyle == MGSplitViewDividerStyleThin) {
		[super drawRect:rect];
		
	} else if (splitViewController.dividerStyle == MGSplitViewDividerStylePaneSplitter) {
		[super drawRect:rect];
		CGRect bounds = self.bounds;
        UIImage *image = [UIImage imageNamed:@"split_Divider.png"];
        [image drawInRect:bounds];
	}
}


- (void)drawGripThumbInRect:(CGRect)rect
{
	float width = 9.0;
	float height;
	if (splitViewController.vertical) {
		height = 30.0;
	} else {
		height = width;
		width = 30.0;
	}
	
	// Draw grip in centred in rect.
	CGRect gripRect = CGRectMake(0, 0, width, height);
	gripRect.origin.x = ((rect.size.width - gripRect.size.width) / 2.0);
	gripRect.origin.y = ((rect.size.height - gripRect.size.height) / 2.0);
	
	float stripThickness = 1.0;
	UIColor *stripColor = [UIColor colorWithWhite:0.35 alpha:1.0];
	UIColor *lightColor = [UIColor colorWithWhite:1.0 alpha:1.0];
	float space = 3.0;
	if (splitViewController.vertical) {
		gripRect.size.width = stripThickness;
		[stripColor set];
		UIRectFill(gripRect);
		
		gripRect.origin.x += stripThickness;
		gripRect.origin.y += 1;
		[lightColor set];
		UIRectFill(gripRect);
		gripRect.origin.x -= stripThickness;
		gripRect.origin.y -= 1;
		
		gripRect.origin.x += space + stripThickness;
		[stripColor set];
		UIRectFill(gripRect);
		
		gripRect.origin.x += stripThickness;
		gripRect.origin.y += 1;
		[lightColor set];
		UIRectFill(gripRect);
		gripRect.origin.x -= stripThickness;
		gripRect.origin.y -= 1;
		
		gripRect.origin.x += space + stripThickness;
		[stripColor set];
		UIRectFill(gripRect);
		
		gripRect.origin.x += stripThickness;
		gripRect.origin.y += 1;
		[lightColor set];
		UIRectFill(gripRect);
		
	} else {
		gripRect.size.height = stripThickness;
		[stripColor set];
		UIRectFill(gripRect);
		
		gripRect.origin.y += stripThickness;
		gripRect.origin.x -= 1;
		[lightColor set];
		UIRectFill(gripRect);
		gripRect.origin.y -= stripThickness;
		gripRect.origin.x += 1;
		
		gripRect.origin.y += space + stripThickness;
		[stripColor set];
		UIRectFill(gripRect);
		
		gripRect.origin.y += stripThickness;
		gripRect.origin.x -= 1;
		[lightColor set];
		UIRectFill(gripRect);
		gripRect.origin.y -= stripThickness;
		gripRect.origin.x += 1;
		
		gripRect.origin.y += space + stripThickness;
		[stripColor set];
		UIRectFill(gripRect);
		
		gripRect.origin.y += stripThickness;
		gripRect.origin.x -= 1;
		[lightColor set];
		UIRectFill(gripRect);
	}
}


#pragma mark -
#pragma mark Interaction
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (splitViewController.splitPosition <= kSplitPositionMin)
    {
        style = MGSplitDividerBeganStyleMin;
    }
    else if (splitViewController.splitPosition <= kSplitPositionMax)
    {
        style = MGSplitDividerBeganStyleMiddle;
    }
    else if (splitViewController.splitPosition <= kSplitPositionLeftMax)
    {
        style = MGSplitDividerBeganStyleMax;
    }

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	if (touch) {
		CGPoint lastPt = [touch previousLocationInView:self];
		CGPoint pt = [touch locationInView:self];
		float offset = (splitViewController.vertical) ? pt.x - lastPt.x : pt.y - lastPt.y;
		if (!splitViewController.masterBeforeDetail) {
			offset = -offset;
		}
        if (offset<0 && splitViewController.splitPosition <=kSplitPositionMin) {
            return;
        }
        /*
        else if (offset>0 && splitViewController.splitPosition >=kSplitPositionMax) {
            return;
            
        }
        */
		splitViewController.splitPosition = splitViewController.splitPosition + offset;

         if (splitViewController.splitPosition < kSplitPositionMin)
         {
         splitViewController.splitPosition = kSplitPositionMin;
         }
        /*
        else if (splitViewController.splitPosition >kSplitPositionMax)
        {
            splitViewController.splitPosition = kSplitPositionMax;
        }

         */
	}
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (splitViewController.splitPosition - kSplitPositionMin < (kSplitPositionMax -kSplitPositionMin)/2)
    {
        [splitViewController setSplitPosition:kSplitPositionMin animated:YES];
    }
    else if(style != MGSplitDividerBeganStyleMax)
    {
        if (splitViewController.splitPosition - kSplitPositionMax > (kSplitPositionLeftMax -kSplitPositionMax)/3)
        {
             [splitViewController setSplitPosition:kSplitPositionLeftMax animated:YES];       
        }else
        {
             [splitViewController setSplitPosition:kSplitPositionMax animated:YES];
        }
    }else
    {
        if (splitViewController.splitPosition - kSplitPositionMax < (kSplitPositionLeftMax -kSplitPositionMax)/3*2)
        {
            [splitViewController setSplitPosition:kSplitPositionMin animated:YES];
        }else
        {
            [splitViewController setSplitPosition:kSplitPositionLeftMax animated:YES];
        }
    }
    style = MGSplitDividerBeganStyleNone;
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (splitViewController.splitPosition - kSplitPositionMin < (kSplitPositionMax -kSplitPositionMin)/2)
    {
        [splitViewController setSplitPosition:kSplitPositionMin animated:YES];
    }
    else if(style != MGSplitDividerBeganStyleMax)
    {
        if (splitViewController.splitPosition - kSplitPositionMax > (kSplitPositionLeftMax -kSplitPositionMax)/3)
        {
            [splitViewController setSplitPosition:kSplitPositionLeftMax animated:YES];
        }else
        {
            [splitViewController setSplitPosition:kSplitPositionMax animated:YES];
        }
    }else
    {
        if (splitViewController.splitPosition - kSplitPositionMax < (kSplitPositionLeftMax -kSplitPositionMax)/3*2)
        {
            [splitViewController setSplitPosition:kSplitPositionMin animated:YES];
        }else
        {
            [splitViewController setSplitPosition:kSplitPositionLeftMax animated:YES];
        }
        
        
    }
    style = MGSplitDividerBeganStyleNone;
}

#pragma mark -
#pragma mark Accessors and properties


- (void)setAllowsDragging:(BOOL)flag
{
	if (flag != allowsDragging) {
		allowsDragging = flag;
		self.userInteractionEnabled = allowsDragging;
	}
}


@synthesize splitViewController;
@synthesize allowsDragging;


@end
