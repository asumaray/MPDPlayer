//
//  AppDelegate.h
//  MPDPlayer
//
//  Created by Audie Sumaray on 2/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPDServer.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    MPDServer * mpdServer;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MPDServer *mpdServer;

@end
