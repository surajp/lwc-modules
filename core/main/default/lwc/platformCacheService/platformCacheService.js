import saveToPlatformCache from "@salesforce/apex/PlatformCacheService.saveToPlatformCache";
import retrieveFromPlatformCache from "@salesforce/apex/PlatformCacheService.retrieveFromPlatformCache";
import removeFromPlatformCache from "@salesforce/apex/PlatformCacheService.removeFromPlatformCache";
import isPlatformCacheEnabled from "@salesforce/apex/PlatformCacheService.isPlatformCacheEnabled";

const putAll = async (objectsToCache) => {
  return saveToPlatformCache({ keyValuePairsToCache: objectsToCache });
};

const get = async (key) => {
  return retrieveFromPlatformCache({ fullyQualifiedKeyName: key });
};

const remove = async (key) => {
  return removeFromPlatformCache({ fullyQualifiedKeyName: key });
};

const isEnabled = async () => {
  return isPlatformCacheEnabled();
};

export { putAll, get, remove, isEnabled };
