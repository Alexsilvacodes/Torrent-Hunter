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
@synthesize popover;

- (id)init {
    self = [super init];
    if (self) {
        list = [[NSMutableArray alloc] init];
        recentSearches = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)awakeFromNib {
    [searchField setRecentSearches:recentSearches];
    [torrentTableView setTarget:self];
    [torrentTableView setAction:NSSelectorFromString(@"showPopover:")];
    [torrentTableView setDoubleAction:NSSelectorFromString(@"doubleClick:")];
}

- (IBAction)search:(id)sender {
    /* Operation queue */
    NSOperationQueue *threads = [NSOperationQueue new];
    
    /* Instance a NSInvocationOperation (subclass of NSOperation) */
    NSInvocationOperation *task = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadDatainTableView) object:nil];
    
    /* Add the operation to the queue */
    [threads addOperation:task];
}

- (void)doubleClick:(id)sender {
    if ([list count] > 0) {
        NSInteger i = [torrentTableView clickedRow];
        NSURL *magnet = [NSURL URLWithString:[[list objectAtIndex:i] magnetLink]];
        [[NSWorkspace sharedWorkspace] openURL:magnet];
    }
}

- (IBAction)showPopover:(id)sender {
    if ([list count] > 0) {
        NSInteger i = [torrentTableView selectedRow];
        NSString *desc = [[NSString alloc] initWithString:[[list objectAtIndex:i] description]];
        NSString *user = [[NSString alloc] initWithString:[[list objectAtIndex:i] userName]];
        clicked = i;
        [botonUser setToolTip:user];
        [descriptionField setStringValue:desc];
        [popover showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMinXEdge];
    }
}

- (IBAction)showInWeb:(id)sender {
    NSString *url = @"http://thepiratebay.se";
    NSString *torrent = [[NSString alloc] initWithString:[[list objectAtIndex:clicked] url]];
    NSURL *urlTorrent = [[NSURL alloc] initWithString:[url stringByAppendingString:torrent]];
    [[NSWorkspace sharedWorkspace] openURL:urlTorrent];
}

- (IBAction)showUserInWeb:(id)sender {
    NSString *url = @"http://thepiratebay.se";
    NSString *user = [[NSString alloc] initWithString:[[list objectAtIndex:clicked] userURL]];
    NSURL *urlUser = [[NSURL alloc] initWithString:[url stringByAppendingString:user]];
    [[NSWorkspace sharedWorkspace] openURL:urlUser];
}

- (void)showAlertError:(NSString *)error {
    NSTimer *timer;
    if ([error isEqualTo:@"-1"]) {
        [errorLabel setStringValue:@"No se han encontrado resultados"];
        timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(clearLabel) userInfo:nil repeats:NO];
        NSLog(@"Error de busqueda");
    }
    else if ([error isEqualTo:@"-2"]) {
        [errorLabel setStringValue:@"Error de conexión con el servidor"];
        timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(clearLabel) userInfo:nil repeats:NO];
        NSLog(@"Error de conexion");
    }
}

- (void)clearLabel {
    [errorLabel setStringValue:@""];
}

- (void)loadDatainTableView {
    NSString *url = @"http://thepiratebay.se/search/";
    NSString *error = [[NSString alloc] init];
    NSString *toolTip = @"Resultados de: ";
    id torrents = nil;
    
    // Do the parse
    NSString *searchValue = [searchField stringValue];
    NSString *searchString = [url stringByAppendingFormat:searchValue];
    parseTPB = [[ParseWeb alloc] init];
    [self clearLabel];
    [progressGear startAnimation:self];
    
    // if not void searchField, not void torrents Array or not connection error
    torrents = [parseTPB loadHTMLbyURL:searchString];
    [list removeAllObjects];
    NSLog(@"%@",[searchString stringByReplacingOccurrencesOfString:@" " withString:@"%20"]);
    
    if ([torrents isNotEqualTo:@"-1"] && [torrents isNotEqualTo:@"-2"] && [torrents isNotEqualTo:@"void"]){
        for (Torrent *tor in torrents){
            [list addObject:tor];
        }
        /*if ([searchValue rangeOfString:@" "].location == NSNotFound || [searchValue rangeOfString:@"%20"].location == NSNotFound) {
            [recentSearches addObject:searchValue];
        }*/
        [torrentTableView setToolTip:[toolTip stringByAppendingString:searchValue]];
        [torrentTableView reloadData];
    }
    else {
        error = torrents;
        [list removeAllObjects];
        [torrentTableView reloadData];
        [torrentTableView setToolTip:@""];
        [self performSelectorOnMainThread:@selector(showAlertError:) withObject:error waitUntilDone:NO];
    }
    [searchField setStringValue:@""];
    [progressGear stopAnimation:self];
    
}

#pragma mark TableView methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [list count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    Torrent *t = [list objectAtIndex:row];
    NSString *identifier = [tableColumn identifier];
    return [t valueForKey:identifier];
}

@end
