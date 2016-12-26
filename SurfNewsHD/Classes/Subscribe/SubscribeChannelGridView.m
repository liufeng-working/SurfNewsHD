//
//  SubscribeChannelGridView.m
//  SurfNewsHD
//
//  Created by SYZ on 13-3-25.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SubscribeChannelGridView.h"

@implementation CellSpace

- (id)init
{
    self = [super init];
    if (self) {
        self.aRect = CGRectZero;
    }
    return self;
}

- (NSString*)description
{
    DJLog(@"-------------------");
    DJLog(@"a:%f, %f, %f, %f",self.aRect.origin.x, self.aRect.origin.y, self.aRect.size.width, self.aRect.size.height);
    DJLog(@"b:%f, %f, %f, %f",self.bRect.origin.x, self.bRect.origin.y, self.bRect.size.width, self.bRect.size.height);
    return nil;
}

@end

#define CELL_HEIGHT    30.0f
#define MarginLeft     15.0f
#define LabelSizeFont  18.0f
@implementation SubscribeChannelGridViewCell

@synthesize subsChannel;

- (id)init
{
    self = [super init];
    if (self) {
        backgroundView = [[UIImageView alloc] init];
        [self addSubview:backgroundView];
        
        label = [[UILabel alloc] init];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        label.textAlignment = UITextAlignmentRight;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:LabelSizeFont];
        [self addSubview:label];
        
        deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteButton.hidden = YES;
        deleteButton.frame = CGRectMake(0.0f, 0.0f, 34.0f, CELL_HEIGHT);
        [deleteButton addTarget:self action:@selector(deleteSubsChannel:) forControlEvents:UIControlEventTouchUpInside];
        [deleteButton setBackgroundImage:[UIImage imageNamed:@"subscribe_delete"] forState:UIControlStateNormal];
        [self addSubview:deleteButton];
    }
    return self;
}

- (void)setSubsChannel:(SubsChannel *)theSubsChannel onlyOne:(BOOL)only
{
    subsChannel = theSubsChannel;
    label.text = subsChannel.name;
    
    CGSize viewSize = [subsChannel.name sizeWithFont:[UIFont systemFontOfSize:LabelSizeFont]
                                   constrainedToSize:CGSizeMake(MAXFLOAT, CELL_HEIGHT)
                                       lineBreakMode:UILineBreakModeWordWrap];

    if (only) {
        deleteButton.hidden = YES;
        CGRect viewFrame = {CGPointZero, CGSizeMake(viewSize.width + 2 * MarginLeft, CELL_HEIGHT)};
        self.frame = viewFrame;
        backgroundView.frame = viewFrame;
        label.frame = CGRectMake(MarginLeft, 0.0f, viewSize.width, CELL_HEIGHT);
        return;
    }
    deleteButton.hidden = NO;
    CGRect viewFrame = {CGPointZero, CGSizeMake(viewSize.width + MarginLeft + deleteButton.frame.size.width, CELL_HEIGHT)};
    self.frame = viewFrame;
    backgroundView.frame = viewFrame;
    label.frame = CGRectMake(MarginLeft, 0.0f, viewSize.width, CELL_HEIGHT);
    deleteButton.frame = CGRectMake(viewSize.width + MarginLeft, 0.0f, 34.0f, CELL_HEIGHT);
}

- (void)setCellBackground:(NSString *)imageName textColor:(NSString*)color
{
    UIImage *image = [UIImage imageNamed:imageName];
    [backgroundView setImage:[image stretchableImageWithLeftCapWidth:30.0f topCapHeight:0.0f]];
    
    label.textColor = [UIColor hexChangeFloat:color];
}

- (BOOL)pointInDeleteButton:(CGPoint)point
{
    return CGRectContainsPoint(deleteButton.frame, point);
}

- (void)deleteSubsChannel:(UIButton*)sender
{
    
}

@end

@interface SubscribeChannelGridView () <UIGestureRecognizerDelegate>
{
    UIView *invisibleView;
    UIImageView *invisibleBackground;
    UIView *visibleView;
    UIImageView *visibleBackground;
    UIView *otherView;
    UILongPressGestureRecognizer *longPressGesture;               //拖动手势
    
    SubscribeChannelGridViewCell *movingCell;                     //移动的cell
    
    SubsChannel *movingSubsChannel;                               //移动的订阅
    SubsChannel *deleteSubsChannel;                               //删除的订阅
    NSInteger previousArea;                                       //Changed状态下,前一个触摸对象
    NSInteger sortPosition;                                       //移动到的位置
    NSInteger beginArea;
    
    BOOL changed;
    
    NSMutableArray *invisibleCellFrameArray;
    NSMutableArray *visibleCellFrameArray;
    NSMutableArray *invisibleCellSpaceArray;
    NSMutableArray *visibleCellSpaceArray;
    
    float invisibleViewheight;
    float visibleViewHeight;
    
    UIScrollView *scrollView;
}

@end

#define CELL_TAGOFFSET            500
#define INVISIBLE_CELL_TAGOFFSET  500
#define VISIBLE_CELL_TAGOFFSET    1000

#define INVALID_POSITION          -1

@implementation SubscribeChannelGridView

@synthesize delegate, dataSource;
@synthesize heightOfView, cellVerticalSpacing, cellHorizontalSpacing;
@synthesize edgeInsets;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y,
                                                                    self.bounds.size.width, self.bounds.size.height - 43.0f)];
        scrollView.bounces = NO;
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:scrollView];
        
        invisibleBackground = [[UIImageView alloc] init];
        UIImage *invisibleImage = [UIImage imageNamed:@"invisible_subs_channel_bg"];
        [invisibleBackground setImage:[invisibleImage stretchableImageWithLeftCapWidth:0.0f topCapHeight:45.0f]];
        [scrollView addSubview:invisibleBackground];
        
        UILabel *invisibleLabel = [[UILabel alloc] initWithFrame:CGRectMake(14.0f, 8.0f, 80.0f, 30.0f)];
        invisibleLabel.text = @"其他订阅";
        invisibleLabel.textAlignment = UITextAlignmentCenter;
        invisibleLabel.backgroundColor = [UIColor clearColor];
        invisibleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        invisibleLabel.textColor = [UIColor hexChangeFloat:@"0E2434"];
        [scrollView addSubview:invisibleLabel];
        
        UIButton *finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [finishButton setFrame:CGRectMake(750.0f, 6.0f, 95.0f, 33.0f)];
        [finishButton setBackgroundImage:[UIImage imageNamed:@"subs_channel_button"]
                                forState:UIControlStateNormal];
        [scrollView addSubview:finishButton];
        
        invisibleView = [[UIView alloc] init];
        invisibleView.tag = 1;          //无意义,但是重要
        invisibleView.backgroundColor = [UIColor clearColor];
        [scrollView addSubview:invisibleView];
        
        visibleBackground = [[UIImageView alloc] init];
        UIImage *visibleImage = [UIImage imageNamed:@"visible_subs_channel_bg"];
        [visibleBackground setImage:[visibleImage stretchableImageWithLeftCapWidth:0.0f topCapHeight:60.0f]];
        [scrollView addSubview:visibleBackground];
        
        visibleView = [[UIView alloc] init];
        visibleView.tag = 2;            //无意义,但是重要
        visibleView.backgroundColor = [UIColor clearColor];
        [scrollView addSubview:visibleView];
        
        otherView = [[UIView alloc] init];
        otherView.backgroundColor = [UIColor hexChangeFloat:@"E1DDD1"];
        otherView.alpha = 0.85f;
        [scrollView addSubview:otherView];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGesture:)];
        singleTap.delegate = self;
        [self addGestureRecognizer:singleTap];
        
        longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureUpdated:)];
        longPressGesture.minimumPressDuration = 0.05f;
        longPressGesture.delegate = self;
        [scrollView addGestureRecognizer:longPressGesture];
        
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
    
    for (int i = 0; i < [self.invisibleChannelArray count]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        SubscribeChannelGridViewCell *cell = [self.dataSource cellAtIndexPath:indexPath];
        cell.tag = INVISIBLE_CELL_TAGOFFSET + i;
        if (i == 0) {
            CGRect rect = CGRectMake(edgeInsets.left,
                                     edgeInsets.top + 40.0f,
                                     cell.frame.size.width,
                                     cell.frame.size.height);
            cell.frame = rect;
            [invisibleCellFrameArray addObject:[NSValue valueWithCGRect:rect]];
        } else {
            CGRect forwardCellRect = [[invisibleCellFrameArray objectAtIndex:i - 1] CGRectValue];
            CGRect rect = CGRectZero;
            if (forwardCellRect.origin.x + forwardCellRect.size.width + cellHorizontalSpacing + cell.frame.size.width >
                self.widthOfView - edgeInsets.left) {
                rect = CGRectMake(edgeInsets.left,
                                  forwardCellRect.origin.y + CELL_HEIGHT + cellVerticalSpacing,
                                  cell.frame.size.width,
                                  cell.frame.size.height);
            } else {
                rect = CGRectMake(forwardCellRect.origin.x + forwardCellRect.size.width + cellHorizontalSpacing,
                                  forwardCellRect.origin.y,
                                  cell.frame.size.width,
                                  cell.frame.size.height);
            }
            cell.frame = rect;
            [invisibleCellFrameArray addObject:[NSValue valueWithCGRect:rect]];
        }
        [invisibleView addSubview:cell];
    }
    
    invisibleView.frame = CGRectMake(0.0f, 0.0f, self.widthOfView, [self heightForInvisibleCellArea]);
    invisibleBackground.frame = CGRectMake(0.0f, 0.0f, self.widthOfView, [self heightForInvisibleCellArea]);
    
    [self computeCellSpace:invisibleCellFrameArray invisible:YES];
}

//重新加载不可见区view的Frame
- (void)reloadInvisibleViewFrame
{
    [scrollView setContentSize:CGSizeMake(self.bounds.size.width, invisibleViewheight + visibleViewHeight)];
    
    [invisibleCellFrameArray removeAllObjects];
    
    for (int i = 0; i < [self.invisibleChannelArray count]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        SubscribeChannelGridViewCell *cell = [self.dataSource cellAtIndexPath:indexPath];
        cell.tag = INVISIBLE_CELL_TAGOFFSET + i;
        if (i == 0) {
            CGRect rect = CGRectMake(edgeInsets.left,
                                     edgeInsets.top + 40.0f,
                                     cell.frame.size.width,
                                     cell.frame.size.height);
            cell.frame = rect;
            [invisibleCellFrameArray addObject:[NSValue valueWithCGRect:rect]];
        } else {
            CGRect forwardCellRect = [[invisibleCellFrameArray objectAtIndex:i - 1] CGRectValue];
            CGRect rect = CGRectZero;
            if (forwardCellRect.origin.x + forwardCellRect.size.width + cellHorizontalSpacing + cell.frame.size.width >
                self.widthOfView - edgeInsets.left) {
                rect = CGRectMake(edgeInsets.left,
                                  forwardCellRect.origin.y + CELL_HEIGHT + cellVerticalSpacing,
                                  cell.frame.size.width,
                                  cell.frame.size.height);
            } else {
                rect = CGRectMake(forwardCellRect.origin.x + forwardCellRect.size.width + cellHorizontalSpacing,
                                  forwardCellRect.origin.y,
                                  cell.frame.size.width,
                                  cell.frame.size.height);
            }
            cell.frame = rect;
            [invisibleCellFrameArray addObject:[NSValue valueWithCGRect:rect]];
        }
    }
    
    [self setInvisibleViewFrame];
    
    for (int i = 0; i < [invisibleCellFrameArray count]; i++) {
        SubscribeChannelGridViewCell *cell = (SubscribeChannelGridViewCell*)[self viewWithTag:INVISIBLE_CELL_TAGOFFSET + i];
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
    
    for (int i = 0; i < [self.visibleChannelArray count]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:1];
        SubscribeChannelGridViewCell *cell = [self.dataSource cellAtIndexPath:indexPath];
        cell.tag = VISIBLE_CELL_TAGOFFSET + i;
        if (i == 0) {
            CGRect rect = CGRectMake(edgeInsets.left,
                                     edgeInsets.top + 55.0f,
                                     cell.frame.size.width,
                                     cell.frame.size.height);
            cell.frame = rect;
            [visibleCellFrameArray addObject:[NSValue valueWithCGRect:rect]];
        } else {
            CGRect forwardCellRect = [[visibleCellFrameArray objectAtIndex:i - 1] CGRectValue];
            CGRect rect = CGRectZero;
            if (forwardCellRect.origin.x + forwardCellRect.size.width + cellHorizontalSpacing + cell.frame.size.width >
                self.widthOfView - edgeInsets.left) {
                rect = CGRectMake(edgeInsets.left,
                                  forwardCellRect.origin.y + CELL_HEIGHT + cellVerticalSpacing,
                                  cell.frame.size.width,
                                  cell.frame.size.height);
            } else {
                rect = CGRectMake(forwardCellRect.origin.x + forwardCellRect.size.width + cellHorizontalSpacing,
                                  forwardCellRect.origin.y,
                                  cell.frame.size.width,
                                  cell.frame.size.height);
            }
            cell.frame = rect;
            [visibleCellFrameArray addObject:[NSValue valueWithCGRect:rect]];
        }
        [visibleView addSubview:cell];
    }
    
    
    visibleView.frame = CGRectMake(0.0f, [self heightForInvisibleCellArea], self.widthOfView, [self heightForVisibleCellArea]);
    visibleBackground.frame = CGRectMake(0.0f, [self heightForInvisibleCellArea], self.widthOfView, [self heightForVisibleCellArea]);
    
    UILabel *visibleLabel = [[UILabel alloc] initWithFrame:CGRectMake(14.0f, 20.0f, 80.0f, 30.0f)];
    visibleLabel.text = @"常看订阅";
    visibleLabel.textAlignment = UITextAlignmentCenter;
    visibleLabel.backgroundColor = [UIColor clearColor];
    visibleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    visibleLabel.textColor = [UIColor blackColor];
    [visibleView addSubview:visibleLabel];
    
    [self computeCellSpace:visibleCellFrameArray invisible:NO];
}

//重新加载可见区view的frame
- (void)reloadVisibleViewFrame
{
    [visibleCellFrameArray removeAllObjects];
    
    for (int i = 0; i < [self.visibleChannelArray count]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:1];
        SubscribeChannelGridViewCell *cell = [self.dataSource cellAtIndexPath:indexPath];
        cell.tag = VISIBLE_CELL_TAGOFFSET + i;
        if (i == 0) {
            CGRect rect = CGRectMake(edgeInsets.left,
                                     edgeInsets.top + 55.0f,
                                     cell.frame.size.width,
                                     cell.frame.size.height);
            cell.frame = rect;
            [visibleCellFrameArray addObject:[NSValue valueWithCGRect:rect]];
        } else {
            CGRect forwardCellRect = [[visibleCellFrameArray objectAtIndex:i - 1] CGRectValue];
            CGRect rect = CGRectZero;
            if (forwardCellRect.origin.x + forwardCellRect.size.width + cellHorizontalSpacing + cell.frame.size.width >
                self.widthOfView - edgeInsets.left) {
                rect = CGRectMake(edgeInsets.left,
                                  forwardCellRect.origin.y + CELL_HEIGHT + cellVerticalSpacing,
                                  cell.frame.size.width,
                                  cell.frame.size.height);
            } else {
                rect = CGRectMake(forwardCellRect.origin.x + forwardCellRect.size.width + cellHorizontalSpacing,
                                  forwardCellRect.origin.y,
                                  cell.frame.size.width,
                                  cell.frame.size.height);
            }
            cell.frame = rect;
            [visibleCellFrameArray addObject:[NSValue valueWithCGRect:rect]];
        }
    }
    
    [self setVisibleViewFrame];
    
    for (int i = 0; i < [visibleCellFrameArray count]; i++) {
        SubscribeChannelGridViewCell *cell = (SubscribeChannelGridViewCell*)[self viewWithTag:VISIBLE_CELL_TAGOFFSET + i];
        [self relayoutItems:cell frameOfIndex:i invisible:NO animated:YES];
    }
    
    [self computeCellSpace:visibleCellFrameArray invisible:NO];
}

//设置不可见区的frame
- (void)setInvisibleViewFrame
{
    [scrollView setContentSize:CGSizeMake(self.bounds.size.width, invisibleViewheight + visibleViewHeight)];
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         invisibleView.frame = CGRectMake(0.0f, 0.0f, self.widthOfView, [self heightForInvisibleCellArea]);
                         invisibleBackground.frame = CGRectMake(0.0f, 0.0f, self.widthOfView, [self heightForInvisibleCellArea]);
                     }
                     completion:nil
     ];
}

//设置可见区的frame
- (void)setVisibleViewFrame
{
    [scrollView setContentSize:CGSizeMake(self.bounds.size.width, invisibleViewheight + visibleViewHeight)];
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         visibleView.frame = CGRectMake(0.0f, [self heightForInvisibleCellArea], self.widthOfView, [self heightForVisibleCellArea]);
                         visibleBackground.frame = CGRectMake(0.0f, [self heightForInvisibleCellArea], self.widthOfView, [self heightForVisibleCellArea]);
                     }
                     completion:nil
     ];
}

//不可见cell区域的高度
- (float)heightForInvisibleCellArea
{
    if ([self.invisibleChannelArray count] == 0) {
        invisibleViewheight = edgeInsets.top + CELL_HEIGHT + edgeInsets.bottom + 40.0f;
        return invisibleViewheight;
    }
    invisibleViewheight = [[invisibleCellFrameArray lastObject] CGRectValue].origin.y + CELL_HEIGHT + edgeInsets.bottom;
    return invisibleViewheight;
}

//可见cell区域的高度
- (float)heightForVisibleCellArea
{
    if ([self.visibleChannelArray count] == 0) {
        visibleViewHeight = edgeInsets.top + CELL_HEIGHT + edgeInsets.bottom + 55.0f;
        return visibleViewHeight;
    }
    visibleViewHeight = [[visibleCellFrameArray lastObject] CGRectValue].origin.y + CELL_HEIGHT + edgeInsets.bottom;
    return visibleViewHeight;
}

//整个区域的高度
- (void)selfViewHeight
{
    self.heightOfView = invisibleViewheight + visibleViewHeight;
    [scrollView setContentSize:CGSizeMake(self.bounds.size.width, heightOfView)];
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         if (heightOfView + 5.0f >= scrollView.frame.size.height) {
                             otherView.hidden = YES;
                         } else {
                             otherView.hidden = NO;
                             otherView.frame = CGRectMake(0.0f,
                                                          self.heightOfView + 5.0f,
                                                          self.widthOfView,
                                                          self.frame.size.height - self.heightOfView - 48.0f);
                         }
                     }
                     completion:nil
     ];
}

//计算cell之间的间距frame
- (void)computeCellSpace:(NSArray*)cellFrameArray invisible:(BOOL)invisble
{
    float marginTop = invisble? 50.0f : 65.0f;
    NSMutableArray *cellSpaceArray;
    if (invisble) {
        cellSpaceArray = invisibleCellSpaceArray;
    } else {
        cellSpaceArray = visibleCellSpaceArray;
    }
    [cellSpaceArray removeAllObjects];
    
    for (int i = 0; i < [cellFrameArray count]; i++) {
        CellSpace *cellSpace = [CellSpace new];
        CGRect rect = [[cellFrameArray objectAtIndex:i] CGRectValue];
        if (i == 0) {
            CGRect frame = {CGPointMake(0.0f, marginTop),
                            CGSizeMake(rect.origin.x + rect.size.width / 2,
                                       CELL_HEIGHT + cellVerticalSpacing)};
            cellSpace.bRect = frame;
        } else {
            CGRect forwardRect = [[cellFrameArray objectAtIndex:i - 1] CGRectValue];
            if (rect.origin.y != forwardRect.origin.y) {
                cellSpace.aRect = CGRectMake(forwardRect.origin.x + forwardRect.size.width / 2,
                                             forwardRect.origin.y,
                                             self.widthOfView - forwardRect.origin.x - forwardRect.size.width / 2,
                                             CELL_HEIGHT + cellVerticalSpacing);
                CGRect frame = {CGPointMake(0.0f, forwardRect.origin.y + cellVerticalSpacing + forwardRect.size.height),
                                CGSizeMake(rect.origin.x + rect.size.width / 2,
                                           CELL_HEIGHT + cellVerticalSpacing)};
                cellSpace.bRect = frame;
            } else {
                cellSpace.bRect = CGRectMake(forwardRect.origin.x + forwardRect.size.width / 2,
                                             forwardRect.origin.y,
                                             rect.origin.x + rect.size.width / 2 - forwardRect.origin.x - forwardRect.size.width / 2,
                                             CELL_HEIGHT + cellVerticalSpacing);
            }
        }
        
        [cellSpaceArray addObject:cellSpace];
     
    }
    
    CellSpace *cellSpace = [CellSpace new];
    CGRect rect = [[cellFrameArray lastObject] CGRectValue];
    cellSpace.bRect = CGRectMake(rect.origin.x + rect.size.width / 2,
                                 rect.origin.y,
                                 self.widthOfView - rect.origin.x - rect.size.width / 2,
                                 CELL_HEIGHT + cellVerticalSpacing);
    [cellSpaceArray addObject:cellSpace];
}

//获得当前触摸点处于哪个间距
- (NSInteger)positionOfCellSpace:(CGPoint)point invisible:(BOOL)invisible
{
    NSInteger position = INVALID_POSITION;
    if (invisible) {
        CGPoint relativePoint = [scrollView convertPoint:point toView:invisibleView];
        for (int i = 0; i < [invisibleCellSpaceArray count]; i++) {
            CellSpace *cellSpace = [invisibleCellSpaceArray objectAtIndex:i];
            if (CGRectContainsPoint(cellSpace.aRect, relativePoint) ||
                CGRectContainsPoint(cellSpace.bRect, relativePoint)) {
                position = i;
                break;
            } 
        }
    } else {
        CGPoint relativePoint = [scrollView convertPoint:point toView:visibleView];
        for (int i = 0; i < [visibleCellSpaceArray count]; i++) {
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
    int position = INVALID_POSITION;
    if (point.y <= [self heightForInvisibleCellArea]) {
        CGPoint relativePoint = [scrollView convertPoint:point toView:invisibleView];
        for (int i = 0; i < [invisibleCellFrameArray count]; i++) {
            CGRect rect = [[invisibleCellFrameArray objectAtIndex:i] CGRectValue];
            if (CGRectContainsPoint(rect, relativePoint)) {
                movingSubsChannel = [self.invisibleChannelArray objectAtIndex:i];
                [self.invisibleChannelArray removeObjectAtIndex:i];
                position = INVISIBLE_CELL_TAGOFFSET + i;
                sortPosition = i;
                break;
            }
        }
    } else if (point.y > [self heightForInvisibleCellArea] &&
               point.y <= [self heightOfView]) {
        CGPoint relativePoint = [scrollView convertPoint:point toView:visibleView];
        for (int i = 0; i < [visibleCellFrameArray count]; i++) {
            CGRect rect = [[visibleCellFrameArray objectAtIndex:i] CGRectValue];
            if (CGRectContainsPoint(rect, relativePoint)) {
                movingSubsChannel = [self.visibleChannelArray objectAtIndex:i];
                [self.visibleChannelArray removeObjectAtIndex:i];
                position = VISIBLE_CELL_TAGOFFSET + i;
                sortPosition = i;
                break;
            }
        }
    }
    return position;
}

//计算点击的cell的位置
- (NSInteger)tapCellPositionFromPoint:(CGPoint)point
{
    int position = INVALID_POSITION;
    if (point.y <= [self heightForInvisibleCellArea]) {
        CGPoint relativePoint = [scrollView convertPoint:point toView:invisibleView];
        for (int i = 0; i < [invisibleCellFrameArray count]; i++) {
            CGRect rect = [[invisibleCellFrameArray objectAtIndex:i] CGRectValue];
            if (CGRectContainsPoint(rect, relativePoint)) {
                position = INVISIBLE_CELL_TAGOFFSET + i;
                break;
            }
        }
    } else if (point.y > [self heightForInvisibleCellArea] &&
               point.y <= [self heightOfView]) {
        CGPoint relativePoint = [scrollView convertPoint:point toView:visibleView];
        for (int i = 0; i < [visibleCellFrameArray count]; i++) {
            CGRect rect = [[visibleCellFrameArray objectAtIndex:i] CGRectValue];
            if (CGRectContainsPoint(rect, relativePoint)) {
                position = VISIBLE_CELL_TAGOFFSET + i;
                break;
            }
        }
    }
    return position;
}

//获取点击的cell
- (SubscribeChannelGridViewCell*)tapCellAtPositon:(int)position
{
    SubscribeChannelGridViewCell *view = nil;
    
    if (position >= VISIBLE_CELL_TAGOFFSET) {
        view = (SubscribeChannelGridViewCell*)[visibleView viewWithTag:position];
        return view;
    }
    
    view = (SubscribeChannelGridViewCell*)[invisibleView viewWithTag:position];
    return view;
}

//获取要移动的cell
- (SubscribeChannelGridViewCell*)cellAtPositon:(int)position
{
    SubscribeChannelGridViewCell *view = nil;
    
    if (position >= VISIBLE_CELL_TAGOFFSET) {
        int cellPosition = position - VISIBLE_CELL_TAGOFFSET;
        view = (SubscribeChannelGridViewCell*)[visibleView viewWithTag:position];
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
    
    int cellPosition = position - INVISIBLE_CELL_TAGOFFSET;
    view = (SubscribeChannelGridViewCell*)[invisibleView viewWithTag:position];
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
    if (point.y <= invisibleViewheight) {
        return INVISIBLE_AREA;
    } else if (point.y > invisibleViewheight &&
               point.y <= [self heightOfView]) {
        return VISIBLE_AREA;
    }
    return INVALID_AREA;
}

//单击操作
- (void)singleTapGesture:(UIGestureRecognizer*)recognizer
{
    switch (recognizer.state) {
            
        case UIGestureRecognizerStatePossible:
            break;
            
        case UIGestureRecognizerStateBegan:
            break;
            
        case UIGestureRecognizerStateChanged:
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            CGPoint point = [recognizer locationInView:scrollView];
            if (point.y >= self.heightOfView + 5.0f) {  //点击空白区域
                [self.delegate saveSubscribe];
                break;
            }
            
            break;
        }
            
        case UIGestureRecognizerStateCancelled:
            break;
            
        case UIGestureRecognizerStateFailed:
            break;
    }
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
                CGPoint point = [recognizer locationInView:scrollView];
                int position = [self cellPositionFromPoint:point];        //设置排列触摸点为开始触摸点
                previousArea = [self pointInArea:point];
                beginArea = previousArea;
                
                if (position == INVALID_POSITION) {
                    break;
                }

                SubscribeChannelGridViewCell *cell = [self cellAtPositon:position];
                movingCell = cell;
                movingCell.tag = 0;
                
                CGRect frameInSuperView;
                if (previousArea == INVISIBLE_AREA) {
                     frameInSuperView= [invisibleView convertRect:movingCell.frame toView:self.superview];
                } else if (previousArea == VISIBLE_AREA) {
                    frameInSuperView = [visibleView convertRect:movingCell.frame toView:self.superview];
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
            
            changed = YES;
            //拖到左侧的时候失败
            CGPoint centerPonitInSuperView = [recognizer locationInView:self.superview];
            CGPoint ponitInSuperView = CGPointMake(centerPonitInSuperView.x - movingCell.frame.size.width / 2,
                                                   centerPonitInSuperView.y - movingCell.frame.size.height / 2);
            if(![self.superview pointInside:ponitInSuperView withEvent:nil]){
                break;
            }
            
            movingCell.center = [recognizer locationInView:self.superview];
            CGPoint point = [recognizer locationInView:scrollView];
            NSInteger currentArea = [self pointInArea:point];
            
            //----------------------------移动到外区-----------------------------
            if (currentArea == INVALID_AREA) {
                if (previousArea == INVALID_AREA) {
                } else if (previousArea == INVISIBLE_AREA) {
                    [self reloadInvisibleViewFrame];
                    [self setVisibleViewFrame];
                } else if (previousArea == VISIBLE_AREA) {
                    [self reloadVisibleViewFrame];
                    [self selfViewHeight];
                }
                previousArea = currentArea;
            }
            
            //---------------------------移动到不可见区---------------------------
            if (currentArea == INVISIBLE_AREA) {
                [scrollView setContentOffset:CGPointZero animated:NO];
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
                    [self setInvisibleViewFrame];
                    [self setVisibleViewFrame];
                    [self selfViewHeight];
                }
                previousArea = currentArea;
            }
            
            //----------------------------移动到可见区----------------------------
            if (currentArea == VISIBLE_AREA) {
                if (previousArea == INVALID_AREA) {//是从外区过来的
                } else if (previousArea == INVISIBLE_AREA) {
//                    [scrollView setContentOffset:CGPointMake(0.0f, scrollView.contentSize.height - visibleViewHeight) animated:NO];
                    [self reloadInvisibleViewFrame];
                    [self setVisibleViewFrame];
                    [self selfViewHeight];
                } else if (previousArea == VISIBLE_AREA) {
                    if ([self heightForInvisibleCellArea] < point.y &&
                        point.y <= [self heightForInvisibleCellArea] + 55.0f) {  //可见区的头部
                        [self reloadVisibleViewFrame];
                        [self selfViewHeight];
                    }
                    NSInteger changePosition = [self positionOfCellSpace:point invisible:NO];
                    sortPosition = changePosition;
                    if (changePosition == INVALID_POSITION) {
                        break;
                    } else {
                        [self reloadViewFromPosition:changePosition invisible:NO];
                    }
                    [self setVisibleViewFrame];
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
            
            CGPoint point = [recognizer locationInView:scrollView];
            NSInteger currentArea = [self pointInArea:point];
                
            if (currentArea == INVALID_AREA) {
                if (beginArea == INVISIBLE_AREA) {
                    [self relayoutMovingItems:movingCell position:[self.invisibleChannelArray count] invisible:YES withAnimationFinished:^(BOOL finished) {
                        if (finished) {
                            [self.invisibleChannelArray addObject:movingSubsChannel];
                            [self afterMovingEnd];
                            changed = NO;
                        }
                    }];
                } else if (beginArea == VISIBLE_AREA) {
                    [self relayoutMovingItems:movingCell position:[self.visibleChannelArray count] invisible:NO withAnimationFinished:^(BOOL finished) {
                        if (finished) {
                            [self.visibleChannelArray addObject:movingSubsChannel];
                            [self afterMovingEnd];
                            changed = NO;
                        }
                    }];
                }
            } else if (currentArea == INVISIBLE_AREA) {
                if ([self.invisibleChannelArray count] == 0 || sortPosition == INVALID_POSITION) {
                    [self relayoutMovingItems:movingCell position:[self.invisibleChannelArray count] invisible:YES withAnimationFinished:^(BOOL finished) {
                        if (finished) {
                            [self.invisibleChannelArray addObject:movingSubsChannel];
                            [self afterMovingEnd];
                            if (!changed) {
                                [self deleteInvisibleChannel:point position:0];
                            }
                            changed = NO;
                        }
                    }];
                } else {
                    [self relayoutMovingItems:movingCell position:sortPosition invisible:YES withAnimationFinished:^(BOOL finished) {
                        if (finished) {
                            [self.invisibleChannelArray insertObject:movingSubsChannel atIndex:sortPosition];
                            [self afterMovingEnd];
                            if (!changed) {
                                [self deleteInvisibleChannel:point position:sortPosition];
                            }
                            changed = NO;
                        }
                    }];
                }
            } else if (currentArea == VISIBLE_AREA) {
                if ([self.visibleChannelArray count] == 7) {  //常用订阅最多显示7个
                    [SurfNotification surfNotification:@"您最多可在侧边栏放置7个栏目"];
                    if (beginArea == INVISIBLE_AREA) {
                        [self relayoutMovingItems:movingCell position:[self.invisibleChannelArray count] invisible:YES withAnimationFinished:^(BOOL finished) {
                            if (finished) {
                                [self.invisibleChannelArray addObject:movingSubsChannel];
                                [self afterMovingEnd];
                                changed = NO;
                            }
                        }];
                    }
                } else if ([self.visibleChannelArray count] == 0 || sortPosition == INVALID_POSITION) {
                    [self relayoutMovingItems:movingCell position:[self.visibleChannelArray count] invisible:NO withAnimationFinished:^(BOOL finished) {
                        if (finished) {
                            [self.visibleChannelArray addObject:movingSubsChannel];
                            [self afterMovingEnd];
                            if (!changed) {
                                [self deleteVisibleChannel:point position:0];
                            }
                            changed = NO;
                        }
                    }];
                } else {
                    [self relayoutMovingItems:movingCell position:sortPosition invisible:NO withAnimationFinished:^(BOOL finished) {
                        if (finished) {
                            [self.visibleChannelArray insertObject:movingSubsChannel atIndex:sortPosition];
                            [self afterMovingEnd];
                            if (!changed) {
                                [self deleteVisibleChannel:point position:sortPosition];
                            }
                            changed = NO;
                        }
                    }];
                }
            }
        }
            break;
            
        case UIGestureRecognizerStateFailed:
        {
            if (beginArea == INVISIBLE_AREA) {
                [self.invisibleChannelArray addObject:movingSubsChannel];
            } else if (beginArea == VISIBLE_AREA) {
                [self.visibleChannelArray addObject:movingSubsChannel];
            }
            
            [self afterMovingEnd];
            changed = NO;
            
            break;
        }
            
        case UIGestureRecognizerStateCancelled:
        {
            if (beginArea == INVISIBLE_AREA) {
                [self.invisibleChannelArray addObject:movingSubsChannel];
            } else if (beginArea == VISIBLE_AREA) {
                [self.visibleChannelArray addObject:movingSubsChannel];
            }
            
            [self afterMovingEnd];
            changed = NO;
            
            break;
        }
            
        default:
            break;
    }
}

//重新计算cell的位置
- (void)reloadViewFromPosition:(NSInteger)position invisible:(BOOL)invisible
{
    int count;
    int section;
    float marginTop;
    
    NSMutableArray *cellFrameArray;
    if (invisible) {
        marginTop = 40.0f;
        section = 0;
        count = [self.invisibleChannelArray count];
        cellFrameArray = invisibleCellFrameArray;
    } else {
        marginTop = 55.0f;
        section = 1;
        count = [self.visibleChannelArray count];
        cellFrameArray = visibleCellFrameArray;
    }

    [cellFrameArray removeAllObjects];

    for (int i = 0; i < count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:section];
        SubscribeChannelGridViewCell *cell = [self.dataSource cellAtIndexPath:indexPath];
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
                                      forwardCellRect.origin.y + CELL_HEIGHT + cellVerticalSpacing,
                                      cell.frame.size.width,
                                      cell.frame.size.height);
                } else if (forwardCellRect.origin.x + forwardCellRect.size.width + cellHorizontalSpacing +
                           movingCell.frame.size.width > self.widthOfView - edgeInsets.left) {
                    rect = CGRectMake(edgeInsets.left + movingCell.frame.size.width + cellHorizontalSpacing,
                                      forwardCellRect.origin.y + CELL_HEIGHT + cellVerticalSpacing,
                                      cell.frame.size.width,
                                      cell.frame.size.height);
                } else {
                    if (forwardCellRect.origin.x + forwardCellRect.size.width + 2 * cellHorizontalSpacing +  movingCell.frame.size.width + cell.frame.size.width > self.widthOfView - edgeInsets.left) {
                        rect = CGRectMake(edgeInsets.left,
                                          forwardCellRect.origin.y + CELL_HEIGHT + cellVerticalSpacing,
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
                                      forwardCellRect.origin.y + CELL_HEIGHT + cellVerticalSpacing,
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
        invisibleView.frame = CGRectMake(0.0f, 0.0f, self.widthOfView, [self heightForInvisibleCellArea]);
        for (int i = 0; i < [cellFrameArray count]; i++) {
            SubscribeChannelGridViewCell *cell = (SubscribeChannelGridViewCell*)[self viewWithTag:INVISIBLE_CELL_TAGOFFSET + i];
            [self relayoutItems:cell frameOfIndex:i invisible:YES animated:YES];
        }
    } else {
        visibleView.frame = CGRectMake(0.0f, [self heightForInvisibleCellArea], self.widthOfView, [self heightForVisibleCellArea]);
        for (int i = 0; i < [cellFrameArray count]; i++) {
            SubscribeChannelGridViewCell *cell = (SubscribeChannelGridViewCell*)[self viewWithTag:VISIBLE_CELL_TAGOFFSET + i];
            [self relayoutItems:cell frameOfIndex:i invisible:NO animated:YES];
        }
    }
}

//cell的移动动画
- (void)relayoutItems:(SubscribeChannelGridViewCell*)view frameOfIndex:(int)index invisible:(BOOL)invisible animated:(BOOL)animated
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
        [UIView animateWithDuration:0.2f
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
- (void)relayoutMovingItems:(SubscribeChannelGridViewCell*)view
                   position:(int)position
                  invisible:(BOOL)invisible
      withAnimationFinished:(void(^)(BOOL))handler
{
    NSMutableArray *cellFrameArray;
    int count;
    if (invisible) {
        cellFrameArray = invisibleCellFrameArray;
        count = self.invisibleChannelArray.count;
    } else {
        cellFrameArray = visibleCellFrameArray;
        count = self.visibleChannelArray.count;
    }
    float marginTop = invisible ? 40.0f : 55.0f;
    
    void (^layoutBlock)(void) = ^{
        CGRect frame = CGRectZero;
        if (position == 0) {
            frame = CGRectMake(edgeInsets.left, edgeInsets.top + marginTop, movingCell.frame.size.width, movingCell.frame.size.height);
        } else {
            CGRect forwardCellRect = [[cellFrameArray objectAtIndex:position - 1] CGRectValue];
            if (forwardCellRect.origin.x + forwardCellRect.size.width + cellHorizontalSpacing +
                movingCell.frame.size.width <= self.widthOfView - edgeInsets.left) {
                frame = CGRectMake(forwardCellRect.origin.x + forwardCellRect.size.width + cellHorizontalSpacing,
                                  forwardCellRect.origin.y,
                                  movingCell.frame.size.width,
                                  movingCell.frame.size.height);
            } else {
                frame = CGRectMake(edgeInsets.left,
                                  forwardCellRect.origin.y + CELL_HEIGHT + cellVerticalSpacing,
                                  movingCell.frame.size.width,
                                  movingCell.frame.size.height);
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
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint touchPoint = [touch locationInView:scrollView];
    
    if (CGRectContainsPoint(CGRectMake(765.0f, 10.0f, 80.0f, 25.0f), touchPoint)) { 
        [self.delegate saveSubscribe]; //完成Button
        return NO;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

//移动结束后操作
- (void)afterMovingEnd
{
    [movingCell removeFromSuperview];
    movingCell = nil;
    [self reloadView];
}

//删除不可见区的订阅
- (void)deleteInvisibleChannel:(CGPoint)point position:(NSInteger)position
{
    SubscribeChannelGridViewCell *cell = [self tapCellAtPositon:position + INVISIBLE_CELL_TAGOFFSET];
    CGPoint relativePoint = [scrollView convertPoint:point toView:cell];
    if ([cell pointInDeleteButton:relativePoint]) {
        deleteSubsChannel = [self.invisibleChannelArray objectAtIndex:sortPosition];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"是否确认退订\"%@\"",deleteSubsChannel.name]
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定", nil];
        alertView.tag = 10000;
        [alertView show];
    }
}

//删除可见区的订阅
- (void)deleteVisibleChannel:(CGPoint)point position:(NSInteger)position
{
    SubscribeChannelGridViewCell *cell = [self tapCellAtPositon:sortPosition + VISIBLE_CELL_TAGOFFSET];
    CGPoint relativePoint = [scrollView convertPoint:point toView:cell];
    if ([cell pointInDeleteButton:relativePoint]) {
        deleteSubsChannel = [self.visibleChannelArray objectAtIndex:sortPosition];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"是否确认退订\"%@\"",deleteSubsChannel.name]
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定", nil];
        alertView.tag = 20000;
        [alertView show];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    SubsChannelsManager *manager = [SubsChannelsManager sharedInstance];
    if (alertView.tag == 10000) {
        if (buttonIndex == 1) {
            [manager removeSubscription:deleteSubsChannel];
            [manager commitChangesWithHandler:^(BOOL succeeded) {
                if (succeeded) {
                    [self reloadInvisibleViewFrame];
                    [self setVisibleViewFrame];
                    [self selfViewHeight];
                    [self reloadView];
                }
             }];
        }
    } else if (alertView.tag == 20000) {
        if (buttonIndex == 1) {
            [manager removeSubscription:deleteSubsChannel];
            [manager commitChangesWithHandler:^(BOOL succeeded) {
                if (succeeded) {
                    [self reloadVisibleViewFrame];
                    [self selfViewHeight];
                    [self reloadView];
                }
            }];
        }
    }
    
}

@end
