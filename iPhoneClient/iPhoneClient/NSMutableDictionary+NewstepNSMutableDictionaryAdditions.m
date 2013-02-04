//
//  NSMutableDictionary+NewstepNSMutableDictionaryAdditions.m
//  Queens Lab QR Code Reader
//
//  Created by エルダ アンドレ on H.24/03/30.
//  Copyright (c) 平成24年 エルダ アンドレ. All rights reserved.
//

#import "NSMutableDictionary+NewstepNSMutableDictionaryAdditions.h"

@implementation NSMutableDictionary (NewstepNSMutableDictionaryAdditions)

- (NSDictionary *)immutableCopy { 
	return [NSDictionary dictionaryWithDictionary:self];
}

@end
