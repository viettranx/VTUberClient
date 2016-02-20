//
//  VTUberClient.h
//  VTUberClientExample
//
//  Created by Tran Viet on 2/17/16.
//  Copyright © 2016 viettranx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VTUberClientRequest.h"
#import "VTUberClientResponse.h"
#import "VTUberLoginManager.h"
#import "VTUberTokenData.h"

#define kUberProductionURL      @"https://api.uber.com"
#define kUberSandboxURL         @"https://sandbox-api.uber.com";
#define kUberGetTokenURL        @"https://login.uber.com/oauth/v2/token"
#define kOAuthURLFormat         @"https://login.uber.com/oauth/v2/authorize?client_id=%@&response_type=code&scopes=%@"
#define kUberRevokeToken        @"https://login.uber.com/oauth/revoke"

#define kUberTokenDataSaveKey   @"kUberTokenDataSaveKey"

@class VTUberTokenData;
@interface VTUberClient : NSObject

@property (nonatomic) NSString *clientID;
@property (nonatomic) NSString *clientSecret;
@property (nonatomic) NSString *redirectURI;
@property (nonatomic) VTUberTokenData *tokenData;

+ (instancetype)shareInstance;
- (void)setEnabledProductionMode:(BOOL)enabled;

- (void)api:(NSString *)apiEndPoint method:(NSString *)method params:(NSDictionary *)params successHandler:(void (^)(VTUberClientRequest *req, VTUberClientResponse *res, NSError *error))successHandler failHandler:(void (^)(NSData *errorData, NSURLResponse *res, NSError *error))failHandler;
@end
