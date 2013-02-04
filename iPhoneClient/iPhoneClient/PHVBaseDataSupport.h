//
//  PHVBaseDataSupport.h
//  Battery Poop
//
//  Created by アンドレ on H.24/08/16.
//  Copyright (c) 平成24年 エルダ アンドレ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PHVDataTypes.h"

UIKIT_EXTERN NSString *kPHVServerResponseOK;
UIKIT_EXTERN NSString *kPHVServerResonseError;

UIKIT_EXTERN NSString *kPHVSecretAppKey;
UIKIT_EXTERN NSString *kPHVAppURL;

UIKIT_EXTERN NSString *kPHVNewUser;
UIKIT_EXTERN NSString *kPHVUserUpdate;
UIKIT_EXTERN NSString *kPHVPostScore;
UIKIT_EXTERN NSString *kPHVMedals;
UIKIT_EXTERN NSString *kPHVRankings;
UIKIT_EXTERN NSString *kPHVUserShare;
UIKIT_EXTERN NSString *kPHVMedia ;
UIKIT_EXTERN NSString *kPHVTicker;

UIKIT_EXTERN NSString *kPHVDailySyukei_DEBUG;
UIKIT_EXTERN NSString *kPHVMonthlySyukei_DEBUG;
UIKIT_EXTERN NSString *kPHVDeleteData_DEBUG;

UIKIT_EXTERN NSString *kPHVValidCountryCodeTableFileName;
UIKIT_EXTERN NSString *kPHVValidCountryCodeMapFileName;
UIKIT_EXTERN NSString *kPHVInvalidCountryCodeMapFileName;

UIKIT_EXTERN NSString *kPHVFlagNameSeparator;

UIKIT_EXTERN NSString *kPHVFlagNameSeparator;

UIKIT_EXTERN NSString *kPHVSNSShareActionSheetName;
UIKIT_EXTERN NSString *kPHVFacebookSNSDBName;
UIKIT_EXTERN NSString *kPHVTwitterSNSDBName;

UIKIT_EXTERN NSString *kPHVUnrecognizedCountryCode;

UIKIT_EXTERN NSString *kPHVJSONExtension;
UIKIT_EXTERN NSString *kPHVPlistExtension;
UIKIT_EXTERN NSString *kPHVCacheExtension;
UIKIT_EXTERN NSString *kPHVVideoMediaMimeType;
UIKIT_EXTERN NSString *kPHVVideoMediaExtention;
UIKIT_EXTERN NSString *kPHVVideoMediaFileComponenetSeparator;
UIKIT_EXTERN NSString *kPHVVideoMediaFileDateComponentReplacementSeparator;
UIKIT_EXTERN NSString *kPHVVideoMediaFileTimeComponentReplacementSeparator;
UIKIT_EXTERN NSString *kPHVVideoMediaFileDateSeparator;
UIKIT_EXTERN NSString *kPHVVideoMediaFileTimeSeparator;
UIKIT_EXTERN NSString *kPHVCacheName;
UIKIT_EXTERN NSString *kPHVPlayerCacheDirectoryName;
UIKIT_EXTERN NSString *kPHVMediaCacheDirectoryName;
UIKIT_EXTERN NSString *kPHVDownloadingMediaCacheDirectoryName;
UIKIT_EXTERN NSString *kPHVTargetComponentSepearatorString;

UIKIT_EXTERN NSString *kPHVUserImageMimeTypePNG;
UIKIT_EXTERN NSString *kPHVUserImageExtentionTypePNG;
UIKIT_EXTERN NSString *kPHVDefaultUserImageName;

UIKIT_EXTERN NSString *kPHVCachePayloadKey;

UIKIT_EXTERN NSString *kPHVFlagNamePrefix;
UIKIT_EXTERN NSString *kPHVURLPathSeparator;
UIKIT_EXTERN NSString *kPHVCachedImageComponentSeparator;

UIKIT_EXTERN NSString *kPHVTickerFileNamePrefix;

UIKIT_EXTERN NSTimeInterval kPHVDefaultConnectionTimeout;

@class Base64;

typedef void(^imageLoadBlock)(UIImage *);

UIImage *PHVCachedUserImageForURLMain(NSURL *url,imageLoadBlock); //dispatch_get_main_queue()
UIImage *PHVCachedImageForURL(NSURL *url,imageLoadBlock,dispatch_queue_t callBackQueue);

NSString *PHVCachedFileNamePathForURL(NSURL *url);
void PHVRemoveCachedUserImageForURL(NSURL *url);

FOUNDATION_EXPORT NSString *PHVPlayerCacheDirectory(void);
FOUNDATION_EXPORT NSString *PHVMediaCacheDirectory(void);
FOUNDATION_EXPORT NSString *PHVMediaTestDirectory(void);
FOUNDATION_EXPORT NSString *PHVMediaBuiltInVideosDirectory(void);
FOUNDATION_EXPORT NSString *PHVDownloadingMediaCacheDirectory(void);

PHVIndexedMedia *PHVMediaList(void);
NSUInteger PHVDownloadItemIndexOfItemWithIDInMedia(NSNumber *itemID,PHVIndexedMedia *videos);

NSString *PHVTemporaryFileLocationForMediaDownload(NSObject <PHVMedia>*downloadMedia);
NSString *PHVFileLocationForMediaDownload(NSObject <PHVMedia>*downloadMedia);
NSString *PHVFileNameForMediaDownload(NSObject <PHVMedia>*downloadMedia);

void PHVDownloadMediaItem(NSObject <PHVMedia>*item);
void PHVWaitForDownloadsToComplete(void);
void PHVSuspendDownloadsIfNecessary(void);
void PHVResumeDownloadsIfNecessary(void);

BOOL PHVDownloadIsClear(void);
void PHVSetDownloadIsClear(void);
void PHVSetDownloadHasBegun(void);

NSString *PHVUserContractSavePath(void);
NSString *PHVUserContractForLanguage(NSString *localeIdentifier);
NSString *PHVUserContractSavePathForLanguage(NSString *localeIdentifier);
NSURL *PHVUserContractDownloadURLForLanguage(NSString *localeIdentifier);

BOOL PHVShouldDownloadContractForLocale(NSString *localeIdentifier);
void PHVAttemptToUpdateUserContractForLocale(NSString *localeIdentifier);

UIKIT_EXTERN NSString *kPHVUserContractLocalSaveDirectoryName;// = @"PHVTerms";
UIKIT_EXTERN NSString *kPHVUserContractFilenameExtension;// = @"txt";
UIKIT_EXTERN NSString *kPHVUserContractDirectoryName;// = @"terms";
UIKIT_EXTERN NSString *kPHVAmericanEnglishLocaleIdentifier;// = @"en_US";
UIKIT_EXTERN NSString *kPHVDefaultBuiltInTermsOfUseFileName;// = @"PHV - TOYOTA - Plugin Championship - Terms of Use - ";
UIKIT_EXTERN NSString *kPHVCanadianFrenchLocaleIdentifier;//= @"fr_CA";
UIKIT_EXTERN NSString *kPHVFrenchLanguagedentifier;//= @"fr";
UIKIT_EXTERN NSString *kPHVEnglishLanguageIdentifier;// = @"en_US";
UIKIT_EXTERN uint kPHVStandardStringEncoding;// = NSUTF8StringEncoding;

NSString *PHVCleanedDateStringForSavingToFileSysytem(NSString * filenameDate);
NSString *PHVRestoredDateStringFromFilesystem(NSString *string);

NSString *PHVFlagFileNameForCountryCode(NSString *isoCountryCode);
UIImage *PHVFlagImageForCountryCode(NSString *isoCountryCode);

NSString *PHVTickerFlagFileNameForCountryCode(NSString *isoCountryCode);
UIImage *PHVTickerFlagImageForCountryCode(NSString *isoCountryCode);

UIKIT_EXTERN CGFloat kPHVRankingItemCornerRadius;
void PHVSetRegisterProfileCornerRadius(CALayer *layer);
void PHVSetRankingCornerRadius(CALayer *layer);
void PHVSetRankingPHVLogoShadow(CALayer *layer);
void PHVSetRankingShadow(CALayer *layer);
void PHVResultsPHVTitleShadow(CALayer *layer);
void PHVSetResultsTextShadow(CALayer *layer);
void PHVSetResultsStartButtonTextShadow(CALayer *layer);
void PHVSetStanadardMedalCircleTextGlow(CALayer *layer);
void PHVSetStanadardGlow(CALayer *layer);
void PHVSetStanadardSplashTitleGlow(CALayer *layer);
void PHVSetStanadardSplashTitleInnerGlow(CALayer *layer);
void PHVSetStanadardSplashCopyrightGlow(CALayer *layer);
void PHVSetStanadardSplashLightningGlow(CALayer *layer);
void PHVSetStanadardSplashLightningOuterGlow(CALayer *layer);
void PHVSetPlugScoreTextShadow(CALayer *layer);
void PHVSetPlugLocationShadow(CALayer *layer);
void PHVSetPlugResultsTitleShadow(CALayer *layer);
void PHVSetMedalShadow(CALayer *layer);
void PHVRemoveShadow(CALayer *layer);
void PHVSetRankingProfileShadow(CALayer *layer);
void PHVSetNoMedalsShadow(CALayer *layer);
void PHVShowOrHideDebugItem(UIView * view);
void PHVShowOrHideSimulatorDebugItem(UIView * view);
void PHVShowItem(UIView * view);
void PHVHideItem(UIView * view);

CGGradientRef PHVTronShineGradient(void);
CGGradientRef PHVBlueWhiteLabelGradient(void);
CGGradientRef PHVLightWhiteGlowGradient(void);

NSURL *PHVServerLocation(NSString *path);

UIKIT_EXTERN NSString *kPHVCountyCodeCanada;// = @"CA";
UIKIT_EXTERN NSString *kPHVCountyCodeAmerica;// = @"US";
UIKIT_EXTERN NSString *kPHVCountyCodeJapan;// = @"JP";
UIKIT_EXTERN NSString *kPHVToyotaJapanPromotionURL;// = @"/http://toyota.jp/priusphv/index.html";
UIKIT_EXTERN NSString *kPHVToyotaCanadaQuebecPromotionURL;// = @"http://www.apple.com/";
UIKIT_EXTERN NSString *kPHVToyotaCanadaPromotionURL;// = @"http://www.toyota.ca/toyota/en/vehicles/prius-plugin/overview/";
UIKIT_EXTERN NSString *kPHVToyotaAmericaPromotionURL;// = @"http://touch.toyota.com/prius-plug-in/";
UIKIT_EXTERN NSString *kPHVToyotaWorldPromotionURL;// = @"http://www.toyota-global.com/innovation/environmental_technology/plugin_hybrid/";

void PHVShowErrors(PHVServerResponseError error);

NSString *PHVTargetKeyFromIndex(NSUInteger index);
NSString *PHVLocalizedTitleForRankingTarget(PHVServerRankingTarget target,BOOL includeTargetArea);
NSMutableOrderedSet *PHVMutableOrderedSetOfStandardTargets(void);
PHVServerRankingTarget PHVRankingTargetFromKey(NSString *key);
PHVServerRankingTarget PHVRankingTargetForIndex(NSUInteger index);
NSUInteger PHVIndexForRankingTarget(PHVServerRankingTarget target );

@interface Base64 : NSString
@end

NSNumber *kPHVServerNoError(void);
Base64 *emptyBase64Image(void);

@interface NSData (Base64Encode)
@property(readonly) Base64 *base64;
@end

@interface NSDate ()
+ (NSDate *)date;
+ (NSDate *)distantFuture;
+ (NSDate *)distantPast;
@end

@protocol NewstepRubyDate <NSObject>

@property NSString *year;
@property NSString *month;
@property NSString *day;
@property NSString *hour;
@property NSString *minute;
@property NSString *second;

@end

@interface NSDate (RubyTime)
- (NSString *)commaSeparatedGMTTime;
- (NSString *)commaSeparatedTimeWIthTimeZone:(NSString *)timezone;

- (NSObject <NewstepRubyDate>*)rubyStyleGMTDate;
- (NSObject <NewstepRubyDate>*)rubyStyleDateWithTimeZone:(NSString *)timezone;
@end

@interface NSLocale (CountryCodes)
+ (NSArray *)validPHVCountryCodes;
+ (NSDictionary *)invalidPHVCountryCodeMap;
+ (NSDictionary *)validPHVCountryCodeNameMap;
+ (NSString *)localizedNameForCountryCode:(NSString *)isoCountryCode;
+ (PHVCountryCodeStatus)getCountryCodeStatus:(NSString *)countryCode andSubsituteCode:(NSString**)substitue;
@end
