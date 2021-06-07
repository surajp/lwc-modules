/**
 * Provides methods for interacting with Plaform Cache
 *
 */
import { LightningElement } from "lwc";
import * as cache from "c/platformCacheService";

const CACHE_KEY = "theKey";
export default class PlatformCacheExample extends LightningElement {
  userInput = "";
  outputText = "";

  handleInputChange(event) {
    this.userInput = event.target.value;
  }

  handlePut() {
    const cacheInputs = {};
    cacheInputs[CACHE_KEY] = this.userInput;
    cache.putAll(cacheInputs);
  }

  async handleGet() {
    try {
      this.outputText = await cache.get(CACHE_KEY);
    } catch (err) {
      console.error(err);
    }
  }
}
