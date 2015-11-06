//
//  ViewController.h
//  Top GoT Chars
//
//  Created by Kacper Augustyniak on 29.10.2015.
//  Copyright © 2015 Kacper Augustyniak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#import "WebViewController.h"

@interface ViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property bool loadingDataAllowed;
@property id jsonData;
@property NSMutableArray *topTitles;
@property NSMutableArray *topAbstracts;
@property NSMutableArray *topThumbnails;
@property NSMutableArray *topUrls;
@property IBOutlet UITableView *mainTableView;
@property NSString *category;
@property int limit;
@property NSOperationQueue *loadingThumbnailsQueue;
@property NSOperationQueue *loadingDataQueue;
@property NSTimer *Timer;
@property (strong, nonatomic) IBOutlet UIView *webContainerView;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UINavigationItem *navBar;


@end

