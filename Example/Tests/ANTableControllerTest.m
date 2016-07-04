//
//  ANListControllerTest.m
//  Alister
//
//  Created by Oksana Kovalchuk on 7/2/16.
//  Copyright © 2016 Oksana Kovalchuk. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ANTableController.h"
#import "ANStorage.h"
#import <Expecta/Expecta.h>
#import "ANTestTableCell.h"
#import "ANTestTableHeaderFooter.h"

@interface ANTableControllerTest : XCTestCase

@property (nonatomic, strong) ANStorage* storage;
@property (nonatomic, strong) UITableView* tw;
@property (nonatomic, strong) ANTableController* listController;
@property (nonatomic) dispatch_group_t dispatchGroup;

@end

@implementation ANTableControllerTest

- (void)performGroupedBlock:(dispatch_block_t)block
{
    
    dispatch_group_enter(self.dispatchGroup);
    block();
    dispatch_group_leave(self.dispatchGroup);
}

- (void)setUp
{
    [super setUp];
    
    self.dispatchGroup = dispatch_group_create();
    
    self.storage = [ANStorage new];
    self.tw = [UITableView new];
    self.listController = [ANTableController controllerWithTableView:self.tw];
    [self.listController attachStorage:self.storage];
}

- (void)tearDown
{//TODO: zoombie
    self.listController = nil;
    self.tw = nil;
    self.storage = nil;
    
    [super tearDown];
}

- (void)testAttachStorage
{
    //given
    ANTableController* listController = [ANTableController new];
    ANStorage* storage = [ANStorage new];
    //when
    [listController attachStorage:storage];
    //then
    expect(listController.currentStorage).notTo.beNil;
    expect(listController.currentStorage).equal(storage);
}

- (void)testConfigureCellsWithBlockRetriveFromTabelView
{
    //given
   
    //when
    [self.listController configureCellsWithBlock:^(id<ANListControllerReusableInterface> configurator) {
        [configurator registerCellClass:[UITableViewCell class] forSystemClass:[NSString class]];
    }];
    //then
    UITableViewCell* cell = [self.tw dequeueReusableCellWithIdentifier:NSStringFromClass([NSString class])];
    expect(cell).notTo.beNil();
    expect(cell).beKindOf([UITableViewCell class]);
}

- (void)testConfigureCellsWithBlockRetriveFromTableController
{
    //given
    NSString* testModel = @"Mock";
    
    [self.listController configureCellsWithBlock:^(id<ANListControllerReusableInterface> configurator) {
        [configurator registerCellClass:[ANTestTableCell class] forSystemClass:[NSString class]];
    }];
    
    //when
    XCTestExpectation *expectation = [self expectationWithDescription:@"testConfigureCellsWithBlockRetriveFromTableController called"];
    
    __weak typeof(self) welf = self;
    [self.listController addUpdatesFinsihedTriggerBlock:^{
        [expectation fulfill];
        ANTestTableCell* cell = (id)[welf.listController tableView:welf.tw
                                             cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        expect(cell).notTo.beNil();
        expect(cell.model).equal(testModel);
        expect(cell.textLabel.text).equal(testModel);
    }];
    
    [self.storage updateWithoutAnimationWithBlock:^(id<ANStorageUpdatableInterface> storageController) {
        [storageController addItem:testModel];
    }];
    
    //then
    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

- (void)testConfigureItemSelectionBlock
{
    //given
    NSString* testModel = @"Mock";
    
    [self.listController configureCellsWithBlock:^(id<ANListControllerReusableInterface> configurator) {
        [configurator registerCellClass:[ANTestTableCell class] forSystemClass:[NSString class]];
    }];
    
    //when
    XCTestExpectation *expectation = [self expectationWithDescription:@"configureItemSelectionBlock called"];
    __weak typeof(self) welf = self;
    
    [self.listController configureItemSelectionBlock:^(id model, NSIndexPath *indexPath) {
        [expectation fulfill];
        expect(model).equal(testModel);
        expect(indexPath.row).equal(0);
        expect(indexPath.section).equal(0);
    }];
    
    [self.listController addUpdatesFinsihedTriggerBlock:^{
        [welf.listController tableView:welf.tw
               didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }];
    
    [self.storage updateWithoutAnimationWithBlock:^(id<ANStorageUpdatableInterface> storageController) {
        [storageController addItem:testModel];
    }];
    
    //then
    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

- (void)testUpdateConfigurationModelWithBlockSetToNO
{
    //given
    XCTestExpectation *expectation = [self expectationWithDescription:@"updateConfigurationModelWithBlock called"];
    
    NSNumber* testModel = @123; // not a string
    self.tw.sectionHeaderHeight = 30;
    
    [self.listController configureCellsWithBlock:^(id<ANListControllerReusableInterface> configurator) {
        [configurator registerHeaderClass:[ANTestTableHeaderFooter class] forSystemClass:[NSNumber class]];
    }];
    
    [self.storage updateWithoutAnimationWithBlock:^(id<ANStorageUpdatableInterface> storageController) {
        [storageController setSectionHeaderModel:testModel forSectionIndex:0];
    }];
    
    __weak typeof(self) welf = self;
    [self.listController addUpdatesFinsihedTriggerBlock:^{
        UIView* header = [welf.listController tableView:welf.tw viewForHeaderInSection:0];
        expect(header).willNot.beNil(); // separate on 2 tests
    }];
    
    //when
    [self.listController updateConfigurationModelWithBlock:^(ANListControllerConfigurationModel *configurationModel) {
        [expectation fulfill];
        configurationModel.shouldHandleKeyboard = NO;
        configurationModel.shouldDisplayHeaderOnEmptySection = NO;
    }];
    
    //then
    UIView* header = [self.tw headerViewForSection:0];
    [self waitForExpectationsWithTimeout:0.1 handler:nil];
    expect(self.listController.keyboardHandler).to.beNil();
    expect(header).beNil();
}

- (void)testTitleForHeaderInSectionWithNSStringSectionModel
{
    //given
    NSString* testModel = @"Mock";
    self.tw.sectionHeaderHeight = 30;
    
    [self.listController configureCellsWithBlock:^(id<ANListControllerReusableInterface> configurator) {
        [configurator registerHeaderClass:[ANTestTableHeaderFooter class] forSystemClass:[NSString class]];
    }];
    
    [self.storage updateWithoutAnimationWithBlock:^(id<ANStorageUpdatableInterface> storageController) {
        [storageController setSectionHeaderModel:testModel forSectionIndex:0];
    }];
    
    UIView* header = [self.listController tableView:self.tw viewForHeaderInSection:0];
    NSString* titleHeader = [self.listController tableView:self.tw titleForHeaderInSection:0];
    
    //then

    expect(titleHeader).notTo.beNil();
    expect(header).beNil();
}

- (void)testAddUpdatesFinsihedTriggerBlock
{
    //given
    NSString* testModel = @"Mock";
    
    [self.listController configureCellsWithBlock:^(id<ANListControllerReusableInterface> configurator) {
        [configurator registerCellClass:[ANTestTableCell class] forSystemClass:[NSString class]];
    }];
    
    //when
    XCTestExpectation *expectation = [self expectationWithDescription:@"testAddUpdatesFinsihedTriggerBlock called"];
    
    [self.listController addUpdatesFinsihedTriggerBlock:^{
        [expectation fulfill];
    }];
    
    [self.storage updateWithoutAnimationWithBlock:^(id<ANStorageUpdatableInterface> storageController) {
        [storageController addItem:testModel];
    }];
    
    //then
    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

- (void)testAttachSearchBar
{
    //given
    UISearchBar* searchBar = [UISearchBar new];
    //when
    [self.listController attachSearchBar:searchBar];
    //then
    expect(self.listController.searchBar).notTo.beNil();
    expect(self.listController.searchBar).equal(searchBar);
}

- (void)testControllerWithTableView
{
    //when
    ANTableController* tc = [ANTableController controllerWithTableView:self.tw];
    //then
    expect(tc.tableView).notTo.beNil();
    expect(tc.tableView).equal(self.tw);
}

- (void)testInitWithTableView
{
    //when
    ANTableController* tc = [[ANTableController alloc] initWithTableView:self.tw];
    //then
    expect(tc.tableView).notTo.beNil();
    expect(tc.tableView).equal(self.tw);
}

@end