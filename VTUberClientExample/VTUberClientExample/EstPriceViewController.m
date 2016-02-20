//
//  EstPriceViewController.m
//  VTUberClientExample
//
//  Created by Tran Viet on 2/19/16.
//  Copyright © 2016 viettranx. All rights reserved.
//

#import "EstPriceViewController.h"
#import "UberProduct.h"

#import "AppDelegate.h"
#import "VTUberClient.h"

@interface EstPriceViewController() {
    UIView *loadingView;
}
@property (weak, nonatomic) IBOutlet UILabel *testLocationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *estPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *productIDLabel;

@end

@implementation EstPriceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"Estimate Price from Uber"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.testLocationLabel.text = [NSString stringWithFormat:@"Test location from %.3f, %.3f to %.3f, %.3f", demoLocationLat, demoLocationLng, demoDropOffLat, demoDropOffLng];
    self.productImageView.image = self.product.prodImage;
    self.productNameLabel.text = self.product.prodName;
    self.productIDLabel.text = [NSString stringWithFormat:@"ID: %@", self.product.prodID];
    
    [self getEstPricesFromUber];
}



- (IBAction)makeRequestTouched:(UIButton *)sender {
    [self makeRequestRideToUber];
}

#pragma mark - Use VTUberClient
- (void)getEstPricesFromUber {
    
    if ([[VTUberClient shareInstance].tokenData isValid]) {
        
        [self showLoadingView];
        
        NSDictionary *paramsDict = @{ @"start_latitude" :@demoLocationLat,
                                      @"start_longitude":@demoLocationLng,
                                      @"end_latitude" :@demoDropOffLat,
                                      @"end_longitude":@demoLocationLng,
                                      };
        
        [[VTUberClient shareInstance] api:@"/v1/estimates/price" method:@"GET" params:paramsDict successHandler:^(VTUberClientRequest *req, VTUberClientResponse *res, NSError *error) {
            NSLog(@"%@", res.responseData);
            
            NSArray *prices = [res.responseData objectForKey:@"prices"];
            // Uber returns a list of prices, not specific for our product id
            // So we need to find it out
            NSDictionary *priceDict = nil;
            for (NSDictionary *prDict in prices) {
                if ([[prDict objectForKey:@"product_id"] isEqualToString:self.product.prodID]) {
                    priceDict = prDict;
                    break;
                }
            }
            
            if (!priceDict) {
                // product not found :(
                
                UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"Error" message:@"Product not found" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                [alertView addAction:cancelAction];
                
                [self presentViewController:alertView animated:YES completion:nil];
                
            } else {
                // Found product and display info
                
                float distance = [[priceDict objectForKey:@"distance"] floatValue];
                NSString *distanceUnit = self.product.prodDistanceUnit;
                
                float lowPrice = [[priceDict objectForKey:@"low_estimate"] floatValue];
                float highPrice = [[priceDict objectForKey:@"high_estimate"] floatValue];
                NSString *currencyCode = [priceDict objectForKey:@"currency_code"];
                
                self.estPriceLabel.text = [NSString stringWithFormat:@"Est Price: %.1f %@ - %.1f %@", lowPrice, currencyCode, highPrice, currencyCode];
                self.distanceLabel.text = [NSString stringWithFormat:@"Distance: %.1f %@", distance, distanceUnit];
            }
            
            [self hideLoadingView];
        } failHandler:^(NSData *errorData, NSURLResponse *res, NSError *error) {
            NSLog(@"Error: %@", res);
        }];
    }
}

- (void)makeRequestRideToUber {
    
    if ([[VTUberClient shareInstance].tokenData isValid]) {
        
        [self showLoadingView];
        
        NSDictionary *paramsDict = @{
                                        @"product_id": self.product.prodID,
                                        @"start_latitude" :@demoLocationLat,
                                        @"start_longitude":@demoLocationLng,
                                        @"end_latitude" :@demoDropOffLat,
                                        @"end_longitude":@demoLocationLng,
                                      };
        
        [[VTUberClient shareInstance] api:@"/v1/requests" method:@"POST" params:paramsDict successHandler:^(VTUberClientRequest *req, VTUberClientResponse *res, NSError *error) {
            NSLog(@"%@", res.responseData);
            [self hideLoadingView];
            
            UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"Success" message:@"Request success, please check your current request" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
            
            [alertView addAction:cancelAction];
            [self presentViewController:alertView animated:YES completion:nil];
            
            
        } failHandler:^(NSData *errorData, NSURLResponse *res, NSError *error) {
            NSLog(@"Error data: %@", [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding]);
            NSLog(@"Error: %@", res);
            
            UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"Error" message:@"Request fail" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
            
            [alertView addAction:cancelAction];
            [self presentViewController:alertView animated:YES completion:nil];
            
            [self hideLoadingView];
        }];
    }
}

#pragma mark - Loading view
- (void)showLoadingView {
    if (!loadingView) {
        loadingView = [[UIView alloc] init];
        [loadingView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
        [self.view addSubview:loadingView];
        
        // ActivityIndicator
        UIActivityIndicatorView *icv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        [icv startAnimating];
        icv.center = self.view.center;
        [loadingView addSubview:icv];
        
        // Appear rect
        CGRect appearRect = self.view.bounds;
        appearRect.origin.y = self.view.bounds.size.height + 10;
        [loadingView setFrame:appearRect];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        [loadingView setFrame:self.view.bounds];
    }];
}

- (void)hideLoadingView {
    if (!loadingView) {
        return;
    }
    
    CGRect appearRect = self.view.bounds;
    appearRect.origin.y = self.view.bounds.size.height + 10;
    [loadingView setFrame:appearRect];
    
    [UIView animateWithDuration:0.2 animations:^{
        [loadingView setFrame:appearRect];
    }];
}
@end
