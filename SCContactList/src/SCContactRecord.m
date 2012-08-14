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

#pragma mark - SCContactRecord lifecycle methods

- (id)init
{
    self = [super init];
    
    if (self)
    {
        [self initializeKeyValueObserving:[self objectKeysToObserve]
                                  options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld];
        
        [self _resetState];        
    }
    
    return self;
}

- (void)dealloc
{
    [_changesToModel release];
    
    if (_ABRecord != NULL)
    {
        CFRelease(_ABRecord);
    }
    
    [self deinitializeKeyValueObserving:[self objectKeysToObserve]];
    
    [super dealloc];
}

#pragma mark - SCContactRecord state methods

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

- (NSDictionary *)changesRequiringPersistence
{
    return [[_changesToModel copy] autorelease];
}

- (BOOL)hasChanges
{
    return ([_changesToModel count] > 0);
}

- (BOOL)isSaved
{
    return ([self recordExistsInDatabase] && ! [self hasChanges]);
}

- (void)_resetState
{
    if (_changesToModel != nil)
    {
        [_changesToModel release];
        _changesToModel = [[NSMutableDictionary alloc] initWithCapacity:20];
    }
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
#ifdef DEBUG
    NSLog(@"%@ OBSERVING: %@ = %@", self, keyPath, change);
#endif

    [_changesToModel setObject:change forKey:keyPath];    
}

#pragma mark - SCContactRecord setup methods

- (void)setProperties:(ABPropertyID *)properties
  withAccessorMethods:(SEL *)accessorMethods
           fromRecord:(ABRecordRef)record
   numberOfProperties:(int)count
{
    for (int i = 0; i < count; i += 1)
    {
        ABPropertyID property       = properties[i];
        SEL accessorMethod          = accessorMethods[i];
        id propertyValue            = nil;
        
        if (ABPersonGetTypeOfProperty(property) & kABMultiValueMask)
        {
            propertyValue = (id)[self mutableDictionaryFromMultiValueProperty:property record:record];
        }
        else
        {
            propertyValue = [(id)ABRecordCopyValue(record, property) autorelease];
        }
        
        if (propertyValue)
        {
            [self performSelector:accessorMethod
                       withObject:propertyValue];
        }
    }
}

- (NSMutableDictionary *)mutableDictionaryFromMultiValueProperty:(ABPropertyID)property record:(ABRecordRef)record
{
    NSMutableDictionary *dictionary = nil;
    
    if (property == kABInvalidPropertyType || record == NULL)
    {
        return dictionary;
    }
    
    ABMutableMultiValueRef propertyMultiValue = ABRecordCopyValue(record, property);
    
    if (propertyMultiValue == NULL)
    {
        return dictionary;
    }
    
    NSArray *propertyArray                    = [(NSArray *)ABMultiValueCopyArrayOfAllValues(propertyMultiValue) autorelease];
    int arrayCount                            = [propertyArray count];
    NSMutableArray *keys                      = [NSMutableArray arrayWithCapacity:arrayCount];
    
    for (int i = 0; i < arrayCount; i += 1)
    {
        if (propertyMultiValue != NULL)
        {
            NSString *arrayKey = [(NSString *)ABMultiValueCopyLabelAtIndex(propertyMultiValue, i) autorelease];
            [keys addObject:arrayKey];
        }
    }
    
    CFRelease(propertyMultiValue);
    
    dictionary = [NSMutableDictionary dictionaryWithObjects:propertyArray
                                                    forKeys:keys];
    
    return dictionary;
}

@end
