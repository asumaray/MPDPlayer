//
//  MPDServer.m
//  MPDPlayer
//
//  Created by Audie Sumaray on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MPDServer.h"

@implementation MPDServer
@synthesize mpdConnection, mpdStatus, isPlaying, isPaused, curSong;

- (bool) isConnected {
    if (mpd_connection_get_error(self.mpdConnection) == MPD_ERROR_SUCCESS) {
        return true;
    } else {
        return false;
    }
}

- (void) initialize {
    [self refreshConnection];
    mpdStatus = mpd_run_status(mpdConnection);
    if (mpdStatus == NULL) {
        NSLog(@"Error getting server status");
    }
    
    curSong = mpd_run_current_song(mpdConnection);
    mpdState = mpd_status_get_state(mpdStatus);
    if (mpdState == MPD_STATE_PLAY) {
        isPlaying = true;
        isPaused = false;
    } else if (mpdState == MPD_STATE_PAUSE) {
        isPaused = true;
        isPlaying = false;
    } else {
        isPlaying = false;
        isPaused = false;
    }
}

- (void) connectToHost:(char *)host atPort:(unsigned int)port {
    self.mpdConnection = mpd_connection_new(host, port, 10000);
    if (mpd_connection_get_error(self.mpdConnection) == MPD_ERROR_SUCCESS) {
        //NSLog(@"Connected to server");
    } else {
        NSLog(@"Error connecting to server");
    }
}

- (void) sendPassword:(char *)password {
    if(!mpd_run_password(self.mpdConnection, password)) {
        NSLog(@"Password Denited");
    }
}

- (void) refreshConnection {
    mpd_connection_free(mpdConnection);
    [self connectToHost:"Lampb.vf.cnu.edu" atPort:6600];
    [self sendPassword:"cnu2012"];
}

- (struct mpd_connection *) getConnection {
    return mpdConnection;
}

- (NSMutableArray *) getArtists {
    [self refreshConnection];
    if(mpd_send_command(self.mpdConnection, "list artist", nil)) {
        NSMutableArray * artists = [[NSMutableArray alloc] init];
        struct mpd_pair * pair = mpd_recv_pair(self.mpdConnection);
        while (pair != NULL) {
            [artists addObject:[NSString stringWithUTF8String:pair->value]];
            mpd_return_pair(self.mpdConnection, pair);
            pair = mpd_recv_pair(self.mpdConnection);
        }
        [artists sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        return artists;
    } else {
        NSLog(@"Error returning artists");
        return nil;
    }
}

- (NSMutableArray *) getAlbumsForArtist:(NSString *)artist {
    NSString * searchCommand = [NSString stringWithFormat:@"list album artist \"%@\"", artist];
    if(mpd_send_command(self.mpdConnection, [searchCommand cStringUsingEncoding:NSUTF8StringEncoding] , NULL)) {
        NSMutableArray * albums = [[NSMutableArray alloc] init];
        struct mpd_pair * pair = mpd_recv_pair(self.mpdConnection);
        while (pair != NULL) {
            [albums addObject:[NSString stringWithUTF8String:pair->value]];
            mpd_return_pair(self.mpdConnection, pair);
            pair = mpd_recv_pair(self.mpdConnection);
        }
        [albums sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        return albums;
    } else {
        NSLog(@"Error returning artists");
        return nil;
    }
}

- (NSMutableArray *) getSongsForAlbum:(NSString *)album {
    NSString * searchCommand = [NSString stringWithFormat:@"list title album \"%@\"", album];
    if(mpd_send_command(self.mpdConnection, [searchCommand cStringUsingEncoding:NSUTF8StringEncoding] , NULL)) {
        NSMutableArray * songs = [[NSMutableArray alloc] init];
        struct mpd_pair * pair = mpd_recv_pair(self.mpdConnection);
        while (pair != NULL) {
            [songs addObject:[NSString stringWithUTF8String:pair->value]];
            mpd_return_pair(self.mpdConnection, pair);
            pair = mpd_recv_pair(self.mpdConnection);
        }
        //[songs sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        return songs;
    } else {
        NSLog(@"Error returning artists");
        return nil;
    }
}

- (NSMutableArray *) getQueueSongs {
    mpd_send_list_queue_meta(mpdConnection);
    NSMutableArray * queue = [[NSMutableArray alloc] init];
    struct mpd_pair * pair = mpd_recv_pair_named(self.mpdConnection, "Title");
    while (pair != NULL) {
        [queue addObject:[NSString stringWithUTF8String:pair->value]];
        mpd_return_pair(self.mpdConnection, pair);
        pair = mpd_recv_pair_named(self.mpdConnection, "Title");
    }
    return queue;
}

- (NSMutableArray *) getQueueArtists {
    mpd_send_list_queue_meta(mpdConnection);
    NSMutableArray * queue = [[NSMutableArray alloc] init];
    struct mpd_pair * pair = mpd_recv_pair_named(self.mpdConnection, "Artist");
    while (pair != NULL) {
        [queue addObject:[NSString stringWithUTF8String:pair->value]];
        mpd_return_pair(self.mpdConnection, pair);
        pair = mpd_recv_pair_named(self.mpdConnection, "Artist");
    }
    return queue;
}

- (void) playSong:(NSString *)song {
    mpd_search_db_songs(mpdConnection, FALSE);
    mpd_search_add_tag_constraint(mpdConnection, MPD_OPERATOR_DEFAULT, MPD_TAG_TITLE, [song cStringUsingEncoding:NSUTF8StringEncoding]);
    mpd_search_commit(mpdConnection);
    struct mpd_song * returnedSong = mpd_recv_song(mpdConnection);
    const char * songPath = mpd_song_get_uri(returnedSong);
    NSLog([[NSString alloc] initWithUTF8String:songPath]);
    NSString * addCommand = [NSString stringWithFormat:@"add \"%@\"", [[NSString alloc] initWithUTF8String:songPath]];
    if (mpd_send_command(mpdConnection, [addCommand cStringUsingEncoding:NSUTF8StringEncoding], NULL)) {
        NSLog(@"Song added");
    } else {
        NSLog(@"Error adding song");
    }
}

- (NSInteger) getCurElapsedTime {
    [self refreshConnection];
    mpdStatus = mpd_run_status(mpdConnection);
    return mpd_status_get_elapsed_time(mpdStatus);
}

- (void) seekCurSongTo:(unsigned)pos {
    [self refreshConnection];
    unsigned cur = mpd_song_get_id(curSong);
    mpd_send_seek_id(mpdConnection, cur, pos);
}

- (void) setVolume:(NSInteger) vol{
    [self refreshConnection];
    if (mpd_run_set_volume(mpdConnection, vol)) {
        NSLog(@"Volume Set");
    } else {
        NSLog(@"Error setting volume");
    }
}

- (NSInteger) volume {
    NSInteger temp = mpd_status_get_volume(mpdStatus);
    if (temp == -1) {
        NSLog(@"Error getting volume from sever");
    }
    return temp;
}

- (BOOL) isPlaying {
    return isPlaying;
}

- (BOOL) isPaused {
    return isPaused;
}

- (void) play {
    [self refreshConnection];
    mpd_send_play(mpdConnection);
}

- (void) pause {
    [self refreshConnection];
    mpd_send_pause(mpdConnection, true);
}

- (void) playSongAtQueuePos:(int)pos {
    struct mpd_song * selectedSong = mpd_run_get_queue_song_pos(mpdConnection, pos);
    unsigned int songID = mpd_song_get_id(selectedSong);
    mpd_send_play_id(mpdConnection, songID);
}

- (void) nextSong {
    [self refreshConnection];
    if (mpd_run_next(mpdConnection)) {
        NSLog(@"Next Song");
        curSong = mpd_run_current_song(mpdConnection);
    } else {
        NSLog(@"Error skipping");
    }
}

- (void) prevSong {
    [self refreshConnection];
    if (mpd_run_previous(mpdConnection)) {
        NSLog(@"Prev Song");
        curSong = mpd_run_current_song(mpdConnection);
    } else {
        NSLog(@"Error skipping");
    }
}

- (void) moveSongFrom:(int)from to:(int)to {
    if (mpd_send_move(mpdConnection, from, to)) {
        NSLog(@"Song moved successfully");
    } else {
        NSLog(@"Error moving song");
    }
}

- (void) deleteSongAtPos:(int)pos {
    if (mpd_send_delete(mpdConnection, pos)) {
        NSLog(@"Song deleted");
    } else {
        NSLog(@"Error deleting song");
    }gi
}

- (void) updateCurSong {
    curSong = mpd_run_current_song(mpdConnection);
}

- (unsigned) getCurSongLength {
    [self refreshConnection];
    if (mpd_song_get_tag(curSong, MPD_TAG_TITLE, 0)) {
        return  mpd_song_get_duration(curSong);
    } else {
        NSLog(@"Error returning song length");
        return 0;
    }
}

- (NSString *) getCurSongTitle {
    if (mpd_song_get_tag(curSong, MPD_TAG_TITLE, 0)) {
        const char * songTitle = mpd_song_get_tag(curSong, MPD_TAG_TITLE, 0);
        return [NSString stringWithUTF8String:songTitle];
    } else {
        return @"No song currently selected";
    }
}

- (NSString *) getCurSongArtist {
    if (mpd_song_get_tag(curSong, MPD_TAG_ARTIST, 0)) {
        const char * songArtist = mpd_song_get_tag(curSong, MPD_TAG_ARTIST, 0);
        return [NSString stringWithUTF8String:songArtist];
    } else {
        return @"";
    }
}

@end
