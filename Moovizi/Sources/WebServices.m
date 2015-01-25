//
//  WebServices.m
//  Moovizi
//
//  Created by Tchikovani on 26/12/2014.
//  Copyright (c) 2014 Tchikovani. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

#import "WebServices.h"
#import "Base64.h"
#import "AFNetworking.h"

@interface WebServices ()

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;

@end

#define kJxdHeaderTimestamp @"x-jispapi-timestamp"
#define kJxdHeaderAuth @"Authorization"
#define kJxdApiAccessKey @"test-jispapi-secret-access-key"
#define kJxdApiAccessKeyId @"test-jispapi-access-key-id"

@implementation WebServices

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.manager = [AFHTTPRequestOperationManager manager];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    }
    return self;
}

- (void)GEToperation:(NSString *)url parameters:(NSMutableDictionary *)parameters header:(NSMutableDictionary *)header requestType:(kRequestType)requestType {
    
    if ([AFNetworkReachabilityManager sharedManager].reachable == NO) {
        if ([self.delegate respondsToSelector:@selector(internetNotAvailable:)]) {
            [self.delegate internetNotAvailable:requestType];
        }
        return;
    }
    
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    for (NSString *headerKey in header) {
        [self.manager.requestSerializer setValue:[header valueForKey:headerKey] forHTTPHeaderField:headerKey];
    }
    
    [self.manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([self.delegate respondsToSelector:@selector(GEToperationDone:response:)]) {
            [self.delegate GEToperationDone:requestType response:responseObject];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(requestFailed:error:)]) {
            [self.delegate requestFailed:requestType error:error];
        }
    }];
}

- (void)cancelAllOperations {
    [self.manager.operationQueue cancelAllOperations];
}

#pragma Jaccede Api methods

- (NSMutableDictionary *)jxdAuthHeadersForPath:(NSString *)path requestMethod:(NSString *)method atTime:(long)now {
    NSString *signature = [self signatureForRequestMethod:method urlPath:path atTime:now];
    NSString *authHeader = [NSString stringWithFormat:@"%@ %@:%@", kJxdHeaderAuth, kJxdApiAccessKeyId, signature];
    
    NSString *timestampHeader = [NSString stringWithFormat:@"%ld", now];
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [headers setObject:timestampHeader forKey:kJxdHeaderTimestamp];
    [headers setObject:authHeader forKey:kJxdHeaderAuth];
    
    return headers;
}

- (NSString *)signatureForRequestMethod:(NSString *)method urlPath:(NSString *)path atTime:(long)now {
    
    NSString *toSign = [NSString stringWithFormat:@"%@\n%@:%ld\n%@",
                        [method uppercaseString], kJxdHeaderTimestamp, now, path];
    
    const char* cKey = [kJxdApiAccessKey cStringUsingEncoding:NSUTF8StringEncoding];
    const char* cData = [toSign cStringUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char cHMACDest[CC_SHA1_DIGEST_LENGTH]; //dest buffer
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMACDest);
    
    NSData *hmacData = [[NSData alloc] initWithBytes:cHMACDest length:CC_SHA1_DIGEST_LENGTH];
    
    const uint8_t *bytes = [hmacData bytes];
    size_t length = [hmacData length];
    char dest[2*length+1];
    char *dst = &dest[0];
    for( size_t i=0; i<length; i+=1 )
        dst += sprintf(dst,"%02x", bytes[i]);
    
    NSString *hmacString = [[NSString alloc] initWithBytes: dest length: 2*length encoding: NSUTF8StringEncoding];
    return [hmacString base64EncodedString];
}

@end
