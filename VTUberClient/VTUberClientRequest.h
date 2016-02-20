//
//  VTUberClientRequest.h
//  VTUberClientExample
//
//  Created by Tran Viet on 2/17/16.
//  Copyright © 2016 viettranx. All rights reserved.
//

#import <Foundation/Foundation.h>
@class VTUberClientRequest;
@class VTUberClientResponse;

typedef void(^UberResponseSuccessHandler)(VTUberClientRequest *,VTUberClientResponse *, NSError *);
typedef void(^UberResponseFailHandler)(NSData *,NSURLResponse *, NSError *);

@interface VTUberClientRequest : NSObject

@property (nonatomic) NSString      *url;
@property (nonatomic) NSDictionary  *params;
@property (nonatomic) NSString      *absoluteURL;

- (instancetype)initWithURL:(NSString *)url method:(NSString *)method params:(NSDictionary *)params token:(NSString *)clientToken secret:(NSString *)clientSecret;
- (void)setSuccessHandler:(UberResponseSuccessHandler)hdl;
- (void)setFailHandler:(UberResponseFailHandler)hdl;
- (void)makeRequest;
@end
