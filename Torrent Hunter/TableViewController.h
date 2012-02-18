//
//  TableViewController.h
//  Torrent Hunter
//
//  Created by Alejandro Silva on 08/02/12.
//  Copyright (c) 2012 AH-Develop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParseWeb.h"

@interface TableViewController : NSObject <NSTableViewDataSource> {
@private
    IBOutlet NSTableView *torrentTableView;
    IBOutlet NSSearchField *searchField;
    IBOutlet NSWindow *window;
    IBOutlet NSProgressIndicator *progressGear;
    IBOutlet NSTextField *errorLabel;
    IBOutlet NSPopover *itemTorrent;
    IBOutlet NSTextField *descriptionField;
    IBOutlet NSButton *botonUser;
    NSInteger clicked;
    ParseWeb *parseTPB;
    NSMutableArray *list;
    NSMutableArray *recentSearches;
}

@property (nonatomic, retain) ParseWeb *parseTPB;
@property (weak) IBOutlet NSPopover *popover;

- (IBAction)search:(id)sender;
- (IBAction)showPopover:(id)sender;
- (IBAction)showInWeb:(id)sender;
- (IBAction)showUserInWeb:(id)sender;
- (void)doubleClick:(id)sender;
- (void)showAlertError:(NSString *)error;
- (void)clearLabel;
- (void)loadDatainTableView;

@end
