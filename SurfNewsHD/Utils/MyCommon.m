//
//  MyCommon.m
//  SurfNews
//
//  Created by apple on 12-11-1.
//
//

#import "MyCommon.h"

static NSString* DOCPATH = nil;

@implementation MyCommon

+ (void)ensureLocalDirsPresent
{
    NSFileManager* fm = [NSFileManager defaultManager];
    
    NSString* dir0 = [self threadsImageDir];
    NSString* dir1 = [self threadsRscDir];
    NSString* dir2 = [self catesRscDir];
    NSString* dir3 = [self subsChannelsRscDir];
    
    [fm createDirectoryAtPath:dir0 withIntermediateDirectories:FALSE attributes:nil error:nil];
    [fm createDirectoryAtPath:dir1 withIntermediateDirectories:FALSE attributes:nil error:nil];
    [fm createDirectoryAtPath:dir2 withIntermediateDirectories:FALSE attributes:nil error:nil];
    [fm createDirectoryAtPath:dir3 withIntermediateDirectories:FALSE attributes:nil error:nil];
}

+ (NSString *)surfDbFilePath
{
    return [[self documentsPath] stringByAppendingPathComponent:@"SurfNewsDb.db"];
}

+ (NSString *)documentsPath
{
    if(!DOCPATH)
    {
        DOCPATH = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    }
    return DOCPATH;
}

+ (NSString *)threadsImageDir
{
    return [[self documentsPath] stringByAppendingPathComponent:@"Images/"];
}

+ (NSString *)threadsRscDir
{
    return [[self documentsPath] stringByAppendingPathComponent:@"Threads/"];
}

+ (NSString *)catesRscDir
{
    return [[self documentsPath] stringByAppendingPathComponent:@"Cates/"];
}

+ (NSString *)subsChannelsRscDir
{
    return [[self documentsPath] stringByAppendingPathComponent:@"SubsChannels/"];
}
@end
