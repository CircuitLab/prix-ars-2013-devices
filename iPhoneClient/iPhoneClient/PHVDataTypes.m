//
//  PHVDataTypes.m
//  Battery Poop
//
//  Created by アンドレ on H.24/08/16.
//  Copyright (c) 平成24年 エルダ アンドレ. All rights reserved.
//

#import "PHVDataTypes.h"
#import "PHVBaseDataSupport.h"
#import "UIAlertViewCategories.h"
#import "PHVDynamicDataSupport.h"
#import "NSMutableString+NewstepNSStringAdditions.h"

#pragma mark - Compiler Tricks
@implementation PHVIndexedMedal
- (NSObject <PHVMedal> *)objectAtIndexedSubscript:(NSUInteger)idx {return nil;}
@end

@implementation PHVIndexedRanking
- (NSObject <PHVRanking> *)objectAtIndexedSubscript:(NSUInteger)idx {return nil;}
@end

@implementation PHVIndexedScore
- (NSObject <PHVUserScore> *)objectAtIndexedSubscript:(NSUInteger)idx {return nil;}
@end

@implementation PHVKeyedTarget
- (NSObject <PHVTargetRanking> *)objectForKeyedSubscript:(id)key {
	return nil;
}

- (void)setObject:(NSObject<PHVTargetRanking>*)thing forKeyedSubscript:(id<NSCopying>)key {
	nil;
}
@end

#pragma mark - Dynamic Data
@interface NSObject (PHVRetreivedImage) 
- (UIImage *)retreivedImage;
@end

@implementation  NSObject  (PHVRetreivedImage)

- (UIImage *)retreivedImage {
	
	NSObject<PHVUserRegistrationResponse,PHVJSONURL>*dynamicSelf = (id)self;
	__block UIImage *recievedUIImage = nil;
	
	dispatch_sync(UIDevice.PHVTransferQueue, ^{		
		NSData *responseData = nil;
		NSURLResponse *getUserImageResponse = nil;
		NSError *getRemoteImageError = nil;
		NSURLRequest *getUserImageRequest = [NSURLRequest requestWithURL:dynamicSelf.image_url.url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:kPHVDefaultConnectionTimeout];
		
		if ((responseData = [NSURLConnection sendSynchronousRequest:getUserImageRequest returningResponse:&getUserImageResponse error:&getRemoteImageError])) {
			if ([kPHVUserImageMimeTypePNG isEqualToString:getUserImageResponse.MIMEType]) {
				if ((recievedUIImage = [UIImage imageWithData:responseData])) {} else {
					NSLog(@"Could not initialize image from data of length %u at url:%@",responseData.length,dynamicSelf.url);
				}
			} else {
				NSLog(@"Mime-Type Incorrect:%@\nShould be:%@",getUserImageResponse.MIMEType,kPHVUserImageMimeTypePNG);
				[UIAlertView showDebugAlertWithContinueButton:@"Mime-Type Incorrect" andMessage:[NSString stringWithFormat:@"Mime-Type is %@, should be %@",getUserImageResponse.MIMEType,kPHVUserImageMimeTypePNG]];
			}
		}
		
		if (nil != getRemoteImageError) {
			NSLog(@"Error getting Image:",getRemoteImageError);
			[UIAlertView showAlertWithError:getRemoteImageError];
		}
	});
	
	return recievedUIImage;
}

@end

@implementation NSObject (PHVMediaItem)

- (NSDate *)updated_at_date {
	
	NSDate *currentDate = nil;
	NSObject <PHVMedia>*dynamicSelf = (id)self;
	
	if (nil != dynamicSelf.updated_at) {
		currentDate = dynamicSelf.updated_at.isoGMTDate;
	}
	
	return currentDate;
}

@end