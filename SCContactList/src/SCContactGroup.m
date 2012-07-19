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

@synthesize groupID   = _groupID;
@synthesize groupName = _groupName;

#pragma mark - SCContactGroup lifecycle methods

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
    
    self = [super init];

        
    if (self)
    {
        _groupExistsInDatabase = NO;
        
        // Create conditional SDK ref here
        ABAddressBookRef addressBook = ABAddressBookCreate();
        ABRecordID addressBookID     = [groupID intValue];
        
        ABRecordRef group = ABAddressBookGetGroupWithRecordID(addressBook, addressBookID);
        
        if (group == NULL || ABRecordGetRecordType(group) != kABGroupType)
        {
            CFRelease(addressBook);
            return nil;
        }
                
        _groupExistsInDatabase = YES;
        NSString *groupName    = ABRecordCopyValue(group, kABGroupNameProperty);
        
        self.groupID           = groupID;
        self.groupName         = [groupName autorelease];

        CFRelease(addressBook);
    }
    
    return self;
}

- (void)dealloc
{
    [_groupID release];
    [_groupName release];
    
    [super dealloc];
}

#pragma mark - SCContactGroup methods


#pragma mark - SCContactRecord methods

- (void)addContactRecord:(id)record
{
    
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
