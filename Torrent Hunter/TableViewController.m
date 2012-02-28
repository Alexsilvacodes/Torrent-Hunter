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
    [progressWeb setUsesThreadedAnimation:YES];
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

- (void)clearWebView:(id)sender {
    [[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]]; 
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

- (void)showSettings:(id)sender {
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
    NSString *url = @"http://thepiratebay.se/search/";
    NSString *error = [[NSString alloc] init];
    NSString *stringLabelNTorrent = [[NSString alloc] init];
    NSString *toolTip = @"Resultados de: ";
    id torrents = nil;
    
    // Do the parse
    NSString *searchValue = [searchField stringValue];
    NSString *searchString = [url stringByAppendingString:searchValue];
    searchString = [searchString stringByAppendingString:@""];
    parseTPB = [[ParseWeb alloc] init];
    [self clearLabel];
    [progressGear startAnimation:self];
    [searchField setEnabled:NO];
    [botonSearch setEnabled:NO];
    
    // if not void searchField, not void torrents Array or not connection error
    torrents = [parseTPB loadHTMLbyURLTPB:searchString];
    [list removeAllObjects];
    
    if ([torrents isNotEqualTo:@"-1"] && [torrents isNotEqualTo:@"-2"] && [torrents isNotEqualTo:@"void"]){
        for (Torrent *tor in torrents){
            [list addObject:tor];
        }
        /* Rellenar el tooltip de la tabla */
        [torrentTableView setToolTip:[toolTip stringByAppendingString:[parseTPB resultString]]];
        /* Rellenar el label inferior */
        stringLabelNTorrent = [parseTPB resultString];
        stringLabelNTorrent = [stringLabelNTorrent stringByAppendingString:@" - "];
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
