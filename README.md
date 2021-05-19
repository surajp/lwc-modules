# LWC Apex Services

A collection of lwc modules that aim to eliminate the need for writing apex code for building any LWC.
It contains lwc modules for the following operations:

- SOQL
  Import `soqlService` into your lwc and issue queries directly from your lwc!

  ```js
    import soql from "c/soqlService";
    ...
    this.data = await soql( "Select LastName,Account.Name,Email,Account.Owner.LastName from Contact");
  ```

  Refer to [soqlDataTable](examples/main/default/lwc/soqlDatatable/) example for details.

- DML
- Object and Field Describes
- Callouts via Apex (using Named Creds, if available)
- Calling Salesforce APIs directly from the client (Requires CSP and CORS setup)
