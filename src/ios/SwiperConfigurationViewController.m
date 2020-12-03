//
//  SwiperConfigurationViewController.m
//  SampleApp
//
//  Created by Nick Rimer on 3/6/19.
//  Copyright © 2019 iMobile3 LLC. All rights reserved.
//

#import "SwiperConfigurationViewController.h"

//#import "AppDelegate.h"
#import "AppHelper.h"

@interface SwiperConfigurationViewController () <UITableViewDelegate, UITableViewDataSource, CCCSwiperControllerDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) CCCSwiperController *swiper;
@property (nonatomic) NSArray<CCCDevice*> *foundDevices;
@property (nonatomic) CCCDevice *tempDevice;

@property (nonatomic) UIAlertController *alert;

@end

@implementation SwiperConfigurationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    AppHelper *helper = [AppHelper sharedClass];
//    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    if (self.segmentedControl.selectedSegmentIndex == CCCSwiperTypeBBPOS)
    {
        helper.swiperType = CCCSwiperTypeBBPOS;
        helper.device = nil;
    }
    
    [_swiper releaseDevice];
    _swiper = nil;
    
    [super viewWillDisappear:animated];
}

- (IBAction)segmentedControllerValueChanged:(UISegmentedControl*)sender
{
    if (sender.selectedSegmentIndex == 1)
    {
        
        [_swiper releaseDevice];
        _swiper = nil;
        
        _swiper = [[CCCSwiperController alloc] initWithDelegate:self swiper:CCCSwiperTypeVP3300 loggingEnabled:YES];
        [_swiper findDevices];
    }
    else if (sender.selectedSegmentIndex == 2)
    {
        [_swiper releaseDevice];
        _swiper = nil;
        
        _swiper = [[CCCSwiperController alloc] initWithDelegate:self swiper:CCCSwiperTypeVP3600 loggingEnabled:YES];
        [_swiper findDevices];
    }
    else
    {
        [_swiper cancelFindDevices];
        self.foundDevices = nil;
    }
    
    [self.tableView reloadData];
}

#pragma mark TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.segmentedControl.selectedSegmentIndex == 0)
    {
        return 0;
    }
    else
    {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.foundDevices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = self.foundDevices[indexPath.row].name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_swiper cancelFindDevices];
    
    self.tempDevice = self.foundDevices[indexPath.row];
    [_swiper connectToDevice:self.tempDevice.uuid mode:CCCCardReadModeSwipe];
    
    self.alert = [UIAlertController alertControllerWithTitle:@"" message:@"Connecting" preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:self.alert animated:YES completion:nil];
}

#pragma mark Swiper Delegate

- (void)swiper:(CCCSwiper *)swiper connectionStateHasChanged:(CCCSwiperConnectionState)state
{
    switch (state) {
        case CCCSwiperConnectionStateConnected:
            NSLog(@"Did Connect Swiper");
            break;
        case CCCSwiperConnectionStateDisconnected:
            NSLog(@"Did Disconnect Swiper");
            break;
        case CCCSwiperConnectionStateConnecting:
            NSLog(@"Will Connect Swiper");
            break;
        case CCCSwiperConnectionStateConfiguring:
            NSLog(@"Configuring");
            break;
        case CCCSwiperConnectionStateSearching:
            NSLog(@"Searching");
            break;
        default:
            break;
    }
}

- (void)swiperDidStartCardRead:(CCCSwiper *)swiper
{
    __weak SwiperConfigurationViewController *weakSelf = self;
    // This is required to give the terminal enough time to finish starting before canceling
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.swiper cancelTransaction];
    });
}

- (void)swiper:(CCCSwiper *)swiper didGenerateTokenWithAccount:(CCCAccount *)account completion:(void (^)(void))completion
{
}

- (void)swiper:(CCCSwiper *)swiper didFailWithError:(NSError *)error completion:(void (^)(void))completion
{
    // If we connected to the device, we canceled the transaction and should save the device.
    if ([error.domain isEqualToString:CCCSwiperErrorDomain] &&
        error.code == CCCSwiperErrorCanceledTransaction)
    {
        
        AppHelper *helper = [AppHelper sharedClass];
                
        helper.swiperType = self.segmentedControl.selectedSegmentIndex == 1?CCCSwiperTypeVP3300:CCCSwiperTypeVP3600;
        helper.device = self.tempDevice;
        
        if (self.alert)
        {
            [self.alert dismissViewControllerAnimated:YES completion:^{
                self.alert = nil;
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        return;
    }

    NSMutableString *errorMessage = [[NSMutableString alloc] initWithFormat:@"An error occured:\n%@",error.localizedDescription];
    
    if ([error.userInfo valueForKey:@"firmwareVersion"])
    {
        [errorMessage appendFormat:@"\n\n%@", [error.userInfo valueForKey:@"firmwareVersion"]];
    }
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@""
                                                                        message:errorMessage
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [controller addAction:[UIAlertAction actionWithTitle:@"RETRY" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        completion();
    }]];
    
    if (self.alert)
    {
        [self.alert dismissViewControllerAnimated:YES completion:^{
            self.alert = nil;
            [self presentViewController:controller animated:YES completion:nil];
        }];
    }
    else
    {
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)swiper:(CCCSwiperController*)swiper foundDevices:(NSArray*)devices
{
    self.foundDevices = devices;
    [self.tableView reloadData];
}

- (void)swiper:(CCCSwiperController*)swiper displayMessage:(NSString*)message canCancel:(BOOL)cancelable
{
}

- (void)swiper:(CCCSwiperController *)swiper configurationProgress:(float)progress
{
    self.alert.message = [NSString stringWithFormat:@"Configuring: %.0f%%",progress*100];
}

@end
