//
//  AgvControl.h
//  AgvControl
//
//  Created by 郭龙 on 16/9/26.
//  Copyright © 2016年 690193240@qq.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UdpServerSocket.h"

@interface AgvControl : NSObject


@property (nonatomic, strong) UdpServerSocket *server;

+ (instancetype) sharedControl;

- (void)startListen ;

- (void)stopAll ;

- (void)stopListen ;


@end
