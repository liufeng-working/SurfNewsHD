//
//  WeatherRefreshView.m
//  SurfNewsHD
//
//  Created by NJWC on 16/1/25.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "WeatherRefreshView.h"

@interface WeatherRefreshView ()
{
    CGFloat _endAngle;
    CGRect _oldRect;
    NSTimer * _timer;
    NSInteger _index;
}

@property (nonatomic,assign) CGFloat proportion;     //比例
@property (nonatomic,assign) CGFloat byAngle;        //每次旋转的角度
@property (nonatomic,assign) CGFloat lineWidth;     //边框宽度
@property (nonatomic,strong) NSArray *lineColor;    //边框颜色
@property (nonatomic,strong) CAShapeLayer *progressLayer; //<进度条

@end

@implementation WeatherRefreshView


-(instancetype)initWithFrame:(CGRect)frame
{
    self =[super initWithFrame:frame];
    if (self) {
        _oldRect = frame;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = frame.size.width * 0.5;
        self.layer.masksToBounds = YES;
        
        //初始化属性
        self.lineWidth = 2.f;
        self.lineColor = @[
                           [UIColor colorWithRed:75.0 / 255 green:1.0 blue:1.0 alpha:1.0],
                           [UIColor greenColor],
                           [UIColor blueColor],
                           [UIColor redColor],
                           [UIColor purpleColor],
                           [UIColor orangeColor],
                           ];
    }
    return self;
}

-(void)setPullDistance:(CGFloat)pullDistance
{
    //下拉
    [UIView animateWithDuration:0.1 animations:^{
        
        CGRect oldRect = self.frame;
        oldRect.origin.y += pullDistance;
        
        //
        _endAngle = CGRectGetMaxY(oldRect);
        
        if(_endAngle < 0) {
            oldRect.origin.y = - RefreshViewHeight;
        }else if(_endAngle < (RefreshViewHeight + RefreshDistance)) {
            
            self.proportion = _endAngle / (RefreshViewHeight + RefreshDistance);
            self.alpha = self.proportion;
        }else if(_endAngle < (RefreshViewHeight + PullMaxDistance)){
            self.alpha = 1.0;
            self.byAngle = pullDistance / (PullMaxDistance - RefreshDistance);
        }else{
            oldRect.origin.y = PullMaxDistance;
        }
        self.frame = oldRect;
    }];
}

-(void)setIsEnd:(BOOL)isEnd
{
    //手势结束
    if (isEnd == YES) {
        
        CGRect oldR = self.frame;
        if (_endAngle >= (RefreshViewHeight + RefreshDistance)) {
            
            oldR.origin.y = RefreshDistance;
            
            [UIView animateWithDuration:0.3 animations:^{
                self.frame = oldR;
            } completion:^(BOOL finished) {
                //开始动画
                [self startAnimation];

                //刷新按钮也要开始转动
                if([_delegate respondsToSelector:@selector(shouldStartRefreshWeather)]){
                    [_delegate shouldStartRefreshWeather];
                }
            }];
        }else{
            
            oldR.origin.y = - RefreshViewHeight;
            [UIView animateWithDuration:0.2 animations:^{
                self.frame = oldR;
            }completion:^(BOOL finished) {
                //没有调用到stopAnimation，所以这里要移除动画
                [self.layer removeAllAnimations];
            }];
        }
    }
}

//画线的比例
-(void)setProportion:(CGFloat)proportion
{
    _proportion = proportion;
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    //画弧
    CGFloat W = self.bounds.size.width; //view的宽度
    CGFloat H = self.bounds.size.height; //view的高度
    CGFloat centerX = W * 0.5; //圆心x
    CGFloat centerY = H * 0.5; //圆心y
    CGFloat radius = W * 0.5 - 8.f; //半径
    double endAngle = 2 * M_PI * self.proportion * 0.8; //结束角度
    CGFloat lineWidth = 2.f; //线宽
    //开始画
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 75.0/255, 1.0, 1.0, 1.0);
    CGContextSetLineWidth(context, lineWidth);
    CGContextAddArc(context, centerX, centerY, radius, 0, endAngle, 0);
    //渲染
    CGContextStrokePath(context);
    
    //画三角形
    CGFloat equilateral = 3.5 * lineWidth * self.proportion; //等边三角的边长
    CGFloat radiusInside = radius - equilateral * 0.5;
    CGFloat radiusOutside = radius + equilateral * 0.5;
    //内部点
    CGFloat insidePointX = centerX + radiusInside * cos(endAngle);
    CGFloat insidePointY = centerY + radiusInside * sin(endAngle);
    //外部点
    CGFloat outsidePointX = centerX + radiusOutside * cos(endAngle);
    CGFloat outsidePointY = centerY + radiusOutside * sin(endAngle);
    //顶点
    CGFloat perpendicularLineHeight = equilateral * sin(M_PI / 3);  //垂直线高度
    double exAngle = atan(perpendicularLineHeight/radius); //增加的角度
    CGFloat apexRadius = sqrt(radius * radius + perpendicularLineHeight * perpendicularLineHeight); //顶点所在圆的半径
    CGFloat apexPointX = centerX + apexRadius * cos(endAngle + exAngle);
    CGFloat apexPointY = centerY + apexRadius * sin(endAngle + exAngle);
    
    //开始画三角形
    CGContextSetRGBFillColor(context, 75.0/255, 1.0, 1.0, 1.0);
    CGContextMoveToPoint(context, insidePointX, insidePointY);
    CGContextAddLineToPoint(context, outsidePointX, outsidePointY);
    CGContextAddLineToPoint(context, apexPointX, apexPointY);
    
    //渲染
    CGContextFillPath(context);
}

//每次旋转的角度
-(void)setByAngle:(CGFloat)byAngle
{
    _byAngle = byAngle;
    [self rotationAnimation];
}

//旋转动画
-(void)rotationAnimation
{
    CABasicAnimation * basicAni = [CABasicAnimation animation];
    basicAni.keyPath = @"transform.rotation.z";
    basicAni.byValue = @(M_PI * self.byAngle);
    basicAni.removedOnCompletion = NO;
    basicAni.fillMode = kCAFillModeForwards;
    [self.layer addAnimation:basicAni forKey:nil];
}

//最后的旋转动画
- (void)startAnimation
{
    //先移除原来的画面
    self.proportion = 0.0f;
    self.alpha = 1.0;  //确保动画进行时，是不透明的
    //记录正在进行动画
    self.isAnimation = YES;
    
    //外层旋转动画
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue = @0.0;
    rotationAnimation.toValue = @(2*M_PI);
    rotationAnimation.repeatCount = HUGE_VALF;
    rotationAnimation.duration = 3.0;
    rotationAnimation.beginTime = 0.0;
    
    [self.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
    //内层进度条动画
    CABasicAnimation *strokeAnim1 = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    strokeAnim1.fromValue = @0.0;
    strokeAnim1.toValue = @1.0;
    strokeAnim1.duration = 1.0;
    strokeAnim1.beginTime = 0.0;
    strokeAnim1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    //内层进度条动画
    CABasicAnimation *strokeAnim2 = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    strokeAnim2.fromValue = @0.0;
    strokeAnim2.toValue = @1.0;
    strokeAnim2.duration = 1.0;
    strokeAnim2.beginTime = 1.0;
    strokeAnim2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.duration = 2.0;
    animGroup.repeatCount = HUGE_VALF;
    animGroup.fillMode = kCAFillModeForwards;
    animGroup.animations = @[strokeAnim1, strokeAnim2];
    
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake( 8.f, 8.f, CGRectGetWidth(self.frame) - 8.f*2, CGRectGetHeight(self.frame) - 8.f*2)];
    
    self.progressLayer = [CAShapeLayer layer];
    self.progressLayer.lineWidth = self.lineWidth;
    self.progressLayer.lineCap = kCALineCapRound;
    _index = 0;
    self.progressLayer.strokeColor = ((UIColor *)self.lineColor[_index]).CGColor;
    self.progressLayer.fillColor = [UIColor clearColor].CGColor;
    self.progressLayer.strokeStart = 0.0;
    self.progressLayer.strokeEnd = 1.0;
    self.progressLayer.path = path.CGPath;
    [self.progressLayer addAnimation:animGroup forKey:@"strokeAnim"];
    
    [self.layer addSublayer:self.progressLayer];
    
    if(!_timer)
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(changeColor)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)changeColor {
    
    _index ++;
    UIColor *color = (UIColor *)[self.lineColor objectAtIndex:_index % self.lineColor.count];
    self.progressLayer.strokeColor = color.CGColor;
}

-(void)stopAnimation
{
    //停止定时器
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    
    //移除层
    [self.progressLayer removeFromSuperlayer];
    
    //移除动画
    [self.layer removeAllAnimations];

    //从父视图移除(其实是移动坐标，供下次使用)
    [UIView animateWithDuration:0.5 animations:^{
        self.bounds = CGRectMake(0, 0, 0, 0);
    }completion:^(BOOL finished) {
        self.frame = _oldRect;
        
        //设置没有动画正在进行
        self.isAnimation = NO;
    }];
    
    //代理回调
    if ([_delegate respondsToSelector:@selector(refreshAnimationDidEnd)]) {
        [_delegate refreshAnimationDidEnd];
    }
}

@end
