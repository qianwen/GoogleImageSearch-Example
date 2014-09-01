//
//  ISAPIRequest.m
//  ImageSearch
//
//  Created by sissi on 8/31/14.
//  Copyright (c) 2014 qianwen. All rights reserved.
//

#import "ISAPIRequest.h"
#import "ISImageModel.h"
#import "NSObject+NSObjectValidation.h"

static NSString *const kAPIBaseUrl = @"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=8";
static CGFloat const kTimeOut = 60.0f;

@interface ISAPIRequest ()<NSURLSessionDataDelegate>

@property (strong, nonatomic) NSURLSession *session;

@end

@implementation ISAPIRequest

- (instancetype)init {
    if (self == [super init]) {
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    }
    
    return self;
}

- (void)requestWithTerm:(NSString *)term
              startPage:(NSString *)page
             completion:(searchCompletionHandler)handler {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&q=%@&start=%@", kAPIBaseUrl, term, page]];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:kTimeOut];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSError *genericError = [[NSError alloc] initWithDomain:@"ImageSearch" code:0 userInfo:@{NSLocalizedFailureReasonErrorKey:@"Sorry, search result can't be displayed at this time"}];
        
        if (error == nil) {
            if (![json isValidDict]) {
               handler(nil, genericError);
            }
            
            NSString *statusCode = [json[@"responseStatus"] stringValue];
            if ([statusCode isEqualToString:@"200"]) {
                NSMutableArray *results = [@[] mutableCopy];
                
                if ([json[@"responseData"] isValidDict] && [json[@"responseData"][@"results"] isValidArray] && [json[@"responseData"][@"results"] count]) {
                    for (NSDictionary *item in json[@"responseData"][@"results"]) {
                        ISImageModel *imageModel = [[ISImageModel alloc] init];
                        if ([item[@"tbUrl"] isValidString]) {
                            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:item[@"tbUrl"]]
                                                                      options:0
                                                                        error:&error];
                            UIImage *image = [UIImage imageWithData:imageData];
                            imageModel.thumbnail = image;
                            [results addObject:imageModel];
                        }
                    }
                    
                    handler(results, nil);
                } else {
                    handler(nil, genericError);
                }
            } else {
                if ([json[@"responseDetails"] isValidString] && [json[@"responseDetails"] length]) {
                    NSError *dataError = [[NSError alloc] initWithDomain:@"ImageSearch" code:0 userInfo:@{NSLocalizedFailureReasonErrorKey:json[@"responseDetails"]}];
                    handler(nil, dataError);
                } else {
                    handler(nil, genericError);
                }
            }
        } else {
            handler(nil, error);
        }
    }];
    
    [dataTask resume];
}

@end
