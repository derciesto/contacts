import Foundation
import Contacts

enum CDVContactError: Int {
  case UNKNOWN_ERROR = 0
  case INVALID_ARGUMENT_ERROR = 1
  case TIMEOUT_ERROR = 2
  case PENDING_OPERATION_ERROR = 3
  case IO_ERROR = 4
  case NOT_SUPPORTED_ERROR = 5
  case OPERATION_CANCELLED_ERROR = 6
  case PERMISSION_DENIED_ERROR = 20
}

@objc(IonicContacts)
class IonicContacts: CDVPlugin {
  lazy var contacts = Contacts()
  
  override func pluginInitialize() {
    super.pluginInitialize()
  }

  @objc func newContact(_ command: CDVInvokedUrlCommand) {
    // Open iOS's new contact view controller
    contacts.newContact(vc: viewController, completion: {(error: NSError?, contact: Contact?) in
      if contact == nil {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: CDVContactError.OPERATION_CANCELLED_ERROR.rawValue)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        return
      }
      
      let cordovaContact = self.buildCordovaContact(contact!)
      
      let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: cordovaContact)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc func displayContact(_ command: CDVInvokedUrlCommand) {
    guard let id = command.argument(at: 0) as? String else {
      let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
      return
    }
    
    let allowEdit = command.argument(at: 1, withDefault: false) as! Bool
    
    commandDelegate.run {
      self.contacts.get(id) { (contacts) in
        if contacts.count > 0 {
          let contact = contacts[0]
          self.contacts.displayContact(vc: self.viewController, contact: contact, allowEdit: allowEdit,  completion: {(error: NSError?, contact: Contact?) in
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
          })
        }
      }
    }
  }

  @objc func pickContact(_ command: CDVInvokedUrlCommand) {
    let status = CNContactStore.authorizationStatus(for: .contacts)
    if status == .notDetermined {
      CNContactStore().requestAccess(for: CNEntityType.contacts, completionHandler: {(_ granted: Bool, _ error: Error?) -> Void in
        if granted {
          self.callPickContact(command)
        } else {
          self.unauthorizedError(command)
        }
      })
    } else if status == .authorized {
      self.callPickContact(command)
    } else {
      self.unauthorizedError(command)
    }
  }

  func unauthorizedError(_ command: CDVInvokedUrlCommand) {
    let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: CDVContactError.PERMISSION_DENIED_ERROR.rawValue)
    self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
  }

  func callPickContact(_ command: CDVInvokedUrlCommand) {
    contacts.pickContact(vc: viewController, completion: {(error: NSError?, contact: Contact?) in
      if contact == nil {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: CDVContactError.OPERATION_CANCELLED_ERROR.rawValue)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        return
      }
      let cordovaContact = self.buildCordovaContact(contact!)
      
      let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: cordovaContact)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc func search(_ command: CDVInvokedUrlCommand) {
    guard let fields = command.argument(at: 0) as? [String] else {
      let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
      return
    }
    
    guard let options = command.argument(at: 1) as? [String:Any] else {
      let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
      return
    }
    
    commandDelegate.run {
      let filter = options["filter"] as? String ?? ""
      
      let searchFields = self.buildSearchFields(fields, filter)
      
      self.contacts.find(fields: searchFields) { (contacts) in
        let cordovaContacts = self.buildCordovaContacts(contacts)
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: cordovaContacts)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
      }
    }
  }

  @objc func save(_ command: CDVInvokedUrlCommand) {
    guard let contactData = command.argument(at: 0) as? [String:Any] else {
      let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
      return
    }
    
    
    commandDelegate.run {
      // If the contact had an id, get the instance from the contacts database
      // and update it
      if let id = contactData["id"] as? String {
        self.contacts.get(id) { (contacts) in
          if contacts.count > 0 {
            let contact = contacts[0]
            do {
              let returnContact = ContactsCordovaUtils.fromCordovaContactsFormat(contactData, contact.getNativeContact().mutableCopy() as! CNMutableContact)
              _ = try self.contacts.update(returnContact)
              let cordovaContact = ContactsCordovaUtils.toCordovaContactsFormat(returnContact)
              let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: cordovaContact)
              self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            } catch {
              let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
              self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            }
          }
        }
      } else {
        // Create the contact
        do {
          let wrappedContact = ContactsCordovaUtils.fromCordovaContactsFormat(contactData)
          let mutableContact = try self.contacts.save(wrappedContact)
          let returnContact = Contact(mutableContact)
          let cordovaContact = ContactsCordovaUtils.toCordovaContactsFormat(returnContact)
          let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: cordovaContact)
          self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        } catch {
          let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
          self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        }
      }
    }
  }

  @objc func remove(_ command: CDVInvokedUrlCommand) {
    guard let id = command.arguments[0] as? String else {
      let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
      return
    }
    
    commandDelegate.run {
      self.contacts.get(id) { (contacts) in
        if contacts.count > 0 {
          self.contacts.delete([id], completion: { (numDeleted) in
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
          })
        }
      }
    }
  }
  
  func buildCordovaContacts(_ contacts: [Contact]) -> [[String:Any]] {
    var c = [[String:Any]]()
    for contact in contacts {
      c.append(buildCordovaContact(contact))
    }
    return c
  }
  
  func buildCordovaContact(_ contact: Contact) -> [String:Any] {
    return ContactsCordovaUtils.toCordovaContactsFormat(contact)
  }
  
  func buildSearchFields(_ fields: [String], _ filter: String) -> [String:Any] {
    var searchFields = [String:Any]()
    fields.forEach { (field) in
      searchFields[field] = filter
    }
    return searchFields
  }
}
