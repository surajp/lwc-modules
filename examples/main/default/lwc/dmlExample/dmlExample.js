import { LightningElement } from "lwc";
import * as dml from "c/dmlService";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class DmlExample extends LightningElement {
  async handleSave() {
    try {
      const acctName = this.template.querySelector("lightning-input.acct").value;
      const cntctLastName = this.template.querySelector("lightning-input.lastname").value;
      const cntctFirstName = this.template.querySelector("lightning-input.firstname").value;
      const acctId = (await dml.insert({ Name: acctName }, "Account"))[0];
      const cntctId = await dml.insert(
        { LastName: cntctLastName, FirstName: cntctFirstName, AccountId: acctId },
        "Contact"
      );
      console.log("Account and Contact inserted", acctId, cntctId);
      this.dispatchEvent(new ShowToastEvent({ variant: "success", message: "Records created successfully" }));
    } catch (e) {
      this.dispatchEvent(new ShowToastEvent({ variant: "error", message: e.message || e.body.message }));
    }
  }
}
