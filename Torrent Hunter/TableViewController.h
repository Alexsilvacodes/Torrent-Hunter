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
    IBOutlet NSProgressIndicator *progressWeb;
    IBOutlet NSTextField *errorLabel;
    IBOutlet NSTextField *descriptionField;
    IBOutlet NSButton *botonUser;
    IBOutlet NSTextField *labelNTorrent;
    IBOutlet NSWindow *windowWeb;
    IBOutlet WebView *webView;
    IBOutlet NSButton *botonSearch;
    NSInteger clicked;
    ParseWeb *parseTPB;
    NSMutableArray *list;
    NSMutableArray *recentSearches;
}

@property (nonatomic, retain) ParseWeb *parseTPB;
@property (weak) IBOutlet NSPopover *popoverTorrent;

- (IBAction)search:(id)sender;
- (IBAction)showPopover:(id)sender;
- (IBAction)showSettings:(id)sender;
- (IBAction)showInWeb:(id)sender;
- (IBAction)showUserInWeb:(id)sender;
- (IBAction)clearWebView:(id)sender;
- (void)doubleClick:(id)sender;
- (void)showAlertError:(NSString *)error;
- (void)clearLabel;
- (void)loadDatainTableView:(NSString *)type;

@end
