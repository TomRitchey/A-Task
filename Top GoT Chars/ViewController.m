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

@synthesize jsonData;
@synthesize topTitles;
@synthesize topAbstracts;
@synthesize topThumbnails;
@synthesize topUrls;
@synthesize mainTableView;
@synthesize category;
@synthesize limit;
@synthesize loadingThumbnailsQueue;
@synthesize loadingDataQueue;
@synthesize loadingDataAllowed;

int counterr;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    category = @"Characters";
    limit = 75;

    loadingDataQueue = [[NSOperationQueue alloc] init];
    loadingThumbnailsQueue = [[NSOperationQueue alloc] init];
    loadingThumbnailsQueue.maxConcurrentOperationCount = 30;
    
    topTitles = [[NSMutableArray alloc] init];
    topAbstracts = [[NSMutableArray alloc] init];
    topThumbnails = [[NSMutableArray alloc] init];
    topUrls = [[NSMutableArray alloc] init];
    
    loadingDataAllowed = YES;
    self.Timer = [NSTimer timerWithTimeInterval:1.5 target:self selector:@selector(canLoadData) userInfo: nil repeats: YES];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [self.tableView addGestureRecognizer:doubleTap];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    //longPress.minimumPressDuration = 0.5;
    [self.tableView addGestureRecognizer:longPress];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]init];
    [refreshControl addTarget:self action:@selector(refreshPull) forControlEvents:UIControlEventValueChanged];
    //refreshControl.tintColor = [UIColor blueColor];
    self.refreshControl = refreshControl;
    
    [self initDefaultValues:YES];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0), ^{
    
        while(![self checkIfNetworkAwaliable]){
        usleep(1000000);
        }
       // NSLog(@"siec dostepna");
        usleep(30000);
        [self downloadData:limit inCategory:category];
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initDefaultValues:(bool)defaultValues{
    if(!defaultValues){
        for (int i = 0; i<limit; i++) {
            [topTitles  replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"Refreshing..."]];
            [topAbstracts  replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus."]];
            [topUrls replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"empty"]];
            [topThumbnails replaceObjectAtIndex:i withObject:[self genereteBlankImage]];
        }
    }else{
        for (int i = 0; i<limit; i++) {
            [topTitles  addObject:[NSString stringWithFormat:@"No Connection"]];
            [topAbstracts  addObject:[NSString stringWithFormat:@"Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus."]];
            [topUrls addObject:[NSString stringWithFormat:@"empty"]];
            [topThumbnails addObject:[self genereteBlankImage]];
        }
    }
}

#pragma mark - Networking

- (void)downloadData:(int)dataLimit inCategory:(NSString*)dataCategory {
    loadingDataAllowed = NO;
    [self.Timer fire];
    //NSLog(@"allowed  %i for %i time", loadingDataAllowed, counterr);counterr++;
    NSString *baseUrl=[NSString stringWithFormat:@"http://gameofthrones.wikia.com/api/v1/Articles/Top?expand=1&category=%@&limit=%i",dataCategory,dataLimit];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:baseUrl]];
    [request setHTTPMethod:@"GET"];
    
    
    
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        //NSLog(@"requestReply: %@", requestReply);
        
        //id object = [NSJSONSerialization JSONObjectWithData:returnedData options:0 error:&error];
        //NSLog(@"data %@",data);
        if(!data){
        }else{
            //NSLog(@"jest ma data");
            jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
        }
        //NSLog(@"Top Titles %@",topTitles);
    }] resume];
    //[loadingDataQueue addOperationWithBlock: ^ {
    //NSLog(@"outside block");
    __block NSBlockOperation *downloadDataOperation = [NSBlockOperation blockOperationWithBlock:^{
        //NSLog(@"inside block");
        while(!jsonData){
            usleep(200000);
            if([downloadDataOperation isCancelled]) return;
        }
        //NSLog(@"%@",jsonData);
        
        if([downloadDataOperation isCancelled]) return;
        for(int i=0;i<limit;i++){
            NSObject *tempTitle =[[[jsonData objectForKey:@"items"] objectAtIndex: i] valueForKey:@"title"];
            if([downloadDataOperation isCancelled]) return;
            [topTitles  replaceObjectAtIndex:i withObject:tempTitle];
            NSObject *tempItem = [[[jsonData objectForKey:@"items"] objectAtIndex: i] valueForKey:@"abstract"];
            if([downloadDataOperation isCancelled]) return;
            [topAbstracts  replaceObjectAtIndex:i withObject:tempItem];
        
            //NSLog(@"before %@",[topUrls objectAtIndex:i]);
            NSObject *tempUrl = [NSString stringWithFormat:@"%@%@",[jsonData valueForKey:@"basepath"],[[[jsonData objectForKey:@"items"] objectAtIndex: i] valueForKey:@"url"]];
            if([downloadDataOperation isCancelled]) return;
            [topUrls   replaceObjectAtIndex:i withObject:tempUrl];
            
            NSString *urlThumbnail = [[[jsonData objectForKey:@"items"] objectAtIndex: i] valueForKey:@"thumbnail"];
            
            if([downloadDataOperation isCancelled]) return;
            
            if(urlThumbnail == [NSNull null]){
                [topThumbnails replaceObjectAtIndex:i withObject:[self genereteBlankImage]];
                
            }else{
                //NSLog(@"%lu",(unsigned long)[url length]);
                usleep(i*500);
///////////////////////////////////////////////////////////////////////////////////////////////
                if([downloadDataOperation isCancelled]) return;
                
                __block __weak NSBlockOperation *downloadImageOperation = [NSBlockOperation blockOperationWithBlock:^{
                    
                        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlThumbnail]];
                    if([downloadImageOperation isCancelled]) return;
                    
                        if(imageData!=nil && ![downloadImageOperation isCancelled]){
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                UIImage *image = [UIImage imageWithData:imageData];
                                [topThumbnails replaceObjectAtIndex:i withObject:image];
                                //if (!(i%3)) {
                                [mainTableView reloadData]; //}
 
                            });
                            //[mainTableView reloadData];
                        }
                    
                    }];
               
                    [loadingThumbnailsQueue addOperation:downloadImageOperation];

///////////////////////////////////////////////////////////////////////////////////////////////
//                [loadingThumbnailsQueue addOperationWithBlock: ^ {
//                    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
//                
//                    if(imageData!=nil){
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                    
//                            UIImage *image = [UIImage imageWithData:imageData];
//                            [topThumbnails replaceObjectAtIndex:i withObject:image];
//                            if (!(i%3)) {
//                                [mainTableView reloadData]; }
// 
//                        });
//                    }
//                }];
///////////////////////////////////////////////////////////////////////////////////////////////
                
            }
            //[mainTableView reloadData]; 
            
            // [topThumbnails  addObject:image];
            //NSLog(@"%@",[[[jsonData objectForKey:@"items"] objectAtIndex: i] valueForKey:@"thumbnail"]);
        }
        
    }];
    
    [loadingDataQueue addOperation:downloadDataOperation];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0), ^{
//    [mainTableView reloadData];});
    
    //NSLog(@"session closed");
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

- (void)goToCharacterSite:(UISwipeGestureRecognizer*)tap {
    
    if (UIGestureRecognizerStateRecognized == tap.state)
    {
        CGPoint point = [tap locationInView:tap.view];
        NSIndexPath* indexPath = [self.tableView indexPathForRowAtPoint:point];
        //UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if(![[topTitles objectAtIndex:indexPath.row]  isEqual: @"Refreshing..."]){
            if([[topUrls objectAtIndex:indexPath.row]isEqualToString:@"empty"]){
                [self showErrorMessage];
            }else{
                [self showMessage:indexPath.row];
            }
        }
    }
}

-(void)canLoadData{
    loadingDataAllowed = YES;
    //NSLog(@"can load now");
}
#pragma mark Handling user input

- (void)doubleTap:(UISwipeGestureRecognizer*)tap {
    [self goToCharacterSite:tap];
}

- (void)longPress:(UISwipeGestureRecognizer*)tap {
    [self goToCharacterSite:tap];
}

- (void)refreshPull{
    
    [loadingDataQueue cancelAllOperations];
    [loadingThumbnailsQueue cancelAllOperations];
    
    [self initDefaultValues:NO];
    [mainTableView reloadData];
    //NSLog(@"Data loading request");
   if([self checkIfNetworkAwaliable]){
       dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
           //usleep(500000);
//           if ([self.Timer isValid]) {
//               NSLog(@"allowed %i", loadingDataAllowed);
//           }else{
//               
//               NSLog(@"not allowed");
//           }
           while (!loadingDataAllowed) {
               usleep(50000);
               NSLog(@"waiting");
           }
           [loadingThumbnailsQueue waitUntilAllOperationsAreFinished];
           [loadingDataQueue waitUntilAllOperationsAreFinished];
           [self downloadData:limit inCategory:category];
          // NSLog(@"Data loading");
       });
   }else{
       //[self initDefaultValues:YES];
       [mainTableView reloadData];
       [self showErrorMessage];
   }
    [self.refreshControl endRefreshing];
}

#pragma mark Table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [topTitles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *tableIdentifier = @"GoT Characters";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:tableIdentifier];
    }
    
    cell.textLabel.text = [topTitles objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [topAbstracts objectAtIndex:indexPath.row];
    //cell.imageView.image = [topThumbnails objectAtIndex:indexPath.row];
    
    [UIView transitionWithView:cell.imageView duration:0.7f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{ cell.imageView.image = [topThumbnails objectAtIndex:indexPath.row]; } completion:NULL];
    
    return cell;
}

#pragma mark Others

- (void)showErrorMessage {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"No connection"
                                                            message:@"Check your internet connection or try again later."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* dismissAction = [UIAlertAction actionWithTitle:@"Dismiss"
                                                            style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action) {}];
    
    [alert addAction:dismissAction];
    [self presentViewController:alert animated:YES completion:nil];


}

- (void)showMessage:(NSInteger)index {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:[NSString  stringWithFormat:@"Do you want to visit page about %@?",[topTitles objectAtIndex:index]]
                                          message:@"Tap OK to go to Safari."
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       //NSLog(@"Cancel action");
                                   }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[topUrls objectAtIndex:index]]];
                                   //NSLog(@"OK action");
                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


- (UIImage *)genereteBlankImage {
   
    CGSize size = CGSizeMake(200, 200);
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    CGFloat red = arc4random_uniform(255) / 255.0;
    CGFloat green = arc4random_uniform(255) / 255.0;
    CGFloat blue = arc4random_uniform(255) / 255.0;
    
    [[UIColor colorWithRed:red green:green blue:blue alpha:1.0] setFill];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
