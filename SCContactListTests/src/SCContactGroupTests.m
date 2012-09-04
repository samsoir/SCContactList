//
//  SCContactGroupTests.m
//  SCContactList
//
//  Created by Sam de Freyssinet on 7/19/12.
//  Copyright (c) 2012 Sittercity, Inc. All rights reserved.
//

#import "SCContactGroupTests.h"
#import "SCContactList.h"

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
    STAssertTrue([[group contacts] count] < 1, @"Group contacts should be empty");
}

- (void)testContactGroupWithID
{
    STAssertNotNil([SCContactGroup contactGroupWithID:kABRecordInvalidID], @"ContactGroupWithID should not be nil when bad ID supplied");
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef groups            = ABAddressBookCopyArrayOfAllGroups(addressBook);
    ABRecordRef group0           = CFArrayGetValueAtIndex(groups, 0);
    
    ABRecordID group0recordID    = ABRecordGetRecordID(group0);
    
    SCContactGroup *goodGroup0 = [SCContactGroup contactGroupWithID:group0recordID];
        
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
    
    ABRecordID group0recordID    = ABRecordGetRecordID(group0);
    
    SCContactGroup *group = [SCContactGroup contactGroupWithID:group0recordID];
    
    STAssertTrue([group.groupName isEqualToString:group0name], @"Group name should equal '%@', got: %@", group0name, group.groupName);
    
    [group0name release];
    
    CFRelease(addressBook);
    CFRelease(groups);
}

- (void)testAddContactRecord
{
    SCContactGroup *group = [SCContactGroup createGroupWithName:@"testAddRecordGroup"];
    SCContactPerson *testContact = [[[SCContactPerson alloc] init] autorelease];
    
    STAssertTrue(([[group contacts] count] == 0), @"Number of contacts should equal 0, got: %i", [[group contacts] count]);
    
    [group addContactRecord:testContact];
    
    STAssertTrue(([[group contacts] count] == 1), @"Number of contacts should equal 1, got: %i", [[group contacts] count]);
}

- (void)testIsSaved
{
    SCContactGroup *newGroup = [SCContactGroup createGroupWithName:@"testAddRecordGroup"];

    STAssertFalse([newGroup isSaved], @"Group should be saved");
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef groups            = ABAddressBookCopyArrayOfAllGroups(addressBook);
    ABRecordRef group0           = CFArrayGetValueAtIndex(groups, 0);
        
    SCContactGroup *groupExisting = [SCContactGroup contactGroupWithID:ABRecordGetRecordID(group0)];

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
    
    STAssertTrue([newGroup createRecord:newGroup.ABRecordID error:&saveError], @"Should be able to save a new group");
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


- (void)testDeleteRecordError
{
    ABAddressBookRef addressBook = ABAddressBookCreate();
    
    // Tear-down code here.
    NSArray *recordsInserted = [(NSArray *)ABAddressBookCopyArrayOfAllGroups(addressBook) autorelease];
    
    ABRecordRef randomRecord = [recordsInserted objectAtIndex:0];
    ABRecordID recordID      = ABRecordGetRecordID(randomRecord);
    
    SCContactGroup *subject = [[[SCContactGroup alloc] initWithABRecordID:recordID] autorelease];
    
    NSError *deleteError = nil;
    
    STAssertTrue([subject deleteRecord:subject.ABRecordID error:&deleteError], @"Deleting a valid model should return true");
    
    NSArray *recordsRemaining = [(NSArray *)ABAddressBookCopyArrayOfAllGroups(addressBook) autorelease];
    int count = [recordsRemaining count];
    
    for (int i = 0; i < count; i += 1)
    {
        ABRecordRef record = recordsRemaining[i];
        
        if (ABRecordGetRecordID(record) == recordID)
        {
            STFail(@"Found record ID :%i that should be deleted", recordID);
        }
    }
    
    CFRelease(addressBook);
}

- (void)testDeleteRecordNotSaved
{
    NSString *testDeleteGroupName = @"Test Group Name";
    
    SCContactGroup *subject = [[[SCContactGroup alloc] init] autorelease];
    subject.groupName = testDeleteGroupName;
    
    NSError *deleteError = nil;
    
    STAssertTrue([subject deleteRecord:subject.ABRecordID error:&deleteError], @"Deleting a valid model should return YES");
    STAssertNil(deleteError, @"Delete error should be nil");
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    NSArray *groups = [(NSArray *)ABAddressBookCopyArrayOfAllGroups(addressBook) autorelease];

    int count = [groups count];
    
    for (int i = 0; i < count; i += 1)
    {
        ABRecordRef record = groups[i];
        NSString *foundGroupName = [(NSString *)ABRecordCopyValue(record, kABGroupNameProperty) autorelease];
        
        if ([foundGroupName isEqualToString:testDeleteGroupName])
        {
            STFail(@"Found group name :%@ that should be deleted", testDeleteGroupName);
        }
    }
    
    CFRelease(addressBook);
}

- (void)testContactsLoadedOnEmptyGroup
{
    SCContactGroup *subject = [[[SCContactGroup alloc] init] autorelease];
    
    STAssertFalse([subject contactsLoaded], @"ContactsLoaded should be NO");
    STAssertTrue([subject loadContacts:nil], @"LoadContacts should be YES");
    
    int contactsCount = [[subject contacts] count];
    
    STAssertEquals(contactsCount, 0, @"Subject contacts should equal 0");
    STAssertTrue([subject contactsLoaded], @"ContactsLoaded should be YES");
}

- (void)testContactsLoadedOnExistingGroup
{
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef groups            = ABAddressBookCopyArrayOfAllGroups(addressBook);
    int groupsCount              = CFArrayGetCount(groups);

    if (groupsCount < 1)
    {
        STFail(@"Unable to load group from address book");
    }

    ABRecordRef loadedGroup  = CFArrayGetValueAtIndex(groups, 0);
    ABRecordID loadedGroupID = ABRecordGetRecordID(loadedGroup);
    
    NSString *testUserFirstName = @"Test";
    NSString *testUserLastName  = @"User";
    
    ABRecordRef groupContact = ABPersonCreate();
    ABRecordSetValue(groupContact, kABPersonFirstNameProperty, testUserFirstName, NULL);
    ABRecordSetValue(groupContact, kABPersonLastNameProperty, testUserLastName, NULL);
    ABAddressBookAddRecord(addressBook, groupContact, NULL);
    ABGroupAddMember(loadedGroup, groupContact, NULL);
    ABAddressBookSave(addressBook, NULL);
    
    SCContactGroup *subject = [[[SCContactGroup alloc] initWithABRecordID:loadedGroupID] autorelease];

    STAssertFalse([subject contactsLoaded], @"ContactsLoaded shoud be NO");
    STAssertTrue([subject loadContacts:nil], @"LoadContacts should be YES");
    
    int contactsCount = [[subject contacts] count];
    
    STAssertEquals(contactsCount, 1, @"Contacts count should equal 1");
    
    NSSet *personRecordsSet = [subject contacts];
    
    SCContactPerson *personRecord = [personRecordsSet anyObject];
        
    STAssertTrue([personRecord.firstName isEqual:testUserFirstName], @"PersonRecord.firstName: %@ should equal: %@", personRecord.firstName, testUserFirstName);
    STAssertTrue([personRecord.lastName isEqual:testUserLastName], @"PersonRecord.lastName: %@ should equal: %@", personRecord.lastName, testUserLastName);
}

@end
