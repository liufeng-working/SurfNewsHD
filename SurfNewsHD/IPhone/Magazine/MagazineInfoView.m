//
//  MagazineInfoView.m
//  SurfNewsHD
//
//  Created by SYZ on 13-5-13.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "MagazineInfoView.h"

#define Magazine_Free    0

@implementation MagazineInfoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        logoBg = [[UIImageView alloc] initWithFrame:CGRectMake(20.0f, 20.0f, 40.0f, 40.0f)];
        [self addSubview:logoBg];
        
        logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(22.0f, 22.0f, 36.0f, 36.0f)];
        [self addSubview:logoImageView];
        
        starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(80.0f, 15.0f, 97.0f, 16.0f)];
        starImageView.image = [UIImage imageNamed:@"magazine_star"];
        [self addSubview:starImageView];
        
        orderNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(80.0f, 34.0f, 150.0f, 16.0f)];
        orderNumberLabel.font = [UIFont systemFontOfSize:12.0f];
        orderNumberLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:orderNumberLabel];
        
        orderPricesLabel = [[UILabel alloc] initWithFrame:CGRectMake(80.0f, 50.0f, 150.0f, 16.0f)];
        orderPricesLabel.font = [UIFont systemFontOfSize:12.0f];
        orderPricesLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:orderPricesLabel];
        
        orderButton = [UIButton buttonWithType:UIButtonTypeCustom];
        orderButton.layer.cornerRadius = 1.0f;
        orderButton.frame = CGRectMake(245.0f, 27.0f, 60.0f, 26.0f);
        [orderButton.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [orderButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self addSubview:orderButton];
    }
    return self;
}

//加载期刊信息
- (void)loadMagazineInfo:(MagazineInfo *)ma
{
    _magazine = ma;
    logoImageView.image = [UIImage imageNamed:@"default_loading_image.png"];
    
    orderNumberLabel.text = [NSString stringWithFormat:@"%@人订阅", @(_magazine.orderedCount)];
    if (_magazine.payType == Magazine_Free) {
        orderPricesLabel.text = @"免费";
    } else {
        orderPricesLabel.text = @"收费";
    }
    [self changeOrderButtonStatus];
    
    NSString *imgPath = [PathUtil pathOfMagazineLogoWithMagazineId:_magazine.magazineId];
    NSFileManager* fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:imgPath]) { // 图片文件不存在
        ImageDownloadingTask *task = [ImageDownloadingTask new];
        [task setImageUrl:_magazine.imageUrl];
        [task setUserData:_magazine];
        [task setTargetFilePath:imgPath];
        [task setCompletionHandler:^(BOOL succeeded, ImageDownloadingTask *idt) {
            if(succeeded && idt != nil && [idt.userData isEqual:_magazine]){
                UIImage *tempImg = [UIImage imageWithData:[idt resultImageData]];
                [logoImageView setImage:tempImg];
            }
        }];
        [[ImageDownloader sharedInstance] download:task];
    } else { //图片存在
        NSData *imgData = [NSData dataWithContentsOfFile:imgPath];
        [logoImageView setImage:[UIImage imageWithData:imgData]];
    }
}

//改变订阅按钮的状态
- (void)changeOrderButtonStatus
{
    if ([[SubsChannelsManager sharedInstance] magazineSubsStatus:_magazine.magazineId]) {
//        orderButton.backgroundColor = [UIColor colorWithHexString:@"999292"];//不需要背景色
        [orderButton setTitle:@"取消订阅" forState:UIControlStateNormal];
        [orderButton removeTarget:self action:@selector(addMagazineSubs:) forControlEvents:UIControlEventTouchUpInside];
        [orderButton addTarget:self action:@selector(removeMagazineSubs:) forControlEvents:UIControlEventTouchUpInside];
    } else {
//        orderButton.backgroundColor = [UIColor colorWithHexString:@"AD2F2F"];//不需要背景色
        [orderButton setTitle:@"添加订阅" forState:UIControlStateNormal];
        [orderButton removeTarget:self action:@selector(removeMagazineSubs:) forControlEvents:UIControlEventTouchUpInside];
        [orderButton addTarget:self action:@selector(addMagazineSubs:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)applyTheme:(BOOL)isNight
{
    if (isNight) {
        logoBg.image = [UIImage imageNamed:@"subs_channel_bg_night.png"];
        orderNumberLabel.textColor = [UIColor whiteColor];
        orderPricesLabel.textColor = [UIColor whiteColor];
    } else {
        logoBg.image = [UIImage imageNamed:@"subs_channel_bg.png"];
        orderNumberLabel.textColor = [UIColor colorWithHexString:@"34393D"];
        orderPricesLabel.textColor = [UIColor colorWithHexString:@"34393D"];
    }
}

/**
 SYZ -- 2014/08/11
 添加期刊订阅和取消期刊订阅
 Notice:这里要注意的是订阅的状态,有可能是“真”订阅或者“假”订阅
 具体的请参考使用到的每个方法的注释
 */
- (void)addMagazineSubs:(id)sender
{
    MagazineSubsInfo *magazine = [[MagazineSubsInfo alloc] initWithMagazineInfo:_magazine];
    SubsChannelsManager *sm = [SubsChannelsManager sharedInstance];
    if ([sm isMagazineReadyToUnsubscribed:_magazine.magazineId]) {
        [sm removeMagazineFromToMagazineUnsubs:magazine];
    } else if (![[MagazineManager sharedInstance] isMagazineSubscribed:_magazine.magazineId]){
        [sm addMagazinze:magazine];
    }
    [self changeOrderButtonStatus];
}

- (void)removeMagazineSubs:(id)sender
{
    MagazineSubsInfo *magazine = [[MagazineSubsInfo alloc] initWithMagazineInfo:_magazine];
    SubsChannelsManager *sm = [SubsChannelsManager sharedInstance];
    if ([sm isMagazineReadyToSubscribed:_magazine.magazineId]) {
        [sm removeMagazineFromToMagazineSubs:magazine];
    } else if ([[MagazineManager sharedInstance] isMagazineSubscribed:_magazine.magazineId]){
        [sm removeMagazine:magazine];
    }
    [self changeOrderButtonStatus];
}

@end
