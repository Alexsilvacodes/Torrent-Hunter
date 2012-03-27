//
//  CustomStatusView.h
//  Torrent Hunter
//
//  Created by Alejandro Silva on 21/03/12.
//  Copyright (c) 2012 AH-Develop. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AppDelegate;
@interface CustomStatusView : NSView <NSWindowDelegate> {
    __weak AppDelegate *controller;
    BOOL clicked;
}

- (void)setClicked;
- (id)initWithFrame:(NSRect)frame controller:(AppDelegate *)ctrlr;

@end
