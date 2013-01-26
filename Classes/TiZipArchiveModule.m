/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "TiZipArchiveModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "ZipFile.h"
#import "ZipArchive.h"

@implementation TiZipArchiveModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"4da30d24-2d31-4573-a005-12477f895f43";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"TiZipArchive";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
	
	NSLog(@"[INFO] %@ loaded",self);
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably
	
	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup 

-(void)dealloc
{
	// release any resources that have been retained by the module
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma mark Listener Notifications

-(void)_listenerAdded:(NSString *)type count:(int)count
{
	if (count == 1 && [type isEqualToString:@"my_event"])
	{
		// the first (of potentially many) listener is being added 
		// for event named 'my_event'
	}
}

-(void)_listenerRemoved:(NSString *)type count:(int)count
{
	if (count == 0 && [type isEqualToString:@"my_event"])
	{
		// the last listener called for event named 'my_event' has
		// been removed, we can optionally clean up any resources
		// since no body is listening at this point for that event
	}
}

#pragma Public APIs

-(id)files:(TiFile *)file
{
    //ENSURE_CLASS_OR_NIL(file, [TiFile class]);
    
    NSString *filename  = [file path];

    ZipFile *zipFile = [[[ZipFile alloc] initWithFileAtPath:filename] autorelease];
    
    if (![zipFile open]) {
        NSLog(@"[ERROR] Can't open zip file");
    }

    NSArray *files = [zipFile fileNames];
    if (!files) {
         NSLog(@"[ERROR] Can't get files");
    }
    
    [zipFile close];
    
    return (id)files;
}


-(id)read:(id)args
{
    //ENSURE_SINGLE_ARG(args, NSObject);
    //ENSURE_TYPE_OR_NIL(args,NSObject);
    
    TiFile *file = [args objectAtIndex:0];
    NSString *readPath = [args objectAtIndex:1];
    
    ENSURE_CLASS_OR_NIL(file, [TiFile class]);
    ENSURE_CLASS_OR_NIL(readPath, [NSString class]);
    
    
                                
    NSString *filename  = [(TiFile*)file path];
    ZipFile *zipFile = [[[ZipFile alloc] initWithFileAtPath:filename] autorelease];
    
    if (![zipFile open]) {
        NSLog(@"[ERROR] Can't open zip file");
    }
    
    NSArray *fileNames = [zipFile fileNames];
    if (!fileNames) {
        NSLog(@"[ERROR] Can't get files");
    }
    
    NSData *data = [zipFile readWithFileName:readPath maxLength:4096];
    if (!data) {
        NSLog(@"[ERROR] Can't get contents");
    }
    
    [zipFile close];
    
    NSString *str= [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return (id)str;
}

-(void)extract:(id)args
{
    RELEASE_TO_NIL(successCallback);
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    TiFile *file        = [args objectForKey:@"file"];
    NSString *filename  = [(TiFile*)file path];
    NSString *target    = [args objectForKey:@"target"];
    successCallback     = [[args objectForKey:@"success"] retain];
    errorCallback       = [[args objectForKey:@"error"] retain];
    
    
    NSURL *targetUrl    = [NSURL URLWithString:target];
    NSString *newtarget = [targetUrl path];
    
    
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if(![fileManager fileExistsAtPath:filename]) {
		NSLog(@"[DEBUG] Can't find zip file");
        return;
	}
    
	ZipArchive *zipArchive = [[ZipArchive alloc] init];
	if(![zipArchive UnzipOpenFile:filename]) {
        NSLog(@"[DEBUG] can't open zip");
        return;
    }
    
    NSLog(@"[DEBUG] zip opened");
    BOOL ret = [zipArchive UnzipFileTo:newtarget overWrite: YES];
    if (NO == ret){
        NSLog(@"[DEBUG] failed to unzip");
        if (errorCallback != nil) {
            NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys: filename, @"path", nil];
            [self _fireEventToListener:@"error" withObject:event listener:errorCallback thisObject:nil];
        }
    }
    else {
        NSLog(@"[DEBUG] file unzipped");
        if( successCallback != nil ){
            NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys: newtarget, @"target", nil];
            [self _fireEventToListener:@"success" withObject:event listener:successCallback thisObject:nil];
        }
    }
    
    [zipArchive UnzipCloseFile];
    
    
    // removed deletion of zip file after extraction.
    // Developer can use Ti.FileSystem.deleteFile if they want to do this.
    //[fileManager removeItemAtPath:file error:NULL];
    
	[zipArchive release];
}

@end
