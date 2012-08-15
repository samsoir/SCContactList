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

- (void)testCreateGroupWithName
{
    NSString *groupName = @"testGroup0";
    
    SCContactGroup *group = [SCContactGroup createGroupWithName:groupName];
    
    STAssertNotNil(group, @"Group should not be nil");
    STAssertTrue([group isKindOfClass:[SCContactGroup class]], @"Group should be instance of SCContactGroup, got: %@", [group class]);
    STAssertTrue([group.groupName isEqualToString:groupName], @"Group name '%@' should equal '%@'", group.groupName, groupName);
    STAssertTrue([group.contacts count] < 1, @"Group contacts should be empty");
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

- (void)testAddContactRecord
{
    SCContactGroup *group = [SCContactGroup createGroupWithName:@"testAddRecordGroup"];
    NSObject *testContact = [[[NSObject alloc] init] autorelease];
    
    STAssertTrue(([group.contacts count] == 0), @"Number of contacts should equal 0, got: %i", [group.contacts count]);
    
    [group addContactRecord:testContact];
    
    STAssertTrue(([group.contacts count] == 1), @"Number of contacts should equal 1, got: %i", [group.contacts count]);
}

- (void)testIsSaved
{
    SCContactGroup *newGroup = [SCContactGroup createGroupWithName:@"testAddRecordGroup"];

    STAssertFalse([newGroup isSaved], @"Group should be saved");
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef groups            = ABAddressBookCopyArrayOfAllGroups(addressBook);
    ABRecordRef group0           = CFArrayGetValueAtIndex(groups, 0);
        
    SCContactGroup *groupExisting = [SCContactGroup contactGroupWithID:[NSNumber numberWithInt:ABRecordGetRecordID(group0)]];

    STAssertTrue([groupExisting isSaved], @"Group should be saved");
    
    groupExisting.groupName = @"newGroupName";
  
    STAssertFalse([groupExisting isSaved], @"Group should not be saved");
}

- (void)testHasChanges
{
    SCContactGroup *newGroup = [[SCContactGroup alloc] init];
    STAssertFalse([newGroup hasChanges], @"Group should not have any changes");
    
    newGroup.groupName = @"newGroupName";
    STAssertTrue([newGroup hasChanges], @"Group should have changes");
}

- (void)testSave
{
    SCContactGroup *newGroup = [SCContactGroup createGroupWithName:@"testNewGroup"];
    
    NSError *saveError = nil;
    
    STAssertTrue([newGroup save:&saveError], @"Should be able to save a new group");
    STAssertNil(saveError, @"There should be no save error saving a new group");
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef groups            = ABAddressBookCopyArrayOfAllGroups(addressBook);
    int groupsCount              = CFArrayGetCount(groups);
    
    BOOL newGroupFound           = NO;
    
    for (int i = 0; i < groupsCount; i += 1)
    {
        ABRecordRef group   = CFArrayGetValueAtIndex(groups, i);
        NSString *groupName = ABRecordCopyValue(group, kABGroupNameProperty);
                
        if ([groupName isEqualToString:newGroup.groupName])
        {
            newGroupFound = YES;
            break;
        }
        
        [groupName release];
    }
    
    STAssertTrue(newGroupFound, @"The new group should be found in the address book");
    STAssertFalse([newGroup hasChanges], @"The new group should not have changes");
    
    CFRelease(groups);
    CFRelease(addressBook);
    
}

- (void)testRemove
{
    SCContactGroup *existingGroup = [SCContactGroup contactGroupWithName:@"group1"];
    
    STAssertTrue([existingGroup isSaved], @"Group 1 should be saved!");
    
    NSError *removeError = nil;
    
    STAssertTrue([existingGroup remove:&removeError], @"Group should remove itself");
    STAssertNil(removeError, @"There should be no remove error when deleting a group");

    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef groups            = ABAddressBookCopyArrayOfAllGroups(addressBook);
    int groupsCount              = CFArrayGetCount(groups);
    
    BOOL existingGroupFound      = NO;
    
    for (int i = 0; i < groupsCount; i += 1)
    {
        ABRecordRef group   = CFArrayGetValueAtIndex(groups, i);
        NSString *groupName = ABRecordCopyValue(group, kABGroupNameProperty);
                
        if ([groupName isEqualToString:existingGroup.groupName])
        {
            existingGroupFound = YES;
            break;
        }
        
        [groupName release];
    }

    STAssertFalse(existingGroupFound, @"The existing group should not be found in the address book");
    STAssertFalse([existingGroup hasChanges], @"The existing group should not have changes");
    STAssertFalse([existingGroup isSaved], @"The Existing group should not be saved");
    
    CFRelease(groups);
    CFRelease(addressBook);
}

@end
