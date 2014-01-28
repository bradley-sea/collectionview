//
//  ViewController.m
//  coltest
//
//  Created by Brad on 1/27/14.
//  Copyright (c) 2014 Brad. All rights reserved.
//

#import "ViewController.h"
#import "CollectionViewCell.h"
#import "GitUser.h"

@interface ViewController () <UICollectionViewDataSource,UICollectionViewDelegate,UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong,nonatomic) NSMutableArray *usersArray;
@property (strong,nonatomic) NSOperationQueue *imageQueue;


@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.searchBar.delegate =self;
	
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.usersArray = [NSMutableArray new];
    self.imageQueue = [NSOperationQueue new];
    
    self.collectionView.allowsSelection = YES;
    
    
}



-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.usersArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    CollectionViewCell *customCell = (CollectionViewCell *)cell;
    
    customCell.userImageView.image = nil;
    
    GitUser *user = self.usersArray[indexPath.row];
    
    customCell.nameLabel.text = user.name;
    
    if (!user.image)
    {
        [self downloadUserImageForIndex:indexPath.row];
    }
    else customCell.userImageView.image = user.image;
    
    return customCell;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    [self searchForUser:searchBar.text];
}

-(void)searchForUser:(NSString *)searchString
{
    searchString = [NSString stringWithFormat:@"https://api.github.com/search/users?q=%@", searchString];

    NSError *error;
    NSURL *searchURL = [NSURL URLWithString:searchString];
    NSData *searchData = [NSData dataWithContentsOfURL:searchURL];
    NSDictionary *searchDictionary = [NSJSONSerialization JSONObjectWithData:searchData options:NSJSONReadingMutableContainers error:&error];
    NSArray *searchArray = searchDictionary[@"items"];
    NSLog(@"%@", searchArray);
    
    [self createUsersFromArray:searchArray];
}

-(void)createUsersFromArray:(NSArray *)searchArray
{
    for (NSDictionary *dictionary in searchArray)
    {
        GitUser *user = [GitUser new];
        
        user.name = [dictionary objectForKey:@"login"];
        user.imageURL = [dictionary objectForKey:@"avatar_url"];
        [self.usersArray addObject:user];
        
    }
    
    [self.collectionView reloadData];
    
  
}

-(void)downloadUserImageForIndex:(NSInteger)index
{
    GitUser *user = self.usersArray[index];
    NSURL *imageURL = [NSURL URLWithString: user.imageURL];
    
    [self.imageQueue addOperationWithBlock:^{
        
        NSData *picData = [NSData dataWithContentsOfURL:imageURL];
        user.image = [UIImage imageWithData:picData];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0] ]];
        }];
        
    }];
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.usersArray removeObjectAtIndex:indexPath.row];
    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    
}


@end
