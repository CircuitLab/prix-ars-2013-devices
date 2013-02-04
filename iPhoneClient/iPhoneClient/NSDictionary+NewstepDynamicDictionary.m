//
//  NSDictionary+NewstepDynamicDictionary.m
//  Queens Lab QR Code Reader
//
//  Created by エルダ アンドレ on H.24/03/28.
//  Copyright (c) 平成24年 エルダ アンドレ. All rights reserved.
//

#import "NSDictionary+NewstepDynamicDictionary.h"
#import "NSMutableString+NewstepNSStringAdditions.h"
#import "NewstepRepresentedObject.h"
#import <objc/runtime.h>

id newstep_dynamic_getter(id self, SEL _cmd);
void newstep_dynamic_setter(id self, SEL _cmd, NSObject* newValue);

@implementation NSDictionary (NewstepDynamicDictionary)

id newstep_dynamic_getter(NSObject *self, SEL _cmd) { 
	
	id returnValue = nil;
	NSString *method = NSStringFromSelector(_cmd);

    if ([method isEqualToString:@"_doZombieMe"]) {
        return nil;
    }
	
	if ((returnValue = [self valueForKey:method])) {
		return returnValue;
	}
	
	if (nil != self.representedObject) {
		if ([self.representedObject respondsToSelector:_cmd]) {
			returnValue = [self.representedObject valueForKey:method];
		}
	}
	
    return returnValue;
}

void newstep_dynamic_setter(NSObject *self, SEL _cmd, NSObject* newValue) {
	
    NSMutableString *key = [NSMutableString stringWithString:NSStringFromSelector(_cmd)];
	if ([key hasPrefix:@"set"]) {
		[key deleteCharactersInRange:NSMakeRange(0, 3)];
		[key unCapitalizeString];
		if ([key hasSuffix:@":"]) {
			[key removeLastCharacter];
		}
		
		if (nil != self.representedObject) {
			if ([self.representedObject respondsToSelector:_cmd]) {
//				if ([@"date" isEqualToString:key]) {
//					NSLog(@"setting date on 0x%x - %@",(NSUInteger)self,NSStringFromClass(self.class));
//				}
				[self.representedObject setValue:newValue forKey:key];
				return;
			}
		}
		
		[self setValue:newValue forKey:key];
	}
}


+ (BOOL)resolveInstanceMethod:(SEL)aSEL {
	
    NSString *method = NSStringFromSelector(aSEL);
    if ([method hasPrefix:@"set"])  {
        class_addMethod([self class], aSEL, (IMP) newstep_dynamic_setter, "v@:@");
        return YES;
    } else {
        class_addMethod([self class], aSEL, (IMP) newstep_dynamic_getter, "@@:");
        return YES;
    }
	
    return [super resolveInstanceMethod:aSEL];
}
@end
