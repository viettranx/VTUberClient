//
//  VTUberLoginManager.m
//  VTUberClientExample
//
//  Created by Tran Viet on 2/19/16.
//  Copyright © 2016 viettranx. All rights reserved.
//

#import "VTUberLoginManager.h"
#import "VTUberOAuthViewController.h"

@interface VTUberLoginManager()
{
    //VTUberOAuthViewController *oauthVC;
    NSInteger timeout;
}
@end

@implementation VTUberLoginManager

- (instancetype)init {
    if (self = [super init]) {
        timeout = 60;
        self.scopes = @"profile history request";
    }
    
    return self;
}

- (void)loginWithViewController:(UIViewController *)viewController scopes:(NSString *)scopes {
    self.scopes = scopes;
    
    VTUberOAuthViewController *oauthVC = [[VTUberOAuthViewController alloc] init];
    oauthVC.loginManager = self;
    oauthVC.timeoutInSeconds = timeout;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:oauthVC];
    [viewController presentViewController:nav animated:YES completion:nil];
}

- (void)setTimeoutInSeconds:(NSInteger)timeoutInSeconds {
    timeout = timeoutInSeconds;
}
@end
