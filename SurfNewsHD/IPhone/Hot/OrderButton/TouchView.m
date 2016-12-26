//
//  TouchView.m
//  TouchDemo
//
//  Created by Zer0 on 13-8-11.
//  Copyright (c) 2013年 Zer0. All rights reserved.
//

#import "TouchView.h"
#import "HotChannelsListResponse.h"
#import "SurfFlagsManager.h"
#import "UIImage+Extensions.h"


@implementation TouchView
- (void)dealloc
{
    [_editeImage release];
    [_label release];
    [_moreChannelsLabel release];
    [_touchViewModel release];
    [_selectedView release];
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.multipleTouchEnabled = YES;
        self.userInteractionEnabled = YES;
        
        
        [self setImage:[UIImage imageNamedNewImpl:@"pdButton"]];
        CGRect lR = CGRectMake(2, 2, KButtonWidth-10, KButtonHeight-10);
        _label = [[UILabel alloc] initWithFrame:lR];
        [_label setBackgroundColor:[UIColor clearColor]];
        _sign = 0;
        [self addSubview:_label];
    }
    return self;
}

-(void)changeEdit:(BOOL)flage
{
    self.isEditButton = flage;
    HotChannelsManager * manager = [HotChannelsManager sharedInstance];
    if (flage) {
        if (manager.selectChannelIndex == 0 && self.tag == 100) {
            
            [self setImage:[UIImage imageNamedNewImpl:@"pdButton_gray"]];
            [self.label setTextColor:[UIColor colorWithHexValue:0xffdcdcdc]];
        }
    }else{
        if (manager.selectChannelIndex == 0 && self.tag == 100) {
            [self.label setTextColor:[UIColor colorWithHexValue:0xffAD2F2F]];
            [self setImage:[UIImage imageNamedNewImpl:@"pdButton_selected"]];
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // 增加点击效果
    [self selectedView:YES];
    
    
    if (self.isEditButton == NO) {
        return;
    }
    
    UITouch * touch = [touches anyObject];
    _point = [touch locationInView:self];
    _point2 = [touch locationInView:self.superview];
    [self.superview exchangeSubviewAtIndex:[self.superview.subviews indexOfObject:self] withSubviewAtIndex:[[self.superview subviews] count] - 1];
}



- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self animationAction];
    
    // 增加点击效果
    [self selectedView:NO];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // 增加点击效果
    [self selectedView:NO];
    
    if (self.isEditButton == NO) {
        DJLog(@"%@",self.label.text);
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:self.touchViewModel,@"Model", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SELECTCHANEL" object:dic];
        return;
    }
    

    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.superview];
    if (point.x<(KTableStartPointX+KButtonWidth) && point.y<(KTableStartPointY+KButtonHeight))
    {
        [self animationAction];
        return;
    }
    
    if (![self.label.text isEqualToString:@"热推"]) {
        
        if (_sign == 0) {
            if (_array == _viewArr11) {
                [_viewArr11 removeObject:self];
                [_viewArr22 insertObject:self atIndex:_viewArr22.count];
                _array = _viewArr22;
                [self animationAction];
            }
            else if ( _array == _viewArr22){
                [_viewArr22 removeObject:self];
                [_viewArr11 insertObject:self atIndex:_viewArr11.count];
                _array = _viewArr11;
                [self animationAction];
            }
        }
        
        
        else if (([self buttonInArrayArea1:_viewArr11 Point:point] || [self buttonInArrayArea2:_viewArr22 Point:point])&&!(point.x - _point.x > KTableStartPointX && point.x - _point.x < KTableStartPointX + KButtonWidth && point.y - _point.y > KTableStartPointY && point.y - _point.y < KTableStartPointY + KButtonHeight)){
            if (point.x < KTableStartPointX || point.y < KTableStartPointY) {
//                int X = _point2.x - _point.x;
//                int Y = _point2.y - _point.y;
//                [self setFrame:CGRectMake(_point2.x - _point.x, _point2.y - _point.y, self.frame.size.width, self.frame.size.height)];
            }
            else{
//                [self setFrame:CGRectMake(KTableStartPointX + (a + KButtonWidth/2 - KTableStartPointX)/KButtonWidth*KButtonWidth, KTableStartPointY + (b + KButtonHeight/2 - KTableStartPointY)/KButtonHeight*KButtonHeight, self.frame.size.width, self.frame.size.height)];
            }
            [self animationAction];
        }
        else{
            
            [self animationAction];
            
        }
        _sign = 0;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // 增加点击效果
    [self selectedView:NO];
    
    if (self.isEditButton == NO) {
        DJLog(@"%@",self.label.text);
        return;
    }
    
    _sign = 1;
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.superview];
    if (point.x<=0) {
        point.x=0;
    }

    if (![self.label.text isEqualToString:@"热推"])
    {
        [self setFrame:CGRectMake( point.x - _point.x, point.y - _point.y, self.frame.size.width, self.frame.size.height)];
        
        CGFloat newX = point.x - _point.x + KButtonWidth/2;
        CGFloat newY = point.y - _point.y + KButtonHeight/2;
        
        if (!CGRectContainsPoint([[_viewArr11 objectAtIndex:0] frame], CGPointMake(newX, newY)) ) {
            
            if ( _array == _viewArr22) {
                
                if ([self buttonInArrayArea1:_viewArr11 Point:point]) {
                    
                    int index = ((int)newX - KTableStartPointX)/KButtonWidth + (5 * (((int)newY - KTableStartPointY)/KButtonHeight));
                    
                    if (index==0) {
                        index=1;
                    }
                    [ _array removeObject:self];
                    [_viewArr11 insertObject:self atIndex:index];
                    _array = _viewArr11;
                    [self animationAction1a];
                    [self animationAction2];
                }
                else if (newY < KTableStartPointY + [self array2StartY] * KButtonHeight &&![self buttonInArrayArea1:_viewArr11 Point:point]){
                    
                    [ _array removeObject:self];
                    [_viewArr11 insertObject:self atIndex:_viewArr11.count];
                    _array = _viewArr11;
                    [self animationAction2];
                    
                }
                else if([self buttonInArrayArea2:_viewArr22 Point:point]){
                    unsigned long index = ((unsigned long )(newX) - KTableStartPointX)/KButtonWidth + (5 * (((int)(newY) - [self array2StartY] * KButtonHeight - KTableStartPointY)/KButtonHeight));
                    [ _array removeObject:self];

                    [_viewArr22 insertObject:self atIndex:index];
                    [self animationAction2a];
                    
                }
                else if(newY > KTableStartPointY + [self array2StartY] * KButtonHeight &&![self buttonInArrayArea2:_viewArr22 Point:point]){
                    [ _array removeObject:self];
                    [_viewArr22 insertObject:self atIndex:_viewArr22.count];
                    [self animationAction2a];
                    
                }
            }
            else if ( _array == _viewArr11) {
                if ([self buttonInArrayArea1:_viewArr11 Point:point]) {
                    int index = ((int)newX - KTableStartPointX)/KButtonWidth + (5 * (((int)(newY) - KTableStartPointY)/KButtonHeight));
                    
                    if (index==0) {
                        index=1;
                    }
                    [ _array removeObject:self];
                    [_viewArr11 insertObject:self atIndex:index];
                    _array = _viewArr11;
                    
                    [self animationAction1a];
                    [self animationAction2];
                }
                else if (newY < KTableStartPointY + [self array2StartY] * KButtonHeight &&![self buttonInArrayArea1:_viewArr11 Point:point]){
                    [ _array removeObject:self];
                    [_viewArr11 insertObject:self atIndex: _array.count];
                    [self animationAction1a];
                    [self animationAction2];
                }
                else if([self buttonInArrayArea2:_viewArr22 Point:point]){
                    unsigned long index = ((unsigned long)(newX) - KTableStartPointX)/KButtonWidth + (5 * (((int)(newY) - [self array2StartY] * KButtonHeight - KTableStartPointY)/KButtonHeight));
                    [ _array removeObject:self];

                    [_viewArr22 insertObject:self atIndex:index];
                    _array = _viewArr22;
                    [self animationAction2a];
                }
                else if(newY > KTableStartPointY + [self array2StartY] * KButtonHeight &&![self buttonInArrayArea2:_viewArr22 Point:point]){
                    [ _array removeObject:self];
                    [_viewArr22 insertObject:self atIndex:_viewArr22.count];
                    _array = _viewArr22;
                    [self animationAction2a];
                    
                }
            }
        }
    }
}

- (void)animationAction1
{
    HotChannelsManager *manager = [HotChannelsManager sharedInstance];
    NSMutableArray* array1 = [[NSMutableArray alloc]init];
    for (int i = 0; i < _viewArr11.count; i++) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
                
            [[_viewArr11 objectAtIndex:i] setFrame:CGRectMake(KTableStartPointX + (i%5) * (KButtonWidth), KTableStartPointY + (i/5)* (KButtonHeight), KButtonWidth-5, KButtonHeight-5)];
            TouchView* touchview = [_viewArr11 objectAtIndex:i];
            if (self.isEditButton) {
                if ([touchview.label.text isEqualToString:@"热推"]) {
                    touchview.editeState = NO;
                }
                else
                {
                    touchview.editeState = YES;
                }
            }
            else
            {
                touchview.editeState = NO;
            }
            [array1 addObject:touchview.touchViewModel];
            
        } completion:^(BOOL finished){
                
        }];
    }
    
    manager.visibleHotChannels = array1;
    [array1 release];
}
- (void)animationAction1a{
    HotChannelsManager *manager = [HotChannelsManager sharedInstance];
    NSMutableArray* array1 = [[NSMutableArray alloc]init];
    for (int i = 0; i < _viewArr11.count; i++) {
        if ([_viewArr11 objectAtIndex:i] != self) {
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
                
                [[_viewArr11 objectAtIndex:i] setFrame:CGRectMake(KTableStartPointX + (i%5) * (KButtonWidth), KTableStartPointY + (i/5)* (KButtonHeight), KButtonWidth-5, KButtonHeight-5)];
                TouchView* touchview = [_viewArr11 objectAtIndex:i];
                
                if (self.isEditButton) {
                    if ([touchview.label.text isEqualToString:@"热推"]) {
                        touchview.editeState = NO;
                    }
                    else
                    {
                        touchview.editeState = YES;
                    }
                }
                else
                {
                    touchview.editeState = NO;
                }
                [array1 addObject:touchview.touchViewModel];
                
            } completion:^(BOOL finished){
                
            }];
        }
    }
    
    manager.visibleHotChannels = array1;
    [array1 release];
    
}
- (void)animationAction2{
    HotChannelsManager *manager = [HotChannelsManager sharedInstance];
    NSMutableArray* array1 = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < _viewArr22.count; i++) {
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
            
            [[_viewArr22 objectAtIndex:i] setFrame:CGRectMake(KTableStartPointX + (i%5) * (KButtonWidth), KTableStartPointY + [self array2StartY] * KButtonHeight + (i/5)* (KButtonHeight), KButtonWidth-5, KButtonHeight-5)];
            TouchView* touchview = [_viewArr22 objectAtIndex:i];
            touchview.editeState = NO;
            [array1 addObject:touchview.touchViewModel];
        } completion:^(BOOL finished){
            
        }];
    }
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        
        [self.moreChannelsLabel setFrame:CGRectMake(self.moreChannelsLabel.frame.origin.x, KTableStartPointY + (KButtonHeight) * ([self array2StartY] - 1) , self.moreChannelsLabel.frame.size.width, self.moreChannelsLabel.frame.size.height)];
        self.myY = _point2.y;
        
    } completion:^(BOOL finished){
        
    }];
    manager.visibleHotChannels = array1;
    [array1 release];
}
- (void)animationAction2a{
    HotChannelsManager *manager = [HotChannelsManager sharedInstance];
    NSMutableArray* array1 = [[NSMutableArray alloc]init];
    for (int i = 0; i < _viewArr22.count; i++) {
        if ([_viewArr22 objectAtIndex:i] != self) {
            
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
                
                
                [[_viewArr22 objectAtIndex:i] setFrame:CGRectMake(KTableStartPointX + (i%5) * (KButtonWidth), KTableStartPointY + [self array2StartY] * KButtonHeight + (i/5)* (KButtonHeight), KButtonWidth-5, KButtonHeight-5)];
                TouchView* touchview = [_viewArr22 objectAtIndex:i];
                touchview.editeState = NO;
                [array1 addObject:touchview.touchViewModel];
            } completion:^(BOOL finished){
            }];
        }
        
    }
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        
        [self.moreChannelsLabel setFrame:CGRectMake(self.moreChannelsLabel.frame.origin.x, KTableStartPointY + (KButtonHeight) * ([self array2StartY] - 1) , self.moreChannelsLabel.frame.size.width, self.moreChannelsLabel.frame.size.height)];
        self.myY = _point2.y;
        
    } completion:^(BOOL finished){
        
    }];
    manager.visibleHotChannels = array1;
    [array1 release];
}
- (void)animationActionLabel{
    
}

- (void)animationAction{
    
    HotChannelsManager *manager = [HotChannelsManager sharedInstance];
    NSMutableArray* array1 = [[NSMutableArray alloc]init];
//    for (int i=0; i<orderVC.viewArr1.count; i++) {
//        TouchView* touchview = [orderVC.viewArr1 objectAtIndex:i];
//        [array1 addObject:touchview.touchViewModel];
//    }
    
    NSMutableArray* array2 = [[NSMutableArray alloc]init];
//    for (int i=0; i<orderVC.viewArr2.count; i++) {
//        TouchView* touchview = [orderVC.viewArr2 objectAtIndex:i];
//        [array2 addObject:touchview.touchViewModel];
//    }
//    manager.visibleHotChannels = array1;
//    manager.invisibleHotChannels = array2;
    
    for (int i = 0; i < _viewArr11.count; i++) {
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
            
            [[_viewArr11 objectAtIndex:i] setFrame:CGRectMake(KTableStartPointX + (i%5) * (KButtonWidth), KTableStartPointY + (i/5)* (KButtonHeight), KButtonWidth-5, KButtonHeight-5)];
            TouchView* touchview = [_viewArr11 objectAtIndex:i];
            if (self.isEditButton) {
                if ([touchview.label.text isEqualToString:@"热推"]) {
                    touchview.editeState = NO;
                }
                else
                {
                    touchview.editeState = YES;
                }
            }
            else
            {
                touchview.editeState = NO;
            }
            [array1 addObject:touchview.touchViewModel];
            
        } completion:^(BOOL finished){
            
        }];
        
    }
    for (int i = 0; i < _viewArr22.count; i++) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
            
            [[_viewArr22 objectAtIndex:i] setFrame:CGRectMake(KTableStartPointX + (i%5) * (KButtonWidth), KTableStartPointY + [self array2StartY] * (KButtonHeight) + (KButtonHeight) * (i/5), KButtonWidth-5, KButtonHeight-5)];
            TouchView* touchview = [_viewArr22 objectAtIndex:i];
            touchview.editeState = NO;
            [array2 addObject:touchview.touchViewModel];
        } completion:^(BOOL finished){
            
        }];
    }
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        
        [self.moreChannelsLabel setFrame:CGRectMake(self.moreChannelsLabel.frame.origin.x, KTableStartPointY + (KButtonHeight) * ([self array2StartY] - 1) , self.moreChannelsLabel.frame.size.width, self.moreChannelsLabel.frame.size.height)];
        
        
    } completion:^(BOOL finished){
        
    }];
    
    manager.visibleHotChannels = array1;
    manager.invisibleHotChannels = array2;
    [array1 release];
    [array2 release];
    
}

- (BOOL)buttonInArrayArea1:(NSMutableArray *)arr Point:(CGPoint)point{
    CGFloat newX = point.x - _point.x + (KButtonWidth)/2;
    CGFloat newY = point.y - _point.y + (KButtonHeight)/2;
    int a =  arr.count%5;
    unsigned long b =  arr.count/5;
    if ((newX > KTableStartPointX && newX < KTableStartPointX + 5 * (KButtonWidth) && newY > KTableStartPointY && newY < KTableStartPointY + b * (KButtonHeight)) || (newX > KTableStartPointX && newX < KTableStartPointX + a * (KButtonWidth) && newY > KTableStartPointY + b * (KButtonHeight) && newY < KTableStartPointY + (b+1) * (KButtonHeight)) ) {
        return YES;
    }
    return NO;
}
- (BOOL)buttonInArrayArea2:(NSMutableArray *)arr Point:(CGPoint)point{
    CGFloat newX = point.x - _point.x + (KButtonWidth)/2;
    CGFloat newY = point.y - _point.y + (KButtonHeight)/2;
    int a =  arr.count%5;
    unsigned long b =  arr.count/5;
    if ((newX > KTableStartPointX && newX < KTableStartPointX + 5 * (KButtonWidth) && newY > KTableStartPointY + [self array2StartY] * (KButtonHeight) && newY < KTableStartPointY + (b + [self array2StartY]) * (KButtonHeight)) || (newX > KTableStartPointX && newX < KTableStartPointX + a * (KButtonWidth) && newY > KTableStartPointY + (b + [self array2StartY]) * (KButtonHeight) && newY < KTableStartPointY + (b+[self array2StartY]+1) * (KButtonHeight)) )
    {
        return YES;
    }
    return NO;
}
- (unsigned long)array2StartY{
    unsigned long y = 0;
    
    y = _viewArr11.count/5 + 2;
    if (_viewArr11.count%5 == 0) {
        y -= 1;
    }
    return y;
}

#pragma mark - ****新增频道，添加红点****
- (void)setItemIsNew:(HotChannel *)hotCh
{
    SurfFlagsManager *manager = [SurfFlagsManager sharedInstance];
    if (![manager checkNewsChannelIsAddChannel:hotCh]) {
        return;
    }
    
    
    //新增频道的红色标记
    if (_isnewView == nil) {
        UIImage *flag = [SurfFlagsManager flagImage];
        CGFloat fW = flag.size.width;
        CGFloat fH = flag.size.height;
        CGFloat width = CGRectGetWidth(self.bounds);
         _isnewView = [[UIImageView alloc]initWithFrame:CGRectMake(width-fW, 0, fW, fH)];
        [_isnewView setImage:flag];
        [self addSubview:_isnewView];// 添加红点
    }
}

#pragma mark - ****选中频道，特殊标识****
- (void)selectChannelWithIndex:(int)index
{
    HotChannelsManager * manager = [HotChannelsManager sharedInstance];

    if (manager.selectChannelIndex == index){
        
        [self.label setTextColor:[UIColor colorWithHexValue:0xffAD2F2F]];
        [self setImage:[UIImage imageNamedNewImpl:@"pdButton_selected"]];
    }else{
        
        [self.label setTextColor:[UIColor colorWithHexString:@"666666"]];
        [self setImage:[UIImage imageNamedNewImpl:@"pdButton"]];
    }
}

-(void)setEditeState:(BOOL)editeState
{
    _editeState = editeState;
    if (editeState) {
        if (_editeImage == nil) {
            // 编辑图片
            _editeImage = [[UIImageView alloc]initWithImage:[UIImage imageNamedNewImpl:@"editeStyle"]];
            _editeImage.frame = CGRectMake(KButtonWidth-12 , -5, 10, 10);
            _editeImage.clipsToBounds = YES;
            [self addSubview:_editeImage];
        }
    }
    else {
        [_editeImage removeFromSuperview];
        _editeImage = nil;
    }
}


-(void)selectedView:(BOOL)isSelected
{
    if (isSelected) {
        if (_selectedView == nil) {
            // 选择背景
            _selectedView = [[UIImageView alloc]initWithFrame:self.bounds];
            [_selectedView setImage:[UIImage imageNamedNewImpl:@"pdButton_selected@2x"]];
            [self addSubview:_selectedView];
            [self insertSubview:_selectedView atIndex:0];
        }
        [_selectedView setHidden:NO];
        self.label.textColor = [UIColor colorWithHexValue:0xffAD2F2F];
    }
    else {
        [_selectedView setHidden:YES];
        if((self.tag - 100) == [HotChannelsManager sharedInstance].selectChannelIndex){
        
            if (self.tag == 100) {
                [self setImage:[UIImage imageNamedNewImpl:@"pdButton_gray"]];
                [self.label setTextColor:[UIColor colorWithHexValue:0xffdcdcdc]];
            }else{
                [self.label setTextColor:[UIColor colorWithHexValue:0xffAD2F2F]];
                [self setImage:[UIImage imageNamedNewImpl:@"pdButton_selected@2x"]];
            }
        }else{
            self.label.textColor = [UIColor colorWithHexString:@"666666"];
            [self setImage:[UIImage imageNamedNewImpl:@"pdButton"]];
        }
    }
}
@end
