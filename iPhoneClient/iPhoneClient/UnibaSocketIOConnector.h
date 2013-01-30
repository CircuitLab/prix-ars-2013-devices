//
//  UnibaDotComunicator.h
//  DotSwitchBaseApp
//
//  Created by mori koichiro on 12/01/17.
//  Copyright (c) 2012年 Uniba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NNSocketIO.h"

@interface UnibaSocketIOConnector : NSObject <NNSocketIOClient> {
    @public
    BOOL isConnectsocketIONodeServerUniast;
}

@property (retain) NNSocketIO * io;
@property (assign) __block id<NNSocketIOClient> socketIONodeServerUnicast;
@property (assign) BOOL isConnectsocketIONodeServerUnicast;
@property (strong) NSString  *nodeServerUnicastUrl;
@property (retain) NSDictionary *dataOfConnection;

- (id)      initWithUrl:(NSString*)url onPort:(NSString*)port onRoom:(NSString*)roomArg;
- (void)    setUrl:(NSString*)url onPort:(NSString*)port onRoom:(NSString*)roomArg;
- (void)    connectToUnicastServer;
- (void)    resetIsConnect;
- (BOOL)    sendEventToUnicastServer:(NSDictionary*)value forEvent:(NSString*)name;
- (void)    shutdwonUnicastServer;
- (void)    socketIODidConnect:(NSString *)socketName;

@end