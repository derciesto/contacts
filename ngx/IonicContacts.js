/// <reference types="cordova" />
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
    return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (_) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
/**
 * @hidden
 */
var utils = typeof cordova !== 'undefined' ? cordova.require("cordova/utils") : undefined;
/**
 * @hidden
 */
var PLUGIN_NAME = "IonicContacts";
var ɵ0 = function (resolve, rejects) {
    document.addEventListener("deviceready", function () {
        if (window[PLUGIN_NAME]) {
            return resolve();
        }
        return rejects("Contacts plugin not found. Are you sure you installed it?");
    });
};
/**
 * @hidden
 */
var deviceready = new Promise(ɵ0);
/**
 * Contains information about a single contact.
 */
var Contact = /** @class */ (function () {
    function Contact(id, displayName, name, nickname, phoneNumbers, emails, addresses, ims, organizations, birthday, note, photos, categories, urls) {
        this.id = id || null;
        this.rawId = null;
        this.displayName = displayName || null;
        this.name = name || null;
        this.nickname = nickname || null;
        this.phoneNumbers = phoneNumbers || null;
        this.emails = emails || null;
        this.addresses = addresses || null;
        this.ims = ims || null;
        this.organizations = organizations || null;
        this.birthday = birthday || null;
        this.note = note || null;
        this.photos = photos || null;
        this.categories = categories || null;
        this.urls = urls || null;
    }
    /**
     * Creates a deep copy of this Contact.
     * With the contact ID set to null.
     * @return copy of this Contact
     */
    Contact.prototype.clone = function () {
        var clonedContact = utils.clone(this);
        clonedContact.id = null;
        clonedContact.rawId = null;
        function nullIds(arr) {
            if (arr) {
                for (var i = 0; i < arr.length; ++i) {
                    arr[i].id = null;
                }
            }
        }
        // Loop through and clear out any id's in phones, emails, etc.
        nullIds(clonedContact.phoneNumbers);
        nullIds(clonedContact.emails);
        nullIds(clonedContact.addresses);
        nullIds(clonedContact.ims);
        nullIds(clonedContact.organizations);
        nullIds(clonedContact.categories);
        nullIds(clonedContact.photos);
        nullIds(clonedContact.urls);
        return clonedContact;
    };
    /**
     * Removes contact from device storage.
     */
    Contact.prototype.remove = function () {
        return __awaiter(this, void 0, void 0, function () {
            var _this = this;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, deviceready];
                    case 1:
                        _a.sent();
                        return [2 /*return*/, new Promise(function (resolve, reject) {
                                var fail = function (code) {
                                    reject(new ContactError(code));
                                };
                                if (_this.id === null) {
                                    fail(ContactError.UNKNOWN_ERROR);
                                }
                                else {
                                    cordova.exec(resolve, fail, PLUGIN_NAME, "remove", [_this.id]);
                                }
                            })];
                }
            });
        });
    };
    /**
     * Persists contact to device storage.
     */
    Contact.prototype.save = function () {
        return __awaiter(this, void 0, void 0, function () {
            var _this = this;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, deviceready];
                    case 1:
                        _a.sent();
                        return [2 /*return*/, new Promise(function (resolve, reject) {
                                var fail = function (code) {
                                    reject(new ContactError(code));
                                };
                                var success = function (result) {
                                    if (result) {
                                        var fullContact = ConvertUtils.create(result);
                                        resolve(ConvertUtils.toCordovaFormat(fullContact));
                                    }
                                    else {
                                        // no Entry object returned
                                        fail(ContactError.UNKNOWN_ERROR);
                                    }
                                };
                                var dupContact = ConvertUtils.toNativeFormat(utils.clone(_this));
                                cordova.exec(success, fail, PLUGIN_NAME, "save", [dupContact]);
                            })];
                }
            });
        });
    };
    /**
     * iOS only
     * Display a contact in the native Contact Picker UI
     *
     * @param allowEdit
     * true display the contact and allow editing it
     * false (default) display contact without editing
     */
    Contact.prototype.display = function (allowEdit) {
        return __awaiter(this, void 0, void 0, function () {
            var _this = this;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, deviceready];
                    case 1:
                        _a.sent();
                        return [2 /*return*/, new Promise(function (resolve, reject) {
                                if (_this.id === null) {
                                    var errorObj = new ContactError(ContactError.UNKNOWN_ERROR);
                                    reject(errorObj);
                                }
                                else {
                                    cordova.exec(resolve, reject, PLUGIN_NAME, "displayContact", [
                                        _this.id,
                                        allowEdit
                                    ]);
                                }
                            })];
                }
            });
        });
    };
    return Contact;
}());
export { Contact };
/**
 * Contact address.
 */
var ContactAddress = /** @class */ (function () {
    function ContactAddress(pref, type, formatted, streetAddress, locality, region, postalCode, country) {
        this.id = null;
        this.pref = typeof pref != "undefined" ? pref : false;
        this.type = type || null;
        this.formatted = formatted || null;
        this.streetAddress = streetAddress || null;
        this.locality = locality || null;
        this.region = region || null;
        this.postalCode = postalCode || null;
        this.country = country || null;
    }
    return ContactAddress;
}());
export { ContactAddress };
/**
 *  ContactError.
 *  An error code assigned by an implementation when an error has occurred
 * @constructor
 */
var ContactError = /** @class */ (function () {
    function ContactError(code) {
        this.code = code;
    }
    /**
     * Error codes
     */
    ContactError.UNKNOWN_ERROR = 0;
    ContactError.INVALID_ARGUMENT_ERROR = 1;
    ContactError.TIMEOUT_ERROR = 2;
    ContactError.PENDING_OPERATION_ERROR = 3;
    ContactError.IO_ERROR = 4;
    ContactError.NOT_SUPPORTED_ERROR = 5;
    ContactError.OPERATION_CANCELLED_ERROR = 6;
    ContactError.PERMISSION_DENIED_ERROR = 20;
    return ContactError;
}());
export { ContactError };
/**
 * Generic contact field.
 */
var ContactField = /** @class */ (function () {
    function ContactField(type, value, pref) {
        this.id = null;
        this.type = (type && type.toString()) || null;
        this.value = (value && value.toString()) || null;
        this.pref = typeof pref != "undefined" ? pref : false;
    }
    return ContactField;
}());
export { ContactField };
/**
 * ContactFindOptions.
 * Search options to filter
 */
var ContactFindOptions = /** @class */ (function () {
    function ContactFindOptions(filter, multiple, desiredFields, hasPhoneNumber) {
        this.filter = filter || "";
        this.multiple = typeof multiple != "undefined" ? multiple : false;
        this.desiredFields =
            typeof desiredFields != "undefined" ? desiredFields : [];
        this.hasPhoneNumber =
            typeof hasPhoneNumber != "undefined" ? hasPhoneNumber : false;
    }
    return ContactFindOptions;
}());
export { ContactFindOptions };
/**
 * Contact name.
 */
var ContactName = /** @class */ (function () {
    function ContactName(formatted, familyName, givenName, middleName, honorificPrefix, honorificSuffix) {
        this.formatted = formatted || null;
        this.familyName = familyName || null;
        this.givenName = givenName || null;
        this.middleName = middleName || null;
        this.honorificPrefix = honorificPrefix || null;
        this.honorificSuffix = honorificSuffix || null;
    }
    return ContactName;
}());
export { ContactName };
/**
 * Contact organization.
 */
var ContactOrganization = /** @class */ (function () {
    function ContactOrganization(type, name, department, title, pref) {
        this.id = null;
        this.pref = typeof pref != "undefined" ? pref : false;
        this.type = type || null;
        this.name = name || null;
        this.department = department || null;
        this.title = title || null;
    }
    return ContactOrganization;
}());
export { ContactOrganization };
/**
 * Access and manage Contacts on the device.
 */
var Contacts = /** @class */ (function () {
    function Contacts() {
    }
    /**
     * Returns an array of Contacts matching the search criteria.
     * @param fields that should be searched (see platform specific notes)
     * @param {ContactFindOptions} options that can be applied to contact searching
     * @return a promise that resolves with the array of Contacts matching search criteria
     */
    Contacts.prototype.find = function (fields, options) {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, deviceready];
                    case 1:
                        _a.sent();
                        return [2 /*return*/, new Promise(function (resolve, reject) {
                                if (!fields.length) {
                                    reject(new ContactError(ContactError.INVALID_ARGUMENT_ERROR));
                                }
                                else {
                                    // missing 'options' param means return all contacts
                                    options = options || { filter: "", multiple: true };
                                    var win = function (result) {
                                        var cs = [];
                                        for (var i = 0, l = result.length; i < l; i++) {
                                            cs.push(ConvertUtils.toCordovaFormat(ConvertUtils.create(result[i])));
                                        }
                                        resolve(cs);
                                    };
                                    cordova.exec(win, reject, PLUGIN_NAME, "search", [fields, options]);
                                }
                            })];
                }
            });
        });
    };
    /**
     * This function picks contact from phone using contact picker UI
     * @returns a promise that resolves with the selected Contact object
     */
    Contacts.prototype.pickContact = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, deviceready];
                    case 1:
                        _a.sent();
                        return [2 /*return*/, new Promise(function (resolve, reject) {
                                var win = function (result) {
                                    // if Contacts.pickContact return instance of Contact object
                                    // don't create new Contact object, use current
                                    var contact = result instanceof Contact ? result : ConvertUtils.create(result);
                                    resolve(ConvertUtils.toCordovaFormat(contact));
                                };
                                cordova.exec(win, reject, PLUGIN_NAME, "pickContact", []);
                            })];
                }
            });
        });
    };
    /**
     * This function creates a new contact, but it does not persist the contact
     * to device storage. To persist the contact to device storage, invoke
     * contact.save().
     * @param properties an object whose properties will be examined to create a new Contact
     * @returns new Contact object
     */
    Contacts.prototype.create = function (properties) {
        return ConvertUtils.create(properties);
    };
    /**
     * iOS only
     * Create a contact using the iOS Contact Picker UI
     *
     * returns: a promise that resolves with the id of the created contact as param to successCallback
     */
    Contacts.prototype.newContactUI = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, deviceready];
                    case 1:
                        _a.sent();
                        return [2 /*return*/, new Promise(function (resolve, reject) {
                                cordova.exec(resolve, reject, PLUGIN_NAME, "newContact", []);
                            })];
                }
            });
        });
    };
    return Contacts;
}());
export { Contacts };
/**
 * @hidden
 */
var ConvertUtils;
(function (ConvertUtils) {
    function toNativeFormat(contact) {
        var value = contact.birthday;
        if (value !== null && value !== undefined) {
            // try to make it a Date object if it is not already
            if (!utils.isDate(value)) {
                try {
                    value = new Date(value);
                }
                catch (exception) {
                    value = null;
                }
            }
            if (utils.isDate(value) && value !== null) {
                value = value.valueOf(); // convert to milliseconds
            }
            contact.birthday = value;
        }
        return contact;
    }
    ConvertUtils.toNativeFormat = toNativeFormat;
    function toCordovaFormat(contact) {
        var value = contact.birthday;
        if (value !== null) {
            try {
                contact.birthday = new Date(parseFloat(value));
                //we might get 'Invalid Date' which does not throw an error
                //and is an instance of Date.
                if (isNaN(contact.birthday.getTime())) {
                    contact.birthday = null;
                }
            }
            catch (exception) {
                console.log("Cordova Contact toCordovaFormat error: exception creating date.");
            }
        }
        return contact;
    }
    ConvertUtils.toCordovaFormat = toCordovaFormat;
    function create(properties) {
        var contact = new Contact();
        for (var i in properties) {
            if (typeof contact[i] !== "undefined" && properties.hasOwnProperty(i)) {
                contact[i] = properties[i];
            }
        }
        return contact;
    }
    ConvertUtils.create = create;
})(ConvertUtils || (ConvertUtils = {}));
export { ɵ0 };
