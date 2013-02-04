//
//  PHVDataTypes.h
//  Battery Poop
//
//  Created by アンドレ on H.24/08/16.
//  Copyright (c) 平成24年 エルダ アンドレ. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _PHVServerResponseError {
	PHVServerError01_InternalError = 1<<0,
	PHVServerError02_MissingKey = 1<<1,
	PHVServerError03_MisingName = 1<<2,
	PHVServerError04_InvalidImageData	= 1<<3,
	PHVServerError05_InvalidiOSPushKey = 1<<4,
	PHVServerError06_InvalidOrMissingPersistentID = 1<<5,
	PHVServerError07_TooEarlyToRecordPlayScore = 1<<6,
	PHVServerError08_InvalidOrMissingCountryCode = 1<<7,
	PHVServerError09_InvalidPlayTime = 1<<8,
	PHVServerError10_TargetMissingCountryCode = 1<<9,
	PHVServerError11_TargetMissingArea = 1<<10,
	PHVServerError12_TargetMissingLocality = 1<<11,
	PHVServerError13_InvalidOrUnknownSNSSpecified = 1<<12,
	PHVServerError14_CannotSetPushWithoutPushKey = 1<<13
} PHVServerResponseError;

typedef enum _PHVServerRankingTarget {
	//Area Targets
	PHVServerRankingTargetGlobal =	1<<0,
	PHVServerRankingTargetCountry = 1<<1,
	PHVServerRankingTargetArea = 1<<2,
	PHVServerRankingTargetLocal = 1<<3,
	PHVServerRankingTargetAllLocations = (PHVServerRankingTargetGlobal | PHVServerRankingTargetCountry | PHVServerRankingTargetArea | PHVServerRankingTargetLocal),
	//Time Targets
	PHVServerRankingTargetMonthly =	1<<5,
	PHVServerRankingTargetDaily =	1<<6,
	PHVServerRankingTargetMonthlyAndDaily = (PHVServerRankingTargetMonthly | PHVServerRankingTargetDaily),
	//All Targets
	PHVServerRankingTargetAll = (PHVServerRankingTargetAllLocations | PHVServerRankingTargetMonthlyAndDaily)
} PHVServerRankingTarget;

typedef enum _PHVCountryCodeStatus {
	PHVCountryCodeValid = 0,
	PHVCountryCodeInvalid = 1,
	PHVCountryCodeUnknown = 2,
	PHVCountryCodeMapCorrupted = INT_MAX
} PHVCountryCodeStatus;
UIKIT_EXTERN NSString *kPHVTwitterConnection;

@class Base64;

@protocol PHVServerKeyedPOST <NSObject>
@property(strong) NSString *key;
@property(strong) NSString *persistent_id;
@end

@protocol PHVJSONURL <NSObject>
@property(strong) NSURL *url;
@end

@protocol PHVNewUser <NSObject,PHVJSONURL,PHVServerKeyedPOST>

@property(strong) NSString *name;
@property(strong) NSNumber *push_medal;
@property(strong) NSNumber *os;
@property(strong) NSString *ios_push_key;
@property(strong) NSString *locale;
@property(strong) Base64 *user_picture;
@property(strong) NSNumber *use_dummy;

@end

@protocol PHVRanking <NSObject>

@property(strong) NSString *persistent_id;
@property(strong) NSNumber *rank;
@property(strong) NSString *name;
@property(strong) NSNumber *score;
@property(strong) NSString *country_code;
@property(strong) NSString *country_name;
@property(strong) NSString *area;
@property(strong) NSString *locality;
@property(strong) NSNumber *plug_time;
@property(strong) NSString *image_url;
@property(strong) NSString *date;

@end

@protocol PHVMedal <NSObject>

@property(strong) NSNumber *target;
@property(strong) NSNumber *medal_id;
@property(strong) NSNumber *rank;
@property(strong) NSString *name;
@property(strong) NSString *score;
@property(strong) NSString *country_code;
@property(strong) NSString *country_name;
@property(strong) NSString *area;
@property(strong) NSString *locality;
@property(strong) NSNumber *plug_time;
@property(strong) NSString *gmt_award_date;
@property(strong) NSString *gmt_play_time;
;

@end

@protocol PHVMedia <NSObject>

@property(strong) NSString *url;
@property(strong) NSNumber *video_id;
@property(strong) NSString *updated_at;
@property(readonly) NSDate *updated_at_date;

@end

@protocol PHVUserScore <NSObject,PHVJSONURL,PHVServerKeyedPOST>
@property(strong) NSString *name;
@property(strong) NSNumber *score;
@property(strong) NSString *country_code;
@property(strong) NSNumber *plug_time;
@property(strong) NSNumber *plug_latitude;
@property(strong) NSNumber *plug_longitude;
@property(strong) NSString *gmt_play_time;
@property(strong) NSString *image_url;
@end

//Compiler Trick
@interface PHVIndexedRanking : NSArray
- (NSObject <PHVRanking> *)objectAtIndexedSubscript:(NSUInteger)idx;
@end

//@interface PHVMutableIndexedRanking : PHVIndexedRanking
//- (NSObject <PHVRanking> *)objectAtIndexedSubscript:(NSUInteger)idx;
//@end

@interface PHVIndexedMedia : NSArray
- (NSObject <PHVMedia> *)objectAtIndexedSubscript:(NSUInteger)idx;
@end


//Compiler Trick
@interface PHVIndexedMedal : NSArray
- (NSObject <PHVMedal> *)objectAtIndexedSubscript:(NSUInteger)idx;
@end

//Compiler Trick
@interface PHVIndexedScore : NSArray
- (NSObject <PHVUserScore> *)objectAtIndexedSubscript:(NSUInteger)idx;
@end

@protocol PHVServerBasicResponseInternal <NSObject>
@property(strong) NSString *status;
@property(strong) NSString *error_message;
@property(strong) NSNumber *error_code;
@end

@protocol  PHVServerBasicResponse <NSObject>
@property(readonly) BOOL ok;
@property(readonly) NSError *phvError;
@end

@protocol PHVUserRegistrationResponse <NSObject,PHVServerBasicResponse>
@property(strong) NSString *user_name;
@property(strong) NSString *persistent_id;
@property(strong) NSString *image_url;
@property(readonly) UIImage *retreivedImage;
@end

@interface NSObject (PHVServerBasicResponse) <PHVServerBasicResponse,PHVServerBasicResponseInternal>
@property(readonly) BOOL ok;
@property(readonly) NSError *phvError;
@end

@protocol PHVUserScorePostResponse <NSObject,PHVServerBasicResponse>

@property(strong) PHVIndexedRanking <NSFastEnumeration> *rankings;
@property(strong) NSObject <PHVRanking>*self_ranking;

@end

@protocol PHVTargetRanking <NSObject>

@property(strong) PHVIndexedRanking <NSFastEnumeration> *ranking;
@property(strong) NSObject <PHVRanking>*self_ranking;

@end

@protocol PHVMediaList <NSObject,PHVServerBasicResponse>
@property(strong) PHVIndexedMedia *videos;
@end

@protocol PHVUserScorePost <NSObject,PHVJSONURL,PHVServerKeyedPOST>

@property(strong) NSNumber *score;
@property(strong) NSString *country_code;
@property(strong) NSString *country_name;
@property(strong) NSString *area;
@property(strong) NSString *locality;
@property(strong) NSNumber *plug_time;
@property(strong) NSNumber *plug_latitude;
@property(strong) NSNumber *plug_longitude;
@property(strong) NSString *gmt_play_time;

@end


@protocol PHVGetUserMedalsResponse <NSObject,PHVServerBasicResponse>
@property(strong) PHVIndexedMedal <NSFastEnumeration> *medals;
@end

@protocol PHVGetUserMedalsPost <NSObject,PHVJSONURL,PHVServerKeyedPOST>
@end

@protocol PHVGetUserRankingsPost <NSObject,PHVJSONURL,PHVServerKeyedPOST>

@property(strong) NSNumber *target;
@property(strong) NSString *country_code;
@property(strong) NSString *area;
@property(strong) NSString *locality;

@end

@protocol PHVGetTickerPost <NSObject,PHVJSONURL>
@end

@protocol PHVGetTickerResponse <NSObject,PHVServerBasicResponse>
@property(strong) PHVIndexedScore <NSFastEnumeration> *scores;
@end

@interface PHVKeyedTarget : NSDictionary
- (NSObject <PHVTargetRanking> *)objectForKeyedSubscript:(id) key;
- (void)setObject: (NSObject <PHVTargetRanking> *)thing forKeyedSubscript:(id<NSCopying>)key;
@end

@protocol PHVGetUserRankingsResponse  <NSObject,PHVServerBasicResponse>

@property(strong) PHVKeyedTarget <NSFastEnumeration> *rankings;

@end

@protocol PHVUserShare <PHVJSONURL,PHVServerKeyedPOST>

@property(strong) NSString *sns;
@property(strong) NSString *country_code;
@property(strong) NSString *country_name;
@property(strong) NSString *area;

@end

@protocol PHVSNSShareResponse <NSObject,PHVServerBasicResponse>
@end
