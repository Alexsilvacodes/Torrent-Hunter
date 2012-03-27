//
//  SearchOperation.h
//  Torrent Hunter
//
//  Created by Alejandro Silva on 21/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TableViewController.h"
#import "TableViewSUIController.h"

@class TableViewController;
@interface SearchOperation : NSOperation {
    TableViewController *tableViewController;
    TableViewSUIController *tableViewSUIController;
}

@end
