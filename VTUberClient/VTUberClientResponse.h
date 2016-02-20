//
//  VTUberClientResponse.h
//  VTUberClientExample
//
//  Created by Tran Viet on 2/17/16.
//  Copyright © 2016 viettranx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VTUberClientResponse : NSObject

@property (nonatomic) NSHTTPURLResponse *httpResponse;
@property (nonatomic) NSInteger     statusCode;
@property (nonatomic) NSString      *uberErrorCode;
@property (nonatomic) NSDictionary  *responseData;
@property (nonatomic) NSData        *data;

- (instancetype)initWithData:(NSDictionary *)dict uberErrorCode:(NSString *)uberCode statusCode:(NSInteger)statusCode httpURLResponse:(NSHTTPURLResponse *)httpResponse;
@end
