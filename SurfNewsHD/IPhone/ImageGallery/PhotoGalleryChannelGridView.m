//
//  PhotoGalleryChannelGridView.m
//  SurfNewsHD
//
//  Created by SYZ on 13-5-13.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhotoGalleryChannelGridView.h"

#define ITEM_TAGOFFSET            500

@implementation GalleryChannelGridViewItemSpace

- (id)init
{
    self = [super init];
    if (self) {
        self.aRect = CGRectZero;
        self.bRect = CGRectZero;
    }
    return self;
}

- (NSString*)description
{
//    DJLog(@"a:%@", NSStringFromCGRect(_aRect));
//    DJLog(@"b:%@", NSStringFromCGRect(_bRect));
    return nil;
}

@end

//******************************************************************************

@implementation GalleryChannelGridViewItem

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        itemNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 5.0f, 60.0f, 25.0f)];
        itemNameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [itemNameLabel setTextAlignment:NSTextAlignmentCenter];
        itemNameLabel.layer.borderWidth = 1.0f;
        itemNameLabel.layer.cornerRadius = 1.0f;
        itemNameLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:itemNameLabel];
    }
    return self;
}

- (void)setGalleryChannel:(PhotoCollectionChannel *)channel
{
    _galleryChannel = channel;
    itemNameLabel.text = _galleryChannel.name;
    if (_galleryChannel.name.length >= 4) {
        itemNameLabel.font = [UIFont systemFontOfSize:11.0f];
    } else {
        itemNameLabel.font = [UIFont systemFontOfSize:15.0f];
    }
}

- (void)applyTheme:(BOOL)isNight
{
    if (isNight) {
        itemNameLabel.backgroundColor = [UIColor colorWithHexString:@"222223"];
    } else {
        itemNameLabel.backgroundColor = [UIColor colorWithHexString:@"F3F1F1"];
    }
    itemNameLabel.textColor = [UIColor colorWithHexString:@"999292"];
    itemNameLabel.layer.borderColor = [UIColor colorWithHexString:@"999292"].CGColor;
}

- (void)setCurrentItemBorder
{
    itemNameLabel.textColor = [UIColor colorWithHexString:@"AD2F2F"];
    itemNameLabel.layer.borderColor = [UIColor colorWithHexString:@"AD2F2F"].CGColor;
}

- (void)clickEvent
{
    if ([[ThemeMgr sharedInstance] isNightmode]) {
        itemNameLabel.backgroundColor = [UIColor colorWithHexString:@"999292"];
        itemNameLabel.textColor = [UIColor colorWithHexString:@"DCDBDB"];
        itemNameLabel.layer.borderColor = [UIColor colorWithHexString:@"DCDBDB"].CGColor;
    } else {
        itemNameLabel.backgroundColor = [UIColor colorWithHexString:@"DCDBDB"];
    }
}

@end

//******************************************************************************

@interface PhotoGalleryChannelGridView () <UIGestureRecognizerDelegate>
{
    UIView *gridView;
    UILabel *tipLabel;
    CGSize itemSize;                                              //cell的大小
    UILongPressGestureRecognizer *longPressGesture;               //拖动手势
    GalleryChannelGridViewItem *movingItem;                       //移动的cell
    PhotoCollectionChannel *movingChannel;                        //移动的订阅
    NSInteger sortPosition;                                       //移动到的位置
    NSMutableArray *itemFrameArray;
    NSMutableArray *itemSpaceArray;
    NSInteger currentIndex;
    
    BOOL moved;                                                   //是否拖拽
    BOOL isNightMode;
}

@end
    
@implementation PhotoGalleryChannelGridView

#define INVALID_POSITION          -1
#define GRIDVIEW_WIDTH            320.0f
#define ITEM_WIDTH                70.0f
#define ITEM_HEIGHT               35.0f
#define TIPLABEL_HEIGHT           25.0f

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _galleryChannelArray = [NSMutableArray new];
        
        gridView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, GRIDVIEW_WIDTH, 0.0f)];
        [self addSubview:gridView];
                
        tipLabel = [[UILabel alloc] init];
        tipLabel.text = @"长按并拖动按钮可将栏目排序";
        tipLabel.font = [UIFont systemFontOfSize:12.0f];
        [tipLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:tipLabel];
        
        longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureUpdated:)];
        longPressGesture.minimumPressDuration = 0.0f;
        longPressGesture.delegate = self;
        [gridView addGestureRecognizer:longPressGesture];
        
        itemFrameArray = [NSMutableArray new];
        itemSpaceArray = [NSMutableArray new];
    }
    return self;
}

- (void)applyTheme:(BOOL)isNight
{
    isNightMode = isNight;
    UIColor *bgColor = [UIColor colorWithHexValue:isNight?0xFF222223:0xFFF3F1F1];
    self.backgroundColor = bgColor;
    
    
    if (isNight) {
//        gridView.backgroundColor = [UIColor colorWithHexString:@"222223"];
//        tipLabel.backgroundColor = [UIColor colorWithHexString:@"222223"];
        tipLabel.textColor = [UIColor whiteColor];
        
        
    } else {
//        gridView.backgroundColor = [UIColor colorWithHexString:@"F3F1F1"];
//        tipLabel.backgroundColor = [UIColor colorWithHexString:@"F3F1F1"];
        tipLabel.textColor = [UIColor colorWithHexValue:0xff999292];
    }
    
    for (UIView *view in gridView.subviews) {
        if ([view isKindOfClass:[GalleryChannelGridViewItem class]]) {
            GalleryChannelGridViewItem *item = (GalleryChannelGridViewItem *)view;
            [item applyTheme:isNight];
        }
    }
}

//重新加载视图
- (void)reloadView
{
    for (UIView *view in gridView.subviews) {
        [view removeFromSuperview];
    }
    
    [itemFrameArray removeAllObjects];
    
    currentIndex = [_dataSource gridViewCurrentIndex];
    
    for (int i = 0; i < [_galleryChannelArray count]; i++) {
        
        GalleryChannelGridViewItem *item = [[GalleryChannelGridViewItem alloc] initWithFrame:CGRectMake(_edgeInsets.left + (ITEM_WIDTH + _itemHorizontalSpacing) * (i % _itemCountPerRow), _edgeInsets.top + (ITEM_HEIGHT + _itemVerticalSpacing) * (i / _itemCountPerRow), ITEM_WIDTH, ITEM_HEIGHT)];
        item.galleryChannel = [_galleryChannelArray objectAtIndex:i];
        item.tag = ITEM_TAGOFFSET + i;
        [item applyTheme:isNightMode];
        if (i == currentIndex) {
            [item setCurrentItemBorder];
        }
        [itemFrameArray addObject:[NSValue valueWithCGRect:item.frame]];
        [gridView addSubview:item];
    }
    
    [self computeViewFrame];
    [self computeItemSpace:itemFrameArray];
}

//计算各个view的frame
- (void)computeViewFrame
{
    NSInteger rowNumber = _galleryChannelArray.count / _itemCountPerRow;
    if (_galleryChannelArray.count % _itemCountPerRow != 0) {
        rowNumber ++;
    }
    
    gridView.frame = CGRectMake(0.0f, 0.0f,
                                GRIDVIEW_WIDTH, rowNumber * ITEM_HEIGHT + (rowNumber - 1) *_itemVerticalSpacing + _edgeInsets.top + _edgeInsets.bottom);
    tipLabel.frame = CGRectMake(0.0f, gridView.frame.size.height, GRIDVIEW_WIDTH,TIPLABEL_HEIGHT);
    _heightOfView = tipLabel.frame.origin.y + TIPLABEL_HEIGHT;
}

//当移动的点不在gridView区域内的时候重新计算各个GalleryChannelGridViewItem的位置
- (void)reloadItemFrame
{
    [itemFrameArray removeAllObjects];
    
    for (int i = 0; i < [_galleryChannelArray count]; i++) {
        GalleryChannelGridViewItem *item = [[GalleryChannelGridViewItem alloc] init];
        item.tag = ITEM_TAGOFFSET + i;
        item.frame = CGRectMake(_edgeInsets.left + (ITEM_WIDTH + _itemHorizontalSpacing) * (i % _itemCountPerRow),
                                _edgeInsets.top + (ITEM_HEIGHT + _itemVerticalSpacing) * (i / _itemCountPerRow),
                                ITEM_WIDTH,
                                ITEM_HEIGHT);
        [itemFrameArray addObject:[NSValue valueWithCGRect:item.frame]];
    }
    
    [self computeViewFrame];
    [self computeItemSpace:itemFrameArray];
    
    for (int i = 0; i < [itemFrameArray count]; i++) {
        GalleryChannelGridViewItem *item = (GalleryChannelGridViewItem*)[self viewWithTag:ITEM_TAGOFFSET + i];
        [self relayoutItems:item frameOfIndex:i animated:YES];
    }
}

//计算item之间的间距frame
- (void)computeItemSpace:(NSArray*)frameArray
{
    [itemSpaceArray removeAllObjects];
    
    float half = ITEM_WIDTH / 2;
    for (int i = 0; i < [itemFrameArray count]; i++) {
        GalleryChannelGridViewItemSpace *itemSpace = [GalleryChannelGridViewItemSpace new];
        CGRect rect = [[itemFrameArray objectAtIndex:i] CGRectValue];
        if (i == 0) {
            CGRect frame = {CGPointMake(0.0f, 0.0f),
                            CGSizeMake(_edgeInsets.left + half, ITEM_HEIGHT + _itemVerticalSpacing + _edgeInsets.top)};
            itemSpace.bRect = frame;
        } else {
            CGRect forwardRect = [[itemFrameArray objectAtIndex:i - 1] CGRectValue];
            if (rect.origin.y != forwardRect.origin.y) {
                if (i < _itemCountPerRow) {
                    itemSpace.aRect = CGRectMake(forwardRect.origin.x + half,
                                                 forwardRect.origin.y - _edgeInsets.top,
                                                 GRIDVIEW_WIDTH - half - _edgeInsets.right,
                                                 ITEM_HEIGHT + _itemVerticalSpacing + _edgeInsets.top);
                } else {
                    itemSpace.aRect = CGRectMake(forwardRect.origin.x + half,
                                                 forwardRect.origin.y,
                                                 GRIDVIEW_WIDTH - half - _edgeInsets.right,
                                                 ITEM_HEIGHT + _itemVerticalSpacing);
                }
                CGRect frame = {CGPointMake(0.0f, forwardRect.origin.y + ITEM_HEIGHT + _itemVerticalSpacing),
                                CGSizeMake(_edgeInsets.left + half, ITEM_HEIGHT + _itemVerticalSpacing)};
                itemSpace.bRect = frame;
            } else {
                if (i < _itemCountPerRow) {
                    itemSpace.bRect = CGRectMake(forwardRect.origin.x + half,
                                                 forwardRect.origin.y - _edgeInsets.top,
                                                 rect.origin.x - forwardRect.origin.x,
                                                 ITEM_HEIGHT + _itemVerticalSpacing + _edgeInsets.top);
                } else {
                    itemSpace.bRect = CGRectMake(forwardRect.origin.x + half,
                                                 forwardRect.origin.y,
                                                 rect.origin.x - forwardRect.origin.x,
                                                 ITEM_HEIGHT + _itemVerticalSpacing);
                }
            }
        }
        
        [itemSpaceArray addObject:itemSpace];
    }

    GalleryChannelGridViewItemSpace *itemSpace = [GalleryChannelGridViewItemSpace new];
    CGRect rect = [[itemFrameArray lastObject] CGRectValue];
    itemSpace.bRect = CGRectMake(rect.origin.x + half,
                                 rect.origin.y,
                                 GRIDVIEW_WIDTH - rect.origin.x - half,
                                 ITEM_HEIGHT + _itemVerticalSpacing);
    [itemSpaceArray addObject:itemSpace];
}

//计算要移动的item的位置
- (NSInteger)itemPositionFromPoint:(CGPoint)point
{
    int position = INVALID_POSITION;

    for (int i = 0; i < [itemFrameArray count]; i++) {
        CGRect rect = [[itemFrameArray objectAtIndex:i] CGRectValue];
        if (CGRectContainsPoint(rect, point)) {
            movingChannel = [_galleryChannelArray objectAtIndex:i];
            [_galleryChannelArray removeObjectAtIndex:i];
            position = ITEM_TAGOFFSET + i;
            sortPosition = i;
            break;
        }
    }
    
    return position;
}

//获取要移动的item
- (GalleryChannelGridViewItem*)itemAtPositon:(NSInteger)position
{
    GalleryChannelGridViewItem *view = nil;
    
    NSInteger cellPosition = position - ITEM_TAGOFFSET;
    view = (GalleryChannelGridViewItem*)[gridView viewWithTag:position];
    ///**重新计算cell之间的间距,并对tag重新赋值
    [itemFrameArray removeObjectAtIndex:cellPosition];
    [self computeItemSpace:itemFrameArray];
    for (UIView *cell in gridView.subviews) {
        if (cell.tag > position) {
            cell.tag -= 1;
        }
    }
    //**/
    
    return view;
}

//获得当前触摸点处于哪个间距
- (NSInteger)positionOfItemSpace:(CGPoint)point
{
    NSInteger position = INVALID_POSITION;
    
    for (int i = 0; i < [itemSpaceArray count]; i++) {
        GalleryChannelGridViewItemSpace *itemSpace = [itemSpaceArray objectAtIndex:i];
        if (CGRectContainsPoint(itemSpace.aRect, point) ||
            CGRectContainsPoint(itemSpace.bRect, point)) {
            position = i;
            break;
        }
    }
    return position;
}

//重新计算item的位置
- (void)reloadViewFromPosition:(NSInteger)position
{
    [itemFrameArray removeAllObjects];
    
    for (int i = 0; i < _galleryChannelArray.count; i++) {
        CGRect rect = CGRectZero;
        if (i == 0) {
            if (i == position) {
                rect = CGRectMake(_edgeInsets.left + _itemHorizontalSpacing + ITEM_WIDTH,
                                  _edgeInsets.top,
                                  ITEM_WIDTH,
                                  ITEM_HEIGHT);
            } else {
                rect = CGRectMake(_edgeInsets.left,
                                  _edgeInsets.top,
                                  ITEM_WIDTH,
                                  ITEM_HEIGHT);
            }
            [itemFrameArray addObject:[NSValue valueWithCGRect:rect]];
        } else {
            CGRect forwardCellRect = [[itemFrameArray objectAtIndex:i - 1] CGRectValue];
            if (i == position) {
                if (position % _itemCountPerRow == _itemCountPerRow - 1) {      //触摸点在每行的最后一个
                    rect = CGRectMake(_edgeInsets.left,
                                      forwardCellRect.origin.y + ITEM_HEIGHT + _itemVerticalSpacing,
                                      ITEM_WIDTH,
                                      ITEM_HEIGHT);
                } else if (position % _itemCountPerRow == 0) {                  //触摸点在每行的最前一个
                    rect = CGRectMake(_edgeInsets.left + ITEM_WIDTH + _itemHorizontalSpacing,
                                      forwardCellRect.origin.y + ITEM_HEIGHT + _itemVerticalSpacing,
                                      ITEM_WIDTH,
                                      ITEM_HEIGHT);
                } else {
                    rect = CGRectMake(forwardCellRect.origin.x + (ITEM_WIDTH + _itemHorizontalSpacing) * 2 ,
                                      forwardCellRect.origin.y,
                                      ITEM_WIDTH,
                                      ITEM_HEIGHT);
                }
            } else {
                if (forwardCellRect.origin.x + ITEM_WIDTH + _edgeInsets.right == GRIDVIEW_WIDTH) {
                    rect = CGRectMake(_edgeInsets.left,
                                      forwardCellRect.origin.y + ITEM_HEIGHT + _itemVerticalSpacing,
                                      ITEM_WIDTH,
                                      ITEM_HEIGHT);
                } else {
                    rect = CGRectMake(forwardCellRect.origin.x + ITEM_WIDTH + _itemHorizontalSpacing,
                                      forwardCellRect.origin.y,
                                      ITEM_WIDTH,
                                      ITEM_HEIGHT);
                }
            }
            [itemFrameArray addObject:[NSValue valueWithCGRect:rect]];
        }
    }
    
    [self computeItemSpace:itemFrameArray];
    
    for (int i = 0; i < [itemFrameArray count]; i++) {
        GalleryChannelGridViewItem *item = (GalleryChannelGridViewItem*)[self viewWithTag:ITEM_TAGOFFSET + i];
        [self relayoutItems:item frameOfIndex:i animated:YES];
    }
}

//item的移动动画
- (void)relayoutItems:(GalleryChannelGridViewItem*)view frameOfIndex:(int)index animated:(BOOL)animated
{    
    void (^layoutBlock)(void) = ^{
        CGRect newFrame = [[itemFrameArray objectAtIndex:index] CGRectValue];
        view.frame = newFrame;
    };
    
    if (animated) {
        [UIView animateWithDuration:0.3f
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             layoutBlock();
                         }
                         completion:nil
         ];
    }else {
        layoutBlock();
    }
}

//手势结束的动画
- (void)relayoutMovingItems:(GalleryChannelGridViewItem*)view
                   position:(NSInteger)position
      withAnimationFinished:(void(^)(BOOL))handler

{
    if (position == INVALID_POSITION) {
        handler(NO);
        return;
    }
    
    void (^layoutBlock)(void) = ^{
        CGRect frame = CGRectZero;
        if (position == 0) {
            frame = CGRectMake(_edgeInsets.left, _edgeInsets.top, ITEM_WIDTH, ITEM_HEIGHT);
        } else {
            CGRect forwardFrame = [[itemFrameArray objectAtIndex:position - 1] CGRectValue];
            if (forwardFrame.origin.x + ITEM_WIDTH + _edgeInsets.right ==
                GRIDVIEW_WIDTH) {
                frame = CGRectMake(_edgeInsets.left,
                                   forwardFrame.origin.y + ITEM_HEIGHT + _itemVerticalSpacing,
                                   ITEM_WIDTH,
                                   ITEM_HEIGHT);
            } else {
                frame = CGRectMake(forwardFrame.origin.x + ITEM_WIDTH + _itemHorizontalSpacing,
                                   forwardFrame.origin.y,
                                   ITEM_WIDTH,
                                   ITEM_HEIGHT);
            }
        }
        CGRect newFrame = [gridView convertRect:frame toView:self.superview];
        view.frame = newFrame;
    };
    
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         layoutBlock();
                     }
                     completion:^(BOOL finished) {
                         handler(finished);
                     }
     ];
}

//手势结束之后
- (void)didGestureAnimateEnd
{
    if (!movingItem) {
        return;
    }
    
    moved = NO;
    [_galleryChannelArray addObject:movingChannel];
    PhotoCollectionManager *manager = [PhotoCollectionManager sharedInstance];
    [manager changePhotoCollectionChannelListOrder:_galleryChannelArray];
    [movingItem removeFromSuperview];
    movingItem = nil;
    [self reloadView];
}

//点击之后改变边框颜色
- (void)clickChangeBorder:(NSInteger)index;
{
    for (UIView *view in gridView.subviews) {
        if ([view isKindOfClass:[GalleryChannelGridViewItem class]]) {
            GalleryChannelGridViewItem *item = (GalleryChannelGridViewItem*)view;
            [item applyTheme:[[ThemeMgr sharedInstance] isNightmode]];
        }
    }
    GalleryChannelGridViewItem *item = (GalleryChannelGridViewItem*)[gridView viewWithTag:index + ITEM_TAGOFFSET];
    [item setCurrentItemBorder];
}

//长按手势操作
- (void)longPressGestureUpdated:(UIGestureRecognizer*)recognizer
{
    switch (recognizer.state) {
            
        case UIGestureRecognizerStatePossible:
            break;
            
        case UIGestureRecognizerStateBegan:
        {
            if (!movingItem) {
                CGPoint point = [recognizer locationInView:gridView];
                NSInteger position = [self itemPositionFromPoint:point];        //设置排列触摸点为开始触摸点
                //不符合条件的点
                if (position == INVALID_POSITION || movingChannel == nil ) {
                    break;
                }
                
                GalleryChannelGridViewItem *item = [self itemAtPositon:position];
                movingItem = item;
                movingItem.tag = 0;
                [movingItem clickEvent];
                
                CGRect frameInSuperView = [gridView convertRect:item.frame toView:self.superview];
                movingItem.frame = frameInSuperView;
                [movingItem removeFromSuperview];
                [self.superview addSubview:movingItem];
            }
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            if (!movingItem)
                break;
            
            moved = YES;   //有拖拽
            movingItem.center = [recognizer locationInView:self.superview];
            
            CGPoint point = [recognizer locationInView:gridView];
            if (CGRectContainsPoint(gridView.bounds, point)) {
                NSInteger changePosition = [self positionOfItemSpace:point];
                sortPosition = changePosition;
                if (sortPosition == INVALID_POSITION) {
                    [self reloadItemFrame];
                } else {
                    [self reloadViewFromPosition:changePosition];
                }
            } else {
                [self reloadItemFrame];
            }
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            if (movingItem == nil) {
                break;
            }
            
            if (!moved) {//没有拖拽
                [_galleryChannelArray insertObject:movingChannel atIndex:sortPosition];
                PhotoCollectionManager *manager = [PhotoCollectionManager sharedInstance];
                [manager changePhotoCollectionChannelListOrder:_galleryChannelArray];
                [movingItem removeFromSuperview];
                movingItem = nil;
                [self reloadView];
                [self clickChangeBorder:sortPosition];
                [_delegate gridViewItemClicked:movingChannel];
                break;
            }
            
            CGPoint point = [recognizer locationInView:gridView];
            if (CGRectContainsPoint(gridView.bounds, point)) {
                NSInteger changePosition = [self positionOfItemSpace:point];
                [self relayoutMovingItems:movingItem
                                 position:changePosition
                    withAnimationFinished:^(BOOL finished) {
                        if (finished) {
                            moved = NO;
                            [_galleryChannelArray insertObject:movingChannel atIndex:changePosition];
                            PhotoCollectionManager *manager = [PhotoCollectionManager sharedInstance];
                            [manager changePhotoCollectionChannelListOrder:_galleryChannelArray];
                            [movingItem removeFromSuperview];
                            movingItem = nil;
                            [self reloadView];
                        } else {
                            [self didGestureAnimateEnd];
                        }
                }];
            } else {
                [self relayoutMovingItems:movingItem
                                 position:[_galleryChannelArray count]
                    withAnimationFinished:^(BOOL finished) {
                        if (finished) {
                            [self didGestureAnimateEnd];
                        }
                }];
            }
        }
            break;
            
        case UIGestureRecognizerStateFailed:
        {
            [self didGestureAnimateEnd];
            break;
        }
            
        case UIGestureRecognizerStateCancelled:
        {
            [self didGestureAnimateEnd];
            break;
        }
            
        default:
            break;
    }
}

@end
