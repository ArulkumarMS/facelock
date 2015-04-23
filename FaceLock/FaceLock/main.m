//
//  main.m
//  FaceLock
//
//  Created by Alan Xu on 3/13/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@import AVFoundation;

int main(int argc, char * argv[]) {
    AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc]init];
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:@"Welcome to FaceLock!"];
    [utterance setRate:0.1f];
    [synthesizer speakUtterance:utterance];
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
