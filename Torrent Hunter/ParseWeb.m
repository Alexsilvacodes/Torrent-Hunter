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
@synthesize resultString;

- (id)loadHTMLbyURL:(NSString *)urlString {
    NSError *error = nil;
    torrents = [[NSMutableArray alloc] init];
    @try {
        if ([urlString isEqualTo:@"http://thepiratebay.se/search/"]){
            [NSException raise:@"VoidError" format:@""];
        }
        NSLog(@"%@",[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
        NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        parser = [[HTMLParser alloc] initWithContentsOfURL:url error:&error];

        if (error) {
            [NSException raise:@"ConectionError" format:@""];
        }
        
        HTMLNode *bodyNode = [parser body];
        HTMLNode *tableNode = [bodyNode findChildWithAttribute:@"id" matchingName:@"searchResult" allowPartial:FALSE];
        HTMLNode *spanNode = [[bodyNode findChildTag:@"h2"] findChildTag:@"span"];
        NSArray *trNodes = [tableNode findChildTags:@"tr"];
        NSString *user = [NSString alloc];

        if ([trNodes count]<1 || [[spanNode contents] rangeOfString:@"Torrents"].location != NSNotFound) {
            [NSException raise:@"NoSearchResult" format:@""];
        }
        else{
            resultString = [spanNode contents];
            NSLog(@"%@",[NSNumber numberWithLong:[trNodes count]]);
            for (HTMLNode *trNode in trNodes){
                //NSLog(@"%@",[[trNode findChildWithAttribute:@"class" matchingName:@"detLink" allowPartial:FALSE] contents]);
            }
            for (HTMLNode *trNode in trNodes){
                NSLog(@"%@",[[trNode findChildWithAttribute:@"class" matchingName:@"detLink" allowPartial:FALSE] contents]);
                if (![[trNode getAttributeNamed:@"class"] isEqualToString:@"header"]) {
                    Torrent *current = [[Torrent alloc] init];
                    HTMLNode *titleNode = [trNode findChildWithAttribute:@"class" matchingName:@"detLink" allowPartial:FALSE];
                    HTMLNode *magnetNode = [trNode findChildWithAttribute:@"href" matchingName:@"magnet" allowPartial:TRUE];
                    HTMLNode *descNode = [trNode findChildTag:@"font"];
                    if ([descNode findChildTag:@"i"]) {
                        HTMLNode *userNode = [descNode findChildTag:@"i"];
                        user = [userNode contents];
                        [current setUserURL:@"NoUser"];
                        [current setUserName:[userNode contents]];
                    }
                    else {
                        HTMLNode *userNode = [descNode findChildTag:@"a"];
                        user = [userNode contents];
                        [current setUserURL:[userNode getAttributeNamed:@"href"]];
                        [current setUserName:[userNode contents]];
                    }
                    NSArray *tdNodes = [trNode findChildTags:@"td"];
                    NSArray *aNodes = [trNode findChildTags:@"a"];
                    
                    [current setTitle:[titleNode contents]];
                    [current setMagnetLink:[magnetNode getAttributeNamed:@"href"]];
                    [current setUrl:[[aNodes objectAtIndex:2] getAttributeNamed:@"href"]];
                    [current setSeeders:[[[tdNodes objectAtIndex:2] contents] intValue]];
                    [current setLeechers:[[[tdNodes objectAtIndex:3] contents] intValue]];
                    [current setDescription:[[descNode contents] stringByAppendingString:user]];
                    
                    [torrents addObject:current];
                }
            }
            return torrents;
        }
    }
    @catch (NSException *exception) {
        if ([[exception name] isLike:@"ConnectionError"]) {
            return @"-2";
        }
        else if ([[exception name] isLike:@"NoSearchResult"]) {
            return @"-1";
        }
        else if ([[exception name] isLike:@"VoidError"]) {
            return @"void";
        }
    }
}

@end
