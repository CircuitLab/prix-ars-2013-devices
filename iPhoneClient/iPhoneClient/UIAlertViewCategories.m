#import "UIAlertViewCategories.h"
#import <objc/runtime.h>

@implementation UIAlertView (NSError)

static const  void * const __nameKey = @"AlertNameKey";

- (NSString *)name { 
	return objc_getAssociatedObject(self, __nameKey);
}

- (void)setName:(NSString *)newName { 
	objc_setAssociatedObject(self,__nameKey, newName, OBJC_ASSOCIATION_RETAIN);
}


+ (UIAlertView *)showDebugAlertWithContinueButton:(NSString *)title andMessage:(NSString *)message {
#if DEBUG_MESSAGE > 1
	NSString *debugTitle = @"DEBUG::";
	if (nil != title) {
		debugTitle = [debugTitle stringByAppendingString:title];
	}
	
	NSString *debugMessage = @"MESSAGE::";
	if (nil != message) {
		debugMessage = [debugMessage stringByAppendingString:message];
	}
	
	 return [self showAlertWithContinueButton:[@"DEBUG::" stringByAppendingString:debugTitle] andMessage:[@"DEBUG MESSAGE::" stringByAppendingString:debugMessage]];
#endif
	return nil;
}

+ (UIAlertView *)showDebugAlertWithContinueButton:(NSString *)title message:(NSString *)message andAutoDismissWithDelayInSeconds:(CGFloat)dismissDelay {
#if DEBUG_MESSAGE > 1
	NSString *debugTitle = @"DEBUG::";
	if (nil != title) {
		debugTitle = [debugTitle stringByAppendingString:title];
	}
	
	NSString *debugMessage = @"MESSAGE::";
	if (nil != message) {
		debugMessage = [debugMessage stringByAppendingString:message];
	}
	
	return [self showAlertWithContinueButton:[@"DEBUG::" stringByAppendingString:debugTitle] message:[@"DEBUG MESSAGE::" stringByAppendingString:debugMessage] andAutoDismissWithDelayInSeconds:dismissDelay];
#endif
	return nil;
}


+ (UIAlertView *)showAlertWithError:(NSError *)error {
    return  [self showAlertWithError:error debug:NO];
}

+ (UIAlertView *)showAlertWithError:(NSError *)error debug:(BOOL)debug {
	NSString *description = error.localizedDescription;
	NSString *reason = error.localizedFailureReason;
	
	if (YES == debug) {
		if (nil != description) {
			description = [@"DEBUG::" stringByAppendingString:description];
		}
		if (nil != reason) {
			reason = [@"DEBUG::" stringByAppendingString:reason];
		}
	}
	
    return  [self showAlertWithContinueButton:description andMessage:reason];
}



+ (UIAlertView *)showDebugAlertWithError:(NSError *)error {
#if DEBUG_MESSAGE > 1
	return [self showAlertWithError:error debug:YES];
#endif
	return nil;
}

+ (UIAlertView *)showDebugAlertWithError:(NSError *)error andAutoDismissWithDelayInSeconds:(CGFloat)dismissDelay {
#if DEBUG_MESSAGE > 1
	return [self showAlertWithError:error andAutoDismissWithDelayInSeconds:dismissDelay];
#endif
	return nil;
}

+ (UIAlertView *)showAlertWithContinueButton:(NSString *)title andMessage:(NSString *)message {
    return [self showAlertWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) andOtherButtonTitles:nil];
}

+ (UIAlertView *)showAlertWithSingleButton:(NSString *)buttonTitle title:(NSString *)title andMessage:(NSString *)message {
    return [self showAlertWithTitle:title message:message delegate:nil cancelButtonTitle:buttonTitle andOtherButtonTitles:nil];
}

+ (UIAlertView *)showAlertWithTitleRetryButton:(NSString *)title delegate:(id)delegate andMessage:(NSString *)message {
    return [self showAlertWithTitle:title message:message delegate:delegate cancelButtonTitle:NSLocalizedString(@"Retry", nil) andOtherButtonTitles:nil];
}

+ (UIAlertView *)showAlertWithError:(NSError *)error andAutoDismissWithDelayInSeconds:(CGFloat)seconds {
	
	UIAlertView *alertView =  [self showAlertWithContinueButton:[error localizedDescription] andMessage:[[error userInfo] valueForKey:@"reason"]];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (uint)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[alertView dismissWithClickedButtonIndex:0 animated:YES];
	});
	
    return alertView;
}

+ (UIAlertView *)showAlertWithContinueButton:(NSString *)title message:(NSString *)message andAutoDismissWithDelayInSeconds:(CGFloat)seconds{

	UIAlertView *alertView =  [self showAlertWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) andOtherButtonTitles:nil]; ;
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (uint)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[alertView dismissWithClickedButtonIndex:0 animated:YES];
	});
	
    return alertView;	
}

+ (UIAlertView *)showAlertWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)buttonTitle andOtherButtonTitles:(NSString *)otherButtonTitles,... {
    
	__block UIAlertView *alert = nil;
	
#if SUPPRESS_ALERTS < 1
	va_list otherButtonsArgumentList;
    va_start(otherButtonsArgumentList, otherButtonTitles);
    
	alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:buttonTitle otherButtonTitles:otherButtonTitles,nil];
	
    @autoreleasepool {
		dispatch_async(dispatch_get_main_queue(), ^{
			[alert show];
		});
    }
    
    va_end(otherButtonsArgumentList);
#endif
	
	return alert;
}

+ (UIAlertView *)showAlertWithNetworkError {
	UIAlertView *alertView = nil;
    alertView =  [UIAlertView showAlertWithTitle:NSLocalizedString(@"Network Unavailable",@"ネットワーク接続は出来ない場合の、一般的なエラーメッセージタイトル") message:NSLocalizedString(@"Please check your network settings.",@"ネットワーク接続は出来ない場合の、一般的なエラーメッセージの内容") delegate:nil cancelButtonTitle:@"OK" andOtherButtonTitles:nil, nil];
	return alertView;
}

@end
