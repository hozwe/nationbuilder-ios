//
//  UIKitAdditions.h
//  NBClient
//
//  Created by Peng Wang on 7/11/14.
//  Copyright (c) 2014 NationBuilder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (NBAdditions)

+ (UIAlertView *)nb_genericAlertViewWithError:(NSError *)error;

@end