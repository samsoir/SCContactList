//
//  SCContactPersonTests.m
//  SCContactList
//
//  Created by Sam de Freyssinet on 7/23/12.
//  Copyright (c) 2012 Sittercity, Inc. All rights reserved.
//

#import "SCContactPersonTests.h"
#import "SCContactList.h"

static int kSCContactPersonTestsfixtureCount = 5;

@implementation SCContactPersonTests

@synthesize records = _records;

- (NSArray *)fixtureData
{
    NSArray *contactData = [NSArray arrayWithObjects:
        @"Jane",
        @"Doe",
        @"Jenny",
        @"Mrs",
        @"Snr",
        @"Janey",
        @"Jayne",
        @"Doh",
        @"Gen-knee",
        @"Acme",
        @"Iron",
        @"Bell",
        @"This is a note",
        [NSDate date],
        nil];
    
    return contactData;
}

- (NSDictionary *)fixtureHomeAddress
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"4800 N Kenmore Ave", kABPersonAddressStreetKey,
            @"Chicago", kABPersonAddressCityKey,
            @"Illinois", kABPersonAddressStateKey,
            @"60640", kABPersonAddressZIPKey,
            @"United States", kABPersonAddressCountryKey,
            @"us", kABPersonAddressCountryCodeKey, nil];
}

- (NSDictionary *)fixtureWorkAddress
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"15 Kimberely Avenue", kABPersonAddressStreetKey,
            @"London", kABPersonAddressCityKey,
            @"United Kingdom", kABPersonAddressCountryKey,
            @"SE15 4YZ", kABPersonAddressZIPKey,
            @"uk", kABPersonAddressCountryCodeKey, nil];
}

- (NSString *)fixtureHomeEmail
{
    return @"home@test.com";
}

- (NSString *)fixtureWorkEmail
{
    return @"work@test.com";
}

- (NSString *)fixtureMainPhone
{
    return @"+17733556677";
}

- (NSString *)fixtureIPhone
{
    return @"+17733445566";
}

- (NSString *)fixtureWorkPhone
{
    return @"+441206337343";
}

- (NSString *)fixtureForOrganization
{
    return @"Acme Inc.";
}

- (NSDictionary *)fixtureForFacebook
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"test.user", (NSString *)kABPersonSocialProfileUsernameKey,
            (NSString *)kABPersonSocialProfileServiceFacebook, (NSString *)kABPersonSocialProfileServiceKey
            , nil];
}

- (NSDictionary *)fixtureForTwitter
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"T3stusr", (NSString *)kABPersonSocialProfileUsernameKey,
            (NSString *)kABPersonSocialProfileServiceTwitter, (NSString *)kABPersonSocialProfileServiceKey
            , nil];
}

- (ABRecordRef)createTestAddressBookRecord
{
    ABRecordRef subjectRecord = ABPersonCreate();
    
    // Create a couple of addresses
    NSDictionary *addressHome = [self fixtureHomeAddress];
    NSDictionary *addressWork = [self fixtureWorkAddress];
    
    ABMutableMultiValueRef addressValue = ABMultiValueCreateMutable(kABPersonAddressProperty);
    
    ABMultiValueInsertValueAndLabelAtIndex(addressValue, addressHome, kABHomeLabel, 0, NULL);
    ABMultiValueInsertValueAndLabelAtIndex(addressValue, addressWork, kABWorkLabel, 1, NULL);
    
    CFErrorRef addressSetError = NULL;
    
    if ( ! ABRecordSetValue(subjectRecord, kABPersonAddressProperty, addressValue, &addressSetError))
    {
        STFail(@"Unable to set Address value with error: %@", addressSetError);
    }
    
    // Create a couple of email addresses
    NSString *emailHome = [self fixtureHomeEmail];
    NSString *emailWork = [self fixtureWorkEmail];
    
    ABMutableMultiValueRef emailValue = ABMultiValueCreateMutable(kABPersonEmailProperty);
    
    ABMultiValueInsertValueAndLabelAtIndex(emailValue, emailHome, kABHomeLabel, 0, NULL);
    ABMultiValueInsertValueAndLabelAtIndex(emailValue, emailWork, kABWorkLabel, 1, NULL);
    
    CFErrorRef emailSetError = NULL;
    
    if ( ! ABRecordSetValue(subjectRecord, kABPersonEmailProperty, emailValue, &emailSetError))
    {
        STFail(@"Unable to set email address value with error: %@", emailSetError);
    }
    
    // Create an organization
    NSString *organization = [self fixtureForOrganization];
    
    if ( ! ABRecordSetValue(subjectRecord, kABPersonOrganizationProperty, organization, NULL))
    {
        STFail(@"Unable to create organization value");
    }
    
    // Create a couple of phone numbers
    NSString *phoneMain = [self fixtureMainPhone];
    NSString *iphone    = [self fixtureIPhone];
    NSString *phoneWork = [self fixtureWorkPhone];
    
    ABMutableMultiValueRef phoneValue = ABMultiValueCreateMutable(kABPersonPhoneProperty);
    
    ABMultiValueInsertValueAndLabelAtIndex(phoneValue, phoneMain, kABPersonPhoneMainLabel, 0, NULL);
    ABMultiValueInsertValueAndLabelAtIndex(phoneValue, iphone, kABPersonPhoneIPhoneLabel, 1, NULL);
    ABMultiValueInsertValueAndLabelAtIndex(phoneValue, phoneWork, kABWorkLabel, 2, NULL);
    
    CFErrorRef phoneSetError = NULL;
    
    if ( ! ABRecordSetValue(subjectRecord, kABPersonPhoneProperty, phoneValue, &phoneSetError))
    {
        STFail(@"Unable to set phone value with error: %@", phoneSetError);
    }
        
    NSDictionary *facebook = [self fixtureForFacebook];
    NSDictionary *twitter  = [self fixtureForTwitter];
    
    ABMutableMultiValueRef socialValue = ABMultiValueCreateMutable(kABPersonSocialProfileProperty);
    
    ABMultiValueInsertValueAndLabelAtIndex(socialValue, facebook, kABPersonSocialProfileServiceFacebook, 0, NULL);
    ABMultiValueInsertValueAndLabelAtIndex(socialValue, twitter, kABPersonSocialProfileServiceTwitter, 1, NULL);

    CFErrorRef socialSetError = NULL;
    
    if ( ! ABRecordSetValue(subjectRecord, kABPersonSocialProfileProperty, socialValue, &socialSetError))
    {
        STFail(@"Unable to set social value with error: %@", socialSetError);
    }
    
    ABPropertyID personalProperties[] = {
        kABPersonFirstNameProperty,
        kABPersonLastNameProperty,
        kABPersonMiddleNameProperty,
        kABPersonPrefixProperty,
        kABPersonSuffixProperty,
        kABPersonNicknameProperty,
        kABPersonFirstNamePhoneticProperty,
        kABPersonLastNamePhoneticProperty,
        kABPersonMiddleNamePhoneticProperty,
        kABPersonOrganizationProperty,
        kABPersonJobTitleProperty,
        kABPersonDepartmentProperty,
        kABPersonNoteProperty,
        kABPersonBirthdayProperty
    };
    
    NSArray *propertyValues = [self fixtureData];
    
    int counter = (sizeof(personalProperties) / sizeof(ABPropertyID));
    
    for (int i = 0; i < counter; i += 1)
    {
        CFErrorRef setError = NULL;
        
        if ( ! ABRecordSetValue(subjectRecord, personalProperties[i], propertyValues[i], &setError))
        {
            STFail(@"Failed setting value: %@ for property: %i", propertyValues[i], personalProperties[i]);
        }
    }

    CFRelease(phoneValue);
    CFRelease(emailValue);
    CFRelease(addressValue);
    
    return subjectRecord;
}

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    [self tearDown];
    
    int recordNumber                    = kSCContactPersonTestsfixtureCount;
    NSMutableArray *addressBookRecords  = [NSMutableArray arrayWithCapacity:5];
    self.records                        = [NSMutableArray arrayWithCapacity:5];
    
    for (int i = 0; i < recordNumber; i += 1)
    {
        NSString *firstName = [NSString stringWithFormat:@"Jane%i", i];
        NSString *lastName  = [NSString stringWithFormat:@"Smith%i", i];
        NSString *email     = [NSString stringWithFormat:@"jane.smith%i@test.com", i];
        NSString *phone     = [NSString stringWithFormat:@"+1773344724%i", i];
        
        id values[] = {
            firstName,
            lastName,
            email,
            phone
        };
        
        id keys[] = {
            @"firstName",
            @"lastName",
            @"email",
            @"phone"
        };
        
        int size = (sizeof(values) / sizeof(id));
        
        NSDictionary *contactDict = [NSDictionary dictionaryWithObjects:values
                                                                forKeys:keys
                                                                  count:size];
        
        [addressBookRecords addObject:contactDict];
    }
    
    ABAddressBookRef addressBook = SCAddressBookCreate(NULL, NULL);
    
    for (NSDictionary *contactDict in addressBookRecords)
    {
        NSLog(@"Creating contact: %@", contactDict);
        
        ABRecordRef record  = ABPersonCreate();
        
        CFErrorRef setABRecordValueError = NULL;
        ABRecordSetValue(record, kABPersonFirstNameProperty, [contactDict valueForKey:@"firstName"], &setABRecordValueError);
        
        if (setABRecordValueError != NULL)
        {
            STFail(@"There was a problem setting an address book value: %@", setABRecordValueError);
        }
        
        ABRecordSetValue(record, kABPersonLastNameProperty, [contactDict valueForKey:@"lastName"], &setABRecordValueError);
        
        if (setABRecordValueError != NULL)
        {
            STFail(@"There was a problem setting an address book value: %@", setABRecordValueError);
        }
        
        ABMultiValueRef emailMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(emailMultiValue, [contactDict valueForKey:@"email"], kABHomeLabel, NULL);
        ABRecordSetValue(record, kABPersonEmailProperty, emailMultiValue, &setABRecordValueError);
        
        if (setABRecordValueError != NULL)
        {
            STFail(@"There was a problem setting an address book value: %@", setABRecordValueError);
        }
        
        ABMultiValueRef phoneMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(phoneMultiValue, [contactDict valueForKey:@"phone"], kABPersonPhoneMobileLabel, NULL);
        ABRecordSetValue(record, kABPersonPhoneProperty, phoneMultiValue, &setABRecordValueError);
        
        if (setABRecordValueError != NULL)
        {
            STFail(@"There was a problem setting an address book value: %@", setABRecordValueError);
        }
        
        CFErrorRef recordError = NULL;
        ABAddressBookAddRecord(addressBook, record, &recordError);
        
        if (recordError != NULL)
        {
            STFail(@"There was a problem creating an address book record: %@", recordError);
        }

        if (ABAddressBookHasUnsavedChanges(addressBook))
        {
            CFErrorRef saveError = NULL;
            ABAddressBookSave(addressBook, &saveError);
            
            if (saveError != NULL)
            {
                STFail(@"There was a problem saving the address book record: %@", saveError);
            }
        }
        
        [self.records addObject:[NSNumber numberWithInt:ABRecordGetRecordID(record)]];
        
        CFRelease(record);
    }
        
    CFRelease(addressBook);
    
}

- (void)tearDown
{
    ABAddressBookRef addressBook = SCAddressBookCreate(NULL, NULL);
    
    // Tear-down code here.
    CFArrayRef recordsInserted = ABAddressBookCopyArrayOfAllPeople(addressBook);
    long recordsCount          = CFArrayGetCount(recordsInserted);
    int i                      = 0;
    
    for (i = 0; i < recordsCount; i += 1)
    {
        ABRecordRef eRecord = CFArrayGetValueAtIndex(recordsInserted, i);
        ABAddressBookRemoveRecord(addressBook, eRecord, NULL);
        
    }
    
    if (ABAddressBookSave(addressBook, NULL))
    {
        NSLog(@"Successfully removed %i contacts", i);
    }
    
    CFRelease(recordsInserted);
    CFRelease(addressBook);
    
    self.records = nil;
    
    [super tearDown];
}

- (void)testInitContactPersonID
{
    STAssertNotNil([[SCContactPerson alloc] initWithABRecordID:kABRecordInvalidID], @"Should not be nil");

    NSNumber *contactID = [self.records objectAtIndex:0];
        
    SCContactPerson *person = [[[SCContactPerson alloc] initWithABRecordID:[contactID intValue]] autorelease];
    
    STAssertTrue([person isKindOfClass:[SCContactPerson class]], @"Person should be an instance of SCContactPerson");
    STAssertTrue([contactID intValue] == [person ABRecordID], @"Person record ID: %i should be equal to: %@", [person ABRecordID], contactID);
}

- (void)testIsSaved
{
    SCContactPerson *newPerson = [[[SCContactPerson alloc] init] autorelease];
    STAssertFalse([newPerson isSaved], @"New person should not be saved");
    
    NSNumber *contactID = [self.records objectAtIndex:0];
    
    SCContactPerson *existingPerson = [[[SCContactPerson alloc] initWithABRecordID:[contactID intValue]] autorelease];
    STAssertTrue([existingPerson isSaved], @"Existing person should be saved");
}

- (void)testLoadRecordError
{
    ABRecordRef subjectRecord = [self createTestAddressBookRecord];
    
    ABAddressBookRef addressBook = SCAddressBookCreate(NULL, NULL);
    
    ABAddressBookAddRecord(addressBook, subjectRecord, NULL);

    if ( ! ABAddressBookSave(addressBook, NULL))
    {
        STFail(@"Failed saving AddressBook");
    }
    
    CFRelease(addressBook);
    
    if (subjectRecord == NULL)
    {
        STFail(@"subjectRecord failed to initialize");
    }
    
    SCContactPerson *subject = [[SCContactPerson alloc] init];
    NSError *subjectError    = nil;
    
    BOOL result = [subject readRecord:ABRecordGetRecordID(subjectRecord)
                                error:&subjectError];
    
    STAssertTrue(result, @"Load person from record should be YES");
    STAssertFalse([subject hasChanges], @"The subject should have changes");
    
    SEL accessorMethods[] = {
        @selector(firstName),
        @selector(lastName),
        @selector(middleName),
        @selector(prefix),
        @selector(suffix),
        @selector(nickName),
        @selector(firstNamePhonetic),
        @selector(lastNamePhonetic),
        @selector(middleNamePhonetic),
        @selector(organization),
        @selector(jobTitle),
        @selector(department),
        @selector(note),
        @selector(birthday)
    };

    NSArray *propertyValues = [self fixtureData];
    
    int counter = (sizeof(accessorMethods) / sizeof(SEL));
    
    for (int i = 0; i < counter; i += 1)
    {
        id returnValue = [subject performSelector:accessorMethods[i]];
        
        if ([returnValue isKindOfClass:[NSString class]])
        {
            NSString *stringValue = (NSString *)returnValue;
            STAssertTrue([stringValue isEqualToString:propertyValues[i]], @"returnValue: %@ should equal propertyValue[%i]: %@", returnValue, i, propertyValues[i]);
        }
    }
    
    
    // Test email
    STAssertTrue([[subject.email objectForKey:(NSString *)kABHomeLabel] isEqualToString:[self fixtureHomeEmail]], @"Home email :%@ should match returned email: %@", [self fixtureHomeEmail], [subject.email objectForKey:(NSString *)kABHomeLabel]);
    
    // Test iPhone
    STAssertTrue([[subject.phoneNumber objectForKey:(NSString *)kABPersonPhoneIPhoneLabel] isEqualToString:[self fixtureIPhone]], @"Phone (iPhone) :%@ should match returned iPhone: %@", [self fixtureIPhone], [subject.phoneNumber objectForKey:(NSString *)kABPersonPhoneIPhoneLabel]);
    STAssertNil([subject.phoneNumber objectForKey:@"Home Fax"], @"Home fax should be nil");
    
    // Test home address
    NSDictionary *homeAddress = [subject.address objectForKey:(NSString *)kABHomeLabel];
    STAssertTrue([[homeAddress objectForKey:@"Street"] isEqualToString:[[self fixtureHomeAddress] objectForKey:@"Street"]], @"Home address street: %@ should match: %@", [homeAddress objectForKey:@"Street"], [[self fixtureHomeAddress] objectForKey:@"Street"]);
    
    CFRelease(subject);
}

- (void)testSave
{
    ABAddressBookRef addressBook = SCAddressBookCreate(NULL, NULL);
    ABRecordRef subjectRecord = [self createTestAddressBookRecord];

    CFErrorRef error = NULL;
    
    if ( ! ABAddressBookAddRecord(addressBook, subjectRecord, &error))
    {
        STFail(@"Address Book add record failed with error: %@", error);
        return;
    }

    if ( ! ABAddressBookSave(addressBook, &error))
    {
        STFail(@"Address Book save failed with error:%@", error);
    }
    
    CFRelease(addressBook);

    SCContactPerson *subject = [[SCContactPerson alloc] initWithABRecordID:ABRecordGetRecordID(subjectRecord)];

    NSError *subjectError    = nil;
    
    [subject readFromRecordRef:subjectRecord error:&subjectError];

    STAssertTrue([subject updateRecord:subject.ABRecordID error:nil], @"Save Record should be TRUE on save with no changes.");
    
    NSString *newFirstName  = @"Robert";
    NSString *newLastName   = @"Clark";
    NSString *newMiddleName = @"John";
    NSString *newNickName   = @"Bob";
    NSString *newOrganization = [self fixtureForOrganization];

    NSMutableDictionary *newEmail       = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"bob@test.com", kABHomeLabel, nil];
    NSMutableDictionary *newPhone       = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"+442074503900", kABPersonPhoneIPhoneLabel, nil];
    NSMutableDictionary *newHomeAddress = [[[self fixtureHomeAddress] mutableCopy] autorelease];
    [newHomeAddress setObject:@"1 Kiln Cottages" forKey:@"Street"];
    
    NSMutableDictionary *newAddress = [NSMutableDictionary dictionaryWithObject:newHomeAddress forKey:(NSString *)kABHomeLabel];
    
    subject.firstName   = newFirstName;
    subject.lastName    = newLastName;
    subject.middleName  = newMiddleName;
    subject.nickName    = newNickName;
    subject.email       = newEmail;
    subject.phoneNumber = newPhone;
    subject.address     = newAddress;
    subject.organization = newOrganization;
    
    STAssertTrue([subject updateRecord:subject.ABRecordID error:nil], @"Save record should be TRUE");
    
    ABAddressBookRef secondAddressBook = SCAddressBookCreate(NULL, NULL);
    
    ABRecordRef testSubjectRecord = ABAddressBookGetPersonWithRecordID(secondAddressBook, subject.ABRecordID);
        
    NSString *savedFirstName  = [(NSString *)ABRecordCopyValue(testSubjectRecord, kABPersonFirstNameProperty) autorelease];
    NSString *savedLastName   = [(NSString *)ABRecordCopyValue(testSubjectRecord, kABPersonLastNameProperty) autorelease];
    NSString *savedMiddleName = [(NSString *)ABRecordCopyValue(testSubjectRecord, kABPersonMiddleNameProperty) autorelease];
    NSString *savedNickName   = [(NSString *)ABRecordCopyValue(testSubjectRecord, kABPersonNicknameProperty) autorelease];;
    
    ABMultiValueRef addressValue = ABRecordCopyValue(testSubjectRecord, kABPersonAddressProperty);
    ABMultiValueRef emailValue   = ABRecordCopyValue(testSubjectRecord, kABPersonEmailProperty);
    NSArray *addresses = [(NSArray *)ABMultiValueCopyArrayOfAllValues(addressValue) autorelease];
    NSArray *emailAddresses = [(NSArray *)ABMultiValueCopyArrayOfAllValues(emailValue) autorelease];
    
    STAssertTrue([subject.firstName isEqualToString:savedFirstName], @"Subject firstname: %@ should match saved firstname: %@", subject.firstName, savedFirstName);
    STAssertTrue([subject.lastName isEqualToString:savedLastName], @"Subject lastname: %@ should match saved lastname: %@", subject.lastName, savedLastName);
    STAssertTrue([subject.middleName isEqualToString:savedMiddleName], @"Subject middlename: %@ should match saved middlename: %@", subject.middleName, savedMiddleName);
    STAssertTrue([subject.nickName isEqualToString:savedNickName], @"Subject nickname: %@ should match saved nickname: %@", subject.nickName, savedNickName);
    
    NSDictionary *savedAddress = [addresses objectAtIndex:0];
    
    STAssertTrue([[[subject.address objectForKey:(NSString *)kABHomeLabel] objectForKey:(NSString *)kABPersonAddressStreetKey] isEqualToString:[savedAddress objectForKey:(NSString *)kABPersonAddressStreetKey]], @"Subject Street Address: %@ should match saved Street Address: %@",[[subject.address objectForKey:(NSString *)kABHomeLabel] objectForKey:(NSString *)kABPersonAddressStreetKey], [savedAddress objectForKey:(NSString *)kABPersonAddressStreetKey]);

    NSString *savedEmailAddress = [emailAddresses objectAtIndex:0];
    
    STAssertTrue([[subject.email objectForKey:(NSString *)kABHomeLabel] isEqualToString:savedEmailAddress], @"Subject Email Address: %@ should match saved Street Address: %@",[subject.email objectForKey:(NSString *)kABHomeLabel], savedEmailAddress);

    
    CFRelease(secondAddressBook);
    CFRelease(addressValue);
    CFRelease(subjectRecord);
}

- (void)testDeleteRecordError
{
    ABAddressBookRef addressBook = SCAddressBookCreate(NULL, NULL);
    
    // Tear-down code here.
    NSArray *recordsInserted = [(NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook) autorelease];
    
    ABRecordRef randomRecord = [recordsInserted objectAtIndex:0];
    ABRecordID recordID      = ABRecordGetRecordID(randomRecord);
        
    SCContactPerson *subject = [[[SCContactPerson alloc] initWithABRecordID:recordID] autorelease];
    
    NSError *deleteError = nil;
    
    STAssertTrue([subject deleteRecord:subject.ABRecordID error:&deleteError], @"Deleting a valid model should return true");
    
    NSArray *recordsRemaining = [(NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook) autorelease];
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
    SCContactPerson *subject = [[[SCContactPerson alloc] init] autorelease];

    
    NSError *deleteError = nil;
    
    STAssertTrue([subject deleteRecord:subject.ABRecordID error:&deleteError], @"Deleting a valid model should return YES");
    STAssertNil(deleteError, @"Delete error should be nil");
}

- (void)testPeopleWithName
{
    NSString *searchTerm     = @"Jane";
    
    NSArray *foundPeople     = [SCContactPerson peopleWithName:searchTerm];
    
    STAssertNotNil(foundPeople, @"Found people should not be nil");
    
    int foundPeopleCount     = [foundPeople count];
    
    STAssertEquals(kSCContactPersonTestsfixtureCount, foundPeopleCount, @"Found people should contain %i records, found %i", kSCContactPersonTestsfixtureCount, foundPeopleCount);
    
    for (int i = 0; i < foundPeopleCount; i += 1)
    {
        id record = [foundPeople objectAtIndex:i];
        
        STAssertTrue([record isKindOfClass:[SCContactPerson class]], @"Record should be instance of SCContactPerson");
    }
    
    searchTerm               = @"Jane2";
    
    foundPeople              = [SCContactPerson peopleWithName:searchTerm];
    
    STAssertNotNil(foundPeople, @"Found people should not be nil");

    foundPeopleCount         = [foundPeople count];

    STAssertEquals(1, foundPeopleCount, @"Found people should contain %i records, found %i", 5, foundPeopleCount);
}

- (void)testArrayOfAllPeople
{
    NSArray *allPeople = [SCContactPerson allPeopleWithSortOrdering:kABPersonSortByFirstName];
    
    int allPeopleCount = [allPeople count];
    
    STAssertNotNil(allPeople, @"allPeople should not be nil");
    STAssertEquals(kSCContactPersonTestsfixtureCount, allPeopleCount, @"allPeople should contain %i records, got: %i", kSCContactPersonTestsfixtureCount, allPeopleCount);
    
    SCContactPerson *firstRecord = [allPeople objectAtIndex:0];
    SCContactPerson *lastRecord  = [allPeople objectAtIndex:4];
    
    STAssertTrue([firstRecord.firstName isEqualToString:@"Jane0"], @"allPeople should be sorted by first name, first record was %@", firstRecord);
    STAssertTrue([lastRecord.firstName isEqualToString:@"Jane4"], @"allPeople should be sorted by first name, last record was %@", lastRecord);
 

    allPeople      = [SCContactPerson allPeopleWithSortOrdering:kABPersonSortByLastName];
    allPeopleCount = [allPeople count];

    firstRecord = [allPeople objectAtIndex:0];
    lastRecord  = [allPeople objectAtIndex:4];

    STAssertTrue([firstRecord.lastName isEqualToString:@"Smith0"], @"allPeople should be sorted by last name, first record was %@", firstRecord.firstName);
    STAssertTrue([lastRecord.lastName isEqualToString:@"Smith4"], @"allPeople should be sorted by last name, last record was %@", lastRecord.firstName);
}

- (void)testCreateMultiValueForPropertyWithDictionary
{
    NSDictionary *dictionary    = [NSDictionary dictionaryWithObject:@"test.user" forKey:(NSString *)kABPersonSocialProfileServiceFacebook];
    ABPropertyType propertyType = kABMultiStringPropertyType;
    
    SCContactPerson *subject = [[[SCContactPerson alloc] initWithABRecordID:kABRecordInvalidID] autorelease];
    
    ABMutableMultiValueRef result = [subject createMultiValueForProperty:propertyType withDictionary:dictionary];
    
    STAssertNotNil(result, @"Result should not be nil");
}

@end
