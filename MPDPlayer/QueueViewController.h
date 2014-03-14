//
//  QueueViewController.h
//  MPDPlayer
//
//  Created by Audie Sumaray on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPDServer.h"
#import "EGORefreshTableHeaderView.h"

@interface QueueViewController : UITableViewController <EGORefreshTableHeaderDelegate> {
    MPDServer *mpdServer;
    NSMutableArray *queueSongArray;
    NSMutableArray *queueArtistArray;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    BOOL isEditing;
    __weak IBOutlet UIBarButtonItem *editButton;
}

@property (nonatomic, strong) MPDServer *mpdServer;
@property (nonatomic, strong) NSMutableArray *queueSongArray;
@property (nonatomic, strong) NSMutableArray *queueArtistArray;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
