//
//  iPhoneClientViewController.m
//  iPhoneClient
//
//  Created by Koichiro Mori on 2013/01/29.
//  Copyright (c) 2013年 uniba Inc. All rights reserved.
//

#import "iPhoneClientViewController.h"
#import "AudioSignalAnalyzer.h"
#import "FSKSerialGenerator.h"
#import "FSKRecognizer.h"

@interface iPhoneClientViewController ()

@end

@implementation iPhoneClientViewController

@synthesize connector;
@synthesize serialTextField;
@synthesize panValueLabel;
@synthesize pitchValueLabel;
@synthesize consoleTextField;

@synthesize analyzer;
@synthesize generator;
@synthesize recognizer;

NSString * hostname = @"http://moxus.local";
NSString * portNum = @"3000";


- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveJsonNotification:) name:@"recivedGetMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNodeConnectionNotification:) name:@"recivedConnectionData" object:nil];
    
    self.connector = [[UnibaSocketIOConnector alloc] initWithUrl:hostname onPort:portNum onRoom:nil];
    
    [self.connector connectToUnicastServer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSetUrlNotification:) name:@"recivedSetUrlMessage" object:nil];
    
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
	if(session.inputIsAvailable){
		[session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
	}else{
		[session setCategory:AVAudioSessionCategoryPlayback error:nil];
	}
	[session setActive:YES error:nil];
	[session setPreferredIOBufferDuration:0.023220 error:nil];
    
	recognizer = [[FSKRecognizer alloc] init];
	[recognizer addReceiver:self];
    
	generator = [[FSKSerialGenerator alloc] init];
	[generator play];
    
	analyzer = [[AudioSignalAnalyzer alloc] init];
	[analyzer addRecognizer:recognizer];
    self.serialTextField.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"recivedGetMessage"];
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"recivedConnectionData"];
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"recivedSetUrlMessage"];
}


#pragma mark - スライダコントローラアクション
- (IBAction)slideFirstSlider:(id)sender {
    UISlider* slider = (UISlider*)sender;
    NSString* valueText = [NSString stringWithFormat:@"%f",slider.value];
    self.panValueLabel.text = valueText;

    NSDictionary *messageDictionary = [NSDictionary dictionaryWithObjectsAndKeys:valueText, @"value_id_1" , nil];
    [self.connector sendEventToUnicastServer:messageDictionary forEvent:@"slide_1"];
}

- (IBAction)slideSecondSlider:(id)sender {
    UISlider* slider = (UISlider*)sender;
    NSString* valueText = [NSString stringWithFormat:@"%f",slider.value];
    self.pitchValueLabel.text = valueText;
    
    NSDictionary *messageDictionary = [NSDictionary dictionaryWithObjectsAndKeys:valueText, @"value_id_2" , nil];
    [self.connector sendEventToUnicastServer:messageDictionary forEvent:@"slide_2"];
}

#pragma mark - Node Connection Notification メソッド
- (void) receiveNodeConnectionNotification:(NSNotification *)notification{
    if ([[notification name] isEqualToString:@"recivedConnectionData"]){
        self.consoleTextField.text = @"connected";
    }
}

#pragma mark - Json パース
- (void) receiveJsonNotification:(NSNotification *)notification{
    if ([[notification name] isEqualToString:@"recivedGetMessage"]){
        NSDictionary *statuses = [NSDictionary dictionaryWithDictionary:[notification userInfo]];
        if( statuses > 0 ){
            if( nil != [statuses objectForKey:@"r"] ){

            }
            self.consoleTextField.text = [self.consoleTextField.text stringByAppendingFormat:@"%@", @"EVNT:get"];
        }
    }
}

- (void) receiveSetUrlNotification:(NSNotification *)notification {
    NSDictionary *newUrl = [NSDictionary dictionaryWithDictionary:[notification userInfo]];
    NSString* hostString = [NSString stringWithFormat:@"http://%@",[newUrl valueForKey:@"host"]];
    NSString* portString = [newUrl valueForKey:@"port"];
    if( hostString != nil && portString != nil ){
        [self.connector setUrl:hostString onPort:portString onRoom:[newUrl valueForKey:@"room"]];

        [self.connector connectToUnicastServer];
    }
    NSLog(@"notifivation recived");
};


#pragma Softmodem 通信
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self.generator writeByte:0xff];
	[self.generator writeBytes:[textField.text UTF8String] length:[textField.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
	textField.text = @"";
    [self.serialTextField endEditing:YES];
	return YES;
}

- (void) receivedChar:(char)input
{
	if(isprint(input)){
		self.consoleTextField.text = [self.consoleTextField.text stringByAppendingFormat:@"%c", input];
	}
}

- (void)inputIsAvailableChanged:(BOOL)isInputAvailable
{
	NSLog(@"inputIsAvailableChanged %d",isInputAvailable);
	
	AVAudioSession *session = [AVAudioSession sharedInstance];
	
	[self.analyzer stop];
	[self.generator stop];
	
	if(isInputAvailable){
		[session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
		[self.analyzer record];
	}else{
		[session setCategory:AVAudioSessionCategoryPlayback error:nil];
	}
	[self.generator play];
}

@end
