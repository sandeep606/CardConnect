/********* CardConnectMobileiOS.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
// #import <PassKit/PassKit.h>
#import <CardConnectConsumerSDK/CardConnectConsumerSDK.h>

@interface CardConnectMobileiOS : CDVPlugin {
    
  // Member variables go here.
    CDVInvokedUrlCommand *urlCommand;
}
@property (nonatomic, strong) CCCCardInfo *card;
@property (nonatomic,strong) UIView *view;
@property (nonatomic,strong)UINavigationController *navigationController;


- (void)initialisePayment:(CDVInvokedUrlCommand*)command;
- (void)cancelPayment:(CDVInvokedUrlCommand*)command;

@end

@implementation CardConnectMobileiOS

// Method to initialise payment with endpoint.
- (void)initialisePayment:(CDVInvokedUrlCommand*)command
{
    urlCommand = command;
    NSLog(@"Parameters are %@", command.arguments);
    [CCCAPI instance].endpoint = @"fts-uat.cardconnect.com";
    if ([command.arguments[0] valueForKey:@"end_point"] == nil){

        [CCCAPI instance].endpoint = @"fts.cardconnect.com";
    }
    [CCCAPI instance].enableLogging = YES;
//    self.view = self.webView.superview;
    UIStoryboard *sb = [UIStoryboard storyboardWithName: @"Main" bundle: [NSBundle mainBundle]];
    self.navigationController = [sb instantiateInitialViewController];

    self.navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenReceived:) name:@"TokenRecieved" object:nil];

    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Account added"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    ;
    [self.viewController presentViewController:self.navigationController animated:YES completion:^{
        
    }];
}

- (void)tokenReceived:(NSNotification *)notification{
    
    NSLog(@"token received is %@", notification.userInfo);
    NSDictionary *infoDict = notification.userInfo;
    NSString *token = [infoDict objectForKey:@"token"];
    CDVPluginResult* pluginResult;
    if (token == nil || [token  isEqual: @""]){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[infoDict objectForKey:@"error"]];
    }
    else{
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[infoDict objectForKey:@"token"]];
    }
     [self.commandDelegate sendPluginResult:pluginResult callbackId:urlCommand.callbackId];
}

- (void)cancelPayment:(CDVInvokedUrlCommand*)command{
    
    [self removeView:command];
}

- (void)removePaymentView:(CDVInvokedUrlCommand*)command{
    
    [self removeView:command];
}

- (void)removeView:(CDVInvokedUrlCommand*)command{

    NSLog(@"self.viewcontroller=== %@", self.viewController);
    NSLog(@"self.viewcontroller=== %@", self.viewController.childViewControllers);
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"View Removed"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
