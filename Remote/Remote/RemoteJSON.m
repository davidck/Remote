//
//  RemoteJSON.m
//  Remote
//
//  Created by David CK Chan on 2014-06-16.
//  Copyright (c) 2014 AlteredBit Studios inc. All rights reserved.
//

#import "RemoteJSON.h"
#import "Reachability.h"

@interface RemoteJSON()
    @property (nonatomic, weak) IBOutlet id <RemoteJSONDelegate> delegate;
    @property (strong, nonatomic) NSMutableData *responseData;
@end

@implementation RemoteJSON
@synthesize responseData;

+(NSURLConnection *)request:(NSString *)url
            withObject:(NSDictionary *)object
            delegate:(id)delegate {
    
    __block NSMutableArray *requestParams = [[NSMutableArray alloc] init];
    
    NSMutableString *strUrl = [NSMutableString stringWithFormat:@"%@", url];
    
    if ([object count]) {
        [object enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString *newObj = [(NSString *)obj stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
            
            [requestParams addObject:[NSString stringWithFormat:@"%@=%@", (NSString *)key, newObj]];
        }];
    }
    
    __block NSString *compiledParams = [requestParams componentsJoinedByString:@"&"];
    
//    NSLog(@"Built request url: %@", strUrl);
//    NSLog(@"Built request params: %@", compiledParams);
    
    __block NSURL *compiledUrl = [[NSURL alloc] initWithString:strUrl];
    
    @try {
        const char *bytes = [compiledParams UTF8String];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:compiledUrl];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[NSData dataWithBytes:bytes length:strlen(bytes)]];
        
//        if (NO && [connection respondsToSelector:@selector(cancel)]) {
//            NSLog(@"Cancelled");
//            [connection cancel];
//        }
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
        return connection;
    }
    @catch (NSException *e) {
/*
 NSException* myException = [NSException
 exceptionWithName:@"FileNotFoundException"
 reason:@"File Not Found on System"
 userInfo:nil];
 @throw myException;
*/
         // [myException raise]; /* equivalent to above directive */
        
        NSLog(@"%@", e);
        @throw;
    }
}

// Check connection to the Internet
+(BOOL)hasActiveInternetConnection {
    Reachability *r = [Reachability reachabilityWithHostName:@"google.com"]; // Check internet
    if ([r currentReachabilityStatus] != ReachableViaWiFi && [r currentReachabilityStatus] != ReachableViaWWAN) {
        return NO;
    }
    return YES;
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [responseData setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self handleResponse:[NSDictionary dictionaryWithObjectsAndKeys:_delegate, @"delegate", responseData, @"data", nil]];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection error: %@", error);
}

// Sends json string to delegate if response is present.
-(void)handleResponse:(NSDictionary *)package {
    _delegate = [package objectForKey:@"delegate"];
    if (_delegate == nil) {
        return;
    } else {
        NSData *responseObject = [package objectForKey:@"data"];
        
        NSError *error;
        NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject
                                                             options:NSJSONReadingMutableContainers
                                                               error:&error];
        
        [_delegate remoteDidTask:jsonObject sender:self];
    }
}


@end
