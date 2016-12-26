//
//  PopDialog.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-1-25.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopDialog : UIView{
    
    NSString *msg;
    UIFont *msgFont;
}



+ (PopDialog *)sharedInstance;

- (void)show:(NSString *)message fontSize:(CGFloat)fsize drawPoint:(CGPoint)p;


@end
