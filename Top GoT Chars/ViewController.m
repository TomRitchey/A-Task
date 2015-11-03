//
//  ViewController.m
//  Top GoT Chars
//
//  Created by Kacper Augustyniak on 29.10.2015.
//  Copyright © 2015 Kacper Augustyniak. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()


@end

@implementation ViewController
@synthesize topAbstracts;
@synthesize topTitles;
@synthesize mainTableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
     topTitles = [[NSMutableArray alloc] init];
     topAbstracts = [[NSMutableArray alloc] init];
    
    
    NSString *category = @"category";
    int limit = 75;
    for (int i = 0; i<limit; i++) {
        [topTitles  addObject:[NSString stringWithFormat:@"No Connection"]];
        [topAbstracts  addObject:[NSString stringWithFormat:@"No Connection"]];
    }
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0), ^{
        
        while(![self checkIfNetworkAwaliable]){
            usleep(1000000);
        }
        // NSLog(@"siec dostepna");
        usleep(30000);
        [self downloadData:limit inCategory:category];
        [mainTableView reloadData];
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (bool)checkIfNetworkAwaliable{
    bool success = NO;
    bool isAvailable = NO;
    const char *host_name = [@"http://gameofthrones.wikia.com/wiki/Game_of_Thrones_Wiki"
                             cStringUsingEncoding:NSASCIIStringEncoding];
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL,host_name);
    SCNetworkReachabilityFlags flags;
    success = SCNetworkReachabilityGetFlags(reachability, &flags);
    isAvailable = success && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
    return isAvailable;
}

- (void)downloadData:(int)dataLimit inCategory:(NSString*)dataCategory {
    NSString *baseUrl=[NSString stringWithFormat:@"http://gameofthrones.wikia.com/api/v1/Articles/Top?expand=1&category=%@&limit=%i",dataCategory,dataLimit];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:baseUrl]];
    [request setHTTPMethod:@"GET"];
    
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        //id object = [NSJSONSerialization JSONObjectWithData:returnedData options:0 error:&error];
        
        id jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        [topTitles removeAllObjects];
        [topAbstracts removeAllObjects];
        
        for(int i=0;i<dataLimit;i++){
            [topTitles  addObject:[[[jsonData objectForKey:@"items"] objectAtIndex: i] valueForKey:@"title"]];
            [topAbstracts  addObject:[[[jsonData objectForKey:@"items"] objectAtIndex: i] valueForKey:@"abstract"]];
            [mainTableView reloadData];
        }
        
    }] resume];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [topTitles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [topTitles objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [topAbstracts objectAtIndex:indexPath.row];
    return cell;
}
@end
