# LWC Apex Services :fire: :zap:

A collection of LWC modules aimed at eliminating the need for writing Apex code for building LWCs, making it easier for JS devs to build components quicker on the Salesforce platform.

It contains modules for the following operations:

- SOQL

  Import `soqlService` into your lwc and issue queries directly from your lwc!

  ```js
    import soql from "c/soqlService";
    ...
    this.data = await soql( "Select LastName,Account.Name,Email,Account.Owner.LastName from Contact");
  ```

  Refer to [soqlDataTable](examples/main/default/lwc/soqlDatatable/) example for details.

- DML

  Import all exports from `dmlService` into your lwc and use `insert`,`update`,`upsert` and `del` operations as needed.

  ```js
    import * as dml from "c/dmlService";
    ...
    const acctId = (await dml.insert({ Name: acctName }, "Account"))[0]; //the method accepts either a single json record or json array and always returns an array of ids.
  ```

  For `insert` and `upsert` operations, the sobject type must be specified as the second argument.

- Object and Field Describes

  ```js
  import { describeSObjectInfo } from "c/describeMetadataService";
      ...

  describeSObjectInfo(["Account", "Contact"]) //Get Describe information for multiple SObjects in a single call
    .then((resp) => {
      // the response has the shape of List<DescribeSObjectResult>
      console.log(">> got child object info ", resp);
    })
    .catch((err) => {
      // handle error
    });

  ```

  ```js
  import { describeFieldInfo } from "c/describeMetadataService";
        ...
  // Retrieve field describe info for multiple fields in a single call, including relationship fields
  describeFieldInfo(["Account.Name","Contact.Account.Parent.Industry"])
  .then(resp=>{
    // the resp has the shape of List<DescribeFieldResult>
  })

  ```

  Refer to [soqlDatatable](examples/main/default/lwc/soqlDatatable/) for an example

- Callouts via Apex (using Named Creds, if available)

  Call APIs that don't support CORS or require authentication, via Apex using Named Credentials.

  ```js

      import apexCallout from "c/calloutService";
        ...

      let contact = JSON.parse((await apexCallout("callout:random_user/api")).body); //https://randomuser.me/
  ```

  The full signature for this function is `apexCallout(endPoint,method,headers,body)`. `headers` and `body` expect JSON inputs

- Calling Salesforce APIs within your org directly from the LWC (Requires CSP Trusted Sites and CORS setup)

  ```js
  import sfapi from "c/apiService";
      ...

  // Calling Composite API for inserting multiple related records at once
  let response = await sfapi(
    "/composite/" /*path excluding base url*/,
    "POST" /*method*/,
    {} /* additional headers */,
    JSON.stringify(compositeReq) /* request body */
  );
  ```

  Refer to [compositeApiExample](examples/main/default/lwc/compositeApiExample/) for the full example.

- Publish Platform Events

  ```js
    import * as platformEventService from "c/platformEventService";
    ...
    platformEventService.publish('Test_Event__e', payload); //payload would be a json object with the shape of the Platform Event being published
  ```

  [Example](examples/main/default/lwc/platformEventExample/).

  This is still a work in progress :wrench:. Feedback and contributions welcome! :pray:
