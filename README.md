The Contacts plugin provides access to read, write, or select device contacts.

<native-ent-install plugin-id="contacts" variables=""></native-ent-install>

Usage
-----

The Contacts plugin ship with a native Angular & es2015+/Typescript wrappers as well as being available on window.
```typescript
// Angular
import { Contacts } from '@ionic-enterprise/contacts/ngx';
import { Contact, ContactName, ContactField  } from '@ionic-enterprise/contacts';

...

constructor(private contacts: Contacts) { }

async createContact() {
  let contact = this.contacts.create();
  contact.name = new ContactName(null, 'Smith', 'John');
  contact.phoneNumbers = [new ContactField('mobile', '6471234567')];
  contact.save().then(
    () => console.log('Contact saved!', contact),
    (error: any) => console.error('Error saving contact.', error)
  );
}

...

// ES2015+/TypeScript
import { Contacts, Contact, ContactName, ContactField } from '@ionic-enterprise/contacts';

let contact = Contacts.create();
contact.name = new ContactName(null, 'Smith', 'John');
contact.phoneNumbers = [new ContactField('mobile', '6471234567')];
contact.save().then(
  () => console.log('Contact saved!', contact),
  (error: any) => console.error('Error saving contact.', error)
);

...

// Vanilla JS
document.addEventListener('deviceready', () => {
  let contact = IonicContacts.create();
  contact.name = {familyName: 'Smith', givenName: 'John'};
  contact.phoneNumbers = {type: 'mobile', value: '6471234567'};
  contact.save().then(
    () => console.log('Contact saved!', contact),
    (error) => console.error('Error saving contact.', error)
  );
});
```
