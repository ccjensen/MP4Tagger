//
//  MP42Metadata.m
//  Subler
//
//  Created by Damiano Galassi on 06/02/09.
//  Copyright 2009 Damiano Galassi. All rights reserved.
//

#import "MP42Metadata.h"
#import "MP42Utilities.h"
#import "RegexKitLite.h"

typedef struct iTMF_rating_t
{
	char * rating;
	char * english_name;
} iTMF_rating_t;

static const iTMF_rating_t rating_strings[] = {
    {"mpaa|NR|000|", "Not Rated"},          // 0
    {"mpaa|G|100|", "G"},
    {"mpaa|PG|200|", "PG"},
    {"mpaa|PG-13|300|", "PG-13"},
    {"mpaa|R|400|", "R" },
    {"mpaa|NC-17|500|", "NC-17"},
    {"mpaa|Unrated|???|", "Unrated"},
    {"", ""},
    {"us-tv|TV-Y|100|", "TV-Y"},            // 8
    {"us-tv|TV-Y7|200|", "TV-Y7"},
    {"us-tv|TV-G|300|", "TV-G"},
    {"us-tv|TV-PG|400|", "TV-PG"},
    {"us-tv|TV-14|500|", "TV-14"},
    {"us-tv|TV-MA|600|", "TV-MA"},
    {"us-tv|Unrated|???|", "Unrated"},
    {"", ""},
    {"uk-movie|NR|000|", "Not Rated"},      // 16
    {"uk-movie|U|100|", "U"},
    {"uk-movie|Uc|150|", "Uc"},
    {"uk-movie|PG|200|", "PG"},
    {"uk-movie|12|300|", "12"},
    {"uk-movie|12A|325|", "12A"},
    {"uk-movie|15|350|", "15"},
    {"uk-movie|18|400|", "18"},
    {"uk-movie|E|600|", "E" },
    {"uk-movie|Unrated|???|", "Unrated"},
    {"", ""},
    {"uk-tv|Caution|500|", "Caution"},      // 27
    {"", ""},
    {"de-movie|FSK 0|100|", "FSK 0"},		// 29
    {"de-movie|FSK 6|200|", "FSK 6"},
    {"de-movie|FSK 12|300|", "FSK 12"},
    {"de-movie|FSK 16|400|", "FSK 16"},
    {"de-movie|FSK 18|500|", "FSK 18"},
    {"", ""},
    {"", "Unknown"},                        // 35
    {NULL, NULL},
};

@interface MP42Metadata (Private)

-(void) readMetaDataFromFileHandle:(MP4FileHandle)fileHandle;

@end

@implementation MP42Metadata

-(id)initWithSourcePath:(NSString *)source fileHandle:(MP4FileHandle)fileHandle
{
	if ((self = [super init]))
	{
		sourcePath = source;
        tagsDict = [[NSMutableDictionary alloc] init];
		
        [self readMetaDataFromFileHandle: fileHandle];
        isEdited = NO;
        isArtworkEdited = NO;
	}
	
    return self;
}

- (NSString*) stringFromArray:(NSArray *)array
{
    NSString *result = [NSString string];
    for (NSDictionary* name in array) {
        if ([result length])
            result = [result stringByAppendingString:@", "];
        result = [result stringByAppendingString:[name valueForKey:@"name"]];
    }
    return result;
}

- (NSArray *) dictArrayFromString:(NSString *)data
{
    NSString *splitElements  = @",\\s+";
    NSArray *stringArray = [data componentsSeparatedByRegex:splitElements];
    NSMutableArray *dictElements = [[[NSMutableArray alloc] init] autorelease];
    for (NSString *name in stringArray) {
        [dictElements addObject:[NSDictionary dictionaryWithObject:name forKey:@"name"]];
    }
    return dictElements;
}

- (NSArray *) availableRatings
{
    NSMutableArray *ratingsArray = [[NSMutableArray alloc] init];
    iTMF_rating_t *rating;
    for ( rating = (iTMF_rating_t*) rating_strings; rating->english_name; rating++ )
        [ratingsArray addObject:[NSString stringWithUTF8String:rating->english_name]];
	
    return [ratingsArray autorelease];
}

- (NSArray *) availableMediaKinds
{
	return [NSArray arrayWithObjects:
			@"Movie",			//0
			@"Normal",			//1
			@"Audiobook",		//2
			@"",				//3
			@"",				//4
			@"Whacked Bookmark",//5 
			@"Music Video",		//6
			@"",				//7
			@"",				//8
			@"Short Film",		//9
			@"TV Show",			//10
			@"Booklet", nil];	//11
}

- (NSArray *) availableContentRatings
{
	return [NSArray arrayWithObjects:
			@"Inoffensive",	//0
			@""	,			//1
			@"Clean",		//2
			@"",			//3
			@"Explicit", 	//4
			nil];
}

- (BOOL) setTag:(id)value forKey:(NSString *)key;
{
    if (![[tagsDict valueForKey:key] isEqualTo:value]) {
        [tagsDict setValue:value forKey:key];
        isEdited = YES;
        return YES;
    }
    else
        return NO;
}

- (BOOL)setRatingWithString:(NSString *)rwca
{
	NSString *lowercaseRating = [rwca lowercaseString];
	
	NSArray *ratings = [self availableRatings];
	NSMutableArray *lowercaseRatings = [NSMutableArray arrayWithCapacity:[ratings count]];
	for (NSString *rating in ratings) {
		[lowercaseRatings addObject:[rating lowercaseString]];
	}
	
	if ([lowercaseRatings containsObject:lowercaseRating]) {
		NSNumber *ratingIndex = [NSNumber numberWithInt:[lowercaseRatings indexOfObject:lowercaseRating]];
		[self setTag:ratingIndex forKey:@"Rating"];
		return YES;
	} else {
		return NO;
	}
}

- (BOOL)setMediaKindWithString:(NSString *)mkca
{
	if ([mkca isEqualToString:@""]) {
		return NO;
	}
	
	NSString *lowercaseMediaKind = [mkca lowercaseString];
	
	NSArray *mediaKinds = [self availableMediaKinds];
	NSMutableArray *lowercaseMediaKinds = [NSMutableArray arrayWithCapacity:[mediaKinds count]];
	
	for (NSString *mk in mediaKinds) {
		[lowercaseMediaKinds addObject:[mk lowercaseString]];
	}
	
	if ([lowercaseMediaKinds containsObject:lowercaseMediaKind]) {
		int selection = [lowercaseMediaKinds indexOfObject:lowercaseMediaKind];
		[self setMediaKind:selection];
		[self setIsEdited:YES];
		return YES;
	} else {
		return NO;
	}
}

- (BOOL)setContentRatingWithString:(NSString *)crca
{
	if ([crca isEqualToString:@""]) {
		return NO;
	}

	NSString *lowercaseContentRating = [crca lowercaseString];
	
	NSArray *contentRatings = [self availableContentRatings];
	NSMutableArray *lowercaseContentRatings = [NSMutableArray arrayWithCapacity:[contentRatings count]];
	
	for (id cr in contentRatings) {
		[lowercaseContentRatings addObject:[cr lowercaseString]];
	}
	
	if ([lowercaseContentRatings containsObject:lowercaseContentRating]) {
		int selection = [lowercaseContentRatings indexOfObject:lowercaseContentRating];
		[self setContentRating:selection];
		[self setIsEdited:YES];
		return YES;
	} else {
		return NO;
	}
}

- (BOOL)setHdVideoWithString:(NSString *)hdca
{
	NSString *lowercaseAnswer = [hdca lowercaseString];
	if ([lowercaseAnswer isEqualToString:@"yes"]) {
		[self setHdVideo:YES];
		[self setIsEdited:YES];
	} else if ([lowercaseAnswer isEqualToString:@"no"]) {
		[self setHdVideo:NO];
		[self setIsEdited:YES];
	} else {
		//invalid input
		return NO;
	}
	return YES;
}

- (BOOL)setGaplessWithString:(NSString *)gca
{
	NSString *lowercaseAnswer = [gca lowercaseString];
	if ([lowercaseAnswer isEqualToString:@"yes"]) {
		[self setGapless:YES];
		[self setIsEdited:YES];
	} else if ([lowercaseAnswer isEqualToString:@"no"]) {
		[self setGapless:NO];
		[self setIsEdited:YES];
	} else {
		//invalid input
		return NO;
	}
	return YES;
}

- (BOOL)addArtworkWithFilePath:(NSString *)afp
{
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	if (![fileManager isReadableFileAtPath:afp]) {
		return NO;
	}
	
	NSImage *tempArtwork = [[NSImage alloc] initByReferencingFile:afp];
	if (!tempArtwork) {
		return NO;
	}
	
	[self setArtwork:tempArtwork];
	[self setIsArtworkEdited:YES];
	[self setIsEdited:YES];
	return YES;
}

-(void) readMetaDataFromFileHandle:(MP4FileHandle)sourceHandle
{
    const MP4Tags* tags = MP4TagsAlloc();
    MP4TagsFetch( tags, sourceHandle );
	
    if (tags->name)
        [tagsDict setObject:[NSString stringWithCString:tags->name encoding: NSUTF8StringEncoding]
                     forKey:@"Name"];
	
    if (tags->artist)
        [tagsDict setObject:[NSString stringWithCString:tags->artist encoding: NSUTF8StringEncoding]
                     forKey:@"Artist"];
	
    if (tags->albumArtist)
        [tagsDict setObject:[NSString stringWithCString:tags->albumArtist encoding: NSUTF8StringEncoding]
                     forKey:@"Album Artist"];
	
    if (tags->album)
        [tagsDict setObject:[NSString stringWithCString:tags->album encoding: NSUTF8StringEncoding]
                     forKey:@"Album"];
	
    if (tags->grouping)
        [tagsDict setObject:[NSString stringWithCString:tags->grouping encoding: NSUTF8StringEncoding]
                     forKey:@"Grouping"];
	
    if (tags->composer)
        [tagsDict setObject:[NSString stringWithCString:tags->composer encoding: NSUTF8StringEncoding]
                     forKey:@"Composer"];
	
    if (tags->comments)
        [tagsDict setObject:[NSString stringWithCString:tags->comments encoding: NSUTF8StringEncoding]
                     forKey:@"Comments"];
	
    if (tags->genre)
        [tagsDict setObject:[NSString stringWithCString:tags->genre encoding: NSUTF8StringEncoding]
                     forKey:@"Genre"];
	
    if (tags->releaseDate)
        [tagsDict setObject:[NSString stringWithCString:tags->releaseDate encoding: NSUTF8StringEncoding]
                     forKey:@"Release Date"];
	
    if (tags->track)
        [tagsDict setObject:[NSString stringWithFormat:@"%d/%d", tags->track->index, tags->track->total]
                     forKey:@"Track #"];
    
    if (tags->disk)
        [tagsDict setObject:[NSString stringWithFormat:@"%d/%d", tags->disk->index, tags->disk->total]
                     forKey:@"Disk #"];
	
    if (tags->tempo)
        [tagsDict setObject:[NSString stringWithFormat:@"%d", *tags->tempo]
                     forKey:@"Tempo"];
	
    if (tags->tvShow)
        [tagsDict setObject:[NSString stringWithCString:tags->tvShow encoding: NSUTF8StringEncoding]
                     forKey:@"TV Show"];
	
    if (tags->tvEpisodeID)
        [tagsDict setObject:[NSString stringWithCString:tags->tvEpisodeID encoding: NSUTF8StringEncoding]
                     forKey:@"TV Episode ID"];
	
    if (tags->tvSeason)
        [tagsDict setObject:[NSString stringWithFormat:@"%d", *tags->tvSeason]
                     forKey:@"TV Season"];
	
    if (tags->tvEpisode)
        [tagsDict setObject:[NSString stringWithFormat:@"%d", *tags->tvEpisode]
                     forKey:@"TV Episode #"];
	
    if (tags->tvNetwork)
        [tagsDict setObject:[NSString stringWithCString:tags->tvNetwork encoding: NSUTF8StringEncoding]
                     forKey:@"TV Network"];
	
    if (tags->description)
        [tagsDict setObject:[NSString stringWithCString:tags->description encoding: NSUTF8StringEncoding]
                     forKey:@"Description"];
	
    if (tags->longDescription)
        [tagsDict setObject:[NSString stringWithCString:tags->longDescription encoding: NSUTF8StringEncoding]
                     forKey:@"Long Description"];
	
    if (tags->lyrics)
        [tagsDict setObject:[NSString stringWithCString:tags->lyrics encoding: NSUTF8StringEncoding]
                     forKey:@"Lyrics"];
	
    if (tags->copyright)
        [tagsDict setObject:[NSString stringWithCString:tags->copyright encoding: NSUTF8StringEncoding]
                     forKey:@"Copyright"];
	
    if (tags->encodingTool)
        [tagsDict setObject:[NSString stringWithCString:tags->encodingTool encoding: NSUTF8StringEncoding]
                     forKey:@"Encoding Tool"];
	
    if (tags->encodedBy)
        [tagsDict setObject:[NSString stringWithCString:tags->encodedBy encoding: NSUTF8StringEncoding]
                     forKey:@"Encoded By"];
	
    if (tags->hdVideo)
        hdVideo = *tags->hdVideo;
	
    if (tags->mediaType)
        mediaKind = *tags->mediaType;
    
    if (tags->contentRating)
        contentRating = *tags->contentRating;
    
    if (tags->gapless)
        gapless = *tags->gapless;
	
    if (tags->purchaseDate)
        [tagsDict setObject:[NSString stringWithCString:tags->purchaseDate encoding: NSUTF8StringEncoding]
                     forKey:@"Purchase Date"];
	
    if (tags->iTunesAccount)
        [tagsDict setObject:[NSString stringWithCString:tags->iTunesAccount encoding: NSUTF8StringEncoding]
                     forKey:@"iTunes Account"];
    
    if (tags->cnID)
        [tagsDict setObject:[NSString stringWithFormat:@"%d", *tags->cnID]
                     forKey:@"cnID"];
	
    if (tags->artwork) {
        NSData *imageData = [NSData dataWithBytes:tags->artwork->data length:tags->artwork->size];
        NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
        if (imageRep != nil) {
            artwork = [[NSImage alloc] initWithSize:[imageRep size]];
            [artwork addRepresentation:imageRep];
        }
    }
	
    MP4TagsFree(tags);
	
    /* read the remaining iTMF items */
    MP4ItmfItemList* list = MP4ItmfGetItemsByMeaning(sourceHandle, "com.apple.iTunes", "iTunEXTC");
    if (list) {
        uint32_t i;
        for (i = 0; i < list->size; i++) {
            MP4ItmfItem* item = &list->elements[i];
            uint32_t j;
            for (j = 0; j < item->dataList.size; j++) {
                MP4ItmfData* data = &item->dataList.elements[j];
                NSString *rating = [[NSString alloc] initWithBytes:data->value length: data->valueSize encoding:NSUTF8StringEncoding];
                NSString *splitElements  = @"\\|";
                NSArray *ratingItems = [rating componentsSeparatedByRegex:splitElements];
                NSInteger ratingIndex = R_UNKNOWN;
                if ([ratingItems count] >= 3) {
                    NSString *ratingCompareString = [NSString stringWithFormat:@"%@|%@|%@|", 
                                                     [ratingItems objectAtIndex:0],
                                                     [ratingItems objectAtIndex:1],
                                                     [ratingItems objectAtIndex:2]];
                    iTMF_rating_t *ratingList;
                    int k = 0;
                    for ( ratingList = (iTMF_rating_t*) rating_strings; ratingList->rating; ratingList++, k++ ) {
                        if ([ratingCompareString isEqualToString:[NSString stringWithUTF8String:ratingList->rating]])
                            ratingIndex = k;
                    }
                }
                [tagsDict setObject:[NSNumber numberWithInt:ratingIndex] forKey:@"Rating"];
            }
        }
        MP4ItmfItemListFree(list);
    }
	
    list = MP4ItmfGetItemsByMeaning(sourceHandle, "com.apple.iTunes", "iTunMOVI");
    if (list) {
        uint32_t i;
        for (i = 0; i < list->size; i++) {
            MP4ItmfItem* item = &list->elements[i];
            uint32_t j;
            for(j = 0; j < item->dataList.size; j++) {
                MP4ItmfData* data = &item->dataList.elements[j];
                NSData *xmlData = [NSData dataWithBytes:data->value length:data->valueSize];
                NSDictionary *dma = (NSDictionary *)[NSPropertyListSerialization
													 propertyListFromData:xmlData
													 mutabilityOption:NSPropertyListMutableContainersAndLeaves
													 format:nil
													 errorDescription:nil];
                
                NSString *tag;
                if ([tag = [self stringFromArray:[dma valueForKey:@"cast"]] length])
                    [tagsDict setObject:tag forKey:@"Cast"];
                if ([tag = [self stringFromArray:[dma valueForKey:@"directors"]] length])
                    [tagsDict setObject:tag forKey:@"Director"];
                if ([tag = [self stringFromArray:[dma valueForKey:@"codirectors"]] length])
                    [tagsDict setObject:tag forKey:@"Codirector"];
                if ([tag = [self stringFromArray:[dma valueForKey:@"producers"]] length])
                    [tagsDict setObject:tag forKey:@"Producers"];
                if ([tag = [self stringFromArray:[dma valueForKey:@"screenwriters"]] length])
                    [tagsDict setObject:tag forKey:@"Screenwriters"];
            }
        }
        MP4ItmfItemListFree(list);
    }
}

- (BOOL) writeMetadataWithFileHandle: (MP4FileHandle *)fileHandle removeAll:(BOOL)performRemove
{
	if (performRemove)
	{
		[tagsDict removeAllObjects];
	}
	
    if (!fileHandle)
        return NO;
	
    const MP4Tags* tags = MP4TagsAlloc();
	
    MP4TagsFetch(tags, fileHandle);
	
    MP4TagsSetName(tags, [[tagsDict valueForKey:@"Name"] UTF8String]);
	
    MP4TagsSetArtist(tags, [[tagsDict valueForKey:@"Artist"] UTF8String]);
	
    MP4TagsSetAlbumArtist(tags, [[tagsDict valueForKey:@"Album Artist"] UTF8String]);
	
    MP4TagsSetAlbum(tags, [[tagsDict valueForKey:@"Album"] UTF8String]);
	
    MP4TagsSetGrouping(tags, [[tagsDict valueForKey:@"Grouping"] UTF8String]);
	
    MP4TagsSetComposer(tags, [[tagsDict valueForKey:@"Composer"] UTF8String]);
	
    MP4TagsSetComments(tags, [[tagsDict valueForKey:@"Comments"] UTF8String]);
	
    MP4TagsSetGenre(tags, [[tagsDict valueForKey:@"Genre"] UTF8String]);
	
    MP4TagsSetReleaseDate(tags, [[tagsDict valueForKey:@"Release Date"] UTF8String]);
    
    if ([tagsDict valueForKey:@"Track #"]) {
        MP4TagTrack dtrack; int trackNum = 0, totalTrackNum = 0;
        char separator;
        sscanf([[tagsDict valueForKey:@"Track #"] UTF8String],"%u%[/- ]%u", &trackNum, &separator, &totalTrackNum);
        dtrack.index = trackNum;
        dtrack.total = totalTrackNum;
        MP4TagsSetTrack(tags, &dtrack);
    }
    else
        MP4TagsSetTrack(tags, NULL);
    
    if ([tagsDict valueForKey:@"Disk #"]) {
        MP4TagDisk ddisk; int diskNum = 0, totalDiskNum = 0;
        char separator;
        sscanf([[tagsDict valueForKey:@"Disk #"] UTF8String],"%u%[/- ]%u", &diskNum, &separator, &totalDiskNum);
        ddisk.index = diskNum;
        ddisk.total = totalDiskNum;
        MP4TagsSetDisk(tags, &ddisk);
    }
    else
        MP4TagsSetDisk(tags, NULL);    
    
    if ([tagsDict valueForKey:@"Tempo"]) {
        const uint16_t i = [[tagsDict valueForKey:@"Tempo"] integerValue];
        MP4TagsSetTempo(tags, &i);
    }
    else
        MP4TagsSetTempo(tags, NULL);
	
    MP4TagsSetTVShow(tags, [[tagsDict valueForKey:@"TV Show"] UTF8String]);
	
    MP4TagsSetTVNetwork(tags, [[tagsDict valueForKey:@"TV Network"] UTF8String]);
	
    MP4TagsSetTVEpisodeID(tags, [[tagsDict valueForKey:@"TV Episode ID"] UTF8String]);
	
    if ([tagsDict valueForKey:@"TV Season"]) {
        const uint32_t i = [[tagsDict valueForKey:@"TV Season"] integerValue];
        MP4TagsSetTVSeason(tags, &i);
    }
    else
        MP4TagsSetTVSeason(tags, NULL);
	
    if ([tagsDict valueForKey:@"TV Episode #"]) {
        const uint32_t i = [[tagsDict valueForKey:@"TV Episode #"] integerValue];
        MP4TagsSetTVEpisode(tags, &i);
    }
    else
        MP4TagsSetTVEpisode(tags, NULL);
	
    MP4TagsSetDescription(tags, [[tagsDict valueForKey:@"Description"] UTF8String]);
	
    MP4TagsSetLongDescription(tags, [[tagsDict valueForKey:@"Long Description"] UTF8String]);
	
    MP4TagsSetLyrics(tags, [[tagsDict valueForKey:@"Lyrics"] UTF8String]);
	
    MP4TagsSetCopyright(tags, [[tagsDict valueForKey:@"Copyright"] UTF8String]);
	
    MP4TagsSetEncodingTool(tags, [[tagsDict valueForKey:@"Encoding Tool"] UTF8String]);
	
    MP4TagsSetEncodedBy(tags, [[tagsDict valueForKey:@"Encoded By"] UTF8String]);
	
	if (performRemove) {
		MP4TagsSetMediaType(tags, NULL);
		
		MP4TagsSetHDVideo(tags, NULL);
		
		MP4TagsSetGapless(tags, NULL);
		
		MP4TagsSetContentRating(tags, NULL);
	} else {
		MP4TagsSetMediaType(tags, &mediaKind);
		
		MP4TagsSetHDVideo(tags, &hdVideo);
		
		MP4TagsSetGapless(tags, &gapless);
		
		MP4TagsSetContentRating(tags, &contentRating);
	}
	
	
    if ([tagsDict valueForKey:@"cnID"]) {
        const uint32_t i = [[tagsDict valueForKey:@"cnID"] integerValue];
        MP4TagsSetCNID(tags, &i);
    }
    else
        MP4TagsSetCNID(tags, NULL);
	
    if (artwork && isArtworkEdited) {
        MP4TagArtwork newArtwork;
        NSArray *representations;
        NSData *bitmapData;
		
        representations = [artwork representations];
        bitmapData = [NSBitmapImageRep representationOfImageRepsInArray:representations 
                                                              usingType:NSPNGFileType properties:nil];
		
        newArtwork.data = (void *)[bitmapData bytes];
        newArtwork.size = [bitmapData length];
        newArtwork.type = MP4_ART_PNG;
        if (!tags->artworkCount)
            MP4TagsAddArtwork(tags, &newArtwork);
        else
            MP4TagsSetArtwork(tags, 0, &newArtwork);
    }
    else if (tags->artworkCount && isArtworkEdited || performRemove)
        MP4TagsRemoveArtwork(tags, 0);
	
    MP4TagsStore(tags, fileHandle);
    MP4TagsFree(tags);
	
    /* Rewrite extended metadata using the generic iTMF api */
	
    if ([tagsDict valueForKey:@"Rating"] && ([[tagsDict valueForKey:@"Rating"] integerValue] != R_UNKNOWN) ) {
        MP4ItmfItemList* list = MP4ItmfGetItemsByMeaning(fileHandle, "com.apple.iTunes", "iTunEXTC");
        if (list) {
            uint32_t i;
            for (i = 0; i < list->size; i++) {
                MP4ItmfItem* item = &list->elements[i];
                MP4ItmfRemoveItem(fileHandle, item);
            }
        }
        MP4ItmfItemListFree(list);
		
        MP4ItmfItem* newItem = MP4ItmfItemAlloc( "----", 1 );
        newItem->mean = strdup( "com.apple.iTunes" );
        newItem->name = strdup( "iTunEXTC" );
        
        MP4ItmfData* data = &newItem->dataList.elements[0];
        data->typeCode = MP4_ITMF_BT_UTF8;
        data->valueSize = strlen(rating_strings[[[tagsDict valueForKey:@"Rating"] integerValue]].rating);
        data->value = (uint8_t*)malloc( data->valueSize );
        memcpy( data->value, rating_strings[[[tagsDict valueForKey:@"Rating"] integerValue]].rating, data->valueSize );
        
        MP4ItmfAddItem(fileHandle, newItem);
    }
    else {
        MP4ItmfItemList* list = MP4ItmfGetItemsByMeaning(fileHandle, "com.apple.iTunes", "iTunEXTC");
        if (list) {
            uint32_t i;
            for (i = 0; i < list->size; i++) {
                MP4ItmfItem* item = &list->elements[i];
                MP4ItmfRemoveItem(fileHandle, item);
            }
        }
    }
	
    if ([tagsDict valueForKey:@"Cast"] || [tagsDict valueForKey:@"Director"] ||
        [tagsDict valueForKey:@"Codirector"] || [tagsDict valueForKey:@"Producers"] ||
        [tagsDict valueForKey:@"Screenwriters"]) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        if ([tagsDict valueForKey:@"Cast"]) {
            [dict setObject:[self dictArrayFromString:[tagsDict valueForKey:@"Cast"]] forKey:@"cast"];
        }
        if ([tagsDict valueForKey:@"Director"]) {
            [dict setObject:[self dictArrayFromString:[tagsDict valueForKey:@"Director"]] forKey:@"directors"];
        }
        if ([tagsDict valueForKey:@"Codirector"]) {
            [dict setObject:[self dictArrayFromString:[tagsDict valueForKey:@"Codirector"]] forKey:@"codirectors"];
        }
        if ([tagsDict valueForKey:@"Producers"]) {
            [dict setObject:[self dictArrayFromString:[tagsDict valueForKey:@"Producers"]] forKey:@"producers"];
        }
        if ([tagsDict valueForKey:@"Screenwriters"]) {
            [dict setObject:[self dictArrayFromString:[tagsDict valueForKey:@"Screenwriters"]] forKey:@"screenwriters"];
        }
        NSData *serializedPlist = [NSPropertyListSerialization
								   dataFromPropertyList:dict
								   format:NSPropertyListXMLFormat_v1_0
								   errorDescription:nil];
		[dict release];
		
        MP4ItmfItemList* list = MP4ItmfGetItemsByMeaning(fileHandle, "com.apple.iTunes", "iTunMOVI");
        if (list) {
            uint32_t i;
            for (i = 0; i < list->size; i++) {
                MP4ItmfItem* item = &list->elements[i];
                MP4ItmfRemoveItem(fileHandle, item);
            }
        }
        MP4ItmfItemListFree(list);
		
        MP4ItmfItem* newItem = MP4ItmfItemAlloc( "----", 1 );
        newItem->mean = strdup( "com.apple.iTunes" );
        newItem->name = strdup( "iTunMOVI" );
		
        MP4ItmfData* data = &newItem->dataList.elements[0];
        data->typeCode = MP4_ITMF_BT_UTF8;
        data->valueSize = [serializedPlist length];
        data->value = (uint8_t*)malloc( data->valueSize );
        memcpy( data->value, [serializedPlist bytes], data->valueSize );
		
        MP4ItmfAddItem(fileHandle, newItem);
    }
    else {
        MP4ItmfItemList* list = MP4ItmfGetItemsByMeaning(fileHandle, "com.apple.iTunes", "iTunMOVI");
        if (list) {
            uint32_t i;
            for (i = 0; i < list->size; i++) {
                MP4ItmfItem* item = &list->elements[i];
                MP4ItmfRemoveItem(fileHandle, item);
            }
        }
    }
	
    return YES;
}

- (void) printCurrentTags 
{
	BOOL printed = NO;
	printf("Current tags:\n");
	for (NSString* key in [[tagsDict allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
		const char* keyString = [key cStringUsingEncoding:NSUTF8StringEncoding];
		const char* valueString;
		if ([key isEqualToString:@"Rating"]) {
			int ratingIndex = [[tagsDict objectForKey:key] intValue];
			NSArray *ratings = [self availableRatings];
			valueString = [[ratings objectAtIndex:ratingIndex] cStringUsingEncoding:NSUTF8StringEncoding];
		} else {
			valueString = [[tagsDict objectForKey:key] cStringUsingEncoding:NSUTF8StringEncoding];
		}
		printf("  %s: %s\n", keyString, valueString);
		printed = YES;
	}
	if (mediaKind % 1 == 0) {
		NSArray *mediaKinds = [self availableMediaKinds];
		const char* valueString = [[mediaKinds objectAtIndex:mediaKind] cStringUsingEncoding:NSUTF8StringEncoding];
		printf("  MediaKind: %s\n", valueString);
		printed = YES;
	}
	if (contentRating % 1 == 0) {
		NSArray *contentRatings = [self availableContentRatings];
		const char* valueString = [[contentRatings objectAtIndex:contentRating] cStringUsingEncoding:NSUTF8StringEncoding];
		printf("  Content Rating: %s\n", valueString);
		printed = YES;
	}
	if (hdVideo == 1) {
		printf("  HD: yes\n");
		printed = YES;
	} else if (hdVideo == 0) {
		printf("  HD: no\n");
		printed = YES;
	}

	if (gapless == 1) {
		printf("  Gapless: yes\n");
		printed = YES;
	} else if (gapless == 0) {
		printf("  Gapless: no\n");
		printed = YES;
	}
	
	if (artwork) {
		printf("  Artwork: File contains artwork\n");
		printed = YES;
	}
	
	if (!printed) {
		printf("  none\n");
	}
}

@synthesize isEdited;
@synthesize isArtworkEdited;
@synthesize artwork;
@synthesize mediaKind;
@synthesize contentRating;
@synthesize hdVideo;
@synthesize gapless;
@synthesize tagsDict;

-(void) dealloc
{
    [artwork release];
    [tagsDict release];
    [super dealloc];
}

@end
