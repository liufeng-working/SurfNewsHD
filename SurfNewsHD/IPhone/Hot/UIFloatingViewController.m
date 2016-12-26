//
//  UIFloatingViewController.m
//  SurfNewsHD
//
//  Created by jsg on 14-10-15.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#define FLOATING_ALAERTLABEL_VIEW     CGRectMake(18, 0, 143, 19)

#import "UIFloatingViewController.h"


@implementation UIFloatingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initBase];
    }
    return self;
}

- (void)initBase{
    
    m_alertLable = [[UILabel alloc] initWithFrame:FLOATING_ALAERTLABEL_VIEW];
    m_alertLable.font = [UIFont systemFontOfSize:10.0f];
    [m_alertLable setBackgroundColor:[UIColor clearColor]];
    //m_alertLable.textColor = [UIColor hexChangeFloat:@"ad2f2f"];
    m_alertLable.textColor = [UIColor redColor];

    [self addSubview: m_alertLable];
}

- (void)setAlertText:(NSString*)str{
    if (str) {
        NSString *tmp =[NSString stringWithFormat:@"冲浪快讯为您更新了%@条资讯",str];
        [m_alertLable setText:tmp];
    }
}

@end



@interface UIFloatingViewController ()

@end

@implementation UIFloatingViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
    CGRect floatingFrame = CGRectMake(320, 5, 153, 19);
    if (IOS7) {
        floatingFrame = CGRectMake(320, 5, 153, 19);
    }

    self.view.frame = floatingFrame;
    
    // Do any additional setup after loading the view.
    imgBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, floatingFrame.size.width, floatingFrame.size.height)];
//    [imgBgView setBackgroundColor:[UIColor colorWithRed:169/255.0f green:49/255.0f blue:43/255.0f alpha:0.5f]];
    
    UIImage *img = [UIImage imageNamed:@"floatingviewbg.png"];
    CGFloat top = 0; // 顶端盖高度
    CGFloat bottom = 0 ; // 底端盖高度
    CGFloat left = 30; // 左端盖宽度
    CGFloat right = 30; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    // 指定为拉伸模式，伸缩后重新赋值
    UIImage *stretchImg = [img resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    
    CGSize size = CGSizeMake(160, 19);
    UIImage *floatingViewBgImg = [self scaleToSize:stretchImg size:size];
    [imgBgView setImage:floatingViewBgImg];
    imgBgView.alpha = 0.8f;
    
    [self.view addSubview:imgBgView];
    
    //自定义floingView在背景view上
    m_floatingView = [[UIFloatingView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, floatingFrame.size.width, floatingFrame.size.height)];
    
    [self.view addSubview:m_floatingView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(FloatingViewMoved:)
                                                 name:kFloatingViewAppear
                                               object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setAddedThreadsCount:(NSString*)str{
    [m_floatingView setAlertText:str];
}


#pragma mark NSNotificationCenter methods
- (void)FloatingViewMoved:(NSNotification*)notification
{
    //开始浮动栏动画
    [self floatingViewMoving];
    
    //计时3s
    [self startTimer];
}

- (void)floatingViewMoving{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn]; //设置动画方式，具体在后面解释
    [UIView setAnimationDuration:0.5f];//设置动画持续时间
    [UIView setAnimationRepeatCount:1];//设置动画重复次数
    CGPoint center = self.view.center;
    center.x -= 158.0f;
    self.view.center = center;
    [UIView commitAnimations];
}

- (void)startTimer
{
    if(timer == nil){
        timer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
    }
    
}

- (void)stopTimer
{
    if(timer != nil)
        [timer invalidate];
    timer = nil;
    
    [ThreadsFetchingResult sharedInstance].isAppear = NO;
}

- (void)timerFired{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut]; //设置动画方式，具体在后面解释
    [UIView setAnimationDuration:3.0f];//设置动画持续时间
    [UIView setAnimationRepeatCount:1];//设置动画重复次数
    [self.view removeFromSuperview];
    [UIView commitAnimations];
    [self stopTimer];
}

//等比例缩放
- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0,0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    //返回新的改变大小后的图片
    
    return scaledImage;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
