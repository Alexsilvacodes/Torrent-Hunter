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

- (id)init {
    self = [super init];
    if (self) {
        nItems = 0;
    }
    return self;
}

/***********************/
/* ThePirateBay method */
/***********************/

- (id)loadHTMLbyURLTPB:(NSString *)urlString {
    NSError *error = nil;
    int numPages;
    int numItems;
    
    torrents = [[NSMutableArray alloc] init];
    @try {
        if ([urlString isEqualTo:@"https://thepiratebay.org/search/"]){
            [NSException raise:@"VoidError" format:@""];
        }
        NSLog(@"%@", urlString);
        NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        parser = [[HTMLParser alloc] initWithContentsOfURL:url error:&error];

        if ([error isNotEqualTo:nil]) {
            [NSException raise:@"ConnectionError" format:@""];
        }
        
        HTMLNode *bodyNode = [parser body];
        HTMLNode *tableNode = [bodyNode findChildWithAttribute:@"id"
                                                  matchingName:@"searchResult"
                                                  allowPartial:FALSE];
        HTMLNode *spanNode = [[bodyNode findChildTag:@"h2"] findChildTag:@"span"];
        NSArray *trNodes = [tableNode findChildTags:@"tr"];
        NSString *user = [NSString alloc];
        
        if ([trNodes count]<1 || [[spanNode contents] rangeOfString:@"Torrent"].location != NSNotFound) {
            [NSException raise:@"NoSearchResult" format:@""];
        } else if (!tableNode) {
            [NSException raise:@"ConnectionError" format:@""];
            NSLog(@"Conection");
        } else {
            
            /* ------- Numero de paginas ------ */
            
            numItems = [[[[[bodyNode findChildTag:@"h2"] rawContents] componentsSeparatedByString:@" "] objectAtIndex:9] intValue];
            
            nItems = nItems + numItems;
            if (numItems % 30 != 0) {
                numPages = numItems / 30 + 1;
            } else {
                numPages = numItems / 30;
            }
            
            /* =============================== */
            
            for (HTMLNode *trNode in trNodes) {
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
                    } else {
                        HTMLNode *userNode = [descNode findChildTag:@"a"];
                        user = [userNode contents];
                        NSString *urlUser = @"https://thepiratebay.org";
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
                    NSString *urlTPB = @"https://thepiratebay.org/";
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
                    NSString *tam = [[arraySize objectAtIndex:3] substringToIndex:[[arraySize objectAtIndex:3] length]-1];
                    [current setSize:tam];
                    
                    /* Logo Servicio */
                    [current setSource:[NSImage imageNamed:@"favicon_tpb.png"]];
                    
                    
                    [torrents addObject:current];
                }
            }
            return torrents;
        }
    } @catch (NSException *exception) {
        if ([[exception name] isLike:@"ConnectionError"]) {
            return @"-2";
        }
        else if ([[exception name] isLike:@"NoSearchResult"]) {
            return @"-1";
        }
        else if ([[exception name] isLike:@"VoidError"]) {
            return @"void";
        }
        else {
            NSLog(@">> %@",[exception name]);
        }
    }
}

// Metodo para obtener la descripcion completa del torrent
// Se obtiene de la url enviada segun el torrent seleccionado y devuelve el string
- (id)getDesc:(NSString *)url {
    NSError *error = nil;

    NSURL *urlTorrent = [NSURL URLWithString:url];
    HTMLParser *parserTorrent = [[HTMLParser alloc] initWithContentsOfURL:urlTorrent error:&error];
    
    /* Descripcion completa */
    HTMLNode *preNode = [[parserTorrent body] findChildTag:@"pre"];
    return [preNode allContents];
}

/***************************/
/* Kickass Torrents Method */
/***************************/

- (id)loadHTMLbyURLKAT:(NSString *)urlString {
    NSError *error = nil;
    int numPages;
    int numItems;
    
    torrents = [[NSMutableArray alloc] init];
    @try {
        if ([urlString isEqualTo:@"https://thepiratebay.org/search/"]){
            [NSException raise:@"VoidError" format:@""];
        }
        NSLog(@"%@",urlString);
        NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        parser = [[HTMLParser alloc] initWithContentsOfURL:url error:&error];
        
        if ([error isNotEqualTo:nil]) {
            [NSException raise:@"ConnectionError" format:@""];
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
            [NSException raise:@"ConnectionError" format:@""];
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
                        NSString *urlUser = @"https://thepiratebay.org";
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
                    NSString *urlTPB = @"https://thepiratebay.org/";
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
                    NSString *tam = [[arraySize objectAtIndex:3] substringToIndex:[[arraySize objectAtIndex:3] length]-1];
                    [current setSize:tam];
                    
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
        else {
            NSLog(@">> %@",[exception name]);
        }
    }
}
    
@end
