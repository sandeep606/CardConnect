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
    
    //MULTI-LINE COMMENTS
    /*
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if (!(delegate.merchantID.length > 0 &&
        [PKPaymentAuthorizationViewController canMakePayments]))
    {
        self.customApplePayButton.hidden = YES;
    }
    else
    {
        CCCPaymentRequest *request = [CCCPaymentRequest new];
        request.applePayMerchantID = delegate.merchantID;
        request.total = [NSDecimalNumber decimalNumberWithString:@"1.00"];
        request.companyName = @"CardConnect";
        
//         Optional: You can provide your own summary items for the payment request
//        PKPaymentSummaryItem *subtotal = [PKPaymentSummaryItem summaryItemWithLabel:@"Subtotal"
//                                                                             amount:[NSDecimalNumber decimalNumberWithString:@"1.00"]];
//        PKPaymentSummaryItem *tax = [PKPaymentSummaryItem summaryItemWithLabel:@"Tax"
//                                                                        amount:[NSDecimalNumber decimalNumberWithString:@"1.00"]];
//        PKPaymentSummaryItem *total = [PKPaymentSummaryItem summaryItemWithLabel:@"CardConnect"
//                                                                          amount:[NSDecimalNumber decimalNumberWithString:@"2.00"]];
//
//        request.paymentSummaryItems = @[subtotal,tax,total];

        self.paymentController.paymentRequest = request;
    }
    
    */
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

- (IBAction)customApplePayPressed:(id)sender
{
//    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//
//    PKPaymentRequest *request = [PKPaymentRequest new];
//    request.currencyCode = @"USD";
//    request.countryCode = @"US";
//    request.merchantIdentifier = delegate.merchantID;
//
//    NSDecimalNumber *total = [NSDecimalNumber decimalNumberWithString:@"1.00"];
//    request.paymentSummaryItems = @[[PKPaymentSummaryItem summaryItemWithLabel:NSLocalizedString(@"Your Company name", @"ApplePay total label")
//                                                                        amount:total]];
//    request.supportedNetworks = @[PKPaymentNetworkMasterCard, PKPaymentNetworkVisa, PKPaymentNetworkAmex];
//    request.merchantCapabilities = PKMerchantCapability3DS;
//
//    self.applePayViewController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
//    self.applePayViewController.delegate = self;
//    [self presentViewController:self.applePayViewController animated:YES completion:nil];
}

- (IBAction)integratedFlowPressed:(id)sender
{
    [self.paymentController presentPaymentView];
}

- (IBAction)stackIntegratedFlowPressed:(id)sender
{
    [self.paymentController pushPaymentView];
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
