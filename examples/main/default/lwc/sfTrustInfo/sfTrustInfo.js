/**
 * The api does not work for scratch org instances! See comment below
 */
import { LightningElement } from "lwc";
import apexCallout from "c/calloutService";

const INSTANCE = window.location.origin.match(/https:\/\/([^.]+).*/)[1];
//const INSTANCE = "org62"; //If you want to try this out in a scratch org, uncomment this line and comment the above line
export default class SfTrustInfo extends LightningElement {
  maintenances = [];
  trustData = [];

  get statusLink() {
    return `https://status.salesforce.com/instances/${this.trustData.key}`;
  }

  async connectedCallback() {
    let resp = await apexCallout(`https://api.status.salesforce.com/v1/instanceAliases/${INSTANCE}/status`);
    this.trustData = JSON.parse(resp.body);
    this.maintenances = this.trustData.Maintenances;
    this.maintenances.forEach((m) => {
      m.plannedStartTime = new Date(m.plannedStartTime).toLocaleString();
      m.plannedEndTime = new Date(m.plannedEndTime).toLocaleString();
    });
  }
}
