//
//  SCContactPerson.m
//  SCContactList
//
//  Created by Sam de Freyssinet on 7/23/12.
//  Copyright (c) 2012 Sittercity, Inc. All rights reserved.
//

#import "SCContactPerson.h"

@implementation SCContactPerson(Private)

- (NSDictionary *)ABAddressBookKeyMap
{
    NSNumber *ABPropertyID[] = {
        [NSNumber numberWithInt:kABPersonFirstNameProperty],
        [NSNumber numberWithInt:kABPersonLastNameProperty],
        [NSNumber numberWithInt:kABPersonMiddleNameProperty],
        [NSNumber numberWithInt:kABPersonPrefixProperty],
        [NSNumber numberWithInt:kABPersonSuffixProperty],
        [NSNumber numberWithInt:kABPersonNicknameProperty],
        [NSNumber numberWithInt:kABPersonFirstNamePhoneticProperty],
        [NSNumber numberWithInt:kABPersonLastNamePhoneticProperty],
        [NSNumber numberWithInt:kABPersonMiddleNamePhoneticProperty],
        [NSNumber numberWithInt:kABPersonOrganizationProperty],
        [NSNumber numberWithInt:kABPersonJobTitleProperty],
        [NSNumber numberWithInt:kABPersonDepartmentProperty],
        [NSNumber numberWithInt:kABPersonNoteProperty],
        [NSNumber numberWithInt:kABPersonBirthdayProperty],
        [NSNumber numberWithInt:kABPersonEmailProperty],
        [NSNumber numberWithInt:kABPersonPhoneProperty],
        [NSNumber numberWithInt:kABPersonInstantMessageProperty],
        [NSNumber numberWithInt:kABPersonSocialProfileProperty],
        [NSNumber numberWithInt:kABPersonURLProperty],
        [NSNumber numberWithInt:kABPersonRelatedNamesProperty],
        [NSNumber numberWithInt:kABPersonAddressProperty]
    };
    
    NSString *contactPersonKeys[] = {
        @"firstName",
        @"lastName",
        @"middleName",
        @"prefix",
        @"suffix",
        @"nickName",
        @"firstNamePhonetic",
        @"lastNamePhonetic",
        @"middleNamePhonetic",
        @"organizatiion",
        @"jobTitle",
        @"department",
        @"note",
        @"birthday",
        @"email",
        @"phoneNumber",
        @"instantMessage",
        @"socialProfile",
        @"URL",
        @"relatedNames",
        @"address"
    };
    
    int keyCount = (sizeof(contactPersonKeys) / sizeof(NSString *));

    NSDictionary *ABAddressBookKeyMap = [NSDictionary dictionaryWithObjects:ABPropertyID
                                                                    forKeys:contactPersonKeys
                                                                      count:keyCount];
    
    return ABAddressBookKeyMap;
}

- (ABPropertyID)ABPersonPropertyForKey:(NSString *)key addressBookKeyMap:(NSDictionary *)ABAddressBookKeyMapOrNil
{
    if (ABAddressBookKeyMapOrNil == nil)
    {
        ABAddressBookKeyMapOrNil = [self ABAddressBookKeyMap];
    }
    
    NSNumber *propertyValue = [ABAddressBookKeyMapOrNil objectForKey:key];
    
    if (propertyValue == nil)
    {
        return kABPropertyInvalidID;
    }

    ABPropertyID ABPersonProperty = (ABPropertyID)[propertyValue intValue];
    
    return ABPersonProperty;
}


@end

@implementation SCContactPerson

@synthesize image              = _image;

@synthesize firstName          = _firstName;
@synthesize lastName           = _lastName;
@synthesize middleName         = _middleName;
@synthesize prefix             = _prefix;
@synthesize suffix             = _suffix;
@synthesize nickName           = _nickName;

@synthesize firstNamePhonetic  = _firstNamePhonetic;
@synthesize lastNamePhonetic   = _lastNamePhonetic;
@synthesize middleNamePhonetic = _middleNamePhonetic;

@synthesize organization       = _organization;
@synthesize jobTitle           = _jobTitle;
@synthesize department         = _department;

@synthesize birthday           = _birthday;

@synthesize email              = _email;
@synthesize address            = _address;
@synthesize phoneNumber        = _phoneNumber;
@synthesize instantMessage     = _instantMessage;
@synthesize socialProfile      = _socialProfile;
@synthesize URL                = _URL;
@synthesize relatedNames       = _relatedNames;

@synthesize note               = _note;

@synthesize creationDate       = _creationDate;
@synthesize modificationDate   = _modificationDate;

#pragma mark - SCContactPerson lifecycle methods

+ (SCContactPerson *)contactPersonWithID:(NSNumber *)personID
{
    return [[[SCContactPerson alloc] initWithContactPersonID:personID] autorelease];
}

- (void)initializeMutableDictionaryPropertiesWithSize:(NSUInteger)size
{
    self.email          = [NSMutableDictionary dictionaryWithCapacity:size];
    self.address        = [NSMutableDictionary dictionaryWithCapacity:size];
    self.phoneNumber    = [NSMutableDictionary dictionaryWithCapacity:size];
    self.instantMessage = [NSMutableDictionary dictionaryWithCapacity:size];
    self.socialProfile  = [NSMutableDictionary dictionaryWithCapacity:size];
    self.URL            = [NSMutableDictionary dictionaryWithCapacity:size];
    self.relatedNames   = [NSMutableDictionary dictionaryWithCapacity:size];
}

- (id)initWithContactPersonID:(NSNumber *)personID
{
    if (personID == nil)
    {
        return nil;
    }
    
    self = [self init];
    
    if (self)
    {
        ABAddressBookRef addressBook = ABAddressBookCreate();
        ABRecordRef personRecord     = ABAddressBookGetPersonWithRecordID(addressBook, [personID intValue]);
        
        if (personRecord == NULL || ABRecordGetRecordType(personRecord) != kABPersonType)
        {
            CFRelease(addressBook);

            [self release];
            return nil;
        }
        
        [self setABRecord:personRecord];
        
        NSError *loadError = nil;
        
        if ( ! [self loadRecord:self.ABRecord error:&loadError])
        {
            NSLog(@"Error loading person record: %@ from database, error: %@", self.ABRecord, loadError);

            CFRelease(addressBook);

            [self release];
            return nil;
        }
        
        CFRelease(addressBook);
    }
    
    return self;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        ABRecordRef personRecord = ABPersonCreate();
        
        if (personRecord == NULL || ABRecordGetRecordType(personRecord) != kABPersonType)
        {
            if (personRecord != NULL)
            {
                CFRelease(personRecord);
            }
            
            return nil;
        }

        [self initializeMutableDictionaryPropertiesWithSize:kSCContactDefaultDictionarySize];
        
        _ABRecord = personRecord;
        
        [self _resetState];
    }
    
    return self;
}

- (void)dealloc
{    
    [_image release];
    
    [_firstName release];
    [_lastName release];
    [_middleName release];
    [_prefix release];
    [_suffix release];
    [_nickName release];
    
    [_firstNamePhonetic release];
    [_lastNamePhonetic release];
    [_middleNamePhonetic release];
    
    [_organization release];
    [_jobTitle release];
    [_department release];
    
    [_birthday release];
    
    [_email release];
    [_address release];
    [_phoneNumber release];
    [_instantMessage release];
    [_socialProfile release];
    [_URL release];
    [_relatedNames release];
    
    [_note release];
    
    [_creationDate release];
    [_modificationDate release];
    
    [super dealloc];
}

#pragma mark - Key/Value Observing Methods

- (NSArray *)objectKeysToObserve
{
    NSArray *keysToObserve = [NSArray arrayWithObjects:
                              @"firstName",
                              @"lastName",
                              @"middleName",
                              @"prefix",
                              @"suffix",
                              @"nickName",
                              @"firstNamePhonetic",
                              @"lastNamePhonetic",
                              @"middleNamePhonetic",
                              @"organization",
                              @"jobTitle",
                              @"department",
                              @"note",
                              @"birthday",
                              @"email",
                              @"address",
                              @"phoneNumber",
                              @"instantMessage",
                              @"socialProfile",
                              @"url",
                              @"relatedName",
                              nil];

    NSMutableArray *parentKeysToObserve = [[[super objectKeysToObserve] mutableCopy] autorelease];
    
    [parentKeysToObserve addObjectsFromArray:keysToObserve];
    
    return parentKeysToObserve;
}

#pragma mark - SCContactPerson property methods

- (void)setImageDataFromRecord:(ABRecordRef)record
{
    if ( ! ABPersonHasImageData(record))
    {
        return;
    }
    
    self.image = [(NSData *)ABPersonCopyImageData(record) autorelease];
}

#pragma mark - SCContactRecordPersistence protocol methods

- (BOOL)loadRecord:(ABRecordRef)record error:(NSError **)error
{
    BOOL result = YES;
    
    // Load personal properties
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
        kABPersonBirthdayProperty,
        kABPersonEmailProperty,
        kABPersonPhoneProperty,
        kABPersonInstantMessageProperty,
        kABPersonSocialProfileProperty,
        kABPersonURLProperty,
        kABPersonRelatedNamesProperty,
        kABPersonAddressProperty
    };
    
    SEL personalPropertiesAccessorMethods[] = {
        @selector(setFirstName:),
        @selector(setLastName:),
        @selector(setMiddleName:),
        @selector(setPrefix:),
        @selector(setSuffix:),
        @selector(setNickName:),
        @selector(setFirstNamePhonetic:),
        @selector(setLastNamePhonetic:),
        @selector(setMiddleNamePhonetic:),
        @selector(setOrganization:),
        @selector(setJobTitle:),
        @selector(setDepartment:),
        @selector(setNote:),
        @selector(setBirthday:),
        @selector(setEmail:),
        @selector(setPhoneNumber:),
        @selector(setInstantMessage:),
        @selector(setSocialProfile:),
        @selector(setURL:),
        @selector(setRelatedNames:),
        @selector(setAddress:)
    };
    
    int personalPropertiesCount = (sizeof(personalProperties) / sizeof(ABPropertyID));
    
    [self setProperties:personalProperties
    withAccessorMethods:personalPropertiesAccessorMethods
             fromRecord:record
     numberOfProperties:personalPropertiesCount];
    
    // Load image data
    [self setImageDataFromRecord:record];
    
    // Load creation / modification dates
    _creationDate     = (NSDate *)ABRecordCopyValue(record, kABPersonCreationDateProperty);
    _modificationDate = (NSDate *)ABRecordCopyValue(record, kABPersonModificationDateProperty);
    
    [self _resetState];
    
    return result;    
}

- (BOOL)saveRecord:(ABRecordRef)record error:(NSError **)error
{
    BOOL result = NO;
    
    if ( ! [self hasChanges])
    {
        result = YES;
        return result;
    }
    
    NSError *saveProcessingError = nil;
    NSDictionary *changesToModel = [self changesRequiringPersistence];
    NSDictionary *ABPropertyKeys = [self ABAddressBookKeyMap];
    
    for (NSString *changedPropertyKey in changesToModel)
    {
        ABPropertyID propertyID = [self ABPersonPropertyForKey:changedPropertyKey
                                             addressBookKeyMap:ABPropertyKeys];
        
        SEL getterMethod = NSSelectorFromString(changedPropertyKey);
        id value         = [self performSelector:getterMethod];
        
        ABPropertyType propertyType = ABPersonGetTypeOfProperty(propertyID);
        CFErrorRef ABSaveError      = NULL;

        if (value == nil)
        {
            ABRecordRemoveValue(record, propertyID, &ABSaveError);
        }
        else
        {
            // Transform value
            if (propertyType & kABMultiValueMask)
            {
                // Handle multivalue property
                ABMutableMultiValueRef multivalue = ABMultiValueCreateMutable(propertyType);
                
                int multiValueSize = [value count];
                
                id objects[multiValueSize];
                NSString *objectKeys[multiValueSize];
                
                [(NSDictionary *)value getObjects:objects
                                          andKeys:objectKeys];
                
                for (int i = 0; i < multiValueSize; i += 1)
                {
                    ABMultiValueInsertValueAndLabelAtIndex(multivalue, objects[i], (CFStringRef)objectKeys[i], i, NULL);
                }
                
                if ( ! ABRecordSetValue(record, propertyID, multivalue, &ABSaveError))
                {
                    NSLog(@"Error setting value: %@ to key: %i", multivalue, propertyID);
                    return result;
                }
                
                CFRelease(multivalue);
            }
            else
            {
                
                // Handle single value property
                ABRecordSetValue(record, propertyID, value, &ABSaveError);
            }
        }
        
        if (ABSaveError != NULL)
        {
            saveProcessingError = (NSError *)ABSaveError;
            break;
        }
    }

    if (saveProcessingError == nil)
    {
        CFErrorRef saveError         = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreate();
        
        if (addressBook == NULL)
        {
            NSLog(@"Error creating addressbook: %@", addressBook);
            
            return result;
        }
        
        if ( ! ABAddressBookAddRecord(addressBook, record, &saveError))
        {
            saveProcessingError = (NSError *)saveError;
        }
        else
        {
            if ( ! ABAddressBookSave(addressBook, &saveError))
            {
                saveProcessingError = (NSError *)saveError;
            }
            else
            {
                result = YES;
            }
        }        
    }

    if (saveProcessingError != nil && error != NULL)
    {
        *error = saveProcessingError;
    }

    return result;
}

- (BOOL)deleteRecord:(ABRecordRef)record error:(NSError **)error
{
    return NO;
}

@end
