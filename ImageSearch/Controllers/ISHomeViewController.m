//
//  ISHomeViewController.m
//  ImageSearch
//
//  Created by sissi on 8/31/14.
//  Copyright (c) 2014 qianwen. All rights reserved.
//

#import "ISHomeViewController.h"
#import "ISAPIRequest.h"
#import "ISImageCell.h"
#import "ISImageModel.h"
#import "ISHistoryViewController.h"

@interface ISHomeViewController ()<UISearchBarDelegate>

@property (strong, nonatomic) NSMutableArray *searchResults;
@property (strong, nonatomic) ISAPIRequest *api;
@property (strong, nonatomic) NSString *searchTerm;
@property (strong, nonatomic) UIActivityIndicatorView *activityView;
@property (strong, nonatomic) UILabel *loadingLabel;

@property (assign, nonatomic) NSUInteger startNo;

@end

@implementation ISHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.api = [[ISAPIRequest alloc] init];
    self.startNo = 0;
    self.searchResults = [@[] mutableCopy];
    
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityView.center = self.view.center;
    self.loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.activityView.frame), 320.f, 44.f)];
    self.loadingLabel.text = @"Loading Images...";
    self.loadingLabel.textAlignment = NSTextAlignmentCenter;
    self.loadingLabel.textColor = [UIColor whiteColor];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 250, 44)];
    searchBar.delegate = self;
    searchBar.barStyle = UIBarStyleDefault;
    searchBar.placeholder = @"Input Search Term";
    self.navigationItem.titleView = searchBar;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list"] style:UIBarButtonItemStylePlain target:self action:@selector(navigateToHistoryView)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void)handleSearch:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    NSString *term = [searchBar.text stringByTrimmingCharactersInSet:
                      [NSCharacterSet whitespaceCharacterSet]];
    if (term.length > 0) {
        searchBar.text = nil;
        self.searchTerm = term;
        [self.searchResults removeAllObjects];
        
        // save the search input
        NSArray *savedTerms = [[NSUserDefaults standardUserDefaults] objectForKey:@"SEARCH_HISTORY"];
        BOOL shouldAdd = YES;
        if (!savedTerms) {
            savedTerms = [[NSArray alloc] init];
        } else {
            for (NSString *previous in savedTerms) {
                if ([previous isEqualToString:term]) {
                    shouldAdd = NO;
                    break;
                }
            }
        }
        
        if (shouldAdd) {
            NSMutableArray *mutableSavedTerms = [savedTerms mutableCopy];
            [mutableSavedTerms addObject:term];
            
            [[NSUserDefaults standardUserDefaults] setObject:[mutableSavedTerms copy] forKey:@"SEARCH_HISTORY"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        // request images from the API
        [self fetchImages];
    }
}

- (void)fetchImages {
    // display loading spinner
    [self.view addSubview:self.activityView];
    [self.activityView startAnimating];
    [self.view addSubview:self.loadingLabel];
    [self.view bringSubviewToFront:self.loadingLabel];
    
    // fetch images from the API
    __weak ISHomeViewController *this = self;
    [self.api requestWithTerm:self.searchTerm startPage:[NSString stringWithFormat:@"%@", @(self.startNo)] completion:^(NSArray *results, NSError *error) {
        __strong ISHomeViewController *strong = this;
        
        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"ERROR" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                
                [strong stopActivityView];
            });
        } else if (results.count) {
            [self.searchResults addObjectsFromArray:results];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                strong.startNo += results.count;
                [strong stopActivityView];
                
                [strong.collectionView reloadData];
            });
        }
    }];
}

- (void)navigateToHistoryView {
    [self performSegueWithIdentifier:@"VIEW_HISTORY" sender:self];
}

- (void)stopActivityView {
    [self.activityView stopAnimating];
    [self.activityView removeFromSuperview];
    [self.loadingLabel removeFromSuperview];
}

#pragma mark - Search Bar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self handleSearch:searchBar];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [self handleSearch:searchBar];
}

#pragma mark - CollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.searchResults.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    ISImageCell *cell = (ISImageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    ISImageModel *imageModel = self.searchResults[indexPath.row];
    cell.imageView.image = imageModel.thumbnail;
    
    if (indexPath.row == self.searchResults.count -1) {
        [self fetchImages];
    }
    
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"VIEW_HISTORY"]) {
        UINavigationController *naviController = (UINavigationController *)segue.destinationViewController;
        ISHistoryViewController *historyView = (ISHistoryViewController *)naviController.viewControllers[0];
        
        // load the images when user selects the search term from the history page
        historyView.selectedOptionBlock = ^(NSString *term) {
            self.searchTerm = term;
            [self.searchResults removeAllObjects];
            [self fetchImages];
        };
    }
}

@end
