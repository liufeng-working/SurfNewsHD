//
//  LeftSubsChannelCell.m
//  SurfNewsHD
//
//  Created by apple on 13-2-28.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "LeftSubsChannelCell.h"
#import "SubsChannelsListResponse.h"
#import "SubsChannelsManager.h"
@implementation LeftSubsChannelCell
@synthesize logoImage;
@synthesize desLabel;
@synthesize deleteBtn;
@synthesize channel;
@synthesize observer;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        desLabel.frame = CGRectMake(CGRectGetMaxX(logoImage.frame)+7.0f,
                                    CGRectGetMinY(logoImage.frame)+3.0f,
                                    125.0f,
                                    CGRectGetHeight(logoImage.frame));
        deleteBtn.frame = CGRectMake(CGRectGetMaxX(desLabel.frame),
                                     3.5f,
                                     20.0f, 43.0f);
        
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = self.bounds;
        button.autoresizingMask = UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleHeight;
        [button addTarget:self action:@selector(toucheBg) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:[UIImage imageNamed:@"subsSeletBg"] forState:UIControlStateHighlighted];
        [self.contentView addSubview:button];

        
        [self.contentView addSubview:logoImage];
        [self.contentView addSubview:bgImage];
        [self.contentView addSubview:desLabel];

        [self.contentView addSubview:deleteBtn ];
    }
    return self;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code

        
        logoImage = [[UIImageView alloc] initWithFrame:CGRectMake(9.0f, 3.5, 36.0f, 36.0f)];
        logoImage.image = [UIImage imageNamed:@"loadingSubs"];
        [self.contentView addSubview:logoImage];
        
        
        
        desLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(logoImage.frame)+7.0f,
                                                             CGRectGetMinY(logoImage.frame)+3.0f,
                                                             95.0f,
                                                             CGRectGetHeight(logoImage.frame))];
        desLabel.backgroundColor = [UIColor clearColor];
        desLabel.textColor = [UIColor colorWithHexString:@"9d9696"];
        desLabel.font = [UIFont systemFontOfSize:16.0f];
        [self.contentView addSubview:desLabel];
        
        bgImage = [[UIImageView alloc] initWithFrame:CGRectMake(4.0f, 2.0f, 46.0f, 46.0f)];
        bgImage.image = [UIImage imageNamed:@"sub_NoSelected.png"];
        [self.contentView addSubview:bgImage];
        
        self.bgImageHidden = NO;
        
        
        deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteBtn setBackgroundImage:[UIImage imageNamed:@"subsDelete"] forState:UIControlStateNormal];
        deleteBtn.frame = CGRectMake(CGRectGetMaxX(desLabel.frame),
                                     3.5f,
                                     20.0f, 43.0f);
        [deleteBtn addTarget:self action:@selector(deleteChannel:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:deleteBtn];
        
        
        selectBg = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0f, 178.0f, 50.0f)];
        selectBg.image = [UIImage imageNamed:@"subs_Selected_Bg"];
        selectBg.alpha = 0.8f;
        selectBg.hidden = YES;
        [self addSubview:selectBg];
    }
    return self;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!bgImage.hidden) {
        selectBg.hidden = NO;
    }

    [super touchesBegan:touches withEvent:event];
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!bgImage.hidden) {
        selectBg.hidden = YES;
    }

    [super touchesCancelled:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!bgImage.hidden) {
        selectBg.hidden = YES;
    }

    [super touchesEnded:touches withEvent:event];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)isCurrent:(BOOL)_isCurrent
{
    bgImage.hidden = self.bgImageHidden;
    if ([desLabel.text isEqualToString:@"查看全部"])
    {
        logoImage.frame = CGRectMake(7.0f, 10.0f, 40.0f, 30.0f);
    }
    else
    {
        logoImage.frame = CGRectMake(9.0f, 7.0f, 36.0f, 36.0f);
    }
    if (!_isCurrent) {
        bgImage.image = [UIImage imageNamed:@"sub_NoSelected"];
        desLabel.textColor = [UIColor colorWithHexString:@"9d9696"];
    }
    else
    {
        bgImage.image = [UIImage imageNamed:@"sub_Selected"];
        desLabel.textColor = [UIColor blackColor];
    }
}
-(void)deleteChannel:(id)sender
{
   
    if (self.channel) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"是否确认退订\"%@\"",self.channel.name]
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定",nil];
        [alertView show];  
    }
}
-(void)toucheBg
{
    if (self.channel && self.observer) {
        [self.observer singleTapDetected:self.channel];        
    }

}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        SubsChannelsManager *manager = [SubsChannelsManager sharedInstance];
        [manager removeSubscription:self.channel];
        [manager commitChangesWithHandler:^(BOOL succeeded)
        {
            
        }];
    }
}
@end
