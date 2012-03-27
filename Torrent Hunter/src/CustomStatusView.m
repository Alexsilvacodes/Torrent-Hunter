//
//  CustomStatusView.m
//  Torrent Hunter
//
//  Created by Alejandro Silva on 21/03/12.
//  Copyright (c) 2012 AH-Develop. All rights reserved.
//

#import "CustomStatusView.h"
#import "AppDelegate.h"

@implementation CustomStatusView

- (id)initWithFrame:(NSRect)frame controller:(AppDelegate *)ctrlr {
    self = [super initWithFrame:frame];
    if (self) {
        controller = ctrlr;
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    
    NSImage *active = [NSImage imageNamed:@"icon_sui_b.png"];
    if (clicked) {
        active = [NSImage imageNamed:@"icon_sui_w.png"];
    }
    
    NSSize msgActSize = [active size];
    NSRect msgActRect = NSMakeRect(0, 0, msgActSize.width, msgActSize.height);
    
    [active drawInRect:msgActRect fromRect:msgActRect operation:NSCompositeHighlight fraction:5];
}

- (void)setClicked {
    clicked = !clicked;
    NSLog(@"set clicked");
}

- (void)mouseDown:(NSEvent *)event {
    NSRect frame = [[self window] frame];
    NSPoint pt = NSMakePoint(NSMidX(frame), NSMidY(frame));
    NSLog(@"%g,%g",pt.x,pt.y);
    clicked = !clicked;
    [controller toggleAttachedWindowAtPoint:pt];
    [self setNeedsDisplay:YES];
}

@end
