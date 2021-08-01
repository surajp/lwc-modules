/**
 * Provides methods for interacting with Plaform Cache
 *
 */
import { LightningElement } from "lwc";
import * as cache from "c/platformCacheService";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { reduceErrors } from "c/utils";

const CACHE_KEY = "theKey"; //fully qualified key. If partition and namespace are not specified, the value is added to 'lwcmodules' cache partition. https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_cache_Org.htm
export default class PlatformCacheExample extends LightningElement {
  userInput = "";
  outputText = "";

  async connectedCallback() {
    let isCacheEnabled = await cache.isEnabled();
    if (!isCacheEnabled) {
      this.dispatchEvent(
        new ShowToastEvent({ variant: "info", message: "Please enable Platform Cache to use this module" })
      );
    }
  }

  handleInputChange(event) {
    this.userInput = event.target.value;
  }

  async handlePut() {
    try {
      await cache.session.put(CACHE_KEY, this.userInput);
      this.dispatchEvent(new ShowToastEvent({ variant: "success", message: "Value successfully saved to cache" }));
    } catch (err) {
      const errStr = reduceErrors(err);
      this.dispatchEvent(new ShowToastEvent({ variant: "error", message: errStr.join("\n") }));
    }
  }

  async handleGet() {
    try {
      this.outputText = await cache.session.get(CACHE_KEY);
    } catch (err) {
      const errStr = reduceErrors(err);
      this.dispatchEvent(new ShowToastEvent({ variant: "error", message: errStr.join("\n") }));
    }
  }

  blobToBase64(blob) {
    var reader = new FileReader();
    return new Promise((res) => {
      reader.readAsDataURL(blob);
      reader.onloadend = function () {
        var base64data = reader.result;
        res(base64data);
      };
    });
  }

  async testDataSizeException() {
    try {
      let resp = await fetch("https://picsum.photos/1200");
      let data = await resp.blob();
      let base64data = await this.blobToBase64(data);
      await cache.session.put(CACHE_KEY, base64data); // this will exceed the maximum partition size and will result in an exception
    } catch (err) {
      console.error(err);
      const errStr = reduceErrors(err);
      this.dispatchEvent(new ShowToastEvent({ variant: "error", message: errStr.join("\n") }));
    }
  }
}
