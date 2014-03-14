//
//  AlbumViewController.h
//  MPDPlayer
//
//  Created by Audie Sumaray on 2/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPDServer.h"
#import "EGORefreshTableHeaderView.h"

@interface AlbumViewController : UITableViewController <EGORefreshTableHeaderDelegate> {
    MPDServer *mpdServer;
    NSMutableArray *albums;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}

@property (nonatomic, strong) MPDServer *mpdServer;
@property (nonatomic, strong) NSMutableArray *albums;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
