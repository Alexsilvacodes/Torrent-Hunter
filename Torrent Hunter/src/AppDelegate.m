//
//  AppDelegate.m
//  Torrent Hunter
//
//  Created by Alejandro Silva on 02/02/12.
//  Copyright (c) 2012 AH-Develop. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Check for updates
    [updater checkForUpdatesInBackground];
}

@end
