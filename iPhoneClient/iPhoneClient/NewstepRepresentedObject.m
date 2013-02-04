//
//  Category.m
//  Marlboro_Pro_App
//
//  Created by エルダ アンドレ on 11/07/11.
//  Copyright 2011 ユニバ株式会社 - エルダ アンドレ. All rights reserved.
//

#import "NewstepRepresentedObject.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

@implementation NewstepRepresentedObjectArray : NSArray
- (NSObject <NewstepRepresentedObject> *)objectAtIndexedSubscript:(NSUInteger)idx{return nil;}
@end

@implementation NewstepRepresentedMutableObjectArray : NSMutableArray
- (NSObject <NewstepRepresentedObject> *)objectAtIndexedSubscript:(NSUInteger)idx{return nil;}
@end


@implementation NSObject (RepresentedObject)

static const  void * const ___RepresentedObjectUpdateContext = @"RepresentedObjectUpdateContext";

- (id)representedObject { 
	return objc_getAssociatedObject(self, ___RepresentedObjectUpdateContext);
}

- (void)setRepresentedObject:(id)object { 
	
	id currentAssociatedRepresentedObject = objc_getAssociatedObject(self, ___RepresentedObjectUpdateContext);
	
	if (nil != currentAssociatedRepresentedObject) {
		[currentAssociatedRepresentedObject removeObserver:self forKeyPath:@"hasVisibleChanges" context:(void *)self.representedObjectUpdateContext];
	}

	if (nil!=object) {
		[object addObserver:self forKeyPath:@"hasVisibleChanges" options:NSKeyValueObservingOptionNew context:(void *)self.representedObjectUpdateContext];
	}
	
	objc_setAssociatedObject(self,___RepresentedObjectUpdateContext, object, OBJC_ASSOCIATION_RETAIN);
}

- (const  void *)representedObjectUpdateContext { 
	return (const  void *)___RepresentedObjectUpdateContext;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context { 
	if (context == self.representedObjectUpdateContext) {
		NSLog(@"%ud : %@ - represented object contents update (unhandled)",(NSUInteger)self,NSStringFromClass(self.class));
	}
}

@end

@interface UIView ()
@property BOOL currentlyTransitioningForUBUIUpdate;
@property(strong) CATransition*currentTransitionForUBUIUpdate;
@end

@implementation UIView (Animations)

static const  void * const ___currentlyUpdatingContext = @"CurrentlyUpdatingContext";
static const  void * const ___currentTransitionContext = @"CurrentTransitionContext";
static const  void * const ___currentTransitionAnimationContext = @"CurrentTransitionAnimationContext";

- (BOOL)currentlyTransitioningForUBUIUpdate { 
	NSNumber *currentlyTransitioning = objc_getAssociatedObject(self,___currentlyUpdatingContext);
	return currentlyTransitioning.boolValue;
}

- (void)setCurrentlyTransitioningForUBUIUpdate:(BOOL)transitioning { 
	NSNumber *transitioningNumber = [NSNumber numberWithBool:transitioning];
	objc_setAssociatedObject(self,___currentlyUpdatingContext,transitioningNumber,OBJC_ASSOCIATION_RETAIN);
}

- (CATransition *)currentTransitionForUBUIUpdate { 
	CATransition *currentTransition = objc_getAssociatedObject(self,___currentTransitionContext);
	return currentTransition;
}

- (void)setCurrentTransitionForUBUIUpdate:(CATransition *)currentTransitionForUBUIUpdate { 
	objc_setAssociatedObject(self,___currentTransitionContext,currentTransitionForUBUIUpdate,OBJC_ASSOCIATION_RETAIN);
}

- (void)beginTransitionOfType:(NSString *)type subtype:(NSString *)subtype { 
	if (NO == self.currentlyTransitioningForUBUIUpdate && self.superview) {
		
		@synchronized(self) { 
			self.currentlyTransitioningForUBUIUpdate = YES;
		}
		
		[UIView beginAnimations:@"___currentTransitionAnimationContext" context:(void *)___currentTransitionAnimationContext];
		CATransition *transition = [[CATransition alloc] init];
		transition.type = (type ? type : @"fade");
		transition.subtype = subtype;
		transition.removedOnCompletion = YES;
		transition.timingFunction = [CAMediaTimingFunction functionWithName:@"easeInEaseOut"];
		
		@synchronized(self) { 
			self.currentTransitionForUBUIUpdate = transition;
//			[transition autorelease];
		}
	}
}

- (void)commitTransition { 
	if (YES == self.currentlyTransitioningForUBUIUpdate && nil != self.superview) {
		[self.layer  addAnimation:self.currentTransitionForUBUIUpdate forKey:@"___currentTransition"];
		[UIView commitAnimations];
		
		@synchronized(self) {
			self.currentTransitionForUBUIUpdate = nil;  
			self.currentlyTransitioningForUBUIUpdate = NO; 	
		}		
	}
}

@end

@interface UIViewController ()
@property(strong) UIView *cachedViewForUBUIAnimation;
@end

@implementation UIViewController (Animations)

static const  void * const ___currentlyCachedTransitionView = @"CurrentlyTransitionedCachedViewContext";

- (UIView *)cachedViewForUBUIAnimation { 
	UIView *aView = objc_getAssociatedObject(self,___currentlyCachedTransitionView);
	return aView;
}

- (void)setCachedViewForUBUIAnimation:(UIView *)aView { 
	objc_setAssociatedObject(self,___currentlyCachedTransitionView,aView,OBJC_ASSOCIATION_RETAIN);
}


- (void)beginTransitionOfType:(NSString *)type subtype:(NSString *)subtype inView:(UIView *)aView { 
	if (nil == aView) {
		aView = self.view;
	}	
	if (nil != aView) {
		self.cachedViewForUBUIAnimation = aView;
		[self.cachedViewForUBUIAnimation beginTransitionOfType:type subtype:subtype];				
	} 
}

-(void)commitTransition { 
	if (nil != self.cachedViewForUBUIAnimation) {
		[self.cachedViewForUBUIAnimation commitTransition];
		self.cachedViewForUBUIAnimation = nil;
	}
}

@end

