//
//  ImageViewController.m
//  LLSimpleCameraExample
//
//  Created by Ömer Faruk Gül on 15/11/14.
//  Copyright (c) 2014 Ömer Faruk Gül. All rights reserved.
//

#import "ImageViewController.h"
#import "ViewUtils.h"
#import "UIImage+Crop.h"

@interface ImageViewController ()
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *infoLabel;
@property (strong, nonatomic) UIButton *cancelButton;

@end

@implementation ImageViewController

- (instancetype)initWithImage:(UIImage *)image {
    self = [super initWithNibName:nil bundle:nil];
    if(self) {
        self.image = image;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageView.backgroundColor = [UIColor yellowColor];
    
    //self.image = [self.image crop:CGRectMake(0, 0, self.image.size.width, self.image.size.width)];
    
    self.imageView = [[UIImageView alloc] initWithImage:self.image];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.imageView];
    
//    NSString *info = [NSString stringWithFormat:@"Size: %@, orientation: %d", NSStringFromCGSize(self.image.size), self.image.imageOrientation];
    
//    self.infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
//    self.infoLabel.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
//    self.infoLabel.textColor = [UIColor whiteColor];
//    self.infoLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:13];
//    self.infoLabel.textAlignment = NSTextAlignmentCenter;
//    self.infoLabel.text = info;
//    [self.view addSubview:self.infoLabel];
    
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
//    [self.view addGestureRecognizer:tapGesture];
    
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeButton.frame = CGRectMake(10, 15, 30, 25);
    [self.closeButton setImage:[UIImage imageNamed:@"close_cha.png"] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(viewTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.closeButton];
    
    UIButton *choseBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [choseBt setFrame:CGRectMake(self.view.bounds.size.width - 50, 15, 30, 25)];
    
    [choseBt.titleLabel setFont:[UIFont systemFontOfSize:28]];
    [choseBt setTitleColor:[UIColor colorWithHexString:@"e3e2e2"] forState:UIControlStateNormal];
    [choseBt setTitle:@"\u2713  " forState:UIControlStateNormal];
    [choseBt addTarget:self action:@selector(didChoseBt) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:choseBt];
}

- (void)didChoseBt{
    [self dismissViewControllerAnimated:NO completion:^{
        if ([_delegate respondsToSelector:@selector(clickChoseBt:)]) {
            [_delegate clickChoseBt:[self rotateImage:self.image]];
        }
    }];

}

- (UIImage*)rotateImage:(UIImage *)image
{
    float kMaxResolution = 320;
    
    CGImageRef imgRef = image.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

- (void)viewTapped:(UIGestureRecognizer *)gesture {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.imageView.frame = self.view.contentBounds;
    
    [self.infoLabel sizeToFit];
    self.infoLabel.width = self.view.contentBounds.size.width;
    self.infoLabel.top = 0;
    self.infoLabel.left = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
