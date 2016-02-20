//
//  VTUberClientRequest.m
//  VTUberClientExample
//
//  Created by Tran Viet on 2/17/16.
//  Copyright © 2016 viettranx. All rights reserved.
//

#import "VTUberClientRequest.h"
#import "VTUberClientResponse.h"

@interface VTUberClientRequest()
{
    NSString *token;
    NSString *secret;
    NSString *requestMethod;
    UberResponseSuccessHandler successHandler;
    UberResponseFailHandler failHandler;
}

@end

@implementation VTUberClientRequest

- (instancetype)initWithURL:(NSString *)url method:(NSString *)method params:(NSDictionary *)params token:(NSString *)clientToken secret:(NSString *)clientSecret;
{
    if (self = [super init]) {
        self.url = url;
        self.params = params;
        token = clientToken;
        secret = clientSecret;
        requestMethod = method;
    }
    
    return self;
}

- (void) setSuccessHandler:(UberResponseSuccessHandler)hdl {
    successHandler = hdl;
}

- (void)setFailHandler:(UberResponseFailHandler)hdl {
    failHandler = hdl;
}



- (void)makeRequest {
    
    @autoreleasepool {
        NSString *url = [self absoluteURLFromParams:self.params];
        
        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
        
        // create request
        [request setHTTPMethod:requestMethod];
        
        // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
        NSString *boundary = @"----------V2ymHFjf34g03ehbqgZCaKO6jy";
        
        // set Content-Type in HTTP header
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        if(self.params && self.params.allKeys.count > 0) {
            
            // FOR POST REQUEST
            if ([[requestMethod uppercaseString] isEqualToString:@"POST"]) {
                NSMutableData *body = [NSMutableData data];
                
                int i = 0;
                
                for (NSString *p in [self.params allKeys]) {
                    id field_value = [self.params objectForKey:p];
                    
                    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", p] dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    [body appendData:[[NSString stringWithFormat:@"%@\r\n", field_value] dataUsingEncoding:NSUTF8StringEncoding]];
                    i++;
                }
                
                // Close form
                [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                
                // setting the body to the request
                [request setHTTPBody:body];
                
                // set the content-length
                NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
                [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            }
        }
        
        // set Authorization Token to header
        if (token) {
            [request addValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:@"Authorization"];
        }
        
        @try
        {
            
            [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                
                if (error) {
                    if (failHandler) {
                        failHandler(data, response, error);
                    }
                    return;
                }
                
                NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:data
                                                                           options:0
                                                                             error:&error];
                if (error || ([httpResponse statusCode] < 200 || [httpResponse statusCode] > 200) ) {
                    
                    if (failHandler) {
                        failHandler(data, response, error);
                    }
                    return;
                }
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    VTUberClientResponse *uberRes = [[VTUberClientResponse alloc] initWithData:resultDict uberErrorCode:nil statusCode:[httpResponse statusCode] httpURLResponse:httpResponse];
                    uberRes.data = data;
                    
                    if (successHandler) {
                        successHandler(self, uberRes, error);
                    }
                });
                
            }] resume];
        }
        @catch(NSException *ex)
        {
            // Unknow error
            if (failHandler) {
                failHandler(nil, nil, nil);
            }
        }
    }
    
}

- (NSString *)absoluteURLFromParams:(NSDictionary *)params {
    NSString *result = self.url;
    self.absoluteURL = self.url;
    
    if (!params) {
        return result;
    }
    
    if ([[requestMethod uppercaseString] isEqualToString:@"GET"]) {
        NSCharacterSet *customAllowedChars = [NSCharacterSet characterSetWithCharactersInString:@" =\"#%/<>?@\\^`{|}!$&'()*+,:;[]%"].invertedSet;
        
        result = [result stringByAppendingString:@"?"];
        
        NSMutableArray *temp = [NSMutableArray new];
        
        for (NSString *fieldName in [params allKeys]) {
            
            NSString *fieldValue = [params objectForKey:fieldName];
            
            if ([fieldValue isKindOfClass:[NSString class]]) {
                fieldValue = [fieldValue stringByAddingPercentEncodingWithAllowedCharacters:customAllowedChars];
            }
            
            [temp addObject:[NSString stringWithFormat:@"%@=%@", fieldName, fieldValue]];
        }
        
        result = [result stringByAppendingString:[temp componentsJoinedByString:@"&"]];
        self.absoluteURL = result;
    }
    
    return result;
}
@end
