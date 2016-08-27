//
//  ViewController.m
//  AddMe
//
//  Created by mac apple on 24.08.2016.
//  Copyright © 2016 mac apple. All rights reserved.
//

#import "ViewController.h"
#import <Accounts/Accounts.h>
#import "Social/Social.h"
#import "NXOAuth2.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label;

@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickAction:(id)sender {
    
    NSString *accountName = self.textField.text;
    
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [account requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error)
     {
         NSLog(@"this is the request of account ");
         if (granted==YES) {
             NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
             if ([arrayOfAccounts count] > 0)
             {
                 // Keep it simple, use the first account available
                 ACAccount *acct = [arrayOfAccounts objectAtIndex:1];
                 
                 NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:accountName,@"screen_name",@"TRUE",@"follow", nil];
                 
                 NSURL *url = [[NSURL alloc] initWithString:@"https://api.twitter.com/1.1/friendships/create.json"];
                 
                 SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:url parameters:dictionary];
                 
                 [request setAccount:acct];
                 
                 [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
                  {
                      if ([urlResponse statusCode] == 200)
                      {
                          // The response from Twitter is in JSON format
                          // Move the response into a dictionary and print
                          NSError *error;
                          NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
                          NSLog(@"Twitter response: %@", dict);
                      }
                      else
                          NSLog(@"Twitter error, HTTP response: %li", (long)[urlResponse statusCode]);
                  }];
             }
         }
     }];
    
}

- (IBAction)instaClicked:(id)sender {
    
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    
    
    NSArray *instagramAccounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:@"Instagram"];
    
    if([instagramAccounts count] == 0){
        NSLog(@"Warning %ld Instagram accounts logged in", (long)[instagramAccounts count]);
        return;
    }
    
    NXOAuth2Account *acct = instagramAccounts[0];
    NSString *token = acct.accessToken.accessToken;
    
    NSString *userName = self.textField.text;
    
    NSString *urlStr=[NSString stringWithFormat:@"https://api.instagram.com/v1/users/%@/relationship?access_token=%@",userName,token];
    
    NSURL* url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:1000.0];
    NSString *parameters=@"action=follow";
    [theRequest setHTTPBody:[parameters dataUsingEncoding:NSUTF8StringEncoding]];
    [theRequest setHTTPMethod:@"POST"];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:theRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSLog(@"SA");
        
    }];
    
    [postDataTask resume];
    
    
    
    
}

- (IBAction)instaLoginClicked:(id)sender {
    [[NXOAuth2AccountStore sharedStore] requestAccessToAccountWithType:@"Instagram"];

}

- (IBAction)instaLogoutClicked:(id)sender {
    NXOAuth2AccountStore *store = [NXOAuth2AccountStore sharedStore];
    NSArray *instagramAccounts = [store accountsWithAccountType:@"Instagram"];
    
    NSLog([NSString stringWithFormat:@"Count: %d", instagramAccounts.count]);
    
    for (id account in instagramAccounts) {
        [store removeAccount:account];
    }
}

@end
