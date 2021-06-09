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

  /**
   * Store a key value pair in default org cache
   * @param key The key against which the value will be stored in the org cache. The key will be needed to retrieve value from the cache later. For storing values in specific partitions and namespace, prefix it to the key. https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_cache_Org.htm
   * @param value The value to be stored in the cache
   *
   **/
  @AuraEnabled
  public static void saveToOrgCache(String fullyQualifiedKey, Object value) {
    Cache.Org.put(fullyQualifiedKey, value);
  }

  //Refer to https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_cache_Org.htm for details on how the key name works
  @AuraEnabled
  public static Object retrieveFromOrgCache(String fullyQualifiedKey) {
    return Cache.org.get(fullyQualifiedKey);
  }

  @AuraEnabled
  public static void removeFromOrgCache(String fullyQualifiedKey) {
    Cache.org.remove(fullyQualifiedKey);
  }

  /**
   * Store a key value pair in default session cache
   * @param key The key against which the value will be stored in the session cache. The key will be needed to retrieve value from the cache later. For storing values in specific partitions and namespace, prefix it to the key. https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_platform_cache_session_examples.htm
   * @param value The value to be stored in the cache
   *
   **/
  @AuraEnabled
  public static void saveToSessionCache(String fullyQualifiedKey, Object value) {
    Cache.session.put(fullyQualifiedKey, value);
  }

  @AuraEnabled
  public static Object retrieveFromSessionCache(String fullyQualifiedKey) {
    return Cache.session.get(fullyQualifiedKey);
  }

  @AuraEnabled
  public static void removeFromSessionCache(String fullyQualifiedKey) {
    Cache.session.remove(fullyQualifiedKey);
  }
}
