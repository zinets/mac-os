//
//  GoogleReader.m
//  OfflineMate
//
//  Created by Zinetz Victor on 9/15/12.
//  Copyright (c) 2012 Victor Zinetz. All rights reserved.
//

#import "GoogleReader.h"

#define GoogleReaderSubscriptionError   101
#define GoogleReaderFeedsError          102

static NSString *const kGoogleClientID           = @"563901458117.apps.googleusercontent.com";
static NSString *const kGoogleClientSecret       = @"J1xBJgd2PcwdUQgw_Wk6ehAV";
static NSString *const kKeychainItemName         = @"OAuth2: OfflineMate";

@interface GoogleReader (Privates)

- (void)emptyData;
- (void)signOut;


- (BOOL)fillSubscriptions:(NSString *)xml error:(NSError **) error;
- (int)fillFeeds:(NSString *)xml error:(NSError **)error;

- (void)getSubscriptions;
- (void)getFeeds;

- (void)processError:(int)errorType error:(NSError *)error;

@end

#pragma mark -

@implementation GoogleReader

@synthesize managedObjectContext = _managedObjectContext;

-(void)cancel {
    isCanceled = YES;
    [self processError:syncErrorAbort error:[NSError errorWithDomain:@"GoogleReader error"
                                                                code:syncErrorAbort
                                                            userInfo:[NSDictionary dictionaryWithObject:@"Aborted by user" forKey:NSLocalizedDescriptionKey]]];
    
}

- (void) processError:(int)errorType error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        progressBlock(0,0,0,0,errorType, error);
        [progressBlock autorelease];
        progressBlock = nil;        
    });
}

-(void)syncWithCompletionHandler:(void (^)(int, int, int, int, int, NSError *))handler {

    isCanceled = NO;
    progressBlock = [handler copy];
    progressBlock(0,0,0,0, syncPreparing, nil);

    if ([_auth canAuthorize]) {
        [self getSubscriptions];
    } else {
        [self signOut];
        NSString *scope = @"http://www.google.com/reader/api http://www.google.com/reader/atom";
        
        GTMOAuth2WindowController *windowController;
        windowController = [GTMOAuth2WindowController controllerWithScope:scope
                                                                 clientID:kGoogleClientID
                                                             clientSecret:kGoogleClientSecret
                                                         keychainItemName:kKeychainItemName
                                                           resourceBundle:nil];
        
        NSDictionary *params = [NSDictionary dictionaryWithObject:@"en"
                                                           forKey:@"hl"];
        windowController.signIn.additionalAuthorizationParameters = params;
        
        NSString *html = @"<html><body><div align=center>Loading sign-in page...</div></body></html>";
        windowController.initialHTMLString = html;
        windowController.shouldPersistUser = YES;
        
        [windowController signInSheetModalForWindow:_ownerWnd
                                  completionHandler:^(GTMOAuth2Authentication *auth, NSError *error) {
                                      if (error) {
                                          [self processError:syncErrorAuth error:error];
                                      } else {
                                          _auth = [auth retain];
                                          [self getSubscriptions];
                                      }
                                  }];
    }
}

#pragma mark - init

- (void)dealloc
{
    [progressBlock release];
    [_auth release];
    [super dealloc];
}

- (id)initWithWindow:(NSWindow *)wnd {
    self = [super init];
    if (self) {
        _auth = [[GTMOAuth2WindowController authForGoogleFromKeychainForName:kKeychainItemName
                                                                    clientID:kGoogleClientID
                                                                clientSecret:kGoogleClientSecret] retain];
        _ownerWnd = wnd;
    }
    return self;    
}

-(id)init {
    return [self initWithWindow:nil];
}


#pragma mark - Privates

/* 
    Поскольку свясь от SubscriptionItem к остальным зависимым от него классам Cascade,
    то связанные экземпляры удаляться автоматически, так что в цикле удаляю только SubscriptionItem-ы
*/
- (void) emptyData {
    
    [fetchedSubscriptions release];
    fetchedSubscriptions = nil;
    [fetchedCategories release];
    fetchedCategories = nil;
    
    NSFetchRequest * fetchRequest = [NSFetchRequest new];
    NSEntityDescription * items = [NSEntityDescription entityForName:@"SubscriptionItem"
                                              inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:items];
    
    NSArray * _fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest
                                                                     error:nil];
    [fetchRequest release];
    
    for (GRSubscriptionItem * si in _fetchedObjects) {
        [_managedObjectContext deleteObject:si];
    }
    
    NSError * err = nil;
    if (![_managedObjectContext save:&err]) {
        NSLog(@"Error in emptyData: %@", [err description]);
    }
}

- (void) setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    _managedObjectContext = managedObjectContext;
    [self loadSubscriptions];
}

- (BOOL) loadSubscriptions {
    NSFetchRequest * fetchRequest = [[NSFetchRequest new] autorelease];
    NSEntityDescription * item = [NSEntityDescription entityForName:@"SubscriptionItem"
                                              inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:item];
    NSSortDescriptor * sort = [[[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES] autorelease];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchedSubscriptions release];
    NSError * err = nil;
    
    fetchedSubscriptions = [[_managedObjectContext executeFetchRequest:fetchRequest
                                                                error:&err] retain];
    if (err) {
        NSLog(@"Error in : %@", err);
    } else {
        NSLog(@"Loaded %ld items in subscriptions:", [fetchedSubscriptions count]);
        for (GRSubscriptionItem * si in fetchedSubscriptions) {
            NSLog(@"  %@", si.id);
        }
    }
    
    fetchRequest = [[NSFetchRequest new] autorelease];
    item = [NSEntityDescription entityForName:@"CategoryItem"
                       inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:item];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchedCategories release];
    
    fetchedCategories = [[_managedObjectContext executeFetchRequest:fetchRequest
                                                              error:&err] retain];
    
    if (err) {
        NSLog(@"Error in : %@", err);
    } else {
        NSLog(@"Loaded %ld items in categories:", [fetchedCategories count]);
        for (GRCategoryItem * ci in fetchedCategories) {
            NSLog(@"   %@", ci.id);
        }
    }

    return YES;
}

- (GRSubscriptionItem *)fetchedSubscriptionByID:(NSString *)_id {
    for (GRSubscriptionItem * si in fetchedSubscriptions) {
        if ([si.id isEqualToString:_id]) {
            return si;
        }
    }
    NSLog(@"Something wrong! Not found subscription with id %@", _id);
    return nil;
}

#pragma mark - http

- (void)signOut {
    [GTMOAuth2WindowController revokeTokenForGoogleAuthentication:_auth];
    [GTMOAuth2WindowController removeAuthFromKeychainForName:kKeychainItemName];
    [_auth release];
    _auth = nil;
}

-(void) getSubscriptions {
    if (isCanceled)
        return;
    
    GTMHTTPFetcher * fetch = [GTMHTTPFetcher fetcherWithURL:
                              [NSURL URLWithString:@"https://www.google.com/reader/api/0/subscription/list"]];
    [fetch setAuthorizer:_auth];
    
    [fetch beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
        if (error) {
            [self processError:syncError error:error];
        } else {
            if (isCanceled)
                return;
            
            NSString * subscr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSError * err = nil;
            if ([self fillSubscriptions:subscr error:&err]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    progressBlock(0,0,0,(int)[fetchedCategories count],syncSubscriptions,nil);
                });
                freshCount = 0;
                continuation = nil;
                [self getFeeds];
            } else {
                [self processError:syncError error:err];
            }
        }
    }];    
}



-(void)getFeeds {
#define feedsCount  30
    NSString * url = [NSString stringWithFormat:@"https://www.google.com/reader/atom/user/-/state/com.google/reading-list?n=%d&xt=user%%2F-%%2Fstate%%2Fcom.google%%2Fread", feedsCount];
    if (continuation) url = [url stringByAppendingFormat:@"&c=%@", continuation];
    [GTMHTTPFetcher setLoggingEnabled:YES];
    GTMHTTPFetcher * fetch = [GTMHTTPFetcher fetcherWithURL:
                              [NSURL URLWithString:url]];
    
    [fetch setAuthorizer:_auth];

    [fetch beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
        if (error) {
            NSLog (@"%@", error.userInfo.allKeys);
            [self processError:syncError error:error];
        } else {
            NSString * xml = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [xml writeToFile:[NSString stringWithFormat:@"%@/feeds_%d.xml", NSHomeDirectory(), freshCount]
                  atomically:YES
                    encoding:NSUTF8StringEncoding
                       error:nil];
            NSError * err = nil;
            int c = [self fillFeeds:xml error:&err];
            if (c > 0) {
                freshCount += c;
                if (c == feedsCount) { // ну если получили сколько заказывали - то видимо есть еще?
                    progressBlock(freshCount, 200, 0, 0, syncProgress, nil);
                    [self getFeeds];
                } else
                    progressBlock(0,0,0,0,syncDone, nil);
            } else {
                progressBlock(0,0,0,0,syncDone, nil);
            }
        }
    }];
}

#pragma mark - fill

- (BOOL)fillFeed:(NSDictionary *)dict error:(NSError **)error {
    BOOL res = NO;
    NSString * obj = [[dict objectForKey:@"id"] objectForKey:@"text"];
    
    NSRange r = [obj rangeOfString:@"tag:google.com,2005:reader/item/"];
    if (r.location != NSNotFound) {
        obj = [obj substringFromIndex:r.length];
    } else {
        *error = [NSError errorWithDomain:@"GoogleReader parsing error"
                                     code:GoogleReaderFeedsError
                                 userInfo:nil];
        return NO;
    }
    
    GRFeedItem * feed = [NSEntityDescription insertNewObjectForEntityForName:@"FeedItem"
                                                      inManagedObjectContext:_managedObjectContext];
    // id
    feed.id = obj;
    // title
    feed.title = [[dict objectForKey:@"title"] objectForKey:@"text"];
    // date publishing
    obj = [[dict objectForKey:@"published"] objectForKey:@"text"];
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    feed.published = [dateFormatter dateFromString:obj];

    // link - may me array
    //   alternate - урл на статью
    //   canonical - ?
    //   enclosure - прилепленые ресурсы - картинки, видео, мр3
    id link = [dict objectForKey:@"link"];
    NSString *alternate = nil, *enclosure = nil;
    if ([link isKindOfClass:[NSArray class]]) {
        for (NSDictionary * d in link) {
            if ([[d objectForKey:@"rel"] isEqualTo:@"alternate"])
                alternate = [d objectForKey:@"href"];
            else if ([[d objectForKey:@"rel"] isEqualTo:@"enclosure"])
                enclosure = [d objectForKey:@"href"];
        }
    } else if ([link isKindOfClass:[NSDictionary class]]) {
        alternate = [link objectForKey:@"rel"]; // todo: ну по хорошему проверять бы, что тут..
    }
    if (alternate)
        feed.link = alternate;
    
    if ([dict objectForKey:@"content"]) {
        obj = [[dict objectForKey:@"content"] objectForKey:@"text"];
    } else if ([dict objectForKey:@"summary"]) {
        obj = [[dict objectForKey:@"summary"] objectForKey:@"text"];
    }
    
    feed.summary = obj;
    

    feed.readed = [NSNumber numberWithBool:NO];
    feed.starred = [NSNumber numberWithBool:NO]; // todo: ну для гарантии надо считывать
    
    obj = [[[dict objectForKey:@"source"] objectForKey:@"id"] objectForKey:@"text"];
    if (obj) {
        r = [obj rangeOfString:@"tag:google.com,2005:reader/"];
        if (r.location != NSNotFound) {
            obj = [obj substringFromIndex:r.length];
        }
    } else {
        return NO;
    }
    feed.subscription = [self fetchedSubscriptionByID:obj];
    
    res = YES;
    return res;
}

- (int)fillFeeds:(NSString *)xml error:(NSError **)error {
    int res = 0;
    @try {
        NSDictionary * data = [XMLReader dictionaryForXMLString:xml error:error];

//        if (*error)
//            return 0;
        
        NSDictionary * dict = [data objectForKey:@"feed"];
        if (!dict)
            @throw [NSException exceptionWithName:@"GoogleReader error"
                                           reason:@"No <feed> in data"
                                         userInfo:nil];
        NSString * c = [[dict objectForKey:@"gr:continuation"] objectForKey:@"text"];
        [continuation release];
        if (c) continuation = [c copy];
        
        NSArray * arr = [dict objectForKey:@"entry"];
        if (!arr)
            @throw [NSException exceptionWithName:@"GoogleReader error"
                                           reason:@"No <enrty> in data"
                                         userInfo:nil];
        for (NSDictionary * feedData in arr) {
            if ([self fillFeed:feedData error:error])
                res++;
            else
                return 0;
        }
    } @catch (NSException *exception) {
        *error = [[[NSError alloc] initWithDomain:@"GoogleReader error"
                                             code:GoogleReaderSubscriptionError
                                         userInfo:[NSDictionary dictionaryWithObject:[exception description]
                                                                              forKey:NSLocalizedDescriptionKey]] autorelease];
    }
    @finally {
        return res;
    }
}

- (BOOL)fillSubscriptions:(NSString *)xml error:(NSError **) error {
    BOOL res = NO;
    if (isCanceled) return NO;
    
    NSMutableDictionary * cats = [NSMutableDictionary dictionary];

    @try {
        NSDictionary * data = [XMLReader dictionaryForXMLString:xml error:error];
        if (*error)
            return res;
        
        NSDictionary * dict = [data objectForKey:@"object"];
        if (!dict)
            @throw [NSException exceptionWithName:@"GoogleReader error"
                                           reason:@"No <object> in data"
                                         userInfo:nil];
        dict = [dict objectForKey:@"list"];
        if (!dict)
            @throw [NSException exceptionWithName:@"GoogleReader error"
                                           reason:@"No <list> in data"
                                         userInfo:nil];
        
        NSArray * arr = [dict objectForKey:@"object"];
        if (!arr)
            @throw [NSException exceptionWithName:@"GoogleReader error"
                                           reason:@"No subscriptions in data"
                                         userInfo:nil];
        
        [self emptyData];
        
        for (NSDictionary * d in arr) {
            if (isCanceled) return NO;
            
            NSArray * arr = [d objectForKey:@"string"];
            
            // выделяю подписку
            GRSubscriptionItem * item = nil;
            NSString * title = @"", * url = @"";
            
            for (NSDictionary * d in arr) {
                NSString * key = [d objectForKey:@"name"];
                if ([key isEqualToString:@"id"]) {
                    item = [NSEntityDescription insertNewObjectForEntityForName:@"SubscriptionItem"
                                                         inManagedObjectContext:_managedObjectContext];
                    item.id = [d objectForKey:@"text"];
                } else if ([key isEqualToString:@"title"]) {
                    title = [d objectForKey:@"text"];
                } else if ([key isEqualToString:@"htmlUrl"]) {
                    url = [d objectForKey:@"text"];
                }
            }
            if (item) {
                item.title = title;
                item.url = url;
                item.unreaded = 0;
            }
            
            // выделяю категории
                if (isCanceled) return NO;
            id obj = [[d objectForKey:@"list"] objectForKey:@"object"];
            NSString * catID = @"null", * catTitle = @"Other";
            if (!obj) {
                GRCategoryItem * ci;
                if ([cats objectForKey:catID]) {
                    ci = [cats objectForKey:catID];
                } else {
                    ci = [NSEntityDescription insertNewObjectForEntityForName:@"CategoryItem"
                                                       inManagedObjectContext:_managedObjectContext];
                    ci.id = catID;
                    ci.title = catTitle;
                    [cats setObject:ci forKey:catID];
                }
                [ci addSubscriptionsObject:item];
                [item addCategoriesObject:ci];
            } else if ([obj isKindOfClass:[NSDictionary class]]) {
                NSArray * arr = [(NSDictionary *)obj objectForKey:@"string"];
                for (NSDictionary * temp in arr) {
                    if ([[temp objectForKey:@"name"] isEqualToString:@"id"])
                        catID = [temp objectForKey:@"text"];
                    else if ([[temp objectForKey:@"name"] isEqualToString:@"label"])
                        catTitle = [temp objectForKey:@"text"];                    
                }

                GRCategoryItem * ci;
                if ([cats objectForKey:catID]) {
                    ci = [cats objectForKey:catID];
                } else {
                    ci = [NSEntityDescription insertNewObjectForEntityForName:@"CategoryItem"
                                                       inManagedObjectContext:_managedObjectContext];
                    ci.id = catID;
                    ci.title = catTitle;
                    [cats setObject:ci forKey:catID];
                }
                [ci addSubscriptionsObject:item];
                [item addCategoriesObject:ci];
            } else if ([obj isKindOfClass:[NSArray class]]) {
                for (NSDictionary * d in (NSArray *)obj) {
                    NSArray * arr = [d objectForKey:@"string"];
                    for (NSDictionary * temp in arr) {
                        if ([[temp objectForKey:@"name"] isEqualToString:@"id"])
                            catID = [temp objectForKey:@"text"];
                        else if ([[temp objectForKey:@"name"] isEqualToString:@"label"])
                            catTitle = [temp objectForKey:@"text"];
                    }
                    GRCategoryItem * ci;
                    if ([cats objectForKey:catID]) {
                        ci = [cats objectForKey:catID];
                    } else {
                        ci = [NSEntityDescription insertNewObjectForEntityForName:@"CategoryItem"
                                                           inManagedObjectContext:_managedObjectContext];
                        ci.id = catID;
                        ci.title = catTitle;
                        [cats setObject:ci forKey:catID];
                    }
                    [ci addSubscriptionsObject:item];
                    [item addCategoriesObject:ci];
                }
            }
        }
        
        if (![_managedObjectContext save:error])
            return res;
        [self loadSubscriptions];
        
        res = YES;
    }
    @catch (NSException *exception) {
        *error = [[[NSError alloc] initWithDomain:@"GoogleReader error"
                                             code:GoogleReaderSubscriptionError
                                         userInfo:[NSDictionary dictionaryWithObject:[exception description]
                                                                              forKey:NSLocalizedDescriptionKey]] autorelease];
    }
    @finally {
        return res;
    }
}

#pragma mark - tests

-(void)test1 {
    NSString * xml = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/feeds_0.xml", NSHomeDirectory()]
                                               encoding:NSUTF8StringEncoding
                                                  error:nil];
    NSError * err = nil;
    int c = [self fillFeeds:xml error:&err];
}

-(void)test2 {
    
    NSFetchRequest * fetchRequest = [NSFetchRequest new];
    NSEntityDescription * items = [NSEntityDescription entityForName:@"CategoryItem"
                                              inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:items];
    
    NSArray * _fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest
                                                                     error:nil];
    [fetchRequest release];
    NSLog(@"BEFORE deletion: categories:\n%@", _fetchedObjects);
    
    
    fetchRequest = [NSFetchRequest new];
    items = [NSEntityDescription entityForName:@"SubscriptionItem"
                        inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:items];
    
    _fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest
                                                           error:nil];
    //[fetchRequest release];
    NSLog(@"BEFORE deletion: subscriptions:");
    
    for (GRSubscriptionItem * si in _fetchedObjects) {
        NSLog(@"  %@", si.id);
        [_managedObjectContext deleteObject:si];
    }
    [_managedObjectContext save:nil];
    
    _fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest
                                                           error:nil];
    NSLog(@"AFTER deletion: subscriptions: %ld", [_fetchedObjects count]);
    
    [fetchRequest release];
    
    fetchRequest = [NSFetchRequest new];
    items = [NSEntityDescription entityForName:@"CategoryItem"
                                              inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:items];
    
    _fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest
                                                                     error:nil];
    [fetchRequest release];
    NSLog(@"BEFORE deletion: categories:\n%@", _fetchedObjects);
}

@end


/*
if (!_auth || ![_auth canAuthorize]) {
    [self signOut];
    NSString *scope = @"http://www.google.com/reader/api";
    
    GTMOAuth2WindowController *windowController;
    windowController = [GTMOAuth2WindowController controllerWithScope:scope
                                                             clientID:kGoogleClientID
                                                         clientSecret:kGoogleClientSecret
                                                     keychainItemName:kKeychainItemName
                                                       resourceBundle:nil];
    
    NSDictionary *params = [NSDictionary dictionaryWithObject:@"en"
                                                       forKey:@"hl"];
    windowController.signIn.additionalAuthorizationParameters = params;
    
    NSString *html = @"<html><body><div align=center>Loading sign-in page...</div></body></html>";
    windowController.initialHTMLString = html;
    windowController.shouldPersistUser = YES;
    
    [windowController signInSheetModalForWindow:_ownerWnd
                              completionHandler:^(GTMOAuth2Authentication *auth, NSError *error) {
                                  if (error) {
                                      NSLog(@"%@", error);
                                  } else {
                                      NSLog (@"%@", auth.userEmail);
                                  }
                              }];
}
 */
 
