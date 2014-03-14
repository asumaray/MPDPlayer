//
//  ArtistViewController.h
//  MPDPlayer
//
//  Created by Audie Sumaray on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPDServer.h"
#import "AlbumViewController.h"
#import "EGORefreshTableHeaderView.h"

@interface ArtistViewController : UITableViewController <EGORefreshTableHeaderDelegate> {
    MPDServer *mpdServer;
    NSMutableArray *artists;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}

@property (nonatomic, strong) MPDServer *mpdServer;
@property (nonatomic, strong) NSMutableArray *artists;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
