//
//  ANECollectionViewVC.m
//  Alister-Example
//
//  Created by ANODA on 11/18/16.
//  Copyright © 2016 Oksana Kovalchuk. All rights reserved.
//

#import "ANECollectionViewVC.h"
#import "ANECollectionViewController.h"
#import "ANEDataGenerator.h"

@interface ANECollectionViewVC ()

@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) ANECollectionViewController* controller;
@property (nonatomic, strong) ANStorage* storage;

@end

@implementation ANECollectionViewVC

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.storage = [ANStorage new];
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                                 collectionViewLayout:[self _collectionLayout]];
        self.collectionView.backgroundColor = [UIColor whiteColor];
        
        self.controller = [[ANECollectionViewController alloc] initWithCollectionView:self.collectionView];
        [self.controller updateWithStorage:self.storage];
    }
    return self;
}

- (void)loadView
{
    self.view = self.collectionView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray* items = [ANEDataGenerator generateStringsArrayWithCapacity:30];
    
    [self.storage updateWithoutAnimationChangeBlock:^(id<ANStorageUpdatableInterface> storageController) {
        [storageController addItems:items];
    }];
}


#pragma mark - Helper Methods

- (UICollectionViewFlowLayout*)_collectionLayout
{
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds) / 2;
    
    UICollectionViewFlowLayout* layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsZero;
    layout.itemSize = CGSizeMake(width, width);
    return layout;
}

@end
