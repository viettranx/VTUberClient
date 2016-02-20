//
//  VTUberTokenData.m
//  VTUberClientExample
//
//  Created by Tran Viet on 2/17/16.
//  Copyright © 2016 viettranx. All rights reserved.
//

#import "VTUberTokenData.h"
#import "VTUberClient.h"

@interface VTUberTokenData()<NSCoding>
@end

@implementation VTUberTokenData

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        
        [self updateInfoWithDict:dict];
        // Save token data for the next app running
        NSData *encodedData = [NSKeyedArchiver archivedDataWithRootObject:self];
        [[NSUserDefaults standardUserDefaults] setObject:encodedData forKey:kUberTokenDataSaveKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [self init]) {
        self.accessToken = [aDecoder decodeObjectForKey:@"access_token"];
        self.refeshToken = [aDecoder decodeObjectForKey:@"refresh_token"];
        self.exprireDate = [aDecoder decodeObjectForKey:@"exprireDate"];
        self.scopes      = [aDecoder decodeObjectForKey:@"scopes"];
        self.type        = [aDecoder decodeObjectForKey:@"token_type"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.accessToken forKey:@"access_token"];
    [aCoder encodeObject:self.refeshToken forKey:@"refresh_token"];
    [aCoder encodeObject:self.exprireDate forKey:@"exprireDate"];
    [aCoder encodeObject:self.scopes forKey:@"scopes"];
    [aCoder encodeObject:self.type forKey:@"token_type"];
}

- (void)updateInfoWithDict:(NSDictionary *)dict {
    self.accessToken = [dict objectForKey:@"access_token"];
    self.refeshToken = [dict objectForKey:@"refresh_token"];
    self.exprireDate = [[NSDate alloc] initWithTimeIntervalSinceNow:[[dict objectForKey:@"expires_in"] integerValue]];
    self.scopes      = [[dict objectForKey:@"scope"] componentsSeparatedByString:@" "];
    self.type        = [dict objectForKey:@"token_type"];
}

+ (VTUberTokenData *)loadSavedTokenData {
    NSData *tokenData = [[NSUserDefaults standardUserDefaults] objectForKey:kUberTokenDataSaveKey];
    
    if (!tokenData) {
        return [VTUberTokenData new];
    }
    
    VTUberTokenData *tokenObj = [NSKeyedUnarchiver unarchiveObjectWithData:tokenData];
    return tokenObj;
}

- (void)makeRequestNewToken:(void (^)(BOOL))completeHandler {
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[VTUberClient shareInstance].clientID forKey:@"client_id"];
    [params setObject:[VTUberClient shareInstance].clientSecret forKey:@"client_secret"];
    [params setObject:[VTUberClient shareInstance].redirectURI forKey:@"redirect_uri"];
    [params setObject:@"refresh_token" forKey:@"grant_type"];
    [params setObject:self.refeshToken forKey:@"refresh_token"];
    
    VTUberClientRequest *uRequest = [[VTUberClientRequest alloc] initWithURL:kUberGetTokenURL method:@"POST" params:params token:nil secret:nil];
    
    [uRequest setSuccessHandler:^(VTUberClientRequest *req, VTUberClientResponse *res, NSError *error) {
        [self updateInfoWithDict:res.responseData];
        
        if (completeHandler) {
            completeHandler(YES);
        }
    }];
    
    [uRequest setFailHandler:^(NSData *errorData, NSURLResponse *res, NSError *error) {
        if (completeHandler) {
            completeHandler(NO);
        }
    }];
    
    [uRequest makeRequest];
}

- (void)revokeToken {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[VTUberClient shareInstance].clientID forKey:@"client_id"];
    [params setObject:[VTUberClient shareInstance].clientSecret forKey:@"client_secret"];
    [params setObject:self.accessToken forKey:@"token"];
    
    VTUberClientRequest *uRequest = [[VTUberClientRequest alloc] initWithURL:kUberRevokeToken method:@"POST" params:params token:nil secret:nil];
    [uRequest makeRequest];
    
    self.accessToken = nil;
    self.refeshToken = nil;
    self.exprireDate = nil;
    self.scopes      = nil;
    self.type        = nil;
    
    // Remove saved token
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUberTokenDataSaveKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isValid {
    if (self.accessToken == nil) {
        return NO;
    }
    
    if (self.exprireDate) {
        if ([[NSDate date] compare:self.exprireDate] == NSOrderedDescending) {
            return NO;
        }
    }
    
    return YES;
}
@end
