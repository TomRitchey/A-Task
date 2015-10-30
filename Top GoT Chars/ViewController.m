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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *category = @"Characters";
    int limit = 75;
    // Do any additional setup after loading the view, typically from a nib.
    
    dispatch_queue_t myCustomQueue;
    myCustomQueue = dispatch_queue_create("com.example.MyCustomQueue", NULL);
    
    
    topTitles = [[NSMutableArray alloc] init];
    topAbstracts = [[NSMutableArray alloc] init];
    topThumbnails = [[NSMutableArray alloc] init];
    
    
    for (int i = 0; i<limit; i++) {
        [topTitles  addObject:[NSString stringWithFormat:@"No Connection"]];
        [topAbstracts  addObject:[NSString stringWithFormat:@"Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus."]];
        //[topThumbnails  addObject:[UIImage imageNamed: @"mala pizza.png"]];
        [self genereteBlankImage];
        [topThumbnails addObject:[self genereteBlankImage]];
    }
    
    NSString *baseUrl=[NSString stringWithFormat:@"http://gameofthrones.wikia.com/api/v1/Articles/Top?expand=1&category=%@&limit=%i",category,limit];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:baseUrl]];
    [request setHTTPMethod:@"GET"];
    

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        //NSLog(@"requestReply: %@", requestReply);
        
        //id object = [NSJSONSerialization JSONObjectWithData:returnedData options:0 error:&error];
        
        id jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
       
        
//        if([jsonData isKindOfClass:[NSDictionary class]])
//        {
//            NSLog(@"tak jest dobry");
//            //NSDictionary *results = json;
//        }else{
//            NSLog(@"Nie jest dobry");
//        }
        
        //NSLog(@"Full data %@",json);
        
        //[topTitles removeAllObjects];
        //[topAbstracts removeAllObjects];
        //[topThumbnails removeAllObjects];
        
        for(int i=0;i<limit;i++){
        [topTitles  replaceObjectAtIndex:i withObject:[[[jsonData objectForKey:@"items"] objectAtIndex: i] valueForKey:@"title"]];
        [topAbstracts  replaceObjectAtIndex:i withObject:[[[jsonData objectForKey:@"items"] objectAtIndex: i] valueForKey:@"abstract"]];
            
            [mainTableView reloadData];
            
            NSString *url = [[[jsonData objectForKey:@"items"] objectAtIndex: i] valueForKey:@"thumbnail"];
           // NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url ]];
           // UIImage *image = [UIImage imageWithData:imageData];
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
        
        [mainTableView reloadData];
        //NSLog(@"Top Titles %@",topTitles);
    }] resume];
    
 
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
   //[topThumbnails objectAtIndex:indexPath.row]
    //[UIImage imageNamed: @"mala pizza.png"];//
    
    return cell;
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
