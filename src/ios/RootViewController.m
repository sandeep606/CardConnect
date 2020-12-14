#import "RootViewController.h"

#import "AppDelegate.h"
#import "APIBridge.h"

#import <PassKit/PassKit.h>
#import <CardConnectConsumerSDK/CardConnectConsumerSDK.h>

@interface RootViewController () <UITextFieldDelegate, CCCPaymentControllerDelegate>

@property (nonatomic, strong) APIBridge *apiBridge;
@property (nonatomic, strong) CCCPaymentController *paymentController;
@property (nonatomic, strong) CCCTheme *theme;

@property (weak, nonatomic) IBOutlet UITextField *endpointTextField;
@property (weak, nonatomic) IBOutlet UIButton *customApplePayButton;

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
    [self addBarButtonItem];
}

-(void)addBarButtonItem{
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed:)];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    
}
    
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
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
//    [self.view removeFromSuperview];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
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

@end