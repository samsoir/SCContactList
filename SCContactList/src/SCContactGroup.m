//
//  SCContactGroup.m
//  SCContactList
//
//  Created by Sam de Freyssinet on 7/19/12.
//  Copyright (c) 2012 Sittercity, Inc. All rights reserved.
//

#import "SCContactList.h"

@implementation SCContactGroup(Private)

+ (ABRecordID)findGroupIDByName:(NSString *)groupName
                        inArray:(CFArrayRef)array
{
    ABRecordID groupID = kABRecordInvalidID;
    int groupCount    = CFArrayGetCount(array);
    
    if (groupCount > 0)
    {
        for (int i = 0; i < groupCount; i += 1)
        {
            ABRecordRef group         = CFArrayGetValueAtIndex(array, i);
            NSString *groupRecordName = [(NSString *)ABRecordCopyValue(group, kABGroupNameProperty) autorelease];
            
            if ([groupName isEqualToString:groupRecordName])
            {
                groupID = ABRecordGetRecordID(group);
            }            
            
            if (groupID > kABRecordInvalidID)
            {
                break;
            }
        }        
    }

    return groupID;
}

- (BOOL)persistRecord:(ABRecordRef)record addressBook:(ABAddressBookRef)addressBook error:(NSError **)error
{
    BOOL result                 = NO;
    CFErrorRef addressBookError = NULL;
    
    if (ABRecordSetValue(record, kABGroupNameProperty, self.groupName, &addressBookError))
    {
        // Add records
        NSArray *contactRecords = [_contacts allObjects];
        CFErrorRef addError     = NULL;
        
        for (SCContactPerson *addPerson in contactRecords)
        {
            if ( ! [addPerson recordExistsInDatabase])
            {
                NSError *createRecordError = nil;
                
                if ( ! [addPerson createRecord:addPerson.ABRecordID error:&createRecordError])
                {
                    if (error != NULL)
                    {
                        *error = createRecordError;
                    }
                    
                    return result;
                }
            }
            
            ABRecordRef personRecord = [addPerson addressBook:addressBook getABRecordWithID:addPerson.ABRecordID];
            
            if ( ! ABGroupAddMember(record, personRecord, &addressBookError))
            {
                if (error != NULL)
                {
                    *error = [(NSError *)addError autorelease];
                }
                
                return result;
            }
        }
        
        NSArray *removeRecords = [_removedContacts allObjects];
        CFErrorRef removeError = NULL;
        
        for (SCContactPerson *removePerson in removeRecords)
        {
            if ( ! [removePerson recordExistsInDatabase])
            {
                continue;
            }
            
            ABRecordRef removePersonRecord = [removePerson addressBook:addressBook getABRecordWithID:removePerson.ABRecordID];
            
            if ( ! ABGroupRemoveMember(record, removePersonRecord, &removeError))
            {
                if (error != NULL)
                {
                    *error = [(NSError *)removeError autorelease];
                }
                
                return result;
            }
        }
        
        result = ABAddressBookSave(addressBook, &addressBookError);
        
        if (result)
        {
            _contactsLoaded  = YES;
        }
    }

    if ( ! result && error != NULL)
    {
        *error = [(NSError *)addressBookError autorelease];
    }
    
    return result;
}

@end

@implementation SCContactGroup

@synthesize groupName   = _groupName;

#pragma mark - SCContactGroup lifecycle methods

+ (SCContactGroup *)createGroupWithName:(NSString *)groupName
{
    SCContactGroup *newGroup = [[SCContactGroup alloc] initWithABRecordID:kABRecordInvalidID];
    newGroup.groupName       = groupName;
    
    return [newGroup autorelease];
}

+ (SCContactGroup *)contactGroupWithName:(NSString *)groupName
{
    SCContactGroup *contactGroup = nil;
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef groups            = ABAddressBookCopyArrayOfAllGroups(addressBook);
    ABRecordID groupID           = [self findGroupIDByName:groupName
                                                   inArray:groups];
    
    if (groupID > kABRecordInvalidID)
    {
        contactGroup = [self contactGroupWithID:groupID];
    }

    CFRelease(addressBook);
    CFRelease(groups);

    return contactGroup;
}

+ (SCContactGroup *)contactGroupWithID:(ABRecordID)groupID
{
    return [[[SCContactGroup alloc] initWithABRecordID:groupID] autorelease];
}

- (id)initWithABRecordID:(ABRecordID)recordID
{
    self = [super initWithABRecordID:recordID];
        
    if (self)
    {
        _contacts        = [[NSMutableSet alloc] initWithCapacity:SCContactGroupMutableSetCapacity];
        _removedContacts = [[NSMutableSet alloc] initWithCapacity:SCContactGroupMutableSetCapacity];
        _contactsLoaded  = NO;
        _contactsChanged = NO;
        
        if (recordID > kABRecordInvalidID)
        {
            if ( ! [self readRecord:recordID error:nil])
            {
                return nil;
            }            
        }
    }

    NSLog(@"Contact Group initiated: %@", self);
    
    return self;
}

- (void)dealloc
{
    [_groupName release];
    [_contacts release];
    [_removedContacts release];
    
    [super dealloc];
}

#pragma mark - SCContactGroup Key/Value Observing

- (NSArray *)objectKeysToObserve
{
    NSArray *keysToObserve = [NSArray arrayWithObjects:@"groupName", nil];
    
    NSMutableArray *parentKeysToObserve = [[[super objectKeysToObserve] mutableCopy] autorelease];
    
    [parentKeysToObserve addObjectsFromArray:keysToObserve];
    
    return parentKeysToObserve;
}

#pragma mark - SCContactRecord properties

- (BOOL)hasChanges
{
    BOOL result = [super hasChanges];
    
    if (result && [self contactsLoaded])
    {
        result = [self contactsChanged];
    }
    
    return result;
}

- (BOOL)isSaved
{
    BOOL result = [super isSaved];
    
    if (result && [self contactsLoaded])
    {
        result = [self contactsChanged];
    }
    
    return result;
}

#pragma mark - SCContactRecord methods

- (void)_resetState
{
    [super _resetState];
    
    if (_contacts != nil)
    {
        [_contacts release];
    }
    
    if (_removedContacts != nil)
    {
        [_removedContacts release];
    }
    
    _contacts        = [[NSMutableSet alloc] initWithCapacity:SCContactGroupMutableSetCapacity];
    _removedContacts = [[NSMutableSet alloc] initWithCapacity:SCContactGroupMutableSetCapacity];
    _contactsLoaded  = NO;
    _contactsChanged = NO;
}

- (BOOL)contactsLoaded
{
    return _contactsLoaded;
}

- (BOOL)contactsChanged
{
    return _contactsChanged;
}

- (BOOL)loadContacts:(NSError **)error
{
    BOOL result = NO;
    
    if (self.ABRecordID > kABRecordInvalidID)
    {
        ABAddressBookRef addressBook = ABAddressBookCreate();
        ABRecordRef groupRecordRef   = [self addressBook:addressBook getABRecordWithID:self.ABRecordID];
        
        NSArray *groupContacts = [(NSArray *)ABGroupCopyArrayOfAllMembers(groupRecordRef) autorelease];
        int groupContactsCount = [groupContacts count];

        NSMutableArray *groupPersonRecords = [NSMutableArray arrayWithCapacity:groupContactsCount];
        
        for (int i = 0; i < groupContactsCount; i += 1)
        {
            ABRecordRef personRecordRef = [groupContacts objectAtIndex:i];
            
            SCContactPerson *personRecord = [[SCContactPerson alloc] initWithABRecordID:kABRecordInvalidID];
            
            NSError *readError = nil;
            
            if ( ! [personRecord readFromRecordRef:personRecordRef error:&readError])
            {
                if (error != NULL)
                {
                    *error = readError;
                }
                
                break;
            }
            else
            {
                [groupPersonRecords insertObject:personRecord atIndex:i];
            }
        }
        
        [_contacts addObjectsFromArray:groupPersonRecords];
        
        CFRelease(addressBook);
        
        result = YES;
        _contactsLoaded = YES;
    }
    else
    {
        result = YES;
        _contactsLoaded = YES;
    }
    
    return result;
}

- (NSSet *)filterContactsSetWithPredicate:(NSPredicate *)predicate
{
    return [_contacts filteredSetUsingPredicate:predicate];
}

- (NSSet *)contacts
{
    return _contacts;
}

- (void)addContactRecord:(SCContactPerson *)record
{
    [_contacts addObject:record];
    [_removedContacts removeObject:record];
    
    _contactsChanged = YES;
}

- (void)removeContact:(SCContactPerson *)record
{
    [_contacts removeObject:record];
    [_removedContacts addObject:record];

    _contactsChanged = YES;
}

- (void)addContactRecords:(NSSet *)records
{
    NSArray *recordsArray = [records allObjects];

    [_contacts addObjectsFromArray:recordsArray];

    for (SCContactPerson *record in recordsArray)
    {
        [_removedContacts removeObject:records];
    }

    _contactsChanged = YES;
}

- (void)removeContactRecords:(NSSet *)records
{
    NSArray *recordsArray = [records allObjects];
    
    [_removedContacts addObjectsFromArray:recordsArray];
    
    for (SCContactPerson *record in recordsArray)
    {
        [_contacts removeObject:records];
    }    

    _contactsChanged = YES;
}

#pragma mark - SCContactRecordPersistence Methods

- (BOOL)readFromRecordRef:(ABRecordRef)recordRef error:(NSError **)error
{
    BOOL result = NO;    

    CFTypeRef groupName = ABRecordCopyValue(recordRef, kABGroupNameProperty);
    self.groupName      = (NSString *)groupName;
    
    CFRelease(groupName);
    
    self.ABRecordID = ABRecordGetRecordID(recordRef);
    
    result = YES;
    
    [self _resetState];
        
    return result;
}

- (ABRecordRef)addressBook:(ABAddressBookRef)addressBook getABRecordWithID:(ABRecordID)recordID
{
    return ABAddressBookGetGroupWithRecordID(addressBook, recordID);
}

- (BOOL)createRecord:(ABRecordID)recordID error:(NSError **)error
{
    BOOL result                  = NO;
    NSError *createError         = nil;
    ABAddressBookRef addressBook = ABAddressBookCreate();
    
    if (createError && error != NULL)
    {
        *error = createError;
    }
    
    if ( ! addressBook || createError != nil)
    {
        return result;
    }
    else
    {
        ABRecordRef newGroupRecord = ABGroupCreate();
        CFErrorRef addError        = NULL;
        
        if ( ! ABAddressBookAddRecord(addressBook, newGroupRecord, &addError))
        {
            if (addError && error != NULL)
            {
                *error = (NSError *)addError;
            }
        }
        else
        {
            result = [self persistRecord:newGroupRecord
                             addressBook:addressBook
                                   error:error];
            
            if (result)
            {
                self.ABRecordID = ABRecordGetRecordID(newGroupRecord);
                [self _resetState];
            }
        }
        
        CFRelease(newGroupRecord);
    }
    
    CFRelease(addressBook);
    
    return result;
}

- (BOOL)readRecord:(ABRecordID)recordID error:(NSError **)error
{
    BOOL result = NO;
    
    NSError *readError = nil;
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    
    if ( ! addressBook && error != NULL)
    {
        *error = readError;
    }
    
    if ( ! addressBook)
    {
        return result;
    }
    
    ABRecordRef record = [self addressBook:addressBook getABRecordWithID:recordID];
    
    if ( ! record)
    {
        if (error != NULL)
        {
            NSDictionary *eDict = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Updable to load SCContactGroup from recordID: %i", recordID]
                                                              forKey:@"message"];
            *error = [NSError errorWithDomain:kSCContactRecord
                                         code:kSCContactRecordReadError
                                     userInfo:eDict];
        }
        
        self.ABRecordID = kABRecordInvalidID;
    }
    else
    {
        result = [self readFromRecordRef:record error:error];
    }
    
    CFRelease(addressBook);
    
    return result;
}

- (BOOL)updateRecord:(ABRecordID)recordID error:(NSError **)error
{
    BOOL result                  = NO;
    NSError *updateError         = nil;
    ABAddressBookRef addressBook = ABAddressBookCreate();
    
    if (updateError && error != NULL)
    {
        *error = updateError;
    }
    
    if ( ! addressBook || updateError != nil)
    {
        return result;
    }
    else
    {
        ABRecordRef record = [self addressBook:addressBook getABRecordWithID:self.ABRecordID];
        
        result = [self persistRecord:record
                         addressBook:addressBook
                               error:error];
    }
    
    CFRelease(addressBook);
    
    return result;
}

- (BOOL)deleteRecord:(ABRecordID)recordID error:(NSError **)error
{
    return [super deleteRecord:recordID error:error];
}

@end
