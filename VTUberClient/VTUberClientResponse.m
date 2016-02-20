//
//  VTUberClientResponse.m
//  VTUberClientExample
//
//  Created by Tran Viet on 2/17/16.
//  Copyright © 2016 viettranx. All rights reserved.
//

#import "VTUberClientResponse.h"

@implementation VTUberClientResponse

- (instancetype)initWithData:(NSDictionary *)dict uberErrorCode:(NSString *)uberCode statusCode:(NSInteger)statusCode httpURLResponse:(NSHTTPURLResponse *)httpResponse;
{
    if (self = [super init]) {
        self.responseData = dict;
        self.uberErrorCode = uberCode;
        self.statusCode = statusCode;
        self.httpResponse = httpResponse;
    }
    
    return self;
}

@end
