//
//  FirstViewController.m
//  SampleApp
//
//  Created by Sandeep Rawat on 03/12/20.
//  Copyright © 2020 iMobile3 LLC. All rights reserved.
//

#import "FirstViewController.h"
#import "RootViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(IBAction)btnClicked:(id)sender{
    
    RootViewController *rootController = (RootViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"rootVC"];
    [self.view addSubview:rootController.view];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
