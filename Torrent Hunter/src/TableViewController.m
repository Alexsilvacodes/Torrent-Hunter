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

@synthesize parser;
@synthesize popoverTorrent;

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
    [torrentTableView setDoubleAction:NSSelectorFromString(@"doubleClick:")];
}

- (IBAction)search:(id)sender {
    /* Operation queue */
    NSOperationQueue *threads = [NSOperationQueue new];
    
    /* Instance a NSInvocationOperation (subclass of NSOperation) */
    NSInvocationOperation *task = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadDatainTableView:) object:[sender identifier]];
    
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
    if ([list count] >0 && [torrentTableView selectedRow] != -1 ) {
        NSInteger i = [torrentTableView selectedRow];
        NSString *desc = [[NSString alloc] initWithString:[[list objectAtIndex:i] description]];
        NSString *user = [[NSString alloc] initWithString:[[list objectAtIndex:i] userName]];
        clicked = i;
        if ([[[list objectAtIndex:i] userURL] isEqualTo:@"NoUser"]) {
            [botonUser setEnabled:NO];
            [botonUser setToolTip:user];
        }
        else {
            [botonUser setEnabled:YES];
            [botonUser setToolTip:user];
        }
        [descriptionField setStringValue:desc];
        [popoverTorrent showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMinYEdge];
    }
}

- (IBAction)showInWeb:(id)sender {
    NSURL *urlTorrent = [[NSURL alloc] initWithString:[[list objectAtIndex:clicked] url]];
    [[NSWorkspace sharedWorkspace] openURL:urlTorrent];
}

- (IBAction)showUserInWeb:(id)sender {
    NSURL *urlUser = [[NSURL alloc] initWithString:[[list objectAtIndex:clicked] userURL]];
    [[NSWorkspace sharedWorkspace] openURL:urlUser];
}

- (void)showAlertError:(NSString *)error {
    NSTimer *timer;
    if ([error isEqualTo:@"-1"]) {
        [errorLabel setStringValue:@"No se han encontrado resultados"];
        timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(clearLabel) userInfo:nil repeats:NO];
        NSLog(@"Error de busqueda");
    }
    else if ([error isEqualTo:@"-2"]) {
        [errorLabel setStringValue:@"Error de conexión con el servidor"];
        timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(clearLabel) userInfo:nil repeats:NO];
        NSLog(@"Error de conexion");
    }
}

- (void)clearLabel {
    [errorLabel setStringValue:@""];
}

- (void)loadDatainTableView:(NSString *)type {
    NSString *urlTPB = @"http://thepiratebay.se/search/";
    NSString *urlDem = @"http://www.demonoid.me/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=0&quality=0&external=2&query=";
    NSString *error = [[NSString alloc] init];
    NSString *stringLabelNTorrent = [[NSString alloc] init];
    NSString *toolTip = @"Resultados de: ";
    id torrents = nil;
    id torrentsTPB = nil;
    id torrentsDem = nil;
    
    // Do the parse
    NSString *searchValue = [searchField stringValue];
    NSString *searchStringTPB = [urlTPB stringByAppendingString:searchValue];
    NSString *searchStringDem = [urlDem stringByAppendingString:searchValue];
    searchStringDem = [searchStringDem stringByAppendingString:@"&sort=S"];
    parser = [[ParseWeb alloc] init];
    [self clearLabel];
    [progressGear startAnimation:self];
    if ([drawerSettings state] == 1 || [drawerSettings state] == 2) {
        [drawerSettings performSelectorOnMainThread:@selector(close) withObject:nil waitUntilDone:NO];
    }
    [searchField setEnabled:NO];
    [botonSettings setEnabled:NO];
    [botonSearch setEnabled:NO];
    
    // if not void searchField, not void torrents Array or not connection error
    if ([checkTPB state] == NSOnState && [checkDem state] == NSOnState) {
        torrentsTPB = [parser loadHTMLbyURLTPB:searchStringTPB];
        torrentsDem = [parser loadHTMLbyURLDem:searchStringDem];
        if (([torrentsDem isNotEqualTo:@"void"] && [torrentsDem isNotEqualTo:@"-1"] && [torrentsDem isNotEqualTo:@"-2"]) && ([torrentsTPB isNotEqualTo:@"void"] && [torrentsDem isNotEqualTo:@"-1"] && [torrentsDem isNotEqualTo:@"-2"])) {
            torrents = torrentsTPB;
            [torrents addObjectsFromArray:torrentsDem];
        }
        else if (([torrentsDem isNotEqualTo:@"void"] && [torrentsDem isNotEqualTo:@"-1"] && [torrentsDem isNotEqualTo:@"-2"]) && ([torrentsTPB isEqualTo:@"void"] || [torrentsDem isEqualTo:@"-1"] || [torrentsDem isEqualTo:@"-2"])) {
            torrents = torrentsDem;
        }
        else if (([torrentsDem isEqualTo:@"void"] || [torrentsDem isEqualTo:@"-1"] || [torrentsDem isEqualTo:@"-2"]) && ([torrentsTPB isNotEqualTo:@"void"] && [torrentsDem isNotEqualTo:@"-1"] && [torrentsDem isNotEqualTo:@"-2"])) {
            torrents = torrentsTPB;
        }
        else {
            torrents = torrentsTPB;
        }
    }
    else if ([checkTPB state] == NSOnState && [checkDem state] == NSOffState) {
        torrents = [parser loadHTMLbyURLTPB:searchStringTPB];
    }
    else if ([checkTPB state] == NSOffState && [checkDem state] == NSOnState) {
        torrents = [parser loadHTMLbyURLDem:searchStringDem];
    }
    else {
        [errorLabel setStringValue:@"No se ha seleccionado ningún servicio"];
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(clearLabel) userInfo:nil repeats:NO];
        NSLog(@"No Service");
    }
    [list removeAllObjects];
    
    if ([torrents isNotEqualTo:@"-1"] && [torrents isNotEqualTo:@"-2"] && [torrents isNotEqualTo:@"void"]){
        
        for (Torrent *tor in torrents){
            [list addObject:tor];
        }
        /* Rellenar el tooltip de la tabla */
        [torrentTableView setToolTip:[toolTip stringByAppendingString:searchValue]];
        /* Rellenar el label inferior */
        stringLabelNTorrent = @"Resultados para '";
        stringLabelNTorrent = [stringLabelNTorrent stringByAppendingString:searchValue];
        stringLabelNTorrent = [stringLabelNTorrent stringByAppendingString:@"' - "];
        stringLabelNTorrent = [stringLabelNTorrent stringByAppendingString:[[NSNumber numberWithLong:[list count]] stringValue]];
        stringLabelNTorrent = [stringLabelNTorrent stringByAppendingString:@" resultados"];
        [labelNTorrent setStringValue:stringLabelNTorrent];
        /* Recargar los datos de la tabla */
        [torrentTableView reloadData];
        [torrentTableView setFocusedColumn:1];
    }
    else {
        error = torrents;
        [labelNTorrent setStringValue:@""];
        [list removeAllObjects];
        [searchField setFocusRingType:NSFocusRingOnly];
        [recentSearches removeLastObject];
        [torrentTableView reloadData];
        [torrentTableView setToolTip:@""];
        [self performSelectorOnMainThread:@selector(showAlertError:) withObject:error waitUntilDone:NO];
    }
    [searchField setStringValue:@""];
    [searchField setEnabled:YES];
    [botonSettings setEnabled:YES];
    [botonSearch setEnabled:YES];
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
