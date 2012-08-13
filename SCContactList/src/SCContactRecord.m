//
//  SCContactRecord.m
//  SCContactList
//
//  Created by Sam de Freyssinet on 7/23/12.
//  Copyright (c) 2012 Sittercity, Inc. All rights reserved.
//

#import "SCContactRecord.h"

@implementation SCContactRecord

@synthesize ABRecord = _ABRecord;

- (id)init
{
    self = [super init];
    
    if (self)
    {
        [self initializeKeyValueObserving:[self objectKeysToObserve]
                                  options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld];
    }
    
    return self;
}

- (void)setABRecord:(ABRecordRef)record
{
    if (_ABRecord != record)
    {
        if (_ABRecord != NULL)
        {
            CFRelease(_ABRecord);
        }
        
        CFRetain(record);
        _ABRecord = record;
    }
}

- (NSNumber *)recordID
{
    NSNumber *recordID = nil;
    
    if (_ABRecord != NULL)
    {
        recordID = [NSNumber numberWithInt:ABRecordGetRecordID(_ABRecord)];
    }
    
    return recordID;
}

- (BOOL)recordExistsInDatabase
{
    BOOL result = NO;

    if (self.ABRecord)
    {
        result = (ABRecordGetRecordID(self.ABRecord) != kABRecordInvalidID);
    }

    return result;
}

- (BOOL)reloadModelFromRecord:(ABRecordRef)record
{
    return YES;
}

#pragma mark - Key/Value Observing Methods

- (NSArray *)objectKeysToObserve
{
    return [NSArray arrayWithObjects:@"ABRecord", nil];
}

- (void)initializeKeyValueObserving:(NSArray *)keysToObserve options:(int)options
{
    for (NSString *key in keysToObserve)
    {
        [self addObserver:self
               forKeyPath:key
                  options:options
                  context:[self class]];
        
    }
}

- (void)deinitializeKeyValueObserving:(NSArray *)keysToUnobserve
{
    for (NSString *key in keysToUnobserve)
    {
        [self removeObserver:self
                  forKeyPath:key
                     context:[self class]];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    NSLog(@"OBSERVING: %@ = %@", keyPath, change);
    
    _recordHasChanges = YES;
}

#pragma mark - SCContactRecord lifecycle methods

- (void)dealloc
{
    if (_ABRecord != NULL)
    {
        CFRelease(_ABRecord);
    }
    
    [self deinitializeKeyValueObserving:[self objectKeysToObserve]];
    
    [super dealloc];
}

@end
