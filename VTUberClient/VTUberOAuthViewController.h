//
//  OAuthViewController.h
//  FoodyMobile
//
//  Created by Tran Viet on 2/19/16.
//  Copyright © 2016 viettranx. All rights reserved.
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

