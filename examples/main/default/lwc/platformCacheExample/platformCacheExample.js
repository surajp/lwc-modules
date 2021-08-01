/**
 * Provides methods for interacting with Plaform Cache
 *
 */
import { LightningElement } from "lwc";
import * as cache from "c/platformCacheService";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { reduceErrors } from "c/utils";

const CACHE_KEY = "theKey"; //fully qualified key. https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_cache_Org.htm
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
    } catch (err) {
      const errStr = reduceErrors(err);
      this.dispatchEvent(new ShowToastEvent({ variant: "error", message: errStr }));
    }
  }

  async handleGet() {
    try {
      this.outputText = await cache.session.get(CACHE_KEY);
    } catch (err) {
      const errStr = reduceErrors(err);
      this.dispatchEvent(new ShowToastEvent({ variant: "error", message: errStr }));
    }
  }

  async testDataSizeException() {
    try {
      let resp = await fetch("https://www.reddit.com/r/worldnews.json");
      let data = await resp.json();
      await cache.session.put(CACHE_KEY + Math.round(Math.random() * 10000), data);
    } catch (err) {
      console.error(err);
      const errStr = reduceErrors(err);
      this.dispatchEvent(new ShowToastEvent({ variant: "error", message: errStr }));
    }
  }
}
