import saveToOrgCache from "@salesforce/apex/PlatformCacheService.saveToOrgCache";
import retrieveFromOrgCache from "@salesforce/apex/PlatformCacheService.retrieveFromOrgCache";
import removeFromOrgCache from "@salesforce/apex/PlatformCacheService.removeFromOrgCache";
import saveToSessionCache from "@salesforce/apex/PlatformCacheService.saveToSessionCache";
import retrieveFromSessionCache from "@salesforce/apex/PlatformCacheService.retrieveFromSessionCache";
import removeFromSessionCache from "@salesforce/apex/PlatformCacheService.removeFromSessionCache";
import isPlatformCacheEnabled from "@salesforce/apex/PlatformCacheService.isPlatformCacheEnabled";

const org = {
  put: async (key, value) => {
    return saveToOrgCache({ fullyQualifiedKey: key, value });
  },

  get: async (key) => {
    return retrieveFromOrgCache({ fullyQualifiedKey: key });
  },

  remove: async (key) => {
    return removeFromOrgCache({ fullyQualifiedKey: key });
  }
};

const session = {
  put: async (key, value) => {
    return saveToSessionCache({ fullyQualifiedKey: key, value });
  },

  get: async (key) => {
    return retrieveFromSessionCache({ fullyQualifiedKey: key });
  },

  remove: async (key) => {
    return removeFromSessionCache({ fullyQualifiedKey: key });
  }
};
const isEnabled = async () => {
  return isPlatformCacheEnabled();
};
export { org, session, isEnabled };
