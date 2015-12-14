//
//  UserPhotoView.m
//  CupidDatingHD
//
//  Created by Zinetz Victor on 08.05.13.
//  Copyright (c) 2013 Cupid plc. All rights reserved.
//

#import "CachedImageView.h"
#import <QuartzCore/QuartzCore.h>

static NSCache * memCache;

@implementation CachedImageView

+(void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        memCache = [[NSCache alloc] init];
    });
}

-(void)addActivity {
    if (!_activity) {
        _activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectInset(self.bounds, 3, 3)];
        _activity.layer.cornerRadius = 3;
        _activity.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
        _activity.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _activity.hidesWhenStopped = YES;
        _activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        
        [self addSubview:_activity];
    }
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self ) {
        [self addActivity];
    }
    return self;
}

-(id)initWithImage:(UIImage *)image {
    self = [super initWithImage:image];
    if (self ) {
        [self addActivity];
    }
    return self;
}

-(void)loadImageByUrl:(NSString *)addr {
    if ([addr isEqualToString:_addr]) return;
    
    _addr = addr;
    if (_connection)
        [_connection cancel];
    if (_data)
        _data.length = 0;
    [_activity startAnimating];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block NSData * data = [memCache objectForKey:addr];
        if (data) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self imageDone:[UIImage imageWithData:data]];
            });
        } else {
            _data = [NSMutableData data];
            NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:addr]
                                                      cachePolicy:NSURLCacheStorageAllowed
                                                  timeoutInterval:30.0];
            _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
            [_connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
            [_connection start];
        }
        
    });
}

-(void)imageDone:(UIImage *)image {
    self.image = image;
    
//    if (self.delegate && [self.delegate respondsToSelector:@selector(userImageWasLoaded:)]) {
//        [self.delegate userImageWasLoaded:self];
//    }
    [_activity stopAnimating];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [_activity stopAnimating];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _data.length = 0;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [memCache setObject:[NSPurgeableData dataWithData:_data] forKey:_addr];
    UIImage * img = [UIImage imageWithData:_data];
    [self imageDone:img];
}

@end
