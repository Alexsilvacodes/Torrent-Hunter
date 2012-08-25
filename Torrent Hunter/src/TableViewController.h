//
//  TableViewController.h
//  Torrent Hunter
//
//  Created by Alejandro Silva on 08/02/12.
//  Copyright (c) 2012 AH-Develop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <Growl/Growl.h>
#import "ParseWeb.h"

@interface TableViewController : NSObject <NSTableViewDataSource> {
@private
    IBOutlet NSTableView *torrentTableView;
    IBOutlet NSSearchField *searchField;
    IBOutlet NSWindow *window;
    IBOutlet NSProgressIndicator *progressGear;
    IBOutlet NSTextField *errorLabel;
    IBOutlet NSTextField *descriptionField;
    IBOutlet NSTextField *labelNTorrent;
    IBOutlet NSButton *botonUser;
    IBOutlet NSButton *botonSearch;
    IBOutlet NSButton *botonSettings;
    IBOutlet NSButton *checkTPB;
    IBOutlet NSButton *checkDem;
    IBOutlet NSButtonCell *radioAll;
    IBOutlet NSButtonCell *radioApps;
    IBOutlet NSButtonCell *radioVids;
    IBOutlet NSButtonCell *radioGames;
    IBOutlet NSButtonCell *radioMusic;
    IBOutlet NSMenuItem *menuPreferences;
    IBOutlet NSDrawer *drawerSettings;
    NSInteger clicked;
    ParseWeb *parser;
    NSMutableArray *list;
    NSMutableArray *recentSearches;
    NSTimer *timerTimeout;
    BOOL searchEnded;
}

@property (nonatomic, retain) ParseWeb *parser;
@property (weak) IBOutlet NSPopover *popoverTorrent;

- (IBAction)search:(id)sender;
- (IBAction)showPopover:(id)sender;
- (IBAction)showInWeb:(id)sender;
- (IBAction)showUserInWeb:(id)sender;
- (void)doubleClick:(id)sender;
- (void)showAlertError:(NSString *)error;
- (void)triggerTimeout60;
- (void)searchTimeoutAction60;
- (void)clearLabel;
- (void)loadDatainTableView:(NSString *)type;
- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;

@end
