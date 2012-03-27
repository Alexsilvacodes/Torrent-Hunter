//
//  AppDelegate.h
//  Torrent Hunter
//
//  Created by Alejandro Silva on 02/02/12.
//  Copyright (c) 2012 AH-Develop. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Sparkle/Sparkle.h>
#import <Sparkle/SUUpdater.h>
#import "MAAttachedWindow.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate> {
    IBOutlet SUUpdater *updater;
    NSStatusItem *statusBarItem;
    MAAttachedWindow *attachedWindow;
    IBOutlet NSView *statusBarview;
}

@property (assign) IBOutlet NSWindow *window;

- (IBAction)defaultService:(id)sender;
- (IBAction)changeAppType:(id)sender;
- (void)toggleAttachedWindowAtPoint:(NSPoint)pt;
- (void)windowDidResignKey:(NSNotification *) notification;

@end
