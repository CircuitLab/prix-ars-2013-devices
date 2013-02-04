//
//  Category.h
//  Marlboro_Pro_App
//
//  Created by エルダ アンドレ on 11/07/11.
//  Copyright 2011 ユニバ株式会社 - エルダ アンドレ. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NewstepRepresentedObject <NSObject>
@property(retain,atomic) id representedObject;
- (const  void *)representedObjectUpdateContext;
@end

@interface NSObject (RepresentedObject) <NewstepRepresentedObject>
@property(retain,atomic) id representedObject;
- (const  void *)representedObjectUpdateContext;
@end

@interface NewstepRepresentedObjectArray : NSArray
- (NSObject <NewstepRepresentedObject> *)objectAtIndexedSubscript:(NSUInteger)idx;
@end

@interface NewstepRepresentedMutableObjectArray : NSMutableArray
- (NSObject <NewstepRepresentedObject> *)objectAtIndexedSubscript:(NSUInteger)idx;
@end

@interface UIViewController (Animations)
- (void)beginTransitionOfType:(NSString *)type subtype:(NSString *)subtype inView:(UIView *)view;
-(void)commitTransition;
@end

@interface UIView (Animations)
- (void)beginTransitionOfType:(NSString *)type subtype:(NSString *)subtype;
-(void)commitTransition;
@end

@interface UIViewController ()
//- (void)beginAppearanceTransition:(BOOL)isAppearing animated:(BOOL)animated;
//- (void)endAppearanceTransition;
@end
