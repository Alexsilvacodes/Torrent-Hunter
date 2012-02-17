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

- (void)awakeFromNib {
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
    /* NSURLRequest *request = [NSURLRequest requestWithURL:magnet];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self]; */
    [[NSWorkspace sharedWorkspace] openURL:magnet];
}

- (void)loadDatainTableView {
    NSString *searchValue = @"http://thepiratebay.se/search/";
    id torrents = nil;
    // Alert dialogs declaration
    NSAlert *alertNoFinds = [NSAlert alertWithMessageText:@"" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"No se han encontrado resultados para su búsqueda"];
    NSAlert *alertNoConnection = [NSAlert alertWithMessageText:@"" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Error en la conexión con el servidor"];
    NSAlert *alertVoid = [NSAlert alertWithMessageText:@"" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"El campo de búsqueda está vacio"];
    
    // Do the parse
    searchValue = [searchValue stringByAppendingFormat:[searchField stringValue]];
    parseTPB = [[ParseWeb alloc] init];
    [progressGear startAnimation:self];
    
    // if not void searchField, not void torrents Array or not connection error
    if ([[searchField stringValue] isNotEqualTo:@""]){
        torrents = [parseTPB loadHTMLbyURL:searchValue];
        [list removeAllObjects];
        if ([torrents isNotEqualTo:@"-1"] && [torrents isNotEqualTo:@"-2"]){
            for (Torrent *tor in torrents){
                [list addObject:tor];
                [progressGear incrementBy:10];
            }
            [torrentTableView reloadData];
            
        }
        else if ([torrents isEqualTo:@"-1"]){
            [alertNoFinds beginSheetModalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
            [list removeAllObjects];
            NSLog(@"No existe resultado");
        }
        else{
            [alertNoConnection beginSheetModalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
            [list removeAllObjects];
            NSLog(@"Error conexion");
        }
    }
    else{
        [alertVoid beginSheetModalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
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
