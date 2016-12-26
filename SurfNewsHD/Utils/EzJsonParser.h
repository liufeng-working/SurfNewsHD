//
//  EzJsonParser.h
//  awsomelib
//
//  Created by Yu Halley on 12-12-30.
//  Copyright (c) 2012年 laoyur. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EzJsonParser : NSObject

/*
    obj should be NSObject-based

    example:
 
 @interface TestBase : NSObject
 @property int Int;          //支持c基本类型；c premitive type supported
 @property double Double;    //支持c基本类型；c premitive type supported
 @property float Float;      //支持c基本类型；c premitive type supported
 @property NSString* String; //支持常见的objc类型；obj-c type supported
 @end
 
 @implementation TestBase
 @end
 
 @interface Test : TestBase
 @property(setter = whatthefuck:,getter = hello) int Int2;  //支持自定义getter/setter；customized getter/setter supported
 @property NSArray* Array;  //支持数组类型，但必须在@synthesize中声明元素类型，请参考@implementation部分；array supported, however, you should defined ELEMENT type explicitly in @synthesize statement. see the @implementation part for detail.
 @end
 
 @implementation Test
 @synthesize Int2 = __KEY_NAME_id;  //声明‘id’作为json-key-name，由于id是objc关键字，因此不能直接将property名字设为id；define 'id' as json-key-name rather than the default property-name
 @synthesize Array = __ELE_TYPE_SubClass;   //声明数组的元素类型为‘SubClass’；define the element type in Array as 'SubClass',however it is only used for deserializing from json
 //or use the following format to avoid the same iVar name compilation error:
 //__ELE_TYPE_x_SubClass where 'x' == [0,9]
 
 //you can also mix the __KEY_NAME_ and __ELE_TYPE_ like this:
 //@synthesize Array = __ELE_TYPE_SubClass$__KEY_NAME_array2;
 //NOTE that you should use $ to connect the two parts.
 @end
 
 @interface SubClass : NSObject
 @property NSNumber* SS;
 @end
 
 @implementation SubClass
 @end
 
 目前@synthesize中支持的前缀：
 ·__KEY_NAME_：指定json-key-name，示例：__KEY_NAME_id
 ·__ELE_TYPE_：指定数组元素类型，示例：__ELE_TYPE_ThreadSummary
 ·__ELE_TYPE_x_：当json中存在多个同类型的数组时，使用此格式来避免编译错误。'x' == [0,9]
                    示例：__ELE_TYPE_0_ThreadSummary
 ·__DO_NOT_SERIALIZE_：不需要被序列化，该property不会被序列化到最终json中
 混合各种前缀：
 __KEY_NAME_id$__ELE_TYPE_ThreadSummary$__DO_NOT_SERIALIZE_
 
 */
+(NSString*) serializeObjectWithUtf8Encoding:(NSObject*)obj;
+(id) deserializeFromJson:(NSString*)json AsType:(Class)type;

@end
