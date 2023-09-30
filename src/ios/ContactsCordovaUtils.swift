import Foundation
import Contacts

class ContactsCordovaUtils {
  public static func gs(_ v: Any?, _ d: String = "") -> String {
    return v as? String ?? d
  }
  
  public static func ga(_ v: Any?) -> [[String:Any]] {
    guard let array = v as? [[String:Any]] else {
      return []
    }
    return array
  }
  
  public static func fromCordovaContactsFormat(_ fields: [String:Any], _ mutableContact: CNMutableContact = CNMutableContact()) -> Contact {
    let f = fields
    let c = mutableContact
    let displayName = gs(f["displayName"])
    let nameParts = displayName.split(separator: " ")
    if nameParts.count > 1 {
      c.givenName = String.init(nameParts.first!)
      c.familyName = String(nameParts.last!)
    }
    let name = f["name"] as! [String:Any]
    c.givenName = gs(name["givenName"], c.givenName)
    c.middleName = gs(name["middleName"])
    c.familyName = gs(name["familyName"], c.familyName)
    c.namePrefix = gs(name["honorificPrefix"])
    c.nameSuffix = gs(name["honorificSuffix"])
    c.jobTitle = gs(f["jobTitle"])
    c.nickname = gs(f["nickname"])
    
    if let birthdayVal = f["birthday"] as? Double {
      c.birthday = ContactFieldBuilder.buildDateFromJSTimestamp(birthdayVal)
    }
    
    c.emailAddresses = buildEmailAddresses(ga(f["emails"]))
    c.phoneNumbers = buildPhoneNumbers(ga(f["phoneNumbers"]))
    c.instantMessageAddresses = buildInstantMessageAddresses(ga(f["ims"]))
    c.postalAddresses = buildAddresses(ga(f["addresses"]))
    c.organizationName = getOrgName(ga(f["organizations"]))

    return Contact(c)
  }
  
  static func buildEmailAddresses(_ items: [[String:Any]]) -> [CNLabeledValue<NSString>] {
    var r = [CNLabeledValue<NSString>]()
    for i in items {
      let val = CNLabeledValue<NSString>(label: i["type"] as? String ?? "", value: i["value"] as? NSString ?? "")
      r.append(val)
    }
    return r
  }
  
  static func buildPhoneNumbers(_ items: [[String:Any]]) -> [CNLabeledValue<CNPhoneNumber>] {
    var r = [CNLabeledValue<CNPhoneNumber>]()
    for i in items {
      let number = CNPhoneNumber(stringValue: i["value"] as? String ?? "")
      let val = CNLabeledValue<CNPhoneNumber>(label: i["type"] as? String ?? "", value: number)
      r.append(val)
    }
    return r
  }
  
  static func buildInstantMessageAddresses(_ items: [[String:Any]]) -> [CNLabeledValue<CNInstantMessageAddress>] {
    var r = [CNLabeledValue<CNInstantMessageAddress>]()
    for i in items {
      let a = CNInstantMessageAddress(username: i["value"] as? String ?? "", service: i["type"] as? String ?? "")
      let val = CNLabeledValue<CNInstantMessageAddress>(label: i["type"] as? String ?? "", value: a)
      r.append(val)
    }
    return r
  }
  
  static func buildAddresses(_ items: [[String:Any]]) -> [CNLabeledValue<CNPostalAddress>] {
    var r = [CNLabeledValue<CNPostalAddress>]()
    for i in items {
      let a = CNMutablePostalAddress()
      a.city = gs(i["locality"])
      a.state = gs(i["region"])
      a.postalCode = gs(i["postalCode"])
      a.country = gs(i["country"])
      a.street = gs(i["streetAddress"])
      let val = CNLabeledValue<CNPostalAddress>(label: i["type"] as? String ?? "", value: a)
      r.append(val)
    }
    return r
  }
  
  static func getOrgName(_ orgs: [Any]) -> String {
    return ""
  }
  
  public static func toCordovaContactsFormat(_ contact: Contact) -> [String:Any] {
    let c = contact.getNativeContact()
    var r = [String:Any]()
    r["id"] = c.identifier
    r["rawId"] = nil
    r["displayName"] = nil
    
    var n = [String:String]()
    n["givenName"] = c.givenName
    n["honorificSuffix"] = c.nameSuffix
    n["formatted"] = CNContactFormatter.string(from: c, style: .fullName)
    n["middleName"] = c.middleName
    n["familyName"] = c.familyName
    n["honorificPrefix"] = c.namePrefix
    
    r["name"] = n
    
    r["nickname"] = c.nickname
    
    var p = [[String:Any]]()
    var e = [[String:Any]]()
    var a = [[String:Any]]()
    var o = [[String:Any]]()
    
    var id = 0
    for phoneNumber in c.phoneNumbers {
      let label = CNLabeledValue<CNPhoneNumber>.localizedString(forLabel: phoneNumber.label ?? "")
      var ph = [String:Any]()
      ph["value"] = phoneNumber.value.stringValue
      ph["pref"] = false
      ph["id"] = id
      ph["type"] = label
      p.append(ph)
      id += 1
    }
    
    id = 0
    for email in c.emailAddresses {
      let label = CNLabeledValue<NSString>.localizedString(forLabel: email.label ?? "")
      var em = [String:Any]()
      em["value"] = email.value
      em["pref"] = false
      em["id"] = id
      em["type"] = label
      e.append(em)
      id += 1
    }
    
    id = 0
    for address in c.postalAddresses {
      let labelValue = address.label ?? ""
      let label = CNLabeledValue<CNPostalAddress>.localizedString(forLabel: labelValue)
      let ad: [String:Any] = [
        "pref": "false",
        "locality": address.value.city,
        "region": address.value.state,
        "id": id,
        "postalCode": address.value.postalCode,
        "country": address.value.country,
        "type": label,
        "streetAddress": address.value.street
      ]
      a.append(ad)
      id += 1
    }
    
    let org: [String:Any] = [
      "pref": "false",
      "title": c.jobTitle,
      "name": c.organizationName,
      "department": c.departmentName,
      "type": ""
    ]
    
    o.append(org)
    
    r["ims"] = nil
    
    if c.birthday?.date != nil {
      r["birthday"] = c.birthday!.date!.timeIntervalSince1970 * 1000
    } else {
      r["birthday"] = ""
    }
    r["phoneNumbers"] = p
    r["emails"] = e
    r["addresses"] = a
    r["organizations"] = o
    
    r["note"] = nil
    r["photos"] = nil
    r["categories"] = nil
    r["urls"] = nil
    
    return r
  }
}
