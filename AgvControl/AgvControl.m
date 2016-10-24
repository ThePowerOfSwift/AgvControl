//
//  AgvControl.m
//  AgvControl
//
//  Created by 郭龙 on 16/9/26.
//  Copyright © 2016年 690193240@qq.com. All rights reserved.
//

#import "AgvControl.h"

@implementation AgvControl

@synthesize server;

static AgvControl * _instance = nil;

+ (instancetype) sharedControl
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init] ;
    }) ;
    
    return _instance ;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        server = [UdpServerSocket sharedSocket];
    }
    return self;
}

- (void)startListen {
    NSInteger agvPort = UDPBIND_PORT;
    NSInteger staPort = UDPSTA_PORT;
    [server bindToPort:agvPort];
    [server bindToPort:staPort];
}

- (void)stopAll {
    [self stopListen];
}

- (void)stopListen {
    [server stopListen];
}

- (void)sheduelAgv:(int) agvNum toSta:(int)station  {
    
    NSString *hexAgvNum = [CommonsFunc stringToHexString:agvNum];
    NSString *tmp = [NSString stringWithFormat:@"1101012312%@",hexAgvNum];
    NSLog(@"shedule CMD: %@", tmp);
    
    
}

+ (NSInteger)decimalWithHexString:(NSString *)hexString{
    return  strtoul([hexString UTF8String], 0, 16);
}

/*
NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
 
ios中将NSstring字符串转换成char类型

NSString *string = [NSString stringWithFormat:@"5D"];

const char *result = [string UTF8String];


char字符转成NSstring

char a[10] = "3Er4";

NSString *string = [NSString stringWithUTF8String:a];
*/

@end
