import { LightningElement } from "lwc";
import sfapi from "c/apiService";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { reduceErrors, processCompositeApiResponse } from "c/utils";

export default class CompositeApiExample extends LightningElement {
  accts = [];
  cntcs = [];

  handleClick(event) {
    event.preventDefault();
    this.setupAccounts();
    this.setupContacts();
    this.createAccountsAndContacts();
    this.accts = [];
    this.cntcs = [];
  }

  setupAccounts() {
    this.accts.push({ body: { Name: "Amazon", Industry: "E-commerce" }, referenceId: "Amazon" });
    this.accts.push({ body: { Name: "Facebook", Industry: "Social Media" }, referenceId: "Facebook" });
    this.accts.push({ body: { Name: "Google", Industry: "Search" }, referenceId: "Google" });
    this.accts.push({ body: { Name: "Netflix", Industry: "Entertainment" }, referenceId: "Netflix" });
  }

  setupContacts() {
    /* create one contact for each Account */
    this.cntcs.push({
      body: {
        LastName: "Bezos",
        FirstName: "Jeff",
        Email: "bezos@amazon.example.com",
        Title: "CEO of Amazon",
        AccountId: "@{Amazon.id}"
      },
      referenceId: "Jeff"
    });

    this.cntcs.push({
      body: {
        LastName: "Zuckerberg",
        FirstName: "Marc",
        Email: "marc@facebook.example.com",
        Title: "CEO of Facebook",
        AccountId: "@{Facebook.id}"
      },
      referenceId: "Marc"
    });

    this.cntcs.push({
      body: {
        LastName: "Pichai",
        FirstName: "Sundar",
        Email: "pichai@google.example.com",
        Title: "CEO of Google",
        AccountId: "@{Google.id}"
      },
      referenceId: "Sundar"
    });

    this.cntcs.push({
      body: {
        LastName: "Hastings",
        FirstName: "Reed",
        Email: "reed@netflix.example.com",
        Title: "CEO of Netflix",
        AccountId: "@{Netflix.id}"
      },
      referenceId: "Reed"
    });

    /* create subrequests for Account and Contact by adding `method` and `url` properties */
    this.accts = this.accts.map((a) => ({
      ...a,
      method: "POST",
      url: "/services/data/v51.0/sobjects/Account"
    }));
    this.cntcs = this.cntcs.map((c) => ({
      ...c,
      method: "POST",
      url: "/services/data/v51.0/sobjects/Contact"
    }));
  }

  async createAccountsAndContacts() {
    try {
      let compositeReq = { allOrNone: true, compositeRequest: [...this.accts, ...this.cntcs] };
      let response = await sfapi(
        "/composite/" /*path excluding base url*/,
        "POST" /*method*/,
        {} /* additional headers */,
        JSON.stringify(compositeReq) /* request body */
      );
      response = processCompositeApiResponse(response);
      if (response.errors === 0)
        this.dispatchEvent(new ShowToastEvent({ variant: "success", message: "Records created successfully" }));
      else
        this.dispatchEvent(
          new ShowToastEvent({
            variant: "error",
            mode: "sticky",
            message: `Failed to process ${response.errors} records ${response.message}`
          })
        );
    } catch (error) {
      const errorStr = reduceErrors(error);
      this.dispatchEvent(new ShowToastEvent({ variant: "error", message: `Failed to create records ${errorStr}` }));
    }
  }
}
