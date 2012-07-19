//
//  SCContactGroupTests.m
//  SCContactList
//
//  Created by Sam de Freyssinet on 7/19/12.
//  Copyright (c) 2012 Sittercity, Inc. All rights reserved.
//

#import "SCContactGroupTests.h"
#import "SCContactGroup.h"

@implementation SCContactGroupTests

- (void)setUp
{
    [super setUp];

    ABAddressBookRef addressBook = ABAddressBookCreate();
    
    if (addressBook == NULL)
    {
        STFail(@"Failed to create an address book");
    }
    
    int groupSize = 5;
    
    for (int i = 0; i < groupSize; i += 1)
    {
        NSString *groupName = [NSString stringWithFormat:@"group%i", i];
        
        ABRecordRef group = ABGroupCreate();
        ABRecordSetValue(group, kABGroupNameProperty, groupName, NULL);
        
        CFErrorRef addError = NULL;
        
        ABAddressBookAddRecord(addressBook, group, &addError);
        
        if (addError != NULL)
        {
            STFail(@"Error adding group to AddressBook");
        }
        
        CFRelease(group);
    }
    
    CFErrorRef saveError = NULL;

    ABAddressBookSave(addressBook, &saveError);

    if (saveError != NULL)
    {
        STFail(@"Error saving the groups to address book");
    }

    CFRelease(addressBook);
}

- (void)tearDown
{
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef groups            = ABAddressBookCopyArrayOfAllGroups(addressBook);
    int groupsCount              = CFArrayGetCount(groups);
    
    for (int i = 0; i < groupsCount; i += 1)
    {
        ABRecordRef group = CFArrayGetValueAtIndex(groups, i);
        
        NSLog(@"Group ID : %i", ABRecordGetRecordID(group));
        
        ABAddressBookRemoveRecord(addressBook, group, NULL);
    }
    
    CFErrorRef saveError = NULL;
    
    ABAddressBookSave(addressBook, &saveError);
    
    if (saveError != NULL)
    {
        STFail(@"Error saving the groups to address book");
    }
    
    CFRelease(groups);
    CFRelease(addressBook);
    
    [super tearDown];
}

- (void)testContactGroupWithID
{
    NSNumber *badGroupID = nil;
    STAssertNil([SCContactGroup contactGroupWithID:badGroupID], @"ContactGroupWithID should be nil when bad ID supplied");
    
    NSNumber *badGroupIDNotNil = [NSNumber numberWithInt:-1];
    STAssertNil([SCContactGroup contactGroupWithID:badGroupIDNotNil], @"ContactGroupWithID should be nil when bad ID real int supplied");
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef groups            = ABAddressBookCopyArrayOfAllGroups(addressBook);
    ABRecordRef group0           = CFArrayGetValueAtIndex(groups, 0);
    
    NSNumber *goodGroupID0     = [NSNumber numberWithInt:ABRecordGetRecordID(group0)];
    SCContactGroup *goodGroup0 = [SCContactGroup contactGroupWithID:goodGroupID0];
        
    STAssertNotNil(goodGroup0, @"goodGroup0 should not be nil");
    STAssertTrue([goodGroup0 isKindOfClass:[SCContactGroup class]], @"goodGroup0 should be of type SCContactGroup, got: %@", [goodGroup0 class]);
    
    CFRelease(addressBook);
    CFRelease(groups);
}

- (void)testGroupName
{
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef groups            = ABAddressBookCopyArrayOfAllGroups(addressBook);
    ABRecordRef group0           = CFArrayGetValueAtIndex(groups, 0);

    NSString *group0name = ABRecordCopyValue(group0, kABGroupNameProperty);
    
    SCContactGroup *group = [SCContactGroup contactGroupWithID:[NSNumber numberWithInt:ABRecordGetRecordID(group0)]];
    
    STAssertTrue([group.groupName isEqualToString:group0name], @"Group name should equal '%@', got: %@", group0name, group.groupName);
    
    [group0name release];
    
    CFRelease(addressBook);
    CFRelease(groups);
}

@end
