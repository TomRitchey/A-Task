//
//  ViewController.m
//  Top GoT Chars
//
//  Created by Kacper Augustyniak on 29.10.2015.
//  Copyright © 2015 Kacper Augustyniak. All rights reserved.
//

#import "ViewController.h"
#import <SystemConfiguration/SCNetworkReachability.h>

@interface ViewController ()


@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *category = @"Characters";
    int limit = 75;

    
    topTitles = [[NSMutableArray alloc] init];
    topAbstracts = [[NSMutableArray alloc] init];
    topThumbnails = [[NSMutableArray alloc] init];
    topUrls = [[NSMutableArray alloc] init];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToCharacterSite:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [self.tableView addGestureRecognizer:doubleTap];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(goToCharacterSite:)];
    //longPress.minimumPressDuration = 0.5;
    [self.tableView addGestureRecognizer:longPress];
    //NSLog(@" %@",topTitles);
    

    
    for (int i = 0; i<limit; i++) {
        [topTitles  addObject:[NSString stringWithFormat:@"No Connection"]];
        [topAbstracts  addObject:[NSString stringWithFormat:@"Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus."]];
        [topThumbnails addObject:[self genereteBlankImage]];
        [topUrls addObject:[NSString stringWithFormat:@"empty"]];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0), ^{
        
        bool success = NO;
        bool isAvailable = NO;
        const char *host_name = [@"http://gameofthrones.wikia.com/wiki/Game_of_Thrones_Wiki"
                                 cStringUsingEncoding:NSASCIIStringEncoding];
        while(!isAvailable){
        SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL,
                                                                                    host_name);
        SCNetworkReachabilityFlags flags;
        success = SCNetworkReachabilityGetFlags(reachability, &flags);
        isAvailable = success && (flags & kSCNetworkFlagsReachable) &&
        !(flags & kSCNetworkFlagsConnectionRequired);
//        if (isAvailable){
//            //[self downloadData:limit inCategory:category];
//            //NSLog(@"siec dostepna");
//        }else{//NSLog(@"siec nie dostepna");
//            }
        usleep(30000);
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

- (void)downloadData:(int)limit inCategory:(NSString*)category{
    
    NSString *baseUrl=[NSString stringWithFormat:@"http://gameofthrones.wikia.com/api/v1/Articles/Top?expand=1&category=%@&limit=%i",category,limit];
    
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
            id jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            for(int i=0;i<limit;i++){
                [topTitles  replaceObjectAtIndex:i withObject:[[[jsonData objectForKey:@"items"] objectAtIndex: i] valueForKey:@"title"]];
                [topAbstracts  replaceObjectAtIndex:i withObject:[[[jsonData objectForKey:@"items"] objectAtIndex: i] valueForKey:@"abstract"]];
                
                
                //NSLog(@"before %@",[topUrls objectAtIndex:i]);
                [topUrls   replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%@%@",[jsonData valueForKey:@"basepath"],[[[jsonData objectForKey:@"items"] objectAtIndex: i] valueForKey:@"url"]]];
                
                NSString *url = [[[jsonData objectForKey:@"items"] objectAtIndex: i] valueForKey:@"thumbnail"];
                
                if(url == [NSNull null]){
                    [topThumbnails replaceObjectAtIndex:i withObject:[self genereteBlankImage]];
                    [mainTableView reloadData];
                    
                }else{
                    //NSLog(@"%lu",(unsigned long)[url length]);
                    //usleep(i*3000);
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0), ^{
                        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
                        if ( imageData == nil )
                            return;
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            
                            UIImage *image = [UIImage imageWithData:imageData];
                            //[topThumbnails addObject:image];
                            [topThumbnails replaceObjectAtIndex:i withObject:image];
                            [mainTableView reloadData];
                        });
                    });
                }
                // [topThumbnails  addObject:image];
                //NSLog(@"%@",[[[jsonData objectForKey:@"items"] objectAtIndex: i] valueForKey:@"thumbnail"]);
            }
        }
        [mainTableView reloadData];
        //NSLog(@"Top Titles %@",topTitles);
    }] resume];
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [topTitles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tableIdentifier = @"GoT Characters";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:tableIdentifier];
    }
    
    cell.textLabel.text = [topTitles objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [topAbstracts objectAtIndex:indexPath.row];
    //cell.imageView.image = [topThumbnails objectAtIndex:indexPath.row];
    cell.imageView.image = [topThumbnails objectAtIndex:indexPath.row];
   
    //[UIImage imageNamed: @"mala pizza.png"];//
    
    return cell;
}


- (void)goToCharacterSite:(UISwipeGestureRecognizer*)tap
{
    if (UIGestureRecognizerStateRecognized == tap.state)
    {
        CGPoint point = [tap locationInView:tap.view];
        NSIndexPath* indexPath = [self.tableView indexPathForRowAtPoint:point];
        //UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
         //NSLog(@"tap row %@",[topUrls objectAtIndex:indexPath.row]);
        if(![[topTitles objectAtIndex:indexPath.row]isEqualToString:@"No Connection"]){
        [self showMessage:indexPath.row];
        }
    }
}

- (void)showMessage:(NSInteger)index {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:[NSString  stringWithFormat:@"Do you want to visit page about %@?",[topTitles objectAtIndex:index]]
                                          message:@"Tap OK to go to Safari"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       //NSLog(@"Cancel action");
                                   }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
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


- (UIImage *)genereteBlankImage{
    //UIImage *tempImage = [topThumbnails objectAtIndex:0];
    
    //CGSize size = CGSizeMake(tempImage.size.width, tempImage.size.height);
    CGSize size = CGSizeMake(200, 200);
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    CGFloat red = arc4random_uniform(255) / 255.0;
    CGFloat green = arc4random_uniform(255) / 255.0;
    CGFloat blue = arc4random_uniform(255) / 255.0;
    
    [[UIColor colorWithRed:red green:green blue:blue alpha:1.0] setFill];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    
    //NSLog(@"width %f height %f",size.width,size.height);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
