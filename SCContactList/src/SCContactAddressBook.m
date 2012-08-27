//
//  SCContactList.m
//  SCContactList
//
//  Created by Sam de Freyssinet on 7/18/12.
//  Copyright (c) 2012 Sittercity, Inc. All rights reserved.
//

#import "SCContactList.h"

@implementation SCContactAddressBook

+ (SCContactAddressBook *)currentList
{
    static SCContactAddressBook *list = nil;

    if (list == nil)
    {
        list = [[SCContactAddressBook alloc] init];
    }

    return list;
}


+ (ABAddressBookRef)createAddressBookOptions:(NSDictionary *)options error:(NSError **)error
{
    ABAddressBookRef addressBook = NULL;

    if (ABAddressBookCreateWithOptions != NULL)
    {
        // SDK 6.0 is available
        CFErrorRef createAddressBookError = NULL;
        CFDictionaryRef optionsCDict      = (CFDictionaryRef)options;
        
        addressBook = ABAddressBookCreateWithOptions(optionsCDict, &createAddressBookError);
        
        if (createAddressBookError != NULL && error != NULL)
        {
            *error = [(NSError *)createAddressBookError autorelease];
        }
    }
    else
    {
        addressBook = ABAddressBookCreate();        
    }
    
    return addressBook;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {

    }
    
    return self;
}

#pragma mark - Interrogation Methods

- (BOOL)addressBookHasChanges
{
    BOOL result = NO;
    ABAddressBookRef addressBook = [SCContactAddressBook createAddressBookOptions:nil error:nil];

    result = ABAddressBookHasUnsavedChanges(addressBook);
    
    CFRelease(addressBook);
    
    return result;
}

- (NSArray *)getAllContacts
{
    ABAddressBookRef addressBook  = [SCContactAddressBook createAddressBookOptions:nil error:nil];

    NSArray *ABRecordArray        = [(NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook) autorelease];
    int contactCount              = [ABRecordArray count];
    
    NSMutableArray *contactsArray = [NSMutableArray arrayWithCapacity:contactCount];
    
    for (int i = 0; i < contactCount; i += 1)
    {
        ABRecordRef record      = [ABRecordArray objectAtIndex:i];
        SCContactPerson *person = [[[SCContactPerson alloc] init] autorelease];

        if ([person readFromRecordRef:&record error:nil])
        {
            [contactsArray addObject:[person autorelease]];
        }
    }
    
    CFRelease(addressBook);
    
    return contactsArray;
}

- (NSArray *)getAllGroups
{
    ABAddressBookRef addressBook = [SCContactAddressBook createAddressBookOptions:nil error:nil];
    
    NSArray *ABRecordArray       = [(NSArray *)ABAddressBookCopyArrayOfAllGroups(addressBook) autorelease];
    int groupCount               = [ABRecordArray count];
    
    NSMutableArray *groupsArray  = [NSMutableArray arrayWithCapacity:groupCount];
    
    for (int i = 0; i < groupCount; i += 1)
    {
        ABRecordRef record    = [ABRecordArray objectAtIndex:i];
        SCContactGroup *group = [[SCContactGroup alloc] init];

        if ([group readFromRecordRef:&record error:nil])
        {
            [groupsArray addObject:[group autorelease]];
        }
    }
    
    CFRelease(addressBook);
    
    return groupsArray;
}

#pragma mark - Persistence Methods

- (BOOL)persist:(NSError **)error
{
    BOOL result = NO;
    
    if ( ! [self addressBookHasChanges])
    {
        return YES;
    }

    ABAddressBookRef addressBook = [SCContactAddressBook createAddressBookOptions:nil error:nil];
    CFErrorRef saveError         = NULL;
    result                       = ABAddressBookSave(addressBook, &saveError);

    if ( ! result && (error != NULL))
    {
        *error = [(NSError *)saveError autorelease];
    }
    
    CFRelease(addressBook);
    
    return result;
}

- (void)revert
{
    ABAddressBookRef addressBook = [SCContactAddressBook createAddressBookOptions:nil error:nil];
    ABAddressBookRevert(addressBook);
    CFRelease(addressBook);
}



- (id)createGroupWithName:(NSString *)name
                overwrite:(BOOL)overwrite
{
    return nil;
}


- (void)dealloc
{
    [super dealloc];
}

@end
