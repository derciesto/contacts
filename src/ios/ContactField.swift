import Foundation
import Contacts

public class ContactField<T> {
  let key: String
  let value: T

  public init(_ key: String, _ value: T) {
    self.key = key
    self.value = value
  }
}
