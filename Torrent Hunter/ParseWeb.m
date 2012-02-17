//
//  ParseWeb.m
//  Torrent Hunter
//
//  Created by Alejandro Silva on 15/02/12.
//  Copyright (c) 2012 AH-Develop. All rights reserved.
//
//

#import "ParseWeb.h"
#import "Torrent.h"
#import "HTMLParser.h"

@implementation ParseWeb

@synthesize torrents;

- (id)loadHTMLbyURL:(NSString *)urlString {
    NSError *error = nil;
    torrents = [[NSMutableArray alloc] init];
    @try {
        NSURL *url = [NSURL URLWithString:urlString];
        parser = [[HTMLParser alloc] initWithContentsOfURL:url error:&error];
    }
    @catch (NSException *exception) {
        NSLog(@"Excepcion cogida: %@",exception);
        return @"-1";
    }
    
    if (error) {
        NSLog(@"Error: %@", error);
        return @"-2";
    }
    
    HTMLNode *bodyNode = [parser body];
    HTMLNode *tableNode = [bodyNode findChildWithAttribute:@"id" matchingName:@"searchResult" allowPartial:FALSE];
    NSArray *trNodes = [tableNode findChildTags:@"tr"];
    
    if (trNodes.count<1) {
        return @"-1";
    }
    else{
        for (HTMLNode *trNode in trNodes){
            if (![[trNode getAttributeNamed:@"class"] isEqualToString:@"header"]) {
                Torrent *current = [[Torrent alloc] init];
                HTMLNode *titleNode = [trNode findChildWithAttribute:@"class" matchingName:@"detLink" allowPartial:FALSE];
                HTMLNode *magnetNode = [trNode findChildWithAttribute:@"href" matchingName:@"magnet" allowPartial:TRUE];
                NSArray *tdNodes = [trNode findChildTags:@"td"];
                NSArray *aNodes = [trNode findChildTags:@"a"];
                
                [current setTitle:[titleNode contents]];
                [current setMagnetLink:[magnetNode getAttributeNamed:@"href"]];
                [current setUrl:[[aNodes objectAtIndex:4] getAttributeNamed:@"href"]];
                [current setSeeders:[[[tdNodes objectAtIndex:2] contents] intValue]];
                [current setLeechers:[[[tdNodes objectAtIndex:3] contents] intValue]];
                [torrents addObject:current];
            }
        }
        
        return torrents;
    }
}

@end
