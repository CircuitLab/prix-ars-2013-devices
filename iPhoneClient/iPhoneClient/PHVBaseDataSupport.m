//
//  PHVBaseDataSupport.m
//  Battery Poop
//
//  Created by アンドレ on H.24/08/16.
//  Copyright (c) 平成24年 エルダ アンドレ. All rights reserved.
//

#import "NSMutableString+NewstepNSStringAdditions.h"
#import "PHVDynamicDataSupport.h"
#import <QuartzCore/QuartzCore.h>
#import "UIAlertViewCategories.h"
#import "PHVBaseDataSupport.h"
#import "NewstepUUID.h"


NSString *kPHVServerResponseOK = @"OK";
NSString *kPHVServerResonseError = @"ERROR";
NSString *kPHVSecretAppKey = @"93DC963F-C158-48A9-82F5-0BE26FDC0AF3";

NSString *kPHVUserImageMimeTypePNG = @"image/png";
NSString *kPHVUserImageExtentionTypePNG = @"png";

NSString *kPHVValidCountryCodeTableFileName = @"PHV-ValidCountryCodes.plist";
NSString *kPHVValidCountryCodeMapFileName = @"PHV-CountryCodeToEnglishMapping.plist";
NSString *kPHVInvalidCountryCodeMapFileName = @"PHV-PHV-InvalidCountryCodeMapping.plist";

NSString *kPHVFlagNameSeparator = @"-";

NSTimeInterval kPHVDefaultConnectionTimeout = 21.0F;

#if TEST_URL > 0
NSString *kPHVAppURL = @"http://phv-dev.scl.uniba.jp/";
#else
NSString *kPHVAppURL = @"http://plugin.toyota-digital.com/";
#endif

NSString *kPHVCountyCodeCanada = @"CA";
NSString *kPHVCountyCodeAmerica = @"US";
NSString *kPHVCountyCodeJapan = @"JP";
NSString *kPHVToyotaJapanPromotionURL = @"http://toyota.jp/priusphv/index.html";
NSString *kPHVToyotaCanadaQuebecPromotionURL = @"http://m.toyota.ca/toyota/fr/m/vehicles/prius-plugin/overview";
NSString *kPHVToyotaCanadaPromotionURL = @"http://m.toyota.ca/toyota/en/m/vehicles/prius-plugin/overview";
NSString *kPHVToyotaAmericaPromotionURL = @"http://touch.toyota.com/prius-plug-in/";
NSString *kPHVToyotaWorldPromotionURL = @"http://www.toyota-global.com/innovation/environmental_technology/plugin_hybrid/";

NSString *kPHVNewUser = @"api/users";
NSString *kPHVUserUpdate = @"api/users/update";
NSString *kPHVPostScore = @"api/score";
NSString *kPHVMedals = @"api/medals";
NSString *kPHVRankings = @"api/rankings";
NSString *kPHVUserShare = @"api/share";
NSString *kPHVMedia = @"api/media";
NSString *kPHVTicker = @"api/ticker";

#ifdef DEBUG
NSString *kPHVDailySyukei_DEBUG = @"debug/";
NSString *kPHVMonthlySyukei_DEBUG;
NSString *kPHVDeleteData_DEBUG;
#endif

NSString *kPHVSNSShareActionSheetName = @"PHVSNSShareActionSheetName";
NSString *kPHVFacebookSNSDBName = @"fb";
NSString *kPHVTwitterSNSDBName = @"tw";

NSString *kPHVUnrecognizedCountryCode = @"ZZ";

NSString *kPHVJSONExtension = @"json";
NSString *kPHVPlistExtension = @"plist";
NSString *kPHVCacheExtension = @"data";
NSString *kPHVVideoMediaExtention = @"mp4";
NSString *kPHVVideoMediaMimeType = @"video/mp4";
NSString *kPHVVideoMediaFileComponenetSeparator = @"-";
NSString *kPHVVideoMediaFileDateComponentReplacementSeparator = @"^";
NSString *kPHVVideoMediaFileTimeComponentReplacementSeparator = @"_";
NSString *kPHVVideoMediaFileDateSeparator = @"/";
NSString *kPHVVideoMediaFileTimeSeparator = @":";
NSString *kPHVCacheName = @"PHVCache";
NSString *kPHVPlayerCacheDirectoryName = @"players";
NSString *kPHVMediaCacheDirectoryName = @"PHVMedia";
NSString *kPHVDownloadingMediaCacheDirectoryName = @"_PHVMedia-InTransit";

NSString *kPHVTargetComponentSepearatorString = @" / ";

NSString *kPHVCachePayloadKey = @"payload";

NSString *kPHVFlagNamePrefix = @"Flag-";

NSString *kPHVDefaultUserImageName = @"PHV-XX-Image-UserProfile-NoImage";

NSString *kPHVTickerFileNamePrefix = @"Ticker-";

uint kPHVStandardStringEncoding = NSUTF8StringEncoding;

NSString *kPHVAmericanEnglishLocaleIdentifier = @"en_US";
NSString *kPHVCanadianFrenchLocaleIdentifier= @"fr_CA";
NSString *kPHVEnglishLanguageIdentifier = @"en_US";
NSString *kPHVFrenchLanguagedentifier = @"fr";

NSString *kPHVUserContractLocalSaveDirectoryName = @"PHVTerms";
NSString *kPHVUserContractFilenameExtension = @"txt";
NSString *kPHVUserContractDirectoryName = @"terms";
NSString *kPHVDefaultBuiltInTermsOfUseFileName = @"PHV - TOYOTA - Plugin Championship - Terms of Use - ";

#pragma mark - Convenience Methods
NSURL *PHVServerLocation(NSString *path) {
	return kPHVAppURL.add(path).url;
}

NSNumber *kPHVServernil(void) {
	return @NO;
}

Base64 *emptyBase64Image(void) {
	return  (id)@"";
}

#pragma mark - Flags
UIImage *PHVFlagImageForCountryCode(NSString *countryCode) {
	return UIImage.imageNamed(PHVFlagFileNameForCountryCode(countryCode));
}

NSString *PHVFlagFileNameForCountryCode(NSString * isoCountryCode) {

	NSString *flagFileName = nil;
	NSString *alternativeISOCode = nil;

	if (nil != isoCountryCode && isoCountryCode.length > 0) {
		if (PHVCountryCodeValid == [NSLocale getCountryCodeStatus:isoCountryCode andSubsituteCode:&alternativeISOCode]) {
			flagFileName = kPHVFlagNamePrefix.add(isoCountryCode);
		} else if (nil != alternativeISOCode && alternativeISOCode.length > 0) {
			flagFileName = kPHVFlagNamePrefix.add(alternativeISOCode);
		}
	}
	
	if (nil != flagFileName && flagFileName.length > kPHVFlagNamePrefix.length) {
		return flagFileName;
	}
	
	return kPHVFlagNamePrefix.add(kPHVUnrecognizedCountryCode);
}

NSString *PHVTickerFlagFileNameForCountryCode(NSString *isoCountryCode) {
	return kPHVTickerFileNamePrefix.add(PHVFlagFileNameForCountryCode(isoCountryCode));
}

UIImage *PHVTickerFlagImageForCountryCode(NSString *isoCountryCode) {
	return UIImage.imageNamed(PHVTickerFlagFileNameForCountryCode(isoCountryCode));
}


static __strong NSString *___PHVPlayerCacheDirectory = nil;

FOUNDATION_EXPORT NSString *PHVPlayerCacheDirectory(void) {
	if (nil != ___PHVPlayerCacheDirectory) {
		return ___PHVPlayerCacheDirectory;
	}
	
	NSArray *cacheDirectories = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	if (cacheDirectories.count > 0) {
		NSString *cachePath = cacheDirectories[0];
		NSString *phvUserImageCachePath = cachePath.appendPath(kPHVPlayerCacheDirectoryName);
		if (YES == [[NSFileManager defaultManager] createDirectoryAtPath:phvUserImageCachePath withIntermediateDirectories:YES attributes:nil error:nil]) {
			___PHVPlayerCacheDirectory = phvUserImageCachePath;
		}		
	}
	
	return ___PHVPlayerCacheDirectory;
}

#pragma mark - Media/Videos Cache

static __strong NSString *___PHVMediaDirectory = nil;

FOUNDATION_EXPORT NSString *PHVMediaBuiltInVideosDirectory(void) {
	if (nil == ___PHVMediaDirectory) {
		___PHVMediaDirectory = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Videos"];
	}
	
	return ___PHVMediaDirectory;
}

static __strong NSString *___PHVMediaCacheDirectory = nil;

FOUNDATION_EXPORT NSString *PHVMediaCacheDirectory(void) {
	if (nil != ___PHVMediaCacheDirectory) {
		return ___PHVMediaCacheDirectory;
	}
	
#if DEBUG > 1
	NSUInteger saveDirectory = NSDocumentDirectory;
#else
	NSUInteger saveDirectory = NSLibraryDirectory;
#endif
	
	NSArray *cacheDirectories = NSSearchPathForDirectoriesInDomains(saveDirectory, NSUserDomainMask, YES);
	if (cacheDirectories.count > 0) {
		NSString *cachePath = cacheDirectories[0];
		NSString *phvMediaCachePath = cachePath.appendPath(kPHVMediaCacheDirectoryName);
		if (YES == [[NSFileManager defaultManager] createDirectoryAtPath:phvMediaCachePath withIntermediateDirectories:YES attributes:nil error:nil]) {
			___PHVMediaCacheDirectory = phvMediaCachePath;
		}
	}
	
	return ___PHVMediaCacheDirectory;
}

static __strong NSString *___PHVMediaTestDirectory = nil;

FOUNDATION_EXPORT NSString *PHVMediaTestDirectory(void) {
	if (nil != ___PHVMediaTestDirectory) {
		return ___PHVMediaTestDirectory;
	}
	
	NSUInteger saveDirectory = NSDocumentDirectory;
	
	NSArray *cacheDirectories = NSSearchPathForDirectoriesInDomains(saveDirectory, NSUserDomainMask, YES);
	if (cacheDirectories.count > 0) {
		NSString *cachePath = cacheDirectories[0];
		NSString *testPath = cachePath.appendPath(@"90F4B62D-2DDA-43AB-A5B9-5BF5909F8E3D.bundle");
		___PHVMediaTestDirectory = testPath;
	}
	
	return ___PHVMediaTestDirectory;
}

static __strong NSString *___PHVDownloadingMediaCacheDirectory = nil;

FOUNDATION_EXPORT NSString *PHVDownloadingMediaCacheDirectory(void) {
	if (nil != ___PHVDownloadingMediaCacheDirectory) {
		return ___PHVDownloadingMediaCacheDirectory;
	}
		
#if DEBUG > 1
	NSArray *cacheDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
#else
	NSArray *cacheDirectories = @[ NSTemporaryDirectory() ];
#endif
	
	if (cacheDirectories.count > 0) {
		NSString *cachePath = cacheDirectories[0];
		NSString *phvMediaCachePath = cachePath.appendPath(kPHVDownloadingMediaCacheDirectoryName);
		if (YES == [[NSFileManager defaultManager] createDirectoryAtPath:phvMediaCachePath withIntermediateDirectories:YES attributes:nil error:nil]) {
			___PHVDownloadingMediaCacheDirectory = phvMediaCachePath;
		}
	}
	
	return ___PHVDownloadingMediaCacheDirectory;
}

NSString *PHVCleanedDateStringForSavingToFileSysytem(NSString * filenameDate) {
	NSString *cleanedString = nil;
	
	if (nil != filenameDate) {
		cleanedString = [filenameDate stringByReplacingOccurrencesOfString:kPHVVideoMediaFileDateSeparator withString:kPHVVideoMediaFileDateComponentReplacementSeparator];
		cleanedString = [cleanedString stringByReplacingOccurrencesOfString:kPHVVideoMediaFileTimeSeparator withString:kPHVVideoMediaFileTimeComponentReplacementSeparator];
	}
	
	return cleanedString;
}

NSString *PHVRestoredDateStringFromFilesystem(NSString *string) {
	NSString *restoredString = nil;
	
	if (nil != string) {
		restoredString = [string stringByReplacingOccurrencesOfString:kPHVVideoMediaFileDateComponentReplacementSeparator withString:kPHVVideoMediaFileDateSeparator];
		restoredString = [restoredString stringByReplacingOccurrencesOfString:kPHVVideoMediaFileTimeComponentReplacementSeparator withString:kPHVVideoMediaFileTimeSeparator];
	}

	return restoredString;
}

PHVIndexedMedia *PHVMediaList(void) {

	NSMutableArray *listItems = [[NSMutableArray alloc]initWithCapacity:10];
	NSString *cachePath = PHVMediaCacheDirectory();
	
	if (nil != cachePath) {
		NSArray *cachedMediaItems = [[NSFileManager defaultManager] subpathsAtPath:cachePath];
	
		for (NSString *cachedMedia in cachedMediaItems) {
			
			NSString *fileName = cachedMedia.lastPathComponent;
			NSString *fileExtention = fileName.pathExtension;
			
			if (nil != fileExtention && fileExtention.length > 0) {
				if ([fileExtention isEqualToString:kPHVVideoMediaExtention]) {
				
					NSString *nakedFileName = [fileName stringByDeletingPathExtension];
					NSArray *fileNameComponents =[nakedFileName componentsSeparatedByString:kPHVVideoMediaFileComponenetSeparator];
				
					if (nil != fileNameComponents && fileNameComponents.count > 1) {
						
						NSString *mediaID = fileNameComponents[0];
						NSString *mediaUpdateDate = fileNameComponents[1];
					 
						if (nil != mediaID && mediaID.length > 0) {
							if (nil != mediaUpdateDate && mediaUpdateDate.length > 0) {
								
								NSObject <PHVMedia>*fileListItem = (id)NSMutableDictionary.new;
								fileListItem.video_id = mediaID.number;
								fileListItem.updated_at = PHVRestoredDateStringFromFilesystem(mediaUpdateDate);
								fileListItem.url = [PHVMediaCacheDirectory() stringByAppendingPathComponent:fileName];
								[listItems addObject:fileListItem];
							}
						}
					}
				}
			}
		}
	}
	
	return (id)listItems;
}

#pragma mark - User Contract
static __strong NSString *___PHVUserContractCacheDirectory = nil;
NSString *PHVUserContractSavePath(void) {
	if (nil != ___PHVUserContractCacheDirectory) {
		return ___PHVUserContractCacheDirectory;
	}
	
	NSUInteger saveDirectory = NSLibraryDirectory;
	NSArray *cacheDirectories = NSSearchPathForDirectoriesInDomains(saveDirectory, NSUserDomainMask, YES);

	if (cacheDirectories.count > 0) {
		NSString *cachePath = cacheDirectories[0];
		NSString *testPath = cachePath.appendPath(kPHVUserContractLocalSaveDirectoryName);
		
		[NSFileManager.defaultManager createDirectoryAtPath:testPath withIntermediateDirectories:YES attributes:nil error:nil];
		
		___PHVUserContractCacheDirectory = testPath;
	}
	
	return ___PHVUserContractCacheDirectory;
}


NSString *PHVUserContractSavePathForLanguage(NSString *languageIdentifier) {
	
	NSString *cachedUserContractDirectory = nil;
	
	if (nil != languageIdentifier) {
		if ( [languageIdentifier hasPrefix:kPHVEnglishLanguageIdentifier] || [languageIdentifier hasPrefix:kPHVFrenchLanguagedentifier]) {
			if ((cachedUserContractDirectory = PHVUserContractSavePath())) {
				if (cachedUserContractDirectory.length > 0) {
					cachedUserContractDirectory = cachedUserContractDirectory.appendPath(languageIdentifier).appendExtention(kPHVUserContractFilenameExtension);
				}
			}
		}
	}
	
	return cachedUserContractDirectory;
}

NSString *PHVUserContractForLanguage(NSString *languageIdentifier) {

	NSString *userContractForLocale = nil;
	NSString *savePathForLocalContract = nil;
	NSError *userContractFileOpenError = nil;
	
	if (nil != languageIdentifier) {
		if ((savePathForLocalContract = PHVUserContractSavePathForLanguage(languageIdentifier))) {
			userContractForLocale = [NSString stringWithContentsOfFile:savePathForLocalContract encoding:kPHVStandardStringEncoding error:&userContractFileOpenError];
		}
		
		if (nil != userContractFileOpenError) {
			NSLog(@"Error opening contract for language %@ at path %@ - Error:%@",languageIdentifier,savePathForLocalContract,userContractFileOpenError.localizedDescription);
			[UIAlertView showDebugAlertWithError:userContractFileOpenError];
			userContractFileOpenError = nil;
		}
		
		if (nil == userContractForLocale) {
			NSString *builtingContractForLocalePath = [[NSBundle mainBundle] pathForResource:kPHVDefaultBuiltInTermsOfUseFileName.add(languageIdentifier) ofType:kPHVUserContractFilenameExtension];
			if (nil != builtingContractForLocalePath) {
				userContractForLocale = [NSString stringWithContentsOfFile:builtingContractForLocalePath encoding:kPHVStandardStringEncoding error:&userContractFileOpenError];
			}
		}
		
		if (nil != userContractFileOpenError) {
			NSLog(@"Error opening contract for language %@ at path %@ - Error:%@",languageIdentifier,savePathForLocalContract,userContractFileOpenError.localizedDescription);
			[UIAlertView showDebugAlertWithError:userContractFileOpenError];
		}
	}
	
	
	return userContractForLocale;
}

NSURL *PHVUserContractDownloadURLForLanguage(NSString *languageIdentifier) {

	NSURL *downloadURL = nil;
	
	if (nil != languageIdentifier) {
		if ([languageIdentifier hasPrefix:kPHVEnglishLanguageIdentifier] || [languageIdentifier  hasPrefix:kPHVFrenchLanguagedentifier]) {
			downloadURL = kPHVAppURL.appendPath(kPHVUserContractDirectoryName).appendPath(languageIdentifier).appendExtention(kPHVUserContractFilenameExtension).url;
		}
	}
	
	return downloadURL;
}

static BOOL _isAttemptingToDownloadContract = NO;
static const NSString *_contractDownloadLock = @"downloadLock";

void PHVAttemptToUpdateUserContractForLocale(NSString *localeIdentifier) {
	
	if (nil != localeIdentifier) {
		if (YES == PHVShouldDownloadContractForLocale(localeIdentifier)) {
			
			BOOL canAttemptDownload = NO;
			
			@synchronized(_contractDownloadLock) {
				if (NO == _isAttemptingToDownloadContract) {
					_isAttemptingToDownloadContract = YES;
					canAttemptDownload = YES;
				}
			}
			
			if (canAttemptDownload) {
				
				NSString *savePath = nil;
				NSError *contractSaveError = nil;
				NSError *contractDownloadError = nil;
				NSURL *downloadURL = PHVUserContractDownloadURLForLanguage(localeIdentifier);
				
				if (nil != downloadURL) {
					
					NSString *newContract = [NSString stringWithContentsOfURL:downloadURL encoding:kPHVStandardStringEncoding error:&contractDownloadError];
					
					if (nil != newContract) {
						if (newContract.length > 0) {
							if ((savePath = PHVUserContractSavePathForLanguage(localeIdentifier))) {
								
								if (YES == [newContract writeToFile:savePath atomically:YES encoding:kPHVStandardStringEncoding error:&contractSaveError]) {
									NSLog(@"Succeded to download new user contract to %@ !!",savePath);
								}
								
								if (nil != contractSaveError) {
									NSLog(@"Error saving contract for locale %@ at to file %@ - Error:%@",localeIdentifier,savePath,contractSaveError.localizedDescription);
									[UIAlertView showDebugAlertWithError:contractSaveError];
								}
							}
						}
					}
					
					if (nil != contractDownloadError) {
						NSLog(@"Error downloading contract for locale %@ at URL %@ - Error:%@",localeIdentifier,downloadURL.absoluteString,contractDownloadError.localizedDescription);
						[UIAlertView showDebugAlertWithError:contractDownloadError];
					}
				}
				
				@synchronized(_contractDownloadLock) {
					_isAttemptingToDownloadContract = NO;
				}
			}
		}
	}
}



BOOL PHVShouldDownloadContractForLocale(NSString *localeIdentifier) {

	BOOL shouldDownload = NO;
	BOOL attemptingToDownload = NO;
	
	NSString *downloadPath = PHVUserContractSavePathForLanguage(localeIdentifier);

	@synchronized(_contractDownloadLock) {
		attemptingToDownload = _isAttemptingToDownloadContract;
	}

	if (nil != localeIdentifier) {
		if (nil != downloadPath) {
			if (NO == attemptingToDownload) {
				shouldDownload = ![NSFileManager.defaultManager fileExistsAtPath:downloadPath];
			}
		}
	}
	
	return shouldDownload;
}

#pragma mark - Download Delegate
@interface  PHVMediaDownloadDelegate : NSObject <NSURLConnectionDelegate>

@property BOOL couldStartDownload;
@property (weak) NSURLConnection *owner;
@property (strong) NSString *outPutFIle;
@property (strong) NSString *tempOutPutFIle;
@property (strong) NSOutputStream *outputStream;
@property(strong) NSObject <PHVMedia>*downloadMedia;
@property(strong) NSMutableData *downloadData;

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

@end

@implementation PHVMediaDownloadDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSError *validationError = nil;
	
	if (YES == [kPHVVideoMediaMimeType isEqualToString:response.MIMEType]) {
		if (YES == [kPHVVideoMediaExtention isEqualToString:connection.currentRequest.URL.lastPathComponent.pathExtension]) {
		} else {
			NSString *localizedDescription = NSLocalizedString(@"Invalid File Type", nil);
			
			NSString *filename = connection.currentRequest.URL.lastPathComponent;
			NSString *pathExtension = filename.pathExtension;
			NSString *localizedReason = NSLocalizedString(@"File Type is %@ for file:%@\n\n Mime Type Should be:%@", nil);
			NSString *formattedLocalizedReason = [NSString stringWithFormat:localizedReason, pathExtension,filename,kPHVVideoMediaExtention];
			
			NSDictionary *info = @{	NSLocalizedDescriptionKey					:	localizedDescription,
															NSLocalizedFailureReasonErrorKey	:	formattedLocalizedReason};
			
			validationError = [NSError errorWithDomain:NSCocoaErrorDomain code:-3 userInfo:info];
		}
	} else {
		
		NSString *localizedDescription = NSLocalizedString(@"Invalid Mime Type", nil);
		
		NSString *filename = connection.currentRequest.URL.lastPathComponent;
		NSString *localizedReason = NSLocalizedString(@"Mime Type is %@ for file:%@\n\n Mime Type Should be:%@", nil);
		NSString *formattedLocalizedReason = [NSString stringWithFormat:localizedReason,response.MIMEType, filename,kPHVVideoMediaMimeType];
		
		NSDictionary *info = @{	NSLocalizedDescriptionKey					:	localizedDescription,
														NSLocalizedFailureReasonErrorKey	:	formattedLocalizedReason};
		
		validationError = [NSError errorWithDomain:NSCocoaErrorDomain code:-3 userInfo:info];
	}
	
	if (nil != validationError) {
		[self.owner cancel];
		[UIAlertView showAlertWithError:validationError];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	
	if (nil == self.tempOutPutFIle) {
		self.tempOutPutFIle = PHVTemporaryFileLocationForMediaDownload(self.downloadMedia);
		self.outPutFIle = PHVFileLocationForMediaDownload(self.downloadMedia);
	}
		
	if (NO == self.couldStartDownload) {
		self.couldStartDownload = [data writeToFile:self.tempOutPutFIle atomically:YES];
	} else {
		
		NSFileHandle *handle = [NSFileHandle fileHandleForUpdatingAtPath:self.tempOutPutFIle];
		[handle seekToEndOfFile];
		[handle writeData:data];
		[handle closeFile];
		
		NSLog(@"Writing to output stream of %d bytes for %@!!",data.length,connection.originalRequest.URL.lastPathComponent);		
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

#if DEBUG > 2
	NSFileHandle *handle = [NSFileHandle fileHandleForUpdatingAtPath:self.tempOutPutFIle];
	NSLog(@"Finished! %@ ..... total downloaded: %d",connection.originalRequest.URL.lastPathComponent,handle.availableData.length);
	[handle closeFile];
#endif
	
	BOOL moveSuccess = NO;
	NSError *fileMoveError = nil;
	NSFileManager *fileManager = NSFileManager.alloc.init;
	
	NSNumber *currentItemID = self.downloadMedia.video_id;
	PHVIndexedMedia *currentMediaList = PHVMediaList();

	for (NSObject <PHVMedia> *existingMedia in currentMediaList) {
		if ([existingMedia.video_id isEqualToNumber:currentItemID]) {
			if (nil != existingMedia.url) {
				NSError *existingItemWithSameIDDeletionError = nil;
				[fileManager removeItemAtPath:existingMedia.url error:&existingItemWithSameIDDeletionError];
				
				if (nil != existingItemWithSameIDDeletionError) {
#if DEBUG > 2
					[UIAlertView showDebugAlertWithError:existingItemWithSameIDDeletionError];
#endif
				}
				
			}
		}
	}
	
	moveSuccess = [fileManager moveItemAtPath:self.tempOutPutFIle toPath:self.outPutFIle error:&fileMoveError];
	
	if (YES == moveSuccess) {
#if DEBUG > 2
		[UIAlertView showDebugAlertWithContinueButton:@"Finished!" andMessage:self.downloadMedia.url.lastPathComponent];
#endif
		NSLog(@"Finished! %@",self.downloadMedia.url.lastPathComponent);
	} else {
#if DEBUG > 2
		[UIAlertView showDebugAlertWithError:fileMoveError];
#endif
		NSLog(@"Failed! %@",fileMoveError.description);
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
#if DEBUG > 2
	[UIAlertView showAlertWithContinueButton:@"Connection Failed" andMessage:connection.description.add(error.localizedDescription)];
#endif
	NSLog(@"Failed! %@",error.description);
}

- (void)dealloc {
	NSLog(@"DEBUGGIBG DEALOC!");
	self.outputStream = nil;
	PHVSetDownloadIsClear();
}

@end

#pragma mark - Download Helper Functions
NSString *PHVTemporaryFileLocationForMediaDownload(NSObject <PHVMedia>*downloadMedia) {
	NSString *tempFile = [PHVDownloadingMediaCacheDirectory() stringByAppendingPathComponent:NewstepUUID.UUID].add(@"-").add(downloadMedia.url.lastPathComponent.stringByDeletingPathExtension).appendExtention(kPHVVideoMediaExtention);
	return tempFile;
}

NSString *PHVFileNameForMediaDownload(NSObject <PHVMedia>*downloadMedia) {
	NSString *filenameIdComponent = downloadMedia.video_id.stringValue;
	NSString *filenameDateComponent = PHVCleanedDateStringForSavingToFileSysytem(downloadMedia.updated_at);
	NSString *originalFileName = downloadMedia.url.lastPathComponent.stringByDeletingPathExtension;
	NSString *savePathFilenameComponent = filenameIdComponent.add(kPHVVideoMediaFileComponenetSeparator).add(filenameDateComponent).add(kPHVVideoMediaFileComponenetSeparator).add(originalFileName).appendExtention(kPHVVideoMediaExtention);
	return  savePathFilenameComponent;
}

NSString *PHVFileLocationForMediaDownload(NSObject <PHVMedia>*downloadMedia) {
	NSString *fileName = PHVFileNameForMediaDownload(downloadMedia);
	NSString *tempFile = [PHVMediaCacheDirectory() stringByAppendingPathComponent:fileName];
	return tempFile;
}

void PHVDownloadMediaItem(NSObject <PHVMedia>*item) {
	if (YES == PHVDownloadIsClear()) {
		PHVSetDownloadHasBegun();
		dispatch_sync(UIDevice.PHVWiFiTransferQueue, ^{

			dispatch_sync_m(^{
				NSURL *fileDownloadURL = item.url.url;
				
				PHVMediaDownloadDelegate *delegate = [[PHVMediaDownloadDelegate alloc]init];
				delegate.downloadMedia = item;
				delegate.downloadData = [[NSMutableData alloc] initWithCapacity:100];
				NSMutableURLRequest *downloadingMediaRequest = [NSMutableURLRequest requestWithURL:fileDownloadURL cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:kPHVDefaultConnectionTimeout];
				NSURLConnection *downloadConnection = [NSURLConnection connectionWithRequest:downloadingMediaRequest delegate:delegate];
				delegate.owner = downloadConnection;
			});
			
			while (NO == PHVDownloadIsClear()) {
				[NSThread sleepForTimeInterval:2.0F];
			}
		});
	}
}

static BOOL PHVDownloadIsCleared = YES;
static const NSString *PHVDownloadClearedLock = @"PHVDownloadClearedLock";

BOOL PHVDownloadIsClear(void) {

	BOOL returnValue = NO;
	
	@synchronized(PHVDownloadClearedLock) {
		returnValue = PHVDownloadIsCleared;
	}
	
	return returnValue;
}

void PHVSetDownloadIsClear(void) {
	@synchronized(PHVDownloadClearedLock) {
		PHVDownloadIsCleared = YES;
	}
}

void PHVSetDownloadHasBegun(void) {
	@synchronized(PHVDownloadClearedLock) {
		PHVDownloadIsCleared = NO;
	}
}

void PHVWaitForDownloadsToComplete(void) {
	dispatch_group_wait(UIDevice.PHVWiFiTransferGroup, DISPATCH_TIME_FOREVER);
}

static BOOL _PHVDownloadsHaveBeenSuspended = NO;

void PHVSuspendDownloadsIfNecessary(void) {
	if (NO == _PHVDownloadsHaveBeenSuspended) {
		dispatch_suspend(UIDevice.PHVWiFiTransferQueue);
		_PHVDownloadsHaveBeenSuspended = YES;
	}
}

void PHVResumeDownloadsIfNecessary(void) {
	if (YES == _PHVDownloadsHaveBeenSuspended) {
		dispatch_resume(UIDevice.PHVWiFiTransferQueue);
		_PHVDownloadsHaveBeenSuspended = NO;
	}
}

NSUInteger PHVDownloadItemIndexOfItemWithIDInMedia(NSNumber *itemID,PHVIndexedMedia *videos) {
	
	NSUInteger itemIndex = NSNotFound;
	if (nil != itemID && nil != videos) {
		for (NSObject <PHVMedia> *item in videos) {
			NSNumber *id = item.video_id;
			if ([id isEqualToNumber:itemID]) {
				itemIndex = [videos indexOfObject:item];
				break;
			}
		}
	}
	
	return itemIndex;
}

NSString *kPHVURLPathSeparator = @"/";
NSString *kPHVCachedImageComponentSeparator = @"-";

#pragma mark - Interface Styling
void PHVSetRankingCornerRadius(CALayer *layer) {
	if (nil != layer) {
		layer.cornerRadius = kPHVRankingItemCornerRadius;
		layer.masksToBounds = YES;
	}
}

void PHVSetRegisterProfileCornerRadius(CALayer *layer) {
	if (nil != layer) {
		layer.cornerRadius = kPHVRankingItemCornerRadius*3;
		layer.masksToBounds = YES;
	}
}


void PHVSetRankingProfileShadow(CALayer *layer) {
	if (nil != layer) {
		PHVSetRankingShadow(layer);
		layer.shadowOffset = CGSizeMake(-2.0f, 0.0f);
		layer.shadowOpacity = 0.40;
		layer.shadowRadius = 2.1;
	}
}

void PHVSetMedalShadow(CALayer *layer) {
	if (nil != layer) {
		PHVSetRankingShadow(layer);
		layer.shadowColor = UIColor.blackColor.CGColor;
		layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
		layer.shadowOpacity = 1;
		layer.shadowRadius = 1.76;
	}
}

void PHVRemoveShadow(CALayer *layer) {
	if (nil != layer) {
		layer.shadowColor = nil;
		layer.shadowOpacity = 0.0f;
	}
}


void PHVSetRankingShadow(CALayer *layer) {
	if (nil != layer) {
		if (1 < UIScreen.mainScreen.scale) {
			layer.rasterizationScale = UIScreen.mainScreen.scale;
		}
		layer.shadowOpacity = 0.7;
		layer.shadowRadius = 3.0;
		layer.shadowColor = UIColor.blackColor.CGColor;
		layer.shadowOffset = CGSizeMake(0, 1.0);
		layer.shouldRasterize = YES;
	}
}

void PHVSetRankingPHVLogoShadow(CALayer *layer) {
	if (nil != layer) {
		if (1 < UIScreen.mainScreen.scale) {
			layer.rasterizationScale = UIScreen.mainScreen.scale;
		}
		layer.shadowColor = UIColor.whiteColor.CGColor;
		layer.shadowOffset = CGSizeMake(0, 1);
		layer.shadowRadius = 0.0f;
		layer.shadowOpacity = 0.65f;
	}
}

void PHVResultsPHVTitleShadow(CALayer *layer) {
	if (nil != layer) {
		if (1 < UIScreen.mainScreen.scale) {
			layer.rasterizationScale = UIScreen.mainScreen.scale;
		}
		layer.shadowOpacity = 0.82;
		layer.shadowRadius = 1.258;
		layer.shadowColor = UIColor.blackColor.CGColor;
		layer.shadowOffset = CGSizeMake(0.0, 0.750f);
		layer.shouldRasterize = YES;
	}
}


void PHVSetStanadardGlow(CALayer *layer) {
	if (nil != layer) {
		if (1 < UIScreen.mainScreen.scale) {
			layer.rasterizationScale = UIScreen.mainScreen.scale;
		}
		layer.shadowOpacity = 0.70;
		layer.shadowRadius = 6.0;

		layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
		layer.shouldRasterize = YES;
		layer.needsDisplayOnBoundsChange = YES;
	}
}

void PHVSetStanadardMedalCircleTextGlow(CALayer *layer) {
	if (nil != layer) {
		if (1 < UIScreen.mainScreen.scale) {
			layer.rasterizationScale = UIScreen.mainScreen.scale;
		}
		layer.shadowOpacity = 1.0f;
		layer.shadowRadius = 1.87f;

		layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
		layer.shouldRasterize = YES;
		layer.needsDisplayOnBoundsChange = YES;
	}
}


void PHVSetStanadardSplashTitleGlow(CALayer *layer) {
	if (nil != layer) {
		if (1 < UIScreen.mainScreen.scale) {
			layer.rasterizationScale = UIScreen.mainScreen.scale;
		}
		layer.shadowOpacity = 0.6;
		layer.shadowRadius = 4.0;
		layer.shadowColor = UIColor.whiteColor.CGColor;
		layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
		layer.shouldRasterize = YES;
		layer.needsDisplayOnBoundsChange = YES;
	}
}

void PHVSetStanadardSplashTitleInnerGlow(CALayer *layer) {
	if (nil != layer) {
		if (1 < UIScreen.mainScreen.scale) {
			layer.rasterizationScale = UIScreen.mainScreen.scale;
		}
		layer.shadowOpacity = 0.8;
		layer.shadowRadius = 1.68;
		layer.shadowColor = UIColor.whiteColor.CGColor;
		layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
		layer.shouldRasterize = YES;
		layer.needsDisplayOnBoundsChange = YES;
	}
}

void PHVSetStanadardSplashCopyrightGlow(CALayer *layer) {
	if (nil != layer) {
		if (1 < UIScreen.mainScreen.scale) {
			layer.rasterizationScale = UIScreen.mainScreen.scale;
		}
		layer.shadowOpacity = 0.85;
		layer.shadowRadius = 2.25;
		layer.shadowColor = UIColor.whiteColor.CGColor;
		layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
		layer.shouldRasterize = YES;
		layer.needsDisplayOnBoundsChange = YES;
	}
}

void PHVSetStanadardSplashLightningGlow(CALayer *layer) {
	if (nil != layer) {
		if (1 < UIScreen.mainScreen.scale) {
			layer.rasterizationScale = UIScreen.mainScreen.scale;
		}
		layer.shadowOpacity = 1.0;
		layer.shadowRadius = 5.25;

		layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
		layer.shouldRasterize = YES;
		layer.needsDisplayOnBoundsChange = YES;
	}
}

void PHVSetStanadardSplashLightningOuterGlow(CALayer *layer) {
	if (nil != layer) {
		if (1 < UIScreen.mainScreen.scale) {
			layer.rasterizationScale = UIScreen.mainScreen.scale;
		}
		layer.shadowOpacity = 0.85;
		layer.shadowRadius = 12.25;

		layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
		layer.shouldRasterize = YES;
		layer.needsDisplayOnBoundsChange = YES;
	}
}

void PHVSetNoMedalsShadow(CALayer *layer) {
	if (nil != layer) {
		if (1 < UIScreen.mainScreen.scale) {
			layer.rasterizationScale = UIScreen.mainScreen.scale;
		}
		layer.shadowOpacity = 0.7;
		layer.shadowRadius = 5.0;
		layer.shadowColor = UIColor.whiteColor.CGColor;
		layer.shadowOffset = CGSizeMake(0, 0);
		layer.shouldRasterize = YES;
	}
}

void PHVSetResultsTextShadow(CALayer *layer) {
	if (nil != layer) {
		layer.shadowOpacity = 1.0;
		layer.shadowRadius = 1.0;
		layer.shadowColor = UIColor.blackColor.CGColor;
		layer.shadowOffset = CGSizeMake(0.0f, -0.5f);
		layer.shouldRasterize = YES;
	}
}

void PHVSetResultsStartButtonTextShadow(CALayer *layer) {
	if (nil != layer) {
		layer.shadowOpacity = 1.0;
		layer.shadowRadius = 2.0;
		layer.shadowColor = UIColor.blackColor.CGColor;
		layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
		layer.shouldRasterize = YES;
	}
}

void PHVSetPlugScoreTextShadow(CALayer *layer) {
	if (nil != layer) {
		if (1 < UIScreen.mainScreen.scale) {
			layer.rasterizationScale = UIScreen.mainScreen.scale;
		}
		layer.shadowOpacity = 1.0;
		layer.shadowRadius = 0.0f;
		layer.shadowColor = UIColor.blackColor.CGColor;
		layer.shadowOffset = CGSizeMake(0.0f, -0.5f);
		layer.shouldRasterize = YES;
	}
}

void PHVSetPlugLocationShadow(CALayer *layer) {
	PHVSetPlugScoreTextShadow(layer);
	layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
}

void PHVSetPlugResultsTitleShadow(CALayer *layer) {
	PHVSetPlugScoreTextShadow(layer);
	layer.shadowRadius = 2.2f;
	layer.shadowOffset = CGSizeMake(0.0f, 1.5f);
}

#pragma mark - Gradients
CGGradientRef PHVTronShineGradient(void) {
	// CGGradientを生成する
    // 生成するためにCGColorSpaceと色データの配列が必要になるので
    // 適当に用意する
    CGGradientRef gradient;
    CGColorSpaceRef colorSpace;
    size_t num_locations = 4;
	
    CGFloat locations[4] = { 0.0f, 0.5999473f,0.6016387f,1.0f };
	
	CGFloat firstColor[4] = { 0.9999159f, 1.0f, 0.9999159f, 1.0f};
	CGFloat secondColor[4] = { 0.08820166f, 0.706655f, 0.9960559f, 1.0f};
	CGFloat thirdColor[4] = { 0.02771915f, 0.2333691f, 0.326708f, 1.0f};
	CGFloat fourthColor[4] = { 0.07115991f, 0.582153f, 0.9982802f, 1.0f};
    
	CGFloat components[16] = { firstColor[0], firstColor[1], firstColor[2], firstColor[3], secondColor[0], secondColor[1], secondColor[2], secondColor[3], thirdColor[0], thirdColor[1], thirdColor[2], thirdColor[3], fourthColor[0], fourthColor[1], fourthColor[2], fourthColor[3] };
    colorSpace = CGColorSpaceCreateDeviceRGB();
    gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, num_locations);
	
	CFRelease(colorSpace);
	
	return  (__bridge CGGradientRef)CFBridgingRelease((gradient));
}

CGGradientRef PHVBlueWhiteLabelGradient(void) {
	// CGGradientを生成する
    // 生成するためにCGColorSpaceと色データの配列が必要になるので
    // 適当に用意する
    CGGradientRef gradient;
    CGColorSpaceRef colorSpace;
    size_t num_locations = 2;
	
    CGFloat locations[2] = { 0.0f, 1.0f };
	CGFloat firstColor[4] = { 255.00f/255.00f, 255.00f/255.00f, 255.00f/255.00f, 250.0f/255.00f};
	CGFloat secondColor[4] = { 67.00f/255.00f, 193.00f/255.00f, 254.00f/255.00f, 250.0f/255.00f};
    CGFloat components[8] = { firstColor[0], firstColor[1], firstColor[2], firstColor[3], secondColor[0], secondColor[1], secondColor[2], secondColor[3] };
    colorSpace = CGColorSpaceCreateDeviceRGB();
    gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, num_locations);
	
	CFRelease(colorSpace);
	
	return  (__bridge CGGradientRef)CFBridgingRelease((gradient));
}

CGGradientRef PHVLightWhiteGlowGradient(void) {

    CGGradientRef gradient;
    CGColorSpaceRef colorSpace;
    size_t num_locations = 2;
	
    CGFloat locations[2] = { 0.0f, 1.0f };
	CGFloat firstColor[4] = { 255.00f/255.00f, 255.00f/255.00f, 255.00f/255.00f, 45.00f/100.00f};
	CGFloat secondColor[4] = { 255.00f/255.00f, 255.00f/255.00f, 255.00f/255.00f, 0.00f/100.00f};
    CGFloat components[8] = { firstColor[0], firstColor[1], firstColor[2], firstColor[3], secondColor[0], secondColor[1], secondColor[2], secondColor[3] };
    colorSpace = CGColorSpaceCreateDeviceRGB();
    gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, num_locations);
	
	CFRelease(colorSpace);
	
	return  (__bridge CGGradientRef)CFBridgingRelease((gradient));
}

#pragma mark - Targets
NSString *PHVLocalizedTitleForRankingTarget(PHVServerRankingTarget target,BOOL includeTargetArea) {
	
	NSMutableString *targetTitle = @"".mutableCopy;
	
	if (YES == includeTargetArea) {
		
		if (target & PHVServerRankingTargetGlobal) {
			targetTitle.append(NSLocalizedString(@"GLOBAL",@"グローバルランキング名"));
		} else if (target & PHVServerRankingTargetCountry) {
			targetTitle.append(NSLocalizedString(@"COUNTRY",@"カントリーランキング名"));
		} else if (target & PHVServerRankingTargetArea) {
			targetTitle.append(NSLocalizedString(@"AREA",@"エリアランキング名"));
		} else if (target & PHVServerRankingTargetLocal) {
			targetTitle.append(NSLocalizedString(@"LOCAL",@"ローカルランキング名"));
		}
		
	}
	
	if (targetTitle.length > 0) {
		targetTitle.append(kPHVTargetComponentSepearatorString);
	}
	
	if (target & PHVServerRankingTargetMonthly) {
		targetTitle.append(NSLocalizedString(@"MONTHLY",@"マンスリーランキング名"));
	} else if (target & PHVServerRankingTargetDaily) {
		targetTitle.append(NSLocalizedString(@"DAILY",@"デイリーランキング名"));
	}
	
	
	return targetTitle;
}

PHVServerRankingTarget PHVRankingTargetFromKey(NSString *key) {
	PHVServerRankingTarget target = 0;
	
	if (nil != key && key.length > 0) {
		NSNumberFormatter *unsignedIntegerNumberFormatter = [[NSNumberFormatter alloc] init];
		NSNumber *formatedNumber = [unsignedIntegerNumberFormatter numberFromString:key];
		target = formatedNumber.unsignedIntegerValue;
	}
	
	return target;
}

NSMutableOrderedSet *PHVMutableOrderedSetOfStandardTargets(void) {
	NSMutableOrderedSet *standardTargets = NSMutableOrderedSet.new;
	[standardTargets addObject:@(PHVServerRankingTargetGlobal | PHVServerRankingTargetDaily).stringValue];
	[standardTargets addObject:@(PHVServerRankingTargetGlobal | PHVServerRankingTargetMonthly).stringValue];
	[standardTargets addObject:@(PHVServerRankingTargetCountry | PHVServerRankingTargetDaily).stringValue];
	[standardTargets addObject:@(PHVServerRankingTargetCountry | PHVServerRankingTargetMonthly).stringValue];
	[standardTargets addObject:@(PHVServerRankingTargetArea | PHVServerRankingTargetDaily).stringValue];
	[standardTargets addObject:@(PHVServerRankingTargetArea | PHVServerRankingTargetMonthly).stringValue];
	[standardTargets addObject:@(PHVServerRankingTargetLocal | PHVServerRankingTargetDaily).stringValue];
	[standardTargets addObject:@(PHVServerRankingTargetLocal | PHVServerRankingTargetMonthly).stringValue];
	
	return standardTargets;
}

PHVServerRankingTarget PHVRankingTargetForIndex(NSUInteger index) {
	
	PHVServerRankingTarget target = 0;
	
	switch (index) {
		case 0:
			target = (PHVServerRankingTargetGlobal | PHVServerRankingTargetMonthly);
			break;
			
		case 1:
			target = (PHVServerRankingTargetGlobal | PHVServerRankingTargetDaily);
			break;
			
		case 2:
			target = (PHVServerRankingTargetCountry | PHVServerRankingTargetMonthly);
			break;
			
		case 3:
			target = (PHVServerRankingTargetCountry | PHVServerRankingTargetDaily);
			break;
			
		case 4:
			target = (PHVServerRankingTargetArea | PHVServerRankingTargetMonthly);
			break;
			
		case 5:
			target = (PHVServerRankingTargetArea | PHVServerRankingTargetDaily);
			break;
			
		case 6:
			target = (PHVServerRankingTargetLocal | PHVServerRankingTargetMonthly);
			break;
			
		case 7:
			target = (PHVServerRankingTargetLocal | PHVServerRankingTargetDaily);
			break;
			
		default:
			target = (PHVServerRankingTargetGlobal | PHVServerRankingTargetMonthly);
			break;
	}
	
	return target;
}


NSUInteger PHVIndexForRankingTarget(PHVServerRankingTarget target ) {
	NSUInteger index = 0;
	
	switch (target) {
		case (PHVServerRankingTargetGlobal | PHVServerRankingTargetMonthly):
			index = 0;
			break;
			
		case (PHVServerRankingTargetGlobal | PHVServerRankingTargetDaily):
			index = 1;
			break;
			
		case (PHVServerRankingTargetCountry | PHVServerRankingTargetMonthly):
			index = 2;
			break;
			
		case (PHVServerRankingTargetCountry | PHVServerRankingTargetDaily):
			index = 3;
			break;
			
		case (PHVServerRankingTargetArea | PHVServerRankingTargetMonthly):
			index = 4;
			break;
			
		case (PHVServerRankingTargetArea | PHVServerRankingTargetDaily):
			index = 5;
			break;
			
		case (PHVServerRankingTargetLocal | PHVServerRankingTargetMonthly):
			index = 6;
			break;
			
		case (PHVServerRankingTargetLocal | PHVServerRankingTargetDaily):
			index = 7;
			break;
			
		default:
			index = 0;
			break;
	}
	
	return index;
}

NSString *PHVTargetKeyFromIndex(NSUInteger index) {
	NSString *targetKey = nil;
	NSUInteger target = PHVRankingTargetForIndex(index);
	
	if (target > 0) {
		targetKey =  @(PHVRankingTargetForIndex(index)).stringValue;
	}
	
	return targetKey;
}



#pragma mark - Image Cache
CGFloat kPHVRankingItemCornerRadius = 4.0f;

UIImage *PHVCachedUserImageForURLMain(NSURL *url,imageLoadBlock completed) {
	return PHVCachedImageForURL(url,completed,dispatch_get_main_queue());
}

void PHVRemoveCachedUserImageForURL(NSURL *url) {
	
	NSError *removalError = nil;
	NSString *cachedImagePath = nil;
	
	if (nil != url) {
		if ((cachedImagePath = PHVCachedFileNamePathForURL(url))) {
			[[NSFileManager defaultManager] removeItemAtPath:cachedImagePath error:&removalError];
		}
	}
	
	if (nil != removalError) {
		NSLog(@"Could not remove cached image:%@",removalError);
		[UIAlertView showDebugAlertWithError:removalError];
	}
}

NSString *PHVCachedFileNamePathForURL(NSURL *url) {
	
	NSString *fileName = nil;
	NSString *absoluteURLString = nil;
	NSString *playerImagesCachePath = nil;
	NSString *baseURLString = nil;
	NSString *intermediateDirectories = nil;
	NSString *formattedFileNamePrefix = nil;
	NSString *cachedFileNamePath = nil;
	
	if (nil != url) {
		if ((playerImagesCachePath = PHVPlayerCacheDirectory())) {
			if ((absoluteURLString = url.absoluteString)) {
				if ([kPHVUserImageExtentionTypePNG isEqualToString:[absoluteURLString pathExtension]]) {
					if ((fileName = absoluteURLString.lastPathComponent)) {
						if ((baseURLString = url.host)) {
							NSRange rangeOfBaseURL = [absoluteURLString rangeOfString:baseURLString];
							if (rangeOfBaseURL.length > 0) {
								rangeOfBaseURL.length += rangeOfBaseURL.location;
								rangeOfBaseURL.location = 0;
								if ((intermediateDirectories = [absoluteURLString stringByReplacingCharactersInRange:rangeOfBaseURL withString:@""])) {
									if ((intermediateDirectories = [intermediateDirectories stringByDeletingLastPathComponent])) {
										if (intermediateDirectories.length > 0) {
											if ((formattedFileNamePrefix = [intermediateDirectories stringByReplacingOccurrencesOfString:kPHVURLPathSeparator withString:kPHVCachedImageComponentSeparator])) {
												if ((fileName = formattedFileNamePrefix.add(kPHVCachedImageComponentSeparator).add(fileName))) {
													if ((cachedFileNamePath = playerImagesCachePath.appendPath(fileName).appendExtention(kPHVUserImageExtentionTypePNG))) {
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
	
	return cachedFileNamePath;
}

UIImage *PHVCachedImageForURL(NSURL *url,imageLoadBlock completed,dispatch_queue_t callBackQueue) {
	
	NSString *cachedFileNamePath = nil;
	NSData *pngImageForCachedImage = nil;
	NSError *cachedDataReadError = nil;
	UIImage *cachedUserImage = nil;
	
	if (nil != url) {
		if ((cachedFileNamePath = PHVCachedFileNamePathForURL(url))) {
			if ((pngImageForCachedImage = [NSData dataWithContentsOfFile:cachedFileNamePath options:(NSDataReadingUncached | NSDataReadingMappedAlways) error:nil])) {
				if (pngImageForCachedImage.length > 0) {
					if ((cachedUserImage = [UIImage imageWithData:pngImageForCachedImage])) {
						if (nil != cachedUserImage) {
							return cachedUserImage;
						}
					}
				}
			} else if (nil != cachedDataReadError) {
				NSLog(@"Error Getting File: %@ \n Error: %@\n\n",cachedFileNamePath,cachedDataReadError);
			}
			
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
				dispatch_sync(UIDevice.PHVTransferQueue, ^{
					
					NSError *dataWritingError = nil;
					UIImage *recievedUIImageData = nil;
					NSData *responseData = nil;
					NSURLResponse *getUserImageResponse = nil;
					NSError *getRemoteImageError = nil;
					NSURLRequest *getUserImageRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:kPHVDefaultConnectionTimeout];
					
					if ((responseData = [NSURLConnection sendSynchronousRequest:getUserImageRequest returningResponse:&getUserImageResponse error:&getRemoteImageError])) {
						if ([kPHVUserImageMimeTypePNG isEqualToString:getUserImageResponse.MIMEType]) {
							if ((recievedUIImageData = [UIImage imageWithData:responseData])) {
								if ([responseData writeToFile:cachedFileNamePath options:NSDataWritingAtomic error:&dataWritingError]) {
								} else if (nil != dataWritingError) {
									NSLog(@"Error Writing Cache image data to disk: %@",dataWritingError);
								}
								
								if (NULL != completed) {
									if (NULL != callBackQueue) {
										if (callBackQueue != dispatch_get_current_queue()) {
											dispatch_sync(callBackQueue, ^{
												completed(recievedUIImageData);
											});
										} else {
											completed(recievedUIImageData);
										}
									} else {
										completed(recievedUIImageData);
									}
								}
							}
							
						} else {
							NSString *localizedImageWrongFormatErrorTitle = NSLocalizedString(@"User Picture Validation Failed...", @"サーバーから正しくない形式の写真（読み込む事の出来ない画像データ）が来る");
							NSString *localizedImageWrongFormatErrorString = NSLocalizedString(@"Image is wrong MIME Type\n Currently is %@ \n but should be %@. URL is:%@", @"サーバーから貰った不正な画像データについての「型」を表示する。これはデバッグの為のメッセージです。");
							NSString *formatedAndLocalizedImageWrongFormatErrorString = [NSString stringWithFormat:localizedImageWrongFormatErrorString,getUserImageResponse.MIMEType,kPHVUserImageMimeTypePNG,url];
							[UIAlertView showAlertWithContinueButton:localizedImageWrongFormatErrorTitle andMessage:formatedAndLocalizedImageWrongFormatErrorString];
							NSLog(@"%@",formatedAndLocalizedImageWrongFormatErrorString);
						}
					} else if (nil != getRemoteImageError) {
						NSLog(@"NSURL CONNECTION ERROR: %@",getRemoteImageError);
					}
				});
			});
		}
	}
	return UIImage.imageNamed(kPHVDefaultUserImageName);
}

#pragma mark - Errors
void PHVShowErrors(PHVServerResponseError error) {
	NSLog(@"\n");
	NSLog(@"PHVShowErrors:%d",error);
	if (PHVServerError01_InternalError & error) {
		NSLog(@"PHVServerError01_InternalError");
	}
	if (PHVServerError02_MissingKey & error) {
		NSLog(@"PHVServerError02_MissingKey");
	}
	if (PHVServerError03_MisingName & error) {
		NSLog(@"PHVServerError03_MisingName");
	}
	if (PHVServerError04_InvalidImageData & error) {
		NSLog(@"PHVServerError04_InvalidImageData");
	}
	if (PHVServerError05_InvalidiOSPushKey & error) {
		NSLog(@"PHVServerError05_InvalidiOSPushKey");
	}
	if (PHVServerError06_InvalidOrMissingPersistentID & error) {
		NSLog(@"PHVServerError06_InvalidOrMissingPersistentID");
	}
	if (PHVServerError08_InvalidOrMissingCountryCode & error) {
		NSLog(@"PHVServerError08_InvalidOrMissingCountryCode");
	}
	if (PHVServerError09_InvalidPlayTime & error) {
		NSLog(@"PHVServerError09_InvalidPlayTime");
	}
	if (PHVServerError12_TargetMissingLocality & error) {
		NSLog(@"PHVServerError12_TargetMissingLocality");
	}
	if (PHVServerError13_InvalidOrUnknownSNSSpecified & error) {
		NSLog(@"PHVServerError13_InvalidOrUnknownSNSSpecified");
	}
	if (PHVServerError14_CannotSetPushWithoutPushKey & error) {
		NSLog(@"PHVServerError14_CannotSetPushWithoutPushKey");
	}
	NSLog(@"\n");
}
#pragma mark - Item Visiblity
void PHVShowOrHideDebugItem(UIView * view) {
#ifdef DEBUG
	PHVShowItem(view);
#else
	PHVHideItem(view);
#endif
}

void PHVShowOrHideSimulatorDebugItem(UIView * view) {
#if DO_IPHONE_SIMULATOR
	PHVShowItem(view);
#else
	PHVHideItem(view);
#endif
}

void PHVShowItem(UIView * view) {
	if (nil != view) {
		view.hidden = NO;
		view.alpha = 1.0;
		view.userInteractionEnabled = YES;
		if ([view isKindOfClass:UIControl.class]) {
			UIControl *controll = (id)view;
			controll.enabled = YES;
		}
	}
}

void PHVHideItem(UIView * view) {
	if (nil != view) {
		view.hidden = YES;
		view.alpha = 0.0;
		view.userInteractionEnabled = NO;
		if ([view isKindOfClass:UIControl.class]) {
			UIControl *controll = (id)view;
			controll.enabled = NO;
		}
	}
}

#pragma mark - Objects/Categories
#pragma mark
@implementation  NSObject (PHVServerBasicResponse)

@dynamic status,error_code,error_message;

- (BOOL)ok {
	return (YES == [kPHVServerResponseOK isEqual:self.status]);
}

- (NSError *)phvError {
	NSError *returnError = nil;
	if (NO == self.ok) {
		NSDictionary *errorDescritption = nil;
		if (nil != self.error_message) {
			errorDescritption = @{NSLocalizedDescriptionKey : self.error_message};
		}
		returnError = [NSError errorWithDomain:NSCocoaErrorDomain code:self.error_code.integerValue userInfo:errorDescritption];
	}
	return returnError;
}

@end

@implementation Base64
@end

@implementation NSLocale (CountryCodes)

static NSString *countryCodeTableFilePath = nil;
static NSArray *validCountryCodes = nil;

static NSString *countryCodeMapTableFilePath = nil;
static NSDictionary *validPHVCountryCodeNameMap = nil;

static NSString *invalidCountryCodeMapTableFilePath = nil;
static NSDictionary *invalidPHVCountryCodeNameMap = nil;

+ (NSArray *)validPHVCountryCodes {
	
	if (nil == countryCodeTableFilePath) {
		countryCodeTableFilePath = [NSBundle.mainBundle pathForResource:kPHVValidCountryCodeTableFileName ofType:nil];
	}
	
	if (nil == validCountryCodes) {
		validCountryCodes = [NSArray arrayWithContentsOfFile:countryCodeTableFilePath];
	}
	
	return validCountryCodes;
}

+ (NSDictionary *)validPHVCountryCodeNameMap {
	if (nil == countryCodeMapTableFilePath) {
		countryCodeMapTableFilePath = [NSBundle.mainBundle pathForResource:kPHVValidCountryCodeMapFileName ofType:nil];
	}
	
	if (nil == validPHVCountryCodeNameMap) {
		validPHVCountryCodeNameMap = [NSDictionary dictionaryWithContentsOfFile:countryCodeMapTableFilePath];
	}
	
	return validPHVCountryCodeNameMap;
}

+ (NSDictionary *)invalidPHVCountryCodeMap {
	if (nil == invalidCountryCodeMapTableFilePath) {
		invalidCountryCodeMapTableFilePath = [NSBundle.mainBundle pathForResource:kPHVInvalidCountryCodeMapFileName ofType:nil];
	}
	
	if (nil == invalidPHVCountryCodeNameMap) {
		invalidPHVCountryCodeNameMap = [NSDictionary dictionaryWithContentsOfFile:invalidCountryCodeMapTableFilePath];
	}
	
	return invalidPHVCountryCodeNameMap;
}

+ (NSString *)localizedNameForCountryCode:(NSString *)isoCountryCode {
	NSString *localizedName = self.validPHVCountryCodeNameMap[isoCountryCode];
	return localizedName;
}

+ (PHVCountryCodeStatus)getCountryCodeStatus:(NSString *)countryCode andSubsituteCode:(NSString**)substitue {
	PHVCountryCodeStatus countryCodeStatus = PHVCountryCodeUnknown;
	
	NSArray *theInvalidCountryCodes = self.invalidPHVCountryCodeMap.allKeys;
	NSArray *theValidCountryCodes = self.validPHVCountryCodes;
	BOOL countryCodeIsValid = [theValidCountryCodes containsObject:countryCode];
	BOOL countryCodeIsInvalid = [theInvalidCountryCodes containsObject:countryCode];
	
	if (YES == countryCodeIsValid) {
		if (YES == countryCodeIsInvalid) {
			countryCodeStatus = PHVCountryCodeMapCorrupted;
		} else {
			countryCodeStatus = PHVCountryCodeValid;
		}
	} else {
		if (NO == countryCodeIsInvalid) {
			countryCodeStatus = PHVCountryCodeUnknown;
		} else {
			countryCodeStatus = PHVCountryCodeInvalid;
		}
	}
	
	if (PHVCountryCodeInvalid == countryCodeStatus) {
		NSString *substituteCode = self.invalidPHVCountryCodeMap[countryCode];
		if (NO == [kPHVUnrecognizedCountryCode isEqualToString:substituteCode]) {
			*substitue = substituteCode;
		}
	}
	
	return countryCodeStatus;
}


@end

@implementation NSData (Base64Encode)

- (Base64 *)base64 {
	
    const uint8_t* inputBytes = (const uint8_t*)self.bytes;
    NSUInteger byteLength = self.length;
	
    static unsigned char __base64CharTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
	
    NSMutableData* mutableBase64Data = [NSMutableData dataWithLength:((byteLength + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)mutableBase64Data.mutableBytes;
	
    NSUInteger currentByte = 0;
    for (currentByte=0; currentByte < byteLength; currentByte += 3) {
        NSInteger value = 0;
        NSUInteger bit = 0;
        for (bit = currentByte; bit < (currentByte + 3); bit++) {
            value <<= 8;
			
            if (bit < byteLength) {
                value |= (0xFF & inputBytes[bit]);
            }
        }
		
        NSInteger theIndex = (currentByte / 3) * 4;
        output[theIndex + 0] = __base64CharTable[(value >> 18) & 0x3F];
        output[theIndex + 1] = __base64CharTable[(value >> 12) & 0x3F];
        output[theIndex + 2] = (currentByte + 1) < byteLength ? __base64CharTable[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (currentByte + 2) < byteLength ? __base64CharTable[(value >> 0)  & 0x3F] : '=';
    }
	
	Base64 *base64String = (id)[[NSString alloc] initWithData:mutableBase64Data encoding:NSASCIIStringEncoding];
    return base64String;
}

@end

@implementation NSDate (RubyTime)

- (NSString *)commaSeparatedTimeWIthTimeZone:(NSString *)timezone {
	NSLocale *enUSPosixLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
	NSDateFormatter *commaSeparatedDateFormatter = [[NSDateFormatter alloc] init];
	commaSeparatedDateFormatter.dateFormat = @"[yyyy,MM,dd,H,mm,ss]";
	commaSeparatedDateFormatter.locale = enUSPosixLocale;
	commaSeparatedDateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:(nil == timezone ? @"GMT" : timezone)];
	
	NSString *formattedString = [commaSeparatedDateFormatter stringFromDate:self];
	return formattedString;
}

- (NSString *)commaSeparatedGMTTime {
	return [self commaSeparatedTimeWIthTimeZone:@"GMT"];
}

#import "NSMutableString+NewstepNSStringAdditions.h"

- (NSObject <NewstepRubyDate>*)rubyStyleDateWithTimeZone:(NSString *)timezone {
	NSMutableDictionary <NewstepRubyDate> *rubyStyleTime = @{}.mutableCopy;
	NSString *commaSeparatedTime = [self commaSeparatedTimeWIthTimeZone:timezone];
	NSArray *components = [commaSeparatedTime componentsSeparatedByString:@","];
		
	rubyStyleTime.year = components[0];
	rubyStyleTime.month = components[1];
	rubyStyleTime.day = components[2];
	rubyStyleTime.hour = components[3];
	rubyStyleTime.minute= components[4];
	rubyStyleTime.second= components[5];
	
	if ([rubyStyleTime.year hasPrefix:@"["]) {
		rubyStyleTime.year = rubyStyleTime.year.stringByRemovingFirstCharacter;
	}
	
	if ([rubyStyleTime.second hasSuffix:@"]"]) {
		rubyStyleTime.second = rubyStyleTime.second.stringByRemovingLastCharacter;
	}
	
	return rubyStyleTime;
}

- (NSObject <NewstepRubyDate>*)rubyStyleGMTDate {
	return [self rubyStyleDateWithTimeZone:@"GMT"];
}

@end
