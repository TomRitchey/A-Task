//
//  WebViewController.m
//  Top GoT Chars
//
//  Created by Kacper Augustyniak on 06.11.2015.
//  Copyright © 2015 Kacper Augustyniak. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end
@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationTitle.title = self.labelString;
    
    NSURL *url = [NSURL URLWithString:self.urlString];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_webViewWindow loadRequest:requestObj];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
