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
@property NSString *udid;
@property NSString *timestamp;
@property NSString *compass;
//@property NSString *x;
@property NSString *angle;
@property NSString *battery;

@end

@class AudioSignalAnalyzer, FSKSerialGenerator, FSKRecognizer;
@interface iPhoneClientViewController : UIViewController <UITextFieldDelegate, CharReceiver, CLLocationManagerDelegate>


@property (retain) UnibaSocketIOConnector * connector;
@property (strong) IBOutlet UITextField * serialTextField;
@property (strong) IBOutlet UILabel * panValueLabel;
@property (strong) IBOutlet UILabel *pitchValueLabel;
@property (strong) IBOutlet UITextView * consoleTextField;
@property (strong) IBOutlet UILabel *compassDirectionLabel;

@property (nonatomic, retain) AudioSignalAnalyzer* analyzer;
@property (nonatomic, retain) FSKSerialGenerator* generator;
@property (nonatomic, retain) FSKRecognizer* recognizer;

@property (strong) AVCaptureStillImageOutput *stillImageOutput;
@property (strong) AVCaptureSession *captureSession;

@property (strong) NSURL *lastImageAssetUrl;

@property (strong) CLLocationManager *locationManager;
@property (assign) CLLocationDirection currentDirection;

@property double longtitude, latitude;
@property int stepDirection, currentAngle;

@property (strong) NSTimer *timer;

@property (assign) BOOL isBusy;

-(void)initConnector;
- (IBAction)slideFirstSlider:(id)sender;
- (IBAction)slideSecondSlider:(id)sender;
- (IBAction)capture:(id)sender;
- (void) receiveSetUrlNotification:(NSNotification *)notification;

- (NSString*)buildPacket:(int)x y:(int)y;
- (UInt8 *)buildPacketUint8:(int)x y:(int)y;

- (void)emitStatus:(NSTimer*)timer;

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading;
- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager;

@end
