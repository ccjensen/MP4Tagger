#import <Foundation/Foundation.h>
#import <getopt.h>
#include <err.h>
#import "MP42File.h"
#import "MP42Metadata.h" 

#define OPTION_NAME 150
#define OPTION_ARTIST (OPTION_NAME + 1)
#define OPTION_ALBUM_ARTIST (OPTION_ARTIST + 1)
#define OPTION_ALBUM (OPTION_ALBUM_ARTIST + 1)
#define OPTION_GROUPING (OPTION_ALBUM + 1)
#define OPTION_COMPOSER (OPTION_GROUPING + 1)
#define OPTION_COMMENTS (OPTION_COMPOSER + 1)
#define OPTION_GENRE (OPTION_COMMENTS + 1)
#define OPTION_RELEASE_DATE (OPTION_GENRE + 1)
#define OPTION_TRACK_N (OPTION_RELEASE_DATE + 1)
#define OPTION_DISK_N (OPTION_TRACK_N + 1)
#define OPTION_TEMPO (OPTION_DISK_N + 1)
#define OPTION_TV_SHOW (OPTION_TEMPO + 1)
#define OPTION_TV_EPISODE_N (OPTION_TV_SHOW + 1)
#define OPTION_TV_NETWORK (OPTION_TV_EPISODE_N + 1)
#define OPTION_TV_EPISODE_ID (OPTION_TV_NETWORK + 1)
#define OPTION_TV_SEASON (OPTION_TV_EPISODE_ID + 1)
#define OPTION_DESCRIPTION (OPTION_TV_SEASON + 1)
#define OPTION_LONG_DESCRIPTION (OPTION_DESCRIPTION + 1)
#define OPTION_RATING (OPTION_LONG_DESCRIPTION + 1)
#define OPTION_CAST (OPTION_RATING + 1)
#define OPTION_DIRECTOR (OPTION_CAST + 1)
#define OPTION_CODIRECTOR (OPTION_DIRECTOR + 1)
#define OPTION_PRODUCERS (OPTION_CODIRECTOR + 1)
#define OPTION_SCREENWRITERS (OPTION_PRODUCERS + 1)
#define OPTION_LYRICS (OPTION_SCREENWRITERS + 1)
#define OPTION_COPYRIGHT (OPTION_LYRICS + 1)
#define OPTION_ENCODING_TOOL (OPTION_COPYRIGHT + 1)
#define OPTION_ENCODED_BY (OPTION_ENCODING_TOOL + 1)
#define OPTION_CNID (OPTION_ENCODED_BY + 1)
#define OPTION_MEDIA_KIND (OPTION_CNID + 1)
#define OPTION_IS_HD_VIDEO (OPTION_MEDIA_KIND + 1)
#define OPTION_IS_GAPLESS (OPTION_IS_HD_VIDEO + 1)
#define OPTION_CONTENT_RATING (OPTION_IS_GAPLESS + 1)
#define OPTION_ARTWORK (OPTION_CONTENT_RATING + 1)

extern char *optarg;
extern int optind;
extern int optopt;
extern int opterr;
extern int optreset;

/* options descriptor */
static struct option longopts[] = {
	{ "version", no_argument, NULL, 'v' },
	{ "help", no_argument, NULL, 'h' },
	
	{ "input", required_argument, NULL, 'i' }, 
	{ "tags", no_argument, NULL, 't' }, 
	{ "clear_tags", no_argument, NULL, 'c' },
	{ "optimize", no_argument, NULL, 'o' },
	
	{ "artwork", required_argument, NULL, OPTION_ARTWORK },
	{ "media_kind", required_argument, NULL, OPTION_MEDIA_KIND },
	{ "is_hd_video", required_argument, NULL, OPTION_IS_HD_VIDEO },
	{ "is_gapless", required_argument, NULL, OPTION_IS_GAPLESS },
	{ "content_rating", required_argument, NULL, OPTION_CONTENT_RATING },
	{ "name", required_argument, NULL, OPTION_NAME },
	{ "artist", required_argument, NULL, OPTION_ARTIST },
	{ "album_artist", required_argument, NULL, OPTION_ALBUM_ARTIST },
	{ "album", required_argument, NULL, OPTION_ALBUM },
	{ "grouping", required_argument, NULL, OPTION_GROUPING },
	{ "composer", required_argument, NULL, OPTION_COMPOSER },
	{ "comments", required_argument, NULL, OPTION_COMMENTS },
	{ "genre", required_argument, NULL, OPTION_GENRE },
	{ "release_date", required_argument, NULL, OPTION_RELEASE_DATE },
	{ "track_n", required_argument, NULL, OPTION_TRACK_N },
	{ "disk_n", required_argument, NULL, OPTION_DISK_N },
	{ "tempo", required_argument, NULL, OPTION_TEMPO },
	{ "tv_show", required_argument, NULL, OPTION_TV_SHOW },
	{ "tv_episode_n", required_argument, NULL, OPTION_TV_EPISODE_N },
	{ "tv_network", required_argument, NULL, OPTION_TV_NETWORK },
	{ "tv_episode_id", required_argument, NULL, OPTION_TV_EPISODE_ID },
	{ "tv_season", required_argument, NULL, OPTION_TV_SEASON },
	{ "genre", required_argument, NULL, OPTION_GENRE },
	{ "description", required_argument, NULL, OPTION_DESCRIPTION },
	{ "long_description", required_argument, NULL, OPTION_LONG_DESCRIPTION },
	{ "rating", required_argument, NULL, OPTION_RATING },
	{ "cast", required_argument, NULL, OPTION_CAST },
	{ "director", required_argument, NULL, OPTION_DIRECTOR },
	{ "codirector", required_argument, NULL, OPTION_CODIRECTOR },
	{ "producers", required_argument, NULL, OPTION_PRODUCERS },
	{ "screenwriters", required_argument, NULL, OPTION_SCREENWRITERS },
	{ "lyrics", required_argument, NULL, OPTION_LYRICS },
	{ "copyright", required_argument, NULL, OPTION_COPYRIGHT },
	{ "encoding_tool", required_argument, NULL, OPTION_ENCODING_TOOL },
	{ "encoded_by", required_argument, NULL, OPTION_ENCODED_BY },
	{ "cnid", required_argument, NULL, OPTION_CNID }, 
};

void print_help()
{
    printf("usage: MP4Tagger [options]\n");
	printf("Options marked with [*] requires an input file to be set\n");
	
	printf("  System:\n");
	printf("    -v, --version\t print version\n");
	printf("    -h, --help\t\t print this help information\n");
	printf("    -l, --longhelp\t print additional help information\n");
	
	printf("\n  File:\n");
	printf("    -i, --input\t\t * set input file\n");
	printf("    -t, --tags\t\t print the current tags and exits [*]\n");
	printf("    -r, --remove_tags\t clears the current tags [*]\n");
    printf("    -o, --optimize\t optimize resulting file [*]\n");    
	
	printf("\n  Tags [*]:\n");
	printf("    --artwork\t set the artwork tag\n");
	printf("    --media_kind\t set the media kind tag (see longhelp)\n");
	printf("    --is_hd_video\t set the hd video tag [yes/no]\n");
	printf("    --is_gapless\t set gapless tag [yes/no]\n");
	printf("    --content_rating\t set content rating tag (see longhelp)\n");
	printf("    --rating\t\t set rating tag (see longhelp)\n");
	printf("    --name\t\t set name tag\n");
	printf("    --artist\t\t set artist tag\n");
	printf("    --album_artist\t set album artist tag\n");
	printf("    --album\t\t set album tag\n");
	printf("    --grouping\t\t set grouping tag\n");
	printf("    --composer\t\t set composer tag\n");
	printf("    --comments\t\t set comments tag\n");
	printf("    --genre\t\t set genre tag\n");
	printf("    --release_date\t set release date tag\n");
	printf("    --track_n\t\t set track number tag\n");
	printf("    --disk_n\t\t set disk number tag\n");
	printf("    --tempo\t\t set tempo tag\n");
	printf("    --tv_show\t\t set tv show tag\n");
	printf("    --tv_episode_n\t set tv episode number tag\n");
	printf("    --tv_network\t set tv network tag\n");
	printf("    --tv_episode_id\t set tv episode id tag\n");
	printf("    --tv_season\t\t set tv season tag\n");
	printf("    --genre\t\t set genre tag\n");
	printf("    --description\t set description tag\n");
	printf("    --long_description\t set long description tag\n");
	printf("    --cast\t\t set cast tag\n");
	printf("    --director\t\t set director tag\n");
	printf("    --codirector\t set codirector tag\n");
	printf("    --producers\t\t set producers tag\n");
	printf("    --screenwriters\t set screenwriters tag\n");
	printf("    --lyrics\t\t set lyrics tag\n");
	printf("    --copyright\t\t set copyright tag\n");
	printf("    --encoding_tool\t set encoding tool tag\n");
	printf("    --encoded_by\t set encoded by tag\n");
	printf("    --cnid\t\t set cnid tag\n");
}

void print_version()
{
    printf("MP4Tagger: version 0.2\n\n");
	printf("Credits:\n");
	printf("  Much of the code is based upon subler; http://code.google.com/p/subler\n");
	printf("Third-Party Resources:\n");
	printf("  mp4v2 - http://code.google.com/p/mp4v2\n\n");
	printf("The code is available under the GPL. The development site is located at ???\n");
}

void print_longhelp()
{
	printf("All keywords are case-insensitive\n");
	printf("\nMedia Kinds:\n");
	printf("  \"Normal\", \"Movie\", \"TV Show\", \"Audiobook\", \"Whacked Bookmark\", \"Music Video\", \"Short Film\", \"Booklets\"\n");
	printf("\nRatings:\n");
	printf("  MPAA: \"Not Rated\",  \"G\",  \"PG\",  \"PG-13\",  \"R\" ,  \"NC-17\",  \"Unrated\"\n");
	printf("  US-TV: \"TV-Y\",  \"TV-Y7\",  \"TV-G\",  \"TV-PG\",  \"TV-14\",  \"TV-MA\",  \"Unrated\"\n");
	printf("  UK-Movie: \"Not Rated\",  \"U\",  \"Uc\",  \"PG\",  \"12\",  \"12A\",  \"15\",  \"18\",  \"E\" ,  \"Unrated\"\n");
	printf("  UK-TV: \"Caution\"\n");
	printf("  DE-Movie: \"FSK 0\",  \"FSK 6\",  \"FSK 12\",  \"FSK 16\",  \"FSK 18\",  \"Unknown\"\n");
	printf("\nContent Ratings:\n");
	printf("  \"Inoffensive\", \"Clean\", \"Explicit\"\n");
}

MP42File* open_file(char * const input_file)
{
    MP42File *mp4File;
	mp4File = [[MP42File alloc] initWithExistingFile:[NSString stringWithCString:input_file encoding:NSUTF8StringEncoding]];
	if (!mp4File) {
		printf("Error: %s\n", "the mp4 file couln't be open.");
		exit(-1);
	}
	return mp4File;
}

BOOL updateMetadata(MP42Metadata *metadata,char *artwork,char *media_kind,char *is_hd_video,
					char *is_gapless,char *content_rating,char *name,char *artist,char *album_artist,
					char *album,char *grouping,char *composer,char *comments,char *genre,char *release_date,
					char *track_n,char *disk_n,char *tempo,char *tv_show,char *tv_episode_n,
					char *tv_network,char *tv_episode_id,char *tv_season,char *description,
					char *long_description,char *rating,char *cast,char *director,char *codirector,
					char *producers,char *screenwriters,char *lyrics,char *copyright,char *encoding_tool,
					char *encoded_by,char *cnid) 
{
	BOOL modified = false;
	
	if (artwork) {
		NSString *pathToArtwork = [NSString stringWithCString:artwork encoding:NSUTF8StringEncoding];
		BOOL result = [metadata addArtworkWithFilePath:pathToArtwork];
		if (!result) {
			printf("%s is not the path to a readable file. Program aborted.\n", artwork);
			exit(-1);
		}
		modified = true;

		
		
	}
	
	if (media_kind) {
		NSString *tag = [NSString stringWithCString:media_kind encoding:NSUTF8StringEncoding];
		BOOL result = [metadata setMediaKindWithString:tag];
		if (!result) {
			printf("%s is not a valid media kind (see longhelp for valid options). Program aborted.\n", media_kind);
			exit(-1);
		}
		modified = true;
	}
	
	if (is_hd_video) {
		NSString *tag = [NSString stringWithCString:is_hd_video encoding:NSUTF8StringEncoding];
		BOOL result = [metadata setHdVideoWithString:tag];
		if (!result) {
			printf("%s is not a valid entry for the hd tag (only yes or no). Program aborted.\n", is_hd_video);
			exit(-1);
		}
		modified = true;
	}
	
	if (is_gapless) {
		NSString *tag = [NSString stringWithCString:is_gapless encoding:NSUTF8StringEncoding];
		BOOL result = [metadata setGaplessWithString:tag];
		if (!result) {
			printf("%s is not a valid entry for the gapless tag (only yes or no). Program aborted.\n", is_gapless);
			exit(-1);
		}
		modified = true;
	}
	
	if (content_rating) {
		NSString *tag = [NSString stringWithCString:content_rating encoding:NSUTF8StringEncoding];
		BOOL result = [metadata setContentRatingWithString:tag];
		if (!result) {
			printf("%s is not a valid content rating (see longhelp for valid options). Program aborted.\n", content_rating);
			exit(-1);
		}
		modified = true;
	}
	
	if (rating) {
		NSString *tag = [NSString stringWithCString:rating encoding:NSUTF8StringEncoding];
		BOOL result = [metadata setRatingWithString:tag];
		if (!result) {
			printf("%s is not a valid rating (see longhelp for valid options). Program aborted.\n", rating);
			exit(-1);
		}
		modified = true;
	}
	
	if (name) {
		NSString *tag = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
		[metadata setTag:tag forKey:@"Name"];
		modified = true;
	}
	
	if (artist) {
		NSString *tag = [NSString stringWithCString:artist encoding:NSUTF8StringEncoding];
		[metadata setTag:tag forKey:@"Artist"];
		modified = true;
	}
	
	if (album_artist) {
		NSString *tag = [NSString stringWithCString:album_artist encoding:NSUTF8StringEncoding];
		[metadata setTag:tag forKey:@"Album Artist"];
		modified = true;
	}
	
	if (album) {
		NSString *tag = [NSString stringWithCString:album encoding:NSUTF8StringEncoding];
		[metadata setTag:tag forKey:@"Album"];
		modified = true;
	}
	
	if (grouping) {
		NSString *tag = [NSString stringWithCString:grouping encoding:NSUTF8StringEncoding];
		[metadata setTag:tag forKey:@"Grouping"];
		modified = true;
	}
	
	if (composer) {
		NSString *tag = [NSString stringWithCString:composer encoding:NSUTF8StringEncoding];		
		[metadata setTag:tag forKey:@"Composer"];
		modified = true;
	}
	
	if (comments) {
		NSString *tag = [NSString stringWithCString:comments encoding:NSUTF8StringEncoding];		
		[metadata setTag:tag forKey:@"Comments"];
		modified = true;
	}
	
	if (genre) {
		NSString *tag = [NSString stringWithCString:genre encoding:NSUTF8StringEncoding];
		[metadata setTag:tag forKey:@"Genre"];
		modified = true;
	}
	
	if (release_date) {
		NSString *tag = [NSString stringWithCString:release_date encoding:NSUTF8StringEncoding];
		[metadata setTag:tag forKey:@"Release Date"];
		modified = true;
	}
	
	if (track_n) {
		NSString *tag = [NSString stringWithCString:track_n encoding:NSUTF8StringEncoding];
		[metadata setTag:tag forKey:@"Track #"];
		modified = true;
	}
	
	if (disk_n) {
		NSString *tag = [NSString stringWithCString:disk_n encoding:NSUTF8StringEncoding];
		[metadata setTag:tag forKey:@"Disk #"];
		modified = true;
	}
	
	if (tempo) {
		NSString *tag = [NSString stringWithCString:tempo encoding:NSUTF8StringEncoding];
		[metadata setTag:tag forKey:@"Tempo"];
		modified = true;
	}
	
	if (tv_show) {
		NSString *tag = [NSString stringWithCString:tv_show encoding:NSUTF8StringEncoding];
		[metadata setTag:tag forKey:@"TV Show"];
		modified = true;
	}
	
	if (tv_episode_n) {
		NSString *tag = [NSString stringWithCString:tv_episode_n encoding:NSUTF8StringEncoding];
		[metadata setTag:tag forKey:@"TV Episode #"];
		modified = true;
	}
	
	if (tv_network) {
		NSString *tag = [NSString stringWithCString:tv_network encoding:NSUTF8StringEncoding];
		[metadata setTag:tag forKey:@"TV Network"];
		modified = true;
	}
	
	if (tv_episode_id) {
		NSString *tag = [NSString stringWithCString:tv_episode_id encoding:NSUTF8StringEncoding];
		[metadata setTag:tag forKey:@"TV Episode ID"];
		modified = true;
	}
	
	if (tv_season) {
		NSString *tag = [NSString stringWithCString:tv_season encoding:NSUTF8StringEncoding];
		[metadata setTag:tag forKey:@"TV Season"];
		modified = true;
	}
	
	if (genre) {
		NSString *tag = [NSString stringWithCString:genre encoding:NSUTF8StringEncoding];
		[metadata setTag:tag forKey:@"Genre"];
		modified = true;
	}
	
	if (description) {
		NSString *tag = [NSString stringWithCString:description encoding:NSUTF8StringEncoding];
		[metadata setTag:tag forKey:@"Description"];
		modified = true;
	}
	
	if (long_description) {
		NSString *tag = [NSString stringWithCString:long_description encoding:NSUTF8StringEncoding];
		[metadata setTag:tag forKey:@"Long Description"];
		modified = true;
	}
	
	if (cast) {
		NSString *tag = [NSString stringWithCString:cast encoding:NSUTF8StringEncoding];
		[metadata setTag:tag forKey:@"Cast"];
		modified = true;
	}
	
	if (director) {
		NSString *tag = [NSString stringWithCString:director encoding:NSUTF8StringEncoding];
		[metadata setTag:tag forKey:@"Director"];
		modified = true;
	}
	
	if (codirector) {
		NSString *tag = [NSString stringWithCString:codirector encoding:NSUTF8StringEncoding];
		[metadata setTag:tag forKey:@"Codirector"];
		modified = true;
	}
	
	if (producers) {
		NSString *tag = [NSString stringWithCString:producers encoding:NSUTF8StringEncoding];
		[metadata setTag:tag forKey:@"Producers"];
		modified = true;
	}
	
	if (screenwriters) {
		NSString *tag = [NSString stringWithCString:screenwriters encoding:NSUTF8StringEncoding];
		[metadata setTag:tag forKey:@"Screenwriters"];
		modified = true;
	}
	
	if (lyrics) {
		NSString *tag = [NSString stringWithCString:lyrics encoding:NSUTF8StringEncoding];
		[metadata setTag:tag forKey:@"Lyrics"];
		modified = true;
	}
	
	if (copyright) {
		NSString *tag = [NSString stringWithCString:copyright encoding:NSUTF8StringEncoding];
		[metadata setTag:tag forKey:@"Copyright"];
		modified = true;
	}
	
	if (encoding_tool) {
		NSString *tag = [NSString stringWithCString:encoding_tool encoding:NSUTF8StringEncoding];
		[metadata setTag:tag forKey:@"Encoding Tool"];
		modified = true;
	}
	
	if (encoded_by) {
		NSString *tag = [NSString stringWithCString:encoded_by encoding:NSUTF8StringEncoding];
		[metadata setTag:tag forKey:@"Encoded By"];
		modified = true;
	}
	
	if (cnid) {
		NSString *tag = [NSString stringWithCString:cnid encoding:NSUTF8StringEncoding];
		[metadata setTag:tag forKey:@"cnID"];
		modified = true;
	}
	return modified;
}

int main (int argc, char * const * argv) 
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
    // insert code here...
	if (argc == 1) {
        print_help();
        exit(-1);
    }
	
    char* input_file = NULL;
	
	BOOL printTags = false;
	BOOL removeTags = false;
    BOOL optimize = false;
	BOOL modified = false;
	
	char* artwork = NULL;
	char* media_kind = NULL;
	char* is_hd_video = NULL;
	char* is_gapless = NULL;
	char* content_rating = NULL;
	char* name = NULL;
	char* artist = NULL;
	char* album_artist = NULL;
	char* album = NULL;
	char* grouping = NULL;
	char* composer = NULL;
	char* comments = NULL;
	char* genre = NULL;
	char* release_date = NULL;
	char* track_n = NULL;
	char* disk_n = NULL;
	char* tempo = NULL;
	char* tv_show = NULL;
	char* tv_episode_n = NULL;
	char* tv_network = NULL;
	char* tv_episode_id = NULL;
	char* tv_season = NULL;
	char* description = NULL;
	char* long_description = NULL;
	char* rating = NULL;
	char* cast = NULL;
	char* director = NULL;
	char* codirector = NULL;
	char* producers = NULL;
	char* screenwriters = NULL;
	char* lyrics = NULL;
	char* copyright = NULL;
	char* encoding_tool = NULL;
	char* encoded_by = NULL;
	char* cnid = NULL;	
	
	int ch;
	while ((ch = getopt_long_only(argc, argv, "vhli:tro", longopts, NULL)) != -1) {
		switch (ch) {
				//system
			case 'v':
				print_version();
				exit(0);
				break;
			case 'h':
				print_help();
				exit(0);
				break;
			case 'l':
				print_longhelp();
				exit(0);
				break;
				
				//file
			case 'i':
				input_file = optarg;
				break;
			case 'r':
				removeTags = true;
				break;
			case 't':
				printTags = true;
				break;
			case 'o':
				optimize = true;
				break;
				
				//tags
			case OPTION_ARTWORK:
				artwork = optarg;
				break;				
			case OPTION_MEDIA_KIND:
				media_kind = optarg;
				break;
			case OPTION_IS_HD_VIDEO:
				is_hd_video = optarg;
				break;
			case OPTION_IS_GAPLESS:
				is_gapless = optarg;
				break;
			case OPTION_CONTENT_RATING:
				content_rating = optarg;
				break;
			case OPTION_NAME:
				name = optarg;
				break;
			case OPTION_ARTIST:
				artist = optarg;
				break;
			case OPTION_ALBUM_ARTIST:
				album_artist = optarg;
				break;
			case OPTION_ALBUM:
				album = optarg;
				break;
			case OPTION_GROUPING:
				grouping = optarg;
				break;
			case OPTION_COMPOSER:
				composer = optarg;
				break;
			case OPTION_COMMENTS:
				comments = optarg;
				break;
			case OPTION_GENRE:
				genre = optarg;
				break;
			case OPTION_RELEASE_DATE:
				release_date = optarg;
				break;
			case OPTION_TRACK_N:
				track_n = optarg;
				break;
			case OPTION_DISK_N:
				disk_n = optarg;
				break;
			case OPTION_TEMPO:
				tempo = optarg;
				break;
			case OPTION_TV_SHOW:
				tv_show = optarg;
				break;
			case OPTION_TV_EPISODE_N:
				tv_episode_n = optarg;
				break;
			case OPTION_TV_NETWORK:
				tv_network = optarg;
				break;
			case OPTION_TV_EPISODE_ID:
				tv_episode_id = optarg;
				break;
			case OPTION_TV_SEASON:
				tv_season = optarg;
				break;
			case OPTION_DESCRIPTION:
				description = optarg;
				break;
			case OPTION_LONG_DESCRIPTION:
				long_description = optarg;
				break;
			case OPTION_RATING:
				rating = optarg;
				break;
			case OPTION_CAST:
				cast = optarg;
				break;
			case OPTION_DIRECTOR:
				director = optarg;
				break;
			case OPTION_CODIRECTOR:
				codirector = optarg;
				break;
			case OPTION_PRODUCERS:
				producers = optarg;
				break;
			case OPTION_SCREENWRITERS:
				screenwriters = optarg;
				break;
			case OPTION_LYRICS:
				lyrics = optarg;
				break;
			case OPTION_COPYRIGHT:
				copyright = optarg;
				break;
			case OPTION_ENCODING_TOOL:
				encoding_tool = optarg;
				break;
			case OPTION_ENCODED_BY:
				encoded_by = optarg;
				break;
			case OPTION_CNID:
				cnid = optarg;
				break;
				
			default:
				printf("use \"MP4Tagger --help\" for help\n");
				exit(-1);
				break;
		}
	}
	
	if (input_file) {
		NSError *outError;
        MP42File *mp4File = open_file(input_file);
		MP42Metadata *metadata = [mp4File metadata];
		
		if (printTags) {
			[metadata printCurrentTags];
			return 0;
		}
		
//		NSString *inputFile = [NSString stringWithCString:input_file encoding:NSUTF8StringEncoding];
//		if (cautious) {
//			NSString *timestamp = [[NSDate dateWithTimeIntervalSinceNow:0] 
//								   descriptionWithCalendarFormat:@")-%Y-%m-%d-%H-%M-%S." timeZone:nil locale:nil];
//			NSRange replacingRange = NSMakeRange([inputFile length]-6, 5);
//			inputFile = [inputFile stringByReplacingOccurrencesOfString:@")." 
//															 withString:timestamp 
//																options:0 
//																  range:replacingRange];
//		}
		
		if (removeTags) {
			BOOL success = false;
//			if (cautious) {
//				uint64_t flags = 0;
//				if (_64bit) {
//					flags += 0x01;
//					flags += 0x02;
//				}
//				success = [mp4File writeToFilePath:inputFile flags:flags error:&outError removeAllTags:YES];
//			} else {
//				success = [mp4File updateMP4File:&outError removeAllTags:YES];
//			}
			success = [mp4File updateMP4File:&outError removeAllTags:YES];
			if (!success) {
				printf("Error: %s\n", [[outError localizedDescription] UTF8String]);
				return -1;
			}
			return 0;
		}
		
		if (artwork || media_kind || is_hd_video || is_gapless || content_rating ||
			name || artist || album_artist || album || grouping || composer || 
			comments || genre || release_date || track_n || disk_n || tempo || 
			tv_show || tv_episode_n || tv_network || tv_episode_id || 
			tv_season || genre || description || long_description || rating || 
			cast || director || codirector || producers || screenwriters || 
			lyrics || copyright || encoding_tool || encoded_by || cnid) 
		{
			modified = updateMetadata(metadata,artwork,media_kind,is_hd_video,is_gapless,content_rating,
									  name,artist,album_artist,album,grouping,composer,comments,genre,
									  release_date,track_n,disk_n,tempo,tv_show,tv_episode_n,tv_network,
									  tv_episode_id,tv_season,description,long_description,rating,cast,
									  director,codirector,producers,screenwriters,lyrics,copyright,
									  encoding_tool,encoded_by,cnid);
		}		
		
		if (modified && ![mp4File updateMP4File:&outError removeAllTags:NO]) {
            printf("Error: %s\n", [[outError localizedDescription] UTF8String]);
            return -1;
        }
	} else {
		//check if options who require input file have been selected
		
		if (removeTags || artwork || media_kind || is_hd_video || is_gapless || 
			content_rating || name || artist || album_artist || album || 
			grouping || composer || comments || genre || release_date || track_n || 
			disk_n || tempo || tv_show || tv_episode_n || tv_network || tv_episode_id || 
			tv_season || genre || description || long_description || rating || 
			cast || director || codirector || producers || screenwriters || 
			lyrics || copyright || encoding_tool || encoded_by || cnid) 
		{
			printf("Error: input file must be specified when adding tags\n");
			exit(-1);
		}
		
		if (optimize) {
			printf("Error: input file must be specified when optimize is selected\n");
			exit(-1);
		}
	}
	
	if (optimize) {
		MP42File *mp4File = open_file(input_file);
		printf("Optimizing...\n");
		[mp4File optimize];
		[mp4File release];
		printf("Done.\n");
	}
	
	// end
    [pool drain];
    return 0;
}
