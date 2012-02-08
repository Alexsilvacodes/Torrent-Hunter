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

- (IBAction)add:(id)sender {
    [list addObject:[[Torrent alloc] init]];
    [torrentTableView reloadData];
}

@end
