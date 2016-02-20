//
//  ViewController.m
//  VTUberClientExample
//
//  Created by Tran Viet on 2/15/16.
//  Copyright © 2016 viettranx. All rights reserved.
//

#import "ViewController.h"
#import "VTUberClient.h"
#import "VTUberOAuthViewController.h"
#import "UberTableViewCell.h"
#import "UberProduct.h"
#import "EstPriceViewController.h"

#import "AppDelegate.h"

@interface ViewController ()<VTUberLoginDelegate, UITableViewDataSource, UITableViewDelegate> {
    BOOL isFirstRun;
    VTUberOAuthViewController *oauthVC;
    UIView *loadingView;
    
    NSMutableArray *productsArr;
}
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UITableView *uberProductsTable;
@property (weak, nonatomic) IBOutlet UILabel *userInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *getCarsButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isFirstRun = YES;
    
    self.uberProductsTable.delegate = self;
    self.uberProductsTable.dataSource = self;
    
    self.uberProductsTable.rowHeight = UITableViewAutomaticDimension;
    self.uberProductsTable.estimatedRowHeight = 80;
    
    productsArr = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Prevent from calling Uber api again and again when we pop from other view controllers
    if (isFirstRun) {
        isFirstRun = NO;
        self.locationLabel.text = [NSString stringWithFormat:@"Test location: %.4f, %.4f", demoLocationLat, demoLocationLng];
        
        [self getUserInfoFromUber];
    }
    
}

#pragma mark - Use VTUberClient

- (void)getProductsFromUber {
    
    if (![[VTUberClient shareInstance].tokenData isValid]) return;
    
    [self showLoadingView];
    
    NSDictionary *paramsDict = @{ @"latitude" :@demoLocationLat,
                                  @"longitude":@demoLocationLng
                                 };
    
    [[VTUberClient shareInstance] api:@"/v1/products" method:@"GET" params:paramsDict successHandler:^(VTUberClientRequest *req, VTUberClientResponse *res, NSError *error) {
        NSLog(@"%@", res.responseData);
        
        NSArray *products = [res.responseData objectForKey:@"products"];
        
        // Add product to array
        [productsArr removeAllObjects];
        
        for (NSDictionary *prodDict in products) {
            UberProduct *product = [[UberProduct alloc] init];
            product.prodID = [prodDict objectForKey:@"product_id"];
            product.prodName = [prodDict objectForKey:@"display_name"];
            product.prodDescription = [prodDict objectForKey:@"description"];
            product.prodCapacity = [[prodDict objectForKey:@"capacity"] integerValue];
            product.prodImageURL = [prodDict objectForKey:@"image"];
            
            NSDictionary *priceDetailDict = [prodDict objectForKey:@"price_details"];
            product.prodCurrencyCode = [priceDetailDict objectForKey:@"currency_code"];
            product.prodDistanceUnit = [priceDetailDict objectForKey:@"distance_unit"];
            
            product.prodCostPerMin = [[priceDetailDict objectForKey:@"cost_per_minute"] floatValue];
            product.prodCostPerDistance = [[priceDetailDict objectForKey:@"cost_per_distance"] floatValue];
            product.prodCancelFees = [[priceDetailDict objectForKey:@"cancellation_fee"] floatValue];
            
            [productsArr addObject:product];
        }
        
        [self.uberProductsTable reloadData];
        [self hideLoadingView];
        
    } failHandler:^(NSData *errorData, NSURLResponse *res, NSError *error) {
        
    }];
}



- (void)getUserInfoFromUber {
    if ([[VTUberClient shareInstance].tokenData isValid]) {
        
        [self showLoadingView];
        
        [[VTUberClient shareInstance] api:@"/v1/me" method:@"GET" params:nil successHandler:^(VTUberClientRequest *req, VTUberClientResponse *res, NSError *error) {
            
            NSLog(@"Uber response: %@", res.responseData);
            
            self.userInfoLabel.text = [NSString stringWithFormat:@"Logged user: %@ %@", [res.responseData objectForKey:@"first_name"], [res.responseData objectForKey:@"last_name"]];
            
            [self.loginButton setTitle:@"Log out" forState:UIControlStateNormal];
            self.loginButton.tag = 1;
            self.loginButton.enabled = YES;
            
            [self hideLoadingView];
            
        } failHandler:^(NSData *errorData, NSURLResponse *res, NSError *error) {
            self.loginButton.enabled = YES;
            [self hideLoadingView];
        }];
    }
}

- (void)updateUIWhenUserLoggedOut {
    [self.loginButton setTitle:@"Login Uber" forState:UIControlStateNormal];
    self.userInfoLabel.text = @"Logged user: None";
    
    [productsArr removeAllObjects];
    [self.uberProductsTable reloadData];
}

#pragma mark - Loading view
- (void)showLoadingView {
    if (!loadingView) {
        loadingView = [[UIView alloc] init];
        [loadingView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
        [self.view addSubview:loadingView];
        
        // ActivityIndicator
        UIActivityIndicatorView *icv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        //NSLog(@"icv frame: %@", NSStringFromCGRect(icv.frame));
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
    
    // Appear rect
    CGRect appearRect = self.view.bounds;
    appearRect.origin.y = self.view.bounds.size.height + 10;
    [loadingView setFrame:appearRect];
    
    [UIView animateWithDuration:0.2 animations:^{
        [loadingView setFrame:appearRect];
    }];
}

#pragma mark - Login manager delagate methods

- (void)userDidCancelLogin:(VTUberLoginManager *)loginManager {
    self.loginButton.enabled = YES;
}

- (void)uberLoginDidTimeout:(VTUberLoginManager *)loginManager {
    self.loginButton.enabled = YES;
}

- (void)uberLoginDidSuccess:(VTUberLoginManager *)loginManager {
    self.loginButton.enabled = YES;
    [self getUserInfoFromUber];
}

- (void)uberLoginDidError:(VTUberLoginManager *)loginManager errorResponse:(NSURLResponse *)errRes errorData:(NSData *)errData error:(NSError *)err {
    // handle error
    self.loginButton.enabled = YES;
}

#pragma mark - IBActions

- (IBAction)loginWithUber:(UIButton *)sender {
    
    if (sender.tag == 0) {
        VTUberLoginManager *loginManager = [[VTUberLoginManager alloc] init];
        loginManager.delegate = self;
        [loginManager loginWithViewController:self scopes:@"profile history request"];
        sender.enabled = NO;
    } else {
        // Log out / Disconnect to Uber endpoint
        [[[VTUberClient shareInstance] tokenData] revokeToken];
        [self updateUIWhenUserLoggedOut];
        sender.tag = 0;
    }
}

- (IBAction)getCarsTouched:(UIButton *)sender {
    [self getProductsFromUber];
}

- (IBAction)showMyCurrentTouch:(UIButton *)sender {
    
}


#pragma mark - Table Datasource & Delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [productsArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"uberCell" forIndexPath:indexPath];
    
    UberProduct *product = [productsArr objectAtIndex:indexPath.row];
    cell.displayNameLabel.text = product.prodName;
    cell.capacityValueLabel.text = [NSString stringWithFormat:@"%ld", (long) product.prodCapacity];
    cell.distanceUnitLabel.text = [NSString stringWithFormat:@"Per %@", product.prodDistanceUnit];
    cell.costPerDistanceLabel.text = [NSString stringWithFormat:@"%.1f %@", product.prodCostPerDistance, product.prodCurrencyCode];
    cell.costPerMinLabel.text = [NSString stringWithFormat:@"%.1f %@", product.prodCostPerMin, product.prodCurrencyCode];
    cell.cancelFeesLabel.text = [NSString stringWithFormat:@"Cancel fees: %.2f %@", product.prodCancelFees, product.prodCurrencyCode];
    
    // It's just a demo project so I dont care much about how to get image on remote network
    if (product.prodImage) {
        cell.productImageView.image = product.prodImage;
    } else {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSURL *imgURL = [[NSURL alloc] initWithString:product.prodImageURL];
            NSData *imgData = [[NSData alloc] initWithContentsOfURL:imgURL];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                product.prodImage = [UIImage imageWithData:imgData];
                cell.productImageView.image = product.prodImage;
            });
            
        });
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UberProduct *product = [productsArr objectAtIndex:indexPath.row];
    EstPriceViewController *estPriceVC = [self.storyboard instantiateViewControllerWithIdentifier:@"estPriceVC"];
    estPriceVC.product = product;
    [self.navigationController pushViewController:estPriceVC animated:YES];
}
@end
