//
//  NSMutableString+NewstepNSStringAdditions.h
//  Queens Lab QR Code Reader
//
//  Created by エルダ アンドレ on H.24/03/30.
//  Copyright (c) 平成24年 エルダ アンドレ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSCharacterSet (EmojisAddition)
+ (NSCharacterSet *)utf16EmojiCharacterSet;
+ (NSCharacterSet*)utf8emojICharacterSet;
+ (NSCharacterSet*)emojiCharacterSet;
@end

@interface NSMutableString (NewstepNSStringAdditions)
- (void)replaceAllCharacters:(NSString *)characters withString:(NSString *)aString;
- (NSString *)immutableCopy;
- (void)removeFirstCharacter;
- (void)removeLastCharacter;
- (void)unCapitalizeString;
@end

@interface NSString (NewstepNSStringAdditions)
- (NSString *)stringByRemovingLastCharacter;
- (NSString *)stringByRemovingFirstCharacter;
- (NSString *)allEmojiCharacters;
- (BOOL)isUTF16Emoji;
- (BOOL)isEmoji;
- (BOOL)isNotBlessedEnglish;
- (BOOL)containsDiactric;
- (NSString *)unCapitalizedString;
- (NSDate *)isoDateWithTimeZoneAbbreviation:(NSString *)timeZone usingFormat:(NSString *)format;
- (NSDate *)isoGMTDate;
- (NSNumber *)number;
- (NSURL *)fileURL;
- (NSURL *)url;
@end

