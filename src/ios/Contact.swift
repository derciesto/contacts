import Foundation
import ContactsUI

public typealias ContactFields = [String:Any]

public class Contact {
  let cnContact: CNContact
  
  public init(_ cnContact: CNContact) {
    self.cnContact = cnContact
  }
  
  /**
   * Get the low-level native contact for this Contact
   */
  public func getNativeContact() -> CNContact {
    return self.cnContact
  }

}
