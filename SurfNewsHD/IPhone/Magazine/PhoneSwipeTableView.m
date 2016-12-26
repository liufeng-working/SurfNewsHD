//
//  YFJLeftSwipeDeleteTableView.m
//
//  Provides drop-in TableView component that allows to show iOS7 style left-swipe delete
//
//  Created by Yuichi Fujiki on 6/27/13.
//  Copyright (c) 2013 Yuichi Fujiki. All rights reserved.
//

#import "PhoneSwipeTableView.h"


const static CGFloat kDeleteButtonWidth = 163.f;
const static CGFloat kDeleteButtonHeight = 44.f;

// 置顶和退订控件
@implementation SetTopOrUnsubsView

static UIImage *Divider_Image = nil;
static UIImage *Divider_Image_N = nil;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        dividerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.bounds.size.width - 1 ) / 2, 7.0f, 2.0f, 26.0f)];
        [self addSubview:dividerImageView];
        
        setTopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [setTopButton setTitle:@"置顶" forState:UIControlStateNormal];
        [setTopButton addTarget:self
                         action:@selector(setTopButtonClick)
               forControlEvents:UIControlEventTouchUpInside];
        [setTopButton setBackgroundImage:[UIImage imageNamed:@"set_top_select_bg"]
                                forState:UIControlStateHighlighted];
        [setTopButton setImage:[UIImage imageNamed:@"top"]
                      forState:UIControlStateNormal];
        //zyl
        [setTopButton setImageEdgeInsets:UIEdgeInsetsMake(8.0f, 10.0f, 8.0f, 38.0f)];
        [setTopButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 8.0f, 0.0f, 0.0f)];
        [setTopButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
        [setTopButton setBackgroundColor:[UIColor clearColor]];
        [self addSubview:setTopButton];
        
        cancleSubsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancleSubsButton setTitle:@"退订" forState:UIControlStateNormal];
        [cancleSubsButton addTarget:self
                             action:@selector(cancleSubsClick)
                   forControlEvents:UIControlEventTouchUpInside];
        [cancleSubsButton setBackgroundImage:[UIImage imageNamed:@"set_top_select_bg"]
                                forState:UIControlStateHighlighted];
        [cancleSubsButton setImage:[UIImage imageNamed:@"close1"]
                          forState:UIControlStateNormal];
        [cancleSubsButton setImageEdgeInsets:UIEdgeInsetsMake(8.0f, 10.0f, 8.0f, 40.0f)];
        [cancleSubsButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 0.0f)];
        [cancleSubsButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
        [cancleSubsButton setBackgroundColor:[UIColor clearColor]];
        [self addSubview:cancleSubsButton];
        
        setTopButton.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width / 2, self.frame.size.height);
        cancleSubsButton.frame = CGRectMake(self.frame.size.width / 2, 0.0f,
                                            self.frame.size.width / 2, self.frame.size.height);
    }
    
    return self;
}

- (void)applyTheme
{
    if ([[ThemeMgr sharedInstance] isNightmode]) {
        if (!Divider_Image) {
            Divider_Image = [UIImage imageNamed:@"top_and_canncelsubs_divider_night.png"];
        }
        
        self.backgroundColor = [UIColor colorWithHexValue:0xFF242526];
        dividerImageView.image = Divider_Image;
        [setTopButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancleSubsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        if (!Divider_Image_N) {
            Divider_Image_N = [UIImage imageNamed:@"top_and_canncelsubs_divider.png"];
        }
        
        self.backgroundColor = [UIColor colorWithHexValue:0xFFE9E8E8];
        dividerImageView.image = Divider_Image_N;
        [setTopButton setTitleColor:[UIColor colorWithHexString:@"34393D"] forState:UIControlStateNormal];
        [cancleSubsButton setTitleColor:[UIColor colorWithHexString:@"34393D"] forState:UIControlStateNormal];
    }
}

#pragma mark Button Click
- (void)setTopButtonClick
{
    // 隐藏窗口
    if ([[self superview] isKindOfClass:[MagazineOperateView class]]) {
        MagazineOperateView *scv = (MagazineOperateView*)[self superview];
        [scv hiddenOperateViewWithAnimate:NO];
    }
    
    if (_magazine != nil) {
        MagazineManager *mm = [MagazineManager sharedInstance];
        NSMutableArray *magazinesArray = [mm subsMagazines];
        NSInteger idex = [magazinesArray indexOfObject:_magazine];
        if (idex != NSNotFound && idex != 0) {
            id tempObj = [magazinesArray objectAtIndex:idex];//防止这里的弱引用会释放。
            [magazinesArray removeObject:tempObj];
            [magazinesArray insertObject:tempObj atIndex:0];
            [[SubsChannelsManager sharedInstance] commitChangesWithHandler:^(BOOL succeeded) {
                if (!succeeded) {
                    [PhoneNotification autoHideWithText:@"网络异常，置顶失败"];
                }
            }];
        }
    }
}

- (void)cancleSubsClick
{
    // 隐藏窗口
    if ([[self superview] isKindOfClass:[MagazineOperateView class]]) {
        MagazineOperateView *scv = (MagazineOperateView*)[self superview];
        [scv hiddenOperateViewWithAnimate:NO];
    }
    
    if (_magazine != nil) {
        NSString *title = [NSString stringWithFormat:@"是否确认退订\"%@\"",_magazine.name];
        RIButtonItem *cancel = [RIButtonItem itemWithLabel:@"取消" action:nil];
        RIButtonItem *ok = [RIButtonItem itemWithLabel:@"确定" action:
                            ^{
                                [PhoneNotification manuallyHideWithIndicator];
                                [[SubsChannelsManager sharedInstance] removeMagazine:_magazine];
                                [[SubsChannelsManager sharedInstance] commitChangesWithHandler:^(BOOL succeeded) {
                                    if (!succeeded) {
                                        [PhoneNotification autoHideWithText:@"退订失败"];
                                    } else {
                                        [PhoneNotification autoHideWithText:@"退订成功"];
                                    }
                                }];
                            }];
        
        [[[UIAlertView alloc] initWithTitle:title
                                    message:nil
                           cancelButtonItem:cancel
                           otherButtonItems:ok, nil] show];
    }
}

@end

@implementation MagazineOperateView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        //zyl
        CGRect editingRect = CGRectMake(0, 4, 145.f, 38);
        _subsChannelEidtingView = [[SetTopOrUnsubsView alloc] initWithFrame:editingRect];
        _subsChannelEidtingView.hidden = YES;
        [self addSubview:_subsChannelEidtingView];
        
        _maskView = [[UIView alloc] initWithFrame:editingRect];
        [self addSubview:_maskView];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)viewNightModeChanged:(BOOL)isNight
{
    [_subsChannelEidtingView applyTheme];
    
    if (isNight) {
        _maskView.backgroundColor = [UIColor colorWithHexValue:0xFF3c3d3e];
    }
    else{
        _maskView.backgroundColor = [UIColor whiteColor];
    }
}

- (void)showOperateViewWithMagazine:(MagazineSubsInfo *)m
{
    _subsChannelEidtingView.magazine = m;
    
    [self setHidden:NO];
    [_subsChannelEidtingView setHidden:NO];
    
    [_subsChannelEidtingView applyTheme];
    
    CGRect endMaskRect = _maskView.frame;
    CGRect beginMaskRect = endMaskRect;
    endMaskRect.size.width = 0;
    
    _maskView.backgroundColor = [UIColor whiteColor];
    if ([ThemeMgr sharedInstance].isNightmode) {
        _maskView.backgroundColor = [UIColor colorWithHexValue:0xFF3c3d3e];
    }
    _maskView.frame = beginMaskRect;
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         _maskView.frame = endMaskRect;
                     }
                     completion:^(BOOL finished) {}
    ];
}

- (void)hiddenOperateViewWithAnimate:(BOOL)animate
{
    CGRect endMaskRect = _maskView.frame;
    endMaskRect.size.width = _subsChannelEidtingView.bounds.size.width;
    
    if (animate) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _maskView.frame = endMaskRect;
        } completion:^(BOOL finished) {
            
            [self setHidden:YES];
            [_subsChannelEidtingView setHidden:YES];
        }];
    } else {
        _maskView.frame = endMaskRect;
        [self setHidden:YES];
        [_subsChannelEidtingView setHidden:YES];
    }
    
    if ([[self superview] isKindOfClass:[PhoneSwipeTableView class]]) {
        PhoneSwipeTableView *scv = (PhoneSwipeTableView*)[self superview];
        [scv setTableViewNoneEditing];
    }
}

@end

@interface PhoneSwipeTableView()
{
    UISwipeGestureRecognizer * _leftGestureRecognizer;
    UISwipeGestureRecognizer * _rightGestureRecognizer;
    UITapGestureRecognizer * _tapGestureRecognizer;

    MagazineOperateView * operatingView;

    NSIndexPath * _editingIndexPath;
}

@end

@implementation PhoneSwipeTableView

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        _leftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
        _leftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        _leftGestureRecognizer.delegate = self;
        [self addGestureRecognizer:_leftGestureRecognizer];

        _rightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
        _rightGestureRecognizer.delegate = self;
        _rightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:_rightGestureRecognizer];

        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        _tapGestureRecognizer.delegate = self;
        // Don't add this yet

        operatingView = [[MagazineOperateView alloc] initWithFrame:CGRectMake(kContentWidth, 0, 145.f, 40)];
        [self addSubview:operatingView];

//        [self setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame style:UITableViewStylePlain];
}

- (void)viewNightModeChanged:(BOOL)isNight
{    
    [operatingView viewNightModeChanged:isNight];
}

- (void)setTableViewNoneEditing
{
    if (_editingIndexPath) {
        _editingIndexPath = nil;
        [self removeGestureRecognizer:_tapGestureRecognizer];
    }
}

- (void)swiped:(UISwipeGestureRecognizer *)gestureRecognizer
{
    NSIndexPath * indexPath = [self cellIndexPathForGestureRecognizer:gestureRecognizer];
    if (indexPath == nil)
        return;

    if (gestureRecognizer == _leftGestureRecognizer && ![_editingIndexPath isEqual:indexPath]) {
        UITableViewCell * cell = [self cellForRowAtIndexPath:indexPath];
        [self setEditing:YES atIndexPath:indexPath cell:cell];
    } else if (gestureRecognizer == _rightGestureRecognizer && [_editingIndexPath isEqual:indexPath]){
        UITableViewCell * cell = [self cellForRowAtIndexPath:indexPath];
        [self setEditing:NO atIndexPath:indexPath cell:cell];
    }
}

- (void)tapped:(UIGestureRecognizer *)gestureRecognizer
{
    if (_editingIndexPath) {
        UITableViewCell * cell = [self cellForRowAtIndexPath:_editingIndexPath];
        [self setEditing:NO atIndexPath:_editingIndexPath cell:cell];
    }
}

- (NSIndexPath *)cellIndexPathForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    UIView * view = gestureRecognizer.view;
    if (![view isKindOfClass:[UITableView class]]) {
        return nil;
    }

    CGPoint point = [gestureRecognizer locationInView:view];
    NSIndexPath * indexPath = [self indexPathForRowAtPoint:point];
    return indexPath;
}

- (void)setEditing:(BOOL)editing atIndexPath:indexPath cell:(UITableViewCell *)cell
{
    if (editing) {
        if(_editingIndexPath) {
            UITableViewCell * editingCell = [self cellForRowAtIndexPath:_editingIndexPath];
            [self setEditing:NO atIndexPath:_editingIndexPath cell:editingCell];
            return;
        }
        [self addGestureRecognizer:_tapGestureRecognizer];
    } else {
        [self removeGestureRecognizer:_tapGestureRecognizer];
    }

    CGRect frame = cell.frame;

    CGFloat deleteButtonXOffset = kContentWidth - kDeleteButtonWidth;
    operatingView.frame = (CGRect) {deleteButtonXOffset, frame.origin.y + 15.0f, operatingView.frame.size.width, kDeleteButtonHeight};
    
    if (editing) {
        _editingIndexPath = indexPath;
        MagazineSubsInfo *magazine = [[MagazineManager sharedInstance].subsMagazines objectAtIndex:_editingIndexPath.row];
        [operatingView showOperateViewWithMagazine:magazine];
    } else {
        _editingIndexPath = nil;
        [operatingView hiddenOperateViewWithAnimate:YES];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO; // Recognizers of this class are the first priority
}

@end
