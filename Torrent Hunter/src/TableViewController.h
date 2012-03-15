//
//  TableViewController.h
//  Torrent Hunter
//
//  Created by Alejandro Silva on 08/02/12.
//  Copyright (c) 2012 AH-Develop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
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
    IBOutlet NSDrawer *drawerSettings;
    NSInteger clicked;
    ParseWeb *parser;
    NSMutableArray *list;
    NSMutableArray *recentSearches;
}

@property (nonatomic, retain) ParseWeb *parser;
@property (weak) IBOutlet NSPopover *popoverTorrent;

- (IBAction)search:(id)sender;
- (IBAction)showPopover:(id)sender;
- (IBAction)showInWeb:(id)sender;
- (IBAction)showUserInWeb:(id)sender;
- (void)doubleClick:(id)sender;
- (void)showAlertError:(NSString *)error;
- (void)clearLabel;
- (void)loadDatainTableView:(NSString *)type;

@end
