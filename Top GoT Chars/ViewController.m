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
    // Do any additional setup after loading the view, typically from a nib.
    
    NSMutableArray* topTitles = [[NSMutableArray alloc] init];
    NSMutableArray* topAbstracts = [[NSMutableArray alloc] init];
    
    
    NSString *category = @"category";
    int limit = 10;
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
        
        for(int i=0;i<limit;i++){
        [topTitles  addObject:[[[jsonData objectForKey:@"items"] objectAtIndex: i] valueForKey:@"title"]];
        [topAbstracts  addObject:[[[jsonData objectForKey:@"items"] objectAtIndex: i] valueForKey:@"abstract"]];
        }
        NSLog(@"Top Titles %@",topTitles);
        
        
    }] resume];
    

    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
