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
@synthesize nItems;

/***********************/
/* ThePirateBay method */
/***********************/

-(id)init {
    self = [super init];
    if (self) {
        nItems = 0;
    }
    return self;
}

- (id)loadHTMLbyURLTPB:(NSString *)urlString {
    NSError *error = nil;
    int numPages;
    int numItems;
    
    torrents = [[NSMutableArray alloc] init];
    @try {
        if ([urlString isEqualTo:@"http://thepiratebay.se/search/"]){
            [NSException raise:@"VoidError" format:@""];
        }
        NSLog(@"%@",urlString);
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
        else if (!tableNode) {
            [NSException raise:@"ConectionError" format:@""];
            NSLog(@"Conection");
        }
        else {
            
            /* ------- Numero de paginas ------ */
            
            numItems = [[[[[bodyNode findChildTag:@"h2"] rawContents] componentsSeparatedByString:@" "] objectAtIndex:11] intValue];
            nItems = nItems + numItems;
            if (numItems % 30 != 0) {
                numPages = numItems / 30 + 1;
            }
            else {
                numPages = numItems / 30;
            }
            
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
                        NSString *urlUser = @"http://thepiratebay.se";
                        urlUser = [urlUser stringByAppendingString:[userNode getAttributeNamed:@"href"]];
                        [current setUserURL:urlUser];
                        [current setUserName:[userNode contents]];
                    }
                    NSArray *tdNodes = [trNode findChildTags:@"td"];
                    NSArray *aNodes = [trNode findChildTags:@"a"];
                    
                    /* Titulo */
                    [current setTitle:[titleNode contents]];
                    /* Magnet */
                    [current setMagnetLink:[magnetNode getAttributeNamed:@"href"]];
                    /* Torrent URL */
                    NSString *urlTPB = @"http://thepiratebay.se";
                    urlTPB = [urlTPB stringByAppendingString:[[aNodes objectAtIndex:2] getAttributeNamed:@"href"]];
                    [current setUrl:urlTPB];
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
/*
- (id)loadHTMLbyURLDem:(NSString *)urlString {
    NSError *error = nil;
    int numPages;
    int numItems;
    
    torrents = [[NSMutableArray alloc] init];
    @try {
        if ([urlString isEqualTo:@"http://www.demonoid.me/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=0&quality=0&external=2&query=&sort=S"]){
            [NSException raise:@"VoidError" format:@""];
        }
        NSLog(@"%@",urlString);
        NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        parser = [[HTMLParser alloc] initWithContentsOfURL:url error:&error];
        
        if (error) {
            [NSException raise:@"ConectionError" format:@""];
        }
        
        HTMLNode *bodyNode = [parser body];
*/        
        /* Compobacion de existencia */
/*
        NSArray *bNodes = [bodyNode findChildTags:@"b"];
        for (HTMLNode *bNode in bNodes) {
            if ([[bNode contents] isEqualToString:@"No torrents found"]) {
                [NSException raise:@"NoSearchResult" format:@""];
            }
        }
        
        HTMLNode *tableNode = [bodyNode findChildWithAttribute:@"class" matchingName:@"font_12px" allowPartial:FALSE];
*/
        /* Titulo */
/*
        NSArray *tdNodes1Pad = [tableNode findChildrenOfClass:@"tone_1_pad"];
        NSArray *tdNodes3Pad = [tableNode findChildrenOfClass:@"tone_3_pad"];
        NSMutableArray *titleNodes = [[NSMutableArray alloc] init];
        for (NSInteger i=0 ; i<[tdNodes1Pad count] ; i++) {
            [titleNodes addObject:[tdNodes1Pad objectAtIndex:i]];
            [titleNodes addObject:[tdNodes3Pad objectAtIndex:i]];
        }
*/
        /* Torrent URL */
        //NSArray *urlNodes = [tableNode findChildrenWithAttribute:@"href" matchingName:@"/files/details/" allowPartial:YES];
        /* Usuario */
        //NSArray *aUserNodes = [tableNode findChildrenWithAttribute:@"href" matchingName:@"/users/" allowPartial:YES];
        /* Magnet */
        //NSArray *aMagnetNodes = [tableNode findChildrenWithAttribute:@"href" matchingName:@"/files/downloadmagnet/" allowPartial:YES];
        /* Seeders */
        //NSArray *fontSNodes = [tableNode findChildrenOfClass:@"green"];
        /* Leechers */
        //NSArray *fontLNodes = [tableNode findChildrenOfClass:@"red"];
        /* Size */
        /*NSArray *tdNodes = [tableNode findChildTags:@"td"];
        NSMutableArray *tdSizeNodes = [[NSMutableArray alloc] init];
        for (HTMLNode *tdNode in tdNodes) {
            if ([[tdNode getAttributeNamed:@"align"] isEqualToString:@"right"]) {
                [tdSizeNodes addObject:tdNode];
            }
        }*/
        /* Times completed */
        /*NSArray *fontBNodes = [tableNode findChildrenOfClass:@"blue"];
        
        HTMLNode *fontErrorNode = [bodyNode findChildWithAttribute:@"size" matchingName:@"+2" allowPartial:NO];
        if ([[fontErrorNode contents] isEqualToString:@"Maintenance"]) {
            [NSException raise:@"ConectionError" format:@""];
        }
        else{*/
            /* ------- Numero de paginas ------ */
            /*
            numItems = [[[[[tableNode findChildTag:@"strong"] contents] componentsSeparatedByString:@" "] objectAtIndex:0] intValue];
            nItems = nItems + numItems;
            if (numItems % 30 != 0) {
                numPages = numItems / 30 + 1;
            }
            else {
                numPages = numItems / 30;
            }
            */
            /* =============================== */
            //int j = 0;
            //for (HTMLNode *titleNode in titleNodes) {
                //Torrent *current = [[Torrent alloc] init];
                
                /* Title */
                //[current setTitle:[[titleNode findChildTag:@"a"] contents]];
                /* User */
                //[current setUserName:[[[[aUserNodes objectAtIndex:j] getAttributeNamed:@"href"] componentsSeparatedByString:@"/users/"] objectAtIndex:1]];
                /* User URL */
                //NSString *user = @"http://demonoid.me";
                //user = [user stringByAppendingString:[[aUserNodes objectAtIndex:j] getAttributeNamed:@"href"]];
                //[current setUserURL:user];
                /* Source */
                //[current setSource:[NSImage imageNamed:@"favicon_dem.png"]];
                /* Magnet Link */
                //NSString *magnet = @"http://demonoid.me";
                //magnet = [magnet stringByAppendingString:[[aMagnetNodes objectAtIndex:j] getAttributeNamed:@"href"]];
                //[current setMagnetLink:magnet];
                /* Seeders */
                //[current setSeeders:[[[fontSNodes objectAtIndex:j] contents] intValue]];
                /* Leechers */
                //[current setLeechers:[[[fontLNodes objectAtIndex:j] contents] intValue]];
                /* Size */
                //[current setSize:[[tdSizeNodes objectAtIndex:j] contents]];
                /* Description */
/*
                NSString *desc = [[NSString alloc] init];
                desc = [desc stringByAppendingString:NSLocalizedString(@"Completed: ", "Description -> Completed")];
                desc = [desc stringByAppendingString:[[fontBNodes objectAtIndex:j] contents]];
                desc = [desc stringByAppendingString:NSLocalizedString(@" times, Size: ", "Description -> Size")];
                desc = [desc stringByAppendingString:[[tdSizeNodes objectAtIndex:j] contents]];
                desc = [desc stringByAppendingString:NSLocalizedString(@", uploaded by ", "Description -> Uploaded")];
                desc = [desc stringByAppendingString:[[[[aUserNodes objectAtIndex:j] getAttributeNamed:@"href"] componentsSeparatedByString:@"/users/"] objectAtIndex:1]];
                [current setDescription:desc];
 */
                /* Torrent URL */
/*
                NSString *urlDem = @"http://www.demonoid.me";
                urlDem = [urlDem stringByAppendingString:[[urlNodes objectAtIndex:j] getAttributeNamed:@"href"]];
                [current setUrl:urlDem];
                
                j++;
                
                [torrents addObject:current];
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
*/
@end
