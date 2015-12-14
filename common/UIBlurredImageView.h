//
//  UIBlurredImageView.h
//  testHorTable
//
//  Created by Zinetz Victor on 22.04.13.
//  Copyright (c) 2013 Cupid plc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBlurredImageView : UIImageView

@property (nonatomic, assign) CGFloat blurValue; // 0.0 - 1.0
@property (nonatomic, assign) NSInteger blurRadius; // 1 - ..

@end
