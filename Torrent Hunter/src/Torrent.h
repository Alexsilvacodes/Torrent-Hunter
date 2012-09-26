//
//  Torrent.h
//  Torrent Hunter
//
//  Created by Alejandro Silva on 07/02/12.
//  Copyright (c) 2012 AH-Develop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Torrent : NSObject {
@private
    NSString *title;
    NSString *magnetLink;
    NSString *url;
    NSString *description;
    NSString *userURL;
    NSString *userName;
    NSImage *source;
    NSString *size;
    NSString *completeDesc;
    int pages;
    int seeders;
    int leechers;
}

@property (copy) NSString *title;
@property (copy) NSString *magnetLink;
@property (copy) NSString *url;
@property (copy) NSString *description;
@property (copy) NSString *userURL;
@property (copy) NSString *userName;
@property (copy) NSImage *source;
@property (copy) NSString *size;
@property (copy) NSString *completeDesc;
@property double numSize;
@property int pages;
@property int seeders;
@property int leechers;

@end
