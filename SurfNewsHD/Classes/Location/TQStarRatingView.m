//
//  TQStarRatingView.m
//  TQStarRatingView
//
//  Created by fuqiang on 13-8-28.
//  Copyright (c) 2013年 TinyQ. All rights reserved.
//

#import "TQStarRatingView.h"

@interface TQStarRatingView ()

@property (nonatomic, strong) UIView *starBackgroundView;
@property (nonatomic, strong) UIView *starForegroundView;

@end

@implementation TQStarRatingView

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame numberOfStar:kNUMBER_OF_STAR];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _numberOfStar = kNUMBER_OF_STAR;
    [self commonInit];
}

/**
 *  初始化TQStarRatingView
 *
 *  @param frame  Rectangles
 *  @param number 星星个数
 *
 *  @return TQStarRatingViewObject
 */
- (id)initWithFrame:(CGRect)frame numberOfStar:(int)number
{
    self = [super initWithFrame:frame];
    if (self) {
        _selectStar = -1;
        _numberOfStar = number;
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.starBackgroundView = [self buidlStarViewWithImageName:kBACKGROUND_STAR];
    self.starForegroundView = [self buidlStarViewWithImageName:kFOREGROUND_STAR];
    [_starForegroundView setFrame:CGRectZero];
    [self addSubview:self.starBackgroundView];
    [self addSubview:self.starForegroundView];
}

#pragma mark -
#pragma mark - Set Score

/**
 *  设置控件分数
 *
 *  @param score     分数，必须在 0 － 1 之间
 *  @param isAnimate 是否启用动画
 */
- (void)setScore:(float)score withAnimation:(bool)isAnimate
{
    [self setScore:score withAnimation:isAnimate completion:^(BOOL finished){}];
}

/**
 *  设置控件分数
 *
 *  @param score      分数，必须在 0 － 1 之间
 *  @param isAnimate  是否启用动画
 *  @param completion 动画完成block
 */
- (void)setScore:(float)score
   withAnimation:(bool)isAnimate
      completion:(void (^)(BOOL finished))completion
{
    if (score < 0) {
        score = 0;
    }
    
    if (score > 1) {
        score = 1;
    }
    
    CGPoint point = CGPointMake(score * self.frame.size.width, 0);
    
    if(isAnimate)
    {
        __weak __typeof(self)weakSelf = self;
        
        [UIView animateWithDuration:0.2 animations:^
         {
             [weakSelf changeStarForegroundViewWithPoint:point];
             
         } completion:^(BOOL finished)
         {
             if (completion)
             {
                 completion(finished);
             }
         }];
    }
    else
    {
//        [self changeStarForegroundViewWithPoint:point];
    }
}

#pragma mark -
#pragma mark - Touche Event
//滑动被禁，可以开启
#if 0
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    if(CGRectContainsPoint(rect,point))
    {
        [self changeStarForegroundViewWithPoint:point];
        
    }

    //[self star];
    
}
#endif

//-(void)star{
//    
//    if (!imageView) {
//        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/5, self.frame.size.height)];
//        image = [UIImage imageNamed:@"yellow_star"];
//        
//        imageView.image = image;
//        imageView.contentMode = UIViewContentModeTopLeft;
//        imageView.clipsToBounds = YES;
//        imageView.layer.masksToBounds = YES;
//
//        
//        
//        CGFloat markW = image.size.width / 2;
//        CGFloat markH = image.size.height / 2;
//        
//        CALayer *mask = [CALayer new];
//        mask.frame = CGRectMake(markW, markH, markW, markH);
//        mask.backgroundColor = [UIColor redColor].CGColor;
//        imageView.layer.mask = mask;
//        [self addSubview:imageView];
//        
//    }
//}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    __weak __typeof(self)weakSelf = self;
    
    [UIView animateWithDuration:0.2 animations:^
     {
         [weakSelf changeStarForegroundViewWithPoint:point];
     }];

    if ([_delegate respondsToSelector:@selector(starRatingView:score:)]) {
        [_delegate starRatingView:self score:_selectStar];
    }
}

#pragma mark -
#pragma mark - Buidl Star View

/**
 *  通过图片构建星星视图
 *
 *  @param imageName 图片名称
 *
 *  @return 星星视图
 */
- (UIView *)buidlStarViewWithImageName:(NSString *)imageName
{
    CGRect frame = self.bounds;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.clipsToBounds = YES;
    for (int i = 0; i < self.numberOfStar; i ++)
    {
        UIImageView *imageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        imageView1.frame = CGRectMake(i * frame.size.width / self.numberOfStar, 0, frame.size.width / self.numberOfStar, frame.size.height);
        [view addSubview:imageView1];
    }
    return view;
}

#pragma mark -
#pragma mark - Change Star Foreground With Point

/**
 *  通过坐标改变前景视图
 *
 *  @param point 坐标
 */
- (void)changeStarForegroundViewWithPoint:(CGPoint)point
{
    CGPoint p = point;
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat space = width / 10.f;
    
    if (p.x < 0)
    {
        p.x = 0;
    }
    
    if (p.x >= width)
    {
        p.x = width - space;
    }
    
    NSUInteger idex = p.x / space;
    _selectStar = idex + 1;
  
    self.starForegroundView.frame = CGRectMake(0, 0,_selectStar*space , height);
}

@end
