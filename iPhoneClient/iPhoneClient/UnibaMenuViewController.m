//
//  UnibaMenuViewController.m
//  UnibaSocketIOClientExample
//
//  Created by mori koichiro on 12/02/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UnibaMenuViewController.h"

@implementation UnibaMenuViewController
@synthesize delegate = _delegate;
@synthesize hostInputText = _hostInputText;
//@synthesize roomInputText = _roomInputText;
@synthesize portInputText = _portInputText;
@synthesize urlDictionary = _urlDictionary;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    
    if( nil != [[NSUserDefaults standardUserDefaults] objectForKey:@"kSocketIOHostName"] ){
        _hostInputText.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"kSocketIOHostName"];
    }else{
        _hostInputText.placeholder = @"ホストを入力してください";
    }
    _hostInputText.delegate = self;
    _hostInputText.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    _hostInputText.returnKeyType = UIReturnKeyGo;
    _hostInputText.clearButtonMode = UITextFieldViewModeAlways;
    
    if( nil != [[NSUserDefaults standardUserDefaults] objectForKey:@"kSocketIOPortName"] ){
        _portInputText.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"kSocketIOPortName"];
    }else{
        _portInputText.placeholder = @"ポート番号を入力してください";
    }
    _portInputText.delegate = self;
    _portInputText.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    _portInputText.returnKeyType = UIReturnKeyGo;
    _portInputText.clearButtonMode = UITextFieldViewModeAlways;
    
//    if( nil != [[NSUserDefaults standardUserDefaults] objectForKey:@"kSocketIORoomName"] ){
//        _portInputText.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"kSocketIORoomName"];
//    }else {
//        _roomInputText.placeholder = @"ルームIDを入力してください";
//    }
//    _roomInputText.delegate = self;
//    _roomInputText.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
//    _roomInputText.returnKeyType = UIReturnKeyGo;
//    _roomInputText.clearButtonMode = UITextFieldViewModeAlways;

    
//    _urlDictionary = [[NSMutableDictionary alloc] initWithCapacity:3];
    
    _urlDictionary = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    [_urlDictionary setValue:_hostInputText.text forKey:@"host"];
    
    [_urlDictionary setValue:_portInputText.text forKey:@"port"];
    
    [_urlDictionary setValue:@"/uplook" forKey:@"room"];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)done:(id)sender {
    [self.delegate menuViewControllerDidFinish:self];
    NSLog(@"called done in menuviewcontroller");
    
    dispatch_async( dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"recivedSetUrlMessage" object:self userInfo:_urlDictionary];
    });
    [[self presentingViewController] dismissModalViewControllerAnimated:YES];
}

#pragma mark - ホスト名入力時　デリゲート　メソッド
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if( [textField isEqual:_hostInputText] ){
        [_hostInputText resignFirstResponder];
        
    }else if( [textField isEqual:_portInputText] ){
        [_portInputText resignFirstResponder];
        
    }
//    else if( [textField isEqual:_roomInputText] ){
//        
//        [_roomInputText resignFirstResponder];
//    }
    
    [_urlDictionary setValue:_hostInputText.text forKey:@"host"];
    
    [_urlDictionary setValue:_portInputText.text forKey:@"port"];
    
    [_urlDictionary setValue:@"/uplook" forKey:@"room"];
    
    [[NSUserDefaults standardUserDefaults] setValue:_hostInputText.text forKey:@"kSocketIOHostName"];
    [[NSUserDefaults standardUserDefaults] setValue:_portInputText.text forKey:@"kSocketIOPortName"];
//    [[NSUserDefaults standardUserDefaults] setValue:_roomInputText.text forKey:@"kSocketIORoomName"];
    
    NSLog(@"text btton exit");
    
    return YES;
}


@end
