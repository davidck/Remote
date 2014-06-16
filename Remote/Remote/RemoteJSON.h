//
//  RemoteJSON.h
//  Remote
//
//  Created by David CK Chan on 2014-06-16.
//  Copyright (c) 2014 AlteredBit Studios inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RemoteJSON;

@protocol RemoteJSONDelegate <NSObject>
    -(void)remoteDidTask:(NSDictionary *)response sender:(RemoteJSON *)sender;
@end

@interface RemoteJSON : NSObject <NSURLConnectionDelegate>
    @property (nonatomic, strong) NSURLConnection *connection;
    +(NSURLConnection *)request:(NSString *)url withObject:(NSDictionary *)object delegate:(id)delegate;
    +(BOOL)hasActiveInternetConnection;
@end
