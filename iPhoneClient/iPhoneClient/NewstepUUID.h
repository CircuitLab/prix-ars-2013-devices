//
//  NewstepUUID.h
//  Expréss Editor
//
//  Created by エルダアンドレ on  2006/01/09.
//  Copyright 2006 Newstep Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NewstepUUID : NSObject {}

#pragma mark
#pragma mark Create and Return a New String-Based UUID
//Returned String is AutoperformSelector:@selector(retain)d
+ (NSString *)UUID;

@end
