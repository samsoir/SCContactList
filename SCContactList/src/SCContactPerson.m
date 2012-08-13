//
//  SCContactPerson.m
//  SCContactList
//
//  Created by Sam de Freyssinet on 7/23/12.
//  Copyright (c) 2012 Sittercity, Inc. All rights reserved.
//

#import "SCContactPerson.h"

static NSString *observingProperties[] = {
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
    @"relatedName"
};

@implementation SCContactPerson(Private)

- (void)initializeKeyValueObserving
{
    int count = (sizeof(observingProperties) / sizeof(NSString *));
    
    for (int i = 0; i < count; i += 1)
    {
        [self addObserver:self
               forKeyPath:observingProperties[i]
                  options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                  context:nil];
    }
}

- (void)deinitializeKeyValueObserving
{
    int count = (sizeof(observingProperties) / sizeof(NSString *));
    
    for (int i = 0; i < count; i += 1)
    {
        [self removeObserver:self
                  forKeyPath:observingProperties[i]];
    }
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
            return nil;
        }
        
        [self setABRecord:personRecord];
        _recordExistsInDatabase = YES;
        
        CFRelease(addressBook);
    }
    
    return self;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        [self initializeKeyValueObserving];

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
        
        _ABRecord               = personRecord;
        _recordExistsInDatabase = NO;
        _recordHasChanges       = NO;
    }
    
    return self;
}

- (void)dealloc
{
    [self deinitializeKeyValueObserving];
    
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


#pragma mark - SCContactGroup methods

- (void)setImageDataFromRecord:(ABRecordRef)record
{
    if ( ! ABPersonHasImageData(record))
    {
        return;
    }
    
    self.image = [(NSData *)ABPersonCopyImageData(record) autorelease];
}

- (void)setPersonalProperties:(ABPropertyID *)personalProperties
          withAccessorMethods:(SEL *)accessorMethods
                   fromRecord:(ABRecordRef)record
           numberOfProperties:(int)count
{    
    for (int i = 0; i < count; i += 1)
    {
        ABPropertyID property       = personalProperties[i];
        SEL accessorMethod          = accessorMethods[i];
        id propertyValue            = (id)ABRecordCopyValue(record, property);
        
        if (propertyValue)
        {
            [self performSelector:accessorMethod
                       withObject:propertyValue];

            [propertyValue release];
        }
    }
}

- (NSMutableDictionary *)mutableDictionaryFromMultiValueProperty:(ABPropertyID)property record:(ABRecordRef)record
{
    NSMutableDictionary *dictionary = nil;
    
    if (property < 1 || record == NULL)
    {
        return dictionary;
    }
    
    ABMutableMultiValueRef propertyMultiValue = ABRecordCopyValue(record, property);

    if (propertyMultiValue == NULL)
    {
        return dictionary;
    }
    
    NSArray *propertyArray                    = [(NSArray *)ABMultiValueCopyArrayOfAllValues(propertyMultiValue) autorelease];
    int arrayCount                            = [propertyArray count];
    NSMutableArray *keys                      = [NSMutableArray arrayWithCapacity:arrayCount];
    
    for (int i = 0; i < arrayCount; i += 1)
    {
        if (propertyMultiValue != NULL)
        {
            NSString *arrayKey = [(NSString *)ABMultiValueCopyLabelAtIndex(propertyMultiValue, i) autorelease];
            [keys addObject:arrayKey];
        }
    }
    
    CFRelease(propertyMultiValue);
    
    dictionary = [NSMutableDictionary dictionaryWithObjects:propertyArray
                                                    forKeys:keys];
    
    return dictionary;
}

- (void)setMultiValuePersonalProperties:(ABPropertyID *)personalProperties
                    withAccessorMethods:(SEL *)accessorMethods
                             fromRecord:(ABRecordRef)record
                     numberOfProperties:(int)count
{
    for (int i = 0; i < count; i += 1)
    {
        ABPropertyID property = personalProperties[i];
        SEL accessorMethod    = accessorMethods[i];

        NSMutableDictionary *propertyDict = [self mutableDictionaryFromMultiValueProperty:property
                                                                                   record:record];
        
        [self performSelector:accessorMethod withObject:propertyDict];
    }
}

- (NSMutableDictionary *)multiDimensionalMutableDictionaryFromMultiValueProperty:(ABPropertyID)property record:(ABRecordRef)record
{
    NSMutableDictionary *dictionary = nil;
    
    if (property < 1 || record == NULL)
    {
        return dictionary;
    }
    
    ABMultiValueRef multiValueProperty = ABRecordCopyValue(record, property);
    
    if (multiValueProperty == NULL)
    {
        return dictionary;
    }
    
    CFArrayRef propertyArray = ABMultiValueCopyArrayOfAllValues(multiValueProperty);
    
    if (propertyArray == NULL)
    {
        return dictionary;
    }
    
    int propertyCount = CFArrayGetCount(propertyArray);
    dictionary = [NSMutableDictionary dictionaryWithCapacity:propertyCount];
    
    for (int i = 0; i < propertyCount; i += 1)
    {
        NSDictionary *propertyDict = [(NSDictionary *)CFArrayGetValueAtIndex(propertyArray, i) autorelease];
        NSString *propertyKey      = [(NSString *)ABMultiValueCopyLabelAtIndex(multiValueProperty, i) autorelease];

        [dictionary setObject:propertyDict
                       forKey:propertyKey];
    }
    
    CFRelease(propertyArray);
    CFRelease(multiValueProperty);
    
    return dictionary;
}

- (void)setMultiValueComplexPersonalProperties:(ABPropertyID *)personalProperties
                           withAccessorMethods:(SEL *)accessorMethods
                                    fromRecord:(ABRecordRef)record
                            numberOfProperties:(int)count
{
    for (int i = 0; i < count; i += 1)
    {
        ABPropertyID property = personalProperties[i];
        SEL accessorMethod    = accessorMethods[i];
        
        NSMutableDictionary *complexProperty = [self multiDimensionalMutableDictionaryFromMultiValueProperty:property
                                                                                                      record:record];
        
        [self performSelector:accessorMethod
                   withObject:complexProperty];
    }
}

- (BOOL)loadPersonFromRecord:(ABRecordRef)record
                       error:(NSError **)error
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
        kABPersonBirthdayProperty
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
        @selector(setBirthday:)
    };
    
    int personalPropertiesCount = (sizeof(personalProperties) / sizeof(ABPropertyID));
    
    [self setPersonalProperties:personalProperties
            withAccessorMethods:personalPropertiesAccessorMethods
                     fromRecord:record
             numberOfProperties:personalPropertiesCount];
    
    // Load image data
    [self setImageDataFromRecord:record];
    
    // Load simple multivalue properties    
    ABPropertyID simpleMultiValues[] = {
        kABPersonEmailProperty,
        kABPersonPhoneProperty,
        kABPersonInstantMessageProperty,
        kABPersonSocialProfileProperty,
        kABPersonURLProperty,
        kABPersonRelatedNamesProperty
    };
    
    SEL personPropertiesSimpleMultiValueAccessorMethods[] = {
        @selector(setEmail:),
        @selector(setPhoneNumber:),
        @selector(setInstantMessage:),
        @selector(setSocialProfile:),
        @selector(setURL:),
        @selector(setRelatedNames:)
    };
    
    int multiValuePropertiesCount = (sizeof(simpleMultiValues) / sizeof(ABPropertyID));
    
    [self setMultiValuePersonalProperties:simpleMultiValues
                      withAccessorMethods:personPropertiesSimpleMultiValueAccessorMethods
                               fromRecord:record
                       numberOfProperties:multiValuePropertiesCount];
    
    // Load complex multivalue properties
    ABPropertyID complexMultiValues[] = {
        kABPersonAddressProperty
    };
    
    SEL complexMultiValueAccessorMethods[] = {
        @selector(setAddress:)
    };
    
    int complexMultiValuePropertiesCount = (sizeof(complexMultiValues) / sizeof(ABPropertyID));
    
    [self setMultiValueComplexPersonalProperties:complexMultiValues
                             withAccessorMethods:complexMultiValueAccessorMethods
                                      fromRecord:record
                              numberOfProperties:complexMultiValuePropertiesCount];
    
    // Load creation / modification dates
    _creationDate     = (NSDate *)ABRecordCopyValue(record, kABPersonCreationDateProperty);
    _modificationDate = (NSDate *)ABRecordCopyValue(record, kABPersonModificationDateProperty);
    
    return result;
}

- (BOOL)save:(NSError **)error
{
    return NO;
}

- (BOOL)remove:(NSError **)error
{
    return NO;
}

- (BOOL)isSaved
{
    return (_recordExistsInDatabase && ! _recordHasChanges);
}

- (BOOL)hasChanges
{
    return _recordHasChanges;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    NSLog(@"OBSERVING: %@ = %@", keyPath, change);
    
    _recordHasChanges = YES;
}


@end
