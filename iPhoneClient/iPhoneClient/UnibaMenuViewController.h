//
//  UnibaMenuViewController.h
//  UnibaSocketIOClientExample
//
//  Created by mori koichiro on 12/02/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UnibaMenuViewController;


@protocol UnibaMenuViewControllerDelegate
- (void)menuViewControllerDidFinish:(UnibaMenuViewController *)controller;
@end

@interface UnibaMenuViewController : UIViewController <UITextFieldDelegate>
@property (assign) id <UnibaMenuViewControllerDelegate> delegate;
@property (retain) IBOutlet UITextField* hostInputText;
@property (retain) IBOutlet UITextField* portInputText;
//@property (retain) IBOutlet UITextField* roomInputText;
@property (retain) NSMutableDictionary* urlDictionary;
- (IBAction)done:(id)sender;
@end
