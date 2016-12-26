//
//  PhoneWeixinController.h
//  SurfNewsHD
//
//  Created by XuXg on 15/1/9.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "PhoneSurfController.h"
#import "PhoneshareWeiboInfo.h"




// 做一个通用的微信分享功能
@interface PhoneWeiboController : PhoneSurfController


-(void)showShareView:(WeiboViewLayoutModel)type
           shareInfo:(PhoneshareWeiboInfo*)info;

//没有办法，微信和QQ的回调代理方法竟然坑爹的重名，没办法，只能把其中一个移到这个类来代理
+(void)handleOpenUrl:(NSURL *)url;
@end
