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
@synthesize seeders;

- (id)init {
    self = [super init];
    if (self) {
        title = @"Hola";
        magnetLink = @"Link magnet";
        url = @"URL";
        seeders = 486;
    }
    
    return self;
}

@end
