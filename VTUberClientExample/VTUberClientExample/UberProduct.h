//
//  UberProduct.h
//  VTUberClientExample
//
//  Created by Tran Viet on 2/19/16.
//  Copyright © 2016 viettranx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UberProduct : NSObject
@property (nonatomic) NSString *prodID;
@property (nonatomic) NSString *prodDescription;
@property (nonatomic) NSString *prodName;
@property (nonatomic) NSString *prodImageURL;
@property (nonatomic) NSInteger prodCapacity;

@property (nonatomic) NSString *prodCurrencyCode;
@property (nonatomic) NSString *prodDistanceUnit;

@property (nonatomic) float    prodCostPerMin;
@property (nonatomic) float    prodCostPerDistance;
@property (nonatomic) float    prodCancelFees;

// Use to save image data, it's just a test modal, dont use this way on your project :D
@property (nonatomic) UIImage *prodImage;
@end
