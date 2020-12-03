//
//  AppHelper.m
//  SampleApp
//
//  Created by Sandeep Rawat on 03/12/20.
//  Copyright © 2020 iMobile3 LLC. All rights reserved.
//

#import "AppHelper.h"

@implementation AppHelper

static AppHelper *_sharedClass = nil;

+(AppHelper *)sharedClass {
    @synchronized([AppHelper class]) {
        if (!_sharedClass)
          _sharedClass = [[self alloc] init];
        return _sharedClass;
    }
    return nil;
}

@end
