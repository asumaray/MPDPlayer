//
//  MPDServer.h
//  MPDPlayer
//
//  Created by Audie Sumaray on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <mpd/client.h>

@interface MPDServer : NSObject {
    struct mpd_connection * mpdConnection;
    struct mpd_status * mpdStatus;
    struct mpd_song *curSong;
    enum mpd_state mpdState;
    BOOL isPlaying;
    BOOL isPaused;
    NSInteger volume;
}

@property (nonatomic) struct mpd_connection * mpdConnection;
@property (nonatomic) struct mpd_status *mpdStatus;
@property (nonatomic) struct mpd_song *curSong;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic) BOOL isPaused;


- (bool) isConnected;
- (void) refreshConnection;
- (void) initialize;
- (void) connectToHost:(char *)host atPort:(unsigned)port;
- (void) sendPassword:(char *)password;
- (NSMutableArray *) getArtists;
- (NSMutableArray *) getAlbumsForArtist:(NSString *)artist;
- (NSMutableArray *) getSongsForAlbum:(NSString *)album;
- (NSMutableArray *) getQueueSongs;
- (NSMutableArray *) getQueueArtists;
- (void) setVolume:(NSInteger)vol;
- (NSInteger) getCurElapsedTime;
- (void) seekCurSongTo:(unsigned)pos;
- (NSInteger) volume;
- (void) play;
- (void) pause;
- (void) playSong:(NSString *)song;
- (void) playSongAtQueuePos:(int)pos;
- (void) nextSong;
- (void) prevSong;
- (void) moveSongFrom:(int)from to:(int)to;
- (void) deleteSongAtPos:(int)pos;
- (void) updateCurSong;
- (NSString *) getCurSongTitle;
- (NSString *) getCurSongArtist;
- (unsigned) getCurSongLength;

@end
