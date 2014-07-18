//
//  NBTestCase.m
//  NBClient
//
//  Created by Peng Wang on 7/11/14.
//  Copyright (c) 2014 NationBuilder. All rights reserved.
//

#import "NBTestCase.h"

@interface NBTestCase ()

@property (nonatomic) BOOL didCallBack;

@end

@implementation NBTestCase

- (void)setUp
{
    [super setUp];
    // Provide default config for test cases.
    NSUserDefaults *launchArguments = [NSUserDefaults standardUserDefaults];
    self.nationName = [launchArguments stringForKey:@"NBNationName"];
    NSAssert(self.nationName, @"Missing environment arguments for tests.");
    self.baseURL = [NSURL URLWithString:
                    [NSString stringWithFormat:[launchArguments stringForKey:@"NBBaseURLFormat"], self.nationName]];
    self.apiKey = [launchArguments stringForKey:@"NBClientAPIKey"];
    self.clientIdentifier = [launchArguments stringForKey:@"NBClientIdentifier"];
    self.clientSecret = [launchArguments stringForKey:@"NBClientSecret"];
    self.userEmailAddress = [launchArguments stringForKey:@"NBUserEmailAddress"];
    self.userIdentifier = [launchArguments integerForKey:@"NBUserIdentifier"];
    self.userPassword = [launchArguments stringForKey:@"NBUserPassword"];
}

- (void)tearDown
{
    [super tearDown];
}

# pragma mark - Async API

- (void)setUpAsync
{
    self.asyncTimeoutInterval = 10.0f;
    self.didCallBack = NO;
}

- (void)tearDownAsync
{
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:self.asyncTimeoutInterval];
    while (!self.didCallBack && timeoutDate.timeIntervalSinceNow > 0.0f) {
        [[NSRunLoop currentRunLoop] runMode:NSRunLoopCommonModes beforeDate:timeoutDate];
    }
    if (!self.didCallBack) {
        XCTFail(@"Async test timed out.");
    }
}

- (void)completeAsync
{
    self.didCallBack = YES;
}

@end