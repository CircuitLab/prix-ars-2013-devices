//
//  iPhoneClientViewController.h
//  iPhoneClient
//
//  Created by Koichiro Mori on 2013/01/29.
//  Copyright (c) 2013年 uniba Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioSession.h>
#import "CharReceiver.h"
#import "UnibaSocketIOConnector.h"

#import "FSKSerialGenerator.h"
#include <ctype.h>

#import <AVFoundation/AVFoundation.h>

@class AudioSignalAnalyzer, FSKSerialGenerator, FSKRecognizer;
@interface iPhoneClientViewController : UIViewController <UITextFieldDelegate, CharReceiver>


@property (retain) UnibaSocketIOConnector * connector;
@property (strong) IBOutlet UITextField * serialTextField;
@property (strong) IBOutlet UILabel * panValueLabel;
@property (strong) IBOutlet UILabel *pitchValueLabel;
@property (strong) IBOutlet UITextView * consoleTextField;

@property (nonatomic, retain) AudioSignalAnalyzer* analyzer;
@property (nonatomic, retain) FSKSerialGenerator* generator;
@property (nonatomic, retain) FSKRecognizer* recognizer;

@property (strong) AVCaptureStillImageOutput *stillImageOutput;
@property (strong) AVCaptureSession *captureSession;

@property (strong) NSURL *lastImageAssetUrl;

-(void)initConnector;
- (IBAction)slideFirstSlider:(id)sender;
- (IBAction)slideSecondSlider:(id)sender;
- (IBAction)capture:(id)sender;
- (void) receiveSetUrlNotification:(NSNotification *)notification;

@end
