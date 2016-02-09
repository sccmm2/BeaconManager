//
//  BeaconManager.h
//  BeaconManager
//
//  Created by Sung on 2016. 2. 4..
//  Copyright © 2016년 Sung. All rights reserved.


#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol BeaconManagerDelegate;

@interface BeaconManager : NSObject <CLLocationManagerDelegate,CBCentralManagerDelegate> {
    NSMutableDictionary *originDict;
    NSMutableDictionary *compareDict;
}

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CBCentralManager * bluetoothManager;
@property (strong, nonatomic) CLBeaconRegion *myBeaconRegion;
@property (nonatomic) UIBackgroundTaskIdentifier background_task;
@property (strong, nonatomic) NSTimer *myTimer;
@property (assign) id<BeaconManagerDelegate>delegage;

@end

@protocol BeaconManagerDelegate <NSObject>
-(void) beaconManager:(BeaconManager *)bm RequestBeaconInWithBeaconId:(NSArray *)beaconIdArray;
-(void) beaconManager:(BeaconManager *)bm RequestBeaconOutWithBeaconId:(NSArray *)beaconIdArray;

@end

