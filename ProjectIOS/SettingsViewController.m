//
//  SettingsViewController.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 14/07/2018.
//  Copyright © 2018 Manuel B Parungao Jr. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([[defaults objectForKey:MAP_ROUTING_TYPE] isEqualToString:@"walking"]) {
        self.generateRouteType.selectedSegmentIndex =1;
    }else{
        self.generateRouteType.selectedSegmentIndex =0;
    }
    
    if ([[defaults objectForKey:MAP_ROUTING_DIST] isEqualToString:@"500"]) {
        self.routeDIstanceInterval.selectedSegmentIndex =0;
    }else if ([[defaults objectForKey:MAP_ROUTING_DIST] isEqualToString:@"100"]) {
        self.routeDIstanceInterval.selectedSegmentIndex =1;
    }else{
        self.routeDIstanceInterval.selectedSegmentIndex =2;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)typeSegmentValueChanged:(id)sender {
    
    switch (self.generateRouteType.selectedSegmentIndex) {
        case 0:
            [[NSUserDefaults standardUserDefaults] setObject:@"driving"  forKey:MAP_ROUTING_TYPE];
            break;
        case 1:
            [[NSUserDefaults standardUserDefaults] setObject:@"walking"  forKey:MAP_ROUTING_TYPE];
            break;
        default:
            break;
    }
    
}

- (IBAction)distanceSegmentValueChanged:(id)sender {
    
    switch (self.routeDIstanceInterval.selectedSegmentIndex) {
        case 0:
            [[NSUserDefaults standardUserDefaults] setObject:@"500"  forKey:MAP_ROUTING_DIST];
            break;
        case 1:
            [[NSUserDefaults standardUserDefaults] setObject:@"100"  forKey:MAP_ROUTING_DIST];
            break;
        default:
            [[NSUserDefaults standardUserDefaults] setObject:@"50"  forKey:MAP_ROUTING_DIST];
            break;
    }
    
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
