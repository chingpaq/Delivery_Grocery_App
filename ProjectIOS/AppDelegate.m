//
//  AppDelegate.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 03/07/2017
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate
#define GOOGLE_API_KEY    @"AIzaSyBfzd3igMBpI0FUiUsow0jmhoTWpt2LQLA"

//#define GOOGLE_API_KEY    @"AIzaSyDff1g4RwfDN0saC4gXvS9B4R6Ql78LyRw"
NSString *const kGCMMessageIDKey = @"gcm.message_id";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Override point for customization after application launch.
    
    [Fabric with:@[[Crashlytics class]]];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    //[CrashlyticsKit crash];

    // [START set_messaging_delegate]
    
    /*
    curl --header "Content-Type: application/json" --header "Authorization: key=AAAAluFW6WU:APA91bH97hy3eVpE6qAAsJ_uWJGcW75bayywP9nWYSvFWFYxNLE87Ty9X2X6OnDN_vVBgAqdjS38S5vtNpgRtgTeUumz94Y8f09Xrr8nNFYQAio4hw9H90zt3ghu291GKyWSai_hWDgk" https://fcm.googleapis.com/fcm/send -d '{"notification": {"body": "Hello from curl via FCM!", "sound": "default"},"priority": "high", "to": "dkFRQaZKVvU:APA91bEoeJRHHRlQ9AjkDO7KpLMH1qIc4nLvrmIVsR9SC_-0h8Xm5Qz5VIVoEmESEWYeE8qeUCGJUEBnlM44DbEGILY-O-IthWw75lLvfrXT1tt32zOaCxvLT-hjgjngOMYa4sWu_KLH"}'
     
     */
    //[FIRMessaging messaging].delegate = self;
//    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
//    UNAuthorizationOptions authOptions =
//    UNAuthorizationOptionAlert
//    | UNAuthorizationOptionSound
//    | UNAuthorizationOptionBadge;
//    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
//    }];
//        if ([UNUserNotificationCenter class] != nil) {
//            // iOS 10 or later
//            // For iOS 10 display notification (sent via APNS)
//            [UNUserNotificationCenter currentNotificationCenter].delegate = self;
//            UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert |
//            UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
//            [[UNUserNotificationCenter currentNotificationCenter]
//             requestAuthorizationWithOptions:authOptions
//             completionHandler:^(BOOL granted, NSError * _Nullable error) {
//                 // ...
//                 
//                 
//             }];
//        }
//        else {
//            // iOS 10 notifications aren't available; fall back to iOS 8-9 notifications.
//            UIUserNotificationType allNotificationTypes =
//            (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
//            UIUserNotificationSettings *settings =
//            [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
//            [application registerUserNotificationSettings:settings];
//        }
    
//    [application registerForRemoteNotifications];
    
    // Configure tabBarController and navBar appearance
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithHexString:@"#F78320"]];
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];//
    
    
    NSDictionary *selectedAttributes = @{
                                         NSFontAttributeName            : [UIFont fontWithName:@"SEOptimistLight" size:15.0f],
                                         NSForegroundColorAttributeName : [UIColor whiteColor]
                                         };
    NSDictionary *normalAttributes = @{
                                       NSFontAttributeName            : [UIFont fontWithName:@"SEOptimistLight" size:15.0f],
                                       NSForegroundColorAttributeName : [UIColor whiteColor],
                                       };
    
    [[UITabBarItem appearance] setTitleTextAttributes:normalAttributes forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:selectedAttributes forState:UIControlStateSelected];

 
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithHexString:@"00a54F"]];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithHexString:@"#7ECCED"]];
    [[UINavigationBar appearance] setTitleTextAttributes:normalAttributes];
    
    [FIRApp configure];
    [GIDSignIn sharedInstance].clientID = [FIRApp defaultApp].options.clientID;
    [GIDSignIn sharedInstance].delegate = self;
    // Register Google Maps SDK API Key
    [GMSServices provideAPIKey:GOOGLE_API_KEY];
    
    //[FIRMessaging messaging].delegate = self;
    
    
    // Register PayMaya SDK API Key
    
    [[PayMayaSDK sharedInstance] setPaymentsAPIKey:@"pk-6y2WX6WhWxfQOg8ezKIUuiJxa7gC4sDvOipn9NFXlwz" forEnvironment:PayMayaEnvironmentSandbox];
    [[PayMayaSDK sharedInstance] setCheckoutAPIKey:@"pk-nRO7clSfJrojuRmShqRbihKPLdGeCnb9wiIWF8meJE9"
                                    forEnvironment:PayMayaEnvironmentSandbox];
    
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    [FBSDKAppEvents activateApp];
    NSString *key = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"consumerKey"],
    *secret = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"consumerSecret"];
    
    
    if ([key length] && [secret length]) {
        [[Twitter sharedInstance] startWithConsumerKey:key consumerSecret:secret];
    }
    [self configureSVProgressHUD];
    
//    [reSideMenuSingleton sharedManager];
//    [FIRDatabaseSingleton sharedManager];
//    [Orders sharedManager];
//    [DataSingletons sharedManager];
//    [API sharedManager];
    
    
    [self.window setRootViewController:[[reSideMenuSingleton sharedManager]mainViewController]];
    [self showSplash];
    
    
    
    //[self.window setRootViewController:[[reSideMenuSingleton sharedManager]sideMenuViewController]];
 
//    AdViewController *ad = [[AdViewController alloc]initWithNibName:@"AdViewController" bundle:nil];
//    self.window.rootViewController=ad;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)showSplash {
    UIStoryboard*splashStoryBoard = [UIStoryboard storyboardWithName:@"LaunchScreen" bundle:nil];
    UIViewController *vc = [splashStoryBoard instantiateViewControllerWithIdentifier:@"LaunchScreen"];
    [self.window setRootViewController:vc];
    [self performSelector:@selector(hideSplash) withObject:nil afterDelay:2];
}

-(void)hideSplash
{
    [self.window setRootViewController:[[reSideMenuSingleton sharedManager]mainViewController]];
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(nonnull UIApplication *)application
            openURL:(nonnull NSURL *)url
            options:(nonnull NSDictionary<NSString *, id> *)options {
    

    [SVProgressHUD show];
    return [self application:application
                     openURL:url
           sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                  annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    if ([[GIDSignIn sharedInstance] handleURL:url
                            sourceApplication:sourceApplication
                                   annotation:annotation]) {
        return YES;
    }
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}
- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    if (error == nil) {
        // [START google_credential]
        GIDAuthentication *authentication = user.authentication;
        FIRAuthCredential *credential =
        [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken
                                         accessToken:authentication.accessToken];
    } else {
//        [controller showMessagePrompt:error.localizedDescription];
    }
}
// [END headless_google_auth]
- (void)configureSVProgressHUD {
    [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
    [SVProgressHUD setForegroundColor:[UIColor blackColor]];
}

// [START receive_message]
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    
    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    
    // Print message ID.
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    // Print full message.
    NSLog(@"%@", userInfo);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    
    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    
    // Print message ID.
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    // Print full message.
    NSLog(@"%@", userInfo);
    
    completionHandler(UIBackgroundFetchResultNewData);
}
// [END receive_message]

// [START ios_10_message_handling]
// Receive displayed notifications for iOS 10 devices.
// Handle incoming notification messages while app is in the foreground.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSDictionary *userInfo = notification.request.content.userInfo;
    
    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    
    // Print message ID.
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    // Print full message.
    NSLog(@"%@", userInfo);
    
    // Change this to your preferred presentation option
    completionHandler(UNNotificationPresentationOptionNone);
}

// Handle notification messages after display notification is tapped by the user.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)(void))completionHandler {
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    // Print full message.
    NSLog(@"%@", userInfo);
    
    completionHandler();
}

// [END ios_10_message_handling]

// [START refresh_token]
- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    NSLog(@"FCM registration token: %@", fcmToken);
    
    // TODO: If necessary send token to application server.
    // Note: This callback is fired at each app startup and whenever a new token is generated.
}
// [END refresh_token]

// [START ios_10_data_message]
// Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
// To enable direct data messages, you can set [Messaging messaging].shouldEstablishDirectChannel to YES.
- (void)messaging:(FIRMessaging *)messaging didReceiveMessage:(FIRMessagingRemoteMessage *)remoteMessage {
    NSLog(@"Received data message: %@", remoteMessage.appData);
}
// [END ios_10_data_message]

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Unable to register for remote notifications: %@", error);
}

// This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
// If swizzling is disabled then this function must be implemented so that the APNs device token can be paired to
// the FCM registration token.
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"APNs device token retrieved: %@", deviceToken);
    
    // With swizzling disabled you must set the APNs device token here.
     //[FIRMessaging messaging].APNSToken = deviceToken;
}
@end
