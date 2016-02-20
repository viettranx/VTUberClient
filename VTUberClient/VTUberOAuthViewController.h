//
//  OAuthViewController.h
//  FoodyMobile
//
//  Created by Duc Trinh on 12/7/12.
//  Copyright (c) 2012 Foody Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VTUberLoginManager;

@interface VTUberOAuthViewController : UIViewController <UIWebViewDelegate>
{
    NSTimer *timer;
}

@property (nonatomic) NSInteger timeoutInSeconds;
@property (nonatomic, strong)   VTUberLoginManager   *loginManager;
@end

