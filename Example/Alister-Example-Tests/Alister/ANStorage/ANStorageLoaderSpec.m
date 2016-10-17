//
//  ANStorageLoaderSpec.m
//  Alister-Example
//
//  Created by Oksana Kovalchuk on 10/14/16.
//  Copyright © 2016 Oksana Kovalchuk. All rights reserved.
//

#import <Alister/ANStorageLoader.h>
#import <Alister/ANStorageModel.h>
#import <Alister/ANStorageUpdater.h>
#import <Alister/ANStorageSectionModel.h>

SpecBegin()

__block ANStorageModel* storage = nil;

beforeEach(^{
    storage = [ANStorageModel new];
});


describe(@"itemAtIndexPath:", ^{
    
    __block NSString* item = @"test";
    
    beforeEach(^{
        [ANStorageUpdater addItem:item toStorage:storage];
    });
    
    it(@"correctly returns item", ^{
        id result = [ANStorageLoader itemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] inStorage:storage];
        expect(result).equal(item);
    });
    
    it(@"no assert if indexPath is nil", ^{
        void(^block)() = ^() {
            [ANStorageLoader itemAtIndexPath:nil inStorage:storage];
        };
        expect(block).notTo.raiseAny();
    });
    
    it(@"no assert if storage is nil", ^{
        void(^block)() = ^() {
            [ANStorageLoader itemAtIndexPath:[NSIndexPath indexPathWithIndex:0] inStorage:nil];
        };
        expect(block).notTo.raiseAny();
    });
});


describe(@"sectionAtIndex:", ^{
    
    it(@"returns nil if section not exist", ^{
        expect([ANStorageLoader sectionAtIndex:2 inStorage:storage]).to.beNil();
    });
    
    it(@"returns correct section if it exists", ^{
        NSString* item = @"test";
        [ANStorageUpdater addItem:item toStorage:storage];
        ANStorageSectionModel* sectionModel = [ANStorageLoader sectionAtIndex:0 inStorage:storage];
        
        expect(sectionModel.objects).contain(item);
    });
    
    it(@"no assert if index is out of bounds", ^{
        void(^block)() = ^() {
            [ANStorageLoader sectionAtIndex:2 inStorage:storage];
        };
        expect(block).notTo.raiseAny();
    });
    
    it(@"no assert if index is NSNotFound", ^{
        void(^block)() = ^() {
            [ANStorageLoader sectionAtIndex:NSNotFound inStorage:storage];
        };
        expect(block).notTo.raiseAny();
    });
    
    it(@"no assert if storage is nil", ^{
        void(^block)() = ^() {
            [ANStorageLoader sectionAtIndex:1 inStorage:nil];
        };
        expect(block).notTo.raiseAny();
    });
    
    it(@"no assert if index is negative", ^{
        void(^block)() = ^() {
            [ANStorageLoader sectionAtIndex:-1 inStorage:storage];
        };
        expect(block).notTo.raiseAny();
    });
});


describe(@"itemsInSection:", ^{
    
    it(@"returns specified items", ^{
        NSArray* items = @[@"test", @"test2"];
        [ANStorageUpdater addItems:items toStorage:storage];
        
        expect([ANStorageLoader itemsInSection:0 inStorage:storage]).equal(items);
    });
    
    it(@"no assert if index is out of bounds", ^{
        void(^block)() = ^() {
            [ANStorageLoader itemsInSection:1 inStorage:storage];
        };
        expect(block).notTo.raiseAny();
    });
    
    it(@"no assert if storage is nil", ^{
        void(^block)() = ^() {
            [ANStorageLoader itemsInSection:1 inStorage:nil];
        };
        expect(block).notTo.raiseAny();
    });
    
    it(@"no assert it index is NSNotFound", ^{
        void(^block)() = ^() {
            [ANStorageLoader itemsInSection:NSNotFound inStorage:storage];
        };
        expect(block).notTo.raiseAny();
    });
    
    it(@"no assert if index is negative", ^{
        void(^block)() = ^() {
            [ANStorageLoader itemsInSection:-1 inStorage:storage];
        };
        expect(block).notTo.raiseAny();
    });
});


describe(@"indexPathForItem:", ^{
    
    __block NSString* item = @"test";
    
    beforeEach(^{
        [ANStorageUpdater addItem:item toStorage:storage];
    });
    
    it(@"returns nil if item not exists in storageModel", ^{
        expect([ANStorageLoader indexPathForItem:@"some" inStorage:storage]).to.beNil();
    });
    
    it(@"returns specified item", ^{
        expect([ANStorageLoader indexPathForItem:item inStorage:storage]).equal([NSIndexPath indexPathForRow:0 inSection:0]);
    });
    
    it(@"no assert if item is nil", ^{
        void(^block)() = ^() {
            [ANStorageLoader indexPathForItem:nil inStorage:storage];
        };
        expect(block).notTo.raiseAny();
    });
    
    it(@"no assert if storage is nil", ^{
        void(^block)() = ^() {
            [ANStorageLoader indexPathForItem:[NSIndexPath indexPathWithIndex:0] inStorage:nil];
        };
        expect(block).notTo.raiseAny();
    });
});

SpecEnd