//
//  ANListControllerMappingService.m
//  ANStorage
//
//  Created by Oksana Kovalchuk on 2/2/16.
//  Copyright © 2016 ANODA. All rights reserved.
//

#import "ANListControllerMappingService.h"

static NSString* const kANDefaultCellKind = @"kANDefaultCellKind";

@interface ANListControllerMappingService ()

@property (nonatomic, strong) NSMutableDictionary* viewModelToIndentifierMap;

@end

@implementation ANListControllerMappingService

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.viewModelToIndentifierMap = [NSMutableDictionary new];
    }
    return self;
}

- (NSString*)identifierForViewModelClass:(Class)keyClass
{
    return [self identifierForViewModelClass:keyClass kind:kANDefaultCellKind];
}

- (NSString*)identifierForViewModelClass:(Class)viewModelClass kind:(NSString*)kind
{
    NSString* identifier = nil;
    if (kind && viewModelClass)
    {
        NSMutableDictionary* dict = self.viewModelToIndentifierMap[kind];
        if (!dict)
        {
            self.viewModelToIndentifierMap[kind] = [NSMutableDictionary dictionary];
        }
        identifier = [self _identifierFromViewModelClass:viewModelClass map:self.viewModelToIndentifierMap[kind]];
    }
    return identifier;
}


#pragma mark - Private

- (NSString*)_identifierFromViewModelClass:(Class)keyClass map:(NSMutableDictionary*)map
{
    NSString* identifier = nil;
    
    if (keyClass)
    {
        identifier = [map objectForKey:keyClass];
        
        if (!identifier)
        {
            // No mapping found for this key class, but it may be a subclass of another object that does
            // have a mapping, so let's see what we can find.
            Class superClass = nil;
            for (Class class in map.allKeys)
            {
                // We want to find the lowest node in the class hierarchy so that we pick the lowest ancestor
                // in the hierarchy tree.
                if ([keyClass isSubclassOfClass:class] && (!superClass || [class isSubclassOfClass:superClass]))
                {
                    superClass = class;
                }
            }
            
            if (superClass)
            {
                identifier = [map objectForKey:superClass];
                
                // Add this subclass to the map so that next time this result is instant.
                [map setObject:identifier forKey:keyClass];
            }
        }
        
        if (!identifier)
        {
            // We couldn't find a mapping at all so let's add a new mapping.
            identifier = NSStringFromClass(keyClass);
            [map setObject:identifier forKey:keyClass];
        }
        else if (identifier == [NSNull class])
        {
            // Don't return null mappings.
            identifier = nil;
        }
    }
    return identifier;
}

@end
