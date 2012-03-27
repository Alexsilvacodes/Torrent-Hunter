//
//  TableViewSUIController.h
//  Torrent Hunter
//
//  Created by Alejandro Silva on 21/03/12.
//  Copyright (c) 2012 AH-Develop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParseWeb.h"

@interface TableViewSUIController : NSObject <NSTableViewDataSource> {
@private
    IBOutlet NSTableView *torrentTableView;
    IBOutlet NSSearchField *searchField;
    IBOutlet NSProgressIndicator *progressGear;
    IBOutlet NSTextField *errorLabel;
    IBOutlet NSTextField *descriptionField;
    IBOutlet NSButton *botonUser;
    IBOutlet NSButton *botonSearch;
    IBOutlet NSButton *botonSettings;
    IBOutlet NSButton *checkTPB;
    IBOutlet NSButton *checkDem;
    NSInteger clicked;
    ParseWeb *parser;
    NSMutableArray *list;
    NSMutableArray *recentSearches;
}

@property (nonatomic, retain) ParseWeb *parser;
@property (weak) IBOutlet NSPopover *popoverTorrent;
@property (weak) IBOutlet NSPopover *popoverSettings;

- (IBAction)search:(id)sender;
- (IBAction)showSettings:(id)sender;
- (IBAction)showPopover:(id)sender;
- (IBAction)showInWeb:(id)sender;
- (IBAction)showUserInWeb:(id)sender;
- (void)doubleClick:(id)sender;
- (void)showAlertError:(NSString *)error;
- (void)clearLabel;
- (void)loadDatainTableView;

@end
