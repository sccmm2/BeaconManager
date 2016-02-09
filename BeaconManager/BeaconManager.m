//
//  BeaconManager.m
//  BeaconManager
//
//  Created by Sung on 2016. 2. 4..
//  Copyright © 2016년 Sung. All rights reserved.
//

#import "BeaconManager.h"

@implementation BeaconManager

- (id)init{
    self = [super init];
    if (self != nil) {
        [self beaconDetectInit];
        
        originDict = [[NSMutableDictionary alloc] init];
        compareDict = [[NSMutableDictionary alloc] init];
        
        //  타이머 설정. 안드로이드는 3초, 현재 5초로 설정
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]){
                NSLog(@"Multitasking Supported");
                
                self.background_task = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^ {
                    
                    [[UIApplication sharedApplication] endBackgroundTask: self.background_task];
                    self.background_task = UIBackgroundTaskInvalid;
                }];
                
                self.myTimer = [NSTimer timerWithTimeInterval:5.0
                                                       target:self
                                                     selector:@selector(beaconInsert)
                                                     userInfo:nil
                                                      repeats:YES];
                
                [[NSRunLoop mainRunLoop] addTimer:self.myTimer forMode:NSDefaultRunLoopMode];
            }
            else{
                NSLog(@"Multitasking Not Supported");
                self.myTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(beaconInsert) userInfo:nil repeats:YES];
            }
        });
        
        if(!self.bluetoothManager) {
            self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
        }
        [self centralManagerDidUpdateState:self.bluetoothManager];
    }
    return self;
}
//-(NSDictionary *)beaconInfoInsert:(NSString *)userId
//                            major:(NSString *)major
//                            minor:(NSString *)minor
//                    positionGubun:(NSString *)positionGubun {
//    
//    NSDictionary *params = @{@"userId":userId,
//                             @"dvcOs":@"I",
//                             @"major":major,
//                             @"minor":minor,
//                             @"positionGunbun":positionGubun};
//    
//    return params;//[self request:@"beacon_info_insert_pul.jsp" params:params];
//}
-(void)beaconInsert{
    NSLog(@"##############비콘 동작 함수");
    NSLog(@" originDict in %@", originDict);
    
    NSMutableDictionary * x = [[NSMutableDictionary alloc] init];
    for(NSString * key in originDict) {
        NSInteger v1 = [[originDict objectForKey:key] integerValue];
        NSInteger v0 = [[compareDict objectForKey:key] integerValue];
        if (v1 == v0 && v1 == 0) {
            // do nothing
        } else if (v1 - v0 == 0) {
            NSArray* Mm = [key componentsSeparatedByString:@" "];
            //NSDictionary *result = [self beaconInfoInsert:@"kdog_test" major:Mm[0] minor:Mm[1] positionGubun:@"0"];
            [self.delegage beaconManager:self RequestBeaconOutWithBeaconId:Mm];
            NSLog(@"비콘존에서 나옴 %@", key);
//            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground)
//            {
//                UILocalNotification *noti = [[UILocalNotification alloc]init];
//                noti.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
//                noti.timeZone = [NSTimeZone systemTimeZone];
//                //noti.alertBody = [NSString stringWithFormat:@"제거 리퀘스트 결과 : %@",result];
//                noti.alertBody = [NSString stringWithFormat:@"비콘존 OUT Maj(%@) Min(%@)", Mm[0], Mm[1]];
//                noti.alertAction = @"beacons";
//                noti.soundName = UILocalNotificationDefaultSoundName;
//                noti.userInfo = [NSDictionary dictionaryWithObject:@"beacons" forKey:@"beacons"];
//            } else {
//                NSLog(@"제거 리퀘스트 결과 : %@",result);
//            }
            //NSLog(@"제거 리퀘스트 결과 : %@",result);
        }
        
        if (v1 > 0)
            [x setObject:[NSNumber numberWithInteger:v1 - v0] forKey:key];
    }
    
    originDict = x;
    NSLog(@"originDict out %@", originDict);
    
    compareDict = [[NSMutableDictionary alloc] initWithDictionary:originDict];
}

-(void)beaconDetectInit{
    NSLog(@"BeaconDetectInit");
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"];
    
    self.locationManager = [[CLLocationManager alloc] init];
    
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization]; //or requestWhenInUseAuthorization
    }
    self.locationManager.delegate = self;
    
    [CLLocationManager isMonitoringAvailableForClass:[CLRegion class]];

    self.myBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"SmartPulmuone"];
    
    self.myBeaconRegion.notifyEntryStateOnDisplay = YES;
    self.myBeaconRegion.notifyOnEntry = YES;
    self.myBeaconRegion.notifyOnExit = YES;
    
    [self.locationManager startMonitoringForRegion:self.myBeaconRegion];
    [self.locationManager startRangingBeaconsInRegion:self.myBeaconRegion];
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
    UIAlertView *uav = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"gps_check", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"confirm", nil) otherButtonTitles:nil, nil];
    [uav setTag:3];
    [uav show];
}

- (void)locationManager:(CLLocationManager*)manager didEnterRegion:(CLRegion *)region{
    CLBeaconRegion *tempBeacon = (CLBeaconRegion *)region;
    NSLog(@"didEnterRegion %@", tempBeacon);
    if (tempBeacon == nil) return;
    [self.locationManager startRangingBeaconsInRegion:tempBeacon];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{
    CLBeaconRegion *tempBeacon = (CLBeaconRegion *)region;
    NSLog(@"didExitRegion %@",tempBeacon);
    if (tempBeacon == nil) return;
    [self.locationManager stopRangingBeaconsInRegion:tempBeacon];
}

-(void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    CLBeaconRegion *tempBeacon = (CLBeaconRegion *)region;
    if (tempBeacon == nil) return;
    NSLog(@"didDetermineState %@", tempBeacon);
    if (state == CLRegionStateInside) {
        NSLog(@"CLRegionStateInside");
    }else if(state == CLRegionStateOutside){
        NSLog(@"CLRegionStateOutside");
    }else{
        NSLog(@"CLRegionStateUnknown");
    }
}

-(void)locationManager:(CLLocationManager*)manager didRangeBeacons:(NSArray*)beacons inRegion:(CLBeaconRegion*)region{
    if([beacons count] == 0) return;
    for(CLBeacon *beacon in beacons){
        if(![[NSUserDefaults standardUserDefaults] boolForKey:@"beaconEnterNotify"]){
            NSString * key = [NSString stringWithFormat:@"%@ %@", beacon.major, beacon.minor];
            
            NSInteger number = [[originDict objectForKey:key] integerValue];
            number+=1;
            if (number == 1) {
                NSLog(@"비콘존에 들어옴 %@", key);
                NSArray* Mm = [key componentsSeparatedByString:@" "];
                //NSDictionary *result = [self beaconInfoInsert:@"kdog_test" major:Mm[0] minor:Mm[1] positionGubun:@"1"];
                [self.delegage beaconManager:self RequestBeaconInWithBeaconId:Mm];
                //NSLog(@"추가 리퀘스트 결과 : %@",result);
                
//                if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) {
//                    UILocalNotification *noti = [[UILocalNotification alloc]init];
//                    noti.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
//                    noti.timeZone = [NSTimeZone systemTimeZone];
//                    noti.alertBody = [NSString stringWithFormat:@"비콘존 IN Maj(%@) Min(%@)", Mm[0], Mm[1]];
//                    noti.alertAction = @"beacons";
//                    noti.soundName = UILocalNotificationDefaultSoundName;
//                    noti.userInfo = [NSDictionary dictionaryWithObject:@"beacons" forKey:@"beacons"];
//                    [[UIApplication sharedApplication] scheduleLocalNotification:noti];
//                } else {
//                    NSLog(@"추가 리퀘스트 결과 : %@",result);
//                }
            }
            
            [originDict setObject:[NSNumber numberWithInteger:number] forKey:key];
        }
    }
}



@end



















