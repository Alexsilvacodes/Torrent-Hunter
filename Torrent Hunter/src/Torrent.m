//
//  Torrent.m
//  Torrent Hunter
//
//  Created by Alejandro Silva on 07/02/12.
//  Copyright (c) 2012 AH-Develop. All rights reserved.
//

#import "Torrent.h"

@implementation Torrent

@synthesize title;
@synthesize magnetLink;
@synthesize url;
@synthesize description;
@synthesize userURL;
@synthesize userName;
@synthesize size;
@synthesize seeders;
@synthesize leechers;
@synthesize source;
@synthesize pages;

- (id)init {
    self = [super init];
    if (self) {
        title = @"";
        magnetLink = @"";
        url = @"";
        description = @"";
        userURL = @"";
        userName = @"";
        size = @"";
        seeders = 0;
        leechers = 0;
        pages = 0;
        source = nil;
    }
    return self;
}

@end
