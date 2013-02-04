//
//  PHVDynamicDataSupport.m
//  Battery Poop
//
//  Created by アンドレ on H.24/08/16.
//  Copyright (c) 平成24年 エルダ アンドレ. All rights reserved.
//

#import "NewstepUUID.h"
#import "PHVBaseDataSupport.h"
#import "UIAlertViewCategories.h"
#import "PHVDynamicDataSupport.h"
#import "NSMutableString+NewstepNSStringAdditions.h"

@implementation UIImage (ImageNamed)

+ (imageNamedAccessor)imageNamed {
	return ^UIImage* (NSString *imageName) {
		return [self imageNamed:imageName];
	};
}

@end

@implementation UIImage (PNGAndJPEG)

- (NSData *)png {
	NSData *pngData = UIImagePNGRepresentation(self);
	return pngData;
}

- (NSData *)jpeg {
	NSData *jpegData = UIImageJPEGRepresentation(self,1.0f);
	return jpegData;
}

@end

@implementation NSString (URLEncode)
- (NSString *)urlEncodedString {
	NSString *result = [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	return result;
}

@end

@implementation NSMutableString (URLEncode)
- (void)urlEncode {
	NSString *result = [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	[self setString:result];
}
@end


@implementation NSString (Adding)

- (stringAdder)add {
	return ^NSString* (NSString *additionalString) {
		if (nil == additionalString) {
			additionalString = @"";
		}
		return [self stringByAppendingString:additionalString];
	};
}

- (stringAdder)appendPath {
	return ^NSString* (NSString *additionalString) {
		if (nil == additionalString) {
			additionalString = @"";
		}
		return [self stringByAppendingPathComponent:additionalString];
	};
}

- (stringAdder)appendExtention {
	return ^NSString* (NSString *additionalString) {
		if (nil == additionalString) {
			additionalString = @"";
		}
		return [self stringByAppendingPathExtension:additionalString];
	};
}

@end

@implementation NSMutableString (MutableAdding)

- (stringAdder)append {
	return ^NSString * (NSString *additionalString) {
		if (nil == additionalString) {
			additionalString = @"";
		}
		[self appendString:additionalString];
		return self;
	};
}

@end


@implementation NSString (MIMEAdditions)

__strong static NSString* MIMEBoundary = nil;

+ (NSString*)MIMEBoundary {
    if(nil == MIMEBoundary) {
        MIMEBoundary = [NSString stringWithFormat:@"--Uniba-%@--",NSProcessInfo.processInfo.globallyUniqueString];
	}
    return MIMEBoundary;
}

+ (NSString*)multipartMIMEStringFromDictionary:(NSDictionary*)dictionary {
    
	NSMutableString* result = NSMutableString.string;
    for (NSString* key in dictionary) {
        [result appendFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n",NSString.MIMEBoundary,key,dictionary[key]];
    }
	
    [result appendFormat:@"--%@--\r\n",NSString.MIMEBoundary];
	
    return result;
}

@end

@interface NSMutableDictionary (PHVPOST_Private)
- (NSString *)cachePath;
@end

@implementation NSMutableDictionary (PHVPOST)
- (BOOL)sync {
	if (nil != self.cachePath) {
		NSDictionary *cachedDictionary = [NSDictionary dictionaryWithContentsOfFile:self.cachePath];
		if (nil != cachedDictionary) {
			[self setDictionary:cachedDictionary];
			return YES;
		}
	}
	return NO;
}
@end

//3Gまたは2Gの回線では、同時に行える通信は極めて限定している。タイムアウトやエラーを避けるために、全ての通信を一つのスレッドに限定・制御する。一つしかないので、staticで宣言して、アプリが終了するまで存在する。
static dispatch_queue_t _PHVTransferQueue = NULL;
static dispatch_queue_t _PHVWiFiTransferQueue = NULL;
static dispatch_group_t _PHVWiFiTransferGroup = NULL;

@implementation UIDevice (PHVTransferQueue)
+ (dispatch_queue_t)PHVTransferQueue {
	if (NULL == _PHVTransferQueue) {
		_PHVTransferQueue = dispatch_queue_create("PHVTransferQueue", DISPATCH_QUEUE_SERIAL);
	}
	return _PHVTransferQueue;
}

+ (dispatch_queue_t)PHVWiFiTransferQueue {
	if (NULL == _PHVWiFiTransferQueue) {
		_PHVWiFiTransferQueue = dispatch_queue_create("PHVWiFiTransferQueue", DISPATCH_QUEUE_SERIAL);
	}
	return _PHVWiFiTransferQueue;
}

+ (dispatch_group_t)PHVWiFiTransferGroup {
	if (NULL == _PHVWiFiTransferGroup) {
		_PHVWiFiTransferGroup = dispatch_group_create();//dispatch_queue_create("PHVWiFiTransferQueue", DISPATCH_QUEUE_SERIAL);
	}
	return _PHVWiFiTransferGroup;
}
@end


@implementation NSDictionary (PHVPOST)
@dynamic url;

+ (PHVDynamicDictionaryInitializer)initialize {
	return ^id (NSString *initializer) {
		NSMutableDictionary <PHVServerKeyedPOST> *mutableDynamicDictionary = @{}.mutableCopy;
		mutableDynamicDictionary.url = PHVServerLocation(initializer);
		mutableDynamicDictionary.key = kPHVSecretAppKey;
		return mutableDynamicDictionary;
	};
}

+ (PHVDynamicDictionaryInitializer)defrost {
	return ^id (NSString *initializer) {
		if (nil != initializer) {
			NSMutableDictionary <PHVServerKeyedPOST> *mutableDynamicDictionary = @{}.mutableCopy;
			mutableDynamicDictionary.url = PHVServerLocation(initializer);
			mutableDynamicDictionary.key = kPHVSecretAppKey;
			[mutableDynamicDictionary sync];
			
			return mutableDynamicDictionary;
		}
		return nil;
	};
}

- (BOOL)clearCache {
	if (nil != self.cachePath) {
		return [[NSFileManager defaultManager] removeItemAtPath:self.cachePath error:nil];
	}
	return NO;
}


- (BOOL)cache {

	__block BOOL couldCache = NO;
	
	if (nil != self.cachePath) {
		NSError *createIntermediateCacheDirectoriesError = nil;
		NSString *intermediateDirectories = [self.cachePath stringByDeletingLastPathComponent];
		[[NSFileManager defaultManager] createDirectoryAtPath:intermediateDirectories withIntermediateDirectories:YES attributes:nil error:&createIntermediateCacheDirectoriesError];
		
		//Convert all keys to strings
		NSString *currentStatus = self.status;
		NSURL *currentURL = self.url;
		NSString *cache = self.cachePath;
		
		dispatch_queue_t currentQueue = dispatch_get_current_queue();
		dispatch_queue_t mainQueue = dispatch_get_main_queue();
		void (^saveToCache)(void) = ^ {
			self.url = nil;
			self.status = nil;
			
			couldCache = [self writeToFile:cache atomically:YES];
			
			self.url = currentURL;
			self.status = currentStatus;
		};
		
		//Make sure to save on main thread, for some reason saving on non-main can fail
		if (nil == createIntermediateCacheDirectoriesError) {
			if (currentQueue == mainQueue) {
				saveToCache();
			} else {
				dispatch_sync(mainQueue, saveToCache);
			}
		} else {
			[UIAlertView showDebugAlertWithError:createIntermediateCacheDirectoriesError];
		}
	}
	
	return couldCache;
}

- (NSString *)cachePath {
	
	NSString *cacheDirectory = nil;
	
	NSURL *selfURL = nil;
	NSArray *documentsPaths = nil;
	NSString *libraryPath = nil;
	NSString *lastURLComponent = nil;
	
	if ((selfURL = self.url)) {
		if ((documentsPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES))) {
			if ((libraryPath = documentsPaths[0])) {
				if ((lastURLComponent = selfURL.lastPathComponent)) {
					if (lastURLComponent.length > 0) {
						cacheDirectory = libraryPath.appendPath(kPHVCacheName).appendPath(lastURLComponent).appendExtention(kPHVPlistExtension);
					}
				}
			}
		}
	}
	
	return cacheDirectory;
}


- (NSMutableDictionary *)post {
	return [self get:NO];
}

- (NSMutableDictionary *)get {
	return [self get:YES];
}



- (NSMutableDictionary *)get:(BOOL)get {
	__block NSMutableDictionary *responseJSON = nil;
	
	dispatch_sync(UIDevice.PHVTransferQueue, ^{
		if (nil != self.url) {
			if (self.allKeys.count > 0) {
				NSMutableDictionary *headerFields = @{@"Content-Transfer-Encoding" : @"8bit"}.mutableCopy;
				NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:kPHVDefaultConnectionTimeout];//[[NSMutableURLRequest alloc] initWithURL:self.url];
				NSData *bodyData = nil;
				request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
				
				if (YES == get) {
					//				NSString *encodedRandomParameter = NewstepUUID.UUID.urlEncodedString;
					//				request.URL = self.url;//.appendPath(@"?pluggy=").add(encodedRandomParameter).url;
					request.HTTPMethod = @"GET";
				} else { //POST
					NSString *bodyString = [NSString multipartMIMEStringFromDictionary: self];
					bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
					headerFields[@"Content-Type"] = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",NSString.MIMEBoundary];
					request.HTTPMethod = @"POST";
					request.allHTTPHeaderFields = headerFields;
					request.HTTPBody = bodyData;
				}
				
				NSLog(@"Header Fields:%@",headerFields);
				
#ifdef DEBUG
				if ([[NSFileManager defaultManager] fileExistsAtPath:@"/users/andore/"]) {
					NSError *writingHeaderError = nil;
					NSString *headerFieldsFilePath = @"/users/andore/test-".add(self.url.path.lastPathComponent).add(@".http-header.txt");
					[headerFields.description writeToFile:headerFieldsFilePath atomically:YES encoding:NSUTF8StringEncoding error:&writingHeaderError];
					NSLog(@"%@",writingHeaderError);
				}
				
				if (nil != bodyData) {
					if ([[NSFileManager defaultManager] fileExistsAtPath:@"/users/andore/"]) {
						NSString *bodyDataFilePath = @"/users/andore/test-".add(self.url.path.lastPathComponent).add(@".post.txt");
						[bodyData writeToFile:bodyDataFilePath atomically:YES];
					}
				}
#endif
				
				NSURLResponse *requestResponse = nil;
				NSError *responseError = nil;
				NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&requestResponse error:&responseError];
				
				if (nil != responseError) {
					//NSLog(@"self.json = ",responseError);
					//[UIAlertView showAlertWithError:responseError andAutoDismissWithDelayInSeconds:3.0f];
				}
				
				if (nil != responseData) {
					NSError *jsonLoadingError = nil;
					NSJSONReadingOptions readingOptions = (NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments);
					
					responseJSON = [NSJSONSerialization JSONObjectWithData:responseData options:readingOptions error:&jsonLoadingError];
					
					if (nil != jsonLoadingError) {
						//NSLog(@"self.json = %@",jsonLoadingError);
						//[UIAlertView showAlertWithError:jsonLoadingError andAutoDismissWithDelayInSeconds:3.0f];
						
#ifdef DEBUG
						if ([[NSFileManager defaultManager] fileExistsAtPath:@"/users/andore/"]) {
							NSString *responseDataFilePath = @"/users/andore/test-".add(self.url.path.lastPathComponent).add(@"-response.json.txt");
							[responseData writeToFile:responseDataFilePath atomically:YES];
						}
#endif
					} else {
						responseJSON.url = self.url;
					}
					
#ifdef DEBUG
					if ([[NSFileManager defaultManager] fileExistsAtPath:@"/users/andore/"]) {
						NSString *responseDataFilePath = @"/users/andore/test-".add(self.url.path.lastPathComponent).add(@"-response.json.txt");
						[responseData writeToFile:responseDataFilePath atomically:YES];
					}
#endif
				}
			}
		}
	});
	
	return responseJSON;

}

@end

