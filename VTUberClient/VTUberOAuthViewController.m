//
//  OAuthViewController.m
//  FoodyMobile
//
//  Created by Duc Trinh on 12/7/12.
//  Copyright (c) 2012 Foody Corp. All rights reserved.
//

#import "VTUberOAuthViewController.h"
#import "VTUberClient.h"

@interface VTUberOAuthViewController() {
    UIActivityIndicatorView *indicator;
}

//@property (nonatomic, assign)   UIToolbar               *toolbar;
@property (nonatomic, strong)   UIWebView               *OAuthWebView;
@end

@implementation VTUberOAuthViewController
//@synthesize toolbar;
@synthesize OAuthWebView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(didTouchCancelButton:)];
    self.navigationItem.rightBarButtonItem = cancelButton;
    
    
    [self setTitle:@"Uber Authentication"];
    
    OAuthWebView = [[UIWebView alloc] initWithFrame: CGRectZero] ;
    OAuthWebView.delegate = self;
    OAuthWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:OAuthWebView];
    [self loadOAuthPage];
    
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:indicator];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    self.OAuthWebView.frame= self.view.bounds;
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)showIndicator {
    indicator.center = self.view.center;
    indicator.hidden = NO;
    [indicator startAnimating];
}

- (void)hideIndicator {
    indicator.hidden = YES;
    [indicator stopAnimating];
}

- (void)didTouchCancelButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self cancelTimer];
        
        if (self.loginManager && self.loginManager.delegate) {
            
            if ([self.loginManager.delegate respondsToSelector:@selector(userDidCancelLogin:)]) {
                [self.loginManager.delegate userDidCancelLogin:self.loginManager];
            }
        }
        
    }];
}

- (void)loadOAuthPage
{
    NSCharacterSet *customAllowedChars = [NSCharacterSet characterSetWithCharactersInString:@" =\"#%/<>?@\\^`{|}!$&'()*+,:;[]%"].invertedSet;
    NSString *scopes = [self.loginManager.scopes stringByAddingPercentEncodingWithAllowedCharacters:customAllowedChars];
    
    NSString *UberLoginURL = [NSString stringWithFormat:kOAuthURLFormat, [VTUberClient shareInstance].clientID, scopes];
    NSURL *URL = [NSURL URLWithString:UberLoginURL];
    NSMutableURLRequest *URLRequest = [NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    
    [OAuthWebView loadRequest:URLRequest];
}

#pragma mark - UIWebviewDelegate method
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    // webView connected
    if (timer == nil) {
        timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(requestTimeOut) userInfo:nil repeats:NO];
    }
    
    [self showIndicator];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self cancelTimer];
    [self hideIndicator];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
    if ([error code] == -1004) //Could not connect to the server
    {
        [self cancelTimer];
        [self hideIndicator];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    //NSLog(@"%@", request.URL);
    
    if ([request.URL.absoluteString containsString: [NSString stringWithFormat:@"%@?code=", [VTUberClient shareInstance].redirectURI]]) {
        
        [self cancelTimer];
        
        NSArray *components = [request.URL.absoluteString componentsSeparatedByString:@"?code="];
        NSString *code = [components objectAtIndex:1];
        
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:[VTUberClient shareInstance].clientID forKey:@"client_id"];
        [params setObject:[VTUberClient shareInstance].clientSecret forKey:@"client_secret"];
        [params setObject:[VTUberClient shareInstance].redirectURI forKey:@"redirect_uri"];
        [params setObject:@"authorization_code" forKey:@"grant_type"];
        [params setObject:code forKey:@"code"];
        
        VTUberClientRequest *uRequest = [[VTUberClientRequest alloc] initWithURL:kUberGetTokenURL method:@"POST" params:params token:nil secret:nil];
        
        [uRequest setSuccessHandler:^(VTUberClientRequest *req, VTUberClientResponse *res, NSError *error) {
            
            NSDictionary *dict = res.responseData;
            //NSLog(@"Data: %@", dict);
            
            VTUberTokenData *tokenData = [[VTUberTokenData alloc] initWithDictionary:dict];
            [VTUberClient shareInstance].tokenData = tokenData;
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
            if (self.loginManager && self.loginManager.delegate) {
                
                if ([self.loginManager.delegate respondsToSelector:@selector(uberLoginDidSuccess:)]) {
                    [self.loginManager.delegate uberLoginDidSuccess:self.loginManager];
                }
            }
        }];
        
        [uRequest setFailHandler:^(NSData *dataError, NSURLResponse *res, NSError *err) {
            if (self.loginManager && self.loginManager.delegate) {
                
                if ([self.loginManager.delegate respondsToSelector:@selector(uberLoginDidError:errorResponse:errorData:error:)]) {
                    [self.loginManager.delegate uberLoginDidError:self.loginManager errorResponse:res errorData:dataError error:err];
                }
            }
        }];
        
        
        [uRequest makeRequest];
        
        //NSLog(@"%@", code);
        return NO;
    }
    
    [self showIndicator];
    return YES;
}

#pragma mark - time out

- (void)requestTimeOut
{
    [self cancelTimer];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (self.loginManager && self.loginManager.delegate) {
        
        if ([self.loginManager.delegate respondsToSelector:@selector(uberLoginDidTimeout:)]) {
            [self.loginManager.delegate uberLoginDidTimeout:self.loginManager];
        }
    }
}

- (void)cancelTimer{
    if (timer != nil) {
        [timer invalidate];
        timer = nil;
    }
}
@end
