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
    int seeders;
    int leechers;
}

@property (copy) NSString *title;
@property (copy) NSString *magnetLink;
@property (copy) NSString *url;
@property (copy) NSString *description;
@property (copy) NSString *userURL;
@property (copy) NSString *userName;
@property int seeders;
@property int leechers;

@end
