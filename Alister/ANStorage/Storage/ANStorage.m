//
//  ANStorage.m
//  Pods
//
//  Created by Oksana Kovalchuk on 1/28/16.
//
//

#import "ANStorage.h"
#import "ANStorageUpdateOperation.h"
#import "ANStorageUpdateModel.h"
#import "ANStorageLog.h"
#import "ANStorageUpdater.h"
#import "ANStorageRemover.h"
#import "ANStorageLoader.h"
#import "ANStorageModel.h"
#import "ANStorageSectionModel.h"

@interface ANStorage () <ANStorageUpdatableInterface>

@property (nonatomic, assign) BOOL isSearchingType;

@property (nonatomic, strong) ANStorageRemover* remover;
@property (nonatomic, strong) ANStorageUpdater* updater;

/**
 Current storage model that contains all items
 */
@property (nonatomic, strong, nonnull) ANStorageModel* storageModel;

@end

@implementation ANStorage

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _identifier = [[NSUUID UUID] UUIDString];
        
        self.storageModel = [ANStorageModel new];
        
        self.remover = [ANStorageRemover removerWithStorageModel:self.storageModel andUpdateDelegate:nil];
        self.updater = [ANStorageUpdater updaterWithStorageModel:self.storageModel updateDelegate:nil];
    }
    return self;
}

- (void)updateWithAnimationChangeBlock:(ANDataStorageUpdateBlock)block
{
    [self _updateWithBlock:block animatable:YES];
}

- (void)updateWithoutAnimationChangeBlock:(ANDataStorageUpdateBlock)block
{
    [self _updateWithBlock:block animatable:NO];
}

- (void)reloadStorageWithAnimation:(BOOL)isAnimatable
{
    id<ANStorageUpdateEventsDelegate> listController = self.updatesHandler;
    [listController storageNeedsReloadWithIdentifier:self.identifier animated:isAnimatable];
}

- (void)_updateWithBlock:(ANDataStorageUpdateBlock)block animatable:(BOOL)isAnimatable
{
    if (block)
    {
        if (!self.isSearchingType)
        {
            id<ANStorageUpdateEventsDelegate> listController = self.updatesHandler;
            if (listController)
            {
                ANStorageUpdateOperation* updateOperation = nil;
                updateOperation = [ANStorageUpdateOperation operationWithConfigurationBlock:^(ANStorageUpdateOperation* operation) {
                    self.updater.updateDelegate = operation;
                    self.remover.updateDelegate = operation;
                    block(self);
                }];
                
                [listController storageDidPerformUpdate:updateOperation withIdentifier:self.identifier animatable:isAnimatable];
            }
            else
            {
                block(self);
            }
        }
        else
        {
            block(self);
        }
    }
}

- (void)updateHeaderKind:(NSString*)headerKind footerKind:(NSString*)footerKind
{
    [self updateSupplementaryHeaderKind:headerKind];
    [self updateSupplementaryFooterKind:footerKind];
}


#pragma mark - ANStorageRetrivingInterface

- (NSArray*)sections
{
    return [self.storageModel sections];
}

- (id)objectAtIndexPath:(NSIndexPath*)indexPath
{
    return [ANStorageLoader itemAtIndexPath:indexPath inStorage:self.storageModel];
}

- (ANStorageSectionModel*)sectionAtIndex:(NSUInteger)sectionIndex
{
    return [ANStorageLoader sectionAtIndex:sectionIndex inStorage:self.storageModel];
}

- (NSArray*)itemsInSection:(NSUInteger)sectionIndex
{
    return [ANStorageLoader itemsInSection:sectionIndex inStorage:self.storageModel];
}

- (NSIndexPath*)indexPathForItem:(id)item
{
    return [ANStorageLoader indexPathForItem:item inStorage:self.storageModel];
}

- (BOOL)isEmpty
{
    return [self.storageModel isEmpty];
}

- (id)headerModelForSectionIndex:(NSUInteger)index
{
    return [ANStorageLoader supplementaryModelOfKind:self.storageModel.headerKind
                                     forSectionIndex:index
                                           inStorage:self.storageModel];
}

- (id)footerModelForSectionIndex:(NSUInteger)index
{
    return [ANStorageLoader supplementaryModelOfKind:self.storageModel.footerKind
                                     forSectionIndex:index
                                           inStorage:self.storageModel];
}

- (id)supplementaryModelOfKind:(NSString*)kind forSectionIndex:(NSUInteger)sectionIndex
{
    return [ANStorageLoader supplementaryModelOfKind:kind
                                     forSectionIndex:sectionIndex
                                           inStorage:self.storageModel];
}

#pragma mark - Add Items


- (void)addItem:(id)item
{
    [self.updater addItem:item];
}

- (void)addItems:(NSArray*)items
{
    [self.updater addItems:items];
}

- (void)addItem:(id)item toSection:(NSUInteger)sectionIndex
{
    [self.updater addItem:item toSection:sectionIndex];
}

- (void)addItems:(NSArray*)items toSection:(NSUInteger)sectionIndex
{
    [self.updater addItems:items toSection:sectionIndex];
}

- (void)addItem:(id)item atIndexPath:(NSIndexPath*)indexPath
{
    [self.updater addItem:item atIndexPath:indexPath];
}


#pragma mark - Reloading

- (void)reloadItem:(id)item
{
    [self.updater reloadItem:item];
}

- (void)reloadItems:(id)items
{
    [self.updater reloadItems:items];
}


#pragma mark - Removing

- (void)removeItem:(id)item
{
    [self.remover removeItem:item];
}

- (void)removeItemsAtIndexPaths:(NSSet*)indexPaths
{
    [self.remover removeItemsAtIndexPaths:indexPaths];
}

- (void)removeItems:(NSSet*)items
{
    [self.remover removeItems:items];
}

- (void)removeAllItemsAndSections
{
    [self.remover removeAllItemsAndSections];
}

- (void)removeSections:(NSIndexSet*)indexSet
{
    [self.remover removeSections:indexSet];
}


#pragma mark - Replacing / Moving

- (void)replaceItem:(id)itemToReplace withItem:(id)replacingItem
{
    [self.updater replaceItem:itemToReplace withItem:replacingItem];
}

- (void)moveItemWithoutUpdateFromIndexPath:(NSIndexPath*)fromIndexPath toIndexPath:(NSIndexPath*)toIndexPath
{
    [self.updater moveItemWithoutUpdateFromIndexPath:fromIndexPath toIndexPath:toIndexPath];
}

- (void)moveItemFromIndexPath:(NSIndexPath*)fromIndexPath toIndexPath:(NSIndexPath*)toIndexPath
{
    [self.updater moveItemFromIndexPath:fromIndexPath toIndexPath:toIndexPath];
}


#pragma mark - Supplementaries

- (void)updateSupplementaryHeaderKind:(NSString*)headerKind
{
    self.storageModel.headerKind = headerKind;
}

- (void)updateSupplementaryFooterKind:(NSString*)footerKind
{
    self.storageModel.footerKind = footerKind;
}

- (NSString*)footerSupplementaryKind
{
    return self.storageModel.footerKind;
}

- (NSString*)headerSupplementaryKind
{
    return self.storageModel.headerKind;
}

- (void)updateSectionHeaderModel:(id)headerModel forSectionIndex:(NSInteger)sectionIndex
{
    [self.updater updateSectionHeaderModel:headerModel forSectionIndex:sectionIndex];
}

- (void)updateSectionFooterModel:(id)footerModel forSectionIndex:(NSInteger)sectionIndex
{
    [self.updater updateSectionFooterModel:footerModel forSectionIndex:sectionIndex];
}

@end
