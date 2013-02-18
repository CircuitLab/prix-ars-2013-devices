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
#import <AssetsLibrary/AssetsLibrary.h>
#import "NSMutableString+NewstepNSStringAdditions.h"
#import "PHVBaseDataSupport.h"

@interface iPhoneClientViewController ()

@end

@implementation iPhoneClientViewController

@synthesize connector;
@synthesize serialTextField;
@synthesize panValueLabel;
@synthesize pitchValueLabel;
@synthesize consoleTextField;
@synthesize compassDirectionLabel;

@synthesize analyzer;
@synthesize generator;
@synthesize recognizer;

@synthesize stillImageOutput;
@synthesize captureSession;

@synthesize lastImageAssetUrl;

@synthesize locationManager;

@synthesize timer;

NSString * hostname = @"moxus.local";
NSString * portNum = @"3000";

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (nil == locationManager) {
        locationManager = [[CLLocationManager alloc] init];
    }
    locationManager.delegate = self; // デリゲート設定
    locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 位置測定の望みの精度を設定
    locationManager.distanceFilter = kCLDistanceFilterNone; // 位置情報更新の目安距離
    locationManager.headingFilter = kCLHeadingFilterNone;
    
    self.currentX = 0;
    self.currentY = 0;
    
    [self updateCurrentCoordinate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveJsonNotification:) name:@"recivedGetMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recivedTakeNotifivation:) name:@"recivedTakeMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNodeConnectionNotification:) name:@"recivedConnectionData" object:nil];
    
    self.connector = [[UnibaSocketIOConnector alloc] initWithUrl:[NSString stringWithFormat:@"%@",hostname ] onPort:portNum onRoom:@"/uplook"];
    
    if( @"" == hostname ){
        [self.connector connectToUnicastServer];
    } else {
        [self.connector disconnect];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSetUrlNotification:) name:@"recivedSetUrlMessage" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveJsonNotification:) name:@"recivedViewPointMessage" object:nil];
    
    
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
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:300.0f target:self selector:@selector(emitStatus:) userInfo:nil repeats:YES ];
    [self.timer fire];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"recivedViewPointMessage"];
    [self.timer  invalidate];
}


#pragma mark - スライダコントローラアクション
- (IBAction)slideFirstSlider:(id)sender {
    UISlider* slider = (UISlider*)sender;
    NSString* valueText = [NSString stringWithFormat:@"%f",slider.value];
    self.panValueLabel.text = valueText;
    self.currentX = [valueText floatValue];

    NSDictionary *messageDictionary = [NSDictionary dictionaryWithObjectsAndKeys:valueText, @"value_id_1" , nil];
    [self.connector sendEventToUnicastServer:messageDictionary forEvent:@"slide_1"];
    
    [self sendGenerator: [self buildPacketUint8:self.currentX y:self.currentY] ];
}

- (IBAction)slideSecondSlider:(id)sender {
    UISlider* slider = (UISlider*)sender;
    NSString* valueText = [NSString stringWithFormat:@"%f",slider.value];
    self.pitchValueLabel.text = valueText;
    self.currentY = [valueText floatValue];
    
    NSDictionary *messageDictionary = [NSDictionary dictionaryWithObjectsAndKeys:valueText, @"value_id_2" , nil];
    [self.connector sendEventToUnicastServer:messageDictionary forEvent:@"slide_2"];
    
    [self sendGenerator: [self buildPacketUint8:self.currentX y:self.currentY] ];
}

#pragma mark - Node Connection Notification メソッド
- (void) receiveNodeConnectionNotification:(NSNotification *)notification{
    if ([[notification name] isEqualToString:@"recivedConnectionData"]){
        [self updateCurrentCoordinate];
        self.consoleTextField.text = @"connected";
        NSMutableDictionary *helloDict = [NSMutableDictionary dictionary];
        
        [helloDict setValue:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"udid"];
        [helloDict setValue:[NSNumber numberWithDouble:self.latitude] forKey:@"latitude"];
        [helloDict setValue:[NSNumber numberWithDouble:self.longtitude] forKey:@"longtitude"];
        [connector sendEventToUnicastServer:helloDict forEvent:@"hello"];
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
    } else if([[notification name] isEqualToString:@"recivedViewPointMessage"]){
        NSDictionary *position = [NSDictionary dictionaryWithDictionary:[notification userInfo]];
        if( position > 0 ){
            
            if( nil != [position objectForKey:@"x"] ) {
                self.currentX = [[position objectForKey:@"x"] floatValue];
                self.pitchValueLabel.text = [NSString stringWithFormat:@"%f",self.currentX];
                
            }
            if( nil != [position objectForKey:@"y"] ) {
                self.currentY = [[position objectForKey:@"y"] floatValue];
                self.pitchValueLabel.text = [NSString stringWithFormat:@"%f",self.currentY];
            }
            
            [self sendGenerator: [self buildPacketUint8:self.currentX y:self.currentY] ];
        }
    } else if([[notification name] isEqualToString:@"recivedTakeMessage"]){
            [self takePhoto];
    }
}

-(void) recivedTakeNotifivation:(NSNotification *)notification {
    if([[notification name] isEqualToString:@"recivedTakeMessage"]){
        [self takePhoto];
    }
}

- (void) receiveSetUrlNotification:(NSNotification *)notification {
    NSDictionary *newUrl = [NSDictionary dictionaryWithDictionary:[notification userInfo]];
    NSString* hostString = [NSString stringWithFormat:@"http://%@",[newUrl valueForKey:@"host"]];
    NSString* portString = [newUrl valueForKey:@"port"];
    hostname = [newUrl valueForKey:@"host"];
    portNum = portString;
    if( hostString != nil && portString != nil ){
        [self.connector setUrl:hostString onPort:portString onRoom:[newUrl valueForKey:@"room"]];

        [self.connector connectToUnicastServer];
    }
    NSLog(@"notifivation recived");
};


#pragma mark Softmodem 通信
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	//[self.generator writeByte:0xff];
    int len;
    len = [textField.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    [self.generator writeByte:112];
	[self.generator writeBytes:[textField.text UTF8String] length:len];
    [self.generator writeByte:13];
	textField.text = @"";
    [self.serialTextField endEditing:YES];
	return YES;
}

- (void)sendGenerator:( UInt8* )string_ {
    int len;
    //len = [string_ lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    
    [self.generator writeByte:0xff];
    [self.generator writeBytes:string_ length:7];
    
   // NSLog(@"%@",string_);
}

-(NSString*)buildPacket:(float)x y:(float)y {
    NSString *str = @"XXA";
    
    unsigned char xValue_high;
    unsigned char xValue_low;
    unsigned char yValue_high;
    unsigned char yValue_low;
    
    xValue_high = (unsigned char)((int)(x*1024) >> 8 );
    xValue_low = (unsigned char)((int)(x*1024) & 255 );
    yValue_high = (unsigned char)((int)(y*1024) >> 8 );
    yValue_low = (unsigned char)((int)(y*1024) & 255 );
    
    str = [NSString stringWithFormat:@"%@%c%c%c%c___%d_%d", str, xValue_high, xValue_low, yValue_high, yValue_low, (int)(x*1024), (int)(y*1024) ];
    return str;
}

-(UInt8 *)buildPacketUint8:(float)x y:(float)y {
    UInt8 str[7];
    str[0] = 'X';
    str[1] = 'X';
    str[2] = 'A';
    
    str[3] = (UInt8)((int)(x*1024) >> 8 );
    str[4] = (UInt8)((int)(x*1024) & 255 );
    str[5] = (UInt8)((int)(y*1024) >> 8 );
    str[6] = (UInt8)((int)(y*1024) & 255 );
    return str;
}

- (void) receivedChar:(char)input
{
	if(isprint(input)){
		self.consoleTextField.text = [self.consoleTextField.text stringByAppendingFormat:@"%c", input];
	}
}

#pragma mark Get Coordinate
- (void)updateCurrentCoordinate {
    [locationManager startUpdatingLocation];
    [locationManager startUpdatingHeading];
    
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
         [locationManager stopUpdatingHeading];
         [locationManager stopUpdatingLocation];
     });
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    self.longtitude = newLocation.coordinate.longitude;
    self.latitude = newLocation.coordinate.latitude;
    [locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [locationManager stopUpdatingLocation];
    NSLog(@"Fail to update location data...");
}

#pragma mark Camera
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

-(void) takePhoto {
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    AVCaptureInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (videoInput) {
        
        // セッション初期化
        self.captureSession = [[AVCaptureSession alloc] init];
        [self.captureSession addInput:videoInput];
        [self.captureSession beginConfiguration];
        self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
        [self.captureSession commitConfiguration];
        
        
        // ビデオの解像度 High
        if ([self.captureSession canSetSessionPreset:AVCaptureSessionPresetHigh]) {
            self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
        }
        
        // AVCaptureStillImageOutputで静止画出力を作る
        self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        AVVideoCodecJPEG, AVVideoCodecKey, nil];
        self.stillImageOutput.outputSettings = outputSettings;
        
        // セッションに出力を追加
        if ( [self.captureSession canAddOutput:self.stillImageOutput] ){
            [self.captureSession addOutput:self.stillImageOutput];
            
    //        // プレビュー表示
    //        AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
    //        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    //        [previewLayer setFrame:CGRectMake(200, 600, 40, 30)];
    //        
    //        [self.view.layer addSublayer:previewLayer];
            
            // セッション開始
            [self.captureSession startRunning];
            
            // コネクションを検索
            AVCaptureConnection *videoConnection = nil;
            for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
                for (AVCaptureInputPort *port in [connection inputPorts]) {
                    if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                        videoConnection = connection;
                        break;
                    }
                }
                if (videoConnection)
                    break;
            }
            
            // 静止画をキャプチャする
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{// Delay execution of my block for 2 seconds.

                [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                                   completionHandler:
                 ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
                     if (imageSampleBuffer != NULL) {
                         // キャプチャしたデータを取る
                         NSData *data = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
                         
                         ///////////////////// using data here
                         
                         UIImage *image = [UIImage imageWithData:data];
                         ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                         [library writeImageToSavedPhotosAlbum:image.CGImage
                                                   orientation:image.imageOrientation
                                               completionBlock:^(NSURL *assetURL, NSError *error) {
                                                   self.lastImageAssetUrl = assetURL;
                                                   
                                                   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
                                                       [self sendImageData];
                                                   });
                                               }];
                        
                         /////////////////////
                         
                     }
                 }];
                
                [self.captureSession stopRunning];
                
            });
        }
    } else {
        NSLog(@"ERROR:%@", error);
    }
}


- (IBAction) capture:(id)sender {
    [self takePhoto];
}

#pragma mark Image Upload Connection

//-(NSDictionary*) getCurrentCoordinates {
//    NSDictionary *dict;
//    return dict;
//}

-(void) sendImageData {
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:self.lastImageAssetUrl resultBlock:^(ALAsset *asset) {
        ALAssetRepresentation *repr = [asset defaultRepresentation];
        NSUInteger size = repr.size;
        NSMutableData *data = [NSMutableData dataWithLength:size];
        NSError *error;
        [repr getBytes:data.mutableBytes fromOffset:0 length:size error:&error];
       
        [self buildRequestWithImageData:data];
        
    } failureBlock:^(NSError *error) {
        NSLog(@"Fail to get image data from assets.....");
    }];
}

-(void) buildRequestWithImageData:(NSData*)data_ {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    float battery = [UIDevice currentDevice].batteryLevel;
    NSNumber *parcentOfBattery;
    parcentOfBattery = [NSNumber numberWithInt:( battery * 100 )];
        
    NSMutableDictionary <IphoneClientRequest> *requestDict = [NSMutableDictionary new];
    
    requestDict.photo = [data_ base64];
    requestDict.udid = [[UIDevice currentDevice] uniqueIdentifier];
    requestDict.timestamp = [[NSDate date]description]; //フォーマットした方がいい
    requestDict.x = [NSString stringWithFormat:@"%f", self.currentX];
    requestDict.y = [NSString stringWithFormat:@"%f", self.currentY];
    requestDict.battery = [NSString stringWithFormat:@"%@",parcentOfBattery];
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@:%@/photos", hostname, portNum];
    requestDict.url = urlString.url;
    
    [requestDict post];

}

#pragma mark Emit Status
- (void) emitStatus:(NSTimer*)timer {
    [self updateCurrentCoordinate];
    if ([self.connector isConnectsocketIONodeServerUnicast]) {
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        [dict setValue:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"udid"];
        [dict setValue:[NSNumber numberWithFloat:self.currentX] forKey:@"x"];
        [dict setValue:[NSNumber numberWithFloat:self.currentY] forKey:@"y"];
        [UIDevice currentDevice].batteryMonitoringEnabled = YES;
        float battery = [UIDevice currentDevice].batteryLevel;
        NSNumber *parcentOfBattery;
        parcentOfBattery = [NSNumber numberWithInt:( battery * 100 )];
        [dict setValue:parcentOfBattery forKey:@"battery"];
        
        [dict setValue:[NSNumber numberWithFloat:self.currentDirection] forKey:@"compass"];

        [self.connector sendEventToUnicastServer:dict forEvent:@"status"];
    }
};

#pragma mark Location Compass delegate
-(void) locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    self.currentDirection = newHeading.magneticHeading;
    self.compassDirectionLabel.text = [NSString stringWithFormat:@"%f", self.currentDirection];
}

-(BOOL) locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
    return YES;
}



@end
