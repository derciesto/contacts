/**
 * Support for searching varies between platforms. iOS only supports the following types for a text search:
 *  * 'name'
 *  * 'emails'
 *  * 'phoneNumbers'
 *
 * In addition, the wildcard '*' character is required to return all contacts.
 *
 * Android supports all defined fields.
 */
export declare type ContactFieldType = "*" | "addresses" | "birthday" | "categories" | "country" | "department" | "displayName" | "emails" | "name.familyName" | "name.formatted" | "name.givenName" | "name.honorificPrefix" | "name.honorificSuffix" | "id" | "ims" | "locality" | "name.middleName" | "name" | "nickname" | "note" | "organizations" | "phoneNumbers" | "photos" | "postalCode" | "region" | "streetAddress" | "title" | "urls";
/**
 * Contains information about a single contact.
 */
export declare class Contact {
    /** A globally unique identifier. */
    id?: string | null;
    /** A globally unique identifier on Android. */
    rawId?: string | null;
    /** The name of this Contact, suitable for display to end users. */
    displayName?: string | null;
    /** An object containing all components of a persons name. */
    name?: ContactName | null;
    /** A casual name by which to address the contact. */
    nickname?: string | null;
    /** An array of all the contact's phone numbers. */
    phoneNumbers?: ContactField[] | null;
    /** An array of all the contact's email addresses. */
    emails?: ContactField[] | null;
    /** An array of all the contact's addresses. */
    addresses?: ContactAddress[] | null;
    /** An array of all the contact's IM addresses. */
    ims?: ContactField[] | null;
    /** An array of all the contact's organizations. */
    organizations?: ContactOrganization[] | null;
    /** The birthday of the contact. */
    birthday?: Date | string | null;
    /** A note about the contact on Android. */
    note?: string | null;
    /** An array of the contact's photos. */
    photos?: ContactField[] | null;
    /** An array of all the user-defined categories associated with the contact. */
    categories?: ContactField[] | null;
    /** An array of web pages associated with the contact. */
    urls?: ContactField[] | null;
    [key: string]: any | null;
    constructor(id?: string, displayName?: string, name?: ContactName, nickname?: string, phoneNumbers?: ContactField[], emails?: ContactField[], addresses?: ContactAddress[], ims?: ContactField[], organizations?: ContactOrganization[], birthday?: Date | string | null, note?: string, photos?: ContactField[], categories?: ContactField[], urls?: ContactField[]);
    /**
     * Creates a deep copy of this Contact.
     * With the contact ID set to null.
     * @return copy of this Contact
     */
    clone(): Contact;
    /**
     * Removes contact from device storage.
     */
    remove(): Promise<any>;
    /**
     * Persists contact to device storage.
     */
    save(): Promise<any>;
    /**
     * iOS only
     * Display a contact in the native Contact Picker UI
     *
     * @param allowEdit
     * true display the contact and allow editing it
     * false (default) display contact without editing
     */
    display(allowEdit?: boolean): Promise<any>;
}
/**
 * Contact address.
 */
export declare class ContactAddress {
    /** unique identifier, should only be set by native code */
    id?: string | null;
    /** Set to true if this ContactAddress contains the user's preferred value. */
    pref?: boolean;
    /** A string indicating what type of field this is, home for example. */
    type?: string | null;
    /** The full address formatted for display. */
    formatted?: string | null;
    /** The full street address. */
    streetAddress?: string | null;
    /** The city or locality. */
    locality?: string | null;
    /** The state or region. */
    region?: string | null;
    /** The zip code or postal code. */
    postalCode?: string | null;
    /** The country name. */
    country?: string | null;
    constructor(pref?: boolean, type?: string, formatted?: string, streetAddress?: string, locality?: string, region?: string, postalCode?: string, country?: string);
}
/**
 *  ContactError.
 *  An error code assigned by an implementation when an error has occurred
 * @constructor
 */
export declare class ContactError {
    /** Error code */
    code: number;
    /** Error message */
    message?: string;
    /**
     * Error codes
     */
    static UNKNOWN_ERROR: number;
    static INVALID_ARGUMENT_ERROR: number;
    static TIMEOUT_ERROR: number;
    static PENDING_OPERATION_ERROR: number;
    static IO_ERROR: number;
    static NOT_SUPPORTED_ERROR: number;
    static OPERATION_CANCELLED_ERROR: number;
    static PERMISSION_DENIED_ERROR: number;
    constructor(code: number);
}
/**
 * Generic contact field.
 */
export declare class ContactField {
    /** unique identifier, should only be set by native code */
    id?: string | null;
    /** A string that indicates what type of field this is, home for example. */
    type?: string | null;
    /** The value of the field, such as a phone number or email address. */
    value?: string | null;
    /** Set to true if this ContactField contains the user's preferred value. */
    pref?: boolean;
    constructor(type?: string, value?: string, pref?: boolean);
}
/**
 * ContactFindOptions.
 * Search options to filter
 */
export declare class ContactFindOptions {
    /** The search string used to find navigator.contacts. */
    filter?: string;
    /** Determines if the find operation returns multiple navigator.contacts. Defaults to false. */
    multiple?: boolean;
    /** Contact fields to be returned back. If specified, the resulting Contact object only features values for these fields. */
    desiredFields?: string[];
    /**
     * (Android only): Filters the search to only return contacts with a phone number informed.
     */
    hasPhoneNumber?: boolean;
    constructor(filter?: string, multiple?: boolean, desiredFields?: string[], hasPhoneNumber?: boolean);
}
/**
 * Contact name.
 */
export declare class ContactName {
    /** The complete name of the contact. */
    formatted?: string | null;
    /** The contact's family name. */
    familyName?: string | null;
    /** The contact's given name. */
    givenName?: string | null;
    /** The contact's middle name. */
    middleName?: string | null;
    /** The contact's prefix (example Mr. or Dr.) */
    honorificPrefix?: string | null;
    /** The contact's suffix (example Esq.). */
    honorificSuffix?: string | null;
    constructor(formatted?: string, familyName?: string, givenName?: string, middleName?: string, honorificPrefix?: string, honorificSuffix?: string);
}
/**
 * Contact organization.
 */
export declare class ContactOrganization {
    /** unique identifier, should only be set by native code */
    id?: string | null;
    /** Set to true if this ContactOrganization contains the user's preferred value. */
    pref?: boolean;
    /** A string that indicates what type of field this is, home for example. */
    type?: string | null;
    /** The name of the organization. */
    name?: string | null;
    /** The department the contract works for. */
    department?: string | null;
    /** The contact's title at the organization. */
    title?: string | null;
    constructor(type?: string, name?: string, department?: string, title?: string, pref?: boolean);
}
/**
 * Access and manage Contacts on the device.
 */
export declare class Contacts {
    /**
     * Returns an array of Contacts matching the search criteria.
     * @param fields that should be searched (see platform specific notes)
     * @param {ContactFindOptions} options that can be applied to contact searching
     * @return a promise that resolves with the array of Contacts matching search criteria
     */
    find(fields: ContactFieldType[], options?: ContactFindOptions): Promise<Contact[]>;
    /**
     * This function picks contact from phone using contact picker UI
     * @returns a promise that resolves with the selected Contact object
     */
    pickContact(): Promise<Contact>;
    /**
     * This function creates a new contact, but it does not persist the contact
     * to device storage. To persist the contact to device storage, invoke
     * contact.save().
     * @param properties an object whose properties will be examined to create a new Contact
     * @returns new Contact object
     */
    create(properties?: any): Contact;
    /**
     * iOS only
     * Create a contact using the iOS Contact Picker UI
     *
     * returns: a promise that resolves with the id of the created contact as param to successCallback
     */
    newContactUI(): Promise<string>;
}
