#import "CardEntryViewController.h"

#import <PassKit/PassKit.h>

#import "AppHelper.h"

@interface CardEntryViewController () <CCCFormatterDelegateExtension,CCCSwiperControllerDelegate, PKPaymentAuthorizationViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *cardNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *expirationDateTextField;
@property (weak, nonatomic) IBOutlet UITextField *CVVTextField;
@property (weak, nonatomic) IBOutlet UITextField *postalCodeTextField;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *swiperStatus;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *generateTokenBarButton;

@property (weak, nonatomic) IBOutlet UISegmentedControl *maskFormatSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *maskCharacterSegmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *restartReaderButton;

@property (strong, nonatomic) IBOutlet CCCCardFormatterDelegate *cardFormatterDelegate;
@property (strong, nonatomic) IBOutlet CCCExpirationDateFormatterDelegate *expirationFormatterDelegate;
@property (strong, nonatomic) IBOutlet CCCCVVFormatterDelegate *cvvFormatterDelegate;

@property (weak, nonatomic) IBOutlet UISwitch *swipeOnlySwitch;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;

@property (nonatomic, strong) CCCSwiperController *swiper;
@property (nonatomic, strong) UIAlertController *alert;
@property (nonatomic, strong) UIAlertController *communicationAlert;


@property (nonatomic, strong) CCCCardInfo *card;
@property (nonatomic, copy) void(^restartReaderBlock)(void);

@end

@implementation CardEntryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.card = [CCCCardInfo new];

    self.cardNumberTextField.rightViewMode = UITextFieldViewModeAlways;
    self.expirationDateTextField.rightViewMode = UITextFieldViewModeAlways;
    self.CVVTextField.rightViewMode = UITextFieldViewModeAlways;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    if (_swiper)
    {
        [_swiper releaseDevice];
        _swiper = nil;
    }

    [super viewWillDisappear:animated];
}

#pragma mark Internal Methods

- (void)i_startActivityIndicator
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator startAnimating];
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    });
}

- (void)i_stopActivityIndicator
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator stopAnimating];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    });
}

- (void)i_updateCreateButton
{
    self.generateTokenBarButton.enabled =   self.cardFormatterDelegate.isValidCard &&
                                            self.expirationFormatterDelegate.isValidExpirationDate &&
                                            self.cvvFormatterDelegate.isValidCVV;
}

- (void)i_showCommunicationAlertWithMessage:(NSString*)message cancelable:(BOOL)canCancel
{
    if (self.communicationAlert == nil)
    {
        self.communicationAlert = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    }
    
    self.communicationAlert.message = message;
    
    if (canCancel &&
        self.communicationAlert.actions.count == 0)
    {
        [self.communicationAlert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            self.communicationAlert = nil;
            [self.swiper cancelFindDevices];
        }]];
    }
    else if (!canCancel &&
             self.communicationAlert.actions.count > 0)
    {
        for (UIAlertAction *action in self.communicationAlert.actions)
        {
            action.enabled = NO;
        }
    }
    
    if (!self.presentedViewController)
    {
        [self presentViewController:self.communicationAlert animated:YES completion:nil];
    }
}

#pragma mark Action Methods

- (IBAction)createPressed:(id)sender
{
    [self.view endEditing:YES];

    [self i_startActivityIndicator];

    [[CCCAPI instance] generateAccountForCard:self.card completion:^(CCCAccount * _Nullable account, NSError * _Nullable error) {
        [self i_stopActivityIndicator];

        [self.cardFormatterDelegate clearTextField];
        [self.expirationFormatterDelegate clearTextField];
        [self.cvvFormatterDelegate clearTextField];
        self.postalCodeTextField.text = @"";
        self.card = [CCCCardInfo new];
        [self i_updateCreateButton];

        if (account)
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Token Generated" message:account.token preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
            [self postNotificationWithToken:account.token andError:@""];
        }
        else
        {
            [self postNotificationWithToken:@"" andError:error.localizedDescription];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
        ;
    }];
}

-(void)postNotificationWithToken:(NSString *)token andError:(NSString *)error{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:token forKey:@"token"];
    [dict setObject:error forKey:@"error"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TokenRecieved" object:nil userInfo:dict];
}

- (IBAction)segmentedControlValueChanged:(UISegmentedControl*)sender
{
    if (sender == self.maskFormatSegmentedControl)
    {
        switch (sender.selectedSegmentIndex) {
            case 0:
                self.cardFormatterDelegate.maskFormat = CCCCardMaskFormatMaskWithLastFour;
                break;
            case 1:
                self.cardFormatterDelegate.maskFormat = CCCCardMaskFormatLastFour;
                break;
            case 2:
                self.cardFormatterDelegate.maskFormat = CCCCardMaskFormatFirstAndLastFour;
                break;
            default:
                break;
        }
    }
    else
    {
        switch (sender.selectedSegmentIndex) {
            case 0:
                self.cardFormatterDelegate.maskCharacter = '*';
                self.cvvFormatterDelegate.maskCharacter = '*';
                break;
            case 1:
                self.cardFormatterDelegate.maskCharacter = '&';
                self.cvvFormatterDelegate.maskCharacter = '&';
                break;
            case 2:
                self.cardFormatterDelegate.maskCharacter = '-';
                self.cvvFormatterDelegate.maskCharacter = '-';
                break;
            default:
                break;
        }
    }
}

- (IBAction)restartReaderPressed:(id)sender
{
    self.restartReaderButton.enabled = NO;
    
    if (self.restartReaderBlock &&
        self.swiper.connectionState == CCCSwiperConnectionStateConnected)
    {
        self.restartReaderBlock();
    }
}

- (IBAction)connectPressed:(UIButton*)sender
{
    
    AppHelper *helper = [AppHelper sharedClass];
    
    _swiper = [[CCCSwiperController alloc] initWithDelegate:self swiper:helper.swiperType loggingEnabled:YES];
    
    if (helper.swiperType != CCCSwiperTypeBBPOS &&
        helper.device)
    {
        [_swiper connectToDevice:helper.device.uuid mode:self.swipeOnlySwitch.isOn?CCCCardReadModeSwipe:CCCCardReadModeSwipeDip];
    }
}

#pragma mark CCCFormatterDelegateExtension

- (void)didChangeCharactersInRangeForFormatter:(CCCTextFieldDelegateProxy *)formatter
{
    if (formatter == self.cardFormatterDelegate)
    {
        if (self.cardNumberTextField.text.length > 0 &&
            !self.cardFormatterDelegate.isValidCard)
        {
            UILabel *xLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
            xLabel.text = @"X";
            xLabel.textColor = [UIColor redColor];
            xLabel.font = [UIFont boldSystemFontOfSize:20];
            xLabel.textAlignment = NSTextAlignmentCenter;

            self.cardNumberTextField.rightView = xLabel;
        }
        else
        {
            self.cardNumberTextField.rightView = nil;
            [self.cardFormatterDelegate setCardNumberOnCardInfo:self.card];
        }
    }
    else if (formatter == self.expirationFormatterDelegate)
    {
        if (self.expirationDateTextField.text.length > 0 &&
            !self.expirationFormatterDelegate.isValidExpirationDate)
        {
            UILabel *xLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
            xLabel.text = @"X";
            xLabel.textColor = [UIColor redColor];
            xLabel.font = [UIFont boldSystemFontOfSize:20];
            xLabel.textAlignment = NSTextAlignmentCenter;

            self.expirationDateTextField.rightView = xLabel;
        }
        else
        {
            self.expirationDateTextField.rightView = nil;
            [self.expirationFormatterDelegate setExpirationDateOnCardInfo:self.card];
        }
    }
    else if (formatter == self.cvvFormatterDelegate)
    {
        if (self.CVVTextField.text.length > 0 &&
            ![self.cvvFormatterDelegate isValidCVVWithCardFormatter:self.cardFormatterDelegate])
        {
            UILabel *xLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
            xLabel.text = @"X";
            xLabel.textColor = [UIColor redColor];
            xLabel.font = [UIFont boldSystemFontOfSize:20];
            xLabel.textAlignment = NSTextAlignmentCenter;

            self.CVVTextField.rightView = xLabel;
        }
        else
        {
            self.CVVTextField.rightView = nil;
            [self.cvvFormatterDelegate setCVVOnCardInfo:self.card];
        }
    }

    [self i_updateCreateButton];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (textField == self.cardNumberTextField)
    {
        self.card.cardNumber = nil;
    }
    else if (textField == self.expirationDateTextField)
    {
        self.card.expirationDate = nil;
    }
    else if (textField == self.CVVTextField)
    {
        self.card.CVV = nil;
    }

    [self i_updateCreateButton];

    return YES;
}

#pragma mark Swiper Delegate

- (void)swiper:(CCCSwiper *)swiper connectionStateHasChanged:(CCCSwiperConnectionState)state
{
    switch (state) {
        case CCCSwiperConnectionStateConnected:
            NSLog(@"Did Connect Swiper");
            self.swiperStatus.text = @"Connected";
            self.connectButton.enabled = NO;
            if (self.communicationAlert)
            {
                if (self.presentedViewController == self.communicationAlert)
                {
                    [self.communicationAlert dismissViewControllerAnimated:YES completion:^{
                        self.communicationAlert = nil;
                    }];
                }
                else
                {
                    self.communicationAlert = nil;
                }
            }
            break;
        case CCCSwiperConnectionStateDisconnected:
            NSLog(@"Did Disconnect Swiper");
            self.swiperStatus.text = @"Disconnected";
            self.connectButton.enabled = YES;
            if (self.communicationAlert)
            {
                if (self.presentedViewController == self.communicationAlert)
                {
                    [self.communicationAlert dismissViewControllerAnimated:YES completion:^{
                        self.communicationAlert = nil;
                    }];
                }
                else
                {
                    self.communicationAlert = nil;
                }
            }
            break;
        case CCCSwiperConnectionStateConfiguring:
            NSLog(@"Configuring Device");
            self.swiperStatus.text = @"Configuring";
            self.connectButton.enabled = NO;
            [self i_showCommunicationAlertWithMessage:@"Configuring" cancelable:NO];
            break;
        case CCCSwiperConnectionStateConnecting:
            NSLog(@"Will Connect Swiper");
            self.swiperStatus.text = @"Connecting";
            self.connectButton.enabled = NO;
            [self i_showCommunicationAlertWithMessage:@"Connecting" cancelable:NO];
                break;
        case CCCSwiperConnectionStateSearching:
            NSLog(@"Will search for Swiper");
            self.swiperStatus.text = @"Searching";
            self.connectButton.enabled = NO;
            [self i_showCommunicationAlertWithMessage:@"Searching" cancelable:YES];
            break;
        default:
            break;
    }
}

- (void)swiperDidStartCardRead:(CCCSwiper *)swiper
{
    NSLog(@"Card Read Started");
    [self.view endEditing:YES];
    
    if (self.alert == nil)
    {
        self.alert = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [self.alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            self.alert = nil;
            [self.swiper cancelTransaction];
        }]];
    }
    
    AppHelper *helper = [AppHelper sharedClass];
    
    if (self.swipeOnlySwitch.isOn ||
    helper.swiperType == CCCSwiperTypeBBPOS){
        self.alert.message = @"Swipe Card";
    }
    
    if (!self.presentedViewController)
    {
        [self presentViewController:self.alert animated:YES completion:nil];
    }
    else
    {
        // Delay until alert is dismissed
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!self.presentedViewController)
            {
                [self presentViewController:self.alert animated:YES completion:nil];
            }
        });
    }
}

- (void)swiper:(CCCSwiper *)swiper didGenerateTokenWithAccount:(CCCAccount *)account completion:(void (^)(void))completion
{
    [self i_stopActivityIndicator];
    
    if (self.alert)
    {
        [self.alert dismissViewControllerAnimated:YES completion:^{
            self.alert = nil;
        }];
    }
    else if (self.communicationAlert)
    {
        [self.communicationAlert dismissViewControllerAnimated:YES completion:^{
            self.communicationAlert = nil;
        }];
    }
    
    if (account)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Token Generated" message:account.token preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            completion();
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            self.restartReaderBlock = completion;
            self.restartReaderButton.enabled = YES;
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        [self postNotificationWithToken:account.token andError:@""];
    }
    else
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"An unknown error" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            completion();
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            self.restartReaderBlock = completion;
            self.restartReaderButton.enabled = YES;
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        [self postNotificationWithToken:@"" andError:@"An unknown error occurred"];
    }
    
}

- (void)swiper:(CCCSwiper *)swiper didFailWithError:(NSError *)error completion:(void (^)(void))completion
{
    [self i_stopActivityIndicator];
    
    if (self.alert)
    {
        [self.alert dismissViewControllerAnimated:YES completion:^{
            self.alert = nil;
        }];
    }
    else if (self.communicationAlert)
    {
         [self.communicationAlert dismissViewControllerAnimated:YES completion:^{
             self.communicationAlert = nil;
         }];
    }

    NSMutableString *errorMessage = [[NSMutableString alloc] initWithFormat:@"An error occured:\n%@",error.localizedDescription];
    
    if ([error.userInfo valueForKey:@"firmwareVersion"])
    {
        [errorMessage appendFormat:@"\n\n%@", [error.userInfo valueForKey:@"firmwareVersion"]];
    }
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@""
                                                                        message:errorMessage
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        completion();
    }]];
    [controller addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        self.restartReaderBlock = completion;
        self.restartReaderButton.enabled = YES;
    }]];
    [self presentViewController:controller animated:YES completion:nil];
    [self postNotificationWithToken:@"" andError:errorMessage];
}

- (void)swiper:(CCCSwiperController*)swiper foundDevices:(NSArray*)devices
{
    
}

- (void)swiper:(CCCSwiperController*)swiper displayMessage:(NSString*)message canCancel:(BOOL)cancelable
{
    if (self.alert == nil)
    {
        self.alert = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    }
    
    self.alert.message = message;
    
    if (cancelable &&
        self.alert.actions.count == 0)
    {
        [self.alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            self.alert = nil;
            [self.swiper cancelTransaction];
        }]];
    }
    else if (!cancelable &&
             self.alert.actions.count > 0)
    {
        for (UIAlertAction *action in self.alert.actions)
        {
            action.enabled = NO;
        }
    }
    
    if (!self.presentedViewController)
    {
        [self presentViewController:self.alert animated:YES completion:nil];
    }
}

- (void)swiper:(CCCSwiperController *)swiper configurationProgress:(float)progress
{
    [self i_showCommunicationAlertWithMessage:[NSString stringWithFormat:@"Configuring: %.0f%%",progress*100]
                                   cancelable:NO];
}

#pragma mark PKPaymentAuthorizationViewControllerDelegate

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion
{

}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
