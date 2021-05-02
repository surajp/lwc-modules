import { LightningElement } from "lwc";
import { describeFieldInfo } from "c/describeMetadataService";
import { flatten } from "c/utils";
import soql from "c/soqlService";

export default class SoqlDatatable extends LightningElement {
  fieldNames = []; //["Contact.LastName", "Contact.Account.Name", "Contact.Email", "Contact.Account.Owner.LastName"];
  data = [];
  columns = [];

  get hasColumns() {
    return this.columns && this.columns.length > 0;
  }

  async connectedCallback() {
    try {
      const query = "Select LastName,Account.Name,Email,Account.Owner.LastName from Contact";
      this.data = await soql(query);
      this.data = this.data.map((d) => flatten(d, "."));
      this.fieldNames = Object.keys(this.data[0])
        .filter((f) => query.indexOf(f) > -1)
        .map((f) => "Contact." + f);
      console.log("fieldnames", this.fieldNames);
      let result = await describeFieldInfo(this.fieldNames);
      this.columns = this.fieldNames.map((f) => ({ label: result[f].label, fieldName: f.replace(/Contact\./g, "") }));
      console.log("data", this.data);
    } catch (err) {
      console.error("An error ", err);
    }
  }
}
