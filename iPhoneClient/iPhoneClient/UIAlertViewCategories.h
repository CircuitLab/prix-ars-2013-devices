#import <UIKit/UIKit.h>

@interface UIAlertView (NSError)

@property(retain,atomic) NSString *name;

+ (UIAlertView *)showDebugAlertWithError:(NSError *)error;
+ (UIAlertView *)showDebugAlertWithError:(NSError *)error andAutoDismissWithDelayInSeconds:(CGFloat)dismissDelay;
+ (UIAlertView *)showAlertWithError:(NSError *)error;
+ (UIAlertView *)showDebugAlertWithContinueButton:(NSString *)title andMessage:(NSString *)message;
+ (UIAlertView *)showDebugAlertWithContinueButton:(NSString *)title message:(NSString *)message andAutoDismissWithDelayInSeconds:(CGFloat)dismissDelay;
+ (UIAlertView *)showAlertWithSingleButton:(NSString *)buttonTitle title:(NSString *)title andMessage:(NSString *)message;
+ (UIAlertView *)showAlertWithContinueButton:(NSString *)title andMessage:(NSString *)message;
+ (UIAlertView *)showAlertWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)buttonTitle andOtherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;
+ (UIAlertView *)showAlertWithTitleRetryButton:(NSString *)title delegate:(id)delegate andMessage:(NSString *)message;
+ (UIAlertView *)showAlertWithError:(NSError *)error andAutoDismissWithDelayInSeconds:(CGFloat)seconds;
+ (UIAlertView *)showAlertWithNetworkError;

@end
