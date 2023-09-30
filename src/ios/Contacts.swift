import Foundation
import Contacts
import ContactsUI

public typealias ContactPickedBlock = (NSError?, Contact?) -> Void
public typealias ContactCreatedBlock = (NSError?, Contact?) -> Void
public typealias PlainContactField = [String:Any]

/**
 *
 * https://developer.apple.com/library/content/samplecode/ManagingContactsUI/Listings/ManagingContactsUI_ContactPickerViewControllerWithPredicates_ForSelectionOfContactViewController_swift.html
 */
public class Contacts : NSObject, CNContactPickerDelegate, CNContactViewControllerDelegate {
  var cnPicker: CNContactPickerViewController?
  var cnContactController: CNContactViewController?
  var cnContactControllerNavController: UINavigationController?
  var presentingVc: UIViewController?
  
  var pickedCompletion: ContactPickedBlock?
  var newContactCompletion: ContactCreatedBlock?

  let keysToFetch = [
    CNContactBirthdayKey,
    CNContactDatesKey,
    CNContactDepartmentNameKey,
    CNContactEmailAddressesKey,
    CNContactFamilyNameKey,
    CNContactGivenNameKey,
    CNContactIdentifierKey,
    CNContactImageDataAvailableKey,
    CNContactInstantMessageAddressesKey,
    CNContactJobTitleKey,
    CNContactMiddleNameKey,
    CNContactNamePrefixKey,
    CNContactNameSuffixKey,
    CNContactNicknameKey,
    CNContactNonGregorianBirthdayKey,
    CNContactOrganizationNameKey,
    CNContactPhoneNumbersKey,
    CNContactPhoneticFamilyNameKey,
    CNContactPhoneticGivenNameKey,
    CNContactPhoneticMiddleNameKey,
    CNContactPostalAddressesKey,
    CNContactPreviousFamilyNameKey,
    CNContactRelationsKey,
    CNContactSocialProfilesKey,
    CNContactThumbnailImageDataKey,
    CNContactTypeKey,
    CNContactUrlAddressesKey,
    CNContactViewController.descriptorForRequiredKeys()
  ] as! [CNKeyDescriptor]
  
  fileprivate enum SearchableField: String {
    case all = "*"
    case name = "name"
    case phone = "phoneNumbers"
    case email = "emails"
  }
  
  public func getContacts(completion: @escaping ([Contact]) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async(execute: { () -> Void in
      let builtContacts = self.buildContacts(self.getAllContacts())
      DispatchQueue.main.async(execute: { () -> Void in
        completion(builtContacts)
      })
    })
  }
  
  public func getAllContacts() -> [CNContact] {
    let store = CNContactStore()
    let fetchRequest = CNContactFetchRequest(keysToFetch: self.keysToFetch)

    fetchRequest.sortOrder = CNContactSortOrder.givenName
    var contacts = [CNContact]()
    do {
      try store.enumerateContacts(with: fetchRequest, usingBlock: { (contact, _) in
        contacts.append(contact)
      })
    } catch {
      print("Unable to list contacts:", error.localizedDescription)
    }
    return contacts
  }

  public func find(fields: ContactFields, completion: @escaping ([Contact]) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async(execute: { () -> Void in
      // allow the wildcard to override anything else
      let findAll: Bool = (fields[SearchableField.all.rawValue] != nil)
      
      // normalize the other fields and their associated search text, ignoring empty strings
      let searchOptions = fields.compactMap({ (key: String, value: Any) -> (field: SearchableField, text: String)? in
        if let field = SearchableField(rawValue: key) {
          if field != .all, let searchText = value as? String, !searchText.isEmpty {
            return (field, searchText)
          }
        }
        else {
          print("Unsupported search field \"\(key)\"")
        }
        return nil
      })
      
      // now do our search
      var contacts: [CNContact] = []
      if findAll {
        contacts = self.getAllContacts()
      }
      else {
        // define a query action
        let store = CNContactStore()
        let queryContacts = { (predicate: NSPredicate) -> Set<CNContact> in
          do {
            return Set(try store.unifiedContacts(matching: predicate, keysToFetch: self.keysToFetch))
          } catch {
            print("Error querying contacts:", error.localizedDescription)
            return Set<CNContact>()
          }
        }
        // query as needed, storing in a set to filter out duplicates
        var contactSet = Set<CNContact>()
        for option in searchOptions {
          switch option.field {
          case .name:
            let predicate = CNContact.predicateForContacts(matchingName: option.text)
            contactSet = contactSet.union(queryContacts(predicate))
          case .phone:
            let predicate = CNContact.predicateForContacts(matching: CNPhoneNumber(stringValue: option.text))
            contactSet = contactSet.union(queryContacts(predicate))
          case .email:
            let predicate = CNContact.predicateForContacts(matchingEmailAddress: option.text)
            contactSet = contactSet.union(queryContacts(predicate))
          case .all:
            // no-op, handled separately
            break
          }
        }
        // turn the set into an array, sorting by given name to match the behavior of 'getAllContacts'
        contacts = Array(contactSet).sorted(by: { (lContact, rContact) -> Bool in
          return (lContact.givenName.compare(rContact.givenName) == .orderedAscending)
        })
      }
      // transform the array of contacts and return them
      let builtContacts = self.buildContacts(contacts)
      DispatchQueue.main.async(execute: { () -> Void in
        completion(builtContacts)
      })
    })
  }
  
  public func get(_ id: String, completion: @escaping ([Contact]) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async(execute: { () -> Void in
      let store = CNContactStore()
      
      let predicate = CNContact.predicateForContacts(withIdentifiers: [id])
      
      var contacts = [CNContact]()
      do {
        contacts = try store.unifiedContacts(matching: predicate, keysToFetch: self.keysToFetch)
      } catch {
        print("Unable to query contacts:", error.localizedDescription)
      }
      let builtContacts = self.buildContacts(contacts)
      DispatchQueue.main.async(execute: { () -> Void in
        completion(builtContacts)
      })
    })
  }
  
  
  public func delete(_ identifiers: [String], completion: @escaping (Int) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async(execute: { () -> Void in
      let store = CNContactStore()
      
      let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName)]
      let predicate = CNContact.predicateForContacts(withIdentifiers: identifiers)
      
      var contacts = [CNContact]()
      do {
        let saveRequest = CNSaveRequest()
        contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
        for contact in contacts {
          print("Deleting contact", contact.givenName, contact.familyName)
          saveRequest.delete(contact.mutableCopy() as! CNMutableContact)
        }
        
        do {
          try store.execute(saveRequest)
        } catch {
          print("Unable to delete contact:", error.localizedDescription)
        }
      } catch {
        print("Unable to delete contacts:", error.localizedDescription)
      }
      
      DispatchQueue.main.async(execute: { () -> Void in
        completion(contacts.count)
      })
    })
  }
  
  /**
   * Create a contact with the given fields. These fields follow iOS
   */
  public func create(_ fields: ContactFields) throws -> Contact {
    let c = CNMutableContact()
    c.givenName = F(fields, "givenName", "")
    c.familyName = F(fields, "familyName", "")
    c.middleName = F(fields, "middleName", "")
    c.jobTitle = F(fields, "jobTitle", "")
    c.nickname = F(fields, "nickname", "")
    c.namePrefix = F(fields, "namePrefix", "")
    c.organizationName = F(fields, "organizationName", "")
    c.birthday = ContactFieldBuilder.buildDate(F(fields, "birthday", ""))
    c.emailAddresses = ContactFieldBuilder.buildEmailAddresses(F(fields, "emailAddresses", [[String:String]]()))
    c.phoneNumbers = ContactFieldBuilder.buildPhoneNumbers(F(fields, "phoneNumbers", [[String:String]]()))
    c.postalAddresses = ContactFieldBuilder.buildAddresses(F(fields, "postalAddresses", [[String:Any]]()))
    c.imageData = ContactFieldBuilder.buildData(F(fields, "imageData", ""))
    let store = CNContactStore()
    let saveRequest = CNSaveRequest()
    saveRequest.add(c, toContainerWithIdentifier: nil)
    try store.execute(saveRequest)
    return Contact(c)
  }
  
  public func save(_ contact: Contact) throws -> CNMutableContact {
    let store = CNContactStore()
    let saveRequest = CNSaveRequest()
    let mutable = contact.getNativeContact().mutableCopy() as! CNMutableContact
    saveRequest.add(mutable, toContainerWithIdentifier: nil)
    try store.execute(saveRequest)
    return mutable
  }
  
  public func update(_ contact: Contact) throws -> CNMutableContact {
    let store = CNContactStore()
    let saveRequest = CNSaveRequest()
    let mutable = contact.getNativeContact().mutableCopy() as! CNMutableContact
    saveRequest.update(mutable)
    try store.execute(saveRequest)
    return mutable
  }
  
  /**
   * Grab a field from the given fields object, using the supplied type
   */
  func F<T>(_ fields: ContactFields, _ key: String, _ defaultValue: T) -> T {
    return fields[key] as? T ?? defaultValue
  }

  public func displayContact(vc: UIViewController, contact: Contact, allowEdit: Bool, completion: @escaping ContactCreatedBlock) {
    self.presentingVc = vc
    cnContactController = CNContactViewController(for: contact.getNativeContact())
    cnContactController!.delegate = self
    cnContactController!.allowsActions = true
    cnContactController!.allowsEditing = allowEdit
    self.cnContactControllerNavController = UINavigationController(rootViewController: cnContactController!)
    cnContactController?.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
    vc.present(cnContactControllerNavController!, animated: true, completion: nil)
  }
  @objc func doneTapped(sender: UIBarButtonItem) {
    self.presentingVc!.dismiss(animated: true, completion: nil)
  }
  public func newContact(vc: UIViewController, completion: @escaping ContactCreatedBlock) {
    let newContact = CNContact()
    cnContactController = CNContactViewController(forNewContact: newContact)
    cnContactController!.delegate = self
    self.newContactCompletion = completion
    
    self.cnContactControllerNavController = UINavigationController(rootViewController: cnContactController!)
    
    vc.present(cnContactControllerNavController!, animated: true, completion: nil)
  }
  
  /**
   * Prompt the user to pick one or more contacts from their contacts list.
   */
  public func pickContact(vc: UIViewController, completion: @escaping ContactPickedBlock) {
    self.cnPicker = CNContactPickerViewController()
    self.pickedCompletion = completion
    
    let cnPicker = self.cnPicker!
    
    cnPicker.delegate = self
    cnPicker.displayedPropertyKeys = [CNContactNicknameKey, CNContactEmailAddressesKey]
    vc.present(cnPicker, animated: true, completion: nil)
  }
  
  public func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
    if pickedCompletion != nil {
      pickedCompletion!(nil, buildContact(contact))
    }
  }
  
  public func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
    if pickedCompletion != nil {
      pickedCompletion!(nil, nil)
    }
  }
  
  public func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
    if newContactCompletion != nil {
      if contact != nil {
        newContactCompletion!(nil, buildContact(contact!))
      } else {
        newContactCompletion!(nil, nil)
      }
    }
    
    cnContactController?.dismiss(animated: true, completion: nil)
  }
  
  public func contactViewController(_ viewController: CNContactViewController, shouldPerformDefaultActionFor property: CNContactProperty) -> Bool {
    return true
  }
  
  func buildContacts(_ contacts: [CNContact]) -> [Contact] {
    var builtContacts = [Contact]()
    
    for contact in contacts {
      builtContacts.append(Contact(contact))
    }
    
    return builtContacts
  }
  
  func buildContact(_ contact: CNContact) -> Contact {
    return Contact(contact)
  }
}
