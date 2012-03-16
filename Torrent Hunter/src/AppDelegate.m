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
    // Default settings
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults integerForKey:@"CheckDem"] && ![userDefaults integerForKey:@"CheckTPB"]) {
        [userDefaults setInteger:1 forKey:@"CheckDem"];
        [userDefaults setInteger:1 forKey:@"CheckTPB"];
    }
    // Check for updates
    [updater checkForUpdatesInBackground];
}

- (IBAction)defaultService:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:1 forKey:@"CheckDem"];
    [userDefaults setInteger:1 forKey:@"CheckTPB"];
}

@end
