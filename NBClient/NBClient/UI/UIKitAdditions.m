//
//  UIKitAdditions.m
//  NBClient
//
//  Created by Peng Wang on 7/11/14.
//  Copyright (c) 2014 NationBuilder. All rights reserved.
//

#import "UIKitAdditions.h"

#import "FoundationAdditions.h"

@implementation UIAlertView (NBAdditions)

+ (UIAlertView *)nb_genericAlertViewWithError:(NSError *)error
{
    error = error ?: [NSError nb_genericError];
    NSDictionary *userInfo = error.userInfo;
    return [[UIAlertView alloc] initWithTitle:userInfo[NSLocalizedDescriptionKey]
                                      message:[userInfo[NSLocalizedFailureReasonErrorKey]
                                               stringByAppendingFormat:@" %@", (userInfo[NSLocalizedRecoverySuggestionErrorKey] ?: @"")]
                                     delegate:self cancelButtonTitle:nil
                            otherButtonTitles:@"label.ok".nb_localizedString, nil];
}

@end