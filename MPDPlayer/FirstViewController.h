//
//  FirstViewController.h
//  MPDPlayer
//
//  Created by Audie Sumaray on 2/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPDServer.h"
//#include <mpd/client.h>

@class AudioStreamer;

@interface FirstViewController : UIViewController {
    MPDServer *mpdServer;
    BOOL isPlaying;
    NSTimer * scrubberTimer;
    NSTimer * songTimer;
    AudioStreamer *streamer;
    __weak IBOutlet UIButton *skipBack;
    __weak IBOutlet UIButton *skipForward;
    __weak IBOutlet UIButton *playPause;
    __weak IBOutlet UISlider *volumeSlider;
    __weak IBOutlet UILabel *artistLabel;
    __weak IBOutlet UILabel *songLabel;
    __weak IBOutlet UISlider *scrubberSlider;
    __weak IBOutlet UILabel *curLocationLabel;
    __weak IBOutlet UILabel *lengthLabel;
}

@property (strong, nonatomic) MPDServer *mpdServer;
@property (strong, nonatomic) NSTimer *scrubberTimer;
@property (strong, nonatomic) NSTimer * songTimer;
@property (nonatomic) BOOL isPlaying;
@property (weak, nonatomic) IBOutlet UIButton *skipBack;
@property (weak, nonatomic) IBOutlet UIButton *skipForward;
@property (weak, nonatomic) IBOutlet UIButton *playPause;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *songLabel;
@property (weak, nonatomic) IBOutlet UISlider *scrubberSlider;
@property (weak, nonatomic) IBOutlet UILabel *curLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *lengthLabel;

- (void) updateView;
- (void) createStreamer;
- (void) destroyStreamer;
- (IBAction)playPauseTouched:(id)sender;
- (IBAction)scrubberScrubbing:(id)sender;


@end
