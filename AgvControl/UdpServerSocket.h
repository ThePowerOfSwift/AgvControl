//
//  UdpServer.h
//  AgvControl
//
//  Created by 郭龙 on 16/7/5.
//  Copyright © 2016年 690193240@qq.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncUdpSocket.h"

@interface UdpServerSocket: NSObject

@property (nonatomic, strong) AsyncUdpSocket *udpSocket;
@property (nonatomic, strong) NSMutableArray *udpSokcetsArr;
@property (nonatomic, strong) NSMutableArray *messagesArray;

+ (instancetype) sharedSocket;

- (BOOL)bindToPort: (UInt16) port ;

- (BOOL)sendDate:(NSString *)string ToIp:(NSString *)ip port:(UInt16) port ;

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port ;

- (void)startListen ;

- (void)stopListen ;

- (void)sendMessage:(NSString *)string debugstring:(NSString *)debugs;
@end
