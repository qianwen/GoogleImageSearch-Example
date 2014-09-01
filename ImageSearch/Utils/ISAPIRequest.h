//
//  ISAPIRequest.h
//  ImageSearch
//
//  Created by sissi on 8/31/14.
//  Copyright (c) 2014 qianwen. All rights reserved.
//

@import Foundation;

typedef void (^searchCompletionHandler)(NSArray *results, NSError *error);

@interface ISAPIRequest : NSObject

// Request to the Google Image Search with search term and start page number.
//
// @param term The search term to invoke a request
// @param competion A block which is invoked when the request completes.
- (void)requestWithTerm:(NSString *)term
              startPage:(NSString *)page
             completion:(searchCompletionHandler)handler;

@end
