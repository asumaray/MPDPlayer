//
//  FirstViewController.m
//  MPDPlayer
//
//  Created by Audie Sumaray on 2/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FirstViewController.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "AudioStreamer.h"

@implementation FirstViewController
@synthesize mpdServer;
@synthesize isPlaying;
@synthesize skipBack;
@synthesize skipForward;
@synthesize playPause;
@synthesize volumeSlider;
@synthesize artistLabel;
@synthesize songLabel;
@synthesize scrubberSlider;
@synthesize curLocationLabel;
@synthesize lengthLabel;
@synthesize scrubberTimer;
@synthesize songTimer;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    AppDelegate *myAppDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    self.mpdServer = [myAppDelegate mpdServer];
    [self viewWillAppear:TRUE];
    [self createStreamer];
}

- (void)viewDidUnload
{
    [self setSkipBack:nil];
    [self setSkipForward:nil];
    [self setSkipForward:nil];
    [self setPlayPause:nil];
    [self setVolumeSlider:nil];
    [self setArtistLabel:nil];
    [self setSongLabel:nil];
    [self setScrubberSlider:nil];
    [self setCurLocationLabel:nil];
    [self setLengthLabel:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (mpdServer.isConnected) {
        [mpdServer initialize];
        [self updateView];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [scrubberTimer invalidate];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void) updateView {
    [streamer stop];
    [scrubberTimer invalidate];
    [scrubberSlider setValue:[mpdServer getCurElapsedTime]];
    if (mpdServer.isPlaying) {
        [streamer start];
        scrubberTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(scrubberTick) userInfo:nil repeats:TRUE];
        UIImage *img = [UIImage imageNamed:@"pause.png"];
        [playPause setImage:img forState:UIControlStateNormal];
    } else {
        UIImage *img = [UIImage imageNamed:@"play.png"];
        [playPause setImage:img forState:UIControlStateNormal];
    }
    [volumeSlider setValue:[mpdServer volume]];
    NSInteger songLength = [mpdServer getCurSongLength];
    NSInteger min = floor(songLength/60);
    NSInteger sec = round(songLength - min * 60);
    NSString * length;
    if (sec < 10) {
        length = [NSString stringWithFormat:@"%i:0%i", min, sec];
    } else {
        length = [NSString stringWithFormat:@"%i:%i", min, sec];
    }
    [lengthLabel setText:length];
    [scrubberSlider setMaximumValue:songLength];
    [self scrubberScrubbing:nil];
    self.songLabel.text = [mpdServer getCurSongTitle];
    self.artistLabel.text = [mpdServer getCurSongArtist];
}

- (IBAction)playPauseTouched:(id)sender {
    if (mpdServer.isPlaying) {
        [mpdServer pause];
        [streamer stop];
        UIImage *img = [UIImage imageNamed:@"play.png"];
        [playPause setImage:img forState:UIControlStateNormal];
        [mpdServer setIsPlaying:FALSE];
        [mpdServer setIsPaused:TRUE];
        [scrubberTimer invalidate];
    } else {
        scrubberTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(scrubberTick) userInfo:nil repeats:TRUE];
        [mpdServer play];
        [streamer start];
        UIImage *img = [UIImage imageNamed:@"pause.png"];
        [playPause setImage:img forState:UIControlStateNormal];
        [mpdServer setIsPlaying:TRUE];
        [mpdServer setIsPaused:FALSE];
    }
}

- (IBAction)skipForwardTouched:(id)sender {
    [scrubberTimer invalidate];
    [mpdServer nextSong];
    scrubberTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(scrubberTick) userInfo:nil repeats:TRUE];
    [mpdServer play];
    [mpdServer setIsPlaying:TRUE];
    [mpdServer setIsPaused:FALSE];
    [self updateView];
}

- (IBAction)skipBackTouched:(id)sender {
    [scrubberTimer invalidate];
    [mpdServer prevSong];
    scrubberTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(scrubberTick) userInfo:nil repeats:TRUE];
    [mpdServer play];
    [mpdServer setIsPlaying:TRUE];
    [mpdServer setIsPaused:FALSE];
    [self updateView];
}
 
- (IBAction)sliderChangeCompleted:(id)sender {
    [mpdServer setVolume:volumeSlider.value];
}

- (IBAction)scrubberScrubbing:(id)sender {
    NSInteger curTime = [scrubberSlider value];
    NSInteger min = floor(curTime/60);
    NSInteger sec = round(curTime - min * 60);
    NSString * length;
    if (sec < 10) {
        length = [NSString stringWithFormat:@"%i:0%i", min, sec];
    } else {
        length = [NSString stringWithFormat:@"%i:%i", min, sec];
    }
    [curLocationLabel setText:length];
}

- (IBAction)scrubberChangeCompleted:(id)sender {
    [scrubberTimer invalidate];
    [mpdServer seekCurSongTo:[scrubberSlider value]];
    scrubberTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(scrubberTick) userInfo:nil repeats:TRUE];
    [mpdServer play];
    [mpdServer setIsPlaying:TRUE];
    [mpdServer setIsPaused:FALSE];
    UIImage *img = [UIImage imageNamed:@"pause.png"];
    [playPause setImage:img forState:UIControlStateNormal];
}

- (void) scrubberTick {
    NSInteger curTime = [scrubberSlider value] + 1;
    [scrubberSlider setValue:curTime];
    NSInteger min = floor(curTime/60);
    NSInteger sec = round(curTime - min * 60);
    NSString * length;
    if (sec < 10) {
        length = [NSString stringWithFormat:@"%i:0%i", min, sec];
    } else {
        length = [NSString stringWithFormat:@"%i:%i", min, sec];
    }
    [curLocationLabel setText:length];
    
    if ([scrubberSlider value] == [scrubberSlider maximumValue]) {
        [self skipForwardTouched:nil];
    }
}

- (void)destroyStreamer
{
	if (streamer)
	{
		[[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:ASStatusChangedNotification
         object:streamer];
		
		[streamer stop];
		streamer = nil;
	}
}

- (void)createStreamer
{
	if (streamer) {
		return;
	}
    
	[self destroyStreamer];
    
	NSURL *url = [NSURL URLWithString:@"http://137.155.38.82:8000/mpd.mp3"];
	streamer = [[AudioStreamer alloc] initWithURL:url];
}

@end
