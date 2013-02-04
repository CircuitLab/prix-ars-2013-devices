//
//  PHVDynamicDataSupport.h
//  Battery Poop
//
//  Created by アンドレ on H.24/08/16.
//  Copyright (c) 平成24年 エルダ アンドレ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PHVDataTypes.h"

typedef id (^PHVDynamicDictionaryInitializer)(NSString *);
typedef NSString *(^stringAdder)(NSString *);
typedef void (^stringAdderMutable)(NSString *);
typedef UIImage *(^imageNamedAccessor)(NSString *);

@interface UIImage (PNGAndJPEG)
@property(readonly) NSData *png;
@property(readonly) NSData *jpeg;
@end

@interface UIImage (ImageNamed)
+ (imageNamedAccessor)imageNamed;
@end

@interface NSString (URLEncode)
- (NSString *)urlEncodedString;
@end

@interface NSMutableString (URLEncode)
- (void)urlEncode;
@end

@interface NSString (Adding)
- (stringAdder)add;
- (stringAdder)appendPath;
- (stringAdder)appendExtention;
@end

@interface NSMutableString (MutableAdding)
- (stringAdder)append;
@end

@interface NSString (MIMEAdditions)
+ (NSString*)MIMEBoundary;
+ (NSString*)multipartMIMEStringFromDictionary:(NSDictionary*)dict;
@end

@interface NSDictionary (PHVPOST) <PHVJSONURL>
+ (PHVDynamicDictionaryInitializer)initialize;
+ (PHVDynamicDictionaryInitializer)defrost;
- (BOOL)clearCache;
- (BOOL)cache;
- (id)post;
- (id)get;
@end

@interface NSMutableDictionary (PHVPOST)
- (BOOL)sync;
@end

@interface UIDevice (PHVTransferQueue)
+ (dispatch_queue_t)PHVTransferQueue;
+ (dispatch_group_t)PHVWiFiTransferGroup;
+ (dispatch_queue_t)PHVWiFiTransferQueue;
@end

