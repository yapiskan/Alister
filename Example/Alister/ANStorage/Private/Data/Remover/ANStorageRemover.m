//
//  ANStorageRemover.m
//  Pods
//
//  Created by Oksana Kovalchuk on 1/28/16.
//
//

#import "ANStorageRemover.h"
#import "ANStorageUpdateModel.h"
#import "ANStorageLoader.h"
#import "ANStorageModel.h"
#import "ANStorageSectionModel.h"

@implementation ANStorageRemover

+ (ANStorageUpdateModel*)removeItem:(id)item fromStorage:(ANStorageModel*)storage
{
    ANStorageUpdateModel* update = [ANStorageUpdateModel new];
    NSIndexPath* indexPath = [ANStorageLoader indexPathForItem:item inStorage:storage];
    
    if (indexPath)
    {
        ANStorageSectionModel* section = [ANStorageLoader sectionAtIndex:(NSUInteger)indexPath.section inStorage:storage];
        [section removeItemAtIndex:(NSUInteger)indexPath.row];
        [update addDeletedIndexPaths:@[indexPath]];
    }
    else
    {
        NSLog(@"ANStorage: item to delete: %@ was not found", item);
    }
    return update;
}

+ (ANStorageUpdateModel*)removeItemsAtIndexPaths:(NSArray*)indexPaths fromStorage:(ANStorageModel*)storage
{
    ANStorageUpdateModel* update = [ANStorageUpdateModel new];
    for (NSIndexPath* indexPath in indexPaths)
    {
        id object = [ANStorageLoader itemAtIndexPath:indexPath inStorage:storage];
        if (object)
        {
            ANStorageSectionModel* section = [ANStorageLoader sectionAtIndex:(NSUInteger)indexPath.section
                                                                   inStorage:storage];
            [section removeItemAtIndex:(NSUInteger)indexPath.row];
            [update addDeletedIndexPaths:@[indexPath]];
        }
        else
        {
            NSLog(@"ANStorage: item to delete was not found at indexPath : %@ ", indexPath);
        }
    }
    return update;
}

+ (ANStorageUpdateModel*)removeItems:(NSArray *)items fromStorage:(ANStorageModel*)storage
{
    ANStorageUpdateModel* update = [ANStorageUpdateModel new];
    NSMutableArray* indexPaths = [NSMutableArray array];
    
    [items enumerateObjectsUsingBlock:^(id item, NSUInteger idx, BOOL *stop) {
        
        NSIndexPath* indexPath = [ANStorageLoader indexPathForItem:item inStorage:storage];
        if (indexPath)
        {
            ANStorageSectionModel* section = [storage sectionAtIndex:(NSUInteger)indexPath.section];
            [section removeItemAtIndex:(NSUInteger)indexPath.row];
        }
    }];
    
    [update addDeletedIndexPaths:indexPaths];
    return update;
}

+ (ANStorageUpdateModel*)removeAllItemsFromStorage:(ANStorageModel*)storage
{
    ANStorageUpdateModel* update = [ANStorageUpdateModel new];
    if ([storage sections].count)
    {
        [storage removeAllSections];
        update.isRequireReload = YES;
    }
    return update;
}

+ (ANStorageUpdateModel*)removeSections:(NSIndexSet*)indexSet fromStorage:(ANStorageModel*)storage
{
    __block ANStorageUpdateModel* update = [ANStorageUpdateModel new];
    
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (storage.sections.count > idx)
        {
            [storage removeSectionAtIndex:idx];
            [update addDeletedSectionIndex:idx];
        }
    }];
    return update;
}

@end
