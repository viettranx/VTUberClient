//
//  UberTableViewCell.h
//  VTUberClientExample
//
//  Created by Tran Viet on 2/19/16.
//  Copyright © 2016 viettranx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UberTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *displayNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *capacityValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *costPerDistanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *costPerMinLabel;
@property (weak, nonatomic) IBOutlet UILabel *cancelFeesLabel;

@end
