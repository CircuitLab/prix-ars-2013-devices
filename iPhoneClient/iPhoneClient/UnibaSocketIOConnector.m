//
//  UnibaDotComunicator.m
//  DotSwitchBaseApp
//
//  Created by mori koichiro on 12/01/17.
//  Copyright (c) 2012年 Uniba Inc. All rights reserved.
//

#import "UnibaSocketIOConnector.h"

@implementation UnibaSocketIOConnector

@synthesize io;
@synthesize socketIONodeServerUnicast = _socketIONodeServerUnicast;

@synthesize isConnectsocketIONodeServerUnicast = _isConnectsocketIONodeServerUnicast;
@synthesize nodeServerUnicastUrl = _nodeServerUnicastUrl;
@synthesize dataOfConnection =_dataOfConnection;

-(BOOL)UnibaDotComunicatorNode{
    return YES;
    _nodeServerUnicastUrl = nil;
}

- (void)dealloc{
    [super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Init Method
-(id)initWithUrl:(NSString*)url onPort:(NSString*)port onRoom:(NSString*)roomArg{
    self.io = [NNSocketIO io];
    [self resetIsConnect];
    NSString * roomString = roomArg;
    
    if(url && port){
        if(nil != roomArg){
            _nodeServerUnicastUrl = [NSString stringWithFormat:@"%@:%@%@", url, port, roomString];
        }else{
            _nodeServerUnicastUrl = [NSString stringWithFormat:@"%@:%@", url, port];
        }
    }else{
        [NSException raise:@"Falal" format:@"url is not completed in communicator"];
        _nodeServerUnicastUrl = nil;
    }
    return self;
}

- (void) setUrl:(NSString*)url onPort:(NSString*)port onRoom:(NSString*)roomArg{
    NSString * roomString = roomArg;
    
    if(url && port){
        if(nil != roomArg){
            _nodeServerUnicastUrl = [NSString stringWithFormat:@"%@:%@%@", url, port, roomString];
        }else{
            _nodeServerUnicastUrl = [NSString stringWithFormat:@"%@:%@", url, port];
        }
    }else{
        [NSException raise:@"Falal" format:@"url is not completed in communicator"];
        _nodeServerUnicastUrl = nil;
    }
};


#pragma mark - Connection Method
-(void) resetIsConnect{
    [_dataOfConnection setValue:[NSNumber numberWithInt:0] forKey:@"connectioinUnicast"];
    _isConnectsocketIONodeServerUnicast = NO;
}

-(void)connectToUnicastServer{
    if(nil!=_nodeServerUnicastUrl){
        NSURL* url = [NSURL URLWithString:_nodeServerUnicastUrl];
        _socketIONodeServerUnicast =  [io connect:url];
        
        [_socketIONodeServerUnicast on:@"connect" listener:^(NNArgs* args) {
            dispatch_async( dispatch_get_main_queue(), ^{
                [self socketIODidConnect:@"UnibaSocketIOConnector"];
                _isConnectsocketIONodeServerUnicast = YES;
                NSLog(@"connection result ____");
            });
        }];
        
        [_socketIONodeServerUnicast on:@"get" listener:^(NNArgs* args) {
            NSDictionary* profile = [args get:0];
            NSLog(@"this is response og get:%@",profile);
            dispatch_async( dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"recivedGetMessage" object:self userInfo:profile];
                NSLog(@"recivedGetMessage");
            });
        }];
        
        [_socketIONodeServerUnicast on:@"disconnect" listener:^(NNArgs* args) {
            _isConnectsocketIONodeServerUnicast = NO;
            NSLog(@"connection result ____disconnect");
        }];
        
    }else{
        _isConnectsocketIONodeServerUnicast = NO;
        [NSException raise:@"Fatal" format:@"_socketIONodeServerUnicast or _nodeServerUnicastUrl in nil"];
    }
};

#pragma mark - SendEvent Method
-(BOOL)sendEventToUnicastServer:(NSDictionary*)value forEvent:(NSString*)name{
    if(_socketIONodeServerUnicast){
        NSDictionary* profile = value;
        NNArgs* args = [[NNArgs args] add:profile];
        [_socketIONodeServerUnicast emit:name args:args];
    }else{
        [NSException raise:@"Fatal" format:@"_socketIONodeServerUnicast is nil at bang"];
    }
    return YES;
};

#pragma mark - Shutdown Method
-(void)shutdwonUnicastServer{
    if(_isConnectsocketIONodeServerUnicast){
        [_socketIONodeServerUnicast disconnect]; 
        _isConnectsocketIONodeServerUnicast = NO;
    }
};


#pragma mark - Dいsconnect Method
- (void)disconnect{
    if(_socketIONodeServerUnicast){
        [self shutdwonUnicastServer];
    }
};


#pragma mark - SocketIO connectiong Method
- (void) socketIODidConnect:(NSString *)socketName{
    
    if([@"UnibaSocketIOConnector" isEqualToString:socketName]){
        _isConnectsocketIONodeServerUnicast = YES;
        [_dataOfConnection setValue:[NSNumber numberWithInt:1] forKey:@"connectioinUnicast"];
    }
    
    dispatch_async( dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"recivedConnectionData" object:self userInfo:_dataOfConnection];
    });
}
@end
