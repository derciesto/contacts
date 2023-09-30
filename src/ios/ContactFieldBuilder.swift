import Contacts

/**
 * Utilities for converting between our JSON-like key/value format
 * to native contact field objects for iOS
 */
public class ContactFieldBuilder {
  public static func buildEmailAddresses(_ values: [[String:String]]) -> [CNLabeledValue<NSString>] {
    var fields = [CNLabeledValue<NSString>]()
    for v in values {
      let labeledValue = CNLabeledValue<NSString>(label: v["label"], value: v["value"] as NSString? ?? "")
      fields.append(labeledValue)
    }
    return fields
  }

  /**
   * Build a list of labeled values of type CNPhoneNumber
   */
  public static func buildPhoneNumbers(_ values: [[String:String]]) -> [CNLabeledValue<CNPhoneNumber>] {
    var fields = [CNLabeledValue<CNPhoneNumber>]()
    for v in values {
      let labeledValue = CNLabeledValue<CNPhoneNumber>(label: v["label"], value: CNPhoneNumber(stringValue: v["value"] ?? ""))
      fields.append(labeledValue)
    }
    return fields
  }
  
  /**
   * Build a list of labeled values of type CNPostalAddress
   */
  public static func buildAddresses(_ values: [[String:Any]]) -> [CNLabeledValue<CNPostalAddress>] {
    var fields = [CNLabeledValue<CNPostalAddress>]()
    for field in values {
      guard let v = field["value"] as? [String:String] else {
        continue
      }
      
      let pa = CNMutablePostalAddress()
      pa.street = v["street"] ?? ""
      pa.city = v["city"] ?? ""
      pa.state = v["state"] ?? ""
      pa.postalCode = v["postalCode"] ?? ""
      let labeledValue = CNLabeledValue<CNPostalAddress>(label: v["label"], value: pa)
      fields.append(labeledValue)
    }
    return fields
  }
  
  /**
   * Create a date (year, month, day) from a JavaScript ISO formatted string.
   */
  public static func buildDate(_ value: String) -> DateComponents? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    guard let date = dateFormatter.date(from:value) else {
      return nil
    }
    let calendar = Calendar.current
    return calendar.dateComponents([.year, .month, .day], from: date)
  }
  
  /**
   * Create a date (year, month, day) from a unix timestamp
   */
  public static func buildDateFromJSTimestamp(_ value: Double) -> DateComponents? {
    let date = Date(timeIntervalSince1970: value / 1000)
    let calendar = Calendar.current
    return calendar.dateComponents([.year, .month, .day], from: date)
  }
  
  public static func buildData(_ value: String) -> Data? {
    return Data(base64Encoded: value, options: .ignoreUnknownCharacters)
  }
}
