//
//  SMAppDelegate.m
//  cameraDemo
//
//  Created by yan xiaoliang on 13-5-29.
//  Copyright (c) 2013年 yan xiaoliang. All rights reserved.
//

#import "SMAppDelegate.h"

@implementation SMAppDelegate

- (void)dealloc
{
    [super dealloc];
}

- (void)initCaputre
{
    mCaptureSession = [[QTCaptureSession alloc] init];
    [mCaptureView setPreservesAspectRatio:YES];
    // Connect inputs and outputs to the session
    
	BOOL success = NO;
	NSError *error;
    [imageView setHidden:YES];
    [mCaptureView setHidden:NO];
    // Find a video device
    
    QTCaptureDevice *videoDevice = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeVideo];
    success = [videoDevice open:&error];
    
    
    // If a video input device can't be found or opened, try to find and open a muxed input device
    
	if (!success) {
		videoDevice = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeMuxed];
		success = [videoDevice open:&error];
		
    }
    
    if (!success) {
        videoDevice = nil;
        [[NSAlert alertWithError:error] runModal];
        // Handle error
        
    }
    mCaptureVideoDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:videoDevice];
    success = [mCaptureSession addInput:mCaptureVideoDeviceInput error:&error];
    if (!success) {
        [[NSAlert alertWithError:error] runModal];
        // Handle error
    }
    
    mCaptureDecompressedVideoOutput = [[QTCaptureDecompressedVideoOutput alloc] init];
    [mCaptureDecompressedVideoOutput setDelegate:self];
    success = [mCaptureSession addOutput:mCaptureDecompressedVideoOutput error:&error];
    if (!success) {
        [[NSAlert alertWithError:error] runModal];
        return;
    }
    
    [mCaptureView setCaptureSession:mCaptureSession];
    
}

- (IBAction)photoAction:(id)sender
{
    CVImageBufferRef imageBuffer;
    
    @synchronized (self) {
        imageBuffer = CVBufferRetain(mCurrentImageBuffer);
    }
    if (imageBuffer) {
        CIImage *theCIImage = [CIImage imageWithCVImageBuffer:imageBuffer];
        CGRect rect = [theCIImage extent];
        
        NSCIImageRep *imageRep = [NSCIImageRep imageRepWithCIImage:theCIImage];
        NSImage *image = [[[NSImage alloc] initWithSize:[imageRep size]] autorelease];
        [image addRepresentation:imageRep];
        [image setAlignmentRect:CGRectMake((rect.size.width - rect.size.height)/2, 0, rect.size.height, rect.size.height)];
//        [image setScalesWhenResized:YES];
//        
//        [image setSize:CGSizeMake(imageView.frame.size.width, imageView.frame.size.height)];
        CVBufferRelease(imageBuffer);
        
        imageView.image = image;
    }
    [imageView setHidden:NO];
    [mCaptureView setHidden:YES];
}

- (IBAction)cancelPhotoAction:(id)sender
{
    [imageView setHidden:YES];
    [mCaptureView setHidden:NO];
}

- (void)saveImage:(NSImage *)image
{
    [image lockFocus];
    //先设置 下面一个实例
    NSBitmapImageRep *bits = [[[NSBitmapImageRep alloc]initWithFocusedViewRect:NSMakeRect((image.size.width - image.size.height)/2, 0, image.size.height, image.size.height)]autorelease];
    [image unlockFocus];
    
    //再设置后面要用到得 props属性
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0.9] forKey:NSImageCompressionFactor];
    
    NSString *path = [[NSBundle mainBundle] resourcePath];
    //之后 转化为NSData 以便存到文件中
    NSData *imageData = [bits representationUsingType:NSJPEGFileType properties:imageProps];

    NSString *thePath = [path stringByAppendingPathComponent:@"photo"];
    NSLog(@"thePath %@",thePath);
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if (![[NSFileManager defaultManager] fileExistsAtPath:thePath])
	{
		BOOL isSuc = [fileManager createDirectoryAtPath:thePath
                            withIntermediateDirectories:YES
                                             attributes:nil
                                                  error:nil];
		if (!isSuc)
		{
            [fileManager release];
			return ;
		}
	}

    //设定好文件路径后进行存储就ok了
    [imageData writeToFile:[thePath stringByAppendingPathComponent:@"test1.png"] atomically:YES];
    
    
}

- (IBAction)savePhotoAction:(id)sender
{

    [self saveImage:imageView.image];
        NSLog(@"%@",[[NSBundle mainBundle] pathForResource:@"Purple_show_star5" ofType:@"png"]);
//    [imageView.image];
}

- (NSData *) PNGRepresentationOfImage:(NSImage *) image {
    // Create a bitmap representation from the current image
    
    [image lockFocus];
    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0, 0, image.size.width, image.size.height)];
    [image unlockFocus];
    
    return [bitmapRep representationUsingType:NSPNGFileType properties:Nil];
}

- (CIImage *)view:(QTCaptureView *)view willDisplayImage:(CIImage *)
image {
    //    NSCIImageRep *imageRep = [NSCIImageRep imageRepWithCIImage:[CIImage imageWithCVImageBuffer:image]];
    
    CGRect rect = [image extent];
    return [image imageByCroppingToRect:CGRectMake((rect.size.width - rect.size.height)/2, 0, rect.size.height, rect.size.height)];
}


- (void)captureOutput:(QTCaptureOutput *)captureOutput didOutputVideoFrame:(CVImageBufferRef)videoFrame withSampleBuffer:(QTSampleBuffer *)sampleBuffer fromConnection:(QTCaptureConnection *)connection
{
    CVImageBufferRef imageBufferToRelease;
    
    CVBufferRetain(videoFrame);
    
    @synchronized (self) {
        imageBufferToRelease = mCurrentImageBuffer;
        mCurrentImageBuffer = videoFrame;
    }
    
    CVBufferRelease(imageBufferToRelease);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self initCaputre];
    [mCaptureSession startRunning];
    NSLog(@"%@",[[NSBundle mainBundle] resourcePath]);
}

@end
