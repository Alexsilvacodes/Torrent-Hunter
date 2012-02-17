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
    ParseWeb *parseTPB;
    NSMutableArray *list;
}

@property (nonatomic, retain) ParseWeb *parseTPB;

- (IBAction)search:(id)sender;
- (void)doubleClick:(id)sender;
- (void)loadDatainTableView;

@end
