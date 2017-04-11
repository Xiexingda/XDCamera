//
//  XDCamera.m
//  摄像
//
//  Created by 谢兴达 on 2017/3/1.
//  Copyright © 2017年 谢兴达. All rights reserved.
//

#import "XDCamera.h"
#import "CameraUI.h"
#import "PreviewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);


@interface XDCamera ()<CameraUIDelegate>
@property (nonatomic, strong) AVCaptureSession *session;//会话管理
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;//设备输入
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutPut;//照片输出流
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;//实时预览层

@property (nonatomic, strong) SelectView *contentView;//视频层
@property (nonatomic, strong) UIView *focusView;//聚焦视图
@property (nonatomic, strong) PreviewController *preview;//预览照片层
@end

@implementation XDCamera

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.session startRunning];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.session stopRunning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatCameraUI];
}

- (void)creatCameraUI {
    CameraUI *uiView = [[CameraUI alloc]initWithFrame:self.view.bounds];
    [uiView viewsLinkBlock:^(UIView *focusView, SelectView *previewView) {
        _contentView = previewView;
        _focusView = focusView;
    }];
    uiView.delegate = self;
    self.view = uiView;
    
    [self configSessionManager];
}

#pragma mark -- 初始化会话管理
- (void)configSessionManager {
    _session = [[AVCaptureSession alloc]init];
    [self changeConfigurationWithSession:_session block:^(AVCaptureSession *session) {
        if ([session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
            [session setSessionPreset:AVCaptureSessionPresetHigh];
        }
        
        AVCaptureDevice *device = [self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];
        if (!device) {
            NSLog(@"获取摄像头失败");
            return;
        }
        
        NSError *error = nil;
        _deviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:device error:&error];
        if (error) {
            NSLog(@"初始化输入失败");
            return;
        }
        
        _imageOutPut = [[AVCaptureStillImageOutput alloc]init];
        [_imageOutPut setOutputSettings:@{AVVideoCodecKey:AVVideoCodecJPEG}];
        
        if ([session canAddInput:_deviceInput]) {
            [session addInput:_deviceInput];
        }
        
        if ([session canAddOutput:_imageOutPut]) {
            [session addOutput:_imageOutPut];
        }
        
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:session];
        
        CALayer *layer = _contentView.layer;
        layer.masksToBounds = YES;
        
        _previewLayer.frame = layer.bounds;
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [layer insertSublayer:_previewLayer below:_focusView.layer];
        
        [self addNotificationToDevice:device];
    }];
}


#pragma mark - 通知
/**
 给输入设备添加通知
 */
-(void)addNotificationToDevice:(AVCaptureDevice *)captureDevice{
    //注意添加区域改变捕获通知必须首先设置设备允许捕获
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        captureDevice.subjectAreaChangeMonitoringEnabled=YES;
    }];
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    //捕获区域发生改变
    [notificationCenter addObserver:self selector:@selector(areaChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
    //链接成功
    [notificationCenter addObserver:self selector:@selector(deviceConnected:) name:AVCaptureDeviceWasConnectedNotification object:captureDevice];
    //链接断开
    [notificationCenter addObserver:self selector:@selector(deviceDisconnected:) name:AVCaptureDeviceWasDisconnectedNotification object:captureDevice];
}

-(void)removeNotificationFromCaptureDevice:(AVCaptureDevice *)captureDevice{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
    [notificationCenter removeObserver:self name:AVCaptureDeviceWasConnectedNotification object:captureDevice];
    [notificationCenter removeObserver:self name:AVCaptureDeviceWasDisconnectedNotification object:captureDevice];
}
/**
 移除所有通知
 */
-(void)removeNotification{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
}

-(void)addNotificationToCaptureSession:(AVCaptureSession *)captureSession{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    //会话出错
    [notificationCenter addObserver:self selector:@selector(sessionError:) name:AVCaptureSessionRuntimeErrorNotification object:captureSession];
}

/**
 设备连接成功

 @param notification 通知对象
 */
-(void)deviceConnected:(NSNotification *)notification{
    NSLog(@"设备已连接...");
}

/**
 设备连接断开
 
 @param notification 通知对象
 */
-(void)deviceDisconnected:(NSNotification *)notification{
    NSLog(@"设备已断开.");
}

/**
 捕获区域改变
 
 @param notification 通知对象
 */
-(void)areaChange:(NSNotification *)notification{
    NSLog(@"区域改变...");
    CGPoint cameraPoint = [self.previewLayer captureDevicePointOfInterestForPoint:self.view.center];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
}

/**
 会话出错
 
 @param notification 通知对象
 */
-(void)sessionError:(NSNotification *)notification{
    NSLog(@"会话发生错误.");
}

#pragma mark -- 工具方法
/**
 取得指定位置的摄像头
 
 @param position 摄像头位置（前、后）
 
 @return 摄像头设备
 */
-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position{
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position]==position) {
            return camera;
        }
    }
    return nil;
}

/**
 改变设备属性的统一操作方法

 @param propertyChange 属性改变操作
 */
-(void)changeDeviceProperty:(PropertyChangeBlock)propertyChange{
    AVCaptureDevice *captureDevice= [self.deviceInput device];
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    }else{
        NSLog(@"出错了，错误信息：%@",error.localizedDescription);
    }
}

- (void)changeConfigurationWithSession:(AVCaptureSession *)currentSession block:(void (^)(AVCaptureSession *session))block {
    [currentSession beginConfiguration];
    if (block) {
        block(currentSession);
    }
    [currentSession commitConfiguration];
}

/**
 设置闪光灯模式
 
 @param flashMode 闪光灯模式
 */
-(void)setFlashMode:(AVCaptureFlashMode )flashMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFlashModeSupported:flashMode]) {
            [captureDevice setFlashMode:flashMode];
        }
    }];
}

/**
 设置聚焦点
 
 @param point 聚焦点
 */
-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:focusMode];
        }
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:point];
        }
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:exposureMode];
        }
        if ([captureDevice isExposurePointOfInterestSupported]) {
            [captureDevice setExposurePointOfInterest:point];
        }
    }];
}

/**
 设置聚焦光标位置

 @param point 光标位置
 */
-(void)setFocusCursorWithPoint:(CGPoint)point{
    self.focusView.center=point;
    self.focusView.transform=CGAffineTransformMakeScale(1.5, 1.5);
    self.focusView.alpha=1.0;
    [UIView animateWithDuration:1.0 animations:^{
        self.focusView.transform=CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.focusView.alpha=0;
        
    }];
}

#pragma mark -- 按钮点击事件

//取消
- (void)cancelClick {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

//闪光灯开
- (void)onFlashClick {
    [self setFlashMode:AVCaptureFlashModeOn];
}

//闪光灯自动
- (void)autoFlashClick {
    [self setFlashMode:AVCaptureFlashModeAuto];
}

//闪光灯关
- (void)offFlashClick {
    [self setFlashMode:AVCaptureFlashModeOff];
}

//切换摄像头
- (BOOL)changeBtClick {
    bool isBacground = NO;
    AVCaptureDevice *currentDevice=[self.deviceInput device];
    AVCaptureDevicePosition currentPosition=[currentDevice position];
    [self removeNotificationFromCaptureDevice:currentDevice];
    AVCaptureDevice *toChangeDevice;
    AVCaptureDevicePosition toChangePosition=AVCaptureDevicePositionFront;
    if (currentPosition==AVCaptureDevicePositionUnspecified||currentPosition==AVCaptureDevicePositionFront) {
        toChangePosition=AVCaptureDevicePositionBack;
        isBacground = YES;
    }
    toChangeDevice=[self getCameraDeviceWithPosition:toChangePosition];
    [self addNotificationToDevice:toChangeDevice];
    //获得要调整的设备输入对象
    AVCaptureDeviceInput *toChangeDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:toChangeDevice error:nil];
    
    //改变会话的配置前一定要先开启配置，配置完成后提交配置改变
    [self changeConfigurationWithSession:_session block:^(AVCaptureSession *session) {
        //移除原有输入对象
        [session removeInput:self.deviceInput];
        self.deviceInput = nil;
        //添加新的输入对象
        if ([session canAddInput:toChangeDeviceInput]) {
            [session addInput:toChangeDeviceInput];
            self.deviceInput=toChangeDeviceInput;
        }
    }];

    return isBacground;
}

//拍摄
- (void)cameraBtClick {
    AVCaptureConnection *connect = [self.imageOutPut connectionWithMediaType:AVMediaTypeVideo];
    
    //视频防抖模式
    if ([connect isVideoStabilizationSupported]) {
        connect.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
    }
    
    //根据链接却出输出的数据
    [self.imageOutPut captureStillImageAsynchronouslyFromConnection:connect completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData];
            if (!_preview) {
                _preview = [[PreviewController alloc]init];
            }
            _preview.previewImage = image;
            [self presentViewController:_preview animated:YES completion:nil];
        }
    }];
}

//返回点击位置
- (void)cameraLayerClick:(SelectView *)view gesture:(UITapGestureRecognizer *)gesture {
    CGPoint point= [gesture locationInView:view];
    //将UI坐标转化为摄像头坐标
    CGPoint cameraPoint= [self.previewLayer captureDevicePointOfInterestForPoint:point];
    [self setFocusCursorWithPoint:point];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
}

@end
