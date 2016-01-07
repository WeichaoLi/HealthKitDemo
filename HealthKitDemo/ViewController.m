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
                              [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
                              [HKCategoryType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis],
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
        
        NSDate *start = [NSDate date];
        NSDate *end = [NSDate dateWithTimeIntervalSince1970:[[NSDate date] timeIntervalSince1970] + 60*60*2];
        NSLog(@"%@", start);
        NSLog(@"%@", end);
        
        
        NSDictionary *metadata = @{HKMetadataKeyTimeZone: [NSTimeZone systemTimeZone].name};
        HKCategorySample *categorySample = [HKCategorySample categorySampleWithType:[HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis]
                                                                              value:HKCategoryValueSleepAnalysisAsleep
                                                                          startDate:start
                                                                            endDate:end
                                                                            metadata:metadata];
//        [healthStore deleteObject:categorySample withCompletion:^(BOOL success, NSError * _Nullable error) {
//            if (success) {
//                NSLog(@"删除成功");
//            }
//        }];
//        
//        [healthStore saveObjects:@[quantitySample, categorySample] withCompletion:^(BOOL success, NSError * _Nullable error) {
//            if (success) {
//                NSLog(@"更新成功");
//            }else {
//                NSLog(@"更新失败：%@", error);
//            }
//        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"===");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
