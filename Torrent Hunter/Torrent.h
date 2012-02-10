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
    int seeders;
}

@property (copy) NSString *title;
@property (copy) NSString *magnetLink;
@property (copy) NSString *url;
@property int seeders;

@end
