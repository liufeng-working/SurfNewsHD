//
//  SurfNewsTests.m
//  SurfNewsTests
//
//  Created by xuxg on 14-9-18.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <XCTest/XCTest.h>

// 从Xcode5之后开发工程一般都带有单元测试工程（以工程名+Tests结尾）。
// 内容类都是继承自XCTestCase类，容包含set Up(设置)、tearDown（结束）和你所编写的testXXX方法。
// 单元往往测试用来测试接口问题。在单元测试类中初始化调用接口的类，然后调用请求接口，进而查看返回数据情况等。
// 如何看返回数据当然要看你的请求接口类的回调的实现。有了单元测试工具就不用频繁启动应用和手动交互调用接口了，
// 对于层级复杂的应用调试接口尤为方便。
@interface SurfNewsTests : XCTestCase

@end

@implementation SurfNewsTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testXuxg
{
//    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);

    XCTAssert(1, @"Can not be zero");
    
    
    



}




// 测试序列化频道信息
-(void)testHotchannl
{
//    NSString *fileContent = @"{\"id\":4061,\"index\":\"4061\",\"supportOfflineDownload\":false,\"isnew\":\"0\",\"isUnsubscribed\":false,\"time\":1436859847.838176,\"type\":\"0\",\"isBeauty\":false,\"rec\":[{\"recid\":59144109,\"recimg\":\"http://go.10086.cn/hotpic/201212/24/source5914410920121224162311.png\",\"recname\":\"佳人\"},{\"recid\":59148391,\"recimg\":\"http://go.10086.cn/hotpic/201301/09/source5914839120130109175041.png\",\"recname\":\"爱稀奇\"},{\"recid\":59155731,\"recimg\":\"http://go.10086.cn/hotpic/201212/25/source5915573120121225155620.png\",\"recname\":\"奇事奇物奇人\"},{\"recid\":59274631,\"recimg\":\"http://go.10086.cn/hotpic/201505/25/source5927463120150525180009.jpg\",\"recname\":\"第一财经\"},{\"recid\":59322632,\"recimg\":\"http://go.10086.cn/hotpic/201506/01/source59322632.jpg\",\"recname\":\"中新网\"}],\"name\":\"热推\",\"isWidget\":1}";
//    NSString *filePath = [[PathUtil rootPathOfHotChannels] stringByAppendingPathComponent:@"testfile.txt"];
//
//    
//    NSError *err;
//    [fileContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&err];


    
    // 读文件
    
//    NSString *readFile = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&err];
//    
//    
//    if (err) {
//        NSLog(@"error = %@", err);
//    }
//    else {
//        NSLog(@"file content = %@",readFile);
//    }
//    
}

@end
