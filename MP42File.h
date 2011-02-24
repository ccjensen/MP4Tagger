//
//  MP42File.h
//  Subler
//
//  Created by Damiano Galassi on 31/01/09.
//  Copyright 2009 Damiano Galassi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "mp4v2.h"
#import "MP42Metadata.h"

@interface MP42File : NSObject {
@private
    MP4FileHandle	fileHandle;
    NSString		*filePath;

@protected
    MP42Metadata    *metadata;
}

@property(readonly) MP42Metadata    *metadata;

- (id)   initWithExistingFile:(NSString *)path;

- (BOOL) writeToFilePath:(NSString *)absoulteFilePath flags:(uint64_t)flags 
				   error:(NSError **)outError removeAllTags:(BOOL)performRemove;
- (BOOL) updateMP4File:(NSError **)outError removeAllTags:(BOOL)performRemove;
- (void) optimize;

@end
