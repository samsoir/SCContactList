//
//  SCContactList.m
//  SCContactList
//
//  Created by Sam de Freyssinet on 7/18/12.
//  Copyright (c) 2012 Sittercity, Inc. All rights reserved.
//

#import "SCContactList.h"

NSString *const SCContactAddressBookAuthorizationNotification = @"com.sittercity.SCContactList:SCContactAddressBookAuthorizationNotification";

@implementation SCContactAddressBook

#pragma mark - AddressBook Access

+ (void)requestAddressBookAuthorization:(void (^)(BOOL granted, NSError *error))completionHandler
{
    if (ABAddressBookGetAuthorizationStatus == NULL)
    {
        NSLog(@"iOS 5.1 Api detected");
        completionHandler(YES, nil);
        return;
    }
    else
    {
        NSLog(@"iOS 6.0 Api detected");
        ABAddressBookRef addressBook = SCAddressBookCreate(NULL, NULL);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            completionHandler((BOOL)granted, (NSError *)error);
        });
        
        CFRelease(addressBook);
    }
}

+ (SCContactListAuthorizationStatus)addressBookAuthorizationStatus
{
    SCContactListAuthorizationStatus status = kSCContactListAuthorizationStatusNotDetermined;

    if (ABAddressBookGetAuthorizationStatus == NULL)
    {
        NSLog(@"iOS 5.1 Api detected");
        status = kSCContactListAuthorizationStatusAuthorized;
    }
    else
    {
        NSLog(@"iOS 6.0 Api detected");
        ABAuthorizationStatus authStatus        = ABAddressBookGetAuthorizationStatus();
        
        switch (authStatus)
        {
            case kABAuthorizationStatusAuthorized:
                status = kSCContactListAuthorizationStatusAuthorized;
                break;
            case kABAuthorizationStatusDenied:
                status = kSCContactListAuthorizationStatusDenied;
                break;
            case kABAuthorizationStatusNotDetermined:
                status = kSCContactListAuthorizationStatusNotDetermined;
                break;
            case kABAuthorizationStatusRestricted:
                status = kSCContactListAuthorizationStatusRestricted;
                break;
        }
    }

    return status;
}


#pragma mark - Interrogation Methods

- (BOOL)addressBookHasChanges
{
    BOOL result = NO;

    ABAddressBookRef addressBook = SCAddressBookCreate(NULL, NULL);
    
    if (addressBook == NULL)
    {
        return result;
    }

    result = ABAddressBookHasUnsavedChanges(addressBook);
    
    CFRelease(addressBook);
    
    return result;
}

- (NSArray *)getAllContacts
{
    ABAddressBookRef addressBook = SCAddressBookCreate(NULL, NULL);
    
    if (addressBook == NULL)
    {
        return nil;
    }

    NSArray *ABRecordArray        = [(NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook) autorelease];
    int contactCount              = [ABRecordArray count];
    
    NSMutableArray *contactsArray = [NSMutableArray arrayWithCapacity:contactCount];
    
    for (int i = 0; i < contactCount; i += 1)
    {
        ABRecordRef record      = [ABRecordArray objectAtIndex:i];
        SCContactPerson *person = [[[SCContactPerson alloc] init] autorelease];

        if ([person readFromRecordRef:record error:nil])
        {
            [contactsArray addObject:person];
        }
    }
    
    CFRelease(addressBook);
    
    return contactsArray;
}

- (NSArray *)getAllGroups
{
    ABAddressBookRef addressBook = SCAddressBookCreate(NULL, NULL);
    
    if (addressBook == NULL)
    {
        return nil;
    }
    
    NSArray *ABRecordArray       = [(NSArray *)ABAddressBookCopyArrayOfAllGroups(addressBook) autorelease];
    int groupCount               = [ABRecordArray count];
    
    NSMutableArray *groupsArray  = [NSMutableArray arrayWithCapacity:groupCount];
    
    for (int i = 0; i < groupCount; i += 1)
    {
        ABRecordRef record    = [ABRecordArray objectAtIndex:i];
        SCContactGroup *group = [[[SCContactGroup alloc] init] autorelease];

        if ([group readFromRecordRef:&record error:nil])
        {
            [groupsArray addObject:group];
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
    
    CFErrorRef saveError         = NULL;
    result                       = ABAddressBookSave(addressBook, &saveError);

    if ( ! result && (error != NULL))
    {
        *error = (NSError *)saveError;
    }
    
    CFRelease(addressBook);
    
    return result;
}

- (void)revert
{
    ABAddressBookRef addressBook = SCAddressBookCreate(NULL, NULL);
    
    if (addressBook == NULL)
    {
        return;
    }
    
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
