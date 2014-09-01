//
//  ISHistoryViewController.h
//  ImageSearch
//
//  Created by sissi on 8/31/14.
//  Copyright (c) 2014 qianwen. All rights reserved.
//

@import UIKit;

@interface ISHistoryViewController : UITableViewController

@property (strong, nonatomic) void (^selectedOptionBlock)(NSString *term);

@end
