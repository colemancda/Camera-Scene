//
//  CDAAppDelegate.h
//  Camera Scene
//
//  Created by Alsey Coleman Miller on 11/26/12.
//  Copyright (c) 2012 ColemanCDA. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SceneKit/SceneKit.h>
#import <QTKit/QTKit.h>

@interface CDAAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (weak) IBOutlet SCNView *sceneView;

@property QTCaptureDevice *captureDevice;

@property QTCaptureSession *captureSession;

@property QTCaptureDeviceInput *captureDeviceInput;

@property QTCaptureVideoPreviewOutput *captureOutputPreview;

@property NSImage *screenImage;

@property NSTimer *refreshScreenTimer;

@end
