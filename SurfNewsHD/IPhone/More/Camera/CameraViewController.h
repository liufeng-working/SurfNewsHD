//
//  HomeViewController.h
//  LLSimpleCameraExample
//
//  Created by Ömer Faruk Gül on 29/10/14.
//  Copyright (c) 2014 Ömer Faruk Gül. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLSimpleCamera.h"
#import "ImageViewController.h"

@protocol CameraViewControllerDelegate <NSObject>

- (void)chooseImage:(UIImage *)chooseImage;

@end

@interface CameraViewController : UIViewController <LLSimpleCameraDelegate, ImageViewControllerDelegate>

@property (nonatomic, assign)id<CameraViewControllerDelegate>delegate;

@end

