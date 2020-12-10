#import "RootViewController.h"

#import "AppDelegate.h"
#import "APIBridge.h"

#import <PassKit/PassKit.h>
#import <CardConnectConsumerSDK/CardConnectConsumerSDK.h>

@interface RootViewController () <UITextFieldDelegate, CCCPaymentControllerDelegate, PKPaymentAuthorizationViewControllerDelegate>

@property (nonatomic, strong) APIBridge *apiBridge;
@property (nonatomic, strong) CCCPaymentController *paymentController;
@property (nonatomic, strong) CCCTheme *theme;

@property (weak, nonatomic) IBOutlet UITextField *endpointTextField;
@property (weak, nonatomic) IBOutlet UIButton *customApplePayButton;
@property (nonatomic, strong) PKPaymentAuthorizationViewController *applePayViewController;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.apiBridge = [APIBridge new];
    self.theme = [CCCTheme new];
    self.theme.disclaimerText = @"Put some explanatory text here. Tell the user about whatever legal stuff you need to.";
    self.paymentController = [[CCCPaymentController alloc] initWithRootView:self apiBridge:self.apiBridge delegate:self theme:self.theme];

    self.customApplePayButton.hidden = YES;

}
    
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.endpointTextField.text = [CCCAPI instance].endpoint;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [CCCAPI instance].endpoint = self.endpointTextField.text;
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    
}


- (IBAction)cancelButtonPressed:(id)sender
{
    [self.view removeFromSuperview];
}
    
#pragma mark - UITextFieldDelegate -

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - CCCPaymentControllerDelegate -

- (void)paymentController:(CCCPaymentController *)controller finishedWithAccount:(CCCAccount *)account
{

}

- (void)didCancelPaymentController:(CCCPaymentController *)controller
{

}

#pragma mark - ApplePay -

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didAuthorizePayment:(PKPayment *)payment completion:(void (^)(PKPaymentAuthorizationStatus))completion
{
    [[CCCAPI instance] generateTokenForApplePay:payment completion:^(NSString * _Nullable token, NSError * _Nullable error) {
        if (token)
        {
            completion(PKPaymentAuthorizationStatusSuccess);
        }
        else
        {
            completion(PKPaymentAuthorizationStatusFailure);
        }
    }];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
