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

- (void)test NS_DEPRECATED_IOS(5_0,6_0);

@end

@implementation ViewController

- (void)test {
    NSLog(@"111");
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self test];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    if ([HKHealthStore isHealthDataAvailable]) {
        NSLog(@"可以使用healthKit");
        
        healthStore = [[HKHealthStore alloc] init];
        
        NSSet *shareTypes = [NSSet setWithObjects:
                             [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned],
                             [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning],
                             [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
                             [HKCategoryType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis],
                             [HKWorkoutType workoutType],
                              nil];
        
        NSSet *readTypes = [NSSet setWithObjects:
//                            [HKCorrelationType correlationTypeForIdentifier:HKCorrelationTypeIdentifierBloodPressure],
                            [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex],
                            nil];
        
        [healthStore requestAuthorizationToShareTypes:shareTypes
                                            readTypes:readTypes
                                           completion:^(BOOL success, NSError * _Nullable error) {
                                               if (!success) {
                                                   NSLog(@"===%@", error);
                                               }else {
                                                   NSLog(@"yes");
                                               }
                                           }];
        
        
        NSDate *start = [NSDate date];
        NSDate *end = [NSDate dateWithTimeIntervalSince1970:[[NSDate date] timeIntervalSince1970] + 60*60*2];
        NSLog(@"%@", start);
        NSLog(@"%@", end);
        
        //quantity
        HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit countUnit] doubleValue:(double)1000];
        HKQuantitySample *quantitySample = [HKQuantitySample quantitySampleWithType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]
                                                                           quantity:quantity
                                                                          startDate:start
                                                                            endDate:end];
        
        NSLog(@"------%ld", (long)[healthStore authorizationStatusForType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]]);
        NSLog(@"------%ld", (long)[healthStore authorizationStatusForType:[HKCorrelationType correlationTypeForIdentifier:HKCorrelationTypeIdentifierBloodPressure]]);
        
        
        //category
        NSDictionary *metadata = @{HKMetadataKeyTimeZone: [NSTimeZone systemTimeZone].name};
        HKCategorySample *categorySample = [HKCategorySample categorySampleWithType:[HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis]
                                                                              value:HKCategoryValueSleepAnalysisAsleep
                                                                          startDate:start
                                                                            endDate:end
                                                                            metadata:metadata];
        
        //correlation
        NSDate *date = [NSDate date];
        
        // Create systolic sample
        
        HKQuantityType *systolicType =
        [HKObjectType quantityTypeForIdentifier:
         HKQuantityTypeIdentifierBloodPressureSystolic];
        
        HKQuantity *systolicQuantity =
        [HKQuantity quantityWithUnit:[HKUnit millimeterOfMercuryUnit]
                         doubleValue:120.0];
        
        HKQuantitySample *systolicSample =
        [HKQuantitySample quantitySampleWithType:systolicType
                                        quantity:systolicQuantity
                                       startDate:date
                                         endDate:date];
        
        // Create diastolic sample
        
        HKQuantityType *diastolicType =
        [HKObjectType quantityTypeForIdentifier:
         HKQuantityTypeIdentifierBloodPressureDiastolic];
        
        HKQuantity *diastolicQuantity =
        [HKQuantity quantityWithUnit:[HKUnit millimeterOfMercuryUnit]
                         doubleValue:75.0];
        
        HKQuantitySample *diastolicSample =
        [HKQuantitySample quantitySampleWithType:diastolicType
                                        quantity:diastolicQuantity
                                       startDate:date
                                         endDate:date];
        
        // Create blood pressure sample
        
        HKCorrelationType *bloodPressureType =
        [HKObjectType correlationTypeForIdentifier:
         HKCorrelationTypeIdentifierBloodPressure];
        
        NSSet *objects = [NSSet setWithObjects:systolicSample, diastolicSample, nil];
        
        HKCorrelation *bloodPressure =
        [HKCorrelation correlationWithType:bloodPressureType
                                 startDate:date
                                   endDate:date
                                   objects:objects];

        
//        [healthStore deleteObject:categorySample withCompletion:^(BOOL success, NSError * _Nullable error) {
//            if (success) {
//                NSLog(@"删除成功");
//            }
//        }];
//        
        [healthStore saveObjects:@[quantitySample, categorySample] withCompletion:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                NSLog(@"更新成功");
            }else {
                NSLog(@"更新失败：%@", error);
            }
        }];
        
        
//        HKUnit *BPunit = [HKUnit millimeterOfMercuryUnit];
//        HKQuantity *BPSysQuantity = [HKQuantity quantityWithUnit:BPunit doubleValue:150.0];
//        HKQuantityType *BPSysType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic];
//        HKQuantitySample *BPSysSample = [HKQuantitySample quantitySampleWithType:BPSysType quantity:BPSysQuantity startDate:start endDate:start];
//        [healthStore saveObject:BPSysSample withCompletion:^(BOOL success, NSError *error) {
//            if (success) {
//                NSLog(@"更新成功");
//            }else {
//                NSLog(@"更新失败：%@", error);
//            }
//        }];
//        
//        [self saveBloodPressureIntoHealthStore:75.0 Dysbp:75.0];
        
        /**
         *  读取数据
         */
        [self read];
    }
}

- (void)read {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *now = [NSDate date];
    
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    
    NSDate *startDate = [calendar dateFromComponents:components];
    
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    
    HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:predicate limit:0 sortDescriptors:nil resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        if (!results) {
            NSLog(@"An error occured fetching the user's tracked food. In your app, try to handle this gracefully. The error was: %@.", error);
//            abort();
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            for (HKQuantitySample *sample in results) {
                NSString *foodName = sample.metadata[HKMetadataKeyFoodType];
                double joules = [sample.quantity doubleValueForUnit:[HKUnit jouleUnit]];
                
                NSLog(@"%@, %f", foodName, joules);
            }
        });
    }];
    
    [healthStore executeQuery:query];
    
    HKSampleType *type = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKSourceQuery *sourceQuery = [[HKSourceQuery alloc] initWithSampleType:type samplePredicate:predicate completionHandler:^(HKSourceQuery * _Nonnull query, NSSet<HKSource *> * _Nullable sources, NSError * _Nullable error) {
        if (!sources) {
            NSLog(@"An error occured fetching the user's tracked food. In your app, try to handle this gracefully. The error was: %@.", error);
//            abort();
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [sources enumerateObjectsUsingBlock:^(HKSource * _Nonnull obj, BOOL * _Nonnull stop) {
                NSLog(@"sourceName: %@, identifier: %@", obj.name, obj.bundleIdentifier);
            }];
        });
    }];
    [healthStore executeQuery:sourceQuery];

}

- (void)saveBloodPressureIntoHealthStore:(double)Systolic Dysbp:(double)Diastolic {
    
    HKUnit *BloodPressureUnit = [HKUnit millimeterOfMercuryUnit];
    
    HKQuantity *SystolicQuantity = [HKQuantity quantityWithUnit:BloodPressureUnit doubleValue:Systolic];
    HKQuantity *DiastolicQuantity = [HKQuantity quantityWithUnit:BloodPressureUnit doubleValue:Diastolic];
    
    HKQuantityType *SystolicType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic];
    HKQuantityType *DiastolicType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureDiastolic];
    
    NSDate *now = [NSDate date];
    
    HKQuantitySample *SystolicSample = [HKQuantitySample quantitySampleWithType:SystolicType quantity:SystolicQuantity startDate:now endDate:now];
    HKQuantitySample *DiastolicSample = [HKQuantitySample quantitySampleWithType:DiastolicType quantity:DiastolicQuantity startDate:now endDate:now];
    
    NSSet *objects=[NSSet setWithObjects:SystolicSample,DiastolicSample, nil];
    HKCorrelationType *bloodPressureType = [HKObjectType correlationTypeForIdentifier:
                                            HKCorrelationTypeIdentifierBloodPressure];
    HKCorrelation *BloodPressure = [HKCorrelation correlationWithType:bloodPressureType startDate:now endDate:now objects:objects];
    [healthStore saveObject:BloodPressure withCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"An error occured saving the height sample %@. In your app, try to handle this gracefully. The error was: %@.", BloodPressure, error);
            abort();
        }
        UIAlertView *savealert=[[UIAlertView alloc]initWithTitle:@"HealthDemo" message:@"Blood Pressure values has been saved to Health App" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [savealert show];
    }];
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
