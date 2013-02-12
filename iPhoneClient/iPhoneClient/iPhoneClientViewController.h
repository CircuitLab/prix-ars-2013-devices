//
//  iPhoneClientViewController.h
//  iPhoneClient
//
//  Created by Koichiro Mori on 2013/01/29.
//  Copyright (c) 2013年 uniba Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHVDynamicDataSupport.h"
#import <AVFoundation/AVAudioSession.h>
#import "CharReceiver.h"
#import "UnibaSocketIOConnector.h"

#import "FSKSerialGenerator.h"
#include <ctype.h>

#import <AVFoundation/AVFoundation.h>

#import <CoreLocation/CoreLocation.h>

@protocol IphoneClientRequest <PHVJSONURL>
@property Base64 *photo;
@property NSString *timestamp;
@property NSString *x;
@property NSString *y;
@property NSString *battery;

@end

@class AudioSignalAnalyzer, FSKSerialGenerator, FSKRecognizer;
@interface iPhoneClientViewController : UIViewController <UITextFieldDelegate, CharReceiver, CLLocationManagerDelegate>


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

@property (strong) CLLocationManager *locationManager;

@property double longtitude, latitude;
@property float currentX, currentY;

-(void)initConnector;
- (IBAction)slideFirstSlider:(id)sender;
- (IBAction)slideSecondSlider:(id)sender;
- (IBAction)capture:(id)sender;
- (void) receiveSetUrlNotification:(NSNotification *)notification;
- (NSString*)buildPacket:(float)x y:(float)y;

@end
