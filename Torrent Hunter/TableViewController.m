//
//  TableViewController.m
//  Torrent Hunter
//
//  Created by Alejandro Silva on 08/02/12.
//  Copyright (c) 2012 AH-Develop. All rights reserved.
//

#import "TableViewController.h"
#import "Torrent.h"

@implementation TableViewController
@synthesize parseTPB;

- (id)init {
    self = [super init];
    if (self) {
        list = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [list count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    Torrent *t = [list objectAtIndex:row];
    NSString *identifier = [tableColumn identifier];
    return [t valueForKey:identifier];
}

- (IBAction)search:(id)sender {
    NSString *searchValue = @"http://thepiratebay.se/search/";
    searchValue = [searchValue stringByAppendingFormat:[searchField stringValue]];
    parseTPB = [[ParseWeb alloc] init];
    NSMutableArray *torrents = [parseTPB loadHTMLbyURL:searchValue];
    for (Torrent *tor in torrents){
        NSLog(@"Title: %@",[tor title]);
        //NSLog(@"Magnet: %@",[tor magnetLink]);
        NSLog(@"URL: %@",[tor url]);
        //NSLog(@"Seeders: %@",[tor seeders]);
        //NSLog(@"Leechers: %@",[tor leechers]);
        [list addObject:tor];
    }
    [torrentTableView reloadData];
}

@end
