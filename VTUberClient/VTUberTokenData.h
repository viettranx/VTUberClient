//
//  VTUberTokenData.h
//  VTUberClientExample
//
//  Created by Tran Viet on 2/17/16.
//  Copyright © 2016 viettranx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VTUberTokenData : NSObject
@property (nonatomic) NSString  *accessToken;
@property (nonatomic) NSString  *refeshToken;
@property (nonatomic) NSDate    *exprireDate;
@property (nonatomic) NSArray   *scopes;
@property (nonatomic) NSString  *type;

- (instancetype)initWithDictionary:(NSDictionary *)dict;
+ (VTUberTokenData *)loadSavedTokenData;

- (BOOL)isValid;
- (void)makeRequestNewToken:(void (^)(BOOL success))completeHandler;
- (void)revokeToken; // This action is equivalent to a user visiting their user profile and clicking 'Disconnect'
@end
