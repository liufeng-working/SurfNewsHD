//
//  DismissTableView.m
//  SurfNewsHD
//
//  Created by apple on 13-6-18.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "DismissTableView.h"
#import "AppDelegate.h"
#define kaddObserver @"contentOffset"
@implementation DismissTableView
@synthesize dismissController;
- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        // Initialization code

        [self addObserver:self
                forKeyPath:kaddObserver
                   options:NSKeyValueObservingOptionOld
                   context:nil];
        
        self.backgroundColor = [UIColor clearColor];
        
        UIView *bgView = [[UIView alloc] initWithFrame:self.bounds];
        bgView.backgroundColor = [UIColor whiteColor];
        [self addSubview:bgView];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        UIImage *image = [appDelegate.screenShotsList lastObject];
        bgImageView = [[UIImageView alloc] initWithImage:image];
        bgImageView.frame = CGRectMake(0.0f, 0.0f,
                                       kContentWidth,
                                       kContentHeight);


    }
    return self;
}

-(void)dealloc
{
    [self removeObserver:self forKeyPath:kaddObserver];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
/*
#pragma mark - Touch
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    startY = [[touches anyObject] locationInView:self].y;
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    DJLog(@"%f",touchPoint.y);
    float y= dismissController.view.frame.origin.y+touchPoint.y - startY;
    if (y > 20 && y < 200) {
        [self.dismissController actionGestureRecognizer:y];        
    }

}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    float y= dismissController.view.frame.origin.y+touchPoint.y - startY;

    if (y  > 40.0f +dismissController.StateBarHeight) {
        [UIView animateWithDuration:0.5f animations:^{
            [self.dismissController actionGestureRecognizer:dismissController.view.frame.size.height];
        } completion:^(BOOL finished) {
            [dismissController dismissModalViewControllerAnimated:PresentAnimatedStateNone];
        }];
        
    }else
    {
        [UIView animateWithDuration:0.5f animations:^{
            [self.dismissController actionGestureRecognizer:20];
        } completion:^(BOOL finished) {
            
        }];
    }
   
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    CGPoint touchPoint = [[[event touchesForView:self] anyObject] locationInView:self];
    float y= dismissController.view.frame.origin.y+touchPoint.y - startY;
    if (y  > 40.0f +dismissController.StateBarHeight) {
        [UIView animateWithDuration:0.5f animations:^{
            [self.dismissController actionGestureRecognizer:dismissController.view.frame.size.height];
        } completion:^(BOOL finished) {
            [dismissController dismissModalViewControllerAnimated:PresentAnimatedStateNone];
        }];
        
    }else
    {
        [UIView animateWithDuration:0.5f animations:^{
            [self.dismissController actionGestureRecognizer:20];
        } completion:^(BOOL finished) {
            
        }];
    }

}
*/
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{

    if ([object isKindOfClass:[DismissTableView class]]) {
        if (!bgImageView.superview) {
            [self.superview insertSubview:bgImageView belowSubview:self];            
        }



        for (UIGestureRecognizer* gesture in self.gestureRecognizers)
        {
            if ([NSStringFromClass([gesture class]) isEqualToString:@"UIScrollViewPanGestureRecognizer"])
            {

                if ([gesture state] == UIGestureRecognizerStatePossible)
                {
                    float y = self.contentOffset.y;

                    if (y < -40.0f) {
                        self.contentInset = UIEdgeInsetsMake(-y, 0, 0, 0);
                        [UIView animateWithDuration:0.5f animations:^{
                            self.frame = CGRectMake(0.0f, self.frame.size.height, self.frame.size.width, self.frame.size.height);
                        } completion:^(BOOL finished) {
                            [self.dismissController dismissControllerAnimated:PresentAnimatedStateNone];
                        }];
                    }else
                    {
                    
                    }
                }
            }
        }
    }

}

@end
