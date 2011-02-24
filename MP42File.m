//
//  MP42File.m
//  Subler
//
//  Created by Damiano Galassi on 31/01/09.
//  Copyright 2009 Damiano Galassi. All rights reserved.
//

#import "MP42File.h"

@implementation MP42File

- (id) initWithExistingFile:(NSString *)path
{
    if (self = [super init])
	{
		fileHandle = MP4Read([path UTF8String], 0);
        filePath = path;
		if (!fileHandle) {
            [self release];
			return nil;
        }
		
        metadata = [[MP42Metadata alloc] initWithSourcePath:filePath fileHandle:fileHandle];
        MP4Close(fileHandle);
	}

	return self;
}

- (void) optimize
{
    BOOL noErr;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString * tempPath = [NSString stringWithFormat:@"%@%@", filePath, @".tmp"];

    noErr = MP4Optimize([filePath UTF8String], [tempPath UTF8String], MP4_DETAILS_ERROR);

    if (noErr) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
		
		NSError *error;
		[fileManager removeItemAtPath:filePath error:&error];
		[fileManager moveItemAtPath:tempPath toPath:filePath error:&error];
    }

    [pool release];
}

- (BOOL) writeToFilePath:(NSString *)absoulteFilePath flags:(uint64_t)flags 
				   error:(NSError **)outError removeAllTags:(BOOL)performRemove
{
    BOOL success = NO;
	filePath = absoulteFilePath;
    NSString *fileExtension = [filePath pathExtension];
    char* majorBrand = "mp42";
    char* supportedBrands[4];
    u_int32_t supportedBrandsCount = 0;

    if ([fileExtension isEqualToString:@"m4v"]) {
        majorBrand = "M4V ";
        supportedBrands[0] = majorBrand;
        supportedBrands[1] = "M4A ";
        supportedBrands[2] = "mp42";
        supportedBrandsCount = 3;
    }
    else if ([fileExtension isEqualToString:@"m4a"]) {
        majorBrand = "M4A ";
        supportedBrands[0] = majorBrand;
        supportedBrands[1] = "mp42";
        supportedBrandsCount = 2;
    }
    else {
        supportedBrands[0] = majorBrand;
        supportedBrandsCount = 1;
    }

    fileHandle = MP4CreateEx([filePath UTF8String], MP4_DETAILS_ERROR,
                             flags, 1, 1,
                             majorBrand, 0,
                             supportedBrands, supportedBrandsCount);
    if (fileHandle) {
        MP4SetTimeScale(fileHandle, 600);
        MP4Close(fileHandle);

        success = [self updateMP4File:outError removeAllTags:performRemove];
    }

    return success;
}

- (BOOL) updateMP4File:(NSError **)outError removeAllTags:(BOOL)performRemove
{
    fileHandle = MP4Modify([filePath UTF8String], MP4_DETAILS_ERROR, 0);
    if (fileHandle == MP4_INVALID_FILE_HANDLE) {
        if ( outError != NULL) {
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            [errorDetail setValue:@"Failed to open mp4 file" forKey:NSLocalizedDescriptionKey];
            *outError = [NSError errorWithDomain:@"MP42Error"
                                            code:100
                                        userInfo:errorDetail];
        }
        return NO;
    }
	
    if (metadata.isEdited || performRemove)
        [metadata writeMetadataWithFileHandle:fileHandle removeAll:performRemove];

    MP4Close(fileHandle);
    return YES;
}

- (void) dealloc
{
    [metadata release];
    [super dealloc];
}

@synthesize metadata;

@end
