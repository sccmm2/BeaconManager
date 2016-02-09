//
//  AppDelegate.m
//  BeaconManager
//
//  Created by Sung on 2016. 2. 4..
//  Copyright © 2016년 Sung. All rights reserved.
//

#import "AppDelegate.h"
#import "BeaconManager.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface AppDelegate () <CLLocationManagerDelegate, CBCentralManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CBCentralManager * bluetoothManager;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [BeaconManager new];
//    self.locationManager = [[CLLocationManager alloc] init];
//    self.locationManager.delegate = self;
//    NSUInteger code = [CLLocationManager authorizationStatus];
//    if (code == kCLAuthorizationStatusNotDetermined && ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] || [self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])) {
//        if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]){
//            [self.locationManager requestAlwaysAuthorization];
//        } else if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
//            [self.locationManager requestWhenInUseAuthorization];
//        } else {
//            NSLog(@"Info.plist does not contain NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription");
//        }
//    }
//    self.locationManager.distanceFilter = kCLDistanceFilterNone;
//    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//    [self.locationManager startUpdatingLocation];
//    
//    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"];
//    // 비콘 디바이스 확인
//    BOOL b = [CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]];
//    NSLog(@"isMonitoringAvailableForClass = %u", b);
//    
//    // 디바이스가 ranging 측정이 가능한지 체크
//    if ([CLLocationManager isRangingAvailable]) {
//        NSLog(@"거리 측정 가능");
//        // 비콘 ranging
//        CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"SmartPulmuone"];
//        [self.locationManager startMonitoringForRegion:beaconRegion];
//        [self.locationManager startRangingBeaconsInRegion:beaconRegion];
//        beaconRegion.notifyEntryStateOnDisplay = YES;
//        beaconRegion.notifyOnEntry = YES;
//        beaconRegion.notifyOnExit = YES;
//    } else {
//        NSLog(@"거리 측정 불가능");
//    }
//    
//    if(!self.bluetoothManager) {
//        self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
//    }
//    
//    [self centralManagerDidUpdateState:self.bluetoothManager];
//    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark Bluetooth Delegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch(self.bluetoothManager.state){
        case CBCentralManagerStateResetting:
            NSLog(@"The connection with the system service was momentarily lost, update imminent.");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"The platform doesn't support Bluetooth Low Energy.");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"The app is not authorized to use Bluetooth Low Energy.");
            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@"Bluetooth is currently powered off.");
            break;
        case CBCentralManagerStatePoweredOn:
            NSLog(@"Bluetooth is currently powered on and available to use.");
            break;
        default:
            NSLog(@"State unknown, update imminent.");
            break;
    }
}

#pragma mark LocationManager Delegate
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"didStartMonitoringForRegion %@",region);
    CLBeaconRegion *tempBeacon = (CLBeaconRegion *)region;
    [_locationManager requestStateForRegion:tempBeacon];
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"monitoringDidFailForRegion : %@",error);
    //    UIAlertView *uav = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"gps_check", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"confirm", nil) otherButtonTitles:nil, nil];
    //    [uav setTag:3];
    //    [uav show];
}

- (void)locationManager:(CLLocationManager*)manager didEnterRegion:(CLRegion *)region{
    CLBeaconRegion *tempBeacon = (CLBeaconRegion *)region;
    NSLog(@"didEnterRegion %@", tempBeacon);
    if (tempBeacon == nil) return;
    
    //[self localNotiWithBeaconRegion:tempBeacon isExit:NO];
    [self.locationManager startRangingBeaconsInRegion:tempBeacon];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{
    CLBeaconRegion *tempBeacon = (CLBeaconRegion *)region;
    NSLog(@"didExitRegion %@",tempBeacon);
    if (tempBeacon == nil) return;
    
    //[self localNotiWithBeaconRegion:tempBeacon isExit:YES];
    [self.locationManager stopRangingBeaconsInRegion:tempBeacon];
}

-(void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    CLBeaconRegion *tempBeacon = (CLBeaconRegion *)region;
    if (tempBeacon == nil) return;
    NSLog(@"didDetermineState %@", tempBeacon);
    if (state == CLRegionStateInside) {
        NSLog(@"CLRegionStateInside");
        //[self localNotiWithBeaconRegion:tempBeacon isExit:NO];
    }else if(state == CLRegionStateOutside){
        NSLog(@"CLRegionStateOutside");
        //[self localNotiWithBeaconRegion:tempBeacon isExit:YES];
    }else{
        NSLog(@"CLRegionStateUnknown");
    }
}

-(void)locationManager:(CLLocationManager*)manager didRangeBeacons:(NSArray*)beacons inRegion:(CLBeaconRegion*)region{
    if([beacons count] == 0) return;
    for(CLBeacon *beacon in beacons) {
        NSLog(@"beacon major %@m minor %@", beacon.major, beacon.minor);
        if (beacon.proximity == CLProximityImmediate) {
            //NSLog(@"CLProximityImmediate");
        } else if (beacon.proximity == CLProximityNear) {
            //NSLog(@"CLProximityNear");
        } else if (beacon.proximity == CLProximityFar) {
            //NSLog(@"CLProximityFar");
        } else {
            //NSLog(@"beacon.proximity else");
        }
    }
}

@end
