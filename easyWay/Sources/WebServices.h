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
    kGETJaccedePOINearLocation,
    kGETJourney
} kRequestType;


@protocol WebServicesDelegate <NSObject>

@optional
- (void)GEToperationDone:(kRequestType)requestType response:(NSDictionary *)response;

@required
- (void)internetNotAvailable:(kRequestType)requestType;
- (void)requestFailed:(kRequestType)requestType error:(NSError *)error;

@end


@interface WebServices : NSObject

@property (nonatomic, weak) id <WebServicesDelegate> delegate;

- (void)GEToperation:(NSString *)url
          parameters:(NSMutableDictionary *)parameters
              header:(NSMutableDictionary *)header
         requestType:(kRequestType)requestType;

- (void)cancelAllOperations;

// Jaccede Api Tools
- (NSMutableDictionary *)jxdAuthHeadersForPath:(NSString *)path requestMethod:(NSString *)method atTime:(long)now;

@end
