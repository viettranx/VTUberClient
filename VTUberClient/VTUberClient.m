//
//  VTUberClient.m
//  VTUberClientExample
//
//  Created by Tran Viet on 2/17/16.
//  Copyright © 2016 viettranx. All rights reserved.
//

#import "VTUberClient.h"

@interface VTUberClient() {
    BOOL isProductionMode;
}

@end

@implementation VTUberClient
@synthesize clientID, clientSecret;

static VTUberClient *sharedInstance;

+ (instancetype)shareInstance
{
    if (sharedInstance != nil) {
        return sharedInstance;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        
        isProductionMode = NO;
        self.tokenData = [VTUberTokenData loadSavedTokenData];
    }
    return self;
}

- (void)setEnabledProductionMode:(BOOL)enabled {
    isProductionMode = enabled;
}

- (NSString *)fullURLStringForEndPoint:(NSString *)endPoint {
    
    NSString *url = (isProductionMode) ? kUberProductionURL : kUberSandboxURL;
    url = [url stringByAppendingString:endPoint];
    
    return url;
}

- (void)api:(NSString *)apiEndPoint
    method:(NSString *)method
    params:(NSDictionary *)params
    successHandler:(void (^)(VTUberClientRequest *, VTUberClientResponse *, NSError *))successHandler
    failHandler:(void (^)(NSData *, NSURLResponse *, NSError *))failHandler
{
    NSString *fullURL = [self fullURLStringForEndPoint:apiEndPoint];
    
    VTUberClientRequest *request = [[VTUberClientRequest alloc] initWithURL:fullURL method:method params:params token:self.tokenData.accessToken secret:self.clientSecret];
    
    [request setSuccessHandler:successHandler];
    [request setFailHandler:failHandler];
    [request makeRequest];
}
@end
