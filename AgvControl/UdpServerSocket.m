//
//  UdpServer.m
//  AgvControl
//
//  Created by 郭龙 on 16/7/5.
//  Copyright © 2016年 690193240@qq.com. All rights reserved.
//

#import "UdpServerSocket.h"

#define TIMEOUT 3

static UdpServerSocket *instance;

@interface UdpServerSocket(){
    BOOL isRunning;
}
@end

@implementation UdpServerSocket

#pragma mark - Lifecycle
+ (instancetype) sharedSocket
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance ;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.udpSocket = [[AsyncUdpSocket alloc] init];
        self.udpSokcetsArr = [NSMutableArray new];
        isRunning = NO;
    }
    return self;
}

#pragma mark - actions

- (BOOL)bindToPort: (UInt16) port
{
    NSError *error = NULL;
    BOOL bind = [self.udpSocket bindToPort:port error:&error];
    if (!bind) {
        NSLog(@"cannot bind to port %d: ,err: %@", port, error);
    }else
        NSLog(@"bind success!");
    return bind;
}

- (BOOL)sendDate:(NSString *)string ToIp:(NSString *)ip port:(UInt16) port {
    BOOL send = [self.udpSocket sendData:[UdpServerSocket stringToData:string] toHost:ip port:port withTimeout:TIMEOUT tag:0];
    return send;
}

- (void)startListen
{
    if (!isRunning)
    {
        NSInteger port = UDPBIND_PORT;
        [self bindToPort:port];
        isRunning = YES;
    }
}

- (void)stopListen
{
    NSLog(@"stop listen");
    
    if (isRunning)
    {
        [self.udpSocket close];
        isRunning = NO;
    }
}

- (void)sendMessage:(NSString *)string debugstring:(NSString *)debugs{
    NSLog(@"send message:%@, debus:%@", string, debugs);
    
}

#pragma mark - delegate
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
    NSString *msg= [UdpServerSocket dataToString:data];
    NSLog(@"receive :%@", msg);
    
    [self.udpSokcetsArr addObject:host];
    
    [[self mutableArrayValueForKey:@"messagesArray"] addObject:msg];
    BOOL isShow = [self dealWithReceivedMessage:msg socket:sock];
    if (isShow) {
        if ([msg isEqualToString:@"o"]) {
            msg = @"完成";
        }
        AppDelegate *dele = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        if ([dele.main isKindOfClass:[MainViewController class]]) {
            MainViewController *tmpMain = (MainViewController *)dele.main;
            [tmpMain setDebugLabelText:msg mode:MESSAGEMODE_RECV];
        }
    }
    msg = nil;
    
    return YES;
}

#pragma mark - helpers
/**
 *  处理接收到的数据
 *  @param msg  待处理数据
 *  @param sock 对应的socket
 *  @return 是否需要显示在debugLabel上
 */
- (BOOL)dealWithReceivedMessage :(NSString *) msg socket:(AsyncUdpSocket *)sock{
    BOOL willShowOnLabel = YES;
    
    /*
    if ([msg isEqualToString:@"RED"] || [msg isEqualToString:@"BLUE"] || [msg isEqualToString:@"GOLD"]) {
        NSString *tmp ;//= [@"ROBOTNAME_" stringByAppendingString:msg];//每次新添加机器人就只需要在AppMacro.h中添加一个ROBOTNAME_开头的就行了。
        if ([msg isEqualToString:@"RED"]) {
            tmp = ROBOTNAME_RED;
        }else if([msg isEqualToString:@"BLUE"])
            tmp = ROBOTNAME_BLUE;
        else if ([msg isEqualToString:@"GOLD"])
            tmp = ROBOTNAME_GOLD;
        [[NSUserDefaults standardUserDefaults] setObject:tmp forKey:sock.connectedHost];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_CHANGEROBOTNAME object:nil userInfo:@{@"ipAddr":sock.connectedHost}];
        willShowOnLabel = NO;
        
    }else if ([msg hasPrefix:@"v"] && [msg hasSuffix:@"e"]) {
        NSString *power = [msg substringWithRange:NSMakeRange(1, msg.length-2)];
        if (power.length > 5) {
            return NO;
        }
        NSString *roboName = [ServerSocket getRobotName:sock];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_POWERNOTIFICATION object:nil userInfo:@{@"power":power, @"roboName":roboName}];
        willShowOnLabel = NO;
        
    }else if ([msg hasPrefix:@"CARD"] || [msg hasPrefix:@"AT"] || [msg isEqualToString:@"A"] || [msg isEqualToString:@"v"]){//返回的card就不补充了。
        willShowOnLabel = NO;
        
    }else if ([msg hasPrefix:@"o"]&&[msg hasSuffix:@"e"]){
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_CONFIG_MODE_SPEEDN object:nil userInfo:@{@"ipAddr":sock.connectedHost, @"message":msg}];
        
    }else if ([msg hasPrefix:@"~"] && [msg hasSuffix:@"`"]) {
        self.starGazerAckString = msg;
        
    }else{
        //用来检测信息是否发送过去了，即检测发送的信号是否是msg == o;
        receiveMessage = msg;
        tmpSocket = sock;
    }
    */
    return willShowOnLabel;
}


+ (NSString *)dataToString:(NSData *)data
{
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (NSData *)stringToData:(NSString *)string
{
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

@end
