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

/***********************/
/* ThePirateBay method */
/***********************/

- (id)loadHTMLbyURLTPB:(NSString *)urlString {
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
        
        if ([trNodes count]<1 || [[spanNode contents] rangeOfString:@"Torrent"].location != NSNotFound) {
            [NSException raise:@"NoSearchResult" format:@""];
        }
        else{
            resultString = [spanNode contents];
            
            /* ------- Numero de paginas ------ */
            
            int numPages = [[[bodyNode findChildWithAttribute:@"align" matchingName:@"center" allowPartial:NO] contents] intValue];
            NSLog(@"%d",numPages);
            
            /* =============================== */
            
            for (HTMLNode *trNode in trNodes){
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
                    
                    /* Titulo */
                    [current setTitle:[titleNode contents]];
                    /* Magnet */
                    [current setMagnetLink:[magnetNode getAttributeNamed:@"href"]];
                    /* Torrent URL */
                    [current setUrl:[[aNodes objectAtIndex:2] getAttributeNamed:@"href"]];
                    /* Seeders */
                    [current setSeeders:[[[tdNodes objectAtIndex:2] contents] intValue]];
                    /* Leechers */
                    [current setLeechers:[[[tdNodes objectAtIndex:3] contents] intValue]];
                    /* Descripcion */
                    [current setDescription:[[descNode contents] stringByAppendingString:user]];
                    /* Tamaño */
                    NSArray *arraySize = [[descNode contents] componentsSeparatedByString:@" "];
                    [current setSize:[[arraySize objectAtIndex:3] substringToIndex:[[arraySize objectAtIndex:3] length]-1]];
                    /* Logo Servicio */
                    [current setSource:[NSImage imageNamed:@"favicon_tpb.png"]];
                    
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

/*******************/
/* Demonoid Method */
/*******************/

- (id)loadHTMLbyURLDem:(NSString *)urlString {
    NSError *error = nil;
    torrents = [[NSMutableArray alloc] init];
    @try {
        if ([urlString isEqualTo:@"http://www.demonoid.me/files/?category=0&subcategory=All&quality=All&seeded=0&external=2&query=&uid=0&sort=S"]){
            [NSException raise:@"VoidError" format:@""];
        }
        NSLog(@"%@",[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
        NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        parser = [[HTMLParser alloc] initWithContentsOfURL:url error:&error];
        
        if (error) {
            [NSException raise:@"ConectionError" format:@""];
        }
        
        HTMLNode *bodyNode = [parser body];
        
        /* Compobacion de existencia */
        NSArray *bNodes = [bodyNode findChildTags:@"b"];
        for (HTMLNode *bNode in bNodes) {
            if ([[bNode contents] isEqualToString:@"No torrents found"]) {
                [NSException raise:@"NoSearchResult" format:@""];
            }
        }
        
        HTMLNode *tableNode = [bodyNode findChildWithAttribute:@"class" matchingName:@"font_12px" allowPartial:FALSE];
        NSArray *trDateNodes = [tableNode findChildrenWithAttribute:@"bgcolor" matchingName:@"#CCCCCC" allowPartial:NO];
        /* Titulo */
        NSArray *tdNodes1Pad = [tableNode findChildrenOfClass:@"tone_1_pad"];
        NSArray *tdNodes3Pad = [tableNode findChildrenOfClass:@"tone_3_pad"];
        /* Usuario */
        NSArray *aUserNodes = [tableNode findChildrenOfClass:@"user"];
        /* Magnet */
        NSArray *aMagnetNodes = [tableNode findChildrenWithAttribute:@"href" matchingName:@"/files/downloadmagnet/" allowPartial:YES];
        /* Seeders */
        NSArray *fontSNodes = [tableNode findChildrenOfClass:@"green"];
        /* Leechers */
        NSArray *fontLNodes = [tableNode findChildrenOfClass:@"red"];
        /* Size */
        NSArray *tdNodes = [tableNode findChildTags:@"td"];
        NSMutableArray *tdSizeNodes = [NSMutableArray alloc];
        for (HTMLNode *tdNode in tdNodes) {
            if ([[tdNode getAttributeNamed:@"align"] isEqualToString:@"right"]) {
                [tdSizeNodes addObject:tdNode];
            }
        }
        
        NSString *user = [NSString alloc];
        
        //resultString = [spanNode contents];
        
        /* ------- Numero de paginas ------ */
        
        NSInteger numPages = [[[bodyNode findChildWithAttribute:@"align" matchingName:@"center" allowPartial:NO] contents] intValue];
        
        /* =============================== */
        NSInteger i = 0;
        for (HTMLNode *trDateNode in trDateNodes) {
            Torrent *current = [[Torrent alloc] init];
            
            [current setSource:[NSImage imageNamed:@"favicon_dem.png"]];
            
            [torrents addObject:current];
            ++i;
            /*if (![[trNode getAttributeNamed:@"class"] isEqualToString:@"header"]) {
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
            }*/
        }
        return torrents;
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
