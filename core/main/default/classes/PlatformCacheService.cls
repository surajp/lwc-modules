/************************************************************

*** @author Suraj Pillai
*** @date 06/2021
*** @description Provides methods for interacting with Platform Cache from an LWC
*** 
**/
public with sharing class PlatformCacheService {
  private static final String DEFAULTPARTITION = 'local.default';

  /****
   ** @description determines if this method was invoked in a test with @SeeAllData=true
   **/
  @TestVisible
  private static Boolean isSeeAllDataTrue() {
    Boolean seeAllData = false;
    if (!Test.isRunningTest()) {
      return seeAllData;
    }

    try {
      // this will throw an exception in a data-siloed test.
      ConnectApi.ChatterUsers.getFollowings(null, String.valueOf(UserInfo.getUserId()));
      seeAllData = true;
    } catch (UnsupportedOperationException UE) {
      // this means seeAllData != true
      System.debug(LoggingLevel.INFO, 'Caught UnsupportedOperationException');
    }
    return seeAllData;
  }

  /**
   * @description Method determines if platform cache is enabled for this org
   * Note: fail-safes to false.
   * equal to true. Use this in test contexts where cache is not available like
   * when you have to use seeAllData=true
   * @return      `Boolean`
   */
  @AuraEnabled(cacheable=true)
  public static Boolean isPlatformCacheEnabled() {
    if (isSeeAllDataTrue()) {
      return false;
    }

    Boolean cacheAvailable = false;
    try {
      Cache.Org.getPartition(DEFAULTPARTITION).getCapacity();
      cacheAvailable = true;
    } catch (Exception ex) {
      system.debug(LoggingLevel.WARN, 'Failed to get orgCache');
    }
    return cacheAvailable;
  }

  @AuraEnabled
  public static void saveToPlatformCache(Map<String, Object> keyValuePairsToCache) {
    for (String key : keyValuePairsToCache.keySet()) {
      Cache.Org.put(key, keyValuePairsToCache.get(key));
    }
  }

  //Refer to https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_cache_Org.htm for details on how the key name works
  @AuraEnabled
  public static Object retrieveFromPlatformCache(String fullyQualifiedKeyName) {
    return Cache.org.get(fullyQualifiedKeyName);
  }

  @AuraEnabled
  public static void removeFromPlatformCache(String fullyQualifiedKeyName) {
    Cache.org.remove(fullyQualifiedKeyName);
  }
}
