//
//  DownLoadLabel.h
//  SurfNewsHD
//
//  Created by yujiuyin on 13-8-26.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownLoadLabel : UILabel
{
    UIImageView *leftImageView;
    UIImageView *currentImageView;
    
    NSInteger len;
	NSString *text;
	
	NSInteger hight;
	NSInteger linenum;
	
	NSTimer *t;
}

@property (nonatomic, assign) float  widthLength;

-(void)settext:(NSString *)te;
- (void)setTextProgressColor:(float)width;
- (void)getWhiteViewFromWidth:(float)width;
- (void)removeCurrentView;

@end
