//
//  ImageViewController.h
//  LLSimpleCameraExample
//
//  Created by Ömer Faruk Gül on 15/11/14.
//  Copyright (c) 2014 Ömer Faruk Gül. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImageViewControllerDelegate <NSObject>

- (void)clickChoseBt:(UIImage *)image;

@end

@interface ImageViewController : UIViewController
- (instancetype)initWithImage:(UIImage *)image;

@property (nonatomic, assign)id<ImageViewControllerDelegate>delegate;
@property (nonatomic, strong)UIButton *closeButton;


@end
