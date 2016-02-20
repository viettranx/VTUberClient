# VTUberClient
A lib to interact with Uber endpoints easier

## Usage
- Import folder VTUberClient into your project
- Import VTUberClient header into classes where you want to make requests to Uber APIs.
``` #import "VTUberClient.h" ```

### 1. Settings
All of infos below can be found in Uber Developer page of your app
```
[[VTUberClient shareInstance] setClientID:@"YOUR_CLIENT_ID"];
[[VTUberClient shareInstance] setClientSecret:@"YOUR_CLIENT_SECRET"];
[[VTUberClient shareInstance] setRedirectURI:@"YOUR_REDIRECT_URI"];

// Remember set this line to YES if you want to use it in production environment.
//[[VTUberClient shareInstance] setEnabledProductionMode: YES];
```

### 2. Authentication with OAuth 2.0
This method will display a webview controller to login into Uber
```
VTUberLoginManager *loginManager = [[VTUberLoginManager alloc] init];
// loginManager.delegate = self; // you may need it to handle with callback methods
[loginManager loginWithViewController:self scopes:@"profile history request"];
```

### 3. Make request to Uber Endpoints
At this time, you can make requests to Uber APIs following by this page: https://developer.uber.com/docs/overview
```
NSDictionary *paramsDict = @{ @"latitude" :@demoLocationLat,
@"longitude":@demoLocationLng
};

[[VTUberClient shareInstance] api:@"/v1/products" method:@"GET" params:paramsDict successHandler:^(VTUberClientRequest *req, VTUberClientResponse *res, NSError *error) {
NSLog(@"%@", res.responseData);
// handle for success

} failHandler:^(NSData *errorData, NSURLResponse *res, NSError *error) {
// fail handler
}];
```
For more safety, you should check your access token still be valid before make a request:

```
if ([[VTUberClient shareInstance].tokenData isValid]) {

[[VTUberClient shareInstance] api:@"/v1/me" method:@"GET" params:nil successHandler:^(VTUberClientRequest *req, VTUberClientResponse *res, NSError *error) {

NSLog(@"Uber response: %@", res.responseData);

} failHandler:^(NSData *errorData, NSURLResponse *res, NSError *error) {
//
}];
}
```

## Contribution: 
This is just relax project. I think it will be missed manay cases to handle in your real app. So please feel free to contribute it :)