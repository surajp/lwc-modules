import { LightningElement } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import soql from "c/soqlService";

export default class ButtonDisableTest extends NavigationMixin(LightningElement) {
  _isRendered;
  customObject;
  isNavToObjectDisabled = false;
  navRef;

  async renderedCallback() {
    if (!this._isRendered) {
      this._isRendered = true;
      this.customObject = await soql("Select Name from Account");
      this.isNavToObjectDisabled = !this.customObject || !this.customObject[0].Id;
    }
  }

  navToObject() {
    if (this.isNavToObjectDisabled) {
      return;
    }
    // store value locally to deal with "this"
    // reference changing with navigation mixin
    const objectId = this.customObject[0].Id;
    this.navRef = {
      type: "standard__recordPage",
      attributes: {
        objectApiName: "Account",
        actionName: "view",
        recordId: objectId
      }
    };
    this[NavigationMixin.Navigate](this.navRef);
  }
}
