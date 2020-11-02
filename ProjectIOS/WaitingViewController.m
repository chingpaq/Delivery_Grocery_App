//
//  WaitingViewController.m
//  
//
//  Created by Manuel B Parungao Jr on 18/10/2017.
//

#import "WaitingViewController.h"

@interface WaitingViewController ()

@end

@implementation WaitingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden =YES;
    self.proposalsArray = [[NSMutableArray alloc]init];
    self.timerLabel.text =@"60";
    self.continueButton.hidden=YES;
    self.cancelButton.hidden=YES;
    [self startTimer];

}
-(void)viewDidAppear:(BOOL)animated{
    self.continueButton.hidden=YES;
    self.cancelButton.hidden=YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//[self performSegueWithIdentifier:@"showReceivedProposalsSegue" sender:nil];
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showReceivedProposalsSegue"]) {
        self.proposalsViewController = [segue destinationViewController];
        self.proposalsViewController.proposalsArray =self.proposalsArray;
        [self.proposalsViewController.tableView reloadData];
    }
    else if ([segue.identifier isEqualToString:@"proceedOrderFromHomeSegue"]){
        //self.ordersMapViewController = [segue destinationViewController];
        //self.productViewController.productDict =sender;
        //self.productViewController.delegate=self;
    }
    
}
-(void)startTimer{
    //int interval = [sender intValue];
    
    [self.waitTimer invalidate];
    
    self.waitTimer = [[NSTimer alloc] initWithFireDate:[[NSDate date] dateByAddingTimeInterval:0] interval:1
                                                         target:self
                                                       selector:@selector(countDownTimer:)
                                                       userInfo:nil
                                                        repeats:YES];
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:self.waitTimer forMode:NSDefaultRunLoopMode];
}
-(void)countDownTimer:(id)sender{
    if ([[DataSingletons sharedManager]receivedOffer]==YES){
        [[DataSingletons sharedManager]setReceivedOffer:NO];
        self.navigationController.navigationBarHidden=NO;
        [self.delegate proposalsReceived];
        [self.navigationController popViewControllerAnimated:NO];
    }
    int i = [self.timerLabel.text intValue];
    i = i-1;
    if (i==0){
        [self.waitTimer invalidate];
        self.continueButton.hidden=NO;
        self.cancelButton.hidden=NO;
        
    }
    self.timerLabel.text = [NSString stringWithFormat:@"%i",i];
}
- (IBAction)continueWaitingForOrders:(id)sender {
    self.navigationController.navigationBarHidden=NO;
    [self.delegate proposalsReceived];
    [self.navigationController popViewControllerAnimated:NO];
}
- (IBAction)cancelThisOrder:(id)sender {
    
    //self.productDict
    
    [API updateSalesOrder:[self.productDict objectForKey:@"orderId"] withStatus:@"Expired" withSellerId:@"-" withItems:[self.productDict objectForKey:@"orderItems"]withDict:self.productDict
                  success:^(NSDictionary *dict){
                      [API deleteProposals:[self.productDict objectForKey:@"orderId"]
                                   success:^(NSDictionary *dict){
                                       
                                       
                                   } failure:^(NSString *message) {
                                       NSLog(@"Fail");
                                   }];
                      self.navigationController.navigationBarHidden=NO;
                      [self.delegate proposalsReceived];
                      [self.navigationController popViewControllerAnimated:NO];
                  } failure:^(NSString *message) {
                      NSLog(@"Fail");
                  }];
    

}

@end
