import { LightningElement } from "lwc";
import sfapi from "c/apiService";
import soql from "c/soqlService";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class ProfilesManager extends LightningElement {
  columns;
  draftValues = [];
  data = [];
  profileData = [];
  profileIdMap = {};
  filter = "";
  _query =
    "Select FIELDS(STANDARD) from Profile where Id in (Select ProfileId from PermissionSet where IsCustom=true ) and UserType='Standard' limit 15";

  get filteredData() {
    if (!this.filter) return this.data;
    const exp = this.filter.split(" ").map((f) => new RegExp(f, "i"));
    return this.data.filter((d) => exp.every((e) => e.test(d.Name)));
  }

  handleFilterUpdate(evt) {
    this.filter = evt.target.value;
  }

  _createMapOfProfileIdByName() {
    this.profileData.forEach((p) => (this.profileIdMap[p.Name] = p.Id));
  }

  _generateColumnsForProfileNames() {
    this.columns = [
      ...this.columns,
      ...this.profileData.map((p) => ({ label: p.Name, fieldName: p.Name, type: "boolean", editable: true }))
    ];
  }

  _convertColumnsToRows() {
    const permNames = Object.keys(this.profileData[0]).filter((k) => k.startsWith("Permissions"));
    this.data = permNames
      .map((k) => {
        let obj = { Name: k.replace(/^Permissions/, "") };
        this.profileData.forEach((row) => {
          obj[row.Name] = row[k];
        });
        return obj;
      })
      .sort((x, y) => x.Name > y.Name);
  }

  _transponseData() {
    this._generateColumnsForProfileNames();
    this._convertColumnsToRows();
  }

  async _fetchProfilesData() {
    this.columns = [{ label: "Name", fieldName: "Name", initialWidth: 200 }];
    try {
      this.profileData = await soql(this._query);
      this._createMapOfProfileIdByName();
      this._transponseData();
    } catch (err) {
      this.dispatchEvent(new ShowToastEvent({ variant: "error", message: "soql failed " + err.body.message }));
    }
  }

  connectedCallback() {
    this._fetchProfilesData();
  }

  handleSave(evt) {
    const profiles = this._convertDraftValuesToProfileData(evt.detail.draftValues);
    const profilesToUpdate = this._convertToSubRequests(profiles);
    this._updateProfiles(profilesToUpdate);
  }

  _convertDraftValuesToProfileData(draftValues) {
    const retVal = {};
    draftValues.forEach((d) => {
      const perm = d.Name;
      Object.keys(d).forEach((k) => {
        if (k === "Name") return;
        const id = this.profileIdMap[k];
        if (!retVal[id]) retVal[id] = {};
        let obj = retVal[id];
        obj["Permissions" + perm] = d[k];
      });
    });
    return retVal;
  }

  _convertToSubRequests(profilesToUpdate) {
    let retObj = {};
    retObj.batchRequests = Object.keys(profilesToUpdate).map((id) => {
      return {
        method: "PATCH",
        url: `v54.0/sobjects/Profile/${id}`,
        richInput: profilesToUpdate[id]
      };
    });
    return retObj;
  }

  async _updateProfiles(profilesToUpdate) {
    try {
      const resp = await sfapi("/composite/batch", "POST", {}, JSON.stringify(profilesToUpdate));
      if (resp.hasErrors) {
        let errors = this._reduceCompositeErrors(resp.results);
        this.dispatchEvent(new ShowToastEvent({ mode: "sticky", variant: "error", message: errors }));
      } else {
        this.dispatchEvent(new ShowToastEvent({ variant: "success", message: "Profiles updated" }));
        this._fetchProfilesData();
        this.draftValues = [];
      }
    } catch (err) {
      this.dispatchEvent(
        new ShowToastEvent({ mode: "sticky", variant: "error", message: "An error occurred " + err.message })
      );
    }
  }

  _reduceCompositeErrors(results) {
    let errors = results
      .reduce(
        (obj, curr) => (curr.statusCode < 399 && obj) || [...obj, ...curr.result.map((r) => r.message)] || obj,
        []
      )
      .join("\n");
    return errors;
  }
}
