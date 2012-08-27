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
        if (ABAddressBookSave(addressBook, &addressBookError))
        {
            result = NO;
        }
    }
    
    if (error != NULL && ! result)
    {
        *error = [(NSError *)addressBookError autorelease];
    }
    
    return result;
}

@end

@implementation SCContactGroup

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
        
    if (self && recordID > kABRecordInvalidID)
    {
        if ( ! [self readRecord:recordID error:nil])
        {
            [self release];
            return nil;
        }
    }

    return self;
}

- (id)init
{
    return [self initWithABRecordID:kABRecordInvalidID];
}

- (void)dealloc
{
    [_groupName release];
    [_contacts release];
    
    [super dealloc];
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

- (BOOL)readFromRecordRef:(ABRecordRef *)recordRef error:(NSError **)error
{
    BOOL result = NO;    

    ABPropertyID groupProperties[] = {
        kABGroupNameProperty
    };
    
    SEL groupPropertiesAccessorMethods[] = {
        @selector(setGroupName:)
    };
    
    int groupPropertiesCount = (sizeof(groupProperties) / sizeof(ABPropertyID));
    
    [self setProperties:groupProperties
    withAccessorMethods:groupPropertiesAccessorMethods
             fromRecord:recordRef
     numberOfProperties:groupPropertiesCount];
    
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
    ABAddressBookRef addressBook = [SCContactAddressBook createAddressBookOptions:nil
                                                                            error:&createError];
    
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
    
    ABAddressBookRef addressBook = [SCContactAddressBook createAddressBookOptions:nil error:&readError];
    
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
        result = [self readFromRecordRef:&record error:error];
    }
    
    CFRelease(addressBook);
    
    return result;
}

- (BOOL)updateRecord:(ABRecordID)recordID error:(NSError **)error
{
    BOOL result                  = NO;
    NSError *updateError         = nil;
    ABAddressBookRef addressBook = [SCContactAddressBook createAddressBookOptions:nil
                                                                            error:&updateError];
    
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
