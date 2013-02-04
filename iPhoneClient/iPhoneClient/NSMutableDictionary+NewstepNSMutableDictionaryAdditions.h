//
//  NSMutableDictionary+NewstepNSMutableDictionaryAdditions.h
//  Queens Lab QR Code Reader
//
//  Created by エルダ アンドレ on H.24/03/30.
//  Copyright (c) 平成24年 エルダ アンドレ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (NewstepNSMutableDictionaryAdditions)
- (NSDictionary *)immutableCopy;
@end
