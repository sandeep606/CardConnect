/********* CardConnectMobileiOS.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
// #import <PassKit/PassKit.h>
#import <CardConnectConsumerSDK/CardConnectConsumerSDK.h>


static int cardConnectViewTag = 999;

@interface CardConnectMobileiOS : CDVPlugin {
    
  // Member variables go here.
    CDVInvokedUrlCommand *urlCommand;
}
@property (nonatomic, strong) CCCCardInfo *card;
@property (nonatomic,strong) UIView *view;


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
    self.view = self.webView.superview;
    UIStoryboard *sb = [UIStoryboard storyboardWithName: @"Main" bundle: [NSBundle mainBundle]];
    UIViewController *vc = [sb instantiateInitialViewController];
    vc.view.tag = cardConnectViewTag;
    [self.view addSubview:vc.view];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenReceived:) name:@"TokenRecieved" object:nil];

    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Account added"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
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
    [[self.view viewWithTag:cardConnectViewTag] removeFromSuperview];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"View Removed"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
