//
//  WebViewController.h
//  Top GoT Chars
//
//  Created by Kacper Augustyniak on 06.11.2015.
//  Copyright © 2015 Kacper Augustyniak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIWebView *webViewWindow;
@property(nonatomic, strong) NSString *labelString;
@property(nonatomic, strong) NSString *urlString;
@property (strong, nonatomic) IBOutlet UINavigationItem *navigationTitle;

@end
