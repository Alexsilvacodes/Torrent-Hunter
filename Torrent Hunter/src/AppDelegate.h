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

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet SUUpdater *updater;
}

@property (assign) IBOutlet NSWindow *window;

- (IBAction)defaultService:(id)sender;

@end
