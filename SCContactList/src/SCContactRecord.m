//
//  SCContactRecord.m
//  SCContactList
//
//  Created by Sam de Freyssinet on 7/23/12.
//  Copyright (c) 2012 Sittercity, Inc. All rights reserved.
//

#import "SCContactList.h"

@implementation SCContactRecord

@synthesize ABRecordID = _ABRecordID;

#pragma mark - SCContactRecord lifecycle methods

- (id)initWithABRecordID:(ABRecordID)recordID
{
    self = [self init];
    
    if (self)
    {
        self.ABRecordID = recordID;
    }
    
    return self;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.ABRecordID = kABRecordInvalidID;
        
        [self initializeKeyValueObserving:[self objectKeysToObserve]
                                  options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld];
        
        [self _resetState];
    }
    
    return self;
}

- (void)dealloc
{
    [_changesToModel release];
        
    [self deinitializeKeyValueObserving:[self objectKeysToObserve]];
    
    [super dealloc];
}

#pragma mark - SCContactRecord state methods

- (BOOL)recordExistsInDatabase
{
    return (self.ABRecordID > kABRecordInvalidID);
}

- (NSDictionary *)changesRequiringPersistence
{
    return [[_changesToModel copy] autorelease];
}

- (BOOL)hasChanges
{
    NSLog(@"Recorded changes: %@, %i in state: %i", _changesToModel, [_changesToModel count], ([_changesToModel count] > 0));
    return ([_changesToModel count] > 0);
}

- (BOOL)isSaved
{
    NSLog(@"%@ record exists: %i has changes: %i", self, [self recordExistsInDatabase], [self hasChanges]);
    
    return ([self recordExistsInDatabase] && ! [self hasChanges]);
}

- (void)_resetState
{
    if (_changesToModel != nil)
    {
        [_changesToModel release];
    }

    _changesToModel = [[NSMutableDictionary alloc] initWithCapacity:20];
}

#pragma mark - Key/Value Observing Methods

- (NSArray *)objectKeysToObserve
{
    return [NSArray array];
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
    if (record == NULL)
    {
        return;
    }
        
    for (int i = 0; i < count; i += 1)
    {
        ABPropertyID property = properties[i];
        SEL accessorMethod    = accessorMethods[i];
        id propertyValue      = nil;

        if (property < 0)
        {
            continue;
        }
                
        if (ABPersonGetTypeOfProperty(property) & kABMultiValueMask)
        {
            propertyValue = (id)[self mutableDictionaryFromMultiValueProperty:property record:record];
        }
        else
        {
            
            CFTypeRef valueRef = ABRecordCopyValue(record, property);
            
            if (valueRef != NULL)
            {
                propertyValue = [(id)valueRef autorelease];
            }            
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
    
    NSMutableArray *propertyArray = [[[(NSArray *)ABMultiValueCopyArrayOfAllValues(propertyMultiValue) autorelease] mutableCopy] autorelease];
    int arrayCount                = [propertyArray count];
    NSMutableArray *keys          = [NSMutableArray arrayWithCapacity:arrayCount];
    
    for (int i = 0; i < arrayCount; i += 1)
    {
        if (propertyMultiValue != NULL)
        {
            NSString *arrayKey = [(NSString *)ABMultiValueCopyLabelAtIndex(propertyMultiValue, i) autorelease];
            
            if (arrayKey != nil)
            {
                [keys addObject:arrayKey];
            }
            else if (arrayKey == nil && property == kABPersonEmailProperty)
            {
                [keys addObject:[NSString stringWithFormat:@"email%i", i]];
            }
            else
            {
                if (i < [propertyArray count])
                {
                    //Address Book keys MAY be nil/null - this permits those values to remain in the final MutableDictionary
                    [keys addObject:kSCContactRecordKeyForUnkeyedEntry];
                }
            }
        }
    }
    
    CFRelease(propertyMultiValue);
    
    // Sanity check
    if ([propertyArray count] == [keys count])
    {
        dictionary = [NSMutableDictionary dictionaryWithObjects:propertyArray
                                                        forKeys:keys];
    }
    else
    {
        dictionary = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    
    return dictionary;
}

#pragma mark - SCContactRecordPersistence Methods

- (BOOL)readFromRecordRef:(ABRecordRef *)recordRef error:(NSError **)error
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"%@ must be used from instances of SCContactPerson or SCContactGroup", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (ABRecordRef)addressBook:(ABAddressBookRef)addressBook getABRecordWithID:(ABRecordID)recordID
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"%@ must be used from instances of SCContactPerson or SCContactGroup", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (BOOL)createRecord:(ABRecordID)recordID error:(NSError **)error
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"%@ must be used from instances of SCContactPerson or SCContactGroup", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (BOOL)readRecord:(ABRecordID)recordID error:(NSError **)error
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"%@ must be used from instances of SCContactPerson or SCContactGroup", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (BOOL)updateRecord:(ABRecordID)recordID error:(NSError **)error
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"%@ must be used from instances of SCContactPerson or SCContactGroup", NSStringFromSelector(_cmd)]
                                 userInfo:nil];   
}


- (BOOL)deleteRecord:(ABRecordID)recordID error:(NSError **)error
{
    BOOL result = NO;
    
    if (recordID == kABRecordInvalidID)
    {
        return YES;
    }

    CFErrorRef addressBookError  = NULL;
    ABAddressBookRef addressBook = SCAddressBookCreate(NULL, &addressBookError);
    
    if (addressBook == NULL || addressBookError != NULL)
    {
        if (error != NULL)
        {
            *error = (NSError *)addressBookError;
        }
        
        return result;
    }
    
    ABRecordRef record           = [self addressBook:addressBook getABRecordWithID:recordID];
        
    if (record == NULL)
    {
        if (error != NULL)
        {
            NSDictionary *eDict = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Unable to load record %i for deletion", recordID]
                                                              forKey:@"message"];
            
            *error = [NSError errorWithDomain:kSCContactRecord
                                         code:kSCContactRecordDeleteError
                                     userInfo:eDict];
        }
    }
    else
    {
        CFErrorRef deleteError = NULL;
        
        if ( ! ABAddressBookRemoveRecord(addressBook, record, &deleteError))
        {
            if (error != NULL)
            {
                *error = [(NSError *)deleteError autorelease];
            }
        }
        else
        {
            CFErrorRef saveError = NULL;
            
            result = ABAddressBookSave(addressBook, &saveError);
            
            if ( ! result && error != NULL)
            {
                *error = [(NSError *)saveError autorelease];
            }
            else
            {
                result = YES;
                self.ABRecordID = kABRecordInvalidID;
                
                [self _resetState];
            }
        }
    }
    
    CFRelease(addressBook);
    
    return result;
}


@end
