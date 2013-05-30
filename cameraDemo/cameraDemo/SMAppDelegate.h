//
//  SMAppDelegate.h
//  cameraDemo
//
//  Created by yan xiaoliang on 13-5-29.
//  Copyright (c) 2013年 yan xiaoliang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import <QTKit/QTKit.h>
@interface SMAppDelegate : NSObject <NSApplicationDelegate>
{
    IBOutlet QTCaptureView      *mCaptureView;
    QTCaptureDeviceInput        *mCaptureVideoDeviceInput;
    QTCaptureSession            *mCaptureSession;
    QTCaptureDecompressedVideoOutput  *mCaptureDecompressedVideoOutput;
    CVImageBufferRef mCurrentImageBuffer;
    IBOutlet NSImageView        *imageView;
}
@property (assign) IBOutlet NSWindow *window;
- (IBAction)photoAction:(id)sender;
- (IBAction)cancelPhotoAction:(id)sender;
- (IBAction)savePhotoAction:(id)sender;
@end
