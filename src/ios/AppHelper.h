//
//  AppHelper.h
//  SampleApp
//
//  Created by Sandeep Rawat on 03/12/20.
//  Copyright © 2020 iMobile3 LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CardConnectConsumerSDK/CardConnectConsumerSDK.h>


//NS_ASSUME_NONNULL_BEGIN

@interface AppHelper : NSObject{
    
}

@property (nonatomic) CCCSwiperType swiperType;
@property (nonatomic) CCCDevice *device;

+(AppHelper *)sharedClass;

@end

//NS_ASSUME_NONNULL_END
