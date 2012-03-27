//
//  SearchOperation.m
//  Torrent Hunter
//
//  Created by Alejandro Silva on 21/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchOperation.h"

@implementation SearchOperation

-(void)start {
    if ([self isCancelled]) {
        return;
    }
    if ([[[NSUserDefaults alloc] valueForKey:@"CheckAppType"] isEqual:@"Dock"]) {
        [tableViewController loadDatainTableView];
    }
    else {
        [tableViewSUIController loadDatainTableView];
    }
}

@end
