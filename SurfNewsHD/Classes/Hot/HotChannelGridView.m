//
//  HotChannelGridView.m
//  SurfNewsHD
//
//  Created by SYZ on 13-1-25.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "HotChannelGridView.h"

@implementation HotChannelGridViewCell

@synthesize hotChannel;
@synthesize cellFlag;
@synthesize unDrag;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 70.0f, 30.0f)];
        [self addSubview:backgroundView];
        
        label = [[UILabel alloc] init];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        label.textAlignment = UITextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:18.0f];
        [self addSubview:label];
    }
    return self;
}

- (void)setCellBackground:(NSString *)imageName textColor:(NSString*)color
{
    label.textColor = [UIColor hexChangeFloat:color];
    if([hotChannel.name isEqualToString:@"热推"]) {
        backgroundView.image = nil;
        return;
    } 
    backgroundView.image = [UIImage imageNamed:imageName];
}

- (void)setHotChannel:(HotChannel *)theHotChannel
{
    hotChannel = theHotChannel;
    label.text = hotChannel.name;
    
    if([hotChannel.name isEqualToString:@"热推"]) {   //热推不可拖拽
        self.unDrag = YES;
    }
    
}

@end

@interface HotChannelGridView () <UIGestureRecognizerDelegate>
{
    UIView *invisibleView;
    UIImageView *invisibleBackground;
    UIView *visibleView;
    UIImageView *visibleBackground;
    UIImageView *unexpandView;
    CGSize cellSize;                                              //cell的大小
    UILongPressGestureRecognizer *longPressGesture;                     //拖动手势
    
    HotChannelGridViewCell *movingCell;                           //移动的cell
    
    HotChannel *movingHotChannel;                               //移动的订阅
    NSInteger previousArea;                                       //Changed状态下,前一个触摸对象
    NSInteger sortPosition;                                       //移动到的位置
    NSInteger beginArea;
    
    NSMutableArray *invisibleCellFrameArray;
    NSMutableArray *visibleCellFrameArray;
    NSMutableArray *invisibleCellSpaceArray;
    NSMutableArray *visibleCellSpaceArray;
}

@end

#define INVISIBLE_CELL_TAGOFFSET  500
#define VISIBLE_CELL_TAGOFFSET    1000

#define INVALID_AREA              0
#define INVISIBLE_AREA            1
#define VISIBLE_AREA              2

#define INVALID_POSITION          -1

@implementation HotChannelGridView

@synthesize dataSource, delegate;
@synthesize invisibleChannelArray, visibleChannelArray;
@synthesize widthOfView, heightOfView, cellVerticalSpacing, cellHorizontalSpacing;
@synthesize edgeInsets;
@synthesize cellCountPerRow;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        invisibleBackground = [[UIImageView alloc] init];
        UIImage *invisibleImage = [UIImage imageNamed:@"invisible_hot_channel_bg"];
        [invisibleBackground setImage:[invisibleImage stretchableImageWithLeftCapWidth:0.0f topCapHeight:45.0f]];
        [self addSubview:invisibleBackground];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(14.0f, 8.0f, 80.0f, 30.0f)];
        titleLabel.text = @"更多栏目";
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        titleLabel.textColor = [UIColor hexChangeFloat:@"0E2434"];
        [self addSubview:titleLabel];
        
        invisibleView = [[UIView alloc] init];
        invisibleView.tag = 1;          //无意义,但是重要
        invisibleView.backgroundColor = [UIColor clearColor];
        [self addSubview:invisibleView];
        
        visibleBackground = [[UIImageView alloc] init];
        UIImage *visibleImage = [UIImage imageNamed:@"visible_hot_channel_bg"];
        [visibleBackground setImage:[visibleImage stretchableImageWithLeftCapWidth:0.0f topCapHeight:60.0f]];
        [self addSubview:visibleBackground];
        
        visibleView = [[UIView alloc] init];
        visibleView.tag = 2;            //无意义,但是重要
        visibleView.backgroundColor = [UIColor clearColor];
        [self addSubview:visibleView];
        
        longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureUpdated:)];
        longPressGesture.minimumPressDuration = 0.05f;
        longPressGesture.delegate = self;
        [self addGestureRecognizer:longPressGesture];
        
        invisibleCellFrameArray = [NSMutableArray new];
        visibleCellFrameArray = [NSMutableArray new];
        invisibleCellSpaceArray = [NSMutableArray new];
        visibleCellSpaceArray = [NSMutableArray new];
    }
    return self;
}

//重新加载view
- (void)reloadView
{
    self.invisibleChannelArray = [self.dataSource arrayOfInvisibleCell];
    self.visibleChannelArray = [self.dataSource arrayOfVisibleCell];
    cellSize = [self.dataSource sizeForCell];
    
    [self reloadInvisibleView];
    [self reloadVisibleView];
    [self selfViewHeight];
}

//重新加载不可见区view
- (void)reloadInvisibleView
{
    for (UIView *view in invisibleView.subviews) {
        [view removeFromSuperview];
    }
    
    [invisibleCellFrameArray removeAllObjects];
    
    for (NSInteger i = 0; i < [self.invisibleChannelArray count]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        HotChannelGridViewCell *cell = [self.dataSource cellAtIndexPath:indexPath];
        cell.tag = INVISIBLE_CELL_TAGOFFSET + i;
        cell.frame = CGRectMake(edgeInsets.left + (cellSize.width + cellHorizontalSpacing) * (indexPath.row % self.cellCountPerRow),
                                edgeInsets.top + (cellSize.height + cellVerticalSpacing) * (indexPath.row / self.cellCountPerRow) + 40.0f,
                                cellSize.width,
                                cellSize.height);
        [invisibleCellFrameArray addObject:[NSValue valueWithCGRect:cell.frame]];
        [invisibleView addSubview:cell];
    }
    
    invisibleView.frame = CGRectMake(0.0f, 0.0f, self.widthOfView, [self heightForInvisibleCellArea]);
    invisibleBackground.frame = CGRectMake(0.0f, 0.0f, self.widthOfView + 17.0f, [self heightForInvisibleCellArea]);
    
    [self computeCellSpace:invisibleCellFrameArray invisible:YES];
}

//重新计算不可见区view的frame
- (void)reloadInvisibleViewFrame
{
    [invisibleCellFrameArray removeAllObjects];
    
    for (NSInteger i = 0; i < [self.invisibleChannelArray count]; i++) {
        CGRect frame = CGRectMake(edgeInsets.left + (cellSize.width + cellHorizontalSpacing) * (i % self.cellCountPerRow),
                                  edgeInsets.top + (cellSize.height + cellVerticalSpacing) * (i / self.cellCountPerRow) + 40.0f,
                                  cellSize.width,
                                  cellSize.height);
        [invisibleCellFrameArray addObject:[NSValue valueWithCGRect:frame]];
    }
    
    [self setInvisibleViewFrame];
    
    for (NSInteger i = 0; i < [invisibleCellFrameArray count]; i++) {
        HotChannelGridViewCell *cell = (HotChannelGridViewCell*)[self viewWithTag:INVISIBLE_CELL_TAGOFFSET + i];
        [self relayoutItems:cell frameOfIndex:i invisible:YES animated:YES];
    }
    
    [self computeCellSpace:invisibleCellFrameArray invisible:YES];
}

//重新加载可见区view
- (void)reloadVisibleView
{
    for (UIView *view in visibleView.subviews) {
        [view removeFromSuperview];
    }
    
    [visibleCellFrameArray removeAllObjects];
    
    for (NSInteger i = 0; i < [self.visibleChannelArray count]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:1];
        HotChannelGridViewCell *cell = [self.dataSource cellAtIndexPath:indexPath];
        cell.tag = VISIBLE_CELL_TAGOFFSET + i;
        cell.frame = CGRectMake(edgeInsets.left + (cellSize.width + cellHorizontalSpacing) * (indexPath.row % self.cellCountPerRow),
                                edgeInsets.top + (cellSize.height + cellVerticalSpacing) * (indexPath.row / self.cellCountPerRow) + 55.0f,
                                cellSize.width,
                                cellSize.height);
        [visibleCellFrameArray addObject:[NSValue valueWithCGRect:cell.frame]];
        [visibleView addSubview:cell];
    }
    
    visibleView.frame = CGRectMake(0.0f, [self heightForInvisibleCellArea], self.widthOfView, [self heightForVisibleCellArea]);
    visibleBackground.frame = CGRectMake(0.0f, [self heightForInvisibleCellArea], self.widthOfView + 17.0f, [self heightForVisibleCellArea]);
    
    UILabel *visibleLabel = [[UILabel alloc] initWithFrame:CGRectMake(14.0f, 20.0f, 80.0f, 30.0f)];
    visibleLabel.text = @"我的热推";
    visibleLabel.textAlignment = UITextAlignmentCenter;
    visibleLabel.backgroundColor = [UIColor clearColor];
    visibleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    visibleLabel.textColor = [UIColor blackColor];
    [visibleView addSubview:visibleLabel];
    
    unexpandView = [[UIImageView alloc] initWithFrame:CGRectMake(827.0f, [self heightForVisibleCellArea] - 65.0f, 60.0f, 65.0f)];
    [unexpandView setImage:[UIImage imageNamed:@"hotchannel_unexpand"]];
    [visibleView addSubview:unexpandView];
    
    [self computeCellSpace:visibleCellFrameArray invisible:NO];
}

//重新计算可见区view的frame
- (void)reloadVisibleViewFrame
{
    [visibleCellFrameArray removeAllObjects];
    
    for (NSInteger i = 0; i < [self.visibleChannelArray count]; i++) {
        CGRect frame = CGRectMake(edgeInsets.left + (cellSize.width + cellHorizontalSpacing) * (i % self.cellCountPerRow),
                                  edgeInsets.top + (cellSize.height + cellVerticalSpacing) * (i / self.cellCountPerRow) + 55.0f,
                                  cellSize.width,
                                  cellSize.height);
        [visibleCellFrameArray addObject:[NSValue valueWithCGRect:frame]];
    }
    
    [self setVisibleViewFrame];
    
    for (NSInteger i = 0; i < [visibleCellFrameArray count]; i++) {
        HotChannelGridViewCell *cell = (HotChannelGridViewCell*)[self viewWithTag:VISIBLE_CELL_TAGOFFSET + i];
        [self relayoutItems:cell frameOfIndex:i invisible:NO animated:YES];
    }
    
    [self computeCellSpace:visibleCellFrameArray invisible:NO];
}

//设置不可见区的frame
- (void)setInvisibleViewFrame
{
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         invisibleView.frame = CGRectMake(0.0f, 0.0f, self.widthOfView, [self heightForInvisibleCellArea]);
                         invisibleBackground.frame = CGRectMake(0.0f, 0.0f, self.widthOfView + 17.0f, [self heightForInvisibleCellArea]);
                     }
                     completion:nil
     ];
}

//设置可见区的frame
- (void)setVisibleViewFrame
{
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         visibleView.frame = CGRectMake(0.0f, [self heightForInvisibleCellArea], self.widthOfView, [self heightForVisibleCellArea]);
                         visibleBackground.frame = CGRectMake(0.0f, [self heightForInvisibleCellArea], self.widthOfView + 17.0f, [self heightForVisibleCellArea]);
                         unexpandView.frame = CGRectMake(827.0f, [self heightForVisibleCellArea] - 65.0f, 60.0f, 65.0f);
                     }
                     completion:nil
     ];
}

//不可见cell区域的高度
- (float)heightForInvisibleCellArea
{
    if ([self.invisibleChannelArray count] == 0) {
        float height = edgeInsets.top + cellSize.height + edgeInsets.bottom + 40.0f;
        return height;
    }
    float height = [[invisibleCellFrameArray lastObject] CGRectValue].origin.y + cellSize.height + edgeInsets.bottom;
    return height;
}

//可见cell区域的高度
- (float)heightForVisibleCellArea
{
    if ([self.visibleChannelArray count] == 0) {
        float height = edgeInsets.top + cellSize.height + edgeInsets.bottom + 65.0f;
        return height;
    }
    float height = [[visibleCellFrameArray lastObject] CGRectValue].origin.y + cellSize.height + edgeInsets.bottom + 10.0f;
    return height;
}

//整个区域的高度
- (void)selfViewHeight
{
    self.heightOfView = [self heightForInvisibleCellArea] + [self heightForVisibleCellArea];
}

//计算cell之间的间距frame
- (void)computeCellSpace:(NSArray*)cellFrameArray invisible:(BOOL)invisible
{
    NSMutableArray *cellSpaceArray;
    float marginTop;
    if (invisible) {
        cellSpaceArray = invisibleCellSpaceArray;
        marginTop = 50.0f;
    } else {
        cellSpaceArray = visibleCellSpaceArray;
        marginTop = 65.0f;
    }
    [cellSpaceArray removeAllObjects];
    
    float half = cellSize.width / 2;
    for (NSInteger i = 0; i < [cellFrameArray count]; i++) {
        CellSpace *cellSpace = [CellSpace new];
        CGRect rect = [[cellFrameArray objectAtIndex:i] CGRectValue];
        if (i == 0) {
            CGRect frame = {CGPointMake(0.0f, marginTop),
                            CGSizeMake(rect.origin.x + half, cellSize.height + cellVerticalSpacing)};
            cellSpace.bRect = frame;
        } else {
            CGRect forwardRect = [[cellFrameArray objectAtIndex:i - 1] CGRectValue];
            if (rect.origin.y != forwardRect.origin.y) {
                cellSpace.aRect = CGRectMake(forwardRect.origin.x + half,
                                             forwardRect.origin.y,
                                             self.widthOfView - forwardRect.origin.x - half,
                                             cellSize.height + cellVerticalSpacing);
                CGRect frame = {CGPointMake(0.0f, forwardRect.origin.y + cellSize.height + cellVerticalSpacing),
                                CGSizeMake(rect.origin.x + half, cellSize.height + cellVerticalSpacing)};
                cellSpace.bRect = frame;
            } else {
                cellSpace.bRect = CGRectMake(forwardRect.origin.x + half,
                                             forwardRect.origin.y,
                                             rect.origin.x - forwardRect.origin.x,
                                             cellSize.height + cellVerticalSpacing);
            }
        }
        
        [cellSpaceArray addObject:cellSpace];
    }
    
    CellSpace *cellSpace = [CellSpace new];
    if ([cellFrameArray count] == 0) {
        CGRect frame = {CGPointMake(0.0f, marginTop),
                        CGSizeMake(self.widthOfView, cellSize.height + cellVerticalSpacing)};
        cellSpace.bRect = frame;
        [cellSpaceArray addObject:cellSpace];
        return;
    }
    CGRect rect = [[cellFrameArray lastObject] CGRectValue];
    cellSpace.bRect = CGRectMake(rect.origin.x + half,
                                 rect.origin.y,
                                 self.widthOfView - rect.origin.x,
                                 cellSize.height + cellVerticalSpacing);
    [cellSpaceArray addObject:cellSpace];
}

//获得当前触摸点处于哪个间距
- (NSInteger)positionOfCellSpace:(CGPoint)point invisible:(BOOL)invisible
{
    NSInteger position = INVALID_POSITION;
    if (invisible) {
        CGPoint relativePoint = [self convertPoint:point toView:invisibleView];
        for (NSInteger i = 0; i < [invisibleCellSpaceArray count]; i++) {
            CellSpace *cellSpace = [invisibleCellSpaceArray objectAtIndex:i];
            if (CGRectContainsPoint(cellSpace.aRect, relativePoint) ||
                CGRectContainsPoint(cellSpace.bRect, relativePoint)) {
                position = i;
                break;
            }
        }
    } else {
        CGPoint relativePoint = [self convertPoint:point toView:visibleView];
        for (NSInteger i = 0; i < [visibleCellSpaceArray count]; i++) {
            CellSpace *cellSpace = [visibleCellSpaceArray objectAtIndex:i];
            if (CGRectContainsPoint(cellSpace.aRect, relativePoint) ||
                CGRectContainsPoint(cellSpace.bRect, relativePoint)) {
                position = i;
                break;
            }
        }
    }

    return position;
}

//计算要移动的cell的位置
- (NSInteger)cellPositionFromPoint:(CGPoint)point
{
    NSInteger position = INVALID_POSITION;
    if (point.y <= [self heightForInvisibleCellArea]) {
        CGPoint relativePoint = [self convertPoint:point toView:invisibleView];
        for (NSInteger i = 0; i < [invisibleCellFrameArray count]; i++) {
            CGRect rect = [[invisibleCellFrameArray objectAtIndex:i] CGRectValue];
            if (CGRectContainsPoint(rect, relativePoint)) {
                movingHotChannel = [self.invisibleChannelArray objectAtIndex:i];
                [self.invisibleChannelArray removeObjectAtIndex:i];
                position = INVISIBLE_CELL_TAGOFFSET + i;
                sortPosition = i;
                break;
            }
        }
    } else if (point.y > [self heightForInvisibleCellArea] &&
               point.y <= [self heightOfView]) {
        CGPoint relativePoint = [self convertPoint:point toView:visibleView];
        for (NSInteger i = 0; i < [visibleCellFrameArray count]; i++) {
            CGRect rect = [[visibleCellFrameArray objectAtIndex:i] CGRectValue];
            if (CGRectContainsPoint(rect, relativePoint)) {
                if (i != 0) { //热推不能移动
                    movingHotChannel = [self.visibleChannelArray objectAtIndex:i];
                    [self.visibleChannelArray removeObjectAtIndex:i];
                } else {
                    movingHotChannel = nil;
                }
                position = VISIBLE_CELL_TAGOFFSET + i;
                sortPosition = i;
                break;
            }
        }
    }
    return position;
}

//获取要移动的cell
- (HotChannelGridViewCell*)cellAtPositon:(NSInteger)position
{
    HotChannelGridViewCell *view = nil;
    
    if (position >= VISIBLE_CELL_TAGOFFSET) {
        NSInteger cellPosition = position - VISIBLE_CELL_TAGOFFSET;
        view = (HotChannelGridViewCell*)[visibleView viewWithTag:position];
        ///**重新计算cell之间的间距,并对tag重新赋值
        [visibleCellFrameArray removeObjectAtIndex:cellPosition];
        [self computeCellSpace:visibleCellFrameArray invisible:NO];
        for (UIView *cell in visibleView.subviews) {
            if (cell.tag > position) {
                cell.tag -= 1;
            }
        }
        //**/
        return view;
    }
    
    NSInteger cellPosition = position - INVISIBLE_CELL_TAGOFFSET;
    view = (HotChannelGridViewCell*)[invisibleView viewWithTag:position];
    ///**重新计算cell之间的间距,并对tag重新赋值
    [invisibleCellFrameArray removeObjectAtIndex:cellPosition];
    [self computeCellSpace:invisibleCellFrameArray invisible:YES];
    for (UIView *cell in invisibleView.subviews) {
        if (cell.tag > position) {
            cell.tag -= 1;
        }
    }
    //**/
    return view;
}

//计算当前处于哪个区域
#define INVALID_AREA     0
#define INVISIBLE_AREA   1
#define VISIBLE_AREA     2
- (NSInteger)pointInArea:(CGPoint)point
{
    if (point.y <= [self heightForInvisibleCellArea]) {
        return INVISIBLE_AREA;
    } else if (point.y > [self heightForInvisibleCellArea] &&
               point.y <= [self heightOfView]) {
        return VISIBLE_AREA;
    }
    return INVALID_AREA;
}

//长按手势操作
- (void)longPressGestureUpdated:(UIGestureRecognizer*)recognizer
{
    switch (recognizer.state) {
            
        case UIGestureRecognizerStatePossible:
            break;
            
        case UIGestureRecognizerStateBegan:
        {
            if (!movingCell) {
                CGPoint point = [recognizer locationInView:self];
                NSInteger position = [self cellPositionFromPoint:point];        //设置排列触摸点为开始触摸点
                previousArea = [self pointInArea:point];
                beginArea = previousArea;
                
                if (position == INVALID_POSITION || movingHotChannel == nil) {
                    break;
                }
                
                HotChannelGridViewCell *cell = [self cellAtPositon:position];
                if (cell.unDrag) {
                    break;
                }
                movingCell = cell;
                movingCell.tag = 0;
                
                CGRect frameInSuperView;
                if (previousArea == INVISIBLE_AREA) {
                    frameInSuperView = [invisibleView convertRect:cell.frame toView:self.superview];
                } else {
                    frameInSuperView = [visibleView convertRect:cell.frame toView:self.superview];
                }
                movingCell.frame = frameInSuperView;
                [movingCell removeFromSuperview];
                
                [self.superview addSubview:movingCell];
            }
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            if (!movingCell)
                break;
            
            //拖到左侧的时候失败
            CGPoint centerPonitInSuperView = [recognizer locationInView:self.superview];
            CGPoint ponitInSuperView = CGPointMake(centerPonitInSuperView.x - cellSize.width / 2,
                                                   centerPonitInSuperView.y - cellSize.height / 2);
            if(![self.superview pointInside:ponitInSuperView withEvent:nil]){
                break;
            }
            
            movingCell.center = [recognizer locationInView:self.superview];
            CGPoint point = [recognizer locationInView:self];
            NSInteger currentArea = [self pointInArea:point];
            
            //----------------------------移动到外区-----------------------------
            if (currentArea == INVALID_AREA) {
                if (previousArea == INVALID_AREA) {
                } else if (previousArea == INVISIBLE_AREA) {
                    [self reloadInvisibleViewFrame];
                    [self selfViewHeight];
                } else if (previousArea == VISIBLE_AREA) {
                    [self reloadVisibleViewFrame];
                    [self selfViewHeight];
                }
                previousArea = currentArea;
            }
            
            //---------------------------移动到不可见区---------------------------
            if (currentArea == INVISIBLE_AREA) {
                if (previousArea == INVALID_AREA) {
                } else if (previousArea == VISIBLE_AREA) {
                    [self reloadVisibleViewFrame];
                    [self selfViewHeight];
                } else if (previousArea == INVISIBLE_AREA) {
                    if (point.y <= 40.0f) {  //不可见区的头部
                        [self reloadInvisibleViewFrame];
                    } 
                    NSInteger changePosition = [self positionOfCellSpace:point invisible:YES];
                    sortPosition = changePosition;
                    if (sortPosition == INVALID_POSITION) {
                        break;
                    } else {
                        [self reloadViewFromPosition:changePosition invisible:YES];
                    }
                    [self setVisibleViewFrame];
                    [self selfViewHeight];
                }
                previousArea = currentArea;
            }
            
            //----------------------------移动到可见区----------------------------
            if (currentArea == VISIBLE_AREA) {
                if (previousArea == INVALID_AREA) {//是从外区过来的
                } else if (previousArea == INVISIBLE_AREA) {
                    [self reloadInvisibleViewFrame];
                    [self setVisibleViewFrame];
                    [self selfViewHeight];
                } else if (previousArea == VISIBLE_AREA) {
                    if (point.y > [self heightForInvisibleCellArea] &&
                        point.y <= [self heightForInvisibleCellArea] + 55.0f) {  //可见区的头部
                        [self reloadVisibleViewFrame];
                    }
                    NSInteger changePosition = [self positionOfCellSpace:point invisible:NO];
                    sortPosition = changePosition;
                    if (sortPosition == INVALID_POSITION) {
                        break;
                    } else if (sortPosition == 0) {  //固定热推
                        [self reloadVisibleViewFrame];
                        break;
                    } else {
                        [self reloadViewFromPosition:changePosition invisible:NO];
                    }
                    [self selfViewHeight];
                }
                previousArea = currentArea;
            }
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            if (movingCell == nil) {
                break;
            }
            
            CGPoint point = [recognizer locationInView:self];
            NSInteger currentArea = [self pointInArea:point];
            
            if (currentArea == INVALID_AREA) {
                if (beginArea == INVISIBLE_AREA) {
                    [self relayoutMovingItems:movingCell position:[self.invisibleChannelArray count] invisible:YES withAnimationFinished:^(BOOL finished) {
                        if (finished) {
                            [self.invisibleChannelArray addObject:movingHotChannel];
                            HotChannelsManager *manager = [HotChannelsManager sharedInstance];
                            [manager handleHotChannelsResorted];
                            [movingCell removeFromSuperview];
                            movingCell = nil;
                            [self reloadView];
                        }
                    }];
                } else if (beginArea == VISIBLE_AREA) {
                    [self relayoutMovingItems:movingCell position:[self.visibleChannelArray count] invisible:NO withAnimationFinished:^(BOOL finished) {
                        if (finished) {
                            [self.visibleChannelArray addObject:movingHotChannel];
                            HotChannelsManager *manager = [HotChannelsManager sharedInstance];
                            [manager handleHotChannelsResorted];
                            [movingCell removeFromSuperview];
                            movingCell = nil;
                            [self reloadView];
                        }
                    }];
                }
            } else if (currentArea == INVISIBLE_AREA) {
                if ([self.invisibleChannelArray count] == 0 || sortPosition == INVALID_POSITION) {
                    [self relayoutMovingItems:movingCell position:[self.invisibleChannelArray count] invisible:YES withAnimationFinished:^(BOOL finished) {
                        if (finished) {
                            [self.invisibleChannelArray addObject:movingHotChannel];
                            HotChannelsManager *manager = [HotChannelsManager sharedInstance];
                            [manager handleHotChannelsResorted];
                            [movingCell removeFromSuperview];
                            movingCell = nil;
                            [self reloadView];
                            [self.delegate removeCurrentHotChannel:movingHotChannel];
                        }
                    }];
                } else {
                    [self relayoutMovingItems:movingCell position:sortPosition invisible:YES withAnimationFinished:^(BOOL finished) {
                        if (finished) {
                            [self.invisibleChannelArray insertObject:movingHotChannel atIndex:sortPosition];
                            HotChannelsManager *manager = [HotChannelsManager sharedInstance];
                            [manager handleHotChannelsResorted];
                            [movingCell removeFromSuperview];
                            movingCell = nil;
                            [self reloadView];
                            [self.delegate removeCurrentHotChannel:movingHotChannel];
                        }
                    }];
                }
                
            } else if (currentArea == VISIBLE_AREA) {
                if (sortPosition == INVALID_POSITION || sortPosition == 0) {
                    [self relayoutMovingItems:movingCell position:[self.visibleChannelArray count] invisible:NO withAnimationFinished:^(BOOL finished) {
                        if (finished) {
                            [self.visibleChannelArray addObject:movingHotChannel];
                            HotChannelsManager *manager = [HotChannelsManager sharedInstance];
                            [manager handleHotChannelsResorted];
                            [movingCell removeFromSuperview];
                            movingCell = nil;
                            [self reloadView];
                        }
                    }];
                } else {
                    [self relayoutMovingItems:movingCell position:sortPosition invisible:NO withAnimationFinished:^(BOOL finished) {
                        if (finished) {
                            [self.visibleChannelArray insertObject:movingHotChannel atIndex:sortPosition];
                            HotChannelsManager *manager = [HotChannelsManager sharedInstance];
                            [manager handleHotChannelsResorted];
                            [movingCell removeFromSuperview];
                            movingCell = nil;
                            [self reloadView];
                        }
                    }];
                }
            }
            
            break;
        }
            
        case UIGestureRecognizerStateFailed:
        {
            if (beginArea == INVISIBLE_AREA) {
                [self.invisibleChannelArray addObject:movingHotChannel];
            } else if (beginArea == VISIBLE_AREA) {
                [self.visibleChannelArray addObject:movingHotChannel];
            }
            HotChannelsManager *manager = [HotChannelsManager sharedInstance];
            [manager handleHotChannelsResorted];
            [movingCell removeFromSuperview];
            movingCell = nil;
            [self reloadView];
            
            break;
        }
    
        case UIGestureRecognizerStateCancelled:
        {
            if (beginArea == INVISIBLE_AREA) {
                [self.invisibleChannelArray addObject:movingHotChannel];
            } else if (beginArea == VISIBLE_AREA) {
                [self.visibleChannelArray addObject:movingHotChannel];
            }
            HotChannelsManager *manager = [HotChannelsManager sharedInstance];
            [manager handleHotChannelsResorted];
            [movingCell removeFromSuperview];
            movingCell = nil;
            [self reloadView];
            
            break;
        }
            
        default:
            break;
    }
}

//重新计算cell的位置
- (void)reloadViewFromPosition:(NSInteger)position invisible:(BOOL)invisible
{
    NSInteger count;
    NSInteger section;
    float marginTop = invisible? 40.0f:55.0f;
    NSMutableArray *cellFrameArray;
    if (invisible) {
        section = 0;
        count = [self.invisibleChannelArray count];
        cellFrameArray = invisibleCellFrameArray;
    } else {
        section = 1;
        count = [self.visibleChannelArray count];
        cellFrameArray = visibleCellFrameArray;
    }
    
    [cellFrameArray removeAllObjects];
    
    for (NSInteger i = 0; i < count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:section];
        HotChannelGridViewCell *cell = [self.dataSource cellAtIndexPath:indexPath];
        CGRect rect = CGRectZero;
        if (i == 0) {
            if (i == position) {
                rect = CGRectMake(edgeInsets.left + cellHorizontalSpacing + movingCell.frame.size.width,
                                  edgeInsets.top + marginTop,
                                  cell.frame.size.width,
                                  cell.frame.size.height);
            } else {
                rect = CGRectMake(edgeInsets.left,
                                  edgeInsets.top + marginTop,
                                  cell.frame.size.width,
                                  cell.frame.size.height);
            }
            [cellFrameArray addObject:[NSValue valueWithCGRect:rect]];
        } else {
            CGRect forwardCellRect = [[cellFrameArray objectAtIndex:i - 1] CGRectValue];
            if (i == position) {
                if (forwardCellRect.origin.x + forwardCellRect.size.width + cellHorizontalSpacing +
                    movingCell.frame.size.width == self.widthOfView - edgeInsets.left) {
                    rect = CGRectMake(edgeInsets.left,
                                      forwardCellRect.origin.y + cellSize.height + cellVerticalSpacing,
                                      cell.frame.size.width,
                                      cell.frame.size.height);
                } else if (forwardCellRect.origin.x + forwardCellRect.size.width + cellHorizontalSpacing +
                           movingCell.frame.size.width > self.widthOfView - edgeInsets.left) {
                    rect = CGRectMake(edgeInsets.left + movingCell.frame.size.width + cellHorizontalSpacing,
                                      forwardCellRect.origin.y + cellSize.height + cellVerticalSpacing,
                                      cell.frame.size.width,
                                      cell.frame.size.height);
                } else {
                    if (forwardCellRect.origin.x + forwardCellRect.size.width + 2 * cellHorizontalSpacing +
                        movingCell.frame.size.width + cell.frame.size.width > self.widthOfView - edgeInsets.left) {
                        rect = CGRectMake(edgeInsets.left,
                                          forwardCellRect.origin.y + cellSize.height + cellVerticalSpacing,
                                          cell.frame.size.width,
                                          cell.frame.size.height);
                    } else {
                        rect = CGRectMake(forwardCellRect.origin.x + forwardCellRect.size.width + 2 * cellHorizontalSpacing + movingCell.frame.size.width,
                                          forwardCellRect.origin.y,
                                          cell.frame.size.width,
                                          cell.frame.size.height);
                    }
                }
            } else {
                if (forwardCellRect.origin.x + forwardCellRect.size.width + cellHorizontalSpacing + cell.frame.size.width >
                    self.widthOfView - edgeInsets.left) {
                    rect = CGRectMake(edgeInsets.left,
                                      forwardCellRect.origin.y + cellSize.height + cellVerticalSpacing,
                                      cell.frame.size.width,
                                      cell.frame.size.height);
                } else {
                    rect = CGRectMake(forwardCellRect.origin.x + forwardCellRect.size.width + cellHorizontalSpacing,
                                      forwardCellRect.origin.y,
                                      cell.frame.size.width,
                                      cell.frame.size.height);
                }
            }
            [cellFrameArray addObject:[NSValue valueWithCGRect:rect]];
        }
    }
    
    [self computeCellSpace:cellFrameArray invisible:invisible];
    
    if (invisible) {
        [self setInvisibleViewFrame];
        for (NSInteger i = 0; i < [cellFrameArray count]; i++) {
            HotChannelGridViewCell *cell = (HotChannelGridViewCell*)[self viewWithTag:INVISIBLE_CELL_TAGOFFSET + i];
            [self relayoutItems:cell frameOfIndex:i invisible:YES animated:YES];
        }
    } else {
        [self setVisibleViewFrame];
        for (NSInteger i = 0; i < [cellFrameArray count]; i++) {
            HotChannelGridViewCell *cell = (HotChannelGridViewCell*)[self viewWithTag:VISIBLE_CELL_TAGOFFSET + i];
            [self relayoutItems:cell frameOfIndex:i invisible:NO animated:YES];
        }
    }
}

//cell的移动动画
- (void)relayoutItems:(HotChannelGridViewCell*)view
         frameOfIndex:(NSInteger)index
            invisible:(BOOL)invisible
             animated:(BOOL)animated
{
    NSMutableArray *cellFrameArray;
    if (invisible) {
        cellFrameArray = invisibleCellFrameArray;
    } else {
        cellFrameArray = visibleCellFrameArray;
    }
    
    void (^layoutBlock)(void) = ^{
        CGRect newFrame = [[cellFrameArray objectAtIndex:index] CGRectValue];
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
- (void)relayoutMovingItems:(HotChannelGridViewCell*)view
                   position:(NSInteger)position
                  invisible:(BOOL)invisible
      withAnimationFinished:(void(^)(BOOL))handler

{
    float marginTop = invisible? 40.0f:55.0f;
    NSMutableArray *cellFrameArray;
    if (invisible) {
        cellFrameArray = invisibleCellFrameArray;
    } else {
        cellFrameArray = visibleCellFrameArray;
    }
    
    void (^layoutBlock)(void) = ^{
        CGRect frame = CGRectZero;
        if (position == 0) {
            frame = CGRectMake(edgeInsets.left, edgeInsets.top + marginTop, cellSize.width, cellSize.height);
        } else {
            CGRect forwardFrame = [[cellFrameArray objectAtIndex:position - 1] CGRectValue];
            if (forwardFrame.origin.x + 2 * cellSize.width + cellHorizontalSpacing > self.widthOfView) {
                frame = CGRectMake(edgeInsets.left,
                                   forwardFrame.origin.y + cellVerticalSpacing,
                                   cellSize.width,
                                   cellSize.height);
            } else {
                frame = CGRectMake(forwardFrame.origin.x + cellSize.width + cellHorizontalSpacing,
                                   forwardFrame.origin.y,
                                   cellSize.width,
                                   cellSize.height);
            }
        }
        
        if (invisible) {
            CGRect newFrame = [invisibleView convertRect:frame toView:self.superview];
            view.frame = newFrame;
        } else {
            CGRect newFrame = [visibleView convertRect:frame toView:self.superview];
            view.frame = newFrame;
        }
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

#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint touchPoint = [touch locationInView:self];
    
    if (CGRectContainsPoint(CGRectMake(827.0f, self.heightOfView - 65.0f, 60.0f, 65.0f), touchPoint)) {
        [self.delegate foldHotChannels]; //收起区域
        return NO;
    }
    return YES;
}

@end
