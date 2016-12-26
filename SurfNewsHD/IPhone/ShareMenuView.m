//
//  ShareMenuView.m
//  SurfNewsHD
//
//  Created by SYZ on 13-10-16.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "ShareMenuView.h"

#define IconWidth            45
#define IconHeight           45
#define ItemWidth            47
#define ItemHeight           65
#define ItemVerticalSpace    5      //垂直间距
#define ItemHorizontalSpace  20     //水平间距
#define ItemCountPerRow      4      //每行的个数

@implementation ShareMenuItem

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        iconView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - IconWidth) / 2, 0.0f, IconWidth, IconHeight)];
        [self addSubview:iconView];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, IconHeight, self.frame.size.width, 20.0f)];
        [nameLabel setTextAlignment:NSTextAlignmentCenter];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = [UIFont systemFontOfSize:10.0f];
        nameLabel.textColor = [UIColor colorWithHexValue:0xFF999292];
        nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self addSubview:nameLabel];
    }
    return self;
}

- (void)setImage:(UIImage *)image text:(NSString *)name
{
    [iconView setImage:image];
    [nameLabel setText:name];
}

- (void)sendActionsForControlEvents:(UIControlEvents)controlEvents
{
    if (controlEvents == UIControlEventTouchDown) {
        iconView.alpha = 0.8f;
    } else {
        iconView.alpha = 1.0f;
    }
}

#pragma mark Touch
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if ([touch view] == self && [[event allTouches] count] == 1) {
        CGPoint tp =  [touch locationInView:self];
        CGRect rect = [self bounds];
        if (CGRectContainsPoint(rect, tp)) {
            [self sendActionsForControlEvents:UIControlEventTouchDown];
        }
    }
    return YES;

}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self sendActionsForControlEvents:0];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    [self sendActionsForControlEvents:0];
}

@end

@implementation ShareMenuView

- (id)initWithFrame:(CGRect)frame
{
    //根据count计算self的大小
    CGPoint framePoint = CGPointMake(CGRectGetMinX(frame), CGRectGetMinY(frame));
    CGSize frameSize = [self viewSizeOfSelf];
    CGRect frameRect = {framePoint, frameSize};
    
    self = [super initWithFrame:frameRect];
    if (self) {
        
        for (int i = 0; i < ShareMenuCount; i ++) {
            float x = (ItemWidth + ItemHorizontalSpace) * (i % ItemCountPerRow);
            float y = (ItemHeight + ItemVerticalSpace) * (i / ItemCountPerRow);
            
            ShareMenuItem *item = [[ShareMenuItem alloc] initWithFrame:CGRectMake(x, y, ItemWidth, ItemHeight)];
            item.tag = 1000 + i;
            [item addTarget:self action:@selector(itemSelected:) forControlEvents:UIControlEventTouchDown];
            [self setImageForItem:item];
            [self addSubview:item];
        }
    }
    return self;
}

//计算size
- (CGSize)viewSizeOfSelf
{
    if (ShareMenuCount == 0) {
        return CGSizeZero;
    }
    
    //每行正好都有ItemCountPerRow个
    if (ShareMenuCount % ItemCountPerRow == 0) {
        int row = ShareMenuCount / ItemCountPerRow;
        return CGSizeMake(ItemWidth * ItemCountPerRow + ItemHorizontalSpace * (ItemCountPerRow - 1),
                          ItemHeight * row + ItemVerticalSpace * (row - 1));
    }
    
    //最后一行没有ItemCountPerRow个
    int row = ShareMenuCount / ItemCountPerRow + 1;
    return CGSizeMake(ItemWidth * ItemCountPerRow + ItemHorizontalSpace * (ItemCountPerRow - 1),
                      ItemHeight * row + ItemVerticalSpace * (row - 1));
}

//给button设置背景图片
- (void)setImageForItem:(ShareMenuItem*)item
{
    switch (item.tag) {
        case ItemWeixin:
            [item setImage:[UIImage imageNamed:@"weixin"] text:@"微信"];
            break;
            
        case ItemWeiXinFriendZone:
            [item setImage:[UIImage imageNamed:@"weixin_friendzone"] text:@"朋友圈"];
            break;
            
        case ItemSinaWeibo:
            [item setImage:[UIImage imageNamed:@"sina"] text:@"新浪微博"];
            break;
            
        case ItemSMS:
            [item setImage:[UIImage imageNamed:@"SMS"] text:@"短信"];
            break;
            
        default:
            break;
    }
}

//item的点击事件
- (void)itemSelected:(ShareMenuItem*)sender
{
    if ([_delegate respondsToSelector:@selector(menuSelected:)]) {
        [_delegate menuSelected:sender.tag];
    }
}

@end
