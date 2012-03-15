//
//  ParseWeb.h
//  Torrent Hunter
//
//  Created by Alejandro Silva on 15/02/12.
//  Copyright (c) 2012 AH-Develop. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Torrent;
@class HTMLParser;

@interface ParseWeb : NSObject {
    NSMutableArray *torrents;
    HTMLParser *parser;
}

@property (readonly, retain) NSMutableArray *torrents;

- (id)loadHTMLbyURLTPB:(NSString *)urlString;
- (id)loadHTMLbyURLDem:(NSString *)urlString;

@end
