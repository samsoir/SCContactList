//
//  SCContactGroup.m
//  SCContactList
//
//  Created by Sam de Freyssinet on 7/19/12.
//  Copyright (c) 2012 Sittercity, Inc. All rights reserved.
//

#import "SCContactGroup.h"

@implementation SCContactGroup(Private)

+ (NSNumber *)findGroupIDByName:(NSString *)groupName
                        inArray:(CFArrayRef)array
{
    NSNumber *groupID = nil;
    int groupCount    = CFArrayGetCount(array);
    
    if (groupCount > 0)
    {
        for (int i = 0; i < groupCount; i += 1)
        {
            ABRecordRef group         = CFArrayGetValueAtIndex(array, i);
            NSString *groupRecordName = ABRecordCopyValue(group, kABGroupNameProperty);
            
            if ([groupName isEqualToString:groupRecordName])
            {
                groupID = [NSNumber numberWithInt:ABRecordGetRecordID(group)];
            }
            
            CFRelease(groupRecordName);
            
            if (groupID != nil)
            {
                break;
            }
        }        
    }

    return groupID;
}

@end

@implementation SCContactGroup

@synthesize groupID     = _groupID;
@synthesize groupName   = _groupName;
@synthesize contacts    = _contacts;

#pragma mark - SCContactGroup lifecycle methods

+ (SCContactGroup *)createGroupWithName:(NSString *)groupName
{
    SCContactGroup *newGroup = [[SCContactGroup alloc] init];    
    newGroup.groupName       = groupName;
    
    return [newGroup autorelease];
}

+ (SCContactGroup *)contactGroupWithName:(NSString *)groupName
{
    SCContactGroup *contactGroup = nil;
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef groups            = ABAddressBookCopyArrayOfAllGroups(addressBook);
    NSNumber *groupID            = [self findGroupIDByName:groupName
                                                   inArray:groups];
    
    if (groupID != nil)
    {
        contactGroup = [self contactGroupWithID:groupID];
    }

    CFRelease(addressBook);
    CFRelease(groups);

    return contactGroup;
}

+ (SCContactGroup *)contactGroupWithID:(NSNumber *)groupID
{
    return [[[SCContactGroup alloc] initWithGroupID:groupID] autorelease];
}

- (id)initWithGroupID:(NSNumber *)groupID
{
    if (groupID == nil)
    {
        return nil;
    }
    
    self = [self init];

        
    if (self)
    {
        ABAddressBookRef addressBook = ABAddressBookCreate();
        ABRecordID addressBookID     = [groupID intValue];
        
        ABRecordRef group = ABAddressBookGetGroupWithRecordID(addressBook, addressBookID);
        
        if (group == NULL || ABRecordGetRecordType(group) != kABGroupType)
        {
            CFRelease(addressBook);
            return nil;
        }
                
        self.groupID   = groupID;
        self.groupName = [(NSString *)ABRecordCopyValue(group, kABGroupNameProperty) autorelease];

        [self setABRecord:group];
        
        CFRelease(addressBook);
        
        [self _resetState];
    }
    
    return self;
}

- (id)init
{
    self = [super init];

    if (self)
    {
        ABRecordRef groupRecord = ABGroupCreate();
        _contacts               = [[NSMutableSet alloc] initWithCapacity:10];
        
        [self setABRecord:groupRecord];
        
        CFRelease(groupRecord);
    }

    return self;
}

- (void)dealloc
{
    [_groupID release];
    [_groupName release];
    [_contacts release];
    
    [super dealloc];
}

#pragma mark - SCContactGroup methods

- (BOOL)save:(NSError **)error
{
    BOOL result                  = NO;
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFErrorRef setNameError      = NULL;
    
    if ( ! ABRecordSetValue(self.ABRecord, kABGroupNameProperty, self.groupName, &setNameError))
    {
        if (error != NULL)
        {
            *error = (NSError *)setNameError;

            CFRelease(addressBook);
            
            return result;
        }
    }
    
    CFErrorRef addGroupError = NULL;
    
    if ( ! ABAddressBookAddRecord(addressBook, self.ABRecord, &addGroupError))
    {
        if (error != NULL)
        {
            *error = (NSError *)addGroupError;
        }
    }
    else
    {
        CFErrorRef saveError = NULL;
        
        if ( ! ABAddressBookSave(addressBook, &saveError))
        {
            if (error != NULL)
            {
                *error = (NSError *)saveError;
            }
        }
        else
        {
            result       = YES;
            self.groupID = [NSNumber numberWithInt:ABRecordGetRecordID(self.ABRecord)];
        }
    }
    
    CFRelease(addressBook);
    
    [self _resetState];

    return result;
}

- (BOOL)remove:(NSError **)error
{
    BOOL result                  = NO;
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFErrorRef removeError       = NULL;

    if ( ! ABAddressBookRemoveRecord(addressBook, self.ABRecord, &removeError))
    {
        if (error != NULL)
        {
            *error = (NSError *)removeError;
        }
    }
    else
    {
        ABRecordRef groupRecord = ABGroupCreate();
        [self setABRecord:groupRecord];
        
        CFRelease(groupRecord);

        self.groupID   = nil;
        self.groupName = nil;
        result         = YES;
    }
    
    CFRelease(addressBook);
    
    [self _resetState];

    return result;
}

#pragma mark - Key/Value Observing Methods

- (NSArray *)objectKeysToObserve
{
    NSArray *keysToObserve = [NSArray arrayWithObjects:@"groupName", nil];
    
    NSMutableArray *parentKeysToObserve = [[[super objectKeysToObserve] mutableCopy] autorelease];
    
    [parentKeysToObserve addObjectsFromArray:keysToObserve];
    
    return parentKeysToObserve;
}


#pragma mark - SCContactRecord methods

- (void)addContactRecord:(id)record
{
    [_contacts addObject:record];
}

- (void)removeContact:(id)record
{
    
}

- (void)addContactRecords:(NSSet *)records
{
    
}

- (void)removeContactRecords:(NSSet *)records
{
    
}

#pragma mark - SCContactRecordPersistence Methods

- (BOOL)loadRecord:(ABRecordRef)record error:(NSError **)error
{
    BOOL result = YES;
    
    ABPropertyID groupProperties[] = {
        kABGroupNameProperty
    };
    
    SEL groupPropertiesAccessorMethods[] = {
        @selector(setGroupName:)
    };
    
    int groupPropertiesCount = (sizeof(groupProperties) / sizeof(ABPropertyID));
    
    [self setProperties:groupProperties
    withAccessorMethods:groupPropertiesAccessorMethods
             fromRecord:record
     numberOfProperties:groupPropertiesCount];
    
    [self _resetState];
    
    return result;
}

- (BOOL)saveRecord:(ABRecordRef)record error:(NSError **)error
{
    BOOL result = NO;
    
    if ( ! [self hasChanges])
    {
        result = YES;
        return result;
    }
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFErrorRef setNameError      = NULL;
    
    if ( ! ABRecordSetValue(record, kABGroupNameProperty, self.groupName, &setNameError))
    {
        if (error != NULL)
        {
            *error = (NSError *)setNameError;
            
            CFRelease(addressBook);
            
            return result;
        }
    }
    
    CFErrorRef addGroupError = NULL;
    
    if ( ! ABAddressBookAddRecord(addressBook, self.ABRecord, &addGroupError))
    {
        if (error != NULL)
        {
            *error = (NSError *)addGroupError;
        }
    }
    else
    {
        CFErrorRef saveError = NULL;
        
        if ( ! ABAddressBookSave(addressBook, &saveError))
        {
            if (error != NULL)
            {
                *error = (NSError *)saveError;
            }
        }
        else
        {
            result       = YES;
            self.groupID = [NSNumber numberWithInt:ABRecordGetRecordID(self.ABRecord)];
        }
    }
    
    CFRelease(addressBook);
    
    [self _resetState];
    
    return result;
}

- (BOOL)deleteRecord:(ABRecordRef)record error:(NSError **)error
{
    return NO;
}

@end
