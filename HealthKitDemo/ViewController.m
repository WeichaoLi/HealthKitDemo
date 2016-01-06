//
//  ViewController.m
//  HealthKitDemo
//
//  Created by 李伟超 on 16/1/6.
//  Copyright © 2016年 LWC. All rights reserved.
//

#import "ViewController.h"
#import <HealthKit/HealthKit.h>

@interface ViewController () {
    HKHealthStore *healthStore;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if ([HKHealthStore isHealthDataAvailable]) {
        NSLog(@"可以使用healthKit");
        
        healthStore = [[HKHealthStore alloc] init];
        
        NSString *unitIdentifier = HKQuantityTypeIdentifierStepCount;
        
        NSSet *sampleTypes = [NSSet setWithObjects:[HKWorkoutType workoutType],
                              [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned],
                              [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning],
                              [HKQuantityType quantityTypeForIdentifier:unitIdentifier],
                              nil];
        
        [healthStore requestAuthorizationToShareTypes:sampleTypes
                                            readTypes:nil
                                           completion:^(BOOL success, NSError * _Nullable error) {
                                               if (!success) {
                                                   NSLog(@"===%@", error);
                                               }
                                           }];
        
        HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit countUnit] doubleValue:(double)1000];
        HKQuantitySample *quantitySample = [HKQuantitySample quantitySampleWithType:[HKObjectType quantityTypeForIdentifier:unitIdentifier]
                                                                           quantity:quantity
                                                                          startDate:[NSDate date]
                                                                            endDate:[NSDate date]];
        
        [healthStore saveObject:quantitySample withCompletion:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                NSLog(@"更新步数成功");
            }
        }];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
