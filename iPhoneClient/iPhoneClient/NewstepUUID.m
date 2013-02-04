//
//  NewstepUUID.m
//  Expréss Editor
//
//  Created by エルダアンドレ on  2006/01/09.
//  Copyright 2006 Newstep Inc. All rights reserved.
//

#import "NewstepUUID.h"
#import <CoreFoundation/CoreFoundation.h>

@implementation NewstepUUID

#pragma mark
#pragma mark Create and Return a New String-Based UUID
//Wraps Core Foundation CFUUID Object. NOTE:Try to make not using CF in future
//Returned String is Autoreleased
+ (NSString *)UUID {
	NSString  *UUIDString = nil;
	CFUUIDRef newUUID = NULL;
	
	if ((newUUID = CFUUIDCreate(kCFAllocatorDefault))) {
		UUIDString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, newUUID);
		CFRelease(newUUID);
        
#if __has_feature(objc_arc)
#else
        [UUIDString autorelease];
#endif

	}
	
	return UUIDString;
}

@end
