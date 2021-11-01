import saveToOrgCache from "@salesforce/apex/PlatformCacheService.saveToOrgCache";
import retrieveFromOrgCache from "@salesforce/apex/PlatformCacheService.retrieveFromOrgCache";
import removeFromOrgCache from "@salesforce/apex/PlatformCacheService.removeFromOrgCache";
import saveToSessionCache from "@salesforce/apex/PlatformCacheService.saveToSessionCache";
import retrieveFromSessionCache from "@salesforce/apex/PlatformCacheService.retrieveFromSessionCache";
import removeFromSessionCache from "@salesforce/apex/PlatformCacheService.removeFromSessionCache";
import isPlatformCacheEnabled from "@salesforce/apex/PlatformCacheService.isPlatformCacheEnabled";

let cacheEnableCheckComplete = false,
  isCacheEnabled = false;

const isEnabled = async () => {
  if (cacheEnableCheckComplete) return isCacheEnabled;
  isCacheEnabled = await isPlatformCacheEnabled();
  cacheEnableCheckComplete = true;
  return isCacheEnabled;
};

const throwIfNotEnabled = async () => {
  await isEnabled();
  if (!isCacheEnabled) throw "Please enable Platform Cache to use this module";
};

const org = {
  put: async (key, value) => {
    await throwIfNotEnabled();
    return saveToOrgCache({ cacheKey: key, value });
  },

  get: async (key) => {
    await throwIfNotEnabled();
    return retrieveFromOrgCache({ cacheKey: key });
  },

  remove: async (key) => {
    await throwIfNotEnabled();
    return removeFromOrgCache({ cacheKey: key });
  }
};

const session = {
  put: async (key, value) => {
    await throwIfNotEnabled();
    return saveToSessionCache({ cacheKey: key, value });
  },

  get: async (key) => {
    await throwIfNotEnabled();
    return retrieveFromSessionCache({ cacheKey: key });
  },

  remove: async (key) => {
    await throwIfNotEnabled();
    return removeFromSessionCache({ cacheKey: key });
  }
};
export { org, session, isEnabled };
