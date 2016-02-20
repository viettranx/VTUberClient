//
//  VTUberLoginManager.h
//  VTUberClientExample
//
//  Created by Tran Viet on 2/19/16.
//  Copyright © 2016 viettranx. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIViewController;
@protocol VTUberLoginDelegate;

@interface VTUberLoginManager : NSObject
@property (nonatomic, weak) id<VTUberLoginDelegate> delegate;
@property (nonatomic) NSString *scopes;

- (void)loginWithViewController:(UIViewController *)viewController scopes:(NSString *)scopes;
- (void)setTimeoutInSeconds:(NSInteger)timeoutInSeconds;
@end

@protocol VTUberLoginDelegate <NSObject>
@optional
- (void)userDidCancelLogin:(VTUberLoginManager *)loginManager;
- (void)uberLoginDidTimeout:(VTUberLoginManager *)loginManager;
- (void)uberLoginDidError:(VTUberLoginManager *)loginManager errorResponse:(NSURLResponse *)errRes errorData:(NSData *)errData error:(NSError *)err;
- (void)uberLoginDidSuccess:(VTUberLoginManager *)loginManager;
@end