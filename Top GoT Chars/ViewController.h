//
//  ViewController.h
//  Top GoT Chars
//
//  Created by Kacper Augustyniak on 29.10.2015.
//  Copyright © 2015 Kacper Augustyniak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray* topTitles;
    NSMutableArray* topAbstracts;
    NSMutableArray* topThumbnails;
    IBOutlet UITableView *mainTableView;
}

@end

