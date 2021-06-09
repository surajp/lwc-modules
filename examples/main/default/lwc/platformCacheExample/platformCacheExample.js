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
    cache.session.put(CACHE_KEY, this.userInput);
  }

  async handleGet() {
    try {
      this.outputText = await cache.session.get(CACHE_KEY);
    } catch (err) {
      console.error(err);
    }
  }
}
