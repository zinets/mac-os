//
//  UserPhotoView.h
//  CupidDatingHD
//
//  Created by Zinetz Victor on 08.05.13.
//  Copyright (c) 2013 Cupid plc. All rights reserved.
//


@interface CachedImageView : UIImageView {
    NSURLConnection * _connection;
    NSMutableData * _data;
    UIActivityIndicatorView * _activity;
    NSString * _addr;
}

-(void)loadImageByUrl:(NSString *)addr;

@end
