//
//  ISHistoryViewController.m
//  ImageSearch
//
//  Created by sissi on 8/31/14.
//  Copyright (c) 2014 qianwen. All rights reserved.
//

#import "ISHistoryViewController.h"

@interface ISHistoryViewController ()

@property (strong, nonatomic) NSArray *savedTerms;

@end

@implementation ISHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // retrieve the saved search terms
    self.savedTerms = [[NSUserDefaults standardUserDefaults] objectForKey:@"SEARCH_HISTORY"];
    [self.tableView reloadData];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.savedTerms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryCell" forIndexPath:indexPath];
    
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.f];
    cell.textLabel.text = self.savedTerms[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *selectedOption = [self.savedTerms objectAtIndex:indexPath.row];
    
    if (self.selectedOptionBlock) {
        self.selectedOptionBlock(selectedOption);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)dismissPage:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
