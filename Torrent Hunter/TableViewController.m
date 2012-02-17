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
    NSInvocationOperation *task = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadDatainTableView) object:nil];
    
    /* Add the operation to the queue */
    [threads addOperation:task];
}

- (void)doubleClick:(id)sender {
    NSInteger i = [torrentTableView clickedRow];
    NSURL *magnet = [NSURL URLWithString:[[list objectAtIndex:i] magnetLink]];
    [[NSWorkspace sharedWorkspace] openURL:magnet];
}

- (void)showAlertError:(NSString *)error {
    // Alert dialogs declaration
    NSAlert *alertNoFinds = [NSAlert alertWithMessageText:@"" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"No se han encontrado resultados para su búsqueda"];
    NSAlert *alertNoConnection = [NSAlert alertWithMessageText:@"" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Error en la conexión con el servidor"];
    NSAlert *alertVoid = [NSAlert alertWithMessageText:@"" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"El campo de búsqueda está vacio"];
    
    if ([error isEqualTo:@"void"]) {
        NSLog(@"Campo de busqueda vacío");
        [alertVoid beginSheetModalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
    }
    else if ([error isEqualTo:@"-1"]) {
        NSLog(@"Error de busqueda");
        [alertNoFinds beginSheetModalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
    }
    else if ([error isEqualTo:@"-2"]) {
        NSLog(@"Error de conexion");
        [alertNoConnection beginSheetModalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
    }
}

- (void)loadDatainTableView {
    NSString *searchValue = @"http://thepiratebay.se/search/";
    NSString *error = [[NSString alloc] init];
    id torrents = nil;
    
    // Do the parse
    searchValue = [searchValue stringByAppendingFormat:[searchField stringValue]];
    parseTPB = [[ParseWeb alloc] init];
    [progressGear startAnimation:self];
    
    // if not void searchField, not void torrents Array or not connection error
    if ([[searchField stringValue] isNotEqualTo:@""]){
        torrents = [parseTPB loadHTMLbyURL:[searchValue stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
        [list removeAllObjects];
        
        if ([torrents isNotEqualTo:@"-1"] && [torrents isNotEqualTo:@"-2"]){
            for (Torrent *tor in torrents){
                [list addObject:tor];
            }
            [recentSearches addObject:searchValue];
            [torrentTableView reloadData];
        }
        else {
            error = torrents;
            [self performSelectorOnMainThread:@selector(showAlertError:) withObject:error waitUntilDone:NO];
        }
    }
    else{
        error = @"void";
        [self performSelectorOnMainThread:@selector(showAlertError:) withObject:error waitUntilDone:NO];
    }
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
