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

@synthesize stillImageOutput;
@synthesize captureSession;

@synthesize lastImageAssetUrl;

@synthesize locationManager;

NSString * hostname = @"http://moxus.local";
NSString * portNum = @"3000";

#pragma mark - View Contrller Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveJsonNotification:) name:@"recivedGetMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNodeConnectionNotification:) name:@"recivedConnectionData" object:nil];
    
    self.connector = [[UnibaSocketIOConnector alloc] initWithUrl:hostname onPort:portNum onRoom:nil];
    
    [self.connector connectToUnicastServer];
    
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
    
    if (nil == locationManager) {
        locationManager = [[CLLocationManager alloc] init];
    }
    locationManager.delegate = self; // デリゲート設定
    locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 位置測定の望みの精度を設定
    locationManager.distanceFilter = kCLDistanceFilterNone; // 位置情報更新の目安距離
    
    [self updateCurrentCoordinate];
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
        [self updateCurrentCoordinate];
        self.consoleTextField.text = @"connected";
        NSMutableDictionary *helloDict = [NSMutableDictionary dictionary];
        
        [helloDict setValue:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"udid"];
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
                self.pitchValueLabel.text = [position objectForKey:@"x"];
            }
            if( nil != [position objectForKey:@"y"] ) {
                self.pitchValueLabel.text = [position objectForKey:@"y"];
            }
//            sendGenerator "XX
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


#pragma mark Softmodem 通信
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self.generator writeByte:0xff];
	[self.generator writeBytes:[textField.text UTF8String] length:[textField.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
	textField.text = @"";
    [self.serialTextField endEditing:YES];
	return YES;
}

- (void)sendGenerator:( NSString* )string_ {
    [self.generator writeBytes:[string_ UTF8String] length:[string_ lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
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
        
        
        // ビデオの解像度 Midium
        if ([captureSession canSetSessionPreset:AVCaptureSessionPresetMedium]) {
            self.captureSession.sessionPreset = AVCaptureSessionPresetMedium;
        }
        
        // AVCaptureStillImageOutputで静止画出力を作る
        self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        AVVideoCodecJPEG, AVVideoCodecKey, nil];
        self.stillImageOutput.outputSettings = outputSettings;
        [outputSettings release];
        
        // セッションに出力を追加
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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{// Delay execution of my block for 2 seconds.

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
                                                   [self getImageData];
                                               });
                                           }];
                    
                     /////////////////////
                     
                 }
             }];
            
            [self.captureSession stopRunning];
            
        });
    } else {
        NSLog(@"ERROR:%@", error);
    }
}


- (IBAction) capture:(id)sender {
    [self takePhoto];
}

#pragma mark Image Upload Connection
-(void) postImageRequestWithData:(NSDictionary *)params url:(NSString*)url_  {
    NSURL *url = [NSURL URLWithString:url_];
    
    // BODY の作成
    NSString *bodyString = [self _buildParameters:params];
    NSData   *httpBody   = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url
                                                            cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                        timeoutInterval:15.0];
    // POST の HTTP Request を作成
    [req setHTTPMethod:@"POST"];
    [req setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    [req setValue:[NSString stringWithFormat:@"%d", [httpBody length]] forHTTPHeaderField:@"Content-Length"];
    [req setHTTPBody:httpBody];
    [req setHTTPShouldHandleCookies:YES];
    
    NSURLConnection *conn;
    conn = [NSURLConnection connectionWithRequest:req delegate:self];
    
    if (conn) {
        NSLog(@"NSURLConnection create success");
    } else {
        NSLog(@"error : conn is nil");
    }
}
- (NSString*)_buildParameters:(NSDictionary *)params {
    NSMutableString *s = [NSMutableString string];
    
    NSString *key;
    for ( key in params ) {
        NSString *uriEncodedValue = [self _uriEncodeForString:[params objectForKey:key]];
        [s appendFormat:@"%@=%@&", key, uriEncodedValue];
    }
    
    if ( [s length] > 0 ) {
        [s deleteCharactersInRange:NSMakeRange([s length]-1, 1)];
    }
    return s;
}

- (NSString*)_uriEncodeForString:(NSString *)str {
    return [((NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                (CFStringRef)str,
                                                                NULL,
                                                                (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                kCFStringEncodingUTF8)) autorelease];
}

//-(NSDictionary*) getCurrentCoordinates {
//    NSDictionary *dict;
//    return dict;
//}

-(void) getImageData {
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
    
//    [dict setValue:data_ forKey:@"photo"];
//    [dict setValue:[NSDate date] forKey:@"tomestamp"];
//    [dict setValue:[NSNumber numberWithFloat:[self.panValueLabel.text floatValue]] forKey:@"x"];
//    [dict setValue:[NSNumber numberWithFloat:[self.pitchValueLabel.text floatValue]]  forKey:@"y"];
//    [dict setValue:parcentOfBattery forKey:@"battery"];
    
    //buid with string at all.
    [dict setValue:[NSString stringWithFormat:@"%@",data_] forKey:@"photo"];
    [dict setValue:[NSString stringWithFormat:@"%@",[NSDate date]] forKey:@"timestamp"];
    [dict setValue:self.panValueLabel.text forKey:@"x"];
    [dict setValue:self.pitchValueLabel.text forKey:@"y"];
    [dict setValue:[NSString stringWithFormat:@"%@",parcentOfBattery] forKey:@"battery"];
    
    [self postImageRequestWithData:dict url:[NSString stringWithFormat:@"%@:%@/photos", hostname, portNum]];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"didReceiveData");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
}


@end
