import { LightningElement } from "lwc";
import sfapi from "c/apiService";
import soql from "c/soqlService";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { describeFieldInfo } from "c/describeMetadataService";

export default class ProfilesManager extends LightningElement {
  columns;
  draftValues = [];
  data = [];
  profileData = [];
  profileIdMap = {};
  filter = "";
  _pageNum = 0;
  _pageSize = 10;
  _permLabelsMap;
  tableErrors;
  _query =
    "Select FIELDS(STANDARD) from Profile where Id in (Select ProfileId from PermissionSet where IsCustom=true ) and UserType='Standard' limit 15";

  get _numPages() {
    return Math.floor(this.filteredData.length / this._pageSize);
  }

  get _effectivePageNum() {
    return Math.min(this._numPages, this._pageNum);
  }

  get filteredData() {
    if (!this.filter) return this.data;
    const exp = this.filter.split(" ").map((f) => new RegExp(f, "i"));
    return this.data.filter((d) => exp.every((e) => e.test(d.Label)));
  }

  get currentPageData() {
    return this.filteredData.slice(
      this._effectivePageNum * this._pageSize,
      (this._effectivePageNum + 1) * this._pageSize
    );
  }

  handleNext() {
    if (!this.nextDisabled) {
      this._pageNum = this._effectivePageNum;
      this._pageNum++;
    }
  }

  handlePrev() {
    if (!this.prevDisabled) {
      this._pageNum = this._effectivePageNum;
      this._pageNum--;
    }
  }

  get nextDisabled() {
    return this._effectivePageNum >= this._numPages;
  }

  get prevDisabled() {
    return this._effectivePageNum <= 0;
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
    this.data = permNames.map((perm) => {
      let obj = { Name: perm.replace(/^Permissions/, "") };
      this.profileData.forEach((profile) => {
        obj[profile.Name] = profile[perm];
      });
      return obj;
    });
    this.data.sort((x, y) => (x.Name > y.Name ? 1 : -1));
    this.getPermissionLabels();
  }

  _transponseData() {
    this._generateColumnsForProfileNames();
    this._convertColumnsToRows();
  }

  async _fetchProfilesData() {
    this.columns = [{ label: "Name", fieldName: "Label", initialWidth: 400 }];
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
    this._updateProfiles(profilesToUpdate, profiles);
  }

  _convertDraftValuesToProfileData(draftValues) {
    const retVal = {};
    draftValues.forEach((row) => {
      const perm = row.Name;
      Object.keys(row).forEach((colName) => {
        if (colName === "Name") return;
        const id = this.profileIdMap[colName];
        if (!retVal[id]) retVal[id] = {};
        retVal[id]["Permissions" + perm] = row[colName];
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

  async _updateProfiles(profilesToUpdate, profiles) {
    try {
      const resp = await sfapi("/composite/batch", "POST", {}, JSON.stringify(profilesToUpdate));
      if (resp.hasErrors) {
        let errors = this._reduceCompositeErrors(resp.results, profiles);
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

  _reduceCompositeErrors(results, profiles) {
    console.log(">>> results", results); //inspect result shape
    let errors = results
      .reduce(
        (obj, curr) => (curr.statusCode < 399 && obj) || [...obj, ...curr.result.map((r) => r.message)] || obj,
        []
      )
      .join("<br>");
    let rowErrors = {},
      tableErrors = { messages: [] };
    let profileIds = Object.keys(profiles);
    results.forEach((res, index) => {
      if (res.statusCode < 399) return;
      let profileId = profileIds[index];
      let errColName = this.profileData.filter((p) => p.Id === profileId)[0].Name;
      res.result.forEach((singleError) => {
        let matches = singleError.message.match(/permission(\(s\))?: (.*)$/);
        if (matches && matches.length > 2) {
          let rowKey = matches[2];
          if (!rowErrors[rowKey]) rowErrors[rowKey] = { messages: [], fieldNames: [] };
          rowErrors[rowKey].messages.push(singleError.message);
          rowErrors[rowKey].fieldNames.push(errColName);
        }
        tableErrors.messages.push(singleError.message);
      });
    });
    tableErrors.title = `You have ${tableErrors.messages.length} errors`;
    this.tableErrors = {
      rows: rowErrors,
      table: tableErrors
    };
    return errors;
  }

  getPermissionLabels() {
    let permFields = this.data.map((d) => "Profile.Permissions" + d.Name);
    describeFieldInfo(permFields).then((resp) => {
      this._permLabelsMap = resp.reduce((obj, desc) => {
        obj[desc.name] = desc.label;
        return obj;
      }, {});
      console.log(this._permLabelsMap);
      this.data.forEach((d) => (d.Label = this._permLabelsMap["Permissions" + d.Name]));
      this.data = [...this.data];
    });
  }
}
