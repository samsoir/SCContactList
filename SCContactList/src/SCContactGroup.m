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

- (void)setABGroupRecord:(ABRecordRef)group
{
    if (_groupRecord != group)
    {
        if (_groupRecord != NULL)
        {
            CFRelease(_groupRecord);
        }
        
        CFRetain(group);
        _groupRecord = group;
    }
}

@end

@implementation SCContactGroup

@synthesize groupID     = _groupID;
@synthesize groupName   = _groupName;
@synthesize contacts    = _contacts;
@synthesize groupRecord = _groupRecord;

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
                
        NSString *groupName    = (NSString *)ABRecordCopyValue(group, kABGroupNameProperty);
        
        self.groupID           = groupID;
        self.groupName         = [groupName autorelease];

        [self setABGroupRecord:group];
        
        CFRelease(addressBook);

        _groupExistsInDatabase = YES;
        _groupHasChanges       = NO;
    }
    
    return self;
}

- (id)init
{
    self = [super init];

    if (self)
    {
        _contacts               = [[NSMutableSet alloc] initWithCapacity:10];
        _groupExistsInDatabase  = NO;
        _groupHasChanges        = NO;
        
        ABRecordRef groupRecord = ABGroupCreate();
        
        [self setABGroupRecord:groupRecord];
        
        CFRelease(groupRecord);
    }

    return self;
}

- (void)dealloc
{
    [_groupID release];
    [_groupName release];
    [_contacts release];
    
    if (_groupRecord != NULL)
    {
        CFRelease(_groupRecord);
    }
    
    [super dealloc];
}

#pragma mark - SCContactGroup methods

- (void)setGroupName:(NSString *)groupName
{
    if (groupName != _groupName)
    {
        [_groupName release];
        _groupName = [groupName retain];
        
        if (_groupExistsInDatabase)
        {
            _groupExistsInDatabase = NO;
        }
        
        _groupHasChanges = YES;
    }
}

- (BOOL)save:(NSError **)error
{
    BOOL result = NO;

    
    
    return result;
}

- (BOOL)isSaved
{
    return (_groupExistsInDatabase && ( ! [self hasChanges]));
}

- (BOOL)hasChanges
{
    return _groupHasChanges;
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

@end
