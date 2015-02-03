//
//  WebServices.h
//  Moovizi
//
//  Created by Tchikovani on 26/12/2014.
//  Copyright (c) 2014 Tchikovani. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum kRequestType {
    kGETAddressFromInput,
    kGETDetailsStartInput,
    kGETDetailsDestinationInput,
    kGETPOINearLocation,
    kGETJourney,
    kPOSTIssue
} kRequestType;


@protocol WebServicesDelegate <NSObject>

@optional
- (void)operationDone:(kRequestType)requestType response:(NSDictionary *)response;

@required
- (void)internetNotAvailable:(kRequestType)requestType;
- (void)requestFailed:(kRequestType)requestType error:(NSError *)error;

@end


@interface WebServices : NSObject

@property (nonatomic, weak) id <WebServicesDelegate> delegate;

- (void)GEToperation:(NSMutableDictionary *)request;
- (void)POSTMediaOperation:(NSMutableDictionary *)request;

- (void)cancelAllOperations;

// Jaccede Api Tools
- (NSMutableDictionary *)jxdAuthHeadersForPath:(NSString *)path requestMethod:(NSString *)method atTime:(long)now;

@end
