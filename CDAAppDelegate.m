//
//  CDAAppDelegate.m
//  Camera Scene
//
//  Created by Alsey Coleman Miller on 11/26/12.
//  Copyright (c) 2012 ColemanCDA. All rights reserved.
//

#import "CDAAppDelegate.h"
#import <SceneKit/SceneKit.h>
#import <QTKit/QTKit.h>
#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CoreImage.h>

@implementation CDAAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    NSTimeInterval time = 1 / 30;
    NSInvocation *action = [[NSInvocation alloc] init];
    [action setSelector:@selector(screenImage)];
    [action setTarget:self];
    _refreshScreenTimer = [NSTimer scheduledTimerWithTimeInterval:time
                                                       invocation:action
                                                          repeats:YES];
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

-(void)awakeFromNib
{    
    NSError *error;
    
    // set 3D mac's screen to white
    SCNNode *screenNode = [self.sceneView.scene.rootNode childNodeWithName:@"macbook_screen" recursively:YES];
    SCNMaterial *material = screenNode.geometry.materials[5];
    material.diffuse.contents = [NSColor whiteColor];
    
    // open device
    _captureDevice = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeVideo];
    [_captureDevice open:&error];
    if (error) {
        [NSApp presentError:error];
        error = nil;
        [[NSApplication sharedApplication] terminate:self];
    }
    _captureDeviceInput = [QTCaptureDeviceInput deviceInputWithDevice:_captureDevice];
    
    _captureSession = [[QTCaptureSession alloc] init];
    [_captureSession addInput:_captureDeviceInput error:&error];
    if (error) {
        [NSApp presentError:error];
        error = nil;
        [[NSApplication sharedApplication] terminate:self];
    }

    _captureOutputPreview = [[QTCaptureVideoPreviewOutput alloc] init];
    [_captureOutputPreview setDelegate:self];
    [_captureSession addOutput:_captureOutputPreview error:&error];
    if (error) {
        [NSApp presentError:error];
        error = nil;
        [[NSApplication sharedApplication] terminate:self];
    }
    
    // start recording
    [_captureSession startRunning];
    
    // transparency
    [[self sceneView] setBackgroundColor:[NSColor clearColor]];
    self.window.backgroundColor = [NSColor clearColor];
    [self.window setOpaque:NO];
}

- (void)captureOutput:(QTCaptureOutput *)captureOutput didOutputVideoFrame:(CVImageBufferRef)videoFrame withSampleBuffer:(QTSampleBuffer *)sampleBuffer fromConnection:(QTCaptureConnection *)connection
{
    NSCIImageRep *imageRep = [NSCIImageRep imageRepWithCIImage:[CIImage imageWithCVImageBuffer:videoFrame]];
    NSImage *frame = [[NSImage alloc] initWithSize:imageRep.size];
    [frame addRepresentation:imageRep];
    NSData *data = [frame TIFFRepresentation];
    NSBitmapImageRep *bmRep = [NSBitmapImageRep imageRepWithData:data];
    frame = nil;
    data = nil;
    frame = [[NSImage alloc] init];
    [frame addRepresentation:bmRep];
    
    // apply texture
    self.screenImage = frame;
}

-(NSImage *)screenImage
{
    SCNNode *screenNode = [self.sceneView.scene.rootNode childNodeWithName:@"screen" recursively:YES];
    SCNMaterial *screenMaterial = screenNode.geometry.firstMaterial;
    SCNMaterialProperty *texture = screenMaterial.diffuse;
    return texture.contents;
}

-(void)setScreenImage:(NSImage *)screenImage
{
    SCNNode *screenNode = [self.sceneView.scene.rootNode childNodeWithName:@"screen" recursively:YES];
    SCNMaterial *screenMaterial = screenNode.geometry.firstMaterial;
    SCNMaterialProperty *texture = screenMaterial.diffuse;
    texture.contents = screenImage;
}


@end
