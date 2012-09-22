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

- (id)init {
    self = [super init];
    if (self) {
        list = [[NSMutableArray alloc] init];
        recentSearches = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)awakeFromNib {
    // set up growl notifications regardless of whether or not we're supposed to growl
    //[GrowlApplicationBridge setGrowlDelegate:self];
    
    searchEnded = NO;
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
    if ([list count] > 0 && [[torrentTableView selectedRowIndexes] count] == 1) {
        BOOL magnetAppSet = NO;
        NSString *plistPath = NSHomeDirectory();
        plistPath = [plistPath stringByAppendingString:@"/Library/Preferences/com.apple.LaunchServices.plist"];
        NSDictionary *plistData = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        NSArray *arrayData = [plistData objectForKey:[[plistData allKeys] objectAtIndex:0]];
        for (NSDictionary *elemDict in arrayData) {
            if ([[elemDict objectForKey:@"LSHandlerURLScheme"] isEqual:@"magnet"]) {
                magnetAppSet = YES;
            }
        }
        if (magnetAppSet) {
            NSInteger i = [torrentTableView clickedRow];
            NSURL *magnet = [NSURL URLWithString:[[list objectAtIndex:i] magnetLink]];
            //NSString *titleGrowl = @"Torrent Hunter";
            //NSString *msgGrowl = NSLocalizedString(@"Downloading click result", "Growl -> description");
            //[GrowlApplicationBridge notifyWithTitle:titleGrowl description:msgGrowl notificationName:nil iconData:nil priority:0 isSticky:NO clickContext:nil];
            [[NSWorkspace sharedWorkspace] openURL:magnet];
        }
        else {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:NSLocalizedString(@"Download", "Alert -> download")];
            [alert addButtonWithTitle:NSLocalizedString(@"Cancel", "Alert -> cancel")];
            [alert setMessageText:NSLocalizedString(@"Magnet Link application", "Alert -> title")];
            [alert setInformativeText:NSLocalizedString(@"No torrent download application founded. Do you want to download Transsmision client?", "Alert -> description")];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
        }
    }
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == NSAlertFirstButtonReturn) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.transmissionbt.com/"]];
    }
}

- (IBAction)showTorrentPanel:(id)sender {
    if (![panelTorrent isVisible] && [list count] >0 && [torrentTableView selectedRow] != -1) {
        NSInteger i = [torrentTableView selectedRow];
        NSString *desc = [[NSString alloc] initWithString:[[list objectAtIndex:i] description]];
        NSString *user = [[NSString alloc] initWithString:[[list objectAtIndex:i] userName]];
        NSString *descComp = [[NSString alloc] initWithString:[parser getDesc:[[list objectAtIndex:i] url]]];
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
        [completeDescField setString:descComp];
        [panelTorrent setFrameOrigin:NSMakePoint([window frame].origin.x+830, [window frame].origin.y+130)];
        [panelTorrent setIsVisible:YES];
    }
    else {
        [panelTorrent close];
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
        [errorLabel setStringValue:NSLocalizedString(@"No results found", "Error -> no results")];
        timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(clearLabel) userInfo:nil repeats:NO];
        NSLog(@"Error de busqueda");
    }
    else if ([error isEqualTo:@"-2"]) {
        [errorLabel setStringValue:NSLocalizedString(@"Error connecting to server", "Error -> connection")];
        timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(clearLabel) userInfo:nil repeats:NO];
        NSLog(@"Error de conexion");
    }
}

- (void)clearLabel {
    [errorLabel setStringValue:@""];
}

- (void)triggerTimeout60 {
    timerTimeout = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(searchTimeoutAction60) userInfo:nil repeats:NO];
}

- (void)searchTimeoutAction60 {
    if (!searchEnded) {
        [menuPreferences setEnabled:YES];
        [botonSettings setEnabled:YES];
        [botonSearch setEnabled:YES];
        [searchField setStringValue:@""];
        [searchField setEnabled:YES];
        [self search:nil];
    }
    searchEnded = NO;
}

- (void)loadDatainTableView:(NSString *)type {
    NSString *urlTPB = @"http://thepiratebay.se/search/";
    //NSString *urlDem = @"http://www.demonoid.me/files/?to=0&uid=0&category=";
    NSString *error = [[NSString alloc] init];
    NSString *stringLabelNTorrent = [[NSString alloc] init];
    NSString *toolTip = NSLocalizedString(@"Results for: ", "Tooltip -> results");
    id torrents = nil;
    //id torrentsTPB = nil;
    //id torrentsDem = nil;
    
    // Do the parse
    NSString *searchValue = [searchField stringValue];
    NSString *searchStringTPB = [urlTPB stringByAppendingString:searchValue];
    
    if ([radioAll state] == NSOnState) {
        // Todo
        //urlDem = [urlDem stringByAppendingString:@"0"];
        searchStringTPB = [searchStringTPB stringByAppendingString:@"/0/7/0"];
    }
    else if ([radioApps state] == NSOnState) {
        // Apps
        //urlDem = [urlDem stringByAppendingString:@"5"];
        searchStringTPB = [searchStringTPB stringByAppendingString:@"/0/7/300"];
    }
    else if ([radioVids state] == NSOnState) {
        // Videos
        //urlDem = [urlDem stringByAppendingString:@"1"];
        searchStringTPB = [searchStringTPB stringByAppendingString:@"/0/7/200"];
    }
    else if ([radioGames state] == NSOnState) {
        // Games
        //urlDem = [urlDem stringByAppendingString:@"4"];
        searchStringTPB = [searchStringTPB stringByAppendingString:@"/0/7/400"];
    }
    else if ([radioMusic state] == NSOnState) {
        // Music
        //urlDem = [urlDem stringByAppendingString:@"2"];
        searchStringTPB = [searchStringTPB stringByAppendingString:@"/0/7/101"];
    }
    
    //urlDem = [urlDem stringByAppendingString:@"&subcategory=0&language=0&seeded=0&quality=0&external=2&query="];
    //NSString *searchStringDem = [urlDem stringByAppendingString:searchValue];
    //searchStringDem = [searchStringDem stringByAppendingString:@"&sort=S"];
    parser = [[ParseWeb alloc] init];
    [self clearLabel];
    [progressGear startAnimation:self];
    if ([drawerSettings state] == 1 || [drawerSettings state] == 2) {
        [drawerSettings performSelectorOnMainThread:@selector(close) withObject:nil waitUntilDone:NO];
    }
    [menuPreferences setEnabled:NO];
    [searchField setEnabled:NO];
    [botonSettings setEnabled:NO];
    [botonSearch setEnabled:NO];

    [self performSelectorOnMainThread:@selector(triggerTimeout60) withObject:nil waitUntilDone:NO];
    
    // if not void searchField, not void torrents Array or not connection error
    /*if ([checkTPB state] == NSOnState && [checkDem state] == NSOnState) {
        torrentsTPB = [parser loadHTMLbyURLTPB:searchStringTPB];
        //torrentsDem = [parser loadHTMLbyURLDem:searchStringDem];
        if (([torrentsDem isNotEqualTo:@"void"] && [torrentsDem isNotEqualTo:@"-1"] && [torrentsDem isNotEqualTo:@"-2"]) && ([torrentsTPB isNotEqualTo:@"void"] && [torrentsDem isNotEqualTo:@"-1"] && [torrentsDem isNotEqualTo:@"-2"])) {
            torrents = torrentsTPB;
            [torrents addObjectsFromArray:torrentsDem];
        }
        else if (([torrentsDem isNotEqualTo:@"void"] && [torrentsDem isNotEqualTo:@"-1"] && [torrentsDem isNotEqualTo:@"-2"]) && ([torrentsTPB isEqualTo:@"void"] || [torrentsTPB isEqualTo:@"-1"] || [torrentsTPB isEqualTo:@"-2"])) {
            torrents = torrentsDem;
        }
        else if (([torrentsDem isEqualTo:@"void"] || [torrentsDem isEqualTo:@"-1"] || [torrentsDem isEqualTo:@"-2"]) && ([torrentsTPB isNotEqualTo:@"void"] && [torrentsTPB isNotEqualTo:@"-1"] && [torrentsTPB isNotEqualTo:@"-2"])) {
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
        [errorLabel setStringValue:NSLocalizedString(@"No service has been selected", "ErrorLabel -> no service selected")];
        [drawerSettings performSelectorOnMainThread:@selector(open) withObject:nil waitUntilDone:NO];
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(clearLabel) userInfo:nil repeats:NO];
        NSLog(@"No Service");
    }*/
    [list removeAllObjects];
    
    torrents = [parser loadHTMLbyURLTPB:searchStringTPB];
    
    if ([torrents isNotEqualTo:@"-1"] && [torrents isNotEqualTo:@"-2"] && [torrents isNotEqualTo:@"void"]){
        for (Torrent *tor in torrents){
            [list addObject:tor];
        }
        /* Rellenar el tooltip de la tabla */
        [torrentTableView setToolTip:[toolTip stringByAppendingString:searchValue]];
        /* Rellenar el label inferior */
        stringLabelNTorrent = NSLocalizedString(@"Results for: '", "LabelTorrent -> results");
        stringLabelNTorrent = [stringLabelNTorrent stringByAppendingString:searchValue];
        stringLabelNTorrent = [stringLabelNTorrent stringByAppendingString:NSLocalizedString(@"' - showing ", "LabelTorrent -> showing")];
        stringLabelNTorrent = [stringLabelNTorrent stringByAppendingString:[[NSNumber numberWithLong:[list count]] stringValue]];
        stringLabelNTorrent = [stringLabelNTorrent stringByAppendingString:NSLocalizedString(@" results of ", "LabelTorrent -> for")];
        stringLabelNTorrent = [stringLabelNTorrent stringByAppendingString:[[NSNumber numberWithInt:[parser nItems]] stringValue]];
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
    [menuPreferences setEnabled:YES];
    [searchField setEnabled:YES];
    [botonSettings setEnabled:YES];
    [botonSearch setEnabled:YES];
    [progressGear stopAnimation:self];
    searchEnded = YES;
    /* Cancelar timer */
    [timerTimeout invalidate];
    
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

- (void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
    [list sortUsingDescriptors:[tableView sortDescriptors]];
    [tableView reloadData];
}

- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn
{
	[tableView setFocusRingType:0];
}

@end
