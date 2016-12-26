//
//  ShareView.m
//  SurfNewsHD
//
//  Created by SYZ on 13-1-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "ShareView.h"

@implementation ShareItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        itemView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 5.0f, 45.0f, 45.0f)];
        itemView.image = nil;
        [self addSubview:itemView];
        
        selectView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 50.0f, 50.0f)];
        selectView.image = [UIImage imageNamed:@"weibo_select"];
        selectView.hidden = YES;
        [self addSubview:selectView];
    }
    return self;
}

- (void)setItemViewImage:(UIImage *)image select:(BOOL)select
{
    itemView.image = image;
    selectView.hidden = !select;
}

@end

@implementation ShareView

@synthesize shareTextView;

- (id)initWithFrame:(CGRect)frame controller:(id)controller
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        backgroundView = [[PublicPopupView alloc] initWithFrame:self.bounds];
        backgroundView.title = @"分享";
        [self addSubview:backgroundView];
        
        shareBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(40.0f, 90.0f, 270.0f, 165.0f)];
        UIImage *image = [UIImage imageNamed:@"input_view"];
        [shareBackgroundView setImage:[image stretchableImageWithLeftCapWidth:0.0f topCapHeight:10.0f]];
        [self addSubview:shareBackgroundView];
        
        shareTextView = [[UITextView alloc] initWithFrame:CGRectMake(50.0f, 97.0f, 250.0f, 115.0f)];
        [shareTextView setDelegate:self];
        [shareTextView setTextColor:[UIColor colorWithHexString:@"8B8782"]];
        [shareTextView setBackgroundColor:[UIColor clearColor]];
        [shareTextView setFont:[UIFont systemFontOfSize:15.0f]];
        [shareTextView setReturnKeyType:UIReturnKeyDefault];
        [self addSubview:shareTextView];
        
        for (int i = 1; i <= 4; i++) {
            ShareItemView *itemView = [[ShareItemView alloc] initWithFrame:CGRectMake(60.0f * i + 3.0f, 267.0f, 50.0f, 50.0f)];
            itemView.tag = i;
            [self addSubview:itemView];
            
            SEL shareTapDetected = NSSelectorFromString(@"shareItemTapDetected:");
            UITapGestureRecognizer *tapGestureRecognizer =
            [[UITapGestureRecognizer alloc] initWithTarget:controller
                                                    action:shareTapDetected];
            tapGestureRecognizer.numberOfTapsRequired = 1;
            [itemView addGestureRecognizer:tapGestureRecognizer];
        }
        
        cleanButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cleanButton.frame = CGRectMake(255.0f, 233.0f, 45.0f, 12.0f);
        [cleanButton setBackgroundImage:[UIImage imageNamed:@"weibo_clean"]
                               forState:UIControlStateNormal];
        [cleanButton setTitleColor:[UIColor whiteColor]
                          forState:UIControlStateNormal];
        [cleanButton.titleLabel setFont:[UIFont boldSystemFontOfSize:9.0f]];
        [cleanButton addTarget:self action:@selector(cleanShareContent:) forControlEvents:UIControlEventTouchUpInside];
        [cleanButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 10.0f)];
        [self addSubview:cleanButton];
        
        UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        shareButton.frame = CGRectMake(117.5f, 327.0f, 125.0f, 43.0f);
        [shareButton setBackgroundImage:[UIImage imageNamed:@"public_popup_button"]
                               forState:UIControlStateNormal];
        [shareButton setTitle:@"分享" forState:UIControlStateNormal];
        [shareButton setTitleColor:[UIColor colorWithHexString:@"6f5639"]
                          forState:UIControlStateNormal];
        [shareButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
        [shareButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [shareButton.titleLabel setShadowOffset:CGSizeMake(0.0f, -1.0f)];
        SEL didShare = NSSelectorFromString(@"didShare:");
        [shareButton addTarget:controller action:didShare
              forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:shareButton];
    }
    return self;
}

- (void)setItemViewImageWithTag:(int)tag bind:(BOOL)bind share:(BOOL)share
{
    ShareItemView *itemView = (ShareItemView*)[self viewWithTag:tag];
    switch (tag) {
        case 1:
            if (bind) {
                [itemView setItemViewImage:[UIImage imageNamed:@"bind_sina_logo"] select:share];
            } else {
                [itemView setItemViewImage:[UIImage imageNamed:@"unbind_sina_logo"] select:share];
            }
            break;
            
//        case 2:
//            if (bind) {
//                [itemView setItemViewImage:[UIImage imageNamed:@"bind_tencent_logo"] select:share];
//            } else {
//                [itemView setItemViewImage:[UIImage imageNamed:@"unbind_tencent_logo"] select:share];
//            }
//            break;
//            
//        case 3:
//            if (bind) {
//                [itemView setItemViewImage:[UIImage imageNamed:@"bind_renren_logo"] select:share];
//            } else {
//                [itemView setItemViewImage:[UIImage imageNamed:@"unbind_renren_logo"] select:share];
//            }
//            break;
//            
//        case 4:
//            if (bind) {
//                [itemView setItemViewImage:[UIImage imageNamed:@"bind_cm_logo"] select:share];
//            } else {
//                [itemView setItemViewImage:[UIImage imageNamed:@"unbind_cm_logo"] select:share];
//            }
//            break;
            
        default:
            break;
    }
}

- (void)cleanShareContent:(UIButton*)sender
{
    shareTextView.text = nil;
    [self calculateTextLength];
}

#pragma mark - UITextViewDelegate Methods
- (void)textViewDidChange:(UITextView *)textView
{
	[self calculateTextLength];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (void)calculateTextLength
{
	int wordcount = [self textLength:shareTextView.text];
	_leftWordCount  = 120 - wordcount;
	if (_leftWordCount < 0) {
		[cleanButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
	} else {
		[cleanButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	}
	
    [cleanButton setTitle:[NSString stringWithFormat:@"%@字", @(_leftWordCount)] forState:UIControlStateNormal];
}

- (int)textLength:(NSString *)text
{
    float number = 0.0;
    for (int index = 0; index < [text length]; index++) {
        NSString *character = [text substringWithRange:NSMakeRange(index, 1)];
        
        if ([character lengthOfBytesUsingEncoding:NSUTF8StringEncoding] == 3) {
            number++;
        } else {
            number = number + 0.5;
        }
    }
    return ceil(number);
}

@end
