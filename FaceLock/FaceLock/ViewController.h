//
//  ViewController.h
//  FaceLock
//
//  Created by Alan Xu on 3/13/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import <UIKit/UIKit.h>

struct AppStatus{
    NSString* const pleaseConnectSensorMessage = @"Please connect Structure Sensor.";
    NSString* const pleaseChargeSensorMessage = @"Please charge Structure Sensor";
    NSString* const needColorCameraAccessMessage = @"This app requires camera access to capture color.\nAllow access by going to Settings → Privacy → Camera.";
    enum SensorStatus
    {
        SensorStatusOk,
        SensorStatusNeedsUserToConnect,
        SensorStatusNeedsUserToCharge,
    };
    // Structure Sensor status.
    SensorStatus sensorStatus = SensorStatusOk;
    // Whether iOS camera access was granted by the user.
    bool colorCameraIsAuthorized = true;
    // Whether there is currently a message to show.
    bool needsDisplayOfStatusMessage = false;
    // Flag to disable entirely status message display.
    bool statusMessageDisabled = false;
};

@interface ViewController : UIViewController


@end

