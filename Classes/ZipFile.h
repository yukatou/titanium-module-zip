//
//  ZipFile.h
//  tiziparchive
//
//  Created by Kato Yu on 2013/01/26.
//
//


#import "unzip.h"

@interface ZipFile : NSObject {
	NSString *path_;
	unzFile unzipFile_;
}

- (id)initWithFileAtPath:(NSString *)path;
- (BOOL)open;
- (void)close;
- (NSData *)readWithFileName:(NSString *)fileName maxLength:(NSUInteger)maxLength;
- (NSArray *)fileNames;
@end