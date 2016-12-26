//
//  PhoneWeiboPolicyController.h
//  SurfNewsHD
//
//  Created by jsg on 14-9-23.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhoneSurfController.h"

@interface PhoneWeiboPolicyController : PhoneSurfController{
    UIWebView *m_webview;
    NSString *m_url;
}
- (void)setURL:(NSString*)str;
@end
