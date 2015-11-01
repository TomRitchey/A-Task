//
//  ViewController.h
//  Top GoT Chars
//
//  Created by Kacper Augustyniak on 29.10.2015.
//  Copyright © 2015 Kacper Augustyniak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SystemConfiguration/SCNetworkReachability.h>

@interface ViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>
{
    id jsonData;
    NSMutableArray *topTitles;
    NSMutableArray *topAbstracts;
    NSMutableArray *topThumbnails;
    NSMutableArray *topUrls;
    IBOutlet UITableView *mainTableView;
    NSString *category;
    int limit;
    NSOperationQueue *loadingThumbnailsQueue;
    NSOperationQueue *loadingDataQueue;
}

@end

