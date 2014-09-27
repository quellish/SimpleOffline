//
//  ViewController.m
//  SimpleOffline
//
//  Created by Dan Zinngrabe on 9/22/14.
//  Copyright (c) 2014 Dan Zinngrabe. All rights reserved.
//

#import "ViewController.h"
@import SystemConfiguration;

static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkConnectionFlags flags, void* info);

@interface ViewController ()
@property   (nonatomic, strong)             dispatch_queue_t            scNetworkQueue;
@property   (nonatomic, weak)   IBOutlet    UIButton                    *connectButton;
@property   (nonatomic, assign)             SCNetworkReachabilityRef    currentReachability;

@end

@implementation ViewController
@synthesize scNetworkQueue;
@synthesize connectButton;
@synthesize currentReachability;

- (void) awakeFromNib {
    dispatch_queue_t    queue  = NULL;
    queue = dispatch_queue_create("scNetworkReachability", DISPATCH_QUEUE_SERIAL);
    [self setScNetworkQueue:queue];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)connectButtonTapped:(id)sender {
    if (sender != nil){
        NSURL *URL = [NSURL URLWithString:@"http://www.google.com/"];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *response, NSData __unused *data, NSError *error){
            if (response != nil){
                // Request succeeded
            } else {
                [self presentError:error];
            }
        }];
    }
}

- (void) host:(NSString *)__unused host didBecomeReachable:(BOOL)reachable {
    __strong UIButton    *button = [self connectButton];
    // Enable the button when we are notified the host became reachable
    [button setEnabled:reachable];
    if (reachable){
        [self endObsvervingReachabilityStatusForHost:nil];
    }
}

#pragma mark Error handling

- (void) presentError:(NSError *)error {
    
    if ([[error domain] isEqualToString:NSURLErrorDomain]){
        NSURL   *failingURL = [[error userInfo] valueForKey:NSURLErrorFailingURLErrorKey];
        switch ([error code]){
            case NSURLErrorNotConnectedToInternet:
                [self beginObservingReachabilityStatusForHost:[failingURL host]];
                break;
            default:
                break;
        }
    }
    return;
}

#pragma mark Reachability

- (void) beginObservingReachabilityStatusForHost:(NSString *)host {
    SCNetworkReachabilityRef        reachabilityRef     = NULL;
    
    void (^callbackBlock)(SCNetworkReachabilityFlags) = ^(SCNetworkReachabilityFlags flags) {
        BOOL reachable = (flags & kSCNetworkReachabilityFlagsReachable) != 0;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self host:host didBecomeReachable:reachable];
        }];
    };
    
    SCNetworkReachabilityContext context = {
        .version = 0,
        .info = (void *)CFBridgingRetain(callbackBlock),
        .release = CFRelease
    };
    
    
    if ([host length] > 0){
        reachabilityRef = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [host UTF8String]);
        if (SCNetworkReachabilitySetCallback(reachabilityRef, ReachabilityCallback, &context)){
            if (!SCNetworkReachabilitySetDispatchQueue(reachabilityRef, [self scNetworkQueue]) ){
                // Remove our callback if we can't use the queue
                SCNetworkReachabilitySetCallback(reachabilityRef, NULL, NULL);
            }
            [self setCurrentReachability:reachabilityRef];
        }
    }
}

- (void) endObsvervingReachabilityStatusForHost:(NSString *)__unused host {
    // Un-set the dispatch queue
    if (!SCNetworkReachabilitySetDispatchQueue([self currentReachability], NULL) ){
        
    }
    SCNetworkReachabilitySetCallback([self currentReachability], NULL, NULL);
}

static void ReachabilityCallback(SCNetworkReachabilityRef __unused target, SCNetworkConnectionFlags flags, void* info) {
    void (^callbackBlock)(SCNetworkReachabilityFlags) = (__bridge id)info;
    callbackBlock(flags);
}

@end
