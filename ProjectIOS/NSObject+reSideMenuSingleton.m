//
//  NSObject+reSideMenuSingleton.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 05/07/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import "NSObject+reSideMenuSingleton.h"


@interface reSideMenuSingleton()
@end


@implementation reSideMenuSingleton:NSObject



static reSideMenuSingleton *manager = nil;

+ (reSideMenuSingleton *)sharedManager
{
    if (manager == nil) {
        manager = [[self alloc] init];
    }
    
    return manager;
}

+ (reSideMenuSingleton *)restartSharedManager
{
    manager = [[self alloc] init];
    
    return manager;
}
- (id)init
{
    self = [super init];
    
    if (self) {
        self._mainStoryBoard = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:nil];
        self.vc = [self._mainStoryBoard instantiateViewControllerWithIdentifier:@"HomeNav"];
        
        self.mainViewController = [MainViewController new];
        self.mainViewController.rootViewController = self.vc;
        
        if ([[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] isEqualToString:@"Main"]){
             [self.mainViewController setupWithType:TypeSlideAbove];
        }else{
             [self.mainViewController setupWithType:TypeSlideAboveLeftOnly];
        }
       
        
    }
    return self;
}
-(void)enableMenus{
    [self.mainViewController setupWithType:TypeSlideAbove];
}

@end
